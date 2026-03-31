
import models
from database import SessionLocal
from datetime import date, timedelta

def create_bookings():
    db = SessionLocal()
    try:
        parent_id = 9 # Jeevan Muchakarla
        preschool_id = 11 # Suresh Preschool
        daycare_id = 12 # Joseph Daycare
        
        # Ensure we have a child for parent 9
        child = db.query(models.Child).filter(models.Child.parent_id == parent_id).first()
        if not child:
            child = models.Child(
                parent_id=parent_id,
                name="Jeevan Jr",
                age="4",
                allergies="None"
            )
            db.add(child)
            db.flush()
            print(f"Created child for parent {parent_id}")
            
        child_id = child.id
        
        # Create a preschool booking
        b1 = models.Booking(
            parent_id=parent_id,
            provider_id=preschool_id,
            child_id=child_id,
            booking_type="Preschool",
            schedule_type="Full Day",
            booking_date=date.today() + timedelta(days=2),
            status="Confirmed",
            total_amount=1500.0,
            parent_name="Jeevan Muchakarla",
            child_age_or_name="Jeevan Jr"
        )
        db.add(b1)
        
        # Create a daycare booking
        b2 = models.Booking(
            parent_id=parent_id,
            provider_id=daycare_id,
            child_id=child_id,
            booking_type="Daycare",
            schedule_type="Half Day",
            booking_date=date.today() + timedelta(days=1),
            status="Pending",
            total_amount=800.0,
            parent_name="Jeevan Muchakarla",
            child_age_or_name="Jeevan Jr"
        )
        db.add(b2)
        
        db.commit()
        print("Real test bookings created successfully.")
        
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_bookings()
