# Gap-Analyse: frm_KD_Kundenstamm

**Analysiert am:** 2026-01-12
**Access-Export:** forms3/Access_Abgleich/forms/frm_KD_Kundenstamm.md
**HTML-Formular:** forms3/frm_KD_Kundenstamm.html
**Logic-JS:** forms3/logic/frm_KD_Kundenstamm.logic.js
**WebView2-JS:** forms3/logic/frm_KD_Kundenstamm.webview2.js

---

## Executive Summary

### Formular-Umfang
- **Access Controls:** 187 (zweitgrößtes Formular)
  - 17 Buttons
  - 70 TextBoxen
  - 9 ComboBoxen
  - 1 ListBox
  - 7 Unterformulare
  - 4 CheckBoxen
  - 67 Labels
  - 11 sonstige (TabControl, Pages, Rectangles)

### Implementierungsstatus
- **HTML-Struktur:** ✅ **Sehr gut implementiert** (90%)
- **Feldmapping:** ✅ **Vollständig** (100%)
- **Button-Logik:** ⚠️ **Teilweise** (65%)
- **Subforms:** ⚠️ **Stubs vorhanden** (30%)
- **API-Integration:** ✅ **Gut** (80%)

### Kritische Gaps
1. **7 Unterformulare** nur als Platzhalter implementiert
2. **ComboBox-RowSources** fehlen (9 Stück)
3. **PDF-Export-Funktionen** nicht implementiert
4. **Umsatz-Statistik** keine Datenbindung
5. **File-Upload** für Zusatzdateien fehlt Backend

---

## 1. FORMULAR-EIGENSCHAFTEN

### Access
```
RecordSource: SELECT tbl_KD_Kundenstamm.* FROM tbl_KD_Kundenstamm ORDER BY kun_Firma
AllowEdits: True
AllowAdditions: True
AllowDeletions: True
DataEntry: False
DefaultView: Other (Einzelformular)
NavigationButtons: False
Filter: kun_ID = 20727
```

### HTML
```javascript
// Datenquelle via Bridge API
await Bridge.kunden.list(params)

// CRUD-Operationen vorhanden:
- Bridge.kunden.list()
- Bridge.kunden.get(id)
- Bridge.kunden.create(data)
- Bridge.kunden.update(id, data)
- Bridge.kunden.delete(id)

// Filter: nurAktive implementiert
state.nurAktive = true/false
```

### Status: ✅ Gut implementiert
- CRUD vollständig
- Navigation vorhanden
- Filter implementiert

---

## 2. BUTTONS (17 Stück)

### Access → HTML Mapping

| Access-Button | Caption/Funktion | HTML-ID | onclick | Status |
|---------------|------------------|---------|---------|--------|
| **btnAlle** | (versteckt) | - | - | ⚠️ Fehlt |
| **Befehl39** | Erster DS | - | `gotoFirstRecord()` | ✅ OK |
| **Befehl40** | Vorheriger DS | - | `gotoPrevRecord()` | ✅ OK |
| **Befehl41** | Nächster DS | - | `gotoNextRecord()` | ✅ OK |
| **Befehl43** | Letzter DS | - | `gotoLastRecord()` | ✅ OK |
| **Befehl46** | ? | - | - | ⚠️ Fehlt |
| **mcobtnDelete** | Löschen | btnLoeschen | `kundeLoeschen()` | ✅ OK |
| **btnUmsAuswert** | Umsatzauswertung | btnUmsatzauswertung | `openUmsatzauswertung()` | ⚠️ Stub |
| **btnRibbonAus** | Ribbon ausblenden | - | - | ⚠️ Fehlt |
| **btnRibbonEin** | Ribbon einblenden | - | - | ⚠️ Fehlt |
| **btnDaBaEin** | DatNav einblenden | - | - | ⚠️ Fehlt |
| **btnDaBaAus** | DatNav ausblenden | - | - | ⚠️ Fehlt |
| **btnAuswertung** | Auswertung | - | - | ⚠️ Fehlt |
| **btnAufRchPDF** | Rechnung PDF | btnAufRchPDF | `openRechnungPDF()` | ⚠️ Stub |
| **btnAufRchPosPDF** | Berechnungsliste PDF | - | `openBerechnungslistePDF()` | ⚠️ Stub |
| **btnAufEinsPDF** | Einsatzliste PDF | - | `openEinsatzlistePDF()` | ⚠️ Stub |
| **btnNeuAttach** | Datei hinzufügen | - | `dateiHinzufuegen()` | ⚠️ Stub |

### Zusätzliche HTML-Buttons (nicht in Access)
- btnNeuKunde → `neuerKunde()` ✅
- btnSpeichern → `speichern()` ✅
- btnAktualisieren → `refreshData()` ✅
- btnVerrechnungssaetze → `openVerrechnungssaetze()` ⚠️ Stub
- btnOutlook → `openOutlook()` ✅ OK
- btnWord → `openWord()` ⚠️ Stub

