# Datenmodell des CONSEC Planungssystems

## Uebersicht

Das CONSEC-System basiert auf einer Microsoft Access-Datenbank mit Frontend/Backend-Trennung:
- **Frontend:** `0_Consys_FE_Test.accdb` (Formulare, Reports, lokale Tabellen)
- **Backend:** `0_Consec_V1_BE_V1.55_Test.accdb` (Datentabellen, verknuepft)

---

## 1. Haupttabellen

### tbl_VA_Auftragstamm (Auftraege/Veranstaltungen)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **ID** | LONG (PK, Auto) | Eindeutige Auftrags-Nr |
| Auftrag | TEXT | Auftragsname/Bezeichnung |
| Veranstalter_ID | LONG (FK) | -> tbl_KD_Kundenstamm.kun_Id |
| Objekt | TEXT | Location-Name (Freitext) |
| Objekt_ID | LONG (FK) | -> tbl_OB_Objekt.ID |
| Strasse, PLZ, Ort | TEXT | Adresse |
| Dat_VA_Von | DATETIME | Startdatum |
| Dat_VA_Bis | DATETIME | Enddatum |
| Treffpunkt | TEXT | Treffpunkt-Beschreibung |
| Treffp_Zeit | DATETIME | Treffpunkt-Zeit |
| Dienstkleidung | TEXT | Kleidungsvorgabe |
| Ansprechpartner | TEXT | Ansprechpartner vor Ort |
| Veranst_Status_ID | LONG (FK) | -> tbl_VA_Status.ID |
| Fahrtkosten | CURRENCY | Fahrtkosten pro PKW |
| Rech_Nr | TEXT | Rechnungsnummer |
| Rch_Dat | DATETIME | Rechnungsdatum |
| Bemerkungen | MEMO | Freitext-Notizen |
| Autosend_EL | BOOLEAN | Automatischer E-Mail-Versand |
| Sub_send | BOOLEAN | Subunternehmer informiert |
| AnzTg | LONG | Anzahl Tage (berechnet) |
| Erst_von, Erst_am | TEXT/DATE | Audit: Erstellt |
| Aend_von, Aend_am | TEXT/DATE | Audit: Geaendert |

**Indizes:** PrimaryKey(ID), Veranstalter_ID, Objekt_ID, Status_ID

---

### tbl_MA_Mitarbeiterstamm (Mitarbeiter)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **ID** | LONG (PK) | Eindeutige Personal-Nr |
| LEXWare_ID | LONG | Lexware-Referenz |
| IstAktiv | BOOLEAN | Mitarbeiter aktiv? |
| IstSubunternehmer | BOOLEAN | Subunternehmer? |
| Nachname, Vorname | TEXT | Name |
| Strasse, Nr, PLZ, Ort | TEXT | Adresse |
| Land, Bundesland | TEXT | Land/Region |
| Tel_Mobil | TEXT | Mobilnummer |
| Tel_Festnetz | TEXT | Festnetz |
| Email | TEXT | E-Mail-Adresse |
| Geschlecht | TEXT | M/W/D |
| Geb_Dat | DATETIME | Geburtsdatum |
| Geb_Ort, Geb_Name | TEXT | Geburtsort/-name |
| Staatsang | TEXT | Staatsangehoerigkeit |
| Eintrittsdatum | DATETIME | Eintrittsdatum |
| Austrittsdatum | DATETIME | Austrittsdatum |
| Anstellungsart_ID | LONG (FK) | -> tbl_hlp_MA_Anstellungsart.ID |
| Sozialvers_Nr | TEXT | Sozialversicherungsnummer |
| SteuerNr | TEXT | Steuernummer |
| IBAN, BIC | TEXT | Bankverbindung |
| Kontoinhaber | TEXT | Name des Kontoinhabers |
| Stundenlohn_brutto | INTEGER | Brutto-Stundenlohn |
| Hat_keine_34a | BOOLEAN | Kein 34a-Nachweis |
| HatSachkunde | BOOLEAN | Sachkundepruefung |
| Fahrerlaubnis | TEXT | Fuehrerscheinklassen |
| Eigener_PKW | BOOLEAN | Hat eigenes Fahrzeug |
| Kleidergroesse | TEXT | Kleidungsgroesse |
| DienstausweisNr | TEXT | Dienstausweis-Nummer |
| Ausweis_Endedatum | DATETIME | Ausweis gueltig bis |
| tblBilddatei | TEXT | Pfad zum Foto |
| Bemerkungen | MEMO | Notizen |
| StundenZahlMax | SINGLE | Max. Monatsstunden |
| Kosten_pro_MAStunde | CURRENCY | Personalkosten/Std |
| Verfuebgarkeit_ID | LONG | Verfuegbarkeits-Status |

