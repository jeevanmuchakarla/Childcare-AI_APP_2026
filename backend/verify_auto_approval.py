
import sys
import os
from sqlalchemy.orm import Session

# Add backend to path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(current_dir)

from database import SessionLocal, engine
import models

def verify_auto_approval():
    db: Session = SessionLocal()
    try:
        # Create a test user
        test_email = "auto_approve_test_2@example.com"
        
        # Check if exists and delete
        old_user = db.query(models.User).filter(models.User.email == test_email).first()
        if old_user:
            # Delete associated records
            db.query(models.Parent).filter(models.Parent.user_id == old_user.id).delete()
            db.query(models.Center).filter(models.Center.user_id == old_user.id).delete()
            db.delete(old_user)
            db.commit()
            
        new_user = models.User(
            email=test_email,
            password_hash="test",
            role="Parent"
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        
        print(f"User {test_email} created. is_approved: {new_user.is_approved}")
        
        # Create a test parent profile
        new_parent = models.Parent(
            user_id=new_user.id,
            full_name="Auto Approve Parent"
        )
        db.add(new_parent)
        db.commit()
        
        # Create a test center (for provider role check)
        test_center_email = "auto_approve_center_2@example.com"
        old_center_user = db.query(models.User).filter(models.User.email == test_center_email).first()
        if old_center_user:
            db.query(models.Center).filter(models.Center.user_id == old_center_user.id).delete()
            db.delete(old_center_user)
            db.commit()
            
        center_user = models.User(
            email=test_center_email,
            password_hash="test",
            role="Preschool"
        )
        db.add(center_user)
        db.commit()
        db.refresh(center_user)
        
        new_center = models.Center(
            user_id=center_user.id,
            center_name="Auto Approve Center",
            address="123 Test St",
            contact_person="Test Contact"
        )
        db.add(new_center)
        db.commit()
        db.refresh(new_center)
        
        print(f"Center User {test_center_email} created. is_approved: {center_user.is_approved}")
        print(f"Center created. status: {new_center.status}")
        
        if new_user.is_approved == True and center_user.is_approved == True and new_center.status == "Approved":
            print("SUCCESS: Auto-approval working correctly for Parents and Centers!")
        else:
            print("FAILURE: Auto-approval NOT working as expected.")
            
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    verify_auto_approval()
