from database import SessionLocal
import models

def approve_all_centers():
    db = SessionLocal()
    try:
        centers = db.query(models.Center).all()
        for center in centers:
            center.status = "Approved"
        
        users = db.query(models.User).filter(models.User.role.in_(["Preschool", "Daycare"])).all()
        for user in users:
            user.is_approved = True
            
        db.commit()
        print(f"Approved {len(centers)} centers and {len(users)} provider users.")
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    approve_all_centers()