**Indizes:** PrimaryKey(ID), Anstellungsart_ID, LEXWare_ID

---

### tbl_MA_VA_Planung (MA-Zuordnungen)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **ID** | LONG (PK, Auto) | Eindeutige Zuordnungs-Nr |
| VA_ID | LONG (FK) | -> tbl_VA_Auftragstamm.ID |
| VADatum_ID | LONG (FK) | -> tbl_VA_AnzTage.ID |
| VAStart_ID | LONG (FK) | -> tbl_VA_Start.ID |
| MA_ID | LONG (FK) | -> tbl_MA_Mitarbeiterstamm.ID |
| VADatum | DATETIME | Einsatzdatum |
| VA_Start, VA_Ende | DATETIME | Geplante Zeit (Schicht) |
| MVA_Start, MVA_Ende | DATETIME | Tatsaechliche MA-Zeit |
| Status_ID | LONG (FK) | -> tbl_MA_Plan_Status.ID |
| Status_Datum | DATETIME | Status-Aenderungsdatum |
| PosNr | LONG | Positions-Nr |
| MA_Brutto_Std | SINGLE | Anwesenheitszeit |
| MA_Netto_Std | SINGLE | Arbeitszeit |
| PKW | CURRENCY | Fahrtkosten-Anteil |
| Bemerkungen | TEXT | Notizen |
| Anfragezeitpunkt | DATETIME | Wann angefragt |
| Rueckmeldezeitpunkt | DATETIME | Wann geantwortet |

**Indizes:** PrimaryKey(ID), VA_ID, VADatum_ID, VAStart_ID, MA_ID, Status_ID, VADatum

---

### tbl_KD_Kundenstamm (Kunden)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **kun_Id** | LONG (PK, Auto) | Eindeutige Kunden-Nr |
| kun_Firma | TEXT | Firmenname |
| kun_IstAktiv | BOOLEAN | Kunde aktiv? |
| kun_AdressArt | LONG (FK) | -> tbl_KD_Adressart.ID (1=Auftraggeber) |
| kun_Strasse, kun_PLZ, kun_Ort | TEXT | Adresse |
| kun_Land | TEXT | Land |
| kun_Tel1, kun_Tel2 | TEXT | Telefon |
| kun_Fax | TEXT | Fax |
| kun_Email | TEXT | E-Mail |
| kun_Homepage | TEXT | Website |
| kun_Ansprechpartner | TEXT | Haupt-Ansprechpartner |
| kun_Zahlungsziel | LONG | Zahlungsziel in Tagen |
| kun_Ust_ID | TEXT | USt-ID |
| kun_BankName | TEXT | Bankname |
| kun_IBAN, kun_BIC | TEXT | Bankverbindung |
| kun_Bemerkungen | MEMO | Notizen |
| kun_Erst_von, kun_Erst_am | TEXT/DATE | Audit: Erstellt |
| kun_Aend_von, kun_Aend_am | TEXT/DATE | Audit: Geaendert |

**Indizes:** PrimaryKey(kun_Id), kun_IstAktiv

---

## 2. Hilfstabellen

### tbl_VA_AnzTage (Auftrags-Tage)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **ID** | LONG (PK, Auto) | Eindeutige Tag-ID |
| VA_ID | LONG (FK) | -> tbl_VA_Auftragstamm.ID |
| VADatum | DATETIME | Datum des Tages |

