
import models
from database import SessionLocal
import datetime

def test_route():
    db = SessionLocal()
    try:
        provider_id = 11
        bookings = db.query(models.Booking).filter(models.Booking.provider_id == provider_id).all()
        print(f"Found {len(bookings)} bookings for provider {provider_id}")
        
        # Enhance with child names (same logic as in booking_routes.py)
        for b in bookings:
            if b.child_id:
                child = db.query(models.Child).filter(models.Child.id == b.child_id).first()
                if child:
                    b.child_name = child.name
                    print(f"Enhanced booking {b.id} with child name {child.name}")
        
        # Try to validate with Pydantic schema
        import schemas
        from pydantic import TypeAdapter
        adapter = TypeAdapter(list[schemas.Booking])
        validated = adapter.validate_python(bookings)
        print("Successfully validated with Pydantic!")
        print(validated[0].model_dump())
        
    except Exception as e:
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    test_route()
