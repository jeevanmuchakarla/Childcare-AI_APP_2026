from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from sqlalchemy import func
import random
from datetime import date as dt_date

router = APIRouter(prefix="/api/admin", tags=["admin"])

@router.get("/stats")
def get_admin_stats(db: Session = Depends(get_db)):
    # Basic Counts
    total_users = db.query(func.count(models.User.id)).scalar()
    total_parents = db.query(func.count(models.Parent.user_id)).scalar()
    total_centers = db.query(func.count(models.Center.user_id)).scalar()
    
    # Bookings
    total_bookings = db.query(func.count(models.Booking.id)).scalar()
    confirmed_bookings = db.query(func.count(models.Booking.id)).filter(models.Booking.status == models.BookingStatus.CONFIRMED).scalar()
    today = dt_date.today()
    live_today_count = db.query(func.count(models.Booking.id)).filter(
        models.Booking.status.in_([models.BookingStatus.CONFIRMED, models.BookingStatus.COMPLETED]),
        models.Booking.booking_date == today
    ).scalar()
    
    # Capacity calculation
    # For now, let's sum up capacities of all centers. 
    # Since capacity is stored as a string, we might need to handle it.
    # In a real app, this would be more complex.
    total_capacity: int = 0
    centers_query = db.query(models.Center.capacity).all()
    for c in centers_query:
        if c.capacity:
            try:
                # Explicitly cast to help the type checker realize these are numbers
                c_cap = str(c.capacity if c.capacity is not None else "0")
                if c_cap.isdigit():
                    val = int(c_cap)
                    total_capacity = int(total_capacity + val)
            except (ValueError, TypeError):
                continue
    
    active_capacity_pct = (float(confirmed_bookings) / float(total_capacity) * 100.0) if total_capacity > 0 else 0.0
    match_success_pct = (float(confirmed_bookings) / float(total_bookings) * 100.0) if total_bookings > 0 else 0.0
    
    # Pending verification
    pending_count = db.query(func.count(models.User.id)).filter(models.User.is_approved == False).scalar()
    
    # Revenue (Paid Payments)
    total_revenue = db.query(func.sum(models.Payment.amount)).scalar() or 0.0
    
    return {
        "users": {
            "total": total_users,
            "parents": total_parents,
            "centers": total_centers
        },
        "bookings": {
            "total": total_bookings,
            "confirmed": confirmed_bookings,
            "live_today": live_today_count
        },
        "revenue": {
            "total_usd": float(f"{float(total_revenue or 0):.2f}")
        },
        "metrics": {
            "active_capacity": f"{active_capacity_pct:.1f}%",
            "match_success": f"{match_success_pct:.1f}%",
            "pending_verification": pending_count
        }
    }

@router.get("/users")
def list_all_users(db: Session = Depends(get_db)):
    users = db.query(models.User).all()
    results = []
    for u in users:
        results.append({
            "id": u.id,
            "email": u.email,
            "role": u.role.value,
            "created_at": u.created_at
        })
    return results

@router.get("/providers/pending")
def list_pending_providers(db: Session = Depends(get_db)):
    unapproved_users = db.query(models.User).filter(models.User.is_approved == False).all()
    results = []
    for u in unapproved_users:
        if u.role == models.UserRole.PARENT:
            parent = db.query(models.Parent).filter(models.Parent.user_id == u.id).first()
            name = parent.full_name if parent else u.email
            results.append({"id": u.id, "name": name, "type": "Parent", "status": "Pending"})
        elif u.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
            center = db.query(models.Center).filter(models.Center.user_id == u.id).first()
            name = center.center_name if center else u.email
            results.append({"id": u.id, "name": name, "type": u.role.value, "status": center.status if center else "Pending"})
        
    return results

