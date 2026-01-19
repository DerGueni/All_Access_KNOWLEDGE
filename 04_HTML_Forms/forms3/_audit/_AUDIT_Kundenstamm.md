# AUDIT-BERICHT: frm_KD_Kundenstamm.html

**Datum:** 2026-01-05
**Pruefung:** Funktionalitaetsvergleich HTML vs. Access-Original
**HTML-Datei:** `/04_HTML_Forms/forms3/frm_KD_Kundenstamm.html`
**Access-Original:** `frm_KD_Kundenstamm` (Export: 30.12.2025)

---

## ZUSAMMENFASSUNG

| Kategorie | Status | Anzahl |
|-----------|--------|--------|
| VOLLSTAENDIG | Implementiert und funktional | 47 |
| FEHLT | Nicht implementiert | 14 |
| FEHLERHAFT | Implementiert aber fehlerhaft/unvollstaendig | 8 |

**Gesamtbewertung:** ca. 70% der Access-Funktionalitaet ist implementiert.

---

## 1. BUTTONS - VOLLSTAENDIG IMPLEMENTIERT

### Header-Bereich

| Access-Control | HTML-Element | Funktion | Status |
|----------------|--------------|----------|--------|
| `Befehl39` (|<) | `gotoFirstRecord()` | Erster Datensatz | VOLLSTAENDIG |
| `Befehl40` (<) | `gotoPrevRecord()` | Vorheriger Datensatz | VOLLSTAENDIG |
| `Befehl41` (>) | `gotoNextRecord()` | Naechster Datensatz | VOLLSTAENDIG |
| `Befehl43` (>|) | `gotoLastRecord()` | Letzter Datensatz | VOLLSTAENDIG |
| `Befehl46` | `btnNeuKunde` | Neuer Kunde | VOLLSTAENDIG |
| `mcobtnDelete` | `btnLoeschen` | Kunde loeschen | VOLLSTAENDIG |
| `btnUmsAuswert` | `btnUmsatzauswertung` | Umsatzauswertung oeffnen | VOLLSTAENDIG |
| `btnAuswertung` | `btnVerrechnungssaetze` | Verrechnungssaetze | VOLLSTAENDIG |
| `btnAktualisieren` | `refreshData()` | Daten aktualisieren | VOLLSTAENDIG |
| `btnSpeichern` | `speichern()` | Datensatz speichern | VOLLSTAENDIG |

### Auftrags-Tab Buttons

| Access-Control | HTML-Element | Funktion | Status |
|----------------|--------------|----------|--------|
| `btnAufRchPDF` | `openRechnungPDF()` | Rechnung als PDF | VOLLSTAENDIG |
| `btnAufRchPosPDF` | `openBerechnungslistePDF()` | Berechnungsliste PDF | VOLLSTAENDIG |
| `btnAufEinsPDF` | `openEinsatzlistePDF()` | Einsatzliste PDF | VOLLSTAENDIG |
| `btnDate` | `activateDatumsfilter()` | Datumsfilter aktivieren | VOLLSTAENDIG |
| `btnAuftrag` | `openNeuerAuftrag()` | Neuer Auftrag | VOLLSTAENDIG |

### Office-Integration

| Access-Control | HTML-Element | Funktion | Status |
|----------------|--------------|----------|--------|
| `btnOutlook` | `openOutlook()` | Outlook E-Mail | VOLLSTAENDIG |
| `btnWord` | `openWord()` | Word Dokument | VOLLSTAENDIG |

### Filter-Buttons

| Access-Control | HTML-Element | Funktion | Status |
|----------------|--------------|----------|--------|
| `btnAlle` | `resetAuswahlfilter()` | Filter zuruecksetzen | VOLLSTAENDIG |

---

## 2. FELDER/CONTROLS - VOLLSTAENDIG IMPLEMENTIERT

### Stammdaten (pgMain Tab)

