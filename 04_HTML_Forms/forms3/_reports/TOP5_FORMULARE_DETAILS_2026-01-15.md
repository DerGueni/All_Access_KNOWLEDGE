# Top 5 Prioritäre Formulare - Detailanalyse

**Datum:** 2026-01-15
**Status:** Bereit zur Implementierung

---

## 1. frmTop_Login (PRIORITÄT 2)

### Zweck
Benutzer-Authentifizierung und Session-Management für das gesamte System.

### Funktionsumfang
- Benutzer-Login (Username/Passwort)
- Rechte-Verwaltung (Admin, User, Readonly)
- Session-Verwaltung
- "Angemeldet bleiben" Funktion
- Passwort vergessen / Reset

### Datenbank-Tabellen
- `tbl_MA_Mitarbeiterstamm` (ID, Nachname, Vorname, IstAktiv)
- `tbl_User` (UserID, MA_ID, Username, PasswordHash, Rolle)
- `tbl_User_Rechte` (UserID, Modul, Berechtigung)

### UI-Komponenten
| Control | Typ | Beschreibung |
|---------|-----|--------------|
| txtUsername | TextBox | Benutzername-Eingabe |
| txtPassword | PasswordBox | Passwort-Eingabe (maskiert) |
| btnLogin | Button | Login-Button |
| chkRememberMe | Checkbox | Angemeldet bleiben |
| lnkForgotPassword | Link | Passwort vergessen |
| lblError | Label | Fehlerausgabe (rot) |

### API-Endpoints (neu erforderlich)
```
POST /api/auth/login
  Body: { username, password, rememberMe }
  Response: { success, token, user: { id, name, rolle } }

POST /api/auth/logout
  Body: { token }
  Response: { success }

GET /api/auth/session
  Headers: { Authorization: Bearer <token> }
  Response: { valid, user }

POST /api/auth/password-reset
  Body: { email }
  Response: { success, message }
```

### Implementierungs-Schritte
1. HTML-Formular erstellen (Modal-Design)
2. JWT-Token-Generierung im API-Server
3. Session-Storage im Browser
4. Rechteverwaltung implementieren
5. Integration in alle HTML-Formulare (Auth-Check)

### Aufwands-Schätzung
**3 Tage** (EINFACH)
- Tag 1: HTML/CSS, Login-Form
- Tag 2: API-Endpoints, JWT-Logik
- Tag 3: Session-Management, Testing

---

## 2. frmTop_MA_Tagesuebersicht (PRIORITÄT 2)

### Zweck
Übersicht aller Mitarbeiter und deren Verfügbarkeit/Einsätze für einen bestimmten Tag.

### Funktionsumfang
- Tages-Ansicht (Datum wählen)
- Liste aller aktiven MA
- Verfügbarkeits-Status (verfügbar, im Einsatz, abwesend, krank)
- Einsatz-Details (Objekt, Schicht, Zeiten)
- Filter: Nur verfügbare MA, Nur im Einsatz
- Export: Excel, PDF

### Datenbank-Tabellen
- `tbl_MA_Mitarbeiterstamm` (ID, Nachname, Vorname, IstAktiv)
- `tbl_MA_VA_Planung` (MA_ID, VADatum, VA_Start, VA_Ende, Objekt_ID)
- `tbl_MA_NVerfuegZeiten` (MA_ID, vonDat, bisDat, Grund)
- `tbl_VA_Auftragstamm` (Auftrag, Objekt, Veranstalter)

### UI-Komponenten
| Control | Typ | Beschreibung |
|---------|-----|--------------|
| dtpDatum | DatePicker | Datum auswählen |
| btnHeute | Button | Auf heute springen |
| btnVorTag | Button | Vorheriger Tag |
| btnNaechsterTag | Button | Nächster Tag |
| dgvTagesuebersicht | DataGrid | MA-Liste mit Status |
| cboFilterStatus | ComboBox | Filter (Alle, Verfügbar, Im Einsatz) |
| btnExport | Button | Export Excel/PDF |

