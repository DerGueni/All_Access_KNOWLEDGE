# Control-Inventar fuer E2E-Tests

**Version:** 1.0
**Generiert:** 2026-01-07
**Pfad:** `04_HTML_Forms\forms3\`

---

## Zusammenfassung

| Metrik | Wert |
|--------|------|
| Anzahl Formulare | 5 |
| Anzahl Controls | 194 |
| Button | 89 |
| Input | 53 |
| Select | 18 |
| Tab | 20 |
| Checkbox | 12 |
| Textarea | 5 |
| Date | 6 |
| Table | 3 |
| Div | 7 |
| File | 1 |

---

## 1. frm_va_Auftragstamm

**Datei:** `frm_va_Auftragstamm.html`
**Beschreibung:** Auftragsverwaltung - Hauptformular

### Buttons (Aktionen)

| Selector | Event | Erwartete Aktion | API Endpoint |
|----------|-------|------------------|--------------|
| `#fullscreenBtn` | click | toggles fullscreen mode | - |
| `#btnAktualisieren` | click | refreshes data from API | GET /api/auftraege/{id} |
| `#btnSchnellPlan` | click | opens Mitarbeiterauswahl dialog | - |
| `#btnPositionen` | click | opens Positionen view | GET /api/auftraege/{id}/positionen |
| `#btnNeuAuftrag` | click | creates new Auftrag | POST /api/auftraege |
| `#btnKopieren` | click | copies current Auftrag | POST /api/auftraege/{id}/copy |
| `#btnLöschen` | click | deletes current Auftrag with confirmation | DELETE /api/auftraege/{id} |
| `#btnListeStd` | click | prints Namensliste ESS | - |
| `#btnDruckZusage` | click | prints Einsatzliste | - |
| `#btnMailEins` | click | sends Einsatzliste to MA | POST /api/email/einsatzliste/ma |
| `#btnMailBOS` | click | sends Einsatzliste to BOS | POST /api/email/einsatzliste/bos |
| `#btnMailSub` | click | sends Einsatzliste to SUB | POST /api/email/einsatzliste/sub |
| `#btnELGesendet` | click | shows EL sent status | - |
| `#btnDatumLeft` | click | navigates to previous VA date | - |
| `#btnDatumRight` | click | navigates to next VA date | - |

### Inputs (Felder)

| Selector | Typ | Event | Validierung | API |
|----------|-----|-------|-------------|-----|
| `#ID` | text | - | readonly | - |
| `#Rech_NR` | text | - | readonly | - |
| `#Auftrag` | text | change | required | PUT /api/auftraege/{id} |
| `#Ort` | text | change | - | PUT /api/auftraege/{id} |
| `#Objekt` | text | change | - | PUT /api/auftraege/{id} |
| `#PKW_Anzahl` | number | change | min=0 | PUT /api/auftraege/{id} |
| `#Fahrtkosten` | text | change | - | PUT /api/auftraege/{id} |
| `#Treffp_Zeit` | time | change | - | PUT /api/auftraege/{id} |
| `#Treffpunkt` | text | change | - | PUT /api/auftraege/{id} |
| `#Dienstkleidung` | text | change | - | PUT /api/auftraege/{id} |
| `#Ansprechpartner` | text | change | - | PUT /api/auftraege/{id} |

### Datum-Felder

| Selector | Event | Validierung | API |
|----------|-------|-------------|-----|
| `#Dat_VA_Von` | change | required | PUT /api/auftraege/{id} |
| `#Dat_VA_Bis` | change | - | PUT /api/auftraege/{id} |
| `#Aufträge_ab` | change | - | - |

### Selects (Dropdowns)

| Selector | Event | API |
|----------|-------|-----|
| `#Veranst_Status_ID` | change | PUT /api/auftraege/{id} |
| `#Objekt_ID` | change | PUT /api/auftraege/{id} |
| `#cboVADatum` | change | GET /api/auftraege/{id}/einsatztage |
| `#Veranstalter_ID` | change | PUT /api/auftraege/{id} |

### Tabs

| Selector | Tab-Name |
|----------|----------|
| `[data-tab='einsatzliste']` | Einsatzliste |
| `[data-tab='antworten']` | Antworten ausstehend |
| `[data-tab='zusatzdateien']` | Zusatzdateien |
| `[data-tab='rechnung']` | Rechnung |
| `[data-tab='bemerkungen']` | Bemerkungen |
| `[data-tab='eventdaten']` | Eventdaten |

### Checkboxen

| Selector | Beschreibung |
|----------|--------------|
| `#cbAutosendEL` | Autosend EL aktivieren |

---

