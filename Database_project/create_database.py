import sqlite3
from shutil import move

    
with sqlite3.connect(r"tmp.db") as connection:

    cursor = connection.cursor()
    sql_file = open("schema.sql").read()
    cursor.executescript(sql_file)
    
move("tmp.db", "../assets/schema.db")
