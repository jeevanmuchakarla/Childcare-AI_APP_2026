import requests
import sys

def test_conv():
    # We need a token for user 9
    # I'll try to get one if I can, but I don't know the password.
    # Actually I'll use a bypass or just check the logic again.
    
    # Alternatively, I can use a script that mocks the Depends(get_current_user)
    pass

if __name__ == "__main__":
    # Let's just use the logic in a standalone script with DB session
    from database import SessionLocal
    import models
    from sqlalchemy import or_, and_
    
    db = SessionLocal()
    user1_id = 9
    user2_id = 11
    
    messages = db.query(models.Message).filter(
        or_(
            and_(models.Message.sender_id == user1_id, models.Message.receiver_id == user2_id),
            and_(models.Message.sender_id == user2_id, models.Message.receiver_id == user1_id)
        )
    ).order_by(models.Message.created_at.asc()).all()
    
    print(f"Found {len(messages)} messages for conv (9, 11)")
    for m in messages:
        print(f"[{m.id}] {m.sender_id} -> {m.receiver_id}: {m.content}")
    db.close()