### DataGrid Spalten
| Spalte | Typ | Quelle |
|--------|-----|--------|
| Lfd | Number | Auto-Nummerierung |
| Mitarbeiter | Text | Nachname, Vorname |
| Status | Badge | Berechnet (verfügbar/einsatz/abwesend) |
| Objekt | Text | tbl_VA_Auftragstamm.Objekt |
| Schicht | Text | VA_Start - VA_Ende |
| Stunden | Number | Berechnet aus Zeiten |
| Bemerkung | Text | Abwesenheitsgrund |

### API-Endpoints (neu erforderlich)
```
GET /api/mitarbeiter/tagesuebersicht/:datum
  Response: [
    {
      ma_id, name, status,
      einsatz: { objekt, schicht_von, schicht_bis },
      abwesenheit: { grund, von, bis }
    }
  ]

GET /api/mitarbeiter/verfuegbar/:datum
  Response: [ { ma_id, name } ]
```

### Implementierungs-Schritte
1. HTML-Layout mit DatePicker + DataGrid
2. API-Endpoint für Tagesübersicht
3. Status-Berechnung (verfügbar/einsatz/abwesend)
4. Filter-Funktionalität
5. Export-Funktionen (Excel, PDF)

### Aufwands-Schätzung
**5 Tage** (MITTEL)
- Tag 1-2: HTML/CSS, DataGrid-Layout
- Tag 3: API-Endpoint, Status-Logik
- Tag 4: Filter + Navigation
- Tag 5: Export, Testing

---

## 3. frm_Rechnungen_bezahlt_offen (PRIORITÄT 2)

### Zweck
Übersicht aller Rechnungen mit Status bezahlt/offen, Summen, Filter.

### Funktionsumfang
- Liste aller Rechnungen
- Filter: bezahlt, offen, überfällig
- Summen: Gesamt, bezahlt, offen
- Suche: Rechnungsnummer, Kunde
- Detail-Ansicht: Rechnungsdetails öffnen
- Zahlungseingang buchen

### Datenbank-Tabellen
- `tbl_Rch_Kopf` (Rch_Nummer, Rch_Datum, KD_ID, Betrag, IstBezahlt, Bezahlt_Am)
- `tbl_Rch_Pos` (Rch_ID, Position, Beschreibung, Betrag)
- `tbl_KD_Kundenstamm` (kun_Id, kun_Firma)

### UI-Komponenten
| Control | Typ | Beschreibung |
|---------|-----|--------------|
| cboFilterStatus | ComboBox | Alle/Offen/Bezahlt/Überfällig |
| txtSuche | TextBox | Suche Rechnungsnr/Kunde |
| dgvRechnungen | DataGrid | Rechnungsliste |
| lblSummeGesamt | Label | Summe alle Rechnungen |
| lblSummeOffen | Label | Summe offene Rechnungen |
| lblSummeBezahlt | Label | Summe bezahlte Rechnungen |
| btnZahlungEingang | Button | Zahlung buchen |
| btnDetails | Button | Rechnung öffnen |

### DataGrid Spalten
| Spalte | Typ | Quelle |
|--------|-----|--------|
| Rch_Nummer | Text | tbl_Rch_Kopf.Rch_Nummer |
| Rch_Datum | Date | tbl_Rch_Kopf.Rch_Datum |
| Kunde | Text | tbl_KD_Kundenstamm.kun_Firma |
| Betrag | Currency | tbl_Rch_Kopf.Betrag |
| Status | Badge | Berechnet (offen/bezahlt/überfällig) |
| Bezahlt_Am | Date | tbl_Rch_Kopf.Bezahlt_Am |

### API-Endpoints (neu erforderlich)
```
GET /api/rechnungen/liste
  Query: { status: 'alle'|'offen'|'bezahlt'|'ueberfaellig' }
  Response: [ { rch_id, nummer, datum, kunde, betrag, status, bezahlt_am } ]

GET /api/rechnungen/summen
  Response: { gesamt, offen, bezahlt, ueberfaellig }

POST /api/rechnungen/:id/zahlung
  Body: { betrag, datum, bemerkung }
  Response: { success }
```

### Implementierungs-Schritte
1. HTML-Layout mit Filter + DataGrid
2. API-Endpoints für Liste + Summen
3. Filter-Logik (offen/bezahlt/überfällig)
4. Summen-Berechnung
5. Zahlungseingang-Dialog

