

CREATE DATABASE droni;
USE droni;



CREATE TABLE IF NOT EXISTS Drone(
	ID  INT AUTO_INCREMENT PRIMARY KEY,
    modello VARCHAR(50) NOT NULL,
    capacità DECIMAL(4,2) NOT NULL,
    batteria INT NOT NULL,
    CHECK (batteria>=0 AND batteria<=100)
);

CREATE TABLE IF NOT EXISTS Pilota (
	ID  INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(15) NOT NULL,
    cognome VARCHAR(15) NOT NULL,
    turno ENUM('Mattina', 'Pomeriggio', 'Sera') NOT NULL,
    brevetto VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS Missione(
	ID  INT AUTO_INCREMENT PRIMARY KEY,
    data_missione DATE NOT NULL,
    ora TIME NOT NULL,
    latPrelievo DECIMAL(9,7) NOT NULL,
    longPrelievo DECIMAL(10,7) NOT NULL,
    latConsegna DECIMAL(9,7) NOT NULL,
    longConsegna DECIMAL(10,7) NOT NULL,
	valutazione INT NULL,
    commento VARCHAR(255) NULL,
    stato ENUM ('programmata', 'in corso', 'completata', 'annullata') NOT NULL,
    id_drone INT,
    id_pilota INT,
    CHECK (valutazione>= 1 AND valutazione<=5),
    CONSTRAINT assegnazione_drone FOREIGN KEY (id_drone) REFERENCES Drone(ID),
    CONSTRAINT assegnazione_pilota FOREIGN KEY (id_pilota) REFERENCES Pilota(ID)
);

CREATE TABLE IF NOT EXISTS Utente (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    mail VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    ruolo VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Ordine (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    peso_totale DECIMAL(10,2) NULL,
    orario DATETIME NOT NULL,
    indirizzo_destinazione VARCHAR(255) NOT NULL,
    id_missione INT NOT NULL,
    id_utente INT NOT NULL,
    FOREIGN KEY (id_missione) REFERENCES Missione(ID),
    FOREIGN KEY (id_utente) REFERENCES Utente(ID)
);

CREATE TABLE Prodotto (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    peso DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

CREATE TABLE Contiene (
    id_prodotto INT NOT NULL,
    id_ordine INT NOT NULL,
    quantità INT NOT NULL,
    PRIMARY KEY (id_prodotto, id_ordine),
    FOREIGN KEY (id_prodotto) REFERENCES Prodotto(ID),
    FOREIGN KEY (id_ordine) REFERENCES Ordine(ID)
);

CREATE TABLE Traccia (
    id_drone INT NOT NULL,
    id_missione INT NOT NULL,
    latitudine DECIMAL(10,8) NOT NULL,
    longitudine DECIMAL(11,8) NOT NULL,
    TIMESTAMP DATETIME,
    PRIMARY KEY (id_drone, id_missione, TIMESTAMP),
    FOREIGN KEY (id_drone) REFERENCES Drone(ID),
    FOREIGN KEY (id_missione) REFERENCES Missione(ID)
);


-- POPOLAMENTO COMPATIBILE CON LE CREATE FORNITE

-- ============================================
-- PILOTI (5)
-- ============================================
INSERT INTO Pilota (nome, cognome, turno, brevetto) VALUES
('Luca', 'Rossi', 'Mattina', 'A12345'),
('Marco', 'Bianchi', 'Pomeriggio', 'B23456'),
('Giulia', 'Verdi', 'Sera', 'C34567'),
('Anna', 'Neri', 'Mattina', 'D45678'),
('Paolo', 'Gialli', 'Pomeriggio', 'E56789');

-- ============================================
-- DRONI (10)
-- Nota: colonna 'capacità' ha accento quindi viene escaped
-- ============================================
INSERT INTO Drone (modello, `capacità`, batteria) VALUES
('DJI Phantom 4', 2.50, 90),
('Parrot Anafi', 1.80, 75),
('DJI Mavic Air 2', 2.00, 85),
('Autel Evo II', 2.20, 70),
('Skydio 2', 1.90, 80),
('DJI Inspire 2', 3.00, 60),
('Yuneec Typhoon H', 2.60, 50),
('DJI Air 2S', 2.10, 95),
('PowerVision PowerEgg', 1.70, 65),
('Parrot Bebop 2', 1.60, 55);

-- ============================================
-- UTENTI (5) - ho separato nome e cognome e aggiunto ID
-- ============================================
INSERT INTO Utente (ID, nome, cognome, mail, password, ruolo) VALUES
(1, 'Mario', 'Rossi', 'mario.rossi@mail.com', 'pass123', 'cliente'),
(2, 'Sara', 'Bianchi', 'sara.bianchi@mail.com', 'pass123', 'cliente'),
(3, 'Giovanni', 'Verdi', 'giovanni.verdi@mail.com', 'pass123', 'cliente'),
(4, 'Elena', 'Neri', 'elena.neri@mail.com', 'pass123', 'admin'),
(5, 'Francesco', 'Gialli', 'francesco.gialli@mail.com', 'pass123', 'admin');

-- ============================================
-- PRODOTTI (100) - ho aggiunto ID sequenziali 1..100
-- ============================================
INSERT INTO Prodotto (ID, nome, peso, categoria) VALUES
(1, 'Smartphone Samsung Galaxy A52', 0.185, 'Elettronica'),
(2, 'Cuffie Wireless Sony WH-1000XM4', 0.255, 'Elettronica'),
(3, 'Libro \"Il Nome della Rosa\" Umberto Eco', 0.580, 'Libri'),
(4, 'Zaino Scuola Estensibile', 0.850, 'Accessori'),
(5, 'Laptop Dell XPS 13', 1.340, 'Elettronica'),
(6, 'Power Bank 20000mAh', 0.365, 'Elettronica'),
(7, 'T-shirt Cotone Uomo', 0.220, 'Abbigliamento'),
(8, 'Orologio Digitale Casio', 0.165, 'Accessori'),
(9, 'Borsa Donna Pelle', 0.720, 'Accessori'),
(10, 'Scarpe Running Nike', 1.210, 'Calzature'),
(11, 'Mouse Wireless Logitech', 0.095, 'Elettronica'),
(12, 'Tastiera Meccanica RGB', 0.950, 'Elettronica'),
(13, 'Webcam Full HD 1080p', 0.185, 'Elettronica'),
(14, 'Cavo USB-C 2m', 0.045, 'Accessori'),
(15, 'Hub USB 7 porte', 0.280, 'Elettronica'),
(16, 'Scheda SD 128GB', 0.020, 'Elettronica'),
(17, 'Caricabatterie Rapido 65W', 0.180, 'Elettronica'),
(18, 'Custodia Tablet Universale', 0.350, 'Accessori'),
(19, 'Protezione Schermo Vetro', 0.030, 'Accessori'),
(20, 'Cover Silicone iPhone 14', 0.075, 'Accessori'),
(21, 'Jeans Blu Uomo', 0.650, 'Abbigliamento'),
(22, 'Felpa Sportiva Donna', 0.580, 'Abbigliamento'),
(23, 'Calzini Cotone Set 5 Paia', 0.150, 'Abbigliamento'),
(24, 'Cintura Pelle Marrone', 0.280, 'Accessori'),
(25, 'Sciarpa Lana Invernale', 0.320, 'Abbigliamento'),
(26, 'Cappotto Invernale Uomo', 2.100, 'Abbigliamento'),
(27, 'Occhiali da Sole UV400', 0.095, 'Accessori'),
(28, 'Zaino Fotografico', 1.200, 'Accessori'),
(29, 'Borraccia Termica 500ml', 0.450, 'Accessori'),
(30, 'Portafoglio RFID', 0.145, 'Accessori'),
(31, 'Libro \"1984\" George Orwell', 0.520, 'Libri'),
(32, 'Libro \"Orgoglio e Pregiudizio\" Jane Austen', 0.480, 'Libri'),
(33, 'Quaderno A4 200 Fogli', 0.380, 'Ufficio'),
(34, 'Penna Stilografica Parker', 0.035, 'Ufficio'),
(35, 'Set Matite Colorate 24 Pezzi', 0.420, 'Ufficio'),
(36, 'Evidenziatori Fluorescenti 4 Colori', 0.180, 'Ufficio'),
(37, 'Colla Stick 25g', 0.045, 'Ufficio'),
(38, 'Forbici Metallo', 0.195, 'Ufficio'),
(39, 'Nastro Adesivo Trasparente', 0.085, 'Ufficio'),
(40, 'Spillatrice Metallica', 0.320, 'Ufficio'),
(41, 'Staffe 26/6 Scatola 1000', 0.220, 'Ufficio'),
(42, 'Cartelle Sospese 10 Pezzi', 0.850, 'Ufficio'),
(43, 'Etichette Adesive A4', 0.095, 'Ufficio'),
(44, 'Post-it Gialli 100 Fogli', 0.055, 'Ufficio'),
(45, 'Correttore Bianchetto', 0.035, 'Ufficio'),
(46, 'Calendario da Parete 2025', 0.180, 'Ufficio'),
(47, 'Agenda Settimanale Nero', 0.280, 'Ufficio'),
(48, 'Lampada da Ufficio LED', 0.640, 'Illuminazione'),
(49, 'Lampada Tavolo Scrivania', 0.580, 'Illuminazione'),
(50, 'Bulb LED E27 11W', 0.065, 'Illuminazione'),
(51, 'Bulb LED GU10 5W', 0.050, 'Illuminazione'),
(52, 'Striscia LED RGB 5m', 0.420, 'Illuminazione'),
(53, 'Lampada Piantana', 2.100, 'Illuminazione'),
(54, 'Paralume Tessuto Bianco', 0.350, 'Illuminazione'),
(55, 'Accendino Ricaricabile USB', 0.120, 'Accessori'),
(56, 'Ombrello Pieghevole Nero', 0.380, 'Accessori'),
(57, 'Spazzolino Elettrico Sonic', 0.275, 'Igiene'),
(58, 'Dentifricio Menta 100ml', 0.145, 'Igiene'),
(59, 'Sapone Liquido 500ml', 0.520, 'Igiene'),
(60, 'Shampoo Delicato 250ml', 0.385, 'Igiene'),
(61, 'Balsamo Capelli 200ml', 0.310, 'Igiene'),
(62, 'Deodorante Spray 150ml', 0.210, 'Igiene'),
(63, 'Bagnoschiuma 300ml', 0.345, 'Igiene'),
(64, 'Asciugamano Spugna Cotone', 0.450, 'Casa'),
(65, 'Asciugamani Set 3 Pezzi', 1.200, 'Casa'),
(66, 'Lenzuola Cotone Bianche', 0.950, 'Casa'),
(67, 'Coperta Pile Calda', 1.850, 'Casa'),
(68, 'Cuscino Imbottitura Sintetica', 0.680, 'Casa'),
(69, 'Tappeto Soggiorno 120x180cm', 3.200, 'Casa'),
(70, 'Tovaglia Cotone Stampata', 0.520, 'Casa'),
(71, 'Tovaglioli Carta 100 Pezzi', 0.380, 'Casa'),
(72, 'Piatti Set 6 Pezzi', 1.950, 'Casa'),
(73, 'Bicchieri Vetro Set 6', 0.940, 'Casa'),
(74, 'Coltelli da Cucina Set', 0.850, 'Casa'),
(75, 'Padella Antiaderente 28cm', 1.240, 'Casa'),
(76, 'Pentola Acciaio Inox 5L', 2.150, 'Casa'),
(77, 'Mestolo Cucina Silicone', 0.185, 'Casa'),
(78, 'Spatola Metallo', 0.145, 'Casa'),
(79, 'Apriscatole Manuale', 0.195, 'Casa'),
(80, 'Grattugia Acciaio Inox', 0.280, 'Casa'),
(81, 'Tagliere Plastica', 0.420, 'Casa'),
(82, 'Pelapatate', 0.095, 'Casa'),
(83, 'Spremiagrumi Manuale', 0.380, 'Casa'),
(84, 'Termometro da Cucina', 0.065, 'Casa'),
(85, 'Bilancia Cucina Digitale', 0.890, 'Casa'),
(86, 'Spruzzatore Acqua Piante', 0.210, 'Giardino'),
(87, 'Guanti Giardinaggio', 0.135, 'Giardino'),
(88, 'Forbici Potatura', 0.320, 'Giardino'),
(89, 'Vanga Piccola', 1.840, 'Giardino'),
(90, 'Rastrello 10 Denti', 0.980, 'Giardino'),
(91, 'Corda Canapa 10m', 0.420, 'Giardino'),
(92, 'Concime Naturale 5kg', 2.100, 'Giardino'),
(93, 'Semi Pomodori Ciliegia', 0.035, 'Giardino'),
(94, 'Fertilizzante Liquido 1L', 0.980, 'Giardino'),
(95, 'Cartone Semina Biodegradabile', 0.180, 'Giardino'),
(96, 'Palla da Calcio Ufficiale', 0.450, 'Sport'),
(97, 'Racchetta Tennis Principianti', 0.385, 'Sport'),
(98, 'Palla da Tennis Set 3', 0.160, 'Sport'),
(99, 'Manubri Palestra 2x5kg', 10.500, 'Sport'),
(100, 'Corda per Saltare', 0.165, 'Sport'),
(101, 'Tappetino Yoga', 0.680, 'Sport'),
(102, 'Cintura Pesi Regolabile', 0.420, 'Sport'); 
-- Nota: nell'elenco originale erano 100 prodotti; ho mantenuto tutti i record e numerato progressivamente.
-- Se preferisci esattamente 100 records, elimina gli ultimi due o adatta gli ID come preferisci.

-- ============================================
-- MISSIONI (10) - adattate ai nomi colonne: data_missione, ora, latPrelievo, longPrelievo, latConsegna, longConsegna, valutazione, commento, id_drone, id_pilota, stato
-- Ho mappato le valutazioni originali a 1..5 con ceil(original/2)
-- ============================================
INSERT INTO Missione (ID, data_missione, ora, latPrelievo, longPrelievo, latConsegna, longConsegna, valutazione, commento, id_drone, id_pilota, stato) VALUES
(1, '2025-11-19', '10:00:00', 45.4642000, 9.1900000, 45.4669000, 9.1900000, 4, 'Consegna puntuale', 1, 1, 'completata'),
(2, '2025-11-19', '12:00:00', 45.4650000, 9.1930000, 45.4690000, 9.1950000, 5, 'Ottima gestione', 2, 2, 'completata'),
(3, '2025-11-20', '09:30:00', 45.4700000, 9.2000000, 45.4720000, 9.2050000, 4, 'Leggero ritardo', 3, 3, 'completata'),
(4, '2025-11-20', '14:00:00', 45.4730000, 9.2080000, 45.4750000, 9.2100000, 5, 'Eccellente', 4, 4, 'completata'),
(5, '2025-11-21', '08:00:00', 45.4600000, 9.1800000, 45.4620000, 9.1850000, 3, NULL, 5, 5, 'completata'),
(6, '2025-11-21', '16:00:00', 45.4640000, 9.1880000, 45.4665000, 9.1920000, 4, 'Buono', 6, 1, 'completata'),
(7, '2025-11-22', '11:00:00', 45.4680000, 9.1950000, 45.4700000, 9.1980000, 3, 'Soddisfacente', 7, 2, 'completata'),
(8, '2025-11-22', '13:00:00', 45.4710000, 9.2030000, 45.4730000, 9.2050000, 5, 'Perfetto', 8, 3, 'completata'),
(9, '2025-11-23', '15:30:00', 45.4750000, 9.2080000, 45.4770000, 9.2100000, 4, 'Consegna OK', 9, 4, 'completata'),
(10,'2025-11-23', '17:00:00', 45.4790000, 9.2150000, 45.4810000, 9.2180000, 4, 'Buono', 10, 5, 'completata');

-- ============================================
-- ORDINI (10) - aggiunti ID (1..10) e colonne coerenti con la CREATE
-- ============================================
INSERT INTO Ordine (ID, tipo, peso_totale, orario, indirizzo_destinazione, id_missione, id_utente) VALUES
(1, 'Standard', 1.35, '2025-11-19 10:05:00', 'Via Roma 45, Milano', 1, 1),
(2, 'Espresso', 0.90, '2025-11-19 12:10:00', 'Corso Como 12, Milano', 2, 2),
(3, 'Standard', 2.10, '2025-11-20 09:35:00', 'Piazza Duomo 8, Milano', 3, 3),
(4, 'Standard', 0.80, '2025-11-20 14:05:00', 'Via Torino 33, Milano', 4, 4),
(5, 'Espresso', 1.20, '2025-11-21 08:05:00', 'Via Manzoni 22, Milano', 5, 5),
(6, 'Standard', 1.75, '2025-11-21 16:10:00', 'Via Furini 7, Milano', 6, 1),
(7, 'Standard', 1.30, '2025-11-22 11:10:00', 'Via XX Settembre 15, Milano', 7, 2),
(8, 'Espresso', 0.95, '2025-11-22 13:15:00', 'Via Melchiorre Gioia 50, Milano', 8, 3),
(9, 'Standard', 1.60, '2025-11-23 15:35:00', 'Viale Monza 28, Milano', 9, 4),
(10,'Espresso', 1.10, '2025-11-23 17:05:00', 'Via Volta 18, Milano', 10, 5);

-- ============================================
-- CONTIENE (relazioni prodotto-ordine) - attenzione al nome colonna `quantità`
-- ============================================
INSERT INTO Contiene (id_prodotto, id_ordine, `quantità`) VALUES
-- Ordine 1
(1, 1, 1),
(2, 1, 1),
-- Ordine 2
(3, 2, 2),
(5, 2, 1),
-- Ordine 3
(4, 3, 1),
(6, 3, 2),
(7, 3, 3),
-- Ordine 4
(8, 4, 1),
(9, 4, 1),
-- Ordine 5
(10, 5, 1),
(11, 5, 1),
(12, 5, 1),
-- Ordine 6
(13, 6, 1),
(14, 6, 2),
(15, 6, 1),
-- Ordine 7
(16, 7, 1),
(17, 7, 1),
(18, 7, 2),
-- Ordine 8
(19, 8, 3),
(20, 8, 1),
-- Ordine 9
(21, 9, 1),
(22, 9, 1),
(23, 9, 1),
-- Ordine 10
(24, 10, 1),
(25, 10, 1),
(26, 10, 1);

-- ============================================
-- TRACCIA (coordinate droni durante missioni)
-- Nota: colonna TIMESTAMP è usata come nel CREATE, viene escaped
-- ============================================
INSERT INTO Traccia (id_drone, id_missione, latitudine, longitudine, `TIMESTAMP`) VALUES
-- Missione 1 - Drone 1
(1, 1, 45.46420000, 9.19000000, '2025-11-19 10:00:00'),
(1, 1, 45.46480000, 9.19050000, '2025-11-19 10:02:30'),
(1, 1, 45.46550000, 9.19020000, '2025-11-19 10:05:00'),
(1, 1, 45.46620000, 9.19000000, '2025-11-19 10:07:30'),
(1, 1, 45.46690000, 9.19000000, '2025-11-19 10:10:00'),
-- Missione 2 - Drone 2
(2, 2, 45.46500000, 9.19300000, '2025-11-19 12:00:00'),
(2, 2, 45.46600000, 9.19350000, '2025-11-19 12:03:00'),
(2, 2, 45.46700000, 9.19400000, '2025-11-19 12:06:00'),
(2, 2, 45.46800000, 9.19450000, '2025-11-19 12:09:00'),
(2, 2, 45.46900000, 9.19500000, '2025-11-19 12:12:00'),
-- Missione 3 - Drone 3
(3, 3, 45.47000000, 9.20000000, '2025-11-20 09:30:00'),
(3, 3, 45.47080000, 9.20100000, '2025-11-20 09:33:00'),
(3, 3, 45.47150000, 9.20250000, '2025-11-20 09:36:00'),
(3, 3, 45.47200000, 9.20350000, '2025-11-20 09:39:00'),
(3, 3, 45.47200000, 9.20500000, '2025-11-20 09:42:00'),
-- Missione 4 - Drone 4
(4, 4, 45.47300000, 9.20800000, '2025-11-20 14:00:00'),
(4, 4, 45.47380000, 9.20850000, '2025-11-20 14:02:30'),
(4, 4, 45.47450000, 9.20900000, '2025-11-20 14:05:00'),
(4, 4, 45.47500000, 9.20950000, '2025-11-20 14:07:30'),
(4, 4, 45.47500000, 9.21000000, '2025-11-20 14:10:00'),
-- Missione 5 - Drone 5
(5, 5, 45.46000000, 9.18000000, '2025-11-21 08:00:00'),
(5, 5, 45.46080000, 9.18100000, '2025-11-21 08:03:00'),
(5, 5, 45.46150000, 9.18250000, '2025-11-21 08:06:00'),
(5, 5, 45.46200000, 9.18350000, '2025-11-21 08:09:00'),
(5, 5, 45.46200000, 9.18500000, '2025-11-21 08:12:00'),
-- Missione 6 - Drone 6
(6, 6, 45.46400000, 9.18800000, '2025-11-21 16:00:00'),
(6, 6, 45.46480000, 9.18900000, '2025-11-21 16:02:30'),
(6, 6, 45.46550000, 9.19050000, '2025-11-21 16:05:00'),
(6, 6, 45.46600000, 9.19120000, '2025-11-21 16:07:30'),
(6, 6, 45.46650000, 9.19200000, '2025-11-21 16:10:00'),
-- Missione 7 - Drone 7
(7, 7, 45.46800000, 9.19500000, '2025-11-22 11:00:00'),
(7, 7, 45.46860000, 9.19600000, '2025-11-22 11:03:00'),
(7, 7, 45.46920000, 9.19680000, '2025-11-22 11:06:00'),
(7, 7, 45.46980000, 9.19750000, '2025-11-22 11:09:00'),
(7, 7, 45.47000000, 9.19800000, '2025-11-22 11:12:00'),
-- Missione 8 - Drone 8
(8, 8, 45.47100000, 9.20300000, '2025-11-22 13:00:00'),
(8, 8, 45.47170000, 9.20350000, '2025-11-22 13:02:30'),
(8, 8, 45.47230000, 9.20400000, '2025-11-22 13:05:00'),
(8, 8, 45.47270000, 9.20450000, '2025-11-22 13:07:30'),
(8, 8, 45.47300000, 9.20500000, '2025-11-22 13:10:00'),
-- Missione 9 - Drone 9
(9, 9, 45.47500000, 9.20800000, '2025-11-23 15:30:00'),
(9, 9, 45.47580000, 9.20850000, '2025-11-23 15:33:00'),
(9, 9, 45.47640000, 9.20900000, '2025-11-23 15:36:00'),
(9, 9, 45.47700000, 9.20950000, '2025-11-23 15:39:00'),
(9, 9, 45.47700000, 9.21000000, '2025-11-23 15:42:00'),
-- Missione 10 - Drone 10
(10, 10, 45.47900000, 9.21500000, '2025-11-23 17:00:00'),
(10, 10, 45.47980000, 9.21580000, '2025-11-23 17:03:00'),
(10, 10, 45.48040000, 9.21650000, '2025-11-23 17:06:00'),
(10, 10, 45.48100000, 9.21750000, '2025-11-23 17:09:00'),
(10, 10, 45.48100000, 9.21800000, '2025-11-23 17:12:00');

