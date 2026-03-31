from database import SessionLocal
import models

def cleanup():
    db = SessionLocal()
    try:
        # Find the center
        center = db.query(models.Center).filter(models.Center.center_name == "Auto Approve Center").first()
        if center:
            user_id = center.user_id
            print(f"Deleting center: {center.center_name} (User ID: {user_id})")
            
            # Delete center
            db.delete(center)
            
            # Delete associated user
            user = db.query(models.User).filter(models.User.id == user_id).first()
            if user:
                # Delete related profiles if any (Parent, Admin) - though it's a center
                db.query(models.Parent).filter(models.Parent.user_id == user_id).delete()
                db.query(models.Admin).filter(models.Admin.user_id == user_id).delete()
                db.delete(user)
                print(f"Deleted user with email: {user.email}")
            
            db.commit()
            print("Cleanup successful.")
        else:
            print("Auto Approve Center not found.")
            
        # Also check for the test users created by verify_auto_approval.py
        test_emails = ["auto_approve_test_2@example.com", "auto_approve_center_2@example.com"]
        for email in test_emails:
            user = db.query(models.User).filter(models.User.email == email).first()
            if user:
                print(f"Deleting test user: {email}")
                db.query(models.Parent).filter(models.Parent.user_id == user.id).delete()
                db.query(models.Center).filter(models.Center.user_id == user.id).delete()
                db.delete(user)
                db.commit()

    except Exception as e:
        print(f"Error during cleanup: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    cleanup()