| Access-Feld | HTML-ID | Typ | Status |
|-------------|---------|-----|--------|
| `kun_firma` | `kun_Firma` | TextBox | VOLLSTAENDIG |
| `kun_bezeichnung` | `kun_bezeichnung` | TextBox | VOLLSTAENDIG |
| `kun_Matchcode` | `kun_Matchcode` | TextBox (Kunden-Kuerzel) | VOLLSTAENDIG |
| `kun_strasse` | `kun_Strasse` | TextBox | VOLLSTAENDIG |
| `kun_plz` | `kun_PLZ` | TextBox | VOLLSTAENDIG |
| `kun_ort` | `kun_Ort` | TextBox | VOLLSTAENDIG |
| `kun_LKZ` | `kun_LKZ` | ComboBox (Land) | VOLLSTAENDIG |
| `kun_telefon` | `kun_telefon` | TextBox | VOLLSTAENDIG |
| `kun_mobil` | `kun_mobil` | TextBox | VOLLSTAENDIG |
| `kun_telefax` | `kun_telefax` | TextBox | VOLLSTAENDIG |
| `kun_email` | `kun_email` | TextBox | VOLLSTAENDIG |
| `kun_URL` | `kun_URL` | TextBox (Homepage) | VOLLSTAENDIG |
| `kun_kreditinstitut` | `kun_kreditinstitut` | TextBox | VOLLSTAENDIG |
| `kun_blz` | `kun_blz` | TextBox | VOLLSTAENDIG |
| `kun_kontonummer` | `kun_kontonummer` | TextBox | VOLLSTAENDIG |
| `kun_iban` | `kun_iban` | TextBox | VOLLSTAENDIG |
| `kun_bic` | `kun_bic` | TextBox | VOLLSTAENDIG |
| `kun_ustidnr` | `kun_ustidnr` | TextBox | VOLLSTAENDIG |
| `kun_Zahlbed` | `kun_Zahlbed` | ComboBox | VOLLSTAENDIG |
| `kun_IstAktiv` | `kun_IstAktiv` | Checkbox | VOLLSTAENDIG |
| `kun_IstSammelRechnung` | `kun_IstSammelRechnung` | Checkbox | VOLLSTAENDIG |
| `kun_ans_manuell` | `kun_ans_manuell` | Checkbox | VOLLSTAENDIG |

### Rechnungsdaten-Tab

| Access-Feld | HTML-ID | Funktion | Status |
|-------------|---------|----------|--------|
| `KD_Ges` | `KD_Ges` | Gesamt-Umsatz | VOLLSTAENDIG |
| `KD_VJ` | `KD_VJ` | Vorjahr-Umsatz | VOLLSTAENDIG |
| `KD_LJ` | `KD_LJ` | Laufendes Jahr | VOLLSTAENDIG |
| `KD_LM` | `KD_LM` | Laufender Monat | VOLLSTAENDIG |

### Bemerkungen-Tab

| Access-Feld | HTML-ID | Typ | Status |
|-------------|---------|-----|--------|
| `kun_BriefKopf` | `kun_BriefKopf` | TextArea | VOLLSTAENDIG |
| `kun_memo` | `kun_memo` | TextArea | VOLLSTAENDIG |
| `Anschreiben` | `kun_Anschreiben` | TextArea | VOLLSTAENDIG |

### Filter/Suche

| Access-Control | HTML-ID | Funktion | Status |
|----------------|---------|----------|--------|
| `NurAktiveKD` | `chkNurAktive` | Nur aktive Kunden | VOLLSTAENDIG |
| `Textschnell` | `searchInput` | Schnellsuche | VOLLSTAENDIG |
| `cboSuchPLZ` | `cboSuchPLZ` | PLZ-Filter | VOLLSTAENDIG |
| `cboSuchOrt` | `cboSuchOrt` | Ort-Filter | VOLLSTAENDIG |
| `lst_KD` | `kundenTable` | Kundenliste | VOLLSTAENDIG |

---

## 3. TABS - VOLLSTAENDIG IMPLEMENTIERT

| Access-Tab | HTML-Tab | Inhalt | Status |
|------------|----------|--------|--------|
| `pgMain` | `tab-stammdaten` | Stammdaten | VOLLSTAENDIG |
| `Auftragsuebersicht` | `tab-auftraguebersicht` | Auftraege | VOLLSTAENDIG |
| `pgPreise` | `tab-preise` | Kundenpreise | VOLLSTAENDIG |
| `pgAttach` | `tab-zusatzdateien` | Zusatzdateien | VOLLSTAENDIG |
| `pgAnsprech` | `tab-ansprechpartner` | Ansprechpartner | VOLLSTAENDIG |
| `pgBemerk` | `tab-bemerkungen` | Bemerkungen | VOLLSTAENDIG |

---

## 4. EVENT-HANDLER - VOLLSTAENDIG IMPLEMENTIERT

