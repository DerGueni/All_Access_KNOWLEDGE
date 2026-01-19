# REPORT: Layout-Zonen / UI-Bereiche

**Erstellt:** 2026-01-08

---

## Uebersicht

Dieses Dokument beschreibt die logischen UI-Bereiche in den Hauptformularen.

---

## 1. frm_MA_Mitarbeiterstamm.html

### Haupt-Bereiche:

| Bereich | CSS-Container | Beschreibung |
|---------|---------------|--------------|
| **Title-Bar** | `.title-bar` | Fenster-Steuerung (Min/Max/Close) |
| **Header-Row** | `.header-row` | Logo, Titel, Aktions-Buttons, Navigation |
| **Employee-Info** | `.employee-info` | Anzeige Nachname/Vorname |
| **Tab-Container** | `.tab-container` | Tabs und Tab-Content |
| **Right-Panel** | `.right-panel` | Mitarbeiterliste (300px breit) |
| **Status-Bar** | `.status-bar` | Datensatz-Info, Timestamps |

### Tab: Stammdaten (3 Spalten + Foto)

| Spalte | Container | Felder |
|--------|-----------|--------|
| **Spalte 1** | `.form-column` | PersNr, LexNr, Aktiv, Name, Adresse, Kontakt, Geschlecht, Geburtsdaten |
| **Spalte 2** | `.form-column` | Eintrittsdatum, Austrittsdatum, Anstellung, Dienstausweis, DFB-Daten, Bewacher-ID |
| **Spalte 3** | `.form-column` | Bankdaten, Lohn, Steuer, Urlaub, Checkboxen, Bemerkungen |
| **Foto-Bereich** | `.photo-section` | Mitarbeiterfoto (position: absolute, right: 10px) |

### Weitere Tabs:
- Einsatzuebersicht (iframe)
- Dienstplan (iframe)
- Nicht Verfuegbar (table)
- Bestand Dienstkleidung
- [hidden] Zeitkonto, Jahresuebersicht, Stundenuebersicht, Vordrucke, Briefkopf, Karte, SubRechnungen, Ueberhangstunden, Qualifikationen, Dokumente, QuickInfo

---

## 2. frm_KD_Kundenstamm.html

### Haupt-Bereiche:

| Bereich | CSS-Container | Beschreibung |
|---------|---------------|--------------|
| **Title-Bar** | `.title-bar` | Fenster-Steuerung |
| **Header-Row** | `.header-row` | Logo, Titel, Aktions-Buttons, KD-Nr Suche |
| **Customer-Info** | `.customer-info` | Firmenname, Adresse |
| **Tab-Container** | `.tab-container` | Tabs und Tab-Content |
| **Right-Panel** | `.right-panel` | Kundenliste (320px breit) |
| **Status-Bar** | `.status-bar` | Datensatz-Info, Timestamps |

### Tab: Stammdaten (2 Spalten)

| Spalte | Container | Felder |
|--------|-----------|--------|
| **Spalte 1 (Adresse)** | `.form-column` | Firma, Bezeichnung, Kuerzel, Strasse, PLZ, Ort, Land, Telefon, Mobil, Fax, E-Mail, Homepage, Haupt-Ansprechpartner |
| **Spalte 2 (Bank/Zahl)** | `.form-column` | Kreditinstitut, BLZ, Kontonummer, IBAN, BIC, UStIDNr, Zahlungsbedingungen |

### Weitere Tabs:
- Objekte (Button-Row + Tabelle)
- Konditionen (Rabatt, Skonto)
- [hidden] Auftraguebersicht, Ansprechpartner, Angebote, Statistik
- Zusatzdateien (Upload + Tabelle)
- Bemerkungen (Textareas)
- Preise (Tabelle + Detail-Formular)

---

## 3. frm_va_Auftragstamm.html

### Haupt-Bereiche:

| Bereich | CSS-Container | Beschreibung |
|---------|---------------|--------------|
| **Title-Bar** | `.title-bar` | Fenster-Steuerung |
| **Header-Row** | `.header-row.combined-buttons` | Logo, Titel, Aktions-Buttons (95px Hoehe) |
| **Form-Section** | `.form-section` | Stammdaten (Datum, Nr, Auftrag, Ort, Objekt, PKW, Treffpunkt) |
| **Tab-Container** | `.tab-container` | Tabs und Tab-Content |
| **Right-Panel** | `.right-panel` | Auftragsliste (500px breit) |
| **Status-Bar** | `.status-bar` | Datensatz-Info, Timestamps |

### Form-Section (3 Spalten)

| Spalte | Container | Felder |
|--------|-----------|--------|
| **Left** | `.form-column.left` | Datum von/bis, Nr, Auftrag, Ort, Objekt |
| **Middle** | `.form-column.middle` | PKW Anzahl, Fahrtkosten, Datum-Navigation |
| **Right** | `.form-column.right` | Treffzeit, Treffpunkt, Dienstkleidung, Ansprechpartner, Auftraggeber |

### Tab: Einsatzliste

| Bereich | Container | Inhalt |
|---------|-----------|--------|
| **Schichten** | `.subform-left` | Grid mit Einsatztagen |
| **MA-Zuordnungen** | `.subform-right` | Grid mit zugeordneten Mitarbeitern |

### Weitere Tabs:
- Antworten ausstehend (Status-Grid)
- Rechnung (Buttons, Positionen-Grid, Berechnungsliste)
- [hidden] Zusatzdateien, Bemerkungen, Eventdaten

---

## 4. frm_OB_Objekt.html

### Haupt-Bereiche:

| Bereich | CSS-Container | Beschreibung |
|---------|---------------|--------------|
| **Title-Bar** | `.title-bar` | Fenster-Steuerung |
| **Header-Row** | `.header-row` | Logo, Titel, Header-Links |
| **Button-Row** | `.button-row` | Navigation, Aktions-Buttons |
| **Main-Content** | `.main-content` | Split-Layout (Left + Right Panel) |
| **Status-Bar** | `.status-bar` | Status, Timestamps |

### Left-Panel

| Bereich | Container | Inhalt |
|---------|-----------|--------|
| **Form-Section** | `.form-section` | 2 Spalten mit Stammdaten |
| **Tab-Container** | `.tab-container` | Positionen, Zusatzdateien, Bemerkungen, Auftraege |

### Form-Section (2 Spalten)

| Spalte | Container | Felder |
|--------|-----------|--------|
| **Spalte 1** | `.form-column` | Objekt-ID, Objekt, Strasse, PLZ/Ort, Geo-Koordinaten |
| **Spalte 2** | `.form-column` | Treffpunkt/Zeit, Anfahrt, Dienstkleidung, Ansprechpartner, Telefon, Veranstalter |

### Right-Panel

| Bereich | Container | Inhalt |
|---------|-----------|--------|
| **Objektliste** | `.right-panel` | Suche + Liste (320px breit) |

---

## Gemeinsame Container-Klassen

| Klasse | Verwendung |
|--------|------------|
| `.window-frame` | Aeusserer Container |
| `.title-bar` | Titelleiste mit Fenster-Buttons |
| `.main-container` | Hauptbereich |
| `.content-area` | Inhaltsbereich |
| `.header-row` | Header mit Buttons |
| `.tab-container` | Tab-Navigation und -Inhalt |
| `.tab-header` | Tab-Buttons |
| `.tab-content` | Tab-Inhalt |
| `.right-panel` | Rechte Seitenliste |
| `.status-bar` | Statusleiste unten |
| `.form-columns` | Flex-Container fuer Spalten |
| `.form-column` | Einzelne Spalte |
| `.form-row` | Zeile mit Label+Feld |

---

*Erstellt von Claude Code*
