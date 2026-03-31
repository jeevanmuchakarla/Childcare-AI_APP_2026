from pydantic import BaseModel, ConfigDict
from datetime import datetime, date
from typing import Optional, List, Any
from models import UserRole, BookingStatus, PaymentStatus

class ChildBase(BaseModel):
    name: str
    age: Optional[str] = None
    allergies: Optional[str] = None
    medical_notes: Optional[str] = None
    emergency_contact: Optional[str] = None

class ChildCreate(ChildBase):
    pass

class Child(ChildBase):
    id: int
    parent_id: int
    model_config = ConfigDict(from_attributes=True)
    
class CertificationBase(BaseModel):
    name: str
    file_url: str

class CertificationCreate(CertificationBase):
    pass

class Certification(CertificationBase):
    id: int
    user_id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class ParentBase(BaseModel):
    full_name: str
    phone: Optional[str] = None
    bio: Optional[str] = None
    profile_image: Optional[str] = None

class Parent(ParentBase):
    user_id: int
    children: List[Child] = []
    model_config = ConfigDict(from_attributes=True)

class CenterBase(BaseModel):
    center_name: str
    contact_person: Optional[str] = None
    phone: Optional[str] = None
    license_number: Optional[str] = None
    capacity: Optional[str] = None
    address: Optional[str] = None
    opening_time: Optional[str] = None
    closing_time: Optional[str] = None
    certifications: Optional[str] = None
    years_experience: int = 0
    bio: Optional[str] = None
    profile_image: Optional[str] = None
    rating: float = 0.0
    review_count: int = 0
    status: str = "Pending"
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class Center(CenterBase):
    user_id: int
    model_config = ConfigDict(from_attributes=True)
    

class UserBase(BaseModel):
    email: str
    role: UserRole

class UserCreate(UserBase):
    password: str
    # These optional fields are used depending on role
    full_name: Optional[str] = None
    phone: Optional[str] = None
    child_name: Optional[str] = None
    child_age: Optional[str] = None
    allergies: Optional[str] = None
    medical_notes: Optional[str] = None
    emergency_contact: Optional[str] = None
    center_name: Optional[str] = None
    license_number: Optional[str] = None
    capacity: Optional[str] = None
    address: Optional[str] = None
    opening_time: Optional[str] = None
    closing_time: Optional[str] = None
    certifications: Optional[str] = None
    years_experience: Optional[int] = 0
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class User(UserBase):
    id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class UserLogin(BaseModel):
    email: str
    password: str

class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    center_name: Optional[str] = None
    address: Optional[str] = None
    bio: Optional[str] = None
    website: Optional[str] = None
    profile_image: Optional[str] = None
    date_of_birth: Optional[str] = None
    # Provider fields
    certifications: Optional[str] = None
    years_experience: Optional[int] = None
    opening_time: Optional[str] = None
    closing_time: Optional[str] = None
    classes_count: Optional[int] = None
    staff_ratio: Optional[str] = None

class BookingBase(BaseModel):
    parent_id: int
    provider_id: int
    child_id: Optional[int] = None
    booking_type: Optional[str] = "childcare"
    schedule_type: Optional[str] = "daily"
    booking_date: date
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    total_amount: Optional[float] = None
    parent_name: Optional[str] = None
    parent_phone: Optional[str] = None
    child_age_or_name: Optional[str] = None
    notes: Optional[str] = None

class BookingCreate(BookingBase):
    pass

class Booking(BookingBase):
    id: int
    status: BookingStatus
    provider_name: Optional[str] = None
    provider_type: Optional[str] = None
    child_name: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class BookingResponse(BaseModel):
    message: str
    booking: Booking

class BookingStatusUpdate(BaseModel):
    status: BookingStatus

class PaymentCreate(BaseModel):
    method: str = "Card"

class Payment(BaseModel):
    id: int
    booking_id: int
    amount: float
    status: PaymentStatus
    payment_method: Optional[str] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class ReviewBase(BaseModel):
    provider_id: int
    rating: int
    comment: Optional[str] = None

class ReviewCreate(ReviewBase):
    pass

class Review(ReviewBase):
    id: int
    parent_id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class MessageBase(BaseModel):
    receiver_id: int
    receiver_role: Optional[str] = None
    content: str
    image_url: Optional[str] = None # Added for image support

class MessageCreate(MessageBase):
    pass

class Message(MessageBase):
    id: int
    sender_id: int
    sender_role: Optional[str] = None
    is_read: bool
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class PhotoBase(BaseModel):
    url: str
    caption: Optional[str] = None

class PhotoCreate(PhotoBase):
    center_id: Optional[int] = None
    child_id: Optional[int] = None # Added for child-specific photos

class Photo(PhotoBase):
    id: int
    center_id: Optional[int] = None
    child_id: Optional[int] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class NotificationBase(BaseModel):
    user_id: int
    title: str
    message: str
    type: str = "info"
    child_id: Optional[int] = None
    is_read: bool = False

class NotificationCreate(NotificationBase):
    pass

class Notification(NotificationBase):
    id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class MealBase(BaseModel):
    child_id: int
    provider_id: int
    meal_type: str
    food_item: str
    amount_eaten: str

class MealCreate(MealBase):
    pass

class Meal(MealBase):
    id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class ActivityBase(BaseModel):
    child_id: int
    provider_id: int
    activity_type: str
    notes: Optional[str] = None
    start_time: Optional[str] = None
    end_time: Optional[str] = None

class ActivityCreate(ActivityBase):
    pass

class Activity(ActivityBase):
    id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class ForgotPasswordRequest(BaseModel):
    email: str

class VerifyOTPRequest(BaseModel):
    email: str
    code: str

class ResetPasswordRequest(BaseModel):
    email: str
    code: str
    new_password: str

# Provider Specific Schemas
class CenterStatusUpdate(BaseModel):
    current_status: str # Open, Closed, Holiday, Special Event
    status_message: Optional[str] = None

class StaffMemberBase(BaseModel):
    name: str
    role: str
    status: str = "Away"

class StaffMemberCreate(StaffMemberBase):
    pass

class StaffMember(StaffMemberBase):
    id: int
    provider_id: int
    last_seen: datetime
    model_config = ConfigDict(from_attributes=True)

class ScheduleItemBase(BaseModel):
    time: str
    activity: str
    is_completed: bool = False

class ScheduleItemCreate(ScheduleItemBase):
    pass

class ScheduleItem(ScheduleItemBase):
    id: int
    provider_id: int
    model_config = ConfigDict(from_attributes=True)

class AIInsightBase(BaseModel):
    title: str
    content: str
    type: str = "general"

class AIInsight(AIInsightBase):
    id: int
    provider_id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class ProviderSummary(BaseModel):
    classes_count: int
    capacity: str
    staff_ratio: str
    parent_status_count: int

class DailyNoteBase(BaseModel):
    content: str
    author_name: Optional[str] = None

class DailyNoteCreate(DailyNoteBase):
    pass

class DailyNote(DailyNoteBase):
    id: int
    provider_id: int
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)
