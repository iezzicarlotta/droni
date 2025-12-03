"""
Script diagnostico: stampa i record della tabella Utente (ID, mail, password, ruolo)
"""
from db import get_connection

def main():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT ID, nome, cognome, mail, password, ruolo FROM Utente")
            rows = cur.fetchall()
            if not rows:
                print('NO_USERS')
                return
            for r in rows:
                print(r)
    finally:
        conn.close()

if __name__ == '__main__':
    main()
