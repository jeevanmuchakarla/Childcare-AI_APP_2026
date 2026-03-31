from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from database import get_db
import models, schemas
from typing import List, Dict
from sqlalchemy import or_, and_, func
from utils.security import get_current_user

router = APIRouter(prefix="/api/messages", tags=["messages"])

# New endpoints as requested
@router.post("/send-message", status_code=status.HTTP_201_CREATED)
def send_message_aliased(msg_data: schemas.MessageCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return send_message(msg_data, db, current_user)

@router.get("/get-messages", response_model=List[schemas.Message])
def get_all_messages(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user_id = current_user["id"]
    return db.query(models.Message).filter(or_(models.Message.sender_id == user_id, models.Message.receiver_id == user_id)).all()

@router.post("/", status_code=status.HTTP_201_CREATED)
def send_message(msg_data: schemas.MessageCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    sender_id = current_user["id"]
    sender_role = current_user["role"] # Expecting "Parent", "Preschool", "Daycare", "Admin"
    
    # Verify receiver exists
    receiver = db.query(models.User).filter(models.User.id == msg_data.receiver_id).first()
    if not receiver:
        raise HTTPException(status_code=404, detail="Receiver not found")
    
    receiver_role = receiver.role.value if hasattr(receiver.role, 'value') else str(receiver.role)

    # ROLE BASED MESSAGING RULES
    # Parent → Preschool / Daycare / Admin
    # Preschool → Parent / Admin
    # Daycare → Parent / Admin
    # Admin → All
    
    allowed = False
    if sender_role == "Admin":
        allowed = True
    elif sender_role == "Parent":
        if receiver_role in ["Preschool", "Daycare", "Admin"]:
            allowed = True
    elif sender_role in ["Preschool", "Daycare"]:
        if receiver_role in ["Parent", "Admin"]:
            allowed = True
            
    if not allowed:
        raise HTTPException(
            status_code=403, 
            detail=f"Messaging rule violation: {sender_role} cannot message {receiver_role}"
        )
        
    new_msg = models.Message(
        sender_id=sender_id,
        sender_role=sender_role,
        receiver_id=msg_data.receiver_id,
        receiver_role=receiver_role,
        content=msg_data.content,
        image_url=msg_data.image_url
    )
    db.add(new_msg)
    
    # Notify recipient of new message
    try:
        sender = db.query(models.User).filter(models.User.id == sender_id).first()
        sender_name = sender.full_name if sender and hasattr(sender, 'full_name') and sender.full_name else "A user"
        
        # Determine sender name properly based on role
        if sender:
            if sender.role == models.UserRole.PARENT:
                profile = db.query(models.Parent).filter(models.Parent.user_id == sender_id).first()
                if profile: sender_name = profile.full_name
            elif sender.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
                profile = db.query(models.Center).filter(models.Center.user_id == sender_id).first()
                if profile: sender_name = profile.center_name or profile.contact_person
            elif sender.role == models.UserRole.ADMIN:
                profile = db.query(models.Admin).filter(models.Admin.user_id == sender_id).first()
                if profile: sender_name = profile.full_name

        new_noti = models.Notification(
            user_id=msg_data.receiver_id,
            title="💬 New Message",
            message=f"You received a new message from {sender_name}.",
            type="info",
            is_read=False
        )
        db.add(new_noti)
    except Exception as e:
        print(f"Error creating message notification: {e}")

    db.commit()
    db.refresh(new_msg)
    
    msg_dict = {
        "id": new_msg.id,
        "sender_id": new_msg.sender_id,
        "sender_role": new_msg.sender_role,
        "receiver_id": new_msg.receiver_id,
        "receiver_role": new_msg.receiver_role,
        "content": new_msg.content,
        "image_url": new_msg.image_url,
        "is_read": new_msg.is_read,
        "created_at": new_msg.created_at
    }
    
    if isinstance(msg_dict['created_at'], datetime):
        msg_dict['created_at'] = msg_dict['created_at'].isoformat() + "Z"

    return {"message": "Message sent!", "data": msg_dict}

@router.get("/conversation/{user2_id}", response_model=List[schemas.Message])
def get_conversation(user2_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user1_id = current_user["id"]
    print(f"DEBUG: get_conversation user1={user1_id}, user2={user2_id}")
    
    messages = db.query(models.Message).filter(
        or_(
            and_(models.Message.sender_id == user1_id, models.Message.receiver_id == user2_id),
            and_(models.Message.sender_id == user2_id, models.Message.receiver_id == user1_id)
        )
    ).order_by(models.Message.created_at.asc()).all()
    
    print(f"DEBUG: Found {len(messages)} messages")
    
    formatted_messages = []
    for m in messages:
        m_dict = {
            "id": m.id,
            "sender_id": m.sender_id,
            "sender_role": m.sender_role,
            "receiver_id": m.receiver_id,
            "receiver_role": m.receiver_role,
            "content": m.content,
            "image_url": m.image_url,
            "is_read": m.is_read,
            "created_at": m.created_at.isoformat() + "Z" if isinstance(m.created_at, datetime) else str(m.created_at)
        }
        formatted_messages.append(m_dict)
    
    # Mark as read
    for m in messages:
        if m.receiver_id == user1_id:
            m.is_read = True
    db.commit()
    
    return formatted_messages

@router.get("/inbox")
def get_inbox_summary(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user_id = current_user["id"]
    # Find all unique users this user has messaged or been messaged by
    senders = db.query(models.Message.sender_id).filter(models.Message.receiver_id == user_id).distinct().all()
    receivers = db.query(models.Message.receiver_id).filter(models.Message.sender_id == user_id).distinct().all()
    
    unique_user_ids = list(set([s[0] for s in senders] + [r[0] for r in receivers]))
    
    inbox = []
    for uid in unique_user_ids:
        user = db.query(models.User).filter(models.User.id == uid).first()
        last_msg = db.query(models.Message).filter(
            or_(
                and_(models.Message.sender_id == user_id, models.Message.receiver_id == uid),
                and_(models.Message.sender_id == uid, models.Message.receiver_id == user_id)
            )
        ).order_by(models.Message.created_at.desc()).first()
        
        if user and last_msg:
            # Get proper name and role
            role_val = user.role.value if hasattr(user.role, 'value') else str(user.role)
            full_name = None
            center_name = None
            
            if user.role == models.UserRole.PARENT:
                profile = db.query(models.Parent).filter(models.Parent.user_id == uid).first()
                if profile: full_name = profile.full_name
            elif user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
                profile = db.query(models.Center).filter(models.Center.user_id == uid).first()
                if profile: center_name = profile.center_name
            elif user.role == models.UserRole.ADMIN:
                profile = db.query(models.Admin).filter(models.Admin.user_id == uid).first()
                if profile: full_name = profile.full_name

            ts = last_msg.created_at
            if isinstance(ts, datetime):
                ts_str = ts.isoformat() + "Z"
            else:
                ts_str = str(ts)

            inbox.append({
                "user_id": uid,
                "email": user.email,
                "full_name": full_name,
                "center_name": center_name,
                "user_role": role_val,
                "last_message": last_msg.content,
                "timestamp": ts_str,
                "image_url": last_msg.image_url,
                "is_read": last_msg.is_read if last_msg.receiver_id == user_id else True
            })
            
    return sorted(inbox, key=lambda x: x['timestamp'], reverse=True)

@router.get("/unread_count")
def get_unread_counts(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user_id = current_user["id"]
    """Returns count of unread messages grouped by sender role for badge updates."""
    # Optimized: Use a join to get roles directly in the query
    results = db.query(models.User.role, func.count(models.Message.id)) \
        .join(models.Message, models.User.id == models.Message.sender_id) \
        .filter(models.Message.receiver_id == user_id, models.Message.is_read == False) \
        .group_by(models.User.role) \
        .all()
    
    role_counts = {role.value: count for role, count in results}
    total_unread = sum(role_counts.values())
    
    return {"unread_by_role": role_counts, "total_unread": total_unread}

@router.post("/mark_read/{sender_id}")
def mark_conversation_read(sender_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user_id = current_user["id"]
    """Marks all messages from sender_id to user_id as read."""
    db.query(models.Message).filter(
        models.Message.receiver_id == user_id,
        models.Message.sender_id == sender_id,
        models.Message.is_read == False
    ).update({"is_read": True})
    db.commit()
    return {"status": "ok"}

@router.delete("/conversation/{user2_id}")
def clear_conversation(user2_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user1_id = current_user["id"]
    """Permanently deletes all messages between two users."""
    db.query(models.Message).filter(
        or_(
            and_(models.Message.sender_id == user1_id, models.Message.receiver_id == user2_id),
            and_(models.Message.sender_id == user2_id, models.Message.receiver_id == user1_id)
        )
    ).delete(synchronize_session=False)
    db.commit()
    return {"status": "ok", "message": "Conversation cleared"}