| Access-Event | HTML-Implementation | Status |
|--------------|---------------------|--------|
| `Form_Current` | `showRecord()` + `loadKundenStatistik()` | VOLLSTAENDIG |
| `kun_IstAktiv_AfterUpdate` | `onKunIstAktivChange()` | VOLLSTAENDIG |
| `NurAktiveKD_AfterUpdate` | `toggleAlleAnzeigen()` | VOLLSTAENDIG |
| `Textschnell_AfterUpdate` | `searchInput.oninput` | VOLLSTAENDIG |
| `btnAlle_Click` | `resetAuswahlfilter()` | VOLLSTAENDIG |
| `cboSuchOrt_AfterUpdate` | `filterByOrt()` | VOLLSTAENDIG |
| `cboSuchPLZ_AfterUpdate` | `filterByPLZ()` | VOLLSTAENDIG |
| `lst_KD_Click` | `row.addEventListener('click')` | VOLLSTAENDIG |
| `Form_BeforeUpdate` | `setAenderungsdaten()` | VOLLSTAENDIG |

---

## 5. SUBFORMULARE

### VOLLSTAENDIG IMPLEMENTIERT

| Access-Subform | HTML-Entsprechung | Funktion | Status |
|----------------|-------------------|----------|--------|
| `sub_KD_Standardpreise` | Preise-Tab mit CRUD | Kundenpreise verwalten | VOLLSTAENDIG |
| `sub_Ansprechpartner` | Ansprechpartner-Tab | Ansprechpartner CRUD | VOLLSTAENDIG |
| `sub_ZusatzDateien` | Zusatzdateien-Tab | Datei-Upload/Liste | VOLLSTAENDIG |

### FEHLERHAFT IMPLEMENTIERT

| Access-Subform | HTML-Entsprechung | Problem | Status |
|----------------|-------------------|---------|--------|
| `sub_KD_Auftragskopf` | `auftraegeTable` | Nur Basisdaten, keine Bearbeitung | FEHLERHAFT |
| `sub_KD_Rch_Auftragspos` | Fehlt | Rechnungspositionen nicht angezeigt | FEHLERHAFT |

---

## 6. FEHLT - NICHT IMPLEMENTIERT

### Buttons/Funktionen die fehlen

| Access-Control | Funktion | Prioritaet |
|----------------|----------|------------|
| `btn_N_HTMLAnsicht` | HTML-Ansicht wechseln | NIEDRIG |
| `btnRibbonAus` | Ribbon ausblenden | NIEDRIG |
| `btnRibbonEin` | Ribbon einblenden | NIEDRIG |
| `btnDaBaAus` | Datenbankfenster aus | NIEDRIG |
| `btnDaBaEin` | Datenbankfenster ein | NIEDRIG |
| `btnPersonUebernehmen` | Person aus Dropdown uebernehmen | MITTEL |
| `cboKDNrSuche` | Suche nach Kunden-Nr | MITTEL |
| `cbo_Auswahl` | Zusatzanzeige-Auswahl | NIEDRIG |
| `cmdHTMLView` | Alternative HTML-Ansicht | NIEDRIG |

### Felder die fehlen

| Access-Feld | Funktion | Prioritaet |
|-------------|----------|------------|
| `kun_IDF_PersonID` | Haupt-Ansprechpartner Dropdown | MITTEL |
| `kun_AdressArt` | Adressart-Auswahl | MITTEL |
| `kun_land_vorwahl` | Landesvorwahl | NIEDRIG |
| `adr_telefon` | Ansprechpartner-Telefon (Hauptformular) | NIEDRIG |
| `adr_mobil` | Ansprechpartner-Mobil (Hauptformular) | NIEDRIG |
| `adr_eMail` | Ansprechpartner-Email (Hauptformular) | NIEDRIG |
| `kun_geloescht` | Geloescht-Flag Anzeige | NIEDRIG |

### Tabs die fehlen

| Access-Tab | Funktion | Prioritaet |
|------------|----------|------------|
| `pg_Rch_Kopf` | Detaillierte Umsatzstatistik mit Jahresvergleich | MITTEL |
| `pg_Ang` | Angebote-Tab (sub_Rch_Kopf_Ang) | MITTEL |

### Event-Handler die fehlen

