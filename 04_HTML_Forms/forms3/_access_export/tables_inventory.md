# TABELLEN INVENTAR - Access Frontend Export

Exportiert am: 2026-01-08
Quelle: 0_Consys_FE_Test.accdb (verknuepft mit Backend)
Gesamtanzahl Tabellen: 187

---

## STAMMDATEN-TABELLEN

### tbl_MA_Mitarbeiterstamm
- **Funktion:** Mitarbeiter-Stammdaten
- **Primaerschluessel:** ID (LONG, AutoIncrement)
- **Wichtige Felder:**
  - ID - Mitarbeiter-ID
  - LEXWare_ID - Lexware-Verknuepfung
  - IstAktiv - Aktiv/Inaktiv
  - IstSubunternehmer - Subunternehmer-Flag
  - Nachname, Vorname - Name
  - Strasse, Nr, PLZ, Ort, Land, Bundesland - Adresse
  - Tel_Mobil, Tel_Festnetz - Telefon
  - Email - E-Mail-Adresse
  - Geschlecht, Staatsang, Geb_Dat, Geb_Ort - Persoenliche Daten
  - Eintrittsdatum, Austrittsdatum - Beschaeftigung
  - Anstellungsart_ID - FK zu Anstellungsart
  - IBAN, BIC, Kontoinhaber - Bankdaten
  - Stundenlohn_brutto - Lohn
  - Sozialvers_Nr, SteuerNr - Sozialversicherung/Steuer
  - Hat_keine_34a, HatSachkunde - Qualifikationen
  - DienstausweisNr, Ausweis_Endedatum - Dienstausweis
  - tblBilddatei - Foto-Pfad
  - Bemerkungen - Freitext
  - Kosten_pro_MAStunde - Personalkosten
  - Bewacher_ID - Bewacher-Register-ID
- **Indizes:** ID, LEXWare_ID, Anstellungsart_ID, Verfuebgarkeit_ID, Bewacher_ID

### tbl_KD_Kundenstamm
- **Funktion:** Kunden-Stammdaten
- **Primaerschluessel:** kun_Id
- **Wichtige Felder:**
  - kun_Id - Kunden-ID
  - kun_Firma - Firmenname
  - kun_IstAktiv - Aktiv/Inaktiv
  - Adressdaten
  - Kontaktdaten
  - Rechnungsadresse
  - Zahlungsbedingungen

### tbl_OB_Objekt
- **Funktion:** Objekte/Einsatzorte
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID - Objekt-ID
  - Objektname
  - Adresse (Strasse, PLZ, Ort)
  - Ansprechpartner
  - Geo-Koordinaten (Lat, Lng)
  - Kunde_ID - FK zu Kunde

### tbl_OB_Objekt_Positionen
- **Funktion:** Positionen innerhalb eines Objekts
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID - Position-ID
  - Objekt_ID - FK zu Objekt
  - Positionsbezeichnung
  - Anforderungen

---

## AUFTRAGS-TABELLEN (VA_)

### tbl_VA_Auftragstamm
- **Funktion:** Auftragskopfdaten
- **Primaerschluessel:** ID (LONG, AutoIncrement)
- **Wichtige Felder:**
  - ID - Auftrags-ID
  - Auftrag - Auftragsbezeichnung
  - Veranstalter_ID - FK zu Kunde
  - Objekt - Location-Text
  - Objekt_ID - FK zu tbl_OB_Objekt
  - Strasse, PLZ, Ort - Auftragsadresse
  - Dat_VA_Von, Dat_VA_Bis - Zeitraum
  - Treffpunkt, Treffp_Zeit - Treffpunkt
  - Dienstkleidung - Dress-Code
  - Ansprechpartner - Kontakt vor Ort
  - Veranst_Status_ID - FK zu Status (1=offen, 2=in Bearbeitung, 3=abgeschlossen, 4=abgerechnet)
  - Bemerkungen - Freitext
  - Rch_Nr, Rch_Dat - Rechnungsinformationen
  - Erst_von, Erst_am, Aend_von, Aend_am - Audit
