from sqlalchemy import create_engine, text
from config import Config

def check_counts():
    engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)
    tables = [
        'activity_records', 'admins', 'ai_insights', 'bookings', 'centers', 
        'certifications', 'children', 'daily_notes', 'meal_records', 'messages', 
        'notifications', 'otp_codes', 'parents', 'payments', 'photos', 
        'reviews', 'schedule_items', 'staff_members', 'users'
    ]
    with engine.connect() as conn:
        for t in tables:
            try:
                result = conn.execute(text(f'SELECT COUNT(*) FROM {t}'))
                print(f"{t}: {result.fetchone()[0]}")
            except Exception as e:
                print(f"Error checking {t}: {e}")

if __name__ == "__main__":
    check_counts()
