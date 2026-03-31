from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from typing import List

router = APIRouter(prefix="/api/notifications", tags=["notifications"])

@router.get("/{user_id}", response_model=List[schemas.Notification])
def get_notifications(user_id: int, db: Session = Depends(get_db)):
    return db.query(models.Notification).filter(models.Notification.user_id == user_id).order_by(models.Notification.created_at.desc()).all()

@router.post("/", response_model=schemas.Notification, status_code=status.HTTP_201_CREATED)
def create_notification(noti: schemas.NotificationCreate, db: Session = Depends(get_db)):
    new_noti = models.Notification(**noti.model_dump())
    db.add(new_noti)
    db.commit()
    db.refresh(new_noti)
    return new_noti

@router.patch("/read-all/{user_id}")
def mark_all_as_read(user_id: int, db: Session = Depends(get_db)):
    db.query(models.Notification).filter(models.Notification.user_id == user_id).update({"is_read": True})
    db.commit()
    return {"message": "All notifications marked as read"}

@router.delete("/{user_id}")
def delete_notifications(user_id: int, db: Session = Depends(get_db)):
    db.query(models.Notification).filter(models.Notification.user_id == user_id).delete()
    db.commit()
@router.post("/emergency", status_code=status.HTTP_201_CREATED)
def send_emergency_alert(provider_id: int, message: str, db: Session = Depends(get_db)):
    # Find all parents with active bookings with this provider
    active_bookings = db.query(models.Booking).filter(
        models.Booking.provider_id == provider_id,
        models.Booking.status.in_([models.BookingStatus.PENDING, models.BookingStatus.CONFIRMED])
    ).all()
    
    parent_ids = list(set([b.parent_id for b in active_bookings]))
    
    notifications = []
    for p_id in parent_ids:
        new_noti = models.Notification(
            user_id=p_id,
            title="🚨 EMERGENCY ALERT",
            message=message,
            type="alert",
            is_read=False
        )
        db.add(new_noti)
        notifications.append(new_noti)
        
    db.commit()
    return {"message": f"Emergency alert sent to {len(notifications)} parents."}