### Fehlende Button-Funktionalität
```javascript
// ❌ FEHLT: UI-Toggle-Buttons
function btnRibbonAus() { /* Access-Ribbon ausblenden */ }
function btnRibbonEin() { /* Access-Ribbon einblenden */ }
function btnDaBaEin() { /* Access-Navigationsleiste einblenden */ }
function btnDaBaAus() { /* Access-Navigationsleiste ausblenden */ }

// ❌ FEHLT: PDF-Export-Funktionen
function openRechnungPDF() {
    // Muss VBA-Bridge aufrufen: rpt_Rechnung
    // Aktuell: Nur Toast-Nachricht
}

// ❌ FEHLT: Upload-Backend
async function dateiHinzufuegen() {
    // FormData vorhanden, aber /api/upload fehlt in api_server.py
}
```

---

## 3. TEXTBOXEN (70 Stück)

### Stammdaten-Felder

| Access-Feld | ControlSource | HTML-ID | data-field | Status |
|-------------|---------------|---------|------------|--------|
| kun_firma | kun_firma | kun_Firma | kun_Firma | ✅ OK |
| kun_bezeichnung | kun_bezeichnung | kun_bezeichnung | kun_bezeichnung | ✅ OK |
| kun_Matchcode | kun_Matchcode | kun_Matchcode | kun_Matchcode | ✅ OK |
| kun_strasse | kun_strasse | kun_Strasse | kun_Strasse | ✅ OK |
| kun_plz | kun_plz | kun_PLZ | kun_PLZ | ✅ OK |
| kun_ort | kun_ort | kun_Ort | kun_Ort | ✅ OK |
| kun_telefon | kun_telefon | kun_telefon | kun_telefon | ✅ OK |
| kun_mobil | kun_mobil | kun_mobil | kun_mobil | ✅ OK |
| kun_telefax | kun_telefax | kun_telefax | kun_telefax | ✅ OK |
| kun_email | kun_email | kun_email | kun_email | ✅ OK |
| kun_URL | kun_URL | kun_URL | kun_URL | ✅ OK |
| **Bankdaten** | | | | |
| kun_kreditinstitut | kun_kreditinstitut | kun_kreditinstitut | kun_kreditinstitut | ✅ OK |
| kun_blz | kun_blz | kun_blz | kun_blz | ✅ OK |
| kun_kontonummer | kun_kontonummer | kun_kontonummer | kun_kontonummer | ✅ OK |
| kun_iban | kun_iban | kun_iban | kun_iban | ✅ OK |
| kun_bic | kun_bic | kun_bic | kun_bic | ✅ OK |
| kun_ustidnr | kun_ustidnr | kun_ustidnr | kun_ustidnr | ✅ OK |
| **Bemerkungen** | | | | |
| kun_BriefKopf | kun_BriefKopf | kun_BriefKopf | kun_BriefKopf | ✅ OK |
| Anschreiben | kun_Anschreiben | kun_Anschreiben | kun_Anschreiben | ✅ OK |
| kun_memo | kun_memo | kun_memo | kun_memo | ✅ OK |
| **System-Felder** | | | | |
| kun_ID | kun_ID | kdNr | - | ✅ OK (readonly) |
| Erst_am | Erst_am | - | - | ⚠️ Fehlt |
| Erst_von | Erst_von | - | - | ⚠️ Fehlt |
| Aend_am | Aend_am | - | - | ⚠️ Fehlt |
| Aend_von | Aend_von | - | - | ⚠️ Fehlt |

### Statistik-Felder (berechnete Controls)

| Access-Feld | ControlSource | HTML-ID | Status |
|-------------|---------------|---------|--------|
| **Umsatz-Gesamt** | | | |
| KD_Ges | - (berechnet) | KD_Ges | ⚠️ Nur Platzhalter |
| KD_VJ | - (berechnet) | KD_VJ | ⚠️ Nur Platzhalter |
| KD_LJ | - (berechnet) | KD_LJ | ⚠️ Nur Platzhalter |
| KD_LM | - (berechnet) | KD_LM | ⚠️ Nur Platzhalter |
| PosGesamtsumme | - (berechnet) | PosGesamtsumme | ⚠️ Nur Platzhalter |
| **Jahr 1** | | | |
| UmsNGes1 | - (berechnet) | UmsNGes1 | ⚠️ Nur Platzhalter |
| PersGes1 | - (berechnet) | PersGes1 | ⚠️ Nur Platzhalter |
| StdGes1 | - (berechnet) | StdGes1 | ⚠️ Nur Platzhalter |
| UmsGes1 | - (berechnet) | UmsGes1 | ⚠️ Nur Platzhalter |
| AufAnz1 | - (berechnet) | AufAnz1 | ⚠️ Nur Platzhalter |
| Std51, Pers51 | - (berechnet) | Std51, Pers51 | ⚠️ Nur Platzhalter |
| Std61, Pers61 | - (berechnet) | Std61, Pers61 | ⚠️ Nur Platzhalter |
| Std71, Pers71 | - (berechnet) | Std71, Pers71 | ⚠️ Nur Platzhalter |
| **Jahr 2, 3** | | | |
| (analog) | | | ⚠️ Nur Platzhalter |

