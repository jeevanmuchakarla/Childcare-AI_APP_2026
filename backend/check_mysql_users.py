from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import models

# Use the same config logic
DATABASE_URL = "mysql+pymysql://root:@localhost/Childcare_db"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

try:
    users = db.query(models.User).all()
    print(f"Total users: {len(users)}")
    for u in users:
        print(f"ID: {u.id} | Email: {u.email} | Role: {u.role}")
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
