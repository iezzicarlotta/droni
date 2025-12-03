from flask import request, session, jsonify
from functools import wraps
from config import API_KEY
from db import get_connection
from passlib.hash import bcrypt

def require_api_key(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        key = request.headers.get("X-API-KEY")
        # allow either a valid header or a session-stored API key (set at login)
        if key == API_KEY or session.get('api_key') == API_KEY:
            return fn(*args, **kwargs)
        return jsonify({"success": False, "error": "Unauthorized (invalid API key)"}), 401
    return wrapper

def login_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if "user_id" not in session:
            return jsonify({"success": False, "error": "Login required"}), 401
        return fn(*args, **kwargs)
    return wrapper

def check_credentials(mail, password):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # fetch stored password hash (if any) and user info
            cur.execute("SELECT ID, nome, cognome, ruolo, mail, password FROM Utente WHERE mail=%s LIMIT 1", (mail,))
            row = cur.fetchone()
            if not row:
                return None
            stored = row.get('password')
            # if stored looks like a bcrypt hash, verify
            try:
                if stored and stored.startswith('$2'):
                    if bcrypt.verify(password, stored):
                        # return user without password
                        row.pop('password', None)
                        return row
                    else:
                        return None
                else:
                    # fallback: plaintext match (for migration) - compare directly
                    if stored == password:
                        row.pop('password', None)
                        return row
                    return None
            except Exception:
                return None
    finally:
        conn.close()