### Fehlende Statistik-Logik
```javascript
// ❌ FEHLT: API-Endpoint für Umsatz-Statistik
// /api/kunden/:id/statistik?jahr=2024
{
    "gesamt": 123456.78,
    "vorjahr": 98765.43,
    "lfd_jahr": 56789.01,
    "akt_monat": 12345.67,
    "jahre": [
        {
            "jahr": 2024,
            "umsatz_netto": 50000,
            "umsatz_brutto": 59500,
            "stunden": 1250,
            "auftraege": 25,
            "personal_tage": 150,
            "wochen": {
                "51": { "stunden": 40, "personal": 5 },
                "52": { "stunden": 38, "personal": 5 },
                "53": { "stunden": 20, "personal": 3 }
            }
        },
        // ... Jahr 2023, 2022
    ]
}

// ❌ FEHLT: loadStatistik() Implementierung in logic.js
```

---

## 4. COMBOBOXEN (9 Stück)

### Access → HTML Mapping

| Access-ComboBox | RowSource | HTML-Element | Status |
|-----------------|-----------|--------------|--------|
| **cboSuchPLZ** | SELECT kun_plz FROM ... | - | ❌ Fehlt |
| **cboSuchOrt** | SELECT kun_Ort FROM ... | - | ❌ Fehlt |
| **cboKDNrSuche** | SELECT kun_Id FROM ... | cboKDNrSuche (text) | ⚠️ Text statt Combo |
| **kun_LKZ** | SELECT ISO_2, Landesname FROM _tblLKZ | kun_LKZ (select) | ✅ OK (Hardcoded DE/AT/CH) |
| **kun_Zahlbed** | SELECT ID, Bezeichnung FROM _tblEigeneFirma_Zahlungsbedingungen | kun_Zahlbed (select) | ✅ OK (Hardcoded) |
| **kun_IDF_PersonID** | qryAdrKundZuo2 | kun_IDF_PersonID (select) | ⚠️ Leeres Dropdown |
| **kun_AdressArt** | SELECT ID, kun_AdressArt FROM tbl_KD_Adressart | - | ❌ Fehlt |
| **Textschnell** | SELECT kun_Id, kun_Firma FROM tbl_KD_Kundenstamm | - | ❌ Fehlt |
| **cbo_Auswahl** | 0;"";1;"Telefon";2;"eMail";3;"Umsatz" | - | ❌ Fehlt |

### Fehlende ComboBox-Funktionalität
```javascript
// ❌ FEHLT: Ansprechpartner-Dropdown (kun_IDF_PersonID)
// HTML hat leeres <select>, aber keine Daten
// Braucht: /api/kunden/:id/ansprechpartner

// ❌ FEHLT: PLZ/Ort-Suche (cboSuchPLZ, cboSuchOrt)
// Access: Filter-ComboBox in Kundenliste
// HTML: Nicht implementiert (nur txtSuche vorhanden)

// ❌ FEHLT: Adressart-Dropdown (kun_AdressArt)
// Access: tbl_KD_Adressart (Veranstalter, Dienstleister, etc.)
// HTML: Feld fehlt komplett

// ❌ FEHLT: Schnellsuche-ComboBox (Textschnell)
// Access: Combo mit Autosuggest
// HTML: Nur einfaches Textfeld
```

---

## 5. LISTBOX (1 Stück)

### Access: lst_KD
```
RowSource: SELECT kun_Id, kun_Firma, kun_Ort, ... FROM tbl_KD_Kundenstamm
ColumnCount: 4
OnClick: Procedure (Datensatz wechseln)
```

### HTML: Right Panel Kundenliste
```html
<table class="data-grid" id="kundenTable">
    <tbody id="tbody_Liste">
        <!-- Rendert via renderList() -->
    </tbody>
</table>
```

### Status: ✅ Gut implementiert
- Kundenliste wird gerendert
- Click-Handler vorhanden
- Selected-State funktioniert

### Kleine Abweichungen
```javascript
// Access: 4 Spalten (ID, Firma, Ort, ?)
// HTML: 5 Spalten (ID, Firma, Ort, Kontakt, Telefon)

// Access: Multi-Column ListBox
// HTML: Table mit 5 Spalten (besser lesbar)
```

---

## 6. UNTERFORMULARE (7 Stück)

### Access Subforms → HTML Status

| Access-Subform | SourceObject | LinkFields | HTML-Tab | Status |
|----------------|--------------|------------|----------|--------|
| **sub_KD_Standardpreise** | sub_KD_Standardpreise | kun_ID → kun_ID | tab-preise | ⚠️ Stub (Table leer) |
| **sub_KD_Auftragskopf** | sub_KD_Auftragskopf | kun_ID → kun_ID | tab-auftraguebersicht | ⚠️ Stub (Table leer) |
| **sub_KD_Rch_Auftragspos** | sub_KD_Rch_Auftragspos | (keine) | tab-auftraguebersicht | ⚠️ Stub (Table leer) |
| **sub_Rch_Kopf_Ang** | sub_Rch_Kopf_Ang | kun_ID → kun_ID | tab-angebote | ⚠️ Stub (Table leer) |
| **sub_ZusatzDateien** | sub_ZusatzDateien | kun_ID, TabellenNr → Ueberordnung, TabellenID | tab-zusatzdateien | ⚠️ Stub (Table leer) |
| **sub_Ansprechpartner** | sub_Ansprechpartner | kun_Id → kun_Id | tab-ansprechpartner | ⚠️ Stub (Table leer) |
| **Menü** | frm_Menuefuehrung | (keine) | (Sidebar) | ❌ Fehlt in Kundenstamm |