Fuer jeden Tag eines Mehrtages-Auftrags wird ein Eintrag erstellt.

---

### tbl_VA_Start (Schichten)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **ID** | LONG (PK, Auto) | Eindeutige Schicht-ID |
| VA_ID | LONG (FK) | -> tbl_VA_Auftragstamm.ID |
| VADatum_ID | LONG (FK) | -> tbl_VA_AnzTage.ID |
| VA_Start | DATETIME | Beginn der Schicht |
| VA_Ende | DATETIME | Ende der Schicht |
| MA_Anzahl | LONG | Soll-Anzahl MA |
| MA_Anzahl_Ist | LONG | Ist-Anzahl MA (berechnet) |
| Bemerkungen | TEXT | Schicht-Notizen |

---

### tbl_VA_Status (Auftrags-Status)

| ID | Fortschritt | Beschreibung |
|----|-------------|--------------|
| 1 | Planung | Auftrag in Planung |
| 2 | Bestaetigt | Auftrag bestaetigt |
| 3 | Abgeschlossen | Auftrag durchgefuehrt |
| 4 | Abgerechnet | Rechnung erstellt |
| 5 | Storniert | Auftrag storniert |

---

### tbl_MA_Plan_Status (MA-Zuordnungs-Status)

| ID | Status | Beschreibung |
|----|--------|--------------|
| 0 | Angefragt | Anfrage gesendet |
| 1 | Zugesagt | MA hat zugesagt |
| 2 | Abgesagt | MA hat abgesagt |
| 3 | Bestaetigt | Finale Bestaetigung |
| 4 | Storniert | Zuordnung aufgehoben |

---

### tbl_hlp_MA_Anstellungsart (Anstellungsarten)

| ID | Anstellungsart | Sortierung |
|----|----------------|------------|
| 3 | Minijob | 1 |
| 5 | Teilzeit | 2 |
| 9 | Vollzeit | 3 |
| 11 | Werkstudent | 4 |
| 13 | Alle | 99 |

---

### tbl_OB_Objekt (Objekte/Locations)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **ID** | LONG (PK, Auto) | Eindeutige Objekt-ID |
| Objekt | TEXT | Objekt-Name |
| Strasse, PLZ, Ort | TEXT | Adresse |
| Lat, Lng | DOUBLE | GPS-Koordinaten |
| Kunde_ID | LONG (FK) | -> tbl_KD_Kundenstamm.kun_Id |
| Bemerkungen | MEMO | Notizen |
| IstAktiv | BOOLEAN | Objekt aktiv? |

---

### tbl_MA_NVerfuegZeiten (Nicht-Verfuegbarkeiten)

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| **ID** | LONG (PK, Auto) | Eindeutige ID |
| MA_ID | LONG (FK) | -> tbl_MA_Mitarbeiterstamm.ID |
| vonDat | DATETIME | Start der Nicht-Verfuegbarkeit |
| bisDat | DATETIME | Ende der Nicht-Verfuegbarkeit |
| Grund_ID | LONG (FK) | -> tbl_MA_Zeittyp.ID |
| Bemerkungen | TEXT | Notizen |

---

### tbl_MA_Zeittyp (Abwesenheits-Gruende)

| ID | Zeittyp | Beschreibung |
|----|---------|--------------|
| 1 | Urlaub | Geplanter Urlaub |
| 2 | Krank | Krankheit |
| 3 | Fortbildung | Weiterbildung |
| 4 | Privat | Private Abwesenheit |
| 5 | Feiertag | Gesetzlicher Feiertag |

---

## 3. Beziehungen (ER-Diagramm textbasiert)

```
tbl_KD_Kundenstamm (Kunde)
    |
    | 1:n
    v
tbl_VA_Auftragstamm (Auftrag)
    |
    +-- 1:n --> tbl_VA_AnzTage (Tage)
    |               |
    |               +-- 1:n --> tbl_VA_Start (Schichten)
    |
    +-- n:1 --> tbl_OB_Objekt (Objekt)
    |
    +-- n:1 --> tbl_VA_Status (Status)
    |
    +-- 1:n --> tbl_MA_VA_Planung (Zuordnungen)
                    |
                    +-- n:1 --> tbl_MA_Mitarbeiterstamm (MA)
                    |               |
                    |               +-- 1:n --> tbl_MA_NVerfuegZeiten
                    |               |
                    |               +-- n:1 --> tbl_hlp_MA_Anstellungsart
                    |
                    +-- n:1 --> tbl_MA_Plan_Status (Zuordnungs-Status)
```

---

## 4. Wichtige Queries

### qry_Auftrag_Sort (Basis fuer Auftragsverwaltung)
```sql
SELECT a.*, k.kun_Firma
FROM tbl_VA_Auftragstamm a
LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
ORDER BY a.Dat_VA_Von DESC, a.ID DESC
```

### qry_Mitarbeiter_Geplant (Geplante MA eines Auftrags)
```sql
SELECT p.*, m.Nachname, m.Vorname, m.Tel_Mobil
FROM tbl_MA_VA_Planung p
INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
WHERE p.VA_ID = ? AND p.VADatum_ID = ?
ORDER BY p.PosNr, m.Nachname
```

### ztbl_MA_Schnellauswahl (Verfuegbare MA fuer Schnellauswahl)
```sql
SELECT m.ID, m.IstSubunternehmer,
       m.Nachname & ", " & m.Vorname AS Name,
       null AS Std,
       null AS Beginn, null AS Ende, null AS Grund
FROM tbl_MA_Mitarbeiterstamm m
WHERE m.IstAktiv = True
  AND m.ID NOT IN (
      SELECT MA_ID FROM tbl_MA_VA_Planung
      WHERE VADatum = [Datum] AND Status_ID NOT IN (4,5)
  )
ORDER BY m.Nachname, m.Vorname
```

### qry_Anz_MA_Start (Schichten mit Soll/Ist)
```sql
SELECT s.ID AS VAStart_ID, s.VADatum,
       s.VA_Start AS MVA_Start, s.VA_Ende AS MVA_Ende,
       s.MA_Anzahl AS MA_Soll,
       (SELECT COUNT(*) FROM tbl_MA_VA_Planung
        WHERE VAStart_ID = s.ID AND Status_ID IN (1,3)) AS MA_Ist,
       Format(s.VA_Start, "hh:nn") AS Beginn,
       Format(s.VA_Ende, "hh:nn") AS Ende
FROM tbl_VA_Start s
WHERE s.VA_ID = ? AND s.VADatum_ID = ?
ORDER BY s.VA_Start
```

### qry_Einsatzliste (Einsatzliste fuer Druck/E-Mail)
```sql
SELECT a.Auftrag, a.Dat_VA_Von, a.Ort, a.Objekt,
       a.Treffpunkt, a.Treffp_Zeit, a.Dienstkleidung,
       m.Nachname, m.Vorname, m.Tel_Mobil,
       p.MVA_Start, p.MVA_Ende, p.PosNr
FROM tbl_VA_Auftragstamm a
INNER JOIN tbl_MA_VA_Planung p ON a.ID = p.VA_ID
INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
WHERE a.ID = ? AND p.Status_ID IN (1,3)
ORDER BY p.VADatum, p.MVA_Start, m.Nachname
```

---

## 5. Temp-Tabellen (Frontend)

### tbltmp_DP_Grund (Dienstplan-Grunddaten)
| Feld | Beschreibung |
|------|--------------|
| ObjOrt | Objekt + Ort |
| ObjOrt_Anzeige | Fuer Anzeige (nur bei erster Zeile pro Objekt) |
| Pos_Nr | Positionsnummer |
| Tag1_Zuo_ID ... Tag7_Zuo_ID | Zuordnungs-IDs pro Tag |
| sortID | Sortierungsindex |
| Startdat | Start-Datum der Woche |

### tbltmp_DP_Grund_2 (Mit MA-Daten gefuellt)
| Feld | Beschreibung |
|------|--------------|
| ... wie oben ... | |
| Tag1_MA_ID ... Tag7_MA_ID | MA-IDs |
| Tag1_Name ... Tag7_Name | MA-Namen |
| Tag1_von ... Tag7_von | Start-Zeiten |
| Tag1_bis ... Tag7_bis | End-Zeiten |
| Tag1_fraglich ... Tag7_fraglich | Fraglich-Flags |

---

## 6. System-/Config-Tabellen

### _tblEigeneFirma (Firmeneinstellungen)
- Firmenname, Adresse, Logo
- E-Mail-Einstellungen
- Pfade zu Vorlagen
- Mahnfristen

### _tblInternalSystemBE (Backend-System)
- Version
- Letzte Aktualisierung
- DB-Pfade

### _tblInternalSystemFE (Frontend-System)
- Version
- Benutzer-Einstellungen
- Letzte Session

### tbl_Protokoll (Aktivitaets-Log)
| Feld | Beschreibung |
|------|--------------|
| ID | Log-ID |
| Zeitpunkt | Timestamp |
| Benutzer | Username |
| Aktion | Beschreibung |
| Tabelle | Betroffene Tabelle |
| DS_ID | Datensatz-ID |

### tbl_Log_eMail_Sent (E-Mail-Log)
| Feld | Beschreibung |
|------|--------------|
| ID | Log-ID |
| Zeitpunkt | Timestamp |
| Empfaenger | E-Mail-Adresse |
| Betreff | E-Mail-Betreff |
| VA_ID | Auftrags-Referenz |
| MA_ID | MA-Referenz |

---

## 7. Namenskonventionen

### Praefix-Regeln
| Praefix | Bedeutung |
|---------|-----------|
| tbl_ | Datentabelle |
| qry_ | Abfrage |
| frm_ | Formular |
| sub_ | Unterformular |
| rpt_ | Bericht |
| mdl_ | VBA-Modul |
| cls_ | VBA-Klasse |
| btn_ | Button |
| lbl_ | Label |
| txt_ | Textfeld |
| cbo_ | ComboBox |
| lst_ | ListBox |
| chk_ | CheckBox |

### Tabellen-Bereichs-Praefix
| Praefix | Bereich |
|---------|---------|
| tbl_VA_ | Veranstaltung/Auftrag |
| tbl_MA_ | Mitarbeiter |
| tbl_KD_ | Kunde |
| tbl_OB_ | Objekt |
| tbl_hlp_ | Hilfstabelle |
| _tbl | System-/Config-Tabelle |
| tbltmp_ | Temp-Tabelle |
| z* | Obsolet/Archiv |

### Neue Objekte (ab 2024)
Alle neuen Objekte bekommen das `_N_` Infix:
- `frm_N_xxx` - Neue Formulare
- `qry_N_xxx` - Neue Queries
- `mod_N_xxx` - Neue Module
- `tbl_N_xxx` - Neue Tabellen
- `rpt_N_xxx` - Neue Berichte

---

## 8. Datenintegritaet

### Referentielle Integritaet
Die folgenden Beziehungen sind mit Referentieller Integritaet gesichert:

| Parent | Child | Aktion bei Delete |
|--------|-------|-------------------|
| tbl_VA_Auftragstamm | tbl_VA_AnzTage | Cascade |
| tbl_VA_AnzTage | tbl_VA_Start | Cascade |
| tbl_VA_Auftragstamm | tbl_MA_VA_Planung | Restrict |
| tbl_MA_Mitarbeiterstamm | tbl_MA_VA_Planung | Restrict |

### Trigger/Events (in VBA)
- BeforeUpdate: Pflichtfeld-Validierung
- AfterInsert: Audit-Felder setzen
- BeforeDelete: Abhaengigkeiten pruefen

---

*Dokumentation erstellt: 2026-01-08*
*Basierend auf: JSON-Exports aus 11_json_Export\000_Consys_Eport_11_25\10_tables\*