- **Indizes:** ID, Objekt_ID, Veranst_Status_ID, Veranstalter_ID

### tbl_VA_AnzTage
- **Funktion:** Einzelne Tage eines Auftrags
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID (VADatum_ID) - Tag-ID
  - VA_ID - FK zu Auftrag
  - VADatum - Datum des Tages
  - TVA_Soll - Soll-Anzahl MA
  - TVA_Ist - Ist-Anzahl MA

### tbl_VA_Start
- **Funktion:** Schichten/Startzeiten pro Tag
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID (VAStart_ID) - Schicht-ID
  - VA_ID - FK zu Auftrag
  - VADatum_ID - FK zu Tag
  - VADatum - Datum
  - VA_Start, VA_Ende - Schichtzeiten
  - MA_Anzahl - Soll-MA fuer diese Schicht
  - MA_Anzahl_Ist - Ist-MA fuer diese Schicht

### tbl_VA_Status / tbl_Veranst_Status
- **Funktion:** Auftragsstatus-Lookup
- **Werte:**
  - 1 = Offen/Geplant
  - 2 = In Bearbeitung/Angefragt
  - 3 = Abgeschlossen/Zugesagt
  - 4 = Abgerechnet/Abgesagt

---

## ZUORDNUNGS-TABELLEN

### tbl_MA_VA_Zuordnung
- **Funktion:** MA zu Auftrag/Schicht zugeordnet
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID - Zuordnungs-ID
  - VA_ID - FK zu Auftrag
  - VADatum_ID - FK zu Tag
  - VAStart_ID - FK zu Schicht
  - MA_ID - FK zu Mitarbeiter
  - PosNr - Position in der Zuordnung
  - MA_Start, MA_Ende - Individuelle Zeiten
  - MVA_Start, MVA_Ende - Geplante Zeiten (ACHTUNG: Aliase!)
  - MA_Brutto_Std2, MA_Netto_Std2 - Stunden
  - VADatum - Datum
  - RL_34a - 34a-Ruecklage
  - IstFraglich - Noch offen
  - PKW - Mit eigenem PKW
  - Erst_von, Erst_am, Aend_von, Aend_am - Audit

### tbl_MA_VA_Planung
- **Funktion:** MA-Anfragen/Planungen (vor Zuordnung)
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID - Planungs-ID
  - VA_ID - FK zu Auftrag
  - VADatum_ID - FK zu Tag
  - VAStart_ID - FK zu Schicht
  - MA_ID - FK zu Mitarbeiter
  - Status_ID - Planungsstatus (1=geplant, 2=angefragt, 3=zugesagt, 4=abgesagt)
  - Anfragezeitpunkt - Wann angefragt
  - MD5 - Hash fuer E-Mail-Tracking

---

## NICHTVERFUEGBARKEITS-TABELLEN

### tbl_MA_NVerfuegZeiten
- **Funktion:** Abwesenheiten/Nichtverfuegbarkeiten
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID - Eintrag-ID
  - MA_ID - FK zu Mitarbeiter
  - vonDat, bisDat - Zeitraum
  - Grund_ID - FK zu Grund
  - Bemerkung - Freitext

### tbl_MA_Zeittyp
- **Funktion:** Zeittypen/Abwesenheitsgruende
- **Wichtige Werte:**
  - Urlaub
  - Krank
  - Frei
  - Sonstiges

---

## RECHNUNGS-TABELLEN

### tbl_Rch_Kopf
- **Funktion:** Rechnungskopfdaten
- **Primaerschluessel:** ID
- **Wichtige Felder:**
  - ID - Rechnungs-ID
  - VA_ID - FK zu Auftrag
  - Rch_Nr - Rechnungsnummer
  - Rch_Datum - Rechnungsdatum
  - Kunde_ID - FK zu Kunde
  - Netto, Brutto, MwSt - Betraege
  - Zahlbedingung_ID - FK zu Zahlungsbedingung
  - Status_ID - Rechnungsstatus

