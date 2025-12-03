"""
Login and call /api/my_orders to verify the endpoint for the logged-in user.

Usage:
  python -m scripts.call_my_orders --email elena.neri@mail.com --password pass123
"""
import argparse
import requests
from urllib.parse import urljoin

BASE = 'http://127.0.0.1:5000'

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--email', required=True)
    p.add_argument('--password', required=True)
    args = p.parse_args()
    s = requests.Session()
    login_url = urljoin(BASE, '/api/login')
    r = s.post(login_url, json={'mail': args.email, 'password': args.password})
    print('Login status:', r.status_code)
    print(r.text)
    if r.status_code != 200:
        return
    my_url = urljoin(BASE, '/api/my_orders')
    r2 = s.get(my_url)
    print('my_orders status:', r2.status_code)
    print(r2.text)

if __name__ == '__main__':
    main()