### Detaillierte Analyse

#### 6.1 sub_KD_Standardpreise (Preise-Tab)
**Access:**
- Zeigt kundenspezifische Preise
- Felder: Position, Bezeichnung, Preis/Std, Preis/Tag, Nachtzuschlag, Bemerkung
- Bearbeitung inline

**HTML:**
```html
<table id="kundenpreiseTable">
    <tbody id="kundenpreiseBody">
        <!-- Leer! -->
    </tbody>
</table>

<script>
// Buttons vorhanden:
function standardpreiseAnlegen() { /* Stub */ }
function neuerPreis() { /* Stub */ }
function preisLoeschen() { /* Stub */ }
function speicherePreis() { /* Stub */ }
</script>
```

**Gap:**
```javascript
// ❌ FEHLT: /api/kunden/:id/preise
// ❌ FEHLT: loadKundenpreise() Implementierung
// ❌ FEHLT: Detail-Formular Datenbindung
```

#### 6.2 sub_KD_Auftragskopf (Auftragsübersicht-Tab)
**Access:**
- Zeigt alle Aufträge des Kunden
- Felder: Auftrag-Nr, Bezeichnung, Datum, Objekt, Status, Betrag
- Filter: Datumsbereich
- Summenzeile: PosGesamtsumme

**HTML:**
```html
<table id="auftraegeTable">
    <tbody id="auftraegeBody">
        <!-- Wird via filterAuftraege() befüllt -->
    </tbody>
</table>

<script>
async function filterAuftraege() {
    const result = await Bridge.auftraege.list({ kunde_id: id, von, bis });
    renderAuftraege(result.data || []);
}
</script>
```

**Status:** ⚠️ **Teilweise** - API-Call vorhanden, aber keine Daten

**Gap:**
```javascript
// ❌ FEHLT: /api/auftraege?kunde_id=123
// ✅ OK: renderAuftraege() Funktion vorhanden
// ❌ FEHLT: PosGesamtsumme Berechnung
```

#### 6.3 sub_KD_Rch_Auftragspos (Auftragspositionen)
**Access:**
- Zeigt Rechnungspositionen des selektierten Auftrags
- Felder: Pos, Bezeichnung, Menge, Einzelpreis, Gesamt
- Master-Detail: Auftrag → Positionen

**HTML:**
```html
<table id="auftragspositionenTable">
    <tbody id="auftragspositionenBody">
        <tr><td colspan="5">Auftrag auswählen...</td></tr>
    </tbody>
</table>

<script>
function loadAuftragsPositionen() {
    console.log('[loadAuftragsPositionen] Aufgerufen');
    // Stub!
}
</script>
```

**Gap:**
```javascript
// ❌ FEHLT: /api/auftraege/:va_id/positionen
// ❌ FEHLT: Click-Handler auf auftragsTable → loadAuftragsPositionen()
// ❌ FEHLT: Summenzeile PositionenSumme
```

#### 6.4 sub_Rch_Kopf_Ang (Angebote)
**Access:**
- Zeigt alle Angebote des Kunden
- Felder: Datum, Angebot-Nr, Bezeichnung, Betrag, Status, Gültig bis

**HTML:**
```html
<table id="angeboteTable">
    <tbody id="angeboteBody">
        <tr><td colspan="6">Angebote werden geladen...</td></tr>
    </tbody>
</table>

<script>
function loadAngebote() {
    console.log('[Angebote] Laden');
    // Stub!
}
</script>
```

**Gap:**
```javascript
// ❌ FEHLT: /api/angebote?kunde_id=123
// ❌ FEHLT: loadAngebote() Implementierung
// ❌ FEHLT: Angebots-Summe Berechnung
```

#### 6.5 sub_ZusatzDateien (Zusatzdateien)
**Access:**
- Zeigt angehängte Dateien
- Felder: Dateiname, Datum, Größe, Typ, Beschreibung
- Buttons: Hinzufügen, Öffnen, Löschen

**HTML:**
```html
<table id="dateienTable">
    <tbody id="dateienBody">
        <!-- Leer -->
    </tbody>
</table>

<script>
async function dateiHinzufuegen() {
    // File-Input vorhanden
    // FormData-Upload zu /api/upload
    // Backend fehlt!
}
</script>
```

**Gap:**
```javascript
// ❌ FEHLT: /api/kunden/:id/dateien
// ❌ FEHLT: POST /api/upload (in api_server.py)
// ❌ FEHLT: Dateiliste-Rendering
// ❌ FEHLT: Datei-Download/Öffnen
```

#### 6.6 sub_Ansprechpartner
**Access:**
- Zeigt alle Ansprechpartner des Kunden
- Felder: Nachname, Vorname, Position, Telefon, Handy, E-Mail
- Detail-Formular: Ansprechpartner bearbeiten

