from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from typing import List

router = APIRouter(prefix="/api/bookings", tags=["bookings"])

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=schemas.BookingResponse)
def create_booking(booking_data: schemas.BookingCreate, db: Session = Depends(get_db)):
    # Prevent duplicates for the same day/child/provider if already pending
    existing = db.query(models.Booking).filter(
        models.Booking.parent_id == booking_data.parent_id,
        models.Booking.provider_id == booking_data.provider_id,
        models.Booking.child_id == booking_data.child_id,
        models.Booking.booking_date == booking_data.booking_date,
        models.Booking.status == models.BookingStatus.PENDING
    ).first()
    
    if existing:
        return {"message": "Booking already pending for this date.", "booking": existing}

    new_booking = models.Booking(
        parent_id=booking_data.parent_id,
        provider_id=booking_data.provider_id,
        child_id=booking_data.child_id,
        booking_type=booking_data.booking_type,
        schedule_type=booking_data.schedule_type,
        booking_date=booking_data.booking_date,
        start_time=booking_data.start_time,
        end_time=booking_data.end_time,
        total_amount=booking_data.total_amount,
        parent_name=booking_data.parent_name,
        parent_phone=booking_data.parent_phone,
        child_age_or_name=booking_data.child_age_or_name,
        notes=booking_data.notes,
        status=models.BookingStatus.PENDING
    )
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)
    
    # Trigger real-time notification for the provider
    try:
        parent = db.query(models.User).filter(models.User.id == booking_data.parent_id).first()
        parent_name = parent.full_name if parent and parent.full_name else "A parent"
        
        new_noti = models.Notification(
            user_id=booking_data.provider_id,
            title="📅 New Booking Request",
            message=f"{parent_name} has requested a booking for {booking_data.booking_date}.",
            type="booking",
            is_read=False
        )
        db.add(new_noti)
        db.commit()
    except Exception as e:
        print(f"Error creating notification: {e}")
        # Don't fail the booking if notification fails
        db.rollback()
    
    return {"message": "Booking request sent!", "booking": new_booking}

@router.get("/parent/{parent_id}", response_model=List[schemas.Booking])
def get_parent_bookings(parent_id: int, db: Session = Depends(get_db)):
    bookings = db.query(models.Booking).filter(models.Booking.parent_id == parent_id).all()
    
    # Enhance with provider and child names
    for b in bookings:
        # Provider Info
        user = db.query(models.User).filter(models.User.id == b.provider_id).first()
        if user:
            b.provider_type = user.role.value
            if user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
                center = db.query(models.Center).filter(models.Center.user_id == b.provider_id).first()
                if center:
                    b.provider_name = center.center_name
        
        # Child Info
        if b.child_id:
            child = db.query(models.Child).filter(models.Child.id == b.child_id).first()
            if child:
                b.child_name = child.name
                    
    return bookings

@router.get("/provider/{provider_id}", response_model=List[schemas.Booking])
def get_provider_bookings(provider_id: int, db: Session = Depends(get_db)):
    bookings = db.query(models.Booking).filter(models.Booking.provider_id == provider_id).all()
    
    # Enhance with child names
    for b in bookings:
        if b.child_id:
            child = db.query(models.Child).filter(models.Child.id == b.child_id).first()
            if child:
                b.child_name = child.name
                
    return bookings