### tbl_Rch_Pos_Auftrag
- **Funktion:** Rechnungspositionen pro Auftrag
- **Wichtige Felder:**
  - VA_ID - FK zu Auftrag
  - Positionstext
  - Menge, Einzelpreis
  - Netto, MwSt

### tbl_Rch_Pos_Geschrieben
- **Funktion:** Endgueltig geschriebene Positionen

### tbl_Rch_VA_Kopf
- **Funktion:** Rechnungszuordnung zu Auftraegen

### tbl_Rch_Status
- **Funktion:** Rechnungsstatus-Lookup

---

## E-MAIL-TABELLEN

### tbl_eMail_Import
- **Funktion:** Importierte E-Mails (Zu-/Absagen)
- **Wichtige Felder:**
  - Betreff
  - Sender
  - Empfangsdatum
  - Zu_Absage (-1=Zusage, 0=Absage)
  - MA_ID, VA_ID, VADatum_ID, VAStart_ID - Zuordnung
  - IstErledigt

### tbl_MA_Serien_eMail_Vorlage
- **Funktion:** E-Mail-Vorlagen

### tbl_eMail_Template_complete
- **Funktion:** Komplette E-Mail-Templates

### tbl_Log_eMail_Sent
- **Funktion:** Protokoll gesendeter E-Mails

---

## HILFS-/LOOKUP-TABELLEN

### _tblEigeneFirma
- **Funktion:** Eigene Firmenstammdaten
- **Wichtige Felder:**
  - Firmenname, Adresse
  - Bankdaten
  - Steuernummer
  - Mahntage (Mahn1Tage, Mahn2Tage, etc.)

### _tblEigeneFirma_Zahlungsbedingungen
- **Funktion:** Zahlungsbedingungen
- **Wichtige Felder:**
  - ID
  - Zahlungsbedingung - Text
  - AnzTage - Zahlungsziel
  - Skonto - Skonto-Prozent

### _tblEigeneFirma_Word_Nummernkreise
- **Funktion:** Nummernkreise (Rechnung, Angebot, etc.)

### _tblEigeneFirma_Mitarbeiter
- **Funktion:** Interne Benutzer

### _tblAlleTage
- **Funktion:** Alle Kalendertage mit Feiertagen
- **Wichtige Felder:**
  - JJJJMMTT - Datum-Schluessel
  - dtDatum - Datum
  - IstFeiertag, Feiertagsname
  - Bundesland-Feiertage (BBY, BBA, etc.)
  - Schulferien (FBY, FBA, etc.)
  - Wochentag, KW

### tbl_hlp_MA_Anstellungsart
- **Funktion:** Anstellungsarten-Lookup

### tbl_hlp_MA_Geschlecht
- **Funktion:** Geschlecht-Lookup

### tbl_KD_Adressart
- **Funktion:** Adressarten-Lookup

### tbl_KD_Anrede
- **Funktion:** Anreden-Lookup

### tbl_MA_Einsatzart
- **Funktion:** Einsatzarten/Qualifikationen

### tbl_MA_Plan_Status
- **Funktion:** Planungsstatus (geplant, angefragt, zugesagt, abgesagt)

---

## TEMPORAERE TABELLEN (tbltmp_)

### tbltmp_DP_Grund / tbltmp_DP_Grund_2 / tbltmp_DP_Grund_Sort
- **Funktion:** Temporaere Dienstplan-Gruende

### tbltmp_DP_MA_1 / tbltmp_DP_MA_Neu_1/2
- **Funktion:** Temporaere MA-Dienstplandaten

### tbltmp_MA_Auswahl
- **Funktion:** Temporaere MA-Auswahl

### tbltmp_MA_VA_Zuordnung
- **Funktion:** Temporaere Zuordnungen

### tbltmp_Textbaustein_Ersetzung
- **Funktion:** Temporaere Textbaustein-Ersetzungen

