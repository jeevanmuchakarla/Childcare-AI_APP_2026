import models
from sqlalchemy import create_engine
from sqlalchemy.schema import CreateTable
from database import engine

with open('database/schema.sql', 'w') as f:
    f.write("CREATE DATABASE IF NOT EXISTS Childcare_db;\n")
    f.write("USE Childcare_db;\n\n")
    for table in models.Base.metadata.sorted_tables:
        create_stmt = str(CreateTable(table).compile(engine))
        if create_stmt:
            f.write(create_stmt.strip() + ";\n\n")

print("Schema file successfully generated!")
