# Modello logico-relazionale

Trasformazione ER -> Relazionale (sintesi):

Tabelle e colonne (riprese da `memory_bank/db.sql`):

- Drone(ID PK, modello VARCHAR(50), `capacità` DECIMAL(4,2), batteria INT CHECK 0..100)
- Pilota(ID PK, nome VARCHAR(15), cognome VARCHAR(15), turno ENUM(...), brevetto VARCHAR(15))
- Missione(ID PK, data_missione DATE, ora TIME, latPrelievo DECIMAL, longPrelievo DECIMAL, latConsegna DECIMAL, longConsegna DECIMAL, valutazione INT NULL CHECK 1..5, commento VARCHAR(255), stato ENUM(...), id_drone FK->Drone(ID), id_pilota FK->Pilota(ID))
- Utente(ID PK, nome, cognome, mail UNIQUE, password, ruolo)
- Ordine(ID PK, tipo, peso_totale DECIMAL, orario DATETIME, indirizzo_destinazione VARCHAR, id_missione FK->Missione(ID), id_utente FK->Utente(ID))
- Prodotto(ID PK, nome, peso DECIMAL, categoria VARCHAR)
- Contiene(id_prodotto FK->Prodotto(ID), id_ordine FK->Ordine(ID), quantità INT, PRIMARY KEY(id_prodotto,id_ordine))
- Traccia(id_drone FK->Drone(ID), id_missione FK->Missione(ID), latitudine DECIMAL, longitudine DECIMAL, TIMESTAMP DATETIME, PRIMARY KEY(id_drone,id_missione,TIMESTAMP))

Considerazioni implementative:
- Indici: aggiungere indici su `Ordine.id_missione`, `Traccia.id_missione` per velocità di ricerca.
- Constraint di integrità referenziale già definiti con FOREIGN KEY nello script SQL.
- Sicurezza: la colonna `Utente.password` deve contenere hash salted (bcrypt/argon2) invece di plaintext; fornito script di migrazione.

Script di creazione e popolamento: `memory_bank/db.sql`.

Migrazione password:
- `scripts/hash_passwords.py` (crea gli hash bcrypt per le password esistenti in chiaro) — fornito nella repo.

