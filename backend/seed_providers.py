from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models
import random

def seed_diverse_providers():
    db = SessionLocal()
    try:
        providers_data = [
            {
                "email": "little_stars@example.com",
                "role": "Preschool",
                "center_name": "Little Stars Montessori",
                "rating": 4.8,
                "exp": 12,
                "lat": 13.0827,
                "lon": 80.2707,
                "address": "12 Montessori Ave, Chennai"
            },
            {
                "email": "sunny_day@example.com",
                "role": "Daycare",
                "center_name": "Sunny Day Kids Care",
                "rating": 4.5,
                "exp": 8,
                "lat": 12.9716,
                "lon": 77.5946,
                "address": "45 Garden Road, Bangalore"
            },
            {
                "email": "global_prep@example.com",
                "role": "Preschool",
                "center_name": "Global Prep International",
                "rating": 4.9,
                "exp": 15,
                "lat": 13.0475,
                "lon": 80.2089,
                "address": "78 Executive Park, Chennai"
            },
            {
                "email": "cuddle_care@example.com",
                "role": "Daycare",
                "center_name": "Cuddle & Care Daycare",
                "rating": 4.2,
                "exp": 5,
                "lat": 13.0067,
                "lon": 80.2206,
                "address": "23 Family Street, Chennai"
            },
            {
                "email": "elite_academy@example.com",
                "role": "Preschool",
                "center_name": "Elite Early Learning Academy",
                "rating": 5.0,
                "exp": 20,
                "lat": 13.1147,
                "lon": 80.2367,
                "address": "1 Premium Plaza, Chennai"
            }
        ]

        for data in providers_data:
            # Check if exists
            existing = db.query(models.User).filter(models.User.email == data["email"]).first()
            if not existing:
                user = models.User(
                    email=data["email"],
                    password_hash="hashed_password", # Dummy
                    role=data["role"],
                    is_approved=True
                )
                db.add(user)
                db.flush()
                
                center = models.Center(
                    user_id=user.id,
                    center_name=data["center_name"],
                    rating=data["rating"],
                    years_experience=data["exp"],
                    latitude=data["lat"],
                    longitude=data["lon"],
                    address=data["address"],
                    status="Approved"
                )
                db.add(center)
                print(f"Added provider: {data['center_name']}")
        
        db.commit()
        print("Diverse providers seeded successfully.")
    except Exception as e:
        db.rollback()
        print(f"Error seeding: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_diverse_providers()
