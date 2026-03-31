from sqlalchemy import create_engine, text
from config import Config

def migrate():
    engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)
    with engine.connect() as conn:
        print("Adding 'child_id' column to 'notifications' table...")
        try:
            # Add column
            conn.execute(text("ALTER TABLE notifications ADD COLUMN child_id INT NULL"))
            # Add foreign key constraint
            conn.execute(text("ALTER TABLE notifications ADD CONSTRAINT fk_notifications_child_id FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE SET NULL"))
            # Commit the changes (SQLAlchemy connect handles this usually, but text() might need explicit commit in some versions/configs if not autocommit)
            conn.execute(text("COMMIT"))
            print("Successfully added 'child_id' column and foreign key constraint.")
        except Exception as e:
            print(f"Error during migration: {e}")
            conn.execute(text("ROLLBACK"))

if __name__ == "__main__":
    migrate()
