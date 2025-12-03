"""
Migrazione password: converte le password in chiaro della tabella Utente in hash bcrypt.
Uso: assicurati di avere le variabili d'ambiente impostate (.env) e poi
python scripts\hash_passwords.py
"""
import os
from dotenv import load_dotenv
load_dotenv()
from config import DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME
import pymysql
from passlib.hash import bcrypt

conn = pymysql.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, database=DB_NAME, cursorclass=pymysql.cursors.DictCursor, autocommit=False)
try:
    with conn.cursor() as cur:
        cur.execute("SELECT ID, mail, password FROM Utente")
        rows = cur.fetchall()
        updated = 0
        for r in rows:
            pwd = r.get('password')
            if not pwd:
                continue
            # if already bcrypt
            if pwd.startswith('$2'):
                continue
            h = bcrypt.hash(pwd)
            cur.execute("UPDATE Utente SET password=%s WHERE ID=%s", (h, r['ID']))
            updated += 1
        conn.commit()
        print(f"Updated {updated} passwords to bcrypt hashes")
finally:
    conn.close()
*** End Patch