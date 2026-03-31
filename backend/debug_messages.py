from database import SessionLocal
import models
from sqlalchemy import or_, and_

def check_messages():
    db = SessionLocal()
    try:
        messages = db.query(models.Message).all()
        print(f"Total messages in DB: {len(messages)}")
        for m in messages:
            print(f"ID: {m.id}, Sender: {m.sender_id} ({m.sender_role}), Receiver: {m.receiver_id} ({m.receiver_role}), Content: {m.content}, Created: {m.created_at}")
            
        # Check specific conversation if possible
        # Let's see unique pairs
        pairs = db.query(models.Message.sender_id, models.Message.receiver_id).distinct().all()
        print(f"\nUnique pairs: {pairs}")
        
    finally:
        db.close()

if __name__ == "__main__":
    check_messages()