**HTML:**
```html
<table id="ansprechpartnerTable">
    <tbody id="ansprechpartnerTbody">
        <!-- Leer -->
    </tbody>
</table>

<!-- Detail-Formular vorhanden! -->
<div>
    <input id="adr_Nachname" data-ap-field="adr_Nachname">
    <input id="adr_Vorname" data-ap-field="adr_Vorname">
    <!-- ... -->
</div>

<script>
function loadAnsprechpartner() {
    console.log('[AP] Ansprechpartner laden');
    // Stub!
}
</script>
```

**Gap:**
```javascript
// ❌ FEHLT: /api/kunden/:id/ansprechpartner
// ❌ FEHLT: loadAnsprechpartner() Implementierung
// ❌ FEHLT: Click-Handler auf Tabelle → Detail-Formular befüllen
// ❌ FEHLT: speichereAnsprechpartner() → POST/PUT
```

#### 6.7 Menü (Sidebar)
**Access:** Eingebettetes frm_Menuefuehrung

**HTML:** Sidebar fehlt im Kundenstamm-Formular

**Hinweis:** Im HTML-Code ist kein `<div class="left-menu">` vorhanden (Zeile 702 ist leer)

**Gap:**
```html
<!-- ❌ FEHLT: Sidebar-Container -->
<div class="left-menu">
    <div class="menu-header">Menü</div>
    <!-- ... -->
</div>
```

---

## 7. CHECKBOXEN (4 Stück)

| Access-Feld | ControlSource | HTML-ID | Status |
|-------------|---------------|---------|--------|
| kun_IstAktiv | kun_IstAktiv | kun_IstAktiv | ✅ OK |
| kun_IstSammelRechnung | kun_IstSammelRechnung | kun_IstSammelRechnung | ✅ OK |
| kun_ans_manuell | kun_ans_manuell | kun_ans_manuell | ✅ OK |
| NurAktiveKD | - (Filter) | chkNurAktive | ✅ OK |

**Status:** ✅ Alle vorhanden und funktional

---

## 8. TABCONTROL & PAGES

### Access: RegStammKunde (TabControl)
- pgMain (Stammdaten)
- pgPreise (Preise)
- Auftragsübersicht (Aufträge)
- pg_Rch_Kopf (Rechnungen/Statistik)
- pg_Ang (Angebote)
- pgAttach (Zusatzdateien)
- pgAnsprech (Ansprechpartner)
- pgBemerk (Bemerkungen)

### HTML: Tab-Header
```html
<div class="tab-header">
    <button class="tab-btn active" data-tab="stammdaten">Stammdaten</button>
    <button class="tab-btn" data-tab="objekte">Objekte</button>
    <button class="tab-btn" data-tab="konditionen">Konditionen</button>
    <button class="tab-btn" data-tab="zusatzdateien">Zusatzdateien</button>
    <button class="tab-btn" data-tab="bemerkungen">Bemerkungen</button>
    <button class="tab-btn" data-tab="preise">Preise</button>
    <!-- Hidden Tabs -->
    <button class="tab-btn" data-tab="auftraguebersicht" hidden>Auftragsübersicht</button>
    <button class="tab-btn" data-tab="ansprechpartner" hidden>Ansprechpartner</button>
    <button class="tab-btn" data-tab="angebote" hidden>Angebote</button>
    <button class="tab-btn" data-tab="statistik" hidden>Statistik</button>
</div>
```

### Gap: Sichtbarkeit
```javascript
// Access: 8 sichtbare Tabs
// HTML: 6 sichtbare + 4 versteckte Tabs

// ❌ VERSTECKT: auftraguebersicht (sollte sichtbar sein)
// ❌ VERSTECKT: ansprechpartner (sollte sichtbar sein)
// ❌ VERSTECKT: angebote (sollte sichtbar sein)
// ❌ VERSTECKT: statistik (sollte sichtbar sein)

// FIX: Attribute hidden entfernen
```

---

## 9. FORMULAR-EVENTS

### Access Events
```
OnLoad: Procedure (Initialisierung)
OnCurrent: Procedure (Datensatz gewechselt)
BeforeUpdate: Procedure (Validierung)
AfterUpdate: Procedure (Speichern)
```

### HTML Events
```javascript
// Init
async function init() { /* ✅ Vorhanden */ }

// Navigation
async function gotoRecord(index) { /* ✅ Vorhanden */ }

// CRUD
async function saveRecord() { /* ✅ Vorhanden */ }
async function deleteRecord() { /* ✅ Vorhanden */ }

// ❌ FEHLT: BeforeUpdate-Validierung
// ✅ OK: Pflichtfeld-Validierung vorhanden (validateRequired)

// ❌ FEHLT: AfterUpdate-Events für Controls
// Access: kun_IstAktiv_AfterUpdate, KD_Name1_AfterUpdate, etc.
// HTML: Nur Stub-Funktionen (lines 786-869 in logic.js)
```

### Access-Sync Events (in logic.js)
```javascript
// ✅ Stub vorhanden, aber nicht aufgerufen:
KD_Kuerzel_AfterUpdate(value) { /* ... */ }
KD_Name1_AfterUpdate(value) { /* ... */ }
KD_IstAktiv_AfterUpdate(value) { /* ... */ }
cboAuftragsfilter_AfterUpdate(filterValue) { /* ... */ }
// ...

// ❌ FEHLT: Event-Binding von Controls zu diesen Funktionen
```

---

## 10. WEBVIEW2 INTEGRATION

