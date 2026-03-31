from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from typing import List
import os
import shutil

router = APIRouter(prefix="/api/profile", tags=["profile"])

@router.get("/users-by-role/{role}", response_model=List[dict])
def get_users_by_role(role: str, db: Session = Depends(get_db)):
    # role can be Parent, Preschool, Daycare, Admin
    query = db.query(models.User).filter(models.User.role == role)
    if role != models.UserRole.ADMIN:
        query = query.filter(models.User.is_approved == True)
    users = query.all()
    results = []
    for u in users:
        full_name = u.email # Fallback
        if u.role == models.UserRole.PARENT:
            if u.parent_profile: full_name = u.parent_profile.full_name
        elif u.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
            if u.center_profile: full_name = u.center_profile.center_name
        elif u.role == models.UserRole.ADMIN:
            if u.admin_profile: full_name = u.admin_profile.full_name
            
        results.append({
            "id": u.id,
            "email": u.email,
            "full_name": full_name,
            "role": u.role.value
        })
    return results

@router.get("/pending-users", response_model=List[dict])
def get_pending_users(db: Session = Depends(get_db)):
    users = db.query(models.User).filter(models.User.is_approved == False).all()
    results = []
    for u in users:
        full_name = u.email # Fallback
        if u.role == models.UserRole.PARENT:
            if u.parent_profile: full_name = u.parent_profile.full_name
        elif u.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
            if u.center_profile: full_name = u.center_profile.center_name
        elif u.role == models.UserRole.ADMIN:
            if u.admin_profile: full_name = u.admin_profile.full_name
            
        results.append({
            "id": u.id,
            "email": u.email,
            "full_name": full_name,
            "role": u.role.value,
            "created_at": u.created_at.isoformat() if u.created_at else None
        })
    return results

@router.post("/approve-user/{user_id}")
def approve_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.is_approved = True
    
    # Update Center status if applicable
    if user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center: center.status = "Approved"
        
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
    
    from utils.email_utils import send_approval_email
    try:
        send_approval_email(user.email, full_name)
    except:
        pass
        
    return {"message": "User approved successfully"}

@router.post("/reject-user/{user_id}")
def reject_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center: center.status = "Rejected"
        
    db.delete(user)
    db.commit()
    return {"message": "User rejected and removed"}

