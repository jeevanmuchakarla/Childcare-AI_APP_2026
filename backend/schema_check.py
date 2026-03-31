from sqlalchemy import create_engine, text
from config import Config

def check_schema():
    engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)
    with engine.connect() as conn:
        print("--- Notifications Table Schema ---")
        result = conn.execute(text("DESCRIBE notifications"))
        for row in result:
            print(row)
        
        print("\n--- Activity Records Table Schema ---")
        result = conn.execute(text("DESCRIBE activity_records"))
        for row in result:
            print(row)

if __name__ == "__main__":
    try:
        check_schema()
    except Exception as e:
        print(f"Error: {e}")