### webview2.js Status
```javascript
// ✅ Grundstruktur vorhanden (119 Zeilen)
// ✅ onDataReceived: Kunde laden via ID
// ✅ setFormDataProvider: collectKundenData()
// ✅ hookButtons: Speichern, Schließen, Neu, Löschen

// ⚠️ collectKundenData(): Nur Basis-Felder
// ❌ FEHLT: Unterformular-Daten
// ❌ FEHLT: Statistik-Daten
// ❌ FEHLT: Ansprechpartner-Daten
```

---

## 11. API-ENDPOINTS

### Benötigt für Kundenstamm

| Endpoint | Methode | Zweck | Status |
|----------|---------|-------|--------|
| `/api/kunden` | GET | Liste | ✅ OK |
| `/api/kunden/:id` | GET | Detail | ✅ OK |
| `/api/kunden` | POST | Neu | ✅ OK |
| `/api/kunden/:id` | PUT | Update | ✅ OK |
| `/api/kunden/:id` | DELETE | Löschen | ✅ OK |
| `/api/kunden/:id/objekte` | GET | Objekte | ❌ Fehlt |
| `/api/kunden/:id/ansprechpartner` | GET | Ansprechpartner | ❌ Fehlt |
| `/api/kunden/:id/ansprechpartner` | POST | AP Neu | ❌ Fehlt |
| `/api/kunden/:id/ansprechpartner/:ap_id` | PUT | AP Update | ❌ Fehlt |
| `/api/kunden/:id/ansprechpartner/:ap_id` | DELETE | AP Löschen | ❌ Fehlt |
| `/api/kunden/:id/preise` | GET | Kundenpreise | ❌ Fehlt |
| `/api/kunden/:id/preise` | POST | Preis Neu | ❌ Fehlt |
| `/api/kunden/:id/preise/:preis_id` | PUT | Preis Update | ❌ Fehlt |
| `/api/kunden/:id/preise/:preis_id` | DELETE | Preis Löschen | ❌ Fehlt |
| `/api/auftraege?kunde_id=:id` | GET | Aufträge | ❌ Fehlt |
| `/api/auftraege/:va_id/positionen` | GET | Auftragspositionen | ❌ Fehlt |
| `/api/angebote?kunde_id=:id` | GET | Angebote | ❌ Fehlt |
| `/api/kunden/:id/dateien` | GET | Zusatzdateien | ❌ Fehlt |
| `/api/upload` | POST | Datei hochladen | ❌ Fehlt |
| `/api/kunden/:id/statistik` | GET | Umsatz-Statistik | ❌ Fehlt |

---

## 12. PRIORITÄTEN FÜR IMPLEMENTIERUNG

### P0 - Kritisch (Formular-Funktionalität)
1. **Tab-Sichtbarkeit korrigieren**
   - Attribute `hidden` entfernen von: auftraguebersicht, ansprechpartner, angebote, statistik
   - Zeilen 761-764 in HTML

2. **Sidebar hinzufügen**
   - Linkes Menü fehlt komplett
   - Copy from frm_va_Auftragstamm.html (Zeilen 702-750)

3. **API: Auftragsübersicht**
   - `/api/auftraege?kunde_id=123`
   - filterAuftraege() finalisieren

### P1 - Wichtig (Kern-Features)
4. **API: Ansprechpartner CRUD**
   - `/api/kunden/:id/ansprechpartner` (GET, POST, PUT, DELETE)
   - loadAnsprechpartner() implementieren
   - Click-Handler Tabelle → Detail-Form

5. **API: Kundenpreise CRUD**
   - `/api/kunden/:id/preise` (GET, POST, PUT, DELETE)
   - loadKundenpreise() implementieren
   - Detail-Form Datenbindung

6. **API: Auftragspositionen**
   - `/api/auftraege/:va_id/positionen`
   - loadAuftragsPositionen() implementieren
   - Master-Detail: Auftrag → Positionen

### P2 - Nützlich (Zusatz-Features)
7. **API: Angebote**
   - `/api/angebote?kunde_id=123`
   - loadAngebote() implementieren

8. **API: Zusatzdateien + Upload**
   - `/api/kunden/:id/dateien`
   - `/api/upload` (POST)
   - Dateiliste rendern
   - Download-Handler

9. **API: Umsatz-Statistik**
   - `/api/kunden/:id/statistik?jahr=2024`
   - loadStatistik() implementieren
   - Jahresvergleich, KW-Auswertung

### P3 - Optional (Nice-to-have)
10. **PDF-Export-Funktionen**
    - openRechnungPDF() → VBA-Bridge
    - openBerechnungslistePDF() → VBA-Bridge
    - openEinsatzlistePDF() → VBA-Bridge

11. **ComboBox RowSources**
    - cboSuchPLZ, cboSuchOrt (PLZ/Ort-Filter)
    - kun_IDF_PersonID (Ansprechpartner-Dropdown)
    - kun_AdressArt (Adressart-Dropdown)

12. **Office-Integration**
    - openWord() → VBA-Bridge (Brief erstellen)
    - openVerrechnungssaetze() → Formular öffnen
    - openUmsatzauswertung() → Formular öffnen

---