## 2. frm_MA_Mitarbeiterstamm

**Datei:** `frm_MA_Mitarbeiterstamm.html`
**Beschreibung:** Mitarbeiterverwaltung - Stammdaten und Einsaetze

### Navigation

| Selector | Aktion |
|----------|--------|
| `#btnErste` | Erster Datensatz |
| `#btnVorige` | Vorheriger Datensatz |
| `#btnNächste` | Naechster Datensatz |
| `#btnLetzte` | Letzter Datensatz |

### Haupt-Buttons

| Selector | Event | API Endpoint |
|----------|-------|--------------|
| `#btnMAAdressen` | click | - |
| `#btnAktualisieren` | click | GET /api/mitarbeiter/{id} |
| `#btnZeitkonto` | click | - |
| `#btnNeuMA` | click | POST /api/mitarbeiter |
| `#btnLöschen` | click | DELETE /api/mitarbeiter/{id} |
| `#btnEinsaetzeFA` | click | - |
| `#btnEinsaetzeMJ` | click | - |
| `#btnListenDrucken` | click | - |
| `#btnMATabelle` | click | - |
| `#btnDienstplan` | click | - |
| `#btnEinsatzÜbersicht` | click | - |
| `#btnMapsÖffnen` | click | - |
| `#btnSpeichern` | click | PUT /api/mitarbeiter/{id} |

### Stammdaten-Felder

| Selector | Typ | Validierung |
|----------|-----|-------------|
| `#ID` | text | readonly |
| `#LEXWare_ID` | text | - |
| `#Nachname` | text | required |
| `#Vorname` | text | required |
| `#Strasse` | text | - |
| `#PLZ` | text | pattern=[0-9]{5} |
| `#Ort` | text | - |
| `#Tel_Mobil` | tel | tel pattern |
| `#Tel_Festnetz` | tel | tel pattern |
| `#Email` | email | email pattern |
| `#IBAN` | text | IBAN pattern |
| `#BIC` | text | BIC pattern |

### Checkboxen

| Selector | Beschreibung |
|----------|--------------|
| `#IstAktiv` | MA ist aktiv |
| `#Lex_Aktiv` | Lexware aktiv |
| `#IstSubunternehmer` | Ist Subunternehmer |
| `#Hat_Fahrerausweis` | Hat Fahrerausweis |
| `#Eigener_PKW` | Hat eigenen PKW |
| `#Hat_keine_34a` | Hat keine 34a |
| `#HatSachkunde` | Hat Sachkunde |

### Tabs

| Tab-Name | API Endpoint |
|----------|--------------|
| Stammdaten | - |
| Einsatzuebersicht | GET /api/mitarbeiter/{id}/einsaetze |
| Dienstplan | GET /api/dienstplan/ma/{id} |
| Nicht Verfuegbar | GET /api/abwesenheiten?ma_id={id} |
| Dienstkleidung | - |
| Zeitkonto | GET /api/zeitkonten?ma_id={id} |
| Qualifikationen | - |
| Dokumente | - |

---

## 3. frm_KD_Kundenstamm

**Datei:** `frm_KD_Kundenstamm.html`
**Beschreibung:** Kundenverwaltung - Stammdaten und Konditionen

### Haupt-Buttons

| Selector | Event | API Endpoint |
|----------|-------|--------------|
| `#btnAktualisieren` | click | GET /api/kunden/{id} |
| `#btnVerrechnungssaetze` | click | - |
| `#btnUmsatzauswertung` | click | - |
| `#btnOutlook` | click | - |
| `#btnWord` | click | - |
| `#btnNeuKunde` | click | POST /api/kunden |
| `#btnLöschen` | click | DELETE /api/kunden/{id} |
| `#btnSpeichern` | click | PUT /api/kunden/{id} |

### Navigation

| Selector | Aktion |
|----------|--------|
| Erste | Erster Datensatz |
| Vorige | Vorheriger Datensatz |
| Naechste | Naechster Datensatz |
| Letzte | Letzter Datensatz |

### Stammdaten-Felder

| Selector | Typ | Validierung |
|----------|-----|-------------|
| `#kun_Firma` | text | required |
| `#kun_bezeichnung` | text | - |
| `#kun_Matchcode` | text | - |
| `#kun_Strasse` | text | - |
| `#kun_PLZ` | text | pattern=[0-9]{5} |
| `#kun_Ort` | text | - |
| `#kun_telefon` | tel | tel pattern |
| `#kun_email` | email | email pattern |
| `#kun_iban` | text | IBAN pattern |

### Checkboxen