### Aufwands-Schätzung
**4 Tage** (MITTEL)
- Tag 1: HTML/CSS, DataGrid
- Tag 2: API-Endpoints, Filter
- Tag 3: Summen, Status-Badges
- Tag 4: Zahlungseingang, Testing

---

## 4. frmTop_DP_Auftrageingabe (PRIORITÄT 2)

### Zweck
Dialog zum Anlegen/Bearbeiten von Aufträgen mit Schichten und MA-Zuordnung.

### Funktionsumfang
- Auftrag anlegen (Kunde, Objekt, Zeitraum)
- Schichten definieren (Datum, Uhrzeit, MA-Anzahl)
- MA-Zuordnung (Schnellauswahl, Anfragen)
- Status-Verwaltung (Planung, Bestätigt, Abgeschlossen)
- Schichten kopieren (von anderem Auftrag)
- Vorlagen verwenden

### Datenbank-Tabellen
- `tbl_VA_Auftragstamm` (Auftrag, Veranstalter_ID, Objekt_ID, VA_Status)
- `tbl_VA_AnzTage` (VA_ID, VADatum)
- `tbl_VA_Start` (VA_ID, VADatum, VA_Start, VA_Ende, MA_Anzahl)
- `tbl_MA_VA_Planung` (VA_ID, VADatum_ID, VAStart_ID, MA_ID, MVA_Start, MVA_Ende)

### UI-Komponenten
| Section | Controls | Beschreibung |
|---------|----------|--------------|
| **Stammdaten** | cboKunde, cboObjekt, dtpVon, dtpBis | Auftragskopf |
| **Schichten** | dgvSchichten, btnSchichtNeu, btnSchichtLoeschen | Schicht-Verwaltung |
| **MA-Zuordnung** | dgvMAZuordnung, btnMAHinzufuegen, btnMAAbrufen | MA-Planung |
| **Aktionen** | btnSpeichern, btnAbbrechen, btnKopieren | Hauptaktionen |

### DataGrid: Schichten
| Spalte | Typ | Beschreibung |
|--------|-----|--------------|
| Datum | Date | VADatum |
| von | Time | VA_Start |
| bis | Time | VA_Ende |
| MA_Anzahl | Number | Erforderliche MA |
| MA_Ist | Number | Zugeordnete MA |
| Status | Badge | Vollständig/Unvollständig |

### DataGrid: MA-Zuordnung
| Spalte | Typ | Beschreibung |
|--------|-----|--------------|
| Mitarbeiter | ComboBox | MA-Auswahl |
| von | Time | MVA_Start |
| bis | Time | MVA_Ende |
| Status | ComboBox | Angefragt/Bestätigt/Abgesagt |
| Bemerkung | Text | Notizen |

### API-Endpoints (neu erforderlich)
```
POST /api/auftraege/neu
  Body: { kunde_id, objekt_id, von_datum, bis_datum }
  Response: { va_id, success }

POST /api/auftraege/:va_id/schicht
  Body: { datum, va_start, va_ende, ma_anzahl }
  Response: { schicht_id, success }

POST /api/auftraege/:va_id/ma-zuordnung
  Body: { schicht_id, ma_id, mva_start, mva_ende, status }
  Response: { zuordnung_id, success }

POST /api/auftraege/:va_id/schichten-kopieren
  Body: { von_va_id, von_datum, nach_datum }
  Response: { success, anzahl_kopiert }
```

### Implementierungs-Schritte
1. HTML-Layout (3-Section Design: Stammdaten, Schichten, MA)
2. API-Endpoints für Auftrag anlegen
3. Schichten-Verwaltung (CRUD)
4. MA-Zuordnung mit Schnellauswahl
5. Kopier-Funktion
6. Validierung + Testing

### Aufwands-Schätzung
**10 Tage** (KOMPLEX)
- Tag 1-2: HTML/CSS, Layout
- Tag 3-4: API-Endpoints (Auftrag, Schichten)
- Tag 5-6: MA-Zuordnung
- Tag 7-8: Kopier-Funktion, Vorlagen
- Tag 9-10: Validierung, Testing

---

## 5. frm_Zeiterfassung (PRIORITÄT 2)

### Zweck
Zeitbuchungen für Mitarbeiter erfassen, Zeitkonten verwalten.

