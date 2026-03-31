
import os
import shutil
from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models

def cleanup():
    db = SessionLocal()
    try:
        # 1. Identify IDs to keep
        keep_emails = [
            "muchakarlaarjun@gmail.com",
            "saveethadoremon@gmail.com",
            "mjeevankiranm@gmail.com",
            "jeevanmuchakarla107@gmail.com"
        ]
        
        users_to_keep = db.query(models.User).filter(models.User.email.in_(keep_emails)).all()
        keep_ids = [u.id for u in users_to_keep]
        print(f"Keeping User IDs: {keep_ids}")

        # 2. Identify IDs to delete
        users_to_delete = db.query(models.User).filter(~models.User.id.in_(keep_ids)).all()
        delete_ids = [u.id for u in users_to_delete]
        print(f"Deleting User IDs: {delete_ids}")

        # 3. Systematic Deletion of Dependent Records
        # Note: We use keep_ids to ensure we don't delete data belonging to the users we want to keep.
        
        def delete_by_user_id(model, user_attr='user_id'):
            db.query(model).filter(getattr(model, user_attr).in_(delete_ids)).delete(synchronize_session=False)

        # Delete records for deleted users as providers/users
        delete_by_user_id(models.Notification, 'user_id')
        delete_by_user_id(models.Message, 'sender_id')
        db.query(models.Message).filter(models.Message.receiver_id.in_(delete_ids)).delete(synchronize_session=False)
        
        # Child related data
        children_to_delete = db.query(models.Child).filter(models.Child.parent_id.in_(delete_ids)).all()
        child_ids = [c.id for c in children_to_delete]
        
        db.query(models.MealRecord).filter(models.MealRecord.child_id.in_(child_ids)).delete(synchronize_session=False)
        db.query(models.ActivityRecord).filter(models.ActivityRecord.child_id.in_(child_ids)).delete(synchronize_session=False)
        db.query(models.Attendance).delete(synchronize_session=False) if hasattr(models, 'Attendance') else None
        
        # Provider related data for deleted providers
        db.query(models.MealRecord).filter(models.MealRecord.provider_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.ActivityRecord).filter(models.ActivityRecord.provider_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.StaffMember).filter(models.StaffMember.provider_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.ScheduleItem).filter(models.ScheduleItem.provider_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.AIInsight).filter(models.AIInsight.provider_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.DailyNote).filter(models.DailyNote.provider_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.Certification).filter(models.Certification.user_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.Review).filter(models.Review.provider_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.Review).filter(models.Review.parent_id.in_(delete_ids)).delete(synchronize_session=False)

        # Bookings and Payments
        bookings_to_delete = db.query(models.Booking).filter(
            (models.Booking.parent_id.in_(delete_ids)) | 
            (models.Booking.provider_id.in_(delete_ids))
        ).all()
        booking_ids = [b.id for b in bookings_to_delete]
        
        db.query(models.Payment).filter(models.Payment.booking_id.in_(booking_ids)).delete(synchronize_session=False)
        db.query(models.Booking).filter(models.Booking.id.in_(booking_ids)).delete(synchronize_session=False)

        # Profiles and Children
        db.query(models.Child).filter(models.Child.id.in_(child_ids)).delete(synchronize_session=False)
        db.query(models.Parent).filter(models.Parent.user_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.Center).filter(models.Center.user_id.in_(delete_ids)).delete(synchronize_session=False)
        db.query(models.Admin).filter(models.Admin.user_id.in_(delete_ids)).delete(synchronize_session=False)

        # Final User deletion
        db.query(models.User).filter(models.User.id.in_(delete_ids)).delete(synchronize_session=False)
        
        db.commit()
        print("Cleanup complete.")
        
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    cleanup()
