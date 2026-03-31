import sys
import os

# Add the current directory to sys.path to import models and database
sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from database import SessionLocal
import models

def cleanup_parents():
    db = SessionLocal()
    try:
        # Find all parents
        parents = db.query(models.Parent).all()
        
        for parent in parents:
            # Check if this is Jeevan kiran
            if "jeevan" in parent.full_name.lower() or "kiran" in parent.full_name.lower():
                print(f"Skipping parent: {parent.full_name} (ID: {parent.user_id})")
                continue
            
            print(f"Deleting parent: {parent.full_name} (ID: {parent.user_id})")
            
            # Delete associated records in correct order to satisfy FK constraints
            
            # 1. Get child IDs for this parent
            child_ids = [c.id for c in parent.children]
            
            # 2. Delete Payments (linked to Bookings)
            bookings = db.query(models.Booking).filter(models.Booking.parent_id == parent.user_id).all()
            booking_ids = [b.id for b in bookings]
            db.query(models.Payment).filter(models.Payment.booking_id.in_(booking_ids)).delete(synchronize_session=False)
            
            # 3. Delete Bookings
            db.query(models.Booking).filter(models.Booking.parent_id == parent.user_id).delete(synchronize_session=False)
            
            # 4. Delete Records linked to Children
            if child_ids:
                db.query(models.MealRecord).filter(models.MealRecord.child_id.in_(child_ids)).delete(synchronize_session=False)
                db.query(models.ActivityRecord).filter(models.ActivityRecord.child_id.in_(child_ids)).delete(synchronize_session=False)
                db.query(models.Photo).filter(models.Photo.child_id.in_(child_ids)).delete(synchronize_session=False)
                db.query(models.Notification).filter(models.Notification.child_id.in_(child_ids)).delete(synchronize_session=False)
            
            # 5. Delete Children
            db.query(models.Child).filter(models.Child.parent_id == parent.user_id).delete(synchronize_session=False)
            
            # 6. Delete Notifications linked to User
            db.query(models.Notification).filter(models.Notification.user_id == parent.user_id).delete(synchronize_session=False)
            
            # 7. Delete Messages
            db.query(models.Message).filter((models.Message.sender_id == parent.user_id) | (models.Message.receiver_id == parent.user_id)).delete(synchronize_session=False)
            
            # 8. Delete Reviews
            db.query(models.Review).filter(models.Review.parent_id == parent.user_id).delete(synchronize_session=False)
            
            # 9. Delete Parent record
            db.delete(parent)
            db.flush() # Flush to ensure parent is deleted before user
            
            # 10. Delete User record
            db.query(models.User).filter(models.User.id == parent.user_id).delete(synchronize_session=False)
            
        db.commit()
        print("Cleanup completed successfully.")
        
    except Exception as e:
        db.rollback()
        print(f"Error during cleanup: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    cleanup_parents()
