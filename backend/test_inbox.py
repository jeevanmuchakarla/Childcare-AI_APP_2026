from database import SessionLocal
import models
from sqlalchemy import or_, and_

def test_inbox():
    db = SessionLocal()
    user_id = 9
    
    # Logic from message_routes.py
    senders = db.query(models.Message.sender_id).filter(models.Message.receiver_id == user_id).distinct().all()
    receivers = db.query(models.Message.receiver_id).filter(models.Message.sender_id == user_id).distinct().all()
    unique_user_ids = list(set([s[0] for s in senders] + [r[0] for r in receivers]))
    
    print(f"Inbox for user 9: {unique_user_ids}")
    
    for uid in unique_user_ids:
        user = db.query(models.User).filter(models.User.id == uid).first()
        print(f"UID: {uid}, Email: {user.email if user else 'N/A'}")
    db.close()

if __name__ == "__main__":
    test_inbox()