@router.put("/{booking_id}/status", status_code=status.HTTP_200_OK)
def update_booking_status(booking_id: int, status_update: schemas.BookingStatusUpdate, db: Session = Depends(get_db)):
    booking = db.query(models.Booking).filter(models.Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    booking.status = status_update.status
    db.commit()
    db.refresh(booking)
    
    # If confirmed, send email and notify
    if booking.status == models.BookingStatus.CONFIRMED:
        try:
            from utils.email_utils import send_booking_confirmation_email
            parent_user = db.query(models.User).filter(models.User.id == booking.parent_id).first()
            center = db.query(models.Center).filter(models.Center.user_id == booking.provider_id).first()
            if parent_user and center:
                date_str = str(booking.booking_date)
                send_booking_confirmation_email(parent_user.email, center.center_name, date_str)
                print(f"Booking confirmation email sent to {parent_user.email}")
                
                # Internal Notification for Parent
                new_noti = models.Notification(
                    user_id=booking.parent_id,
                    title="✅ Booking Confirmed",
                    message=f"Your booking with {center.center_name} for {date_str} has been confirmed.",
                    type="success",
                    is_read=False
                )
                db.add(new_noti)
        except Exception as e:
            print(f"Failed to send booking confirmation: {e}")
            pass
    
    elif booking.status == models.BookingStatus.CANCELLED:
        try:
            center = db.query(models.Center).filter(models.Center.user_id == booking.provider_id).first()
            center_name = center.center_name if center else "The provider"
            new_noti = models.Notification(
                user_id=booking.parent_id,
                title="❌ Booking Cancelled",
                message=f"Your booking with {center_name} for {booking.booking_date} has been cancelled.",
                type="warning",
                is_read=False
            )
            db.add(new_noti)
        except Exception as e:
            print(f"Failed to send cancellation notification: {e}")

    db.commit()
    return {"message": "Booking status updated", "booking": {k: v for k, v in booking.__dict__.items() if not k.startswith('_')}}

@router.get("/can_chat/{user1_id}/{user2_id}", response_model=dict)
def check_chat_permission(user1_id: int, user2_id: int, db: Session = Depends(get_db)):
    # Admin can always chat
    user1 = db.query(models.User).filter(models.User.id == user1_id).first()
    user2 = db.query(models.User).filter(models.User.id == user2_id).first()
    
    if not user1 or not user2:
        return {"can_chat": False}
        
    user1_role = user1.role.value if hasattr(user1.role, 'value') else str(user1.role)
    user2_role = user2.role.value if hasattr(user2.role, 'value') else str(user2.role)
    
    # Matching rules from message_routes.py
    # Admin can always chat
    if user1_role == "Admin" or user2_role == "Admin":
        return {"can_chat": True}
        
    # Parent → Preschool / Daycare
    if user1_role == "Parent" and user2_role in ["Preschool", "Daycare"]:
        return {"can_chat": True}
    if user2_role == "Parent" and user1_role in ["Preschool", "Daycare"]:
        return {"can_chat": True}
        
    # Fallback to booking check if needed (though rules cover most cases now)
    booking = db.query(models.Booking).filter(
        ((models.Booking.parent_id == user1_id) & (models.Booking.provider_id == user2_id)) |
        ((models.Booking.parent_id == user2_id) & (models.Booking.provider_id == user1_id)),
        models.Booking.status.in_([models.BookingStatus.CONFIRMED, models.BookingStatus.PENDING])
    ).first()
    
    return {"can_chat": booking is not None}

@router.post("/{booking_id}/pay", status_code=status.HTTP_200_OK)
def handle_payment(booking_id: int, payment_data: schemas.PaymentCreate, db: Session = Depends(get_db)):
    booking = db.query(models.Booking).filter(models.Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    payment = models.Payment(
        booking_id=booking.id,
        amount=booking.total_amount or 0.0,
        payment_method=payment_data.method,
        status=models.PaymentStatus.PAID
    )
    db.add(payment)
    booking.status = models.BookingStatus.CONFIRMED
    
    # Notify provider of payment and confirmation
    try:
        parent = db.query(models.User).filter(models.User.id == booking.parent_id).first()
        parent_name = parent.full_name if parent and parent.full_name else "A parent"
        new_noti = models.Notification(
            user_id=booking.provider_id,
            title="💰 Payment Received",
            message=f"{parent_name} has completed payment for the booking on {booking.booking_date}.",
            type="success",
            is_read=False
        )
        db.add(new_noti)
    except Exception as e:
        print(f"Error creating payment notification: {e}")

    db.commit()
    db.refresh(payment)
    
    return {"message": "Payment successful. Booking confirmed.", "payment": {k: v for k, v in payment.__dict__.items() if not k.startswith('_')}}

@router.get("/provider/{provider_id}/children", response_model=list)
def get_provider_children(provider_id: int, db: Session = Depends(get_db)):
    """Get all children who have confirmed/upcoming bookings with this provider."""
    # Get bookings for this provider that are Confirmed or Pending
    bookings = db.query(models.Booking).filter(
        models.Booking.provider_id == provider_id,
        models.Booking.status.in_([models.BookingStatus.CONFIRMED, models.BookingStatus.PENDING])
    ).all()
    
    seen_child_ids = set()
    result = []
    
    for booking in bookings:
        child_id = booking.child_id
        
        # Fallback for old/broken bookings where child_id is null
        if not child_id:
            first_child = db.query(models.Child).filter(models.Child.parent_id == booking.parent_id).first()
            if first_child:
                child_id = first_child.id
        
        if child_id and child_id not in seen_child_ids:
            seen_child_ids.add(child_id)
            child = db.query(models.Child).filter(models.Child.id == child_id).first()
            if child:
                parent = db.query(models.Parent).filter(models.Parent.user_id == child.parent_id).first()
                result.append({
                    "id": child.id,
                    "name": child.name,
                    "age": child.age or "",
                    "allergies": child.allergies or "",
                    "medical_notes": child.medical_notes or "",
                    "parent_name": parent.full_name if parent else "Unknown",
                    "parent_id": child.parent_id,
                    "booking_status": booking.status.value
                })
    
    return result
