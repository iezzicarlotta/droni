# Modello Entity-Relationship - Drone Delivery

Questo documento descrive l'ER model del sistema di consegne con droni.

Entità principali:

- Drone (ID, modello, capacità, batteria)
- Pilota (ID, nome, cognome, turno, brevetto)
- Utente (ID, nome, cognome, mail, password, ruolo)
- Prodotto (ID, nome, peso, categoria)
- Ordine (ID, tipo, peso_totale, orario, indirizzo_destinazione, id_missione, id_utente)
- Missione (ID, data_missione, ora, latPrelievo, longPrelievo, latConsegna, longConsegna, valutazione, commento, stato, id_drone, id_pilota)
- Traccia (id_drone, id_missione, latitudine, longitudine, TIMESTAMP)
- Contiene (id_prodotto, id_ordine, quantità)

Relazioni chiave:
- Un Utente può avere 0..N Ordini (1:N)
- Un Ordine può contenere 1..N Prodotti tramite Contiene (N:M)
- Un Ordine è associato (opzionalmente) a una Missione (1:1 o 0:1)
- Una Missione coinvolge esattamente 1 Drone e 1 Pilota (N:1 verso Drone/Pilota)
- Un Drone può avere 0..N Missioni (1:N)
- Una Missione ha 0..N Tracce (1:N), ciascuna con timestamp

Vincoli principali:
- `Drone.batteria` tra 0 e 100
- `Missione.valutazione` tra 1 e 5 (se presente)

Note:
- L'ER è stato trasformato in schema relazionale implementato in `memory_bank/db.sql`.
- Il campo `capacità` contiene un carattere accentato nel DB originale; nelle query SQL vengono usati backticks per l'accesso.

Di seguito nella cartella `docs` trovi anche la trasformazione in schema relazionale (file `relational_model.md`).