### Funktionsumfang
- Zeitbuchung erfassen (MA, Datum, von, bis, Typ)
- Zeitkonto-Übersicht (Soll, Ist, Differenz)
- Korrektur-Buchungen
- Pausenzeiten berücksichtigen
- Fehlzeiten erfassen (Krank, Urlaub, Feiertag)
- Monats-Übersicht

### Datenbank-Tabellen
- `tbl_MA_Zeitkonten` (MA_ID, Jahr, Monat, Soll_Stunden, Ist_Stunden, Differenz)
- `tbl_MA_Zeitkonto_Buchungen` (MA_ID, Datum, von, bis, Typ, Bemerkung)
- `tbl_MA_NVerfuegZeiten` (MA_ID, vonDat, bisDat, Grund)

### UI-Komponenten
| Section | Controls | Beschreibung |
|---------|----------|--------------|
| **Zeitbuchung** | cboMA, dtpDatum, txtVon, txtBis, cboTyp | Buchung erfassen |
| **Zeitkonto** | lblSoll, lblIst, lblDifferenz, progressBar | Monats-Übersicht |
| **Buchungs-Liste** | dgvBuchungen, btnBearbeiten, btnLoeschen | Alle Buchungen |
| **Aktionen** | btnSpeichern, btnAbbrechen, btnExport | Hauptaktionen |

### DataGrid: Buchungen
| Spalte | Typ | Beschreibung |
|--------|-----|--------------|
| Datum | Date | Buchungsdatum |
| von | Time | Start-Zeit |
| bis | Time | Ende-Zeit |
| Stunden | Number | Berechnete Stunden |
| Typ | Badge | Arbeit/Pause/Krank/Urlaub |
| Bemerkung | Text | Notizen |
| Bearbeiten | Button | Buchung ändern |

### API-Endpoints (neu erforderlich)
```
POST /api/zeiterfassung/buchung
  Body: { ma_id, datum, von, bis, typ, bemerkung }
  Response: { buchung_id, success }

GET /api/zeitkonten/:ma_id/:jahr/:monat
  Response: { soll, ist, differenz, buchungen: [] }

PUT /api/zeiterfassung/buchung/:id
  Body: { von, bis, typ, bemerkung }
  Response: { success }

DELETE /api/zeiterfassung/buchung/:id
  Response: { success }
```

### Implementierungs-Schritte
1. HTML-Layout (Buchung + Übersicht)
2. API-Endpoints für Buchungen
3. Zeitkonto-Berechnung
4. Buchungs-Verwaltung (CRUD)
5. Validierung (Überschneidungen prüfen)
6. Monats-Übersicht, Export

### Aufwands-Schätzung
**7 Tage** (KOMPLEX)
- Tag 1-2: HTML/CSS, Layout
- Tag 3-4: API-Endpoints, Buchungslogik
- Tag 5: Zeitkonto-Berechnung
- Tag 6: Validierung, Überschneidungen
- Tag 7: Export, Testing

---

## Zusammenfassung Top 5

| Formular | Priorität | Aufwand | Komplexität | Start-Empfehlung |
|----------|-----------|---------|-------------|------------------|
| frmTop_Login | 2 | 3 Tage | EINFACH | **SOFORT** |
| frmTop_MA_Tagesuebersicht | 2 | 5 Tage | MITTEL | Woche 1 |
| frm_Rechnungen_bezahlt_offen | 2 | 4 Tage | MITTEL | Woche 2 |
| frmTop_DP_Auftrageingabe | 2 | 10 Tage | KOMPLEX | Woche 3-4 |
| frm_Zeiterfassung | 2 | 7 Tage | KOMPLEX | Bei Bedarf |

**Gesamt-Aufwand:** 29 Tage (ca. 6 Wochen)

---

## Nächste Schritte

1. **Login implementieren** (Basis-Authentifizierung erforderlich)
2. **MA-Tagesübersicht** (tägliche Planung)
3. **Rechnungsübersicht** (Finanz-Kontrolle)
4. **Auftragseingabe** (Planungs-Workflow)
5. **Zeiterfassung** (bei Bedarf, kann warten)

---

**Erstellt:** 2026-01-15
**Autor:** Claude Code
**Status:** Bereit für Implementierung
