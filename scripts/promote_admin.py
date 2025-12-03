"""
Promote an existing Utente to ruolo='admin'.

Usage:
  python -m scripts.promote_admin --email mario.rossi@mail.com

This simply updates the ruolo column; no password changes are made.
"""
import argparse
from db import get_connection


def promote(email):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT ID, ruolo FROM Utente WHERE mail=%s", (email,))
            row = cur.fetchone()
            if not row:
                print(f"No user found with mail={email}")
                return
            if row.get('ruolo') == 'admin':
                print(f"User ID={row['ID']} is already admin")
                return
            cur.execute("UPDATE Utente SET ruolo='admin' WHERE ID=%s", (row['ID'],))
        conn.commit()
        print(f"Promoted user ID={row['ID']} to admin")
    except Exception as e:
        conn.rollback()
        raise
    finally:
        conn.close()


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--email', required=True)
    args = p.parse_args()
    promote(args.email)


if __name__ == '__main__':
    main()