### tbltmp_Attachfile
- **Funktion:** Temporaere Attachment-Liste

---

## ZEITKONTEN-TABELLEN (ztbl_ZK_)

### ztbl_ZK_Daten
- **Funktion:** Zeitkontendaten

### ztbl_ZK_Stunden
- **Funktion:** Stunden fuer Zeitkonten

### ztbl_ZK_Lohnarten
- **Funktion:** Lohnarten

### ztbl_ZK_Importfehler
- **Funktion:** Import-Fehler bei Zeitkonten

### ztbl_ZK_Korrekturen
- **Funktion:** Korrekturbuchungen

### ztbl_Lohnabrechnungen
- **Funktion:** Lohnabrechnungen

---

## FRONTEND-TABELLEN (FE)

### ztbl_MA_VA_Planung_FE
- **Funktion:** Lokale Planungs-Kopie

### ztbl_MA_VA_Zuordnung_FE
- **Funktion:** Lokale Zuordnungs-Kopie

### ztbl_MA_NVerfuegZeiten_FE
- **Funktion:** Lokale Abwesenheits-Kopie

### ztbl_MA_Schnellauswahl
- **Funktion:** Schnellauswahl-MA-Liste

---

## SYSTEM-TABELLEN

### _tblProperty
- **Funktion:** Custom Properties

### _tblInternalSystemFE / _tblInternalSystemBE
- **Funktion:** System-Einstellungen FE/BE

### tbl_Protokoll
- **Funktion:** Aenderungsprotokoll

### tbl_ErrorLog
- **Funktion:** Fehlerprotokoll

### tblFensterpositionen
- **Funktion:** Gespeicherte Fensterpositionen

### ztbl_CloseAll
- **Funktion:** Alle Frontends schliessen (Remote-Befehl)

### ztbl_Log
- **Funktion:** Allgemeines Log

### USysRegInfo
- **Funktion:** Registry-Informationen (Access System)

---

## TABELLEN-BEZIEHUNGEN (Haupt)

```
tbl_KD_Kundenstamm (kun_Id)
    |
    +-- tbl_VA_Auftragstamm (Veranstalter_ID)
            |
            +-- tbl_VA_AnzTage (VA_ID)
            |       |
            |       +-- tbl_VA_Start (VADatum_ID)
            |               |
            |               +-- tbl_MA_VA_Zuordnung (VAStart_ID)
            |               |
            |               +-- tbl_MA_VA_Planung (VAStart_ID)
            |
            +-- tbl_Rch_Kopf (VA_ID)

tbl_MA_Mitarbeiterstamm (ID)
    |
    +-- tbl_MA_VA_Zuordnung (MA_ID)
    |
    +-- tbl_MA_VA_Planung (MA_ID)
    |
    +-- tbl_MA_NVerfuegZeiten (MA_ID)
    |
    +-- tbl_MA_Dienstkleidung (MA_ID)

tbl_OB_Objekt (ID)
    |
    +-- tbl_VA_Auftragstamm (Objekt_ID)
    |
    +-- tbl_OB_Objekt_Positionen (Objekt_ID)
```

---

## TABELLEN-KATEGORIEN STATISTIK

| Kategorie | Praefix | Anzahl |
|-----------|---------|--------|
| Mitarbeiter | tbl_MA_ | ~15 |
| Auftrag | tbl_VA_ | ~10 |
| Kunde | tbl_KD_ | ~8 |
| Objekt | tbl_OB_ | ~3 |
| Rechnung | tbl_Rch_ | ~6 |
| Eigene Firma | _tblEigeneFirma_ | ~10 |
| Hilfs/Lookup | tbl_hlp_, _tbl | ~25 |
| Temporaer | tbltmp_ | ~30 |
| Zeitkonten | ztbl_ZK_ | ~15 |
| System/Log | tbl_Protokoll, tbl_Log | ~10 |
| Frontend | _FE | ~8 |
| Sonstige | diverse | ~50 |
