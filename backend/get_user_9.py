from database import SessionLocal
import models
db = SessionLocal()
user = db.query(models.User).filter(models.User.id == 9).first()
if user:
    print(f"User 9: {user.email} | {user.role}")
else:
    print("User 9 not found")
db.close()
