from database import SessionLocal
import models

def cleanup():
    db = SessionLocal()
    try:
        # IDs to keep
        KEEP_IDS = [11, 12] # Suresh Preschool (11), Joseph Daycare (12)
        
        # We should also keep Admins and Parents (User IDs 1-10 usually)
        # Let's find all user IDs that are NOT Preschool/Daycare or are the ones we keep
        all_users = db.query(models.User).all()
        to_delete = []
        for u in all_users:
            if u.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
                if u.id not in KEEP_IDS:
                    to_delete.append(u)
        
        print(f"Deleting {len(to_delete)} users: {[u.id for u in to_delete]}")
        
        for user in to_delete:
            # Manually clear data that doesn't have cascades
            db.query(models.Notification).filter(models.Notification.user_id == user.id).delete(synchronize_session=False)
            db.query(models.Review).filter(models.Review.provider_id == user.id).delete(synchronize_session=False)
            db.query(models.AIInsight).filter(models.AIInsight.provider_id == user.id).delete(synchronize_session=False)
            db.query(models.DailyNote).filter(models.DailyNote.provider_id == user.id).delete(synchronize_session=False)
            db.query(models.StaffMember).filter(models.StaffMember.provider_id == user.id).delete(synchronize_session=False)
            db.query(models.ScheduleItem).filter(models.ScheduleItem.provider_id == user.id).delete(synchronize_session=False)
            db.query(models.MealRecord).filter(models.MealRecord.provider_id == user.id).delete(synchronize_session=False)
            db.query(models.ActivityRecord).filter(models.ActivityRecord.provider_id == user.id).delete(synchronize_session=False)
            
            # Special handling for bookings as they have payments
            bookings = db.query(models.Booking).filter(models.Booking.provider_id == user.id).all()
            for b in bookings:
                db.query(models.Payment).filter(models.Payment.booking_id == b.id).delete(synchronize_session=False)
                db.delete(b)

            db.query(models.Message).filter(
                (models.Message.sender_id == user.id) | 
                (models.Message.receiver_id == user.id)
            ).delete(synchronize_session=False)
            
            # Delete the user (this will cascade to parent_profile, center_profile, certifications if set)
            db.delete(user)
            print(f"Deleted user {user.id} and associated data.")
        
        db.commit()
        print("Cleanup successful.")
        
        db.commit()
        print("Cleanup successful.")
    except Exception as e:
        db.rollback()
        print(f"Error during cleanup: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    cleanup()