| Access-Event | Funktion | Prioritaet |
|--------------|----------|------------|
| `kun_AdressArt_DblClick` | Adressart-Dialog oeffnen | NIEDRIG |
| `IstAuftragsrt_AfterUpdate` | Auftragsart-Filter | NIEDRIG |
| `RegStammKunde_Change` | Tab-Wechsel Handler | NIEDRIG |
| `cboSuchSuchF_AfterUpdate` | Suchfeld-Auswahl | NIEDRIG |
| `Form_Close` | Cleanup beim Schliessen | NIEDRIG |

---

## 7. FEHLERHAFT - IMPLEMENTIERT ABER UNVOLLSTAENDIG

### 7.1 Objekte-Tab

**Problem:** Tab existiert (`tab-objekte`) aber Subformular `sub_KD_Objekte` aus Access fehlt in den Dateien.

**IST:** Einfache Tabelle mit manueller Befuellung
**SOLL:** Vollstaendiges Subformular mit Objektzuordnung

**Empfehlung:**
- Objekte werden via `Bridge.loadData('objekte')` geladen - funktioniert
- Neues Objekt anlegen via `neuesObjekt()` - funktioniert
- Objekt oeffnen via `openObjekt()` - funktioniert
- **Bewertung:** Weitgehend funktional, nur Detail-Ansicht fehlt

### 7.2 Konditionen-Tab

**Problem:** Tab `tab-konditionen` mit Rabatt/Skonto existiert, aber im Access-Original sind diese Felder im pgMain Tab.

**IST:** Separater Tab mit kun_rabatt, kun_skonto, kun_skonto_tage
**SOLL:** Diese Felder sollten eigentlich im Stammdaten-Tab sein

**Empfehlung:**
- Akzeptabel als alternative UX-Loesung
- **Bewertung:** Funktional korrekt, aber UX anders als Access

### 7.3 Angebote-Tab

**Problem:** Tab existiert (`tab-angebote`) aber ohne Inhalt.

**IST:** Nur Placeholder-Text "Angebote werden geladen..."
**SOLL:** Subformular `sub_Rch_Kopf_Ang` mit Angebotsliste

**Empfehlung:**
- Angebotsliste analog zu Auftrags-Tab implementieren
- API-Endpoint `/api/kunden/{id}/angebote` nutzen
- **Bewertung:** FEHLERHAFT - Funktionalitaet fehlt komplett

### 7.4 Umsatzstatistik-Tab (pg_Rch_Kopf)

**Problem:** Der detaillierte Jahresvergleich fehlt.

**IST:** Nur Basis-Statistik (KD_Ges, KD_VJ, KD_LJ, KD_LM) im Auftrags-Tab
**SOLL:** Vollstaendiger pg_Rch_Kopf Tab mit:
- UmsNGes1/2/3, UmsGes1/2/3 (Umsaetze pro Jahr)
- StdGes1/2/3, Std51/52/53 etc. (Stunden-Statistiken)
- PersGes1/2/3, Pers51/52/53 etc. (Personal-Statistiken)
- AufAnz1/2/3 (Auftragsanzahl)

**Empfehlung:**
- Neuen Tab "Statistik" hinzufuegen oder pg_Rch_Kopf integrieren
- **Bewertung:** FEHLERHAFT - Wichtige Auswertungsfunktion fehlt

### 7.5 Rechnungspositionen-Subform

**Problem:** `sub_KD_Rch_Auftragspos` fehlt komplett.

**IST:** Auftraege werden gelistet, aber keine Positionen
**SOLL:** Unter der Auftragsliste die Rechnungspositionen des ausgewaehlten Auftrags

**Empfehlung:**
- Beim Klick auf Auftrag die Positionen laden
- Neues Subform-Element im Auftrags-Tab
- **Bewertung:** FEHLERHAFT - Detailansicht fehlt

### 7.6 Haupt-Ansprechpartner im Header

**Problem:** `kun_IDF_PersonID` (Dropdown fuer Haupt-Ansprechpartner) fehlt im Header-Bereich.

**IST:** Ansprechpartner nur im separaten Tab verwaltbar
**SOLL:** Dropdown im Hauptformular zum schnellen Wechsel

**Empfehlung:**
- Dropdown `kun_IDF_PersonID` im Stammdaten-Tab hinzufuegen
- Automatische Aktualisierung der adr_* Felder
- **Bewertung:** FEHLERHAFT - Wichtige Funktion fuer taegliche Arbeit

