from pymongo import MongoClient
from dotenv import load_dotenv
import datetime as dt
import os

load_dotenv()

db = None

def get_connection():
    client = MongoClient(os.getenv("STRING_CONNECTION"))
    client.admin.command('ping')  # Test the connection
    print("Connected to MongoDB successfully")
    return client


def main():
    global db
    client = get_connection()
    db = client.get_database("rasp_sensors")

    collection1 = db.get_collection("temp")
    collection2 = db.get_collection("movs")

    documento1 = {
        "temp": 25.5,
        "date": dt.datetime.now()
    }

    documento2 = {
        "date": dt.datetime.now()
    }

    collection1.insert_one(documento1)
    collection2.insert_one(documento2)

if __name__ == "__main__":
    main()