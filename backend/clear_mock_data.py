import os
import sys

# Define base dir explicitly
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(BASE_DIR)

from sqlalchemy.orm import Session
from database import SessionLocal
import models

def clear_mock_data():
    db: Session = SessionLocal()
    try:
        # Identify mock users based on email
        mock_emails = [
            "admin@test.com",
            "parent@test.com",
            "mark@test.com",
            "elena@test.com",
            "preschool@test.com",
            "academy@test.com",
            "daycare@test.com",
            "valley@test.com",
            "sarah@test.com",
            "info@test.com",
            "contact@test.com"
        ]
        
        users_to_delete = db.query(models.User).filter(models.User.email.in_(mock_emails)).all()
        user_ids_to_delete = [u.id for u in users_to_delete]
        
        count = len(users_to_delete)
        if count == 0:
            print("No mock users found.")
            return

        print(f"Found {count} mock users to delete. Proceeding with cascade deletion...")
        
        # 1. Delete dependent records that don't have cascade delete setup or need explicit handling
        
        # Delete Payments linked to Bookings linked to these users
        bookings = db.query(models.Booking).filter(
            (models.Booking.parent_id.in_(user_ids_to_delete)) | 
            (models.Booking.provider_id.in_(user_ids_to_delete))
        ).all()
        booking_ids = [b.id for b in bookings]
        if booking_ids:
            db.query(models.Payment).filter(models.Payment.booking_id.in_(booking_ids)).delete(synchronize_session=False)

        # Delete Bookings
        db.query(models.Booking).filter(
            (models.Booking.parent_id.in_(user_ids_to_delete)) | 
            (models.Booking.provider_id.in_(user_ids_to_delete))
        ).delete(synchronize_session=False)

        # Delete Meal & Activity Records
        db.query(models.MealRecord).filter(models.MealRecord.provider_id.in_(user_ids_to_delete)).delete(synchronize_session=False)
        db.query(models.ActivityRecord).filter(models.ActivityRecord.provider_id.in_(user_ids_to_delete)).delete(synchronize_session=False)

        # Delete Reviews
        db.query(models.Review).filter(
            (models.Review.parent_id.in_(user_ids_to_delete)) | 
            (models.Review.provider_id.in_(user_ids_to_delete))
        ).delete(synchronize_session=False)

        # Delete Messages
        db.query(models.Message).filter(
            (models.Message.sender_id.in_(user_ids_to_delete)) | 
            (models.Message.receiver_id.in_(user_ids_to_delete))
        ).delete(synchronize_session=False)

        # Delete Notifications
        db.query(models.Notification).filter(models.Notification.user_id.in_(user_ids_to_delete)).delete(synchronize_session=False)
        
        # 2. Now delete the users (cascade will handle parent/center/admin/child/certifications)
        for user in users_to_delete:
            db.delete(user)
            
        db.commit()
        print(f"Successfully deleted {count} mock users and all associated dynamic data.")
            
    except Exception as e:
        print(f"Error clearing mock data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    clear_mock_data()
