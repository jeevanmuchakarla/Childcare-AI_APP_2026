
import pymysql
from database import engine

def check_messages_schema():
    connection = engine.raw_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("DESCRIBE messages")
            columns = cursor.fetchall()
            for col in columns:
                print(col)
    finally:
        connection.close()

if __name__ == "__main__":
    check_messages_schema()