### 7.7 Sidebar/Menu fehlt

**Problem:** Das linke Navigationsmenue aus Access (`Menue`) fehlt.

**IST:** Keine Sidebar im HTML
**SOLL:** Navigationsleiste zu anderen Formularen

**Empfehlung:**
- Sidebar-Komponente aus anderen forms3-Formularen uebernehmen
- shell-detector.js ist bereits eingebunden
- **Bewertung:** Okay wenn im Shell-Modus (iframe)

### 7.8 PosGesamtsumme fehlt

**Problem:** Das Feld `PosGesamtsumme` im Auftrags-Tab fehlt.

**IST:** Keine Summenanzeige fuer Positionen
**SOLL:** Gesamtsumme der angezeigten Positionen

**Empfehlung:**
- Summenzeile unter der Auftragstabelle hinzufuegen
- **Bewertung:** FEHLERHAFT - Wichtige Information fehlt

---

## 8. EMPFEHLUNGEN

### Hohe Prioritaet (funktionskritisch)

1. **Angebote-Tab implementieren** - Placeholder ersetzen durch echte Funktion
2. **Rechnungspositionen-Subform** - Detail-Ansicht bei Auftragsauswahl
3. **Haupt-Ansprechpartner-Dropdown** - kun_IDF_PersonID im Header

### Mittlere Prioritaet (verbessert UX)

4. **pg_Rch_Kopf Statistik** - Detaillierte Jahresvergleiche
5. **PosGesamtsumme** - Summenzeile im Auftrags-Tab
6. **cboKDNrSuche** - Direkte Suche nach Kunden-Nummer
7. **btnPersonUebernehmen** - Person aus Pool uebernehmen

### Niedrige Prioritaet (Access-spezifisch)

8. Ribbon/Datenbankfenster-Buttons (nicht relevant fuer HTML)
9. kun_AdressArt mit DblClick-Dialog
10. IstAuftragsrt Filter

---

## 9. TECHNISCHE HINWEISE

### API-Endpoints benoetigt

Die folgenden API-Endpoints werden im Code referenziert und muessen im Backend existieren:

- `GET /api/kunden` - Liste
- `GET /api/kunden/{id}` - Einzelkunde
- `POST /api/kunden` - Neu anlegen
- `PUT /api/kunden/{id}` - Aktualisieren
- `DELETE /api/kunden/{id}` - Loeschen
- `GET /api/kunden/{id}/ansprechpartner` - Ansprechpartner
- `POST/PUT/DELETE /api/kunden/{id}/ansprechpartner/{id}` - CRUD
- `GET /api/kunden/{id}/preise` - Kundenpreise
- `POST /api/kunden/{id}/preise/standard` - Standardpreise anlegen
- `GET /api/preisarten` - Preisarten-Katalog
- `GET /api/attachments?kd_id={id}` - Zusatzdateien

### WebView2-Integration

Die Datei `frm_KD_Kundenstamm.webview2.js` ist vorhanden und bietet:
- Datenempfang von Access via WebView2Bridge
- Formular-Daten sammeln via collectKundenData()
- Button-Hooks fuer Save, Close, Delete

### Keyboard-Shortcuts implementiert

- Ctrl+S: Speichern
- Ctrl+N: Neuer Kunde
- Ctrl+F: Suche fokussieren
- F5: Aktualisieren
- Pfeiltasten: Navigation in Kundenliste

---

## 10. FAZIT

Das HTML-Formular `frm_KD_Kundenstamm.html` ist zu ca. **70%** funktional im Vergleich zum Access-Original. Die Kernfunktionen (CRUD, Navigation, Stammdaten, Preise, Ansprechpartner, Dateien) sind implementiert.

**Hauptdefizite:**
1. Angebote-Tab ist leer
2. Detaillierte Umsatzstatistik fehlt
3. Rechnungspositionen-Subform fehlt
4. Haupt-Ansprechpartner-Dropdown fehlt

**Staerken:**
- Moderne, responsive Oberflaeche
- Gute API-Integration mit Fallbacks
- Keyboard-Navigation
- Dirty-State-Tracking
- Toast-Benachrichtigungen

Die Implementierung ist fuer den produktiven Einsatz geeignet, sofern die unter "Hohe Prioritaet" genannten Punkte umgesetzt werden.

---

*Bericht erstellt am: 2026-01-05*
*Geprueft durch: Claude Code Audit*
