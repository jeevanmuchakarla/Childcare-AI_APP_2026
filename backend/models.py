from sqlalchemy import Column, Integer, String, Float, Boolean, Date, DateTime, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from database import Base

class UserRole(str, enum.Enum):
    PARENT = "Parent"
    PRESCHOOL = "Preschool"
    DAYCARE = "Daycare"
    ADMIN = "Admin"

class CenterStatus(str, enum.Enum):
    OPEN = "Open"
    CLOSED = "Closed"
    HOLIDAY = "Holiday"
    EVENT = "Special Event"

class StaffStatus(str, enum.Enum):
    CLOCKED_IN = "Present"
    CLOCKED_OUT = "Away"
    ON_LEAVE = "On Leave"

class BookingStatus(str, enum.Enum):
    PENDING = "Pending"
    CONFIRMED = "Confirmed"
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"

class PaymentStatus(str, enum.Enum):
    PENDING = "Pending"
    PAID = "Paid"
    FAILED = "Failed"
    REFUNDED = "Refunded"

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(120), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(Enum(UserRole, values_callable=lambda x: [e.value for e in x]), nullable=False)
    is_approved = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    parent_profile = relationship('Parent', back_populates='user', uselist=False, cascade="all, delete-orphan")
    center_profile = relationship('Center', back_populates='user', uselist=False, cascade="all, delete-orphan")
    admin_profile = relationship('Admin', back_populates='user', uselist=False, cascade="all, delete-orphan")
    certifications = relationship('Certification', back_populates='user', cascade="all, delete-orphan")

class Parent(Base):
    __tablename__ = 'parents'
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    full_name = Column(String(150), nullable=False)
    phone = Column(String(20), nullable=True)
    bio = Column(Text, nullable=True)
    profile_image = Column(String(255), nullable=True)
    date_of_birth = Column(String(50), nullable=True)

    user = relationship("User", back_populates="parent_profile")
    children = relationship('Child', back_populates='parent', cascade="all, delete-orphan")

class Admin(Base):
    __tablename__ = 'admins'
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    full_name = Column(String(150), nullable=False)
    employee_id = Column(String(50), nullable=True)

    user = relationship("User", back_populates="admin_profile")

class Child(Base):
    __tablename__ = 'children'
    id = Column(Integer, primary_key=True, index=True)
    parent_id = Column(Integer, ForeignKey('parents.user_id'), nullable=False)
    name = Column(String(100), nullable=False)
    age = Column(String(50), nullable=True)
    allergies = Column(Text, nullable=True)
    medical_notes = Column(Text, nullable=True)
    emergency_contact = Column(String(100), nullable=True)

    parent = relationship("Parent", back_populates="children")
    photos = relationship('Photo', back_populates='child', cascade="all, delete-orphan")

class Center(Base): # Combined for Preschool and Daycare
    __tablename__ = 'centers'
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    center_name = Column(String(200), nullable=False)
    contact_person = Column(String(150), nullable=True)
    phone = Column(String(20), nullable=True)
    license_number = Column(String(100), nullable=True)
    capacity = Column(String(50), nullable=True)
    address = Column(Text, nullable=True)
    opening_time = Column(String(20), nullable=True)
    closing_time = Column(String(20), nullable=True)
    certifications = Column(Text, nullable=True)
    years_experience = Column(Integer, default=0)
    bio = Column(Text, nullable=True)
    website = Column(String(255), nullable=True)
    profile_image = Column(String(255), nullable=True)
    date_of_birth = Column(String(50), nullable=True)
    rating = Column(Float, default=0.0)
    classes_count = Column(Integer, default=0)
    staff_ratio = Column(String(50), nullable=True)
    review_count = Column(Integer, default=0)
    status = Column(String(20), default="Pending") # Default to Pending
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    
    # New Operational Fields
    current_status = Column(Enum(CenterStatus, values_callable=lambda x: [e.value for e in x]), default=CenterStatus.OPEN)
    status_message = Column(String(255), nullable=True)

    user = relationship("User", back_populates="center_profile")
    photos = relationship('Photo', back_populates='center', cascade="all, delete-orphan")



class Booking(Base):
    __tablename__ = 'bookings'
    id = Column(Integer, primary_key=True, index=True)
    parent_id = Column(Integer, ForeignKey('parents.user_id'), nullable=False)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    child_id = Column(Integer, ForeignKey('children.id'), nullable=True)
    
    booking_type = Column(String(50), default="childcare") # visit, childcare
    schedule_type = Column(String(50), nullable=True) # "daily", "weekly"
    status = Column(Enum(BookingStatus, values_callable=lambda x: [e.value for e in x]), default=BookingStatus.PENDING)
    booking_date = Column(Date, nullable=False)
    start_time = Column(String(100), nullable=True)
    end_time = Column(String(100), nullable=True)
    total_amount = Column(Float, nullable=True)
    
    # Detailed application fields
    parent_name = Column(String(150), nullable=True)
    parent_phone = Column(String(50), nullable=True)
    child_age_or_name = Column(String(100), nullable=True)
    notes = Column(Text, nullable=True)

    payments = relationship("Payment", back_populates="booking")

