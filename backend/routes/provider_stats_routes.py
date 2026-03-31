from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from database import get_db
import models, schemas
from datetime import datetime

router = APIRouter(prefix="/api/provider-stats", tags=["provider-stats"])

@router.get("/insights/{provider_id}", response_model=List[schemas.AIInsight])
def get_ai_insights(provider_id: int, db: Session = Depends(get_db)):
    insights = db.query(models.AIInsight).filter(models.AIInsight.provider_id == provider_id).all()
    if not insights:
        # Create some default insights if none exist
        default_insights = [
            models.AIInsight(
                provider_id=provider_id,
                title="Occupancy Peak",
                content="Your center is 95% full on Tuesdays. Consider offering a 'Tuesday Special' for remaining spots.",
                type="efficiency"
            ),
            models.AIInsight(
                provider_id=provider_id,
                title="Parent Satisfaction",
                content="Recent feedback indicates high satisfaction with the 'Art & Craft' sessions. Keep it up!",
                type="satisfaction"
            )
        ]
        for insight in default_insights:
            db.add(insight)
        db.commit()
        insights = db.query(models.AIInsight).filter(models.AIInsight.provider_id == provider_id).all()
    return insights

@router.get("/status/{provider_id}", response_model=schemas.CenterStatusUpdate)
def get_center_status(provider_id: int, db: Session = Depends(get_db)):
    center = db.query(models.Center).filter(models.Center.user_id == provider_id).first()
    if not center:
        raise HTTPException(status_code=404, detail="Center not found")
    return schemas.CenterStatusUpdate(
        current_status=center.current_status.value if hasattr(center.current_status, 'value') else center.current_status,
        status_message=center.status_message
    )

@router.patch("/status/{provider_id}", response_model=schemas.CenterStatusUpdate)
def update_center_status(provider_id: int, update: schemas.CenterStatusUpdate, db: Session = Depends(get_db)):
    center = db.query(models.Center).filter(models.Center.user_id == provider_id).first()
    if not center:
        raise HTTPException(status_code=404, detail="Center not found")
    
    center.current_status = update.current_status
    center.status_message = update.status_message
    db.commit()
    db.refresh(center)
    
    # Notify parents and admin of status update
    try:
        # Get all parents with enrollments at this center
        enrolled_parent_ids = db.query(models.Booking.parent_id).filter(
            models.Booking.provider_id == provider_id
        ).distinct().all()
        
        parent_ids = [p[0] for p in enrolled_parent_ids]
        
        # Notify Parents
        for pid in parent_ids:
            db.add(models.Notification(
                user_id=pid,
                title=f"📢 {center.center_name} Status Update",
                message=f"Status changed to {update.current_status}. {update.status_message or ''}",
                type="info"
            ))
            
        # Notify Admin (Role based find)
        admins = db.query(models.User).filter(models.User.role == "Admin").all()
        for admin in admins:
            db.add(models.Notification(
                user_id=admin.id,
                title=f"🏢 Center Status Change: {center.center_name}",
                message=f"Operational status: {update.current_status}",
                type="info"
            ))
            
        db.commit()
    except Exception as e:
        print(f"Error sending status update notifications: {e}")
        
    return schemas.CenterStatusUpdate(
        current_status=center.current_status.value if hasattr(center.current_status, 'value') else center.current_status,
        status_message=center.status_message
    )

@router.get("/daily-notes/{provider_id}", response_model=List[schemas.DailyNote])
def get_daily_notes(provider_id: int, db: Session = Depends(get_db)):
    return db.query(models.DailyNote).filter(models.DailyNote.provider_id == provider_id).order_by(models.DailyNote.created_at.desc()).all()

@router.post("/daily-notes/{provider_id}", response_model=schemas.DailyNote)
def create_daily_note(provider_id: int, note: schemas.DailyNoteCreate, db: Session = Depends(get_db)):
    center = db.query(models.Center).filter(models.Center.user_id == provider_id).first()
    new_note = models.DailyNote(
        provider_id=provider_id,
        content=note.content,
        author_name=note.author_name or (center.center_name if center else "Center Admin")
    )
    db.add(new_note)
    
    # Notify parents and admin
    try:
        enrolled_parent_ids = db.query(models.Booking.parent_id).filter(
            models.Booking.provider_id == provider_id
        ).distinct().all()
        
        parent_ids = [p[0] for p in enrolled_parent_ids]
        
        # Notify Parents
        for pid in parent_ids:
            db.add(models.Notification(
                user_id=pid,
                title="📝 New Daily Note",
                message=f"A new note has been posted: {note.content[:50]}...",
                type="info"
            ))
            
        # Notify Admins
        admins = db.query(models.User).filter(models.User.role == "Admin").all()
        for admin in admins:
            db.add(models.Notification(
                user_id=admin.id,
                title=f"📝 Daily Note: {center.center_name if center else 'Center'}",
                message=f"New note: {note.content[:50]}...",
                type="info"
            ))
            
        db.commit()
    except Exception as e:
        print(f"Error sending daily note notifications: {e}")
    
    db.commit()
    db.refresh(new_note)
    return new_note

