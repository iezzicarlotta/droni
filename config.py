import os
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")

API_KEY = os.getenv("API_KEY", "dev-key-123")
SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key")
DEBUG = os.getenv("FLASK_DEBUG", "1") == "1"
