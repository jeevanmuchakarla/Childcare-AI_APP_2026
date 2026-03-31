from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from typing import List
import os
import shutil
import uuid
from database import get_db
from sqlalchemy.orm import Session
import models, schemas

router = APIRouter(prefix="/api/upload", tags=["upload"])

# Directory to save files
UPLOAD_DIR = "static/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/image")
async def upload_image(file: UploadFile = File(...)):
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Generate unique filename
    filename = file.filename or "image.png"
    file_extension = os.path.splitext(filename)[1]
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    # Save the file
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    # Return the URL (assuming the backend is running on port 8000 and static is mounted)
    # The URL will be /static/uploads/filename
    return {"url": f"/static/uploads/{unique_filename}"}

@router.post("/profile-photo/{user_id}")
async def upload_user_profile_photo(user_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    filename = file.filename or "profile.png"
    file_extension = os.path.splitext(filename)[1]
    unique_filename = f"profile_{user_id}{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    image_url = f"/static/uploads/{unique_filename}"
    
    if user.role == models.UserRole.PARENT:
        profile = db.query(models.Parent).filter(models.Parent.user_id == user.id).first()
    elif user.role in [models.UserRole.DAYCARE, models.UserRole.PRESCHOOL]:
        profile = db.query(models.Center).filter(models.Center.user_id == user.id).first()
    else:
        profile = None
        
    if profile:
        profile.profile_image = image_url
        db.commit()
        
    return {"message": "Profile photo updated", "url": image_url}

@router.post("/child-photo/{child_id}")
async def upload_child_photo(child_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    # Verify child exists
    child = db.query(models.Child).filter(models.Child.id == child_id).first()
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
        
    # Upload image
    upload_res = await upload_image(file)
    image_url = upload_res["url"]
    
    # Create photo record
    new_photo = models.Photo(
        child_id=child_id,
        url=image_url,
        caption=f"Photo for {child.name}"
    )
    db.add(new_photo)
    db.commit()
    db.refresh(new_photo)
    
    return {"message": "Photo shared successfully", "photo": {k: v for k, v in new_photo.__dict__.items() if not k.startswith('_')}}

@router.get("/child/{child_id}", response_model=List[schemas.Photo])
def get_child_photos(child_id: int, db: Session = Depends(get_db)):
    return db.query(models.Photo).filter(models.Photo.child_id == child_id).order_by(models.Photo.created_at.desc()).all()
