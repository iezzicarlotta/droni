import json
from urllib import request

url = 'http://127.0.0.1:5000/api/login'
body = json.dumps({'mail':'mario.rossi@mail.com','password':'pass123'}).encode('utf-8')
req = request.Request(url, data=body, headers={'Content-Type':'application/json'})
try:
    with request.urlopen(req) as resp:
        print('Status:', resp.status)
        print(resp.read().decode())
except Exception as e:
    print('Error:', e)
    if hasattr(e, 'read'):
        try:
            print(e.read().decode())
        except:
            pass
