# Drone API - Backend (Flask)

## Requisiti
- Python 3.10+
- MySQL database (es. Aiven). Lo schema `droni` deve essere già creato (hai detto che è già fatto).

## File chiave
- `app.py` - applicazione Flask principale
- `db.py` - helper connessione DB (PyMySQL)
- `routes/` - endpoints API
- `auth.py` - funzioni di autenticazione semplice

## Variabili d'ambiente (esempio)
- DB_HOST (es. your-aiven-host)
- DB_PORT (es. 3306)
- DB_USER
- DB_PASSWORD
- DB_NAME (droni)
- API_KEY (stringa per header X-API-KEY)
- SECRET_KEY (per le sessioni Flask)

Esempio (Linux/macOS):
```bash
export DB_HOST=your-aiven-host
export DB_PORT=3306
export DB_USER=youruser
export DB_PASSWORD=yourpass
export DB_NAME=droni
export API_KEY=dev-key-123
export SECRET_KEY=dev-secret-key
```

Esempio (Windows PowerShell):
```powershell
$env:DB_HOST = 'your-aiven-host'
$env:DB_PORT = '3306'
$env:DB_USER = 'youruser'
$env:DB_PASSWORD = 'yourpass'
$env:DB_NAME = 'droni'
$env:API_KEY = 'dev-key-123'
$env:SECRET_KEY = 'dev-secret-key'
```

In questa repository è incluso uno script di utilità per creare e popolare lo schema di database dal file `memory_bank/db.sql`:

```powershell
# Assicurati di aver impostato le variabili d'ambiente sopra
python .\scripts\init_db.py
```

Per avviare l'app Flask in ambiente di sviluppo:

```powershell
# crea virtualenv (solo la prima volta)
python -m venv .venv; .\.venv\Scripts\Activate.ps1
# installa dipendenze
pip install -r requirements.txt
# avvia
python app.py
```

Note di sicurezza e miglioramenti consigliati:
- Le password in `memory_bank/db.sql` sono in chiaro. È consigliato usare hashing (bcrypt/argon2) lato server ed aggiornare gli script di popolamento.
- `API_KEY` attualmente è un valore statico; per produzione considerare JWT o OAuth e HTTPS.
- Lo script `scripts/init_db.py` esegue statement SQL dal file; usalo con attenzione su un DB di test.

## Quickstart & utilities

- Assicurati di avere le variabili d'ambiente indicate sopra (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `API_KEY`, `SECRET_KEY`).
- Per comodità puoi usare uno `.env` loader o impostare le variabili in PowerShell come mostrato nella sezione Variabili d'ambiente.

Utility scripts presenti nella cartella `scripts/`:

- `init_db.py` — esegue `memory_bank/db.sql` per creare e popolare le tabelle.
- `hash_passwords.py` — migra password in chiaro a bcrypt (eseguirlo su DB di test prima di produrre cambiamenti irreversibili).
- `create_admin.py` — crea o aggiorna un utente (inserisce password bcrypt) come admin.
- `promote_admin.py` — promuove un utente esistente (`Utente.mail`) a `ruolo='admin'`.
- `call_my_orders.py` — script di test che esegue login e chiama `/api/my_orders` (utile per testare cookie/session in locale).

Esempi rapidi (PowerShell):

```powershell
# crea virtualenv e installa
python -m venv .venv; .\.venv\Scripts\Activate.ps1; pip install -r requirements.txt

# inizializza DB (dopo aver impostato le env vars)
python .\scripts\init_db.py

# promuovi un utente a admin (opzionale)
python -m scripts.promote_admin --email elena.neri@mail.com

# crea un admin con password (usa create_admin per inserire bcrypt)
python -m scripts.create_admin --email admin@example.com --password AdminPass123! --nome Admin --cognome Test

# testa login + my_orders (usa 127.0.0.1:5000 come base)
python -m scripts.call_my_orders --email elena.neri@mail.com --password pass123
```

Credenziali di prova (incluse nel DB di demo)
- Admin di test: `elena.neri@mail.com` / `pass123` (ruolo `admin`)
- Admin di test: `francesco.gialli@mail.com` / `pass123` (ruolo `admin`)
- Utenti cliente di prova: `mario.rossi@mail.com`, `sara.bianchi@mail.com`, ... (password `pass123`)

Note importanti su login e 401 (SameSite / cookies)
- L'app usa session cookie per autenticazione (Flask session). Per funzionare il browser deve inviare il cookie di sessione.
- Apri sempre la UI usando la stessa origine del server (es. `http://127.0.0.1:5000`) — usare `file://` o una porta/host diversa può impedire l'invio dei cookie e causare 401.
- Le chiamate fetch nel codice client usano `credentials: 'same-origin'`. Se apri il frontend da un'origine differente, dovrai cambiare le richieste a `credentials: 'include'` e abilitare CORS con credenziali sul server.

Passi successivi consigliati
- Eseguire `scripts/hash_passwords.py` su una copia del DB per passare alle password hashate e rimuovere il fallback plaintext in `auth.check_credentials`.
- Aggiungere test automatici (ad es. pytest) per login e per gli endpoint principali.


---

Contenuto attuale del progetto e punti chiave:
- Endpoint per ordini: `GET /api/order/<id>`
- Endpoint per tracce: `GET /api/mission/<id>/traces`
- Endpoint per missioni: `POST /api/mission`, `POST /api/mission/<id>/rating`
- Admin CRUD: `api/admin/*` (richiede `X-API-KEY` header e login)
- Autenticazione: `POST /api/login` e `POST /api/logout`

Se vuoi, posso:
- Aggiungere test unitari minimi per gli endpoint (pytest).
- Implementare hashing password e aggiornare gli script SQL per popolamento.
- Creare una semplice SPA demo che mostra lo stato di un ordine e la mappa delle tracce (frontend statico).
