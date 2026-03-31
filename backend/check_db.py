from sqlalchemy import create_engine, text
from config import Config
import models

def check_db():
    engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)
    with engine.connect() as connection:
        # Check bookings
        print("--- Bookings ---")
        result = connection.execute(text("SELECT id, parent_id, provider_id, child_id, status FROM bookings LIMIT 10;"))
        for row in result:
            print(row)
        
        # Check specific booking 51
        print("\n--- Booking 51 ---")
        result = connection.execute(text("SELECT id, child_id, status FROM bookings WHERE id = 51;"))
        for row in result:
            print(row)
            
        # Check children
        print("\n--- Children ---")
        result = connection.execute(text("SELECT id, name, parent_id FROM children LIMIT 10;"))
        for row in result:
            print(row)
            
        # Check users
        print("\n--- Users ---")
        result = connection.execute(text("SELECT id, email, role FROM users LIMIT 10;"))
        for row in result:
            print(row)
        # Check meal records
        print("\n--- Meal Records ---")
        result = connection.execute(text("SELECT id, child_id, meal_type, food_item, amount_eaten, created_at FROM meal_records ORDER BY created_at DESC LIMIT 10;"))
        for row in result:
            print(row)

        # Check activity records
        print("\n--- Activity Records ---")
        result = connection.execute(text("SELECT id, child_id, activity_type, notes, created_at FROM activity_records ORDER BY created_at DESC LIMIT 10;"))
        for row in result:
            print(row)

        # Check notifications
        print("\n--- Notifications ---")
        result = connection.execute(text("SELECT id, user_id, child_id, title, message, created_at FROM notifications ORDER BY created_at DESC LIMIT 10;"))
        for row in result:
            print(row)

if __name__ == "__main__":
    try:
        check_db()
    except Exception as e:
        print(f"Error connecting to database: {e}")