@router.get("/enrolled-parents/{provider_id}", response_model=List[dict])
def get_enrolled_parents(provider_id: int, db: Session = Depends(get_db)):
    # Get parents with bookings at this provider
    bookings = db.query(models.Booking).filter(models.Booking.provider_id == provider_id).all()
    parent_ids = set([b.parent_id for b in bookings])
    
    result = []
    for pid in parent_ids:
        parent = db.query(models.Parent).filter(models.Parent.user_id == pid).first()
        if parent:
            # Simple status check - if they have a booking today, they are "Active"
            from datetime import date
            today = date.today()
            has_booking_today = any(b.booking_date == today for b in bookings if b.parent_id == pid)
            
            result.append({
                "id": pid,
                "name": parent.full_name,
                "status": "Active" if has_booking_today else "Away",
                "last_seen": "Recently" if has_booking_today else "N/A"
            })
            
    return result


@router.get("/schedule/{provider_id}", response_model=List[schemas.ScheduleItem])
def get_schedule(provider_id: int, db: Session = Depends(get_db)):
    items = db.query(models.ScheduleItem).filter(models.ScheduleItem.provider_id == provider_id).all()
    if not items:
        # Seed default schedule
        defaults = [
            ("08:30 AM", "Morning Reception"),
            ("10:00 AM", "Morning Snack"),
            ("11:30 AM", "Story Time"),
            ("12:30 PM", "Lunch"),
            ("02:00 PM", "Nap Time"),
            ("04:30 PM", "Evening Play")
        ]
        for t, a in defaults:
            db.add(models.ScheduleItem(provider_id=provider_id, time=t, activity=a))
        db.commit()
        items = db.query(models.ScheduleItem).filter(models.ScheduleItem.provider_id == provider_id).all()
    return items

@router.post("/schedule/{provider_id}", response_model=schemas.ScheduleItem)
def add_schedule_item(provider_id: int, item: schemas.ScheduleItemCreate, db: Session = Depends(get_db)):
    new_item = models.ScheduleItem(
        provider_id=provider_id,
        time=item.time,
        activity=item.activity,
        is_completed=item.is_completed
    )
    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    return new_item

@router.get("/staff/{provider_id}", response_model=List[schemas.StaffMember])
def get_staff(provider_id: int, db: Session = Depends(get_db)):
    staff = db.query(models.StaffMember).filter(models.StaffMember.provider_id == provider_id).all()
    if not staff:
        # Seed default staff
        defaults = [
            ("Maria Garcia", "Lead Teacher"),
            ("James Wilson", "Assistant"),
            ("Sarah Chen", "Nutritionist")
        ]
        for n, r in defaults:
            db.add(models.StaffMember(provider_id=provider_id, name=n, role=r, status="Away"))
        db.commit()
        staff = db.query(models.StaffMember).filter(models.StaffMember.provider_id == provider_id).all()
    return staff

@router.patch("/staff/{staff_id}", response_model=schemas.StaffMember)
def update_staff_status(staff_id: int, status: str, db: Session = Depends(get_db)):
    member = db.query(models.StaffMember).filter(models.StaffMember.id == staff_id).first()
    if not member:
        raise HTTPException(status_code=404, detail="Staff member not found")
    member.status = status
    member.last_seen = datetime.utcnow()
    db.commit()
    db.refresh(member)
    return member

@router.get("/summary/{provider_id}", response_model=schemas.ProviderSummary)
def get_provider_summary(provider_id: int, db: Session = Depends(get_db)):
    center = db.query(models.Center).filter(models.Center.user_id == provider_id).first()
    if not center:
        raise HTTPException(status_code=404, detail="Center not found")
    
    # Calculate parent status count (e.g. parents with active bookings today)
    from datetime import date
    parent_count = db.query(models.Booking).filter(
        models.Booking.provider_id == provider_id,
        models.Booking.booking_date == date.today()
    ).distinct(models.Booking.parent_id).count()
    
    return schemas.ProviderSummary(
        classes_count=center.classes_count or 12,
        capacity=center.capacity or "86%",
        staff_ratio=center.staff_ratio or "1:8",
        parent_status_count=parent_count
    )