class Payment(Base):
    __tablename__ = 'payments'
    id = Column(Integer, primary_key=True, index=True)
    booking_id = Column(Integer, ForeignKey('bookings.id'), nullable=False)
    amount = Column(Float, nullable=False)
    status = Column(Enum(PaymentStatus, values_callable=lambda x: [e.value for e in x]), default=PaymentStatus.PENDING)
    payment_method = Column(String(50), nullable=True) # "Card", "Cash"
    created_at = Column(DateTime, default=datetime.utcnow)

    booking = relationship("Booking", back_populates="payments")

class Review(Base):
    __tablename__ = 'reviews'
    id = Column(Integer, primary_key=True, index=True)
    parent_id = Column(Integer, ForeignKey('parents.user_id'), nullable=False)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False) # Can be Center
    rating = Column(Integer, nullable=False)
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class Message(Base):
    __tablename__ = 'messages'
    id = Column(Integer, primary_key=True, index=True)
    sender_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    sender_role = Column(String(50), nullable=True)
    receiver_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    receiver_role = Column(String(50), nullable=True)
    content = Column(Text, nullable=False)
    image_url = Column(String(255), nullable=True) # Added for image support
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class Photo(Base):
    __tablename__ = 'photos'
    id = Column(Integer, primary_key=True, index=True)
    center_id = Column(Integer, ForeignKey('centers.user_id'), nullable=True)
    child_id = Column(Integer, ForeignKey('children.id'), nullable=True) # Added for child-specific photos
    url = Column(String(255), nullable=False)
    caption = Column(String(200), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    center = relationship("Center", back_populates="photos")
    child = relationship("Child", back_populates="photos") # Added relationship

class Notification(Base):
    __tablename__ = 'notifications'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String(150), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(50), default="info") # info, success, warning, alert
    is_read = Column(Boolean, default=False)
    child_id = Column(Integer, ForeignKey('children.id'), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class MealRecord(Base):
    __tablename__ = 'meal_records'
    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(Integer, ForeignKey('children.id'), nullable=False)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    meal_type = Column(String(50), nullable=False) # Breakfast, Lunch, Snack
    food_item = Column(String(255), nullable=False)
    amount_eaten = Column(String(50), nullable=False) # None, Some, Most, All
    created_at = Column(DateTime, default=datetime.utcnow)

class ActivityRecord(Base):
    __tablename__ = 'activity_records'
    id = Column(Integer, primary_key=True, index=True)
    child_id = Column(Integer, ForeignKey('children.id'), nullable=False)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    activity_type = Column(String(50), nullable=False) # Nap, Play, Learning, etc.
    notes = Column(Text, nullable=True)
    start_time = Column(String(100), nullable=True)
    end_time = Column(String(100), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class OTPCode(Base):
    __tablename__ = 'otp_codes'
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(120), index=True, nullable=False)
    code = Column(String(6), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    is_verified = Column(Boolean, default=False)

class Certification(Base):
    __tablename__ = 'certifications'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    name = Column(String(200), nullable=False)
    file_url = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="certifications")

class StaffMember(Base):
    __tablename__ = 'staff_members'
    id = Column(Integer, primary_key=True, index=True)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    name = Column(String(150), nullable=False)
    role = Column(String(100), nullable=False)
    status = Column(Enum(StaffStatus, values_callable=lambda x: [e.value for e in x]), default=StaffStatus.CLOCKED_OUT)
    last_seen = Column(DateTime, default=datetime.utcnow)

class ScheduleItem(Base):
    __tablename__ = 'schedule_items'
    id = Column(Integer, primary_key=True, index=True)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    time = Column(String(20), nullable=False) # e.g. "09:00 AM"
    activity = Column(String(255), nullable=False)
    is_completed = Column(Boolean, default=False)

class AIInsight(Base):
    __tablename__ = 'ai_insights'
    id = Column(Integer, primary_key=True, index=True)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String(200), nullable=False)
    content = Column(Text, nullable=False)
    type = Column(String(50), default="general") # efficiency, satisfaction, growth
    created_at = Column(DateTime, default=datetime.utcnow)

class DailyNote(Base):
    __tablename__ = 'daily_notes'
    id = Column(Integer, primary_key=True, index=True)
    provider_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    author_name = Column(String(150), nullable=True) # e.g. "Ms. Sarah"
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