| Selector | Beschreibung |
|----------|--------------|
| `#kun_IstAktiv` | Kunde ist aktiv |
| `#kun_IstSammelRechnung` | Sammelrechnung |
| `#chkNurAktive` | Nur aktive anzeigen |

### Tabs

| Tab-Name | API Endpoint |
|----------|--------------|
| Stammdaten | - |
| Objekte | GET /api/kunden/{id}/objekte |
| Konditionen | - |
| Auftragsübersicht | GET /api/auftraege?kunde_id={id} |
| Ansprechpartner | GET /api/kunden/{id}/ansprechpartner |
| Zusatzdateien | - |
| Bemerkungen | - |
| Preise | GET /api/kunden/{id}/preise |

---

## 4. frm_OB_Objekt

**Datei:** `frm_OB_Objekt.html`
**Beschreibung:** Objektverwaltung - Stammdaten und Positionen

### Navigation

| Selector | Aktion |
|----------|--------|
| `|<` | Erster Datensatz |
| `<` | Vorheriger Datensatz |
| `>` | Naechster Datensatz |
| `>|` | Letzter Datensatz |

### Haupt-Buttons

| Button | Event | API Endpoint |
|--------|-------|--------------|
| `+ Neu` | click | POST /api/objekte |
| `Speichern` | click | PUT /api/objekte/{id} |
| `Loeschen` | click | DELETE /api/objekte/{id} |
| `Bericht` | click | - |
| `Neuer Veranstalter` | click | - |
| `Geocode` | click | PUT /api/objekte/{id}/geo |
| `?` | click | Hilfe anzeigen |

### Positions-Buttons

| Button | API Endpoint |
|--------|--------------|
| `+ Neue Position` | POST /api/objekte/{id}/positionen |
| `Position loeschen` | DELETE /api/objekte/positionen/{id} |
| `Import` | POST /api/objekte/{id}/positionen/import |
| `Excel` | GET /api/objekte/{id}/positionen/export |
| `Kopieren` | POST /api/objekte/{id}/positionen/copy |
| `Vorlage speichern` | POST /api/objekte/vorlagen |
| `Vorlage laden` | POST /api/objekte/{id}/positionen/vorlage |

### Stammdaten-Felder

| Selector | Typ | Validierung |
|----------|-----|-------------|
| `#ID` | text | readonly |
| `#Objekt` | text | required |
| `#Strasse` | text | - |
| `#PLZ` | text | pattern=[0-9]{5} |
| `#Ort` | text | - |
| `#txtLat` | text | readonly |
| `#txtLon` | text | readonly |
| `#Treffpunkt` | text | - |
| `#Treffp_Zeit` | text | - |
| `#Dienstkleidung` | text | - |
| `#Ansprechpartner` | text | - |

### Tabs

| Tab-Name | API Endpoint |
|----------|--------------|
| Positionen | GET /api/objekte/{id}/positionen |
| Zusatzdateien | - |
| Bemerkungen | - |
| Auftraege | GET /api/objekte/{id}/auftraege |

---

## 5. frm_N_Dienstplanuebersicht

**Datei:** `frm_N_Dienstplanuebersicht.html`
**Beschreibung:** Dienstplanuebersicht - 7-Tage Kalenderansicht

### Datum-Navigation

| Selector | Aktion |
|----------|--------|
| `#dtStartdatum` | Startdatum waehlen (dblclick oeffnet Picker) |
| `#btnStartdatum` | Aktualisieren - Daten laden |
| `#btnVor` | +2 Tage vor |
| `#btnrück` | -2 Tage zurueck |
| `#btn_Heute` | Zum heutigen Datum |

### Haupt-Buttons

| Selector | Event | API Endpoint |
|----------|-------|--------------|
| `#Befehl37` | click | Formular schliessen |
| `#btnDPSenden` | click | POST /api/email/dienstplaene |
| `#btnMADienstpl` | click | Einzeldienstplaene oeffnen |
| `#btnOutpExcel` | click | Excel-Export |
| `#btnOutpExcelSend` | click | Excel senden |
| `#Befehl20` | click | Outlook oeffnen |

### Tages-Header (7 Tage)

| Selector | Event | Beschreibung |
|----------|-------|--------------|
| `#lbl_Tag_1` | dblclick | Montag - Zu diesem Tag springen |
| `#lbl_Tag_2` | dblclick | Dienstag |
| `#lbl_Tag_3` | dblclick | Mittwoch |
| `#lbl_Tag_4` | dblclick | Donnerstag |
| `#lbl_Tag_5` | dblclick | Freitag |
| `#lbl_Tag_6` | dblclick | Samstag (Wochenende - rot) |
| `#lbl_Tag_7` | dblclick | Sonntag (Wochenende - rot) |