@router.get("/users/{user_id}/details", response_model=dict)
def get_user_details(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    details = {
        "id": user.id,
        "email": user.email,
        "role": user.role.value,
        "is_approved": user.is_approved,
        "created_at": user.created_at.isoformat()
    }
    
    if user.role == models.UserRole.PARENT:
        parent = db.query(models.Parent).filter(models.Parent.user_id == user_id).first()
        if parent:
            details.update({
                "full_name": parent.full_name,
                "phone": parent.phone,
                "bio": parent.bio,
                "children": [{"id": c.id, "name": c.name, "age": c.age} for c in parent.children]
            })
    elif user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center:
            details.update({
                "center_name": center.center_name,
                "contact_person": center.contact_person,
                "phone": center.phone,
                "license_number": center.license_number,
                "capacity": center.capacity,
                "address": center.address,
                "opening_time": center.opening_time,
                "closing_time": center.closing_time,
                "certifications": center.certifications,
                "years_experience": center.years_experience,
                "rating": center.rating
            })
            
    return details

@router.post("/users/{user_id}/approve", status_code=200)
def approve_user_general(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.is_approved = True
    
    # Update Center status if applicable
    if user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center: center.status = "Approved"
    
    # Try sending email and internal notification
    from utils.email_utils import send_approval_email
    full_name = "User"
    if user.role == models.UserRole.PARENT:
        parent = db.query(models.Parent).filter(models.Parent.user_id == user_id).first()
        if parent: full_name = parent.full_name
    elif user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center: full_name = center.center_name
        
    # Internal Notification
    try:
        new_noti = models.Notification(
            user_id=user_id,
            title="🎉 Account Approved",
            message=f"Welcome {full_name}! Your account has been approved by the admin. You can now access all features.",
            type="success",
            is_read=False
        )
        db.add(new_noti)
    except Exception as e:
        print(f"Error creating approval notification: {e}")

    db.commit()
    
    # Non-blocking email attempt
    try:
        send_approval_email(user.email, full_name)
    except:
        pass
        
    return {"message": "User approved successfully"}

@router.get("/metrics/capacity")
def get_capacity_details(db: Session = Depends(get_db)):
    centers = db.query(models.Center).all()
    total_cap: int = 0
    occupied: int = 0
    today = dt_date.today()
    
    # Real capacity calculation
    for c in centers:
        if c.capacity:
            # Extract digits from string safely
            cap_str = ''.join(filter(str.isdigit, str(c.capacity)))
            if not cap_str: continue
            cap = int(cap_str)
            total_cap += cap
            
            # Real bookings for this provider mapped to today
            booked = db.query(func.count(models.Booking.id)).filter(
                models.Booking.provider_id == c.user_id,
                models.Booking.status.in_([models.BookingStatus.CONFIRMED, models.BookingStatus.COMPLETED]),
                models.Booking.booking_date == today
            ).scalar() or 0
            
            occupied += min(cap, booked)
            
    pct = (float(occupied) / float(total_cap) * 100.0) if total_cap > 0 else 0.0
    return {
        "total_capacity": total_cap,
        "occupied_seats": occupied,
        "availability_percentage": f"{pct:.1f}%",
        "trend": "+2.3% from last week" # Hardcoded trend for UI display
    }

@router.get("/metrics/live-bookings")
def get_live_bookings_today(db: Session = Depends(get_db)):
    # Fetch today's confirmed/arrived bookings
    today = dt_date.today()
    today_bookings = db.query(models.Booking).filter(
        models.Booking.status.in_([models.BookingStatus.CONFIRMED, models.BookingStatus.COMPLETED]),
        models.Booking.booking_date == today
    ).all()
    
    results = []
    for b in today_bookings:
        # Get child and center names
        child = db.query(models.Child).filter(models.Child.id == b.child_id).first() if b.child_id else None
        center = db.query(models.Center).filter(models.Center.user_id == b.provider_id).first()
        
        # Resolve child name: Child record → child_age_or_name field → fallback
        child_name = (
            (child.name if child else None)
            or getattr(b, 'child_age_or_name', None)
            or "Unknown Child"
        )
        
        results.append({
            "id": b.id,
            "child_name": child_name,
            "center_name": center.center_name if center else "Unknown Center",
            "time": b.start_time or "09:00 AM",
            "status": b.status.value
        })
    return results

@router.get("/bookings")
def get_all_bookings(db: Session = Depends(get_db)):
    bookings = db.query(models.Booking).all()
    results = []
    for b in bookings:
        child = db.query(models.Child).filter(models.Child.id == b.child_id).first() if b.child_id else None
        center = db.query(models.Center).filter(models.Center.user_id == b.provider_id).first()
        
        child_name = (
            (child.name if child else None)
            or getattr(b, 'child_age_or_name', None)
            or "Unknown Child"
        )
        
        results.append({
            "id": b.id,
            "child_name": child_name,
            "center_name": center.center_name if center else "Unknown Center",
            "booking_date": b.booking_date.isoformat() if b.booking_date else "",
            "time": b.start_time or "09:00 AM",
            "status": b.status.value
        })
    return results

    return results

@router.get("/bookings/{booking_id}")
def get_booking_details(booking_id: int, db: Session = Depends(get_db)):
    b = db.query(models.Booking).filter(models.Booking.id == booking_id).first()
    if not b:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    child = db.query(models.Child).filter(models.Child.id == b.child_id).first() if b.child_id else None
    center = db.query(models.Center).filter(models.Center.user_id == b.provider_id).first()
    parent = db.query(models.Parent).filter(models.Parent.user_id == b.parent_id).first()
    
    return {
        "id": b.id,
        "child": {
            "name": child.name if child else (b.child_age_or_name or "Unknown"),
            "age": child.age if child else ""
        },
        "provider": {
            "name": center.center_name if center else "Unknown Center",
            "type": center.user.role.value if center and center.user else "Daycare",
            "address": center.address if center else ""
        },
        "parent": {
            "name": parent.full_name if parent else (b.parent_name or "Parent"),
            "email": parent.user.email if parent and parent.user else "",
            "phone": parent.phone or b.parent_phone or ""
        },
        "booking_date": b.booking_date.isoformat() if b.booking_date else "",
        "time": f"{b.start_time} - {b.end_time}" if b.start_time and b.end_time else b.start_time,
        "status": b.status.value,
        "amount": b.total_amount or 0.0,
        "notes": b.notes or ""
    }

@router.put("/users/{user_id}/reject")
def reject_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    # Mark center as rejected if applicable
    if user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center:
            center.status = "Rejected"
            
    # For all user types, we can just delete the unapproved account entirely or keep it unapproved.
    # Deleting cleans up the system so they can register again if needed
    db.delete(user)
    db.commit()
    return {"message": "User rejected successfully"}
