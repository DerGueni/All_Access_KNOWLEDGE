# frm_MA_Mitarbeiterstamm – HTML Nachbildung

## Übersicht

1:1 HTML-Nachbildung des Access-Formulars `frm_MA_Mitarbeiterstamm` aus `tbl_MA_Mitarbeiterstamm`.

**Quell-Export:** `FRM_frm_MA_Mitarbeiterstamm.json`

---

## Struktur

```
generated/forms/frm_ma_Mitarbeiterstamm/
├── index.html         # Haupt-HTML (Layout + Controls)
├── form.css           # Styling (Toolbar, Sidebar, Tabs, Fields)
├── form.js            # Event-Binding + Data-Handling
├── bridge.js          # Access-Kommunikation via WebView2
└── README.md          # Diese Datei
```

---

## Layout-Anatomie

### 1. Toolbar (oben, 50px)
- **Navigation Buttons:** Erster/Vorheriger/Nächster/Letzter Datensatz
- **Version Label:** Aktuelle Version + Datum
- **Action Buttons:** Löschen, Druck, Zeitkonto, etc.

### 2. Main Container (Sidebar + Content Area)

#### Sidebar (Links, 280px breit)
- **Toggle Buttons:** Menu/Datenbereich an/aus
- **SubForm:** `frm_Menuefuehrung` (Menü-Navigation)

#### Content Area (Mitte)
- **TabControl (reg_MA):**
  - **pgAdresse Tab:** Persönliche & Adressdaten
  - **pgBank Tab:** Bankverbindung
  - **pgArbeit Tab:** Anstellungsdaten & Ausweise

### 3. List Section (unten, 200px)
- **Gefilterte Mitarbeiterliste:**
  - Query: `SELECT ID, Nachname, Vorname, Ort FROM tbl_MA_Mitarbeiterstamm WHERE Anstellungsart_ID IN (3, 5) ORDER BY Nachname, Vorname`
  - Klick auf Zeile = Record laden

---

## Feldzuordnung (Controls)

### Administrative Felder
| ControlName | Type | Beschreibung | Bound |
|---|---|---|---|
| PersNr | TextBox | Mitarbeiter-ID | Ja (readonly) |
| LEXWare_ID | TextBox | LEXWare Import ID | Ja |
| IstAktiv | CheckBox | Mitarbeiter aktiv | Ja |
| IstSubunternehmer | CheckBox | Ist Subunternehmer | Ja |

### Persönliche Daten
| ControlName | Type | Bound |
|---|---|---|
| Nachname | TextBox | Ja |
| Vorname | TextBox | Ja |
| Geschlecht | TextBox | Ja |
| Geb_Dat | TextBox (Date) | Ja |
| Geb_Ort | TextBox | Ja |
| Geb_Name | TextBox | Ja |
| Staatsang | TextBox | Ja |

### Adressdaten
| ControlName | Type |
|---|---|
| Strasse | TextBox |
| Nr | TextBox |
| PLZ | TextBox |
| Ort | TextBox |
| Land | TextBox |
| Bundesland | TextBox |

### Kontaktdaten
| ControlName | Type |
|---|---|
| Tel_Mobil | TextBox |
| Tel_Festnetz | TextBox |
| Email | TextBox |

### Bankverbindung (pgBank Tab)
| ControlName | Type |
|---|---|
| Auszahlungsart | TextBox |
| Bankname | TextBox |
| Bankleitzahl | TextBox |
| Kontonummer | TextBox |
| BIC | TextBox |
| IBAN | TextBox |

### Anstellungsdaten (pgArbeit Tab)
| ControlName | Type |
|---|---|
| Anstellungsart | TextBox |
| Eintrittsdatum | TextBox (Date) |
| Austrittsdatum | TextBox (Date) |
| Kostenstelle | TextBox |
| Eigener_PKW | CheckBox |
| DienstausweisNr | TextBox |
| Ausweis_Endedatum | TextBox (Date) |
| Ausweis_Funktion | TextBox |
| Epin_DFB | TextBox |
| Bewacher_ID | TextBox |

### Sonstiges
| ControlName | Type | Beschreibung |
|---|---|---|
| MA_Bild | ImageControl | Mitarbeiterfoto |
| sub_MA_ErsatzEmail | SubForm | Ersatz-Email Verwaltung |

---

## Events & Handlers

### Form-Level Events (aus Access)

| Event | Handler-Typ | Beschreibung |
|---|---|---|
| OnLoad | Procedure | Form laden, Daten initialisieren |
| OnCurrent | - | Record-Navigation |
| BeforeUpdate | - | Validierung vor Speicherung |
| AfterUpdate | Procedure | Nach Speicherung |

### Control Events (auf HTML abgebildet)

**Toolbar Buttons:**
- `btnDelete` → OnClick → Bridge.callAccess('DeleteRecord', {...})
- `btnLstDruck` → OnClick → Bridge.callAccess('PrintEmployeeList', {...})
- `btnZeitkonto` → OnClick → Bridge.callAccess('OpenTimeAccountForm', {...})

**Navigation Buttons:**
- `btn-first/prev/next/last` → navigateRecord(direction)

