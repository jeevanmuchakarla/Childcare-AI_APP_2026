from sqlalchemy.orm import Session
from database import SessionLocal
from models import User, OTPCode, Center
from sqlalchemy import text

def find_and_remove_user(email):
    db: Session = SessionLocal()
    try:
        print(f"Searching for email: {email}")
        
        # Check users table
        user = db.query(User).filter(User.email == email).first()
        if user:
            print(f"Found user in 'users' table with ID: {user.id}, Role: {user.role}")
            # The relationships have cascade="all, delete-orphan",
            # so deleting the user should delete associated profile.
            db.delete(user)
            db.commit()
            print(f"Deleted user {email} from 'users' table.")
        else:
            print(f"Email {email} not found in 'users' table.")
            
        # Check otp_codes table
        otp = db.query(OTPCode).filter(OTPCode.email == email).all()
        if otp:
            print(f"Found {len(otp)} records in 'otp_codes' table for {email}.")
            for code in otp:
                db.delete(code)
            db.commit()
            print(f"Deleted {len(otp)} records from 'otp_codes'.")
        else:
            print(f"Email {email} not found in 'otp_codes' table.")
            
        # Double check centers table if the email is stored there independently (unlikely but safe)
        # Assuming email is only in User for auth.
        
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    email_to_remove = "saveethadoremon@gmail.com"
    find_and_remove_user(email_to_remove)
