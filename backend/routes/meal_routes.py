from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from typing import List

router = APIRouter(prefix="/api/meals", tags=["meals"])

@router.post("/", response_model=schemas.Meal, status_code=status.HTTP_201_CREATED)
def create_meal_record(meal_data: schemas.MealCreate, db: Session = Depends(get_db)):
    print(f"[MEAL] Incoming payload: child_id={meal_data.child_id}, provider_id={meal_data.provider_id}, meal_type='{meal_data.meal_type}', food_item='{meal_data.food_item}', amount_eaten='{meal_data.amount_eaten}'")
    new_record = models.MealRecord(
        child_id=meal_data.child_id,
        provider_id=meal_data.provider_id,
        meal_type=meal_data.meal_type,
        food_item=meal_data.food_item,
        amount_eaten=meal_data.amount_eaten
    )
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    print(f"[MEAL] ✅ Saved to DB — id={new_record.id}, created_at={new_record.created_at}")

    # Notify parent — isolated so failure here never rolls back the meal record
    try:
        child = db.query(models.Child).filter(models.Child.id == meal_data.child_id).first()
        if child:
            new_noti = models.Notification(
                user_id=child.parent_id,
                title="🍎 Meal Update",
                message=f"A meal record ({meal_data.meal_type}) has been added for {child.name}.",
                type="info",
                is_read=False
            )
            db.add(new_noti)
            db.commit()
            print(f"[MEAL] 🔔 Notification sent to parent_id={child.parent_id}")
    except Exception as e:
        db.rollback()
        print(f"[MEAL] ⚠️ Notification failed (meal was still saved): {e}")

    return new_record

@router.get("/child/{child_id}", response_model=List[schemas.Meal])
def get_child_meals(child_id: int, db: Session = Depends(get_db)):
    return db.query(models.MealRecord).filter(models.MealRecord.child_id == child_id).all()

@router.get("/provider/{provider_id}", response_model=List[schemas.Meal])
def get_provider_meals(provider_id: int, db: Session = Depends(get_db)):
    return db.query(models.MealRecord).filter(models.MealRecord.provider_id == provider_id).all()