**List Selection:**
- `lst_MA tbody tr` → Click → LoadRecord(id)

**Form Fields:**
- OnChange → Bridge.callAccess('FieldChanged', {fieldName, value, recordId})

---

## Bridge Contract

### Browser → Access

```javascript
// Load Form Data
Bridge.callAccess('LoadForm', {
  formName: 'frm_MA_Mitarbeiterstamm',
  recordId: 437
});

// Navigation
Bridge.callAccess('NavigateRecord', {
  direction: 'next' | 'prev' | 'first' | 'last'
});

// Field Change
Bridge.callAccess('FieldChanged', {
  fieldName: 'Nachname',
  value: 'Mueller',
  recordId: 123
});

// Delete Record
Bridge.callAccess('DeleteRecord', {
  formName: 'frm_MA_Mitarbeiterstamm',
  recordId: 123
});
```

### Access → Browser

```javascript
// Load Record Data
Bridge.on('loadForm', (data) => {
  // data.record = {...}
  // data.recordList = [...]
});

// Record Changed
Bridge.on('recordChanged', (data) => {
  // data.record = {...}
});

// Error
Bridge.on('error', (data) => {
  // data.message = '...'
});

// Form Closed
Bridge.on('formClosed', () => {});
```

---

## CSS Klassen

### Layout
- `.toolbar` – Obere Symbolleiste
- `.main-container` – Haupt-Container (Sidebar + Content)
- `.sidebar` – Linke Seitenleiste
- `.content-area` – Mittlerer Inhaltsbereich
- `.list-section` – Unterer Listenbereich

### TabControl
- `.tab-control` – TabControl-Container
- `.tab-header` – Tab-Reiter
- `.tab-button` – Einzelner Tab-Button
- `.tab-button.tab-active` – Aktiver Tab
- `.tab-page` – Tab-Seite
- `.tab-page.tab-active` – Aktive Tab-Seite

### Formulare
- `.form-section` – Formularsektion
- `.subsection-title` – Untertitel
- `.field-row` – Feldzeile
- `.field-group` – Einzelnes Feld
- `.field-input` – Input-Element
- `.field-checkbox` – Checkbox-Feld

### Liste
- `.employee-table` – Mitarbeiterliste
- `.employee-table tbody tr.selected` – Ausgewählte Zeile

---

## State Management

```javascript
const state = {
  currentRecord: {...},        // Aktueller Datensatz
  recordList: [...],          // Alle geladenen Mitarbeiter
  isDirty: false,             // Hat sich etwas geändert?
  currentTab: 'pgAdresse',    // Aktiver Tab
  filters: {
    anstellungsart_id: [3, 5]  // Filter für Liste
  }
};
```

---

## Responsive Design

- **Desktop (>1024px):** 3-spaltig (Sidebar + Content + Extras)
- **Tablet (768-1024px):** 2-spaltig (Sidebar oben, Content unten)
- **Mobile (<768px):** 1-spaltig (Sidebar → Content → Liste)

---

## Etappen-Umsetzung

### Etappe A (DONE) ✓
- [x] JSON-Export analysieren
- [x] UI-Scaffold HTML erstellen
- [x] CSS Layout implementieren
- [x] form.js Grundgerüst

### Etappe B (TODO)
- [ ] Bridge-Integration mit Access testen
- [ ] Datenladung (LoadForm-Event)
- [ ] Formularvalidierung
- [ ] Speichern/Löschen

### Etappe C (TODO)
- [ ] SubForms integrieren (frm_Menuefuehrung, sub_MA_ErsatzEmail)
- [ ] Events mappen (OnClick, OnChange, etc.)
- [ ] Foto-Upload

### Etappe D (TODO)
- [ ] Smoke-Test mit Playwright
- [ ] Pattern dokumentieren
- [ ] Production Build

---

## Abhängigkeiten (Dependencies)

### Tabellen
- `tbl_MA_Mitarbeiterstamm` – Haupttabelle

### SubForms
- `frm_Menuefuehrung` – Menu-Navigation (Sidebar)
- `sub_MA_ErsatzEmail` – Ersatz-Email Management

### Queries/Makros (aus Access)
- `DeleteRecord` Macro – Record-Löschung
- `PrintEmployeeList` Macro – Druck
- `OpenTimeAccountForm`, `OpenTimeAccountFixed`, `OpenTimeAccountMini` – Zeit-Verwaltung

---

## Weitere Hinweise

1. **Bridge nur für frm_WebHost:** Dieses Formular wird als **WebView2-Control** im Access-Frontend angezeigt
2. **Keine Option Compare Database:** VBA-Module werden ohne `Option Compare Database` importiert
3. **Naming Convention:** Alle neuen Controls/Queries/Module müssen `_N_` Präfix haben
4. **Subforms:** Werden via PostMessage kommuniziert (parent ↔ iframe)

---

## Autor & Zeitstempel

- **Erstellt:** 24. Dezember 2025
- **Version:** 1.0 (UI-Scaffold)
- **Status:** Etappe A abgeschlossen, Etappe B folgt