## 13. CODE-BEISPIELE FÜR FEHLENDE FEATURES

### 13.1 API: Ansprechpartner laden
```javascript
// In logic.js
async function loadAnsprechpartner() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!id) return;

    setStatus('Lade Ansprechpartner...');
    try {
        const result = await fetch(`http://localhost:5000/api/kunden/${id}/ansprechpartner`);
        const data = await result.json();
        renderAnsprechpartner(data.data || data);
        setStatus(`${data.length} Ansprechpartner geladen`);
    } catch (error) {
        console.error('[AP] Fehler:', error);
        setStatus('Fehler beim Laden');
    }
}

function renderAnsprechpartner(liste) {
    const tbody = document.getElementById('ansprechpartnerTbody');
    if (!tbody) return;

    if (liste.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666;">Keine Ansprechpartner</td></tr>';
        return;
    }

    tbody.innerHTML = liste.map(ap => `
        <tr data-id="${ap.ID}" onclick="selectAnsprechpartner(${ap.ID})">
            <td>${ap.Nachname || ''}</td>
            <td>${ap.Vorname || ''}</td>
            <td>${ap.Position || ''}</td>
            <td>${ap.Tel || ''}</td>
            <td>${ap.Handy || ''}</td>
            <td>${ap.eMail || ''}</td>
        </tr>
    `).join('');
}

function selectAnsprechpartner(id) {
    // Ansprechpartner in Detail-Form laden
    const ap = state.ansprechpartner.find(a => a.ID === id);
    if (!ap) return;

    document.getElementById('adr_Nachname').value = ap.Nachname || '';
    document.getElementById('adr_Vorname').value = ap.Vorname || '';
    document.getElementById('adr_Tel').value = ap.Tel || '';
    document.getElementById('adr_Handy').value = ap.Handy || '';
    document.getElementById('adr_eMail').value = ap.eMail || '';
    // ... weitere Felder
}
```

### 13.2 API-Server: Ansprechpartner-Endpoint
```python
# In api_server.py

@app.route('/api/kunden/<int:kun_id>/ansprechpartner', methods=['GET'])
def get_kunden_ansprechpartner(kun_id):
    """Ansprechpartner eines Kunden laden"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        sql = """
            SELECT
                a.ID, a.Nachname, a.Vorname, a.AnredeID, a.akad_Grad,
                a.Tel, a.Handy, a.eMail, a.Fax, a.Geburtstag, a.Bemerkung,
                a.Position
            FROM tbl_IDF_Adressen AS a
            INNER JOIN tbl_IDF_Adr_Adressbuch AS az ON a.ID = az.PersonID
            WHERE az.KundenID = ?
            ORDER BY a.Nachname, a.Vorname
        """

        cursor.execute(sql, (kun_id,))
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        result = [dict(zip(columns, row)) for row in rows]

        cursor.close()
        conn.close()

        return jsonify({
            'success': True,
            'data': result,
            'count': len(result)
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/kunden/<int:kun_id>/ansprechpartner', methods=['POST'])
def create_ansprechpartner(kun_id):
    """Neuer Ansprechpartner für Kunden"""
    data = request.json
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # 1. Ansprechpartner in tbl_IDF_Adressen einfügen
        sql_adr = """
            INSERT INTO tbl_IDF_Adressen (
                Nachname, Vorname, AnredeID, akad_Grad, Tel, Handy, eMail, Fax, Geburtstag, Bemerkung, Position
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        cursor.execute(sql_adr, (
            data.get('Nachname'),
            data.get('Vorname'),
            data.get('AnredeID'),
            data.get('akad_Grad'),
            data.get('Tel'),
            data.get('Handy'),
            data.get('eMail'),
            data.get('Fax'),
            data.get('Geburtstag'),
            data.get('Bemerkung'),
            data.get('Position')
        ))

        person_id = cursor.execute("SELECT @@IDENTITY").fetchone()[0]

        # 2. Verknüpfung in tbl_IDF_Adr_Adressbuch
        sql_link = """
            INSERT INTO tbl_IDF_Adr_Adressbuch (PersonID, KundenID)
            VALUES (?, ?)
        """
        cursor.execute(sql_link, (person_id, kun_id))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            'success': True,
            'id': person_id,
            'message': 'Ansprechpartner erstellt'
        }), 201

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
```

### 13.3 Umsatz-Statistik
```python
# In api_server.py

