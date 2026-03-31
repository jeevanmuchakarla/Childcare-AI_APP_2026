
import models
from database import SessionLocal, engine
from datetime import datetime, date
from utils.security import hash_password

def restore_data():
    print("Dropping and recreating tables for full restoration...")
    models.Base.metadata.drop_all(bind=engine)
    models.Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        common_password = hash_password("password123")

        # 1. Restore Users from db_output.txt and seed.py
        print("Restoring Users...")
        users_to_create = [
            # Original Seed Users (1-8)
            {"id": 1, "email": "jeevankiran14341@gmail.com", "role": models.UserRole.ADMIN, "is_approved": True},
            {"id": 2, "email": "parent@test.com", "role": models.UserRole.PARENT, "is_approved": True},
            {"id": 3, "email": "mark@test.com", "role": models.UserRole.PARENT, "is_approved": True},
            {"id": 4, "email": "elena@test.com", "role": models.UserRole.PARENT, "is_approved": True},
            {"id": 5, "email": "preschool@test.com", "role": models.UserRole.PRESCHOOL, "is_approved": True},
            {"id": 6, "email": "academy@test.com", "role": models.UserRole.PRESCHOOL, "is_approved": True},
            {"id": 7, "email": "daycare@test.com", "role": models.UserRole.DAYCARE, "is_approved": True},
            {"id": 8, "email": "valley@test.com", "role": models.UserRole.DAYCARE, "is_approved": True},
            # Missing Users from db_output.txt
            {"id": 9, "email": "jeevanmuchakarla107@gmail.com", "role": models.UserRole.PARENT, "is_approved": True},
            {"id": 11, "email": "muchakarlaarjun@gmail.com", "role": models.UserRole.PRESCHOOL, "is_approved": True},
            {"id": 12, "email": "saveethadoremon@gmail.com", "role": models.UserRole.DAYCARE, "is_approved": True},
            {"id": 13, "email": "mjeevankiranm@gmail.com", "role": models.UserRole.ADMIN, "is_approved": True},
        ]

        for u_data in users_to_create:
            user = models.User(
                id=u_data["id"], 
                email=u_data["email"], 
                password_hash=common_password, 
                role=u_data["role"], 
                is_approved=u_data["is_approved"]
            )
            db.add(user)
        db.commit()

        # 2. Restore Profiles
        print("Restoring Profiles...")
        # Admin 1
        db.add(models.Admin(user_id=1, full_name="System Admin"))
        # Admin 13
        db.add(models.Admin(user_id=13, full_name="Jeevan Admin"))
        
        # Parent 9
        db.add(models.Parent(user_id=9, full_name="Jeevan Muchakarla"))
        # Child for Parent 9
        db.add(models.Child(id=1, parent_id=9, name="Jeevan", age="5"))

        # Provider 11
        db.add(models.Center(user_id=11, center_name="Suresh Preschool", status="Approved", rating=4.5))
        # Provider 12
        db.add(models.Center(user_id=12, center_name="Joseph Daycare", status="Approved", rating=4.3))
        
        db.commit()

        # 3. Restore Bookings from db_output.txt
        print("Restoring Bookings...")
        # (51, 9, 11, 1, 'Confirmed')
        db.add(models.Booking(id=51, parent_id=9, provider_id=11, child_id=1, status=models.BookingStatus.CONFIRMED, booking_date=date.today()))
        # (52, 9, 12, 1, 'Confirmed')
        db.add(models.Booking(id=52, parent_id=9, provider_id=12, child_id=1, status=models.BookingStatus.CONFIRMED, booking_date=date.today()))
        
        db.commit()
        print("Restoration complete! 🚀")

    except Exception as e:
        db.rollback()
        print(f"Error during restoration: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    restore_data()
