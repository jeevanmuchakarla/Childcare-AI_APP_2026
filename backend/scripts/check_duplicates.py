import os
import sys

# Add parent directory to path to allow importing from backend
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import SessionLocal
from models import User
from sqlalchemy import func
import models

def check_duplicates():
    db = SessionLocal()
    try:
        duplicates = db.query(User.email, func.count(User.id)).group_by(User.email).having(func.count(User.id) > 1).all()
        if not duplicates:
            print("No duplicate emails found in users table.")
        else:
            print(f"Found {len(duplicates)} duplicate emails:")
            for email, count in duplicates:
                print(f"  {email}: {count} occurrences")

        # Check specifically for the new parent
        target_user = db.query(models.User).filter(models.User.id == 16).first()
        if target_user:
            print(f"Found Target User: ID={target_user.id}, Email={target_user.email}, Role={target_user.role}, Approved={target_user.is_approved}")
        else:
            print("Target user (ID 16) not found.")
            
        # List all pending users
        pending = db.query(models.User).filter(models.User.is_approved == False).all()
        print(f"\nTotal Pending Users: {len(pending)}")
        for u in pending:
            print(f"- ID: {u.id}, Email: {u.email}, Role: {u.role}")

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_duplicates()
