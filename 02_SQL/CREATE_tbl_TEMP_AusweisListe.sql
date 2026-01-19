-- ========================================
-- Temporäre Tabelle für Ausweis-Erstellung
-- ========================================
-- Diese Tabelle wird von frm_Ausweis_Create verwendet
-- um die ausgewählten Mitarbeiter für Ausweis/Kartendruck
-- zwischenzuspeichern.

CREATE TABLE tbl_TEMP_AusweisListe (
    ID AUTOINCREMENT PRIMARY KEY,
    MA_ID LONG,                     -- Mitarbeiter-ID aus tbl_MA_Mitarbeiterstamm
    Nachname TEXT(100),             -- Nachname (kopiert für Performance)
    Vorname TEXT(100),              -- Vorname (kopiert für Performance)
    AusweisNr TEXT(20),             -- Dienstausweis-Nummer
    GueltBis DATETIME,              -- Gültigkeitsdatum
    AusweisTyp TEXT(50),            -- 'Einsatzleitung', 'Security', 'Service', etc.
    ErstelltAm DATETIME DEFAULT Now(), -- Zeitstempel
    ErstelltVon TEXT(50)            -- User der erstellt hat
);

-- Index für schnelle Abfragen
CREATE INDEX idx_MA_ID ON tbl_TEMP_AusweisListe(MA_ID);
