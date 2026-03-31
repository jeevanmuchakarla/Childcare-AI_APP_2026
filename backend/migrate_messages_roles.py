
from sqlalchemy import text
from database import engine

def migrate():
    print("Starting migration to add roles to messages table...")
    with engine.connect() as connection:
        transaction = connection.begin()
        try:
            # Check if columns already exist to avoid errors
            result = connection.execute(text("DESCRIBE messages"))
            columns = [row[0] for row in result.fetchall()]
            
            if "sender_role" not in columns:
                print("Adding sender_role column...")
                connection.execute(text("ALTER TABLE messages ADD COLUMN sender_role VARCHAR(50) AFTER sender_id"))
            else:
                print("sender_role column already exists.")
                
            if "receiver_role" not in columns:
                print("Adding receiver_role column...")
                connection.execute(text("ALTER TABLE messages ADD COLUMN receiver_role VARCHAR(50) AFTER receiver_id"))
            else:
                print("receiver_role column already exists.")
            
            transaction.commit()
            print("Migration completed successfully.")
        except Exception as e:
            transaction.rollback()
            print(f"Migration failed: {e}")
            raise e

if __name__ == "__main__":
    migrate()
