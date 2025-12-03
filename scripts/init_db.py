"""
Init DB script - executes the SQL statements in memory_bank/db.sql using pymysql.
Run with: python scripts\init_db.py
Requires the same environment variables as the app (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD).
This script will connect to the server and run statements; it will NOT drop existing schema by default.
"""
import os
from dotenv import load_dotenv
from config import DB_HOST, DB_PORT, DB_USER, DB_PASSWORD
import pymysql

load_dotenv()

SQL_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'memory_bank', 'db.sql'))


def load_sql(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # naive split on ';' to get individual statements
    parts = content.split(';')
    stmts = []
    for p in parts:
        s = p.strip()
        # remove SQL comment lines starting with --
        lines = [ln for ln in s.splitlines() if not ln.strip().startswith('--')]
        s2 = '\n'.join(lines).strip()
        if s2:
            stmts.append(s2)
    return stmts


def main():
    if not DB_HOST or not DB_USER:
        print("DB_HOST/DB_USER not set in environment; set .env or environment variables first.")
        return
    stmts = load_sql(SQL_PATH)
    print(f"Loaded {len(stmts)} SQL statements from {SQL_PATH}")
    # Connect without specifying database because the SQL file may create it
    conn = pymysql.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, cursorclass=pymysql.cursors.DictCursor, autocommit=False)
    try:
        with conn.cursor() as cur:
            for i, stmt in enumerate(stmts, start=1):
                try:
                    cur.execute(stmt)
                    print(f"Executed statement {i}/{len(stmts)}")
                except Exception as e:
                    print(f"Error executing statement {i}: {e}\nStatement preview:\n{stmt[:200]}...\nSkipping")
            conn.commit()
            print("All done. Committed.")
    finally:
        conn.close()


if __name__ == '__main__':
    main()
