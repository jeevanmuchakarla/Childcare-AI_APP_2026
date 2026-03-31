from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from typing import List

router = APIRouter(prefix="/api/activities", tags=["activities"])

@router.post("/", response_model=schemas.Activity, status_code=status.HTTP_201_CREATED)
def create_activity_record(activity: schemas.ActivityCreate, db: Session = Depends(get_db)):
    print(f"[ACTIVITY] Incoming payload: child_id={activity.child_id}, provider_id={activity.provider_id}, type='{activity.activity_type}', notes='{activity.notes}'")
    new_record = models.ActivityRecord(
        child_id=activity.child_id,
        provider_id=activity.provider_id,
        activity_type=activity.activity_type,
        notes=activity.notes,
        start_time=activity.start_time,
        end_time=activity.end_time
    )
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    print(f"[ACTIVITY] ✅ Saved to DB — id={new_record.id}, created_at={new_record.created_at}")

    # Notify parent — isolated so failure here never rolls back the activity
    try:
        child = db.query(models.Child).filter(models.Child.id == activity.child_id).first()
        if child:
            new_noti = models.Notification(
                user_id=child.parent_id,
                title="📚 Daily Update",
                message=f"A new activity ({activity.activity_type}) has been recorded for {child.name}.",
                type="info",
                is_read=False
            )
            db.add(new_noti)
            db.commit()
            print(f"[ACTIVITY] 🔔 Notification sent to parent_id={child.parent_id}")
    except Exception as e:
        db.rollback()
        print(f"[ACTIVITY] ⚠️ Notification failed (activity was still saved): {e}")

    return new_record

@router.get("/child/{child_id}", response_model=List[schemas.Activity])
def get_child_activities(child_id: int, db: Session = Depends(get_db)):
    return db.query(models.ActivityRecord).filter(models.ActivityRecord.child_id == child_id).order_by(models.ActivityRecord.created_at.desc()).all()

@router.get("/provider/{provider_id}", response_model=List[schemas.Activity])
def get_provider_activities(provider_id: int, db: Session = Depends(get_db)):
    return db.query(models.ActivityRecord).filter(models.ActivityRecord.provider_id == provider_id).order_by(models.ActivityRecord.created_at.desc()).all()

@router.delete("/child/{child_id}/clear")
def clear_child_records(child_id: int, db: Session = Depends(get_db)):
    print(f"DEBUG: clear_child_records called for child {child_id}")
    db.query(models.ActivityRecord).filter(models.ActivityRecord.child_id == child_id).delete()
    db.query(models.MealRecord).filter(models.MealRecord.child_id == child_id).delete()
    db.commit()
    return {"message": "All previous records cleared for child"}

from datetime import datetime

@router.delete("/child/{child_id}/clear_past")
def clear_past_child_records(child_id: int, db: Session = Depends(get_db)):
    print(f"DEBUG: clear_past_child_records called for child {child_id}")
    today_utc = datetime.utcnow().date()
    
    # Delete past activities
    db.query(models.ActivityRecord).filter(
        models.ActivityRecord.child_id == child_id,
        models.ActivityRecord.created_at < today_utc
    ).delete()
    
    # Delete past meals
    db.query(models.MealRecord).filter(
        models.MealRecord.child_id == child_id,
        models.MealRecord.created_at < today_utc
    ).delete()
    
    db.commit()
    return {"message": "Past records cleared for child"}
