import sys, os
sys.path.insert(0, '.')
from database import SessionLocal
import models

db = SessionLocal()
messages = db.query(models.Message).order_by(models.Message.created_at.desc()).limit(10).all()
for m in messages:
    print(f'id={m.id} sender={m.sender_id} receiver={m.receiver_id} msg={m.content}')
db.close()
