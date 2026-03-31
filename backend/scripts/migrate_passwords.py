import sys
import os

# Add parent directory to path to import backend modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import SessionLocal
import models
from utils.security import hash_password

def migrate_passwords():
    db = SessionLocal()
    try:
        users = db.query(models.User).all()
        migrated_count: int = 0
        skipped_count: int = 0
        
        print(f"Found {len(users)} users. Starting migration...")
        
        for user in users:
            # Check if password is already hashed (bcrypt hashes start with $2b$ or $2a$)
            if user.password_hash and user.password_hash.startswith("$2b$"):
                print(f"Skipping user {user.email} (already hashed)")
                skipped_count = skipped_count + 1
                continue
            
            print(f"Hashing password for user: {user.email}")
            user.password_hash = hash_password(user.password_hash)
            migrated_count = migrated_count + 1
            
        db.commit()
        print(f"Migration complete! {migrated_count} passwords hashed, {skipped_count} already hashed.")
    except Exception as e:
        db.rollback()
        print(f"Error during migration: {str(e)}")
    finally:
        db.close()

if __name__ == "__main__":
    migrate_passwords()
