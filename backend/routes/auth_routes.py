from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
import random
from datetime import datetime, timedelta
import time
from utils.email_utils import send_otp_email
from utils.security import create_access_token, hash_password, verify_password, get_current_user

router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/forgot-password", status_code=status.HTTP_200_OK)
def forgot_password(request: schemas.ForgotPasswordRequest, db: Session = Depends(get_db)):
    email = request.email.strip().lower()
    print(f"DEBUG: Forgot password request for email: {email}")
    user = db.query(models.User).filter(models.User.email == email).first()
    if not user:
        print(f"DEBUG: User not found for email: {email}")
        raise HTTPException(status_code=404, detail="User not found")
    
    print(f"DEBUG: User found: ID={user.id}")
    
    # Generate 6-digit OTP
    otp_code = str(random.randint(100000, 999999))
    expires_at = datetime.utcnow() + timedelta(minutes=10)
    
    # Store OTP
    otp_entry = models.OTPCode(email=request.email, code=otp_code, expires_at=expires_at)
    db.add(otp_entry)
    db.commit()
    
    # Send Email
    if send_otp_email(request.email, otp_code):
        return {"message": "OTP sent to your email"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send email")

@router.post("/verify-otp", status_code=status.HTTP_200_OK)
def verify_otp(request: schemas.VerifyOTPRequest, db: Session = Depends(get_db)):
    email = request.email.strip().lower()
    print(f"DEBUG: Verifying OTP for email: {email}, Code: {request.code}")
    otp_entry = db.query(models.OTPCode).filter(
        models.OTPCode.email == email,
        models.OTPCode.code == request.code,
        models.OTPCode.expires_at > datetime.utcnow(),
        models.OTPCode.is_verified == False
    ).first()
    
    if not otp_entry:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    
    otp_entry.is_verified = True
    db.commit()
    
    return {"message": "OTP verified successfully"}

@router.post("/reset-password", status_code=status.HTTP_200_OK)
def reset_password(request: schemas.ResetPasswordRequest, db: Session = Depends(get_db)):
    email = request.email.strip().lower()
    print(f"DEBUG: Resetting password for email: {email}")
    # Check if OTP was verified
    otp_entry = db.query(models.OTPCode).filter(
        models.OTPCode.email == email,
        models.OTPCode.code == request.code,
        models.OTPCode.is_verified == True
    ).first()
    
    if not otp_entry:
        raise HTTPException(status_code=400, detail="OTP verification required")
    
    user = db.query(models.User).filter(models.User.email == email).first()
    if not user:
        print(f"DEBUG: User not found for email: {email} during password reset")
        raise HTTPException(status_code=404, detail="User not found")
    
    # Update password with hash
    user.password_hash = hash_password(request.new_password)
    
    # Delete OTP after use
    db.delete(otp_entry)
    db.commit()
    
    return {"message": "Password reset successfully"}

@router.post("/register", status_code=status.HTTP_201_CREATED, response_model=dict)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    try:
        email = user.email.strip().lower()
        print(f"Registering user: {email} as {user.role}")
        
        # Check if user exists
        if db.query(models.User).filter(models.User.email == email).first():
            print(f"Registration failed: {email} already exists")
            raise HTTPException(status_code=400, detail="Email already registered")

        # All users start as approved immediately
        is_approved = True
        
        # Hash the password before storing
        hashed_password = hash_password(user.password)
        new_user = models.User(email=email, password_hash=hashed_password, role=user.role, is_approved=is_approved)
        db.add(new_user)
        db.flush() # Flush to get the ID without committing yet

        user_id = new_user.id
        if new_user.role == models.UserRole.PARENT:
            parent = models.Parent(user_id=user_id, full_name=user.full_name or '', phone=user.phone or '')
            db.add(parent)
            
            if user.child_name:
                child = models.Child(
                    parent_id=user_id,
                    name=user.child_name,
                    age=user.child_age or '',
                    allergies=user.allergies or '',
                    medical_notes=user.medical_notes or '',
                    emergency_contact=user.emergency_contact or ''
                )
                db.add(child)
                
        elif new_user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
            center = models.Center(
                user_id=user_id,
                center_name=user.center_name or '',
                contact_person=user.full_name or '',
                phone=user.phone or '',
                license_number=user.license_number or '',
                capacity=user.capacity or '',
                address=user.address or '',
                opening_time=user.opening_time or '',
                closing_time=user.closing_time or '',
                certifications=user.certifications or '',
                years_experience=user.years_experience or 0,
                latitude=user.latitude,
                longitude=user.longitude
            )
            db.add(center)

        elif new_user.role == models.UserRole.ADMIN:
            # Check if an admin already exists. If the limit is one, we should block other admin registrations.
            # Special case: Allowing Jeevan if he's the one registering, but usually one is already present.
            existing_admin = db.query(models.User).filter(models.User.role == models.UserRole.ADMIN).first()
            if existing_admin and existing_admin.email != email:
                db.rollback()
                raise HTTPException(status_code=403, detail="Admin registration is restricted. Only one administrator is allowed.")
            
            admin = models.Admin(user_id=user_id, full_name=user.full_name or '')
            db.add(admin)

        db.commit()
        db.refresh(new_user)

        # Notify Admin if it's a provider requiring approval
        if new_user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
            try:
                # Find admin users
                admins = db.query(models.User).filter(models.User.role == models.UserRole.ADMIN).all()
                provider_name = user.center_name or user.full_name or "A new provider"
                for admin in admins:
                    new_noti = models.Notification(
                        user_id=admin.id,
                        title="🆕 New Provider Registration",
                        message=f"{provider_name} has registered and requires approval.",
                        type="alert",
                        is_read=False
                    )
                    db.add(new_noti)
                db.commit()
            except Exception as e:
                print(f"Error notifying admin of new provider: {e}")
                db.rollback()
        
        # Fetch the real display name based on role
        full_name = user.full_name or user.center_name or ''
        
        # Create real access token
        access_token = create_access_token(data={"sub": str(new_user.id), "email": new_user.email})
        
        return {
            "message": "User registered successfully", 
            "user": {
                "id": new_user.id, 
                "email": new_user.email, 
                "role": new_user.role.value, 
                "created_at": new_user.created_at.isoformat(), 
                "full_name": full_name
            }, 
            "token": access_token
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        print(f"Internal Registration Error: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Registration failed: {str(e)}")

@router.post("/login", status_code=status.HTTP_200_OK)
def login(login_data: schemas.UserLogin, db: Session = Depends(get_db)):
    try:
        email = login_data.email.strip().lower()
        print(f"DEBUG: Login attempt for email: {email}")
        user = db.query(models.User).filter(models.User.email == email).first()
        
        if user:
            print(f"DEBUG: User found: ID={user.id}, Role={user.role}")
        else:
            print(f"DEBUG: User not found for email: {email}")

        if user and verify_password(login_data.password, user.password_hash):
            # Fetch display name based on role
            full_name = ''
            if user.role == models.UserRole.PARENT:
                parent = db.query(models.Parent).filter(models.Parent.user_id == user.id).first()
                if parent:
                    full_name = parent.full_name
            elif user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
                center = db.query(models.Center).filter(models.Center.user_id == user.id).first()
                if center:
                    full_name = center.center_name

            if user.role == models.UserRole.ADMIN:
                admin = db.query(models.Admin).filter(models.Admin.user_id == user.id).first()
                if admin:
                    full_name = admin.full_name
            
            # Admin approval check bypassed

            # Create real access token
            access_token = create_access_token(data={"sub": str(user.id), "email": user.email})

            print("DEBUG: Login successful, returning response")
            return {
                "message": "Login successful", 
                "user": {
                    "id": user.id, 
                    "email": user.email, 
                    "role": user.role.value, 
                    "created_at": user.created_at.isoformat(), 
                    "full_name": full_name
                }, 
                "token": access_token
            }

        print("DEBUG: Invalid credentials")
        raise HTTPException(status_code=401, detail="Invalid credentials")
    except HTTPException:
        raise
    except Exception as e:
        print(f"CRITICAL LOGIN ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