@router.get("/{user_id}", response_model=dict)
def get_profile(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    profile_data = {
        'id': user.id,
        'email': user.email,
        'role': user.role.value,
        'created_at': user.created_at.isoformat()
    }
    
    if user.role == models.UserRole.PARENT:
        parent = db.query(models.Parent).filter(models.Parent.user_id == user_id).first()
        if parent:
            profile_data.update({
                "full_name": parent.full_name, 
                "phone": parent.phone, 
                "bio": parent.bio,
                "profile_image": parent.profile_image,
                "date_of_birth": parent.date_of_birth,
                "children": [
                    {
                        "id": c.id, 
                        "name": c.name, 
                        "age": c.age,
                        "allergies": c.allergies,
                        "medical_notes": c.medical_notes,
                        "emergency_contact": c.emergency_contact
                    } for c in parent.children
                ]
            })
    elif user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center:
            # Flatten center fields
            center_dict = {k: v for k, v in center.__dict__.items() if not k.startswith('_')}
            profile_data.update(center_dict)
    
    # Add certifications to profile data for all roles if they exist
    certs = db.query(models.Certification).filter(models.Certification.user_id == user_id).all()
    profile_data['certifications_list'] = [
        {"id": c.id, "name": c.name, "file_url": c.file_url, "created_at": c.created_at.isoformat()}
        for c in certs
    ]


    return profile_data

from utils.security import get_current_user

@router.put("/{user_id}", status_code=status.HTTP_200_OK)
def update_profile(user_id: int, profile_data: schemas.ProfileUpdate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Verify that the user is updating their own profile (or is an admin)
    if current_user["id"] != user_id:
        # Check if current_user is admin
        user_record = db.query(models.User).filter(models.User.id == current_user["id"]).first()
        if user_record.role != models.UserRole.ADMIN:
            raise HTTPException(status_code=403, detail="You can only update your own profile")

    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.role == models.UserRole.PARENT:
        parent = db.query(models.Parent).filter(models.Parent.user_id == user_id).first()
        if parent:
            if profile_data.full_name is not None:
                parent.full_name = profile_data.full_name
            if profile_data.phone is not None:
                parent.phone = profile_data.phone
            if profile_data.bio is not None:
                parent.bio = profile_data.bio
            if profile_data.profile_image is not None:
                parent.profile_image = profile_data.profile_image
            if getattr(profile_data, 'date_of_birth', None) is not None:
                parent.date_of_birth = profile_data.date_of_birth
    elif user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == user_id).first()
        if center:
            if profile_data.center_name is not None:
                center.center_name = profile_data.center_name
            if profile_data.address is not None:
                center.address = profile_data.address
            if profile_data.bio is not None:
                center.bio = profile_data.bio
            if profile_data.website is not None:
                center.website = profile_data.website
            if profile_data.profile_image is not None:
                center.profile_image = profile_data.profile_image
            if getattr(profile_data, 'date_of_birth', None) is not None:
                center.date_of_birth = profile_data.date_of_birth
            
            # Handle additional provider fields
            if profile_data.certifications is not None:
                center.certifications = profile_data.certifications
            if profile_data.years_experience is not None:
                center.years_experience = profile_data.years_experience
            if profile_data.opening_time is not None:
                center.opening_time = profile_data.opening_time
            if profile_data.closing_time is not None:
                center.closing_time = profile_data.closing_time

            
    db.commit()
    return {"message": "Profile updated successfully"}

@router.post("/{user_id}/children", status_code=status.HTTP_201_CREATED)
def add_child(user_id: int, child_data: schemas.ChildCreate, db: Session = Depends(get_db)):
    parent = db.query(models.Parent).filter(models.Parent.user_id == user_id).first()
    if not parent:
        raise HTTPException(status_code=404, detail="Parent profile not found")
        
    new_child = models.Child(
        parent_id=user_id, 
        name=child_data.name, 
        age=child_data.age,
        allergies=child_data.allergies,
        medical_notes=child_data.medical_notes,
        emergency_contact=child_data.emergency_contact
    )
    db.add(new_child)
    db.commit()
    db.refresh(new_child)
    return {
        "message": "Child added successfully", 
        "child": {
            "id": new_child.id, 
            "name": new_child.name, 
            "age": new_child.age,
            "allergies": new_child.allergies,
            "medical_notes": new_child.medical_notes,
            "emergency_contact": new_child.emergency_contact
        }
    }

@router.put("/{user_id}/children/{child_id}")
def update_child(user_id: int, child_id: int, child_data: schemas.ChildCreate, db: Session = Depends(get_db)):
    child = db.query(models.Child).filter(models.Child.id == child_id, models.Child.parent_id == user_id).first()
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
        
    child.name = child_data.name
    child.age = child_data.age
    child.allergies = child_data.allergies
    child.medical_notes = child_data.medical_notes
    child.emergency_contact = child_data.emergency_contact
    db.commit()
    return {"message": "Child updated successfully"}

@router.get("/{user_id}/children", response_model=List[schemas.Child])
def get_children(user_id: int, db: Session = Depends(get_db)):
    parent = db.query(models.Parent).filter(models.Parent.user_id == user_id).first()
    if not parent:
        raise HTTPException(status_code=404, detail="Parent profile not found")
    return parent.children

@router.delete("/{user_id}/children/{child_id}")
def delete_child(user_id: int, child_id: int, db: Session = Depends(get_db)):
    child = db.query(models.Child).filter(models.Child.id == child_id, models.Child.parent_id == user_id).first()
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
        
    db.delete(child)
    db.commit()
    return {"message": "Child deleted successfully"}

@router.post("/{user_id}/certifications", status_code=status.HTTP_201_CREATED)
async def upload_certification(
    user_id: int, 
    name: str, 
    file: UploadFile = File(...), 
    db: Session = Depends(get_db)
):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    # Ensure uploads directory exists
    os.makedirs("uploads/certifications", exist_ok=True)
    
    filename = file.filename or "cert.pdf"
    file_extension = os.path.splitext(filename)[1]
    # Use robust unique name
    import time
    file_name = f"cert_{user_id}_{int(time.time())}{file_extension}"
    file_path = os.path.join("uploads/certifications", file_name)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    file_url = f"/uploads/certifications/{file_name}"
    
    new_cert = models.Certification(
        user_id=user_id,
        name=name,
        file_url=file_url
    )
    db.add(new_cert)
    db.commit()
    db.refresh(new_cert)
    
    return {
        "message": "Certification uploaded successfully",
        "certification": {
            "id": new_cert.id,
            "name": new_cert.name,
            "file_url": new_cert.file_url
        }
    }

@router.delete("/{user_id}/certifications/{cert_id}")
def delete_certification(user_id: int, cert_id: int, db: Session = Depends(get_db)):
    cert = db.query(models.Certification).filter(
        models.Certification.id == cert_id, 
        models.Certification.user_id == user_id
    ).first()
    
    if not cert:
        raise HTTPException(status_code=404, detail="Certification not found")
        
    # Optional: Delete file from disk
    # file_path = cert.file_url.lstrip("/")
    # if os.path.exists(file_path):
    #     os.remove(file_path)
        
    db.delete(cert)
    db.commit()
    return {"message": "Certification deleted successfully"}
