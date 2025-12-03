"""
Create or update an admin user in the Utente table.

Usage:
  python -m scripts.create_admin --email admin@example.com --password AdminPass123! --nome Admin --cognome User

If --password is omitted the script will prompt for it securely.
This script hashes the password with bcrypt (passlib) before storing.
"""
import argparse
import getpass
from passlib.hash import bcrypt
from db import get_connection


def create_or_update_admin(email, password, nome='Admin', cognome='User'):
    hashed = bcrypt.hash(password)
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # check if user exists
            cur.execute("SELECT ID FROM Utente WHERE mail = %s", (email,))
            row = cur.fetchone()
            if row:
                cur.execute(
                    "UPDATE Utente SET nome=%s, cognome=%s, password=%s, ruolo='admin' WHERE ID = %s",
                    (nome, cognome, hashed, row['ID'])
                )
                print(f"Updated existing user (ID={row['ID']}) to ruolo='admin' and updated password.")
            else:
                cur.execute(
                    "INSERT INTO Utente (nome, cognome, mail, password, ruolo) VALUES (%s, %s, %s, %s, 'admin')",
                    (nome, cognome, email, hashed)
                )
                print(f"Inserted new admin user with mail={email}.")
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise
    finally:
        conn.close()


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--email', required=True, help='email for the admin account')
    p.add_argument('--password', help='password for the admin account (will prompt if omitted)')
    p.add_argument('--nome', default='Admin', help='nome (first name)')
    p.add_argument('--cognome', default='User', help='cognome (last name)')
    args = p.parse_args()

    password = args.password
    if not password:
        password = getpass.getpass('Password for new admin: ')
        password2 = getpass.getpass('Confirm password: ')
        if password != password2:
            print('Passwords do not match. Aborting.')
            return

    create_or_update_admin(args.email, password, args.nome, args.cognome)


if __name__ == '__main__':
    main()
