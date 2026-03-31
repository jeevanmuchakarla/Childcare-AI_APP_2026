from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from typing import List

router = APIRouter(prefix="/api/reviews", tags=["reviews"])

@router.post("/", status_code=status.HTTP_201_CREATED)
def create_review(review_data: schemas.ReviewCreate, parent_id: int, db: Session = Depends(get_db)):
    # Verify parent exists
    parent = db.query(models.Parent).filter(models.Parent.user_id == parent_id).first()
    if not parent:
        raise HTTPException(status_code=404, detail="Parent not found")
        
    # Verify provider exists
    provider = db.query(models.User).filter(models.User.id == review_data.provider_id).first()
    if not provider or provider.role == models.UserRole.PARENT:
        raise HTTPException(status_code=404, detail="Provider not found")
        
    new_review = models.Review(
        parent_id=parent_id,
        provider_id=review_data.provider_id,
        rating=review_data.rating,
        comment=review_data.comment
    )
    db.add(new_review)
    
    # Update provider aggregate rating
    p = db.query(models.Center).filter(models.Center.user_id == provider.id).first()
        
    if p:
        total_rating = p.rating * p.review_count
        p.review_count += 1
        p.rating = (total_rating + review_data.rating) / p.review_count

    db.commit()
    db.refresh(new_review)
    return {"message": "Review posted!", "review": {k: v for k, v in new_review.__dict__.items() if not k.startswith('_')}}

@router.get("/provider/{provider_id}", response_model=List[schemas.Review])
def get_provider_reviews(provider_id: int, db: Session = Depends(get_db)):
    reviews = db.query(models.Review).filter(models.Review.provider_id == provider_id).all()
    return reviews
