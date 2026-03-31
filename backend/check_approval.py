from database import SessionLocal
import models
db = SessionLocal()
user = db.query(models.User).filter(models.User.id == 11).first()
if user:
    print(f"User 11 is_approved: {user.is_approved}")
else:
    print("User 11 not found")
db.close()