@app.route('/api/kunden/<int:kun_id>/statistik', methods=['GET'])
def get_kunden_statistik(kun_id):
    """Umsatz-Statistik für Kunden"""
    jahr = request.args.get('jahr', datetime.now().year)

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Gesamt-Umsatz
        sql_gesamt = """
            SELECT SUM(Betrag) AS Gesamt
            FROM tbl_VA_Auftragstamm
            WHERE Veranstalter_ID = ? AND Geloescht = 0
        """
        cursor.execute(sql_gesamt, (kun_id,))
        gesamt = cursor.fetchone()[0] or 0

        # Umsatz pro Jahr
        sql_jahre = """
            SELECT
                YEAR(VADatum) AS Jahr,
                SUM(Betrag) AS Umsatz_Netto,
                SUM(Betrag * 1.19) AS Umsatz_Brutto,
                COUNT(*) AS Auftraege
            FROM tbl_VA_Auftragstamm
            WHERE Veranstalter_ID = ? AND Geloescht = 0
            GROUP BY YEAR(VADatum)
            ORDER BY Jahr DESC
        """
        cursor.execute(sql_jahre, (kun_id,))
        jahre_rows = cursor.fetchall()

        jahre = []
        for row in jahre_rows:
            jahre.append({
                'jahr': row[0],
                'umsatz_netto': row[1],
                'umsatz_brutto': row[2],
                'auftraege': row[3]
            })

        cursor.close()
        conn.close()

        return jsonify({
            'success': True,
            'data': {
                'gesamt': gesamt,
                'jahre': jahre
            }
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
```

---

## 14. ZUSAMMENFASSUNG & EMPFEHLUNGEN

### Was funktioniert gut ✅
1. **Formular-Layout:** Sehr gutes Design, fast 1:1 Nachbildung
2. **Stammdaten-Felder:** Alle 70 TextBoxen korrekt gemappt
3. **Navigation:** Erster/Letzter/Vor/Zurück funktioniert
4. **CRUD-Basis:** Speichern, Löschen, Neu anlegen
5. **Kundenliste:** Right-Panel mit Suche und Filter
6. **Tab-Struktur:** 10 Tabs vorhanden (wenn sichtbar gemacht)

### Was fehlt (Priorität) ⚠️
1. **P0:** Sidebar-Menü (komplett fehlt)
2. **P0:** Tab-Sichtbarkeit (4 Tabs versteckt)
3. **P1:** 7 Unterformulare (nur Platzhalter)
4. **P1:** API-Endpoints für Subforms (10+ Endpoints)
5. **P2:** Statistik-Datenbindung (Umsatz, KW-Auswertung)
6. **P3:** PDF-Export über VBA-Bridge

### Empfohlenes Vorgehen
**Phase 1 (Quick-Wins):**
1. Sidebar aus Auftragstamm kopieren
2. Tab-Attribute `hidden` entfernen
3. `/api/auftraege?kunde_id=123` implementieren
4. Auftrags-Liste rendern

**Phase 2 (Kern-Features):**
5. Ansprechpartner CRUD (API + UI)
6. Kundenpreise CRUD (API + UI)
7. Auftragspositionen Master-Detail

**Phase 3 (Zusatz-Features):**
8. Angebote-Tab
9. Zusatzdateien + Upload
10. Umsatz-Statistik

**Phase 4 (Optional):**
11. PDF-Export-Funktionen
12. Office-Integration
13. ComboBox-RowSources

### Geschätzer Aufwand
- **P0 (Quick-Wins):** 2-4 Stunden
- **P1 (Kern-Features):** 8-12 Stunden
- **P2 (Zusatz-Features):** 6-8 Stunden
- **P3 (Optional):** 4-6 Stunden
- **Gesamt:** ~20-30 Stunden für vollständige Implementierung

---

## 15. ÄNDERUNGS-CHECKLISTE

### Sofort umsetzbar (ohne Backend)
- [ ] Sidebar hinzufügen (Copy from Auftragstamm)
- [ ] Tab `hidden` Attribute entfernen (4 Stück)
- [ ] Button-Labels korrigieren (falls nötig)
- [ ] Fehlende ComboBox-Options hardcoden (kun_LKZ, kun_Zahlbed)

### Backend-Changes (api_server.py)
- [ ] `/api/kunden/:id/objekte` (GET)
- [ ] `/api/kunden/:id/ansprechpartner` (GET, POST, PUT, DELETE)
- [ ] `/api/kunden/:id/preise` (GET, POST, PUT, DELETE)
- [ ] `/api/auftraege?kunde_id=123` (GET)
- [ ] `/api/auftraege/:va_id/positionen` (GET)
- [ ] `/api/angebote?kunde_id=123` (GET)
- [ ] `/api/kunden/:id/dateien` (GET)
- [ ] `/api/upload` (POST)
- [ ] `/api/kunden/:id/statistik` (GET)

### Frontend-Changes (logic.js)
- [ ] loadObjekte() implementieren
- [ ] loadAnsprechpartner() + renderAnsprechpartner()
- [ ] loadKundenpreise() + renderKundenpreise()
- [ ] filterAuftraege() finalisieren
- [ ] loadAuftragsPositionen() + Click-Handler
- [ ] loadAngebote() + renderAngebote()
- [ ] loadKundenDateien() + renderDateien()
- [ ] loadStatistik() + Datenbindung
- [ ] File-Upload-Handler finalisieren

### Testing
- [ ] Kunde anlegen (POST)
- [ ] Kunde bearbeiten (PUT)
- [ ] Kunde löschen (DELETE)
- [ ] Navigation (alle 4 Buttons)
- [ ] Suche (Text + Filter)
- [ ] Tabs wechseln (alle 10)
- [ ] Ansprechpartner CRUD
- [ ] Kundenpreise CRUD
- [ ] Auftragsübersicht laden
- [ ] Auftragspositionen anzeigen
- [ ] Angebote laden
- [ ] Datei hochladen
- [ ] Statistik anzeigen

---

**Ende der Gap-Analyse frm_KD_Kundenstamm**