### Filter

| Selector | Optionen |
|----------|----------|
| `#NurAktiveMA` | Nur aktive MA / Alle MA / Nur mit Einsatz |

### Sidebar-Navigation

| Button | Ziel |
|--------|------|
| Dienstplanuebersicht | (aktuell) |
| Planungsuebersicht | frm_VA_Planungsuebersicht |
| Auftragsverwaltung | frm_va_Auftragstamm |
| Mitarbeiterverwaltung | frm_MA_Mitarbeiterstamm |
| Offene Anfragen | frm_MA_VA_Schnellauswahl |

---

## API Endpoints Uebersicht

### Auftraege

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| GET | `/api/auftraege` | Liste aller Auftraege |
| GET | `/api/auftraege/{id}` | Einzelner Auftrag |
| POST | `/api/auftraege` | Neuer Auftrag |
| PUT | `/api/auftraege/{id}` | Auftrag aktualisieren |
| DELETE | `/api/auftraege/{id}` | Auftrag loeschen |
| POST | `/api/auftraege/{id}/copy` | Auftrag kopieren |
| GET | `/api/auftraege/{id}/positionen` | Positionen zu Auftrag |
| GET | `/api/auftraege/{id}/einsatztage` | Einsatztage zu Auftrag |

### Mitarbeiter

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| GET | `/api/mitarbeiter` | Liste aller MA |
| GET | `/api/mitarbeiter/{id}` | Einzelner MA |
| POST | `/api/mitarbeiter` | Neuer MA |
| PUT | `/api/mitarbeiter/{id}` | MA aktualisieren |
| DELETE | `/api/mitarbeiter/{id}` | MA loeschen |
| GET | `/api/mitarbeiter/{id}/einsaetze` | Einsaetze des MA |
| POST | `/api/mitarbeiter/{id}/foto` | Foto hochladen |

### Kunden

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| GET | `/api/kunden` | Liste aller Kunden |
| GET | `/api/kunden/{id}` | Einzelner Kunde |
| POST | `/api/kunden` | Neuer Kunde |
| PUT | `/api/kunden/{id}` | Kunde aktualisieren |
| DELETE | `/api/kunden/{id}` | Kunde loeschen |
| GET | `/api/kunden/{id}/objekte` | Objekte des Kunden |
| GET | `/api/kunden/{id}/ansprechpartner` | Ansprechpartner |
| GET | `/api/kunden/{id}/preise` | Kundenpreise |

### Objekte

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| GET | `/api/objekte` | Liste aller Objekte |
| GET | `/api/objekte/{id}` | Einzelnes Objekt |
| POST | `/api/objekte` | Neues Objekt |
| PUT | `/api/objekte/{id}` | Objekt aktualisieren |
| DELETE | `/api/objekte/{id}` | Objekt loeschen |
| PUT | `/api/objekte/{id}/geo` | Geocodierung |
| GET | `/api/objekte/{id}/positionen` | Positionen |
| POST | `/api/objekte/{id}/positionen` | Neue Position |
| DELETE | `/api/objekte/positionen/{id}` | Position loeschen |
| GET | `/api/objekte/{id}/auftraege` | Auftraege zum Objekt |

### Dienstplan / Zuordnungen

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| GET | `/api/zuordnungen` | MA-Zuordnungen |
| GET | `/api/dienstplan/ma/{id}` | Dienstplan eines MA |
| GET | `/api/abwesenheiten` | Abwesenheiten |
| GET | `/api/zeitkonten` | Zeitkonten |

---

## E2E Test Empfehlungen

### Prioritaet 1 - Kritische Pfade

1. **Auftrag erstellen und bearbeiten**
   - Neuer Auftrag anlegen
   - Pflichtfelder ausfuellen
   - Speichern
   - Daten via API verifizieren

2. **Mitarbeiter anlegen**
   - Neuer MA
   - Stammdaten eingeben
   - Speichern
   - In Liste suchen

3. **Kunde anlegen mit Objekt**
   - Neuer Kunde
   - Stammdaten
   - Neues Objekt hinzufuegen
   - Verknuepfung pruefen

### Prioritaet 2 - Navigation

1. **Tab-Wechsel in allen Formularen**
2. **Datensatz-Navigation (Erste/Vorige/Naechste/Letzte)**
3. **Sidebar-Navigation in Dienstplan**

### Prioritaet 3 - Spezialfunktionen

1. **Einsatzliste senden**
2. **Excel-Export**
3. **Geocodierung**
4. **Positionen importieren/exportieren**

---

*Generiert fuer E2E-Tests mit Playwright*
