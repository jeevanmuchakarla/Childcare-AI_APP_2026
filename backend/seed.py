import models
from database import SessionLocal, engine
from datetime import datetime, date

def seed_data():
    print("Dropping and recreating tables for schema sync...")
    models.Base.metadata.drop_all(bind=engine)
    models.Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        common_password = "password123"

        print("Creating Admin account...")
        admin_user = models.User(email="jeevankiran14341@gmail.com", password_hash=common_password, role=models.UserRole.ADMIN)
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        admin_profile = models.Admin(user_id=admin_user.id, full_name="Jeevan Muchakarla", employee_id="ADM-001")
        db.add(admin_profile)
        db.commit()

        print("Creating Parents...")
        parents_data = [
            {"email": "parent@test.com", "name": "Sarah Johnson", "phone": "555-0101", "bio": "Mother of two, looking for childcare centers."},
            {"email": "mark@test.com", "name": "Mark Wilson", "phone": "555-0102", "bio": "Software engineer and father of three."},
            {"email": "elena@test.com", "name": "Elena Rodriguez", "phone": "555-0103", "bio": "Busy professional needing reliable infant care."}
        ]

        created_parents = []
        for p_data in parents_data:
            user = models.User(email=p_data["email"], password_hash=common_password, role=models.UserRole.PARENT)
            db.add(user)
            db.commit()
            db.refresh(user)
            
            parent = models.Parent(user_id=user.id, full_name=p_data["name"], phone=p_data["phone"], bio=p_data["bio"])
            db.add(parent)
            created_parents.append(parent)
        db.commit()

        print("Creating Preschools...")
        preschools_data = [
            {
                "email": "preschool@test.com", 
                "name": "Little Stars Montessori", 
                "phone": "555-1234",
                "address": "123 Education Lane",
                "hours": ("08:00 AM", "04:00 PM"),
                "rating": 4.9
            },
            {
                "email": "academy@test.com", 
                "name": "Bright Minds Academy", 
                "phone": "555-5678",
                "address": "456 Learning Way",
                "hours": ("07:30 AM", "05:30 PM"),
                "rating": 4.7
            }
        ]

        for p_data in preschools_data:
            user = models.User(email=p_data["email"], password_hash=common_password, role=models.UserRole.PRESCHOOL)
            db.add(user)
            db.commit()
            db.refresh(user)
            hours = p_data.get("hours")
            opening_time = ""
            closing_time = ""
            if isinstance(hours, (list, tuple)) and len(hours) >= 2:
                opening_time = str(hours[0])
                closing_time = str(hours[1])
                
            center = models.Center(
                user_id=user.id, 
                center_name=p_data["name"], 
                phone=p_data["phone"],
                address=p_data["address"],
                opening_time=opening_time,
                closing_time=closing_time,
                rating=p_data["rating"],
                status="Approved"
            )
            db.add(center)
        db.commit()

        print("Creating Daycares...")
        daycares_data = [
            {
                "email": "daycare@test.com", 
                "name": "Happy Feet Daycare", 
                "phone": "555-9000",
                "address": "789 Toddler Trail",
                "hours": ("07:00 AM", "06:00 PM"),
                "rating": 4.8
            },
            {
                "email": "valley@test.com", 
                "name": "Green Valley Daycare", 
                "phone": "555-8000",
                "address": "321 Nature Rd",
                "hours": ("06:30 AM", "06:30 PM"),
                "rating": 4.6
            }
        ]

        for d_data in daycares_data:
            user = models.User(email=d_data["email"], password_hash=common_password, role=models.UserRole.DAYCARE)
            db.add(user)
            db.commit()
            db.refresh(user)
            hours = d_data.get("hours")
            opening_time = ""
            closing_time = ""
            if isinstance(hours, (list, tuple)) and len(hours) >= 2:
                opening_time = str(hours[0])
                closing_time = str(hours[1])

            center = models.Center(
                user_id=user.id, 
                center_name=d_data["name"], 
                phone=d_data["phone"],
                address=d_data["address"],
                opening_time=opening_time,
                closing_time=closing_time,
                rating=d_data["rating"],
                status="Approved"
            )
            db.add(center)
        db.commit()

        print("Database synchronization complete! 🚀")

    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
