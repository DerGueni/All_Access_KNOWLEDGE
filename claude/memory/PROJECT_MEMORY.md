# Projektgedächtnis – Consys WebForms

## ZIELE

**Hauptziel:** HTML-Formulare als 1:1-Nachbildungen der Access-Formulare

**Einbindung:** Access-Frontend via `frm_WebHost` (WebView2-Control)

**Output:** `C:\users\guenther.siegert\documents\006_HTML_FERTIG`

---

## ARCHITEKTUR

### 1. Daten-Fluss
```
Access Backend (Consec_BE_V1.55...)
  ↓
Access Frontend (frm_WebHost WebView2 Control)
  ↓
HTML WebForm (index.html)
  ↓
Bridge.js (WebView2 ↔ Access Kommunikation)
```

### 2. WebForm-Struktur
```
generated/forms/
├── frm_ma_Mitarbeiterstamm/  ← DONE (Etappe A)
│   ├── index.html            (UI-Scaffold)
│   ├── form.css              (Styling)
│   ├── form.js               (Event-Binding + State)
│   ├── bridge.js             (Access-Komm.)
│   └── README.md             (Dokumentation)
├── frm_KD_Kundenstamm/        ← NEXT
├── frm_va_Auftragstamm/       ← NEXT
└── ...
```

### 3. Bridge-Protokoll
```
Browser → Access:
  { kind: 'call', method: 'LoadForm', args: {...} }

Access → Browser:
  { kind: 'event', type: 'loadForm', payload: {...} }
```

---

## KONVENTIONEN

### Namensgebung
- **Controls:** `_N_` Präfix für neue Objekte (Regel CLAUDE.md Punkt 2)
  - Formulare: `frm_N_xxx`
  - Queries: `qry_N_xxx`
  - Module: `mod_N_xxx`

### CSS Klassen (namespaced)
- `.toolbar`, `.sidebar`, `.content-area`, `.list-section`
- `.tab-control`, `.tab-header`, `.tab-button`, `.tab-page`
- `.form-section`, `.field-row`, `.field-group`, `.field-input`
- `.employee-table`, `.subform-container`

### JavaScript State
```javascript
const state = {
  currentRecord: {...},
  recordList: [...],
  isDirty: false,
  currentTab: 'pgAdresse',
  filters: {...}
};
```

### Event-Namen (camelCase)
- `Bridge.on('loadForm', fn)`
- `Bridge.on('recordChanged', fn)`
- `Bridge.on('error', fn)`
- `Bridge.callAccess('LoadForm', args)`

---

## STOLPERSTEINE & LÖSUNGEN

### ❌ Stolperstein 1: `Option Compare Database` in VBA
**Problem:** Access hat global `Option Compare Database`, Duplikate = Fehler
**Lösung:** VBA-Code schreiben OHNE diese Zeile → Bridge entfernt automatisch

### ❌ Stolperstein 2: WebView2 nicht in ProPlus2021?
**Problem:** ProPlus2021 Volume typischerweise ohne WebView2
**Lösung:** Nutze bestehenden `frm_WebHost` Mechanismus (wie vorgegeben)

### ❌ Stolperstein 3: SubForms sind separate Formen
**Problem:** frm_Menuefuehrung, sub_MA_ErsatzEmail sind eigene Formen
**Lösung:** Etappe C → iframes + PostMessage für Kommunikation

### ❌ Stolperstein 4: JSON-Exporte können veraltet sein
**Problem:** Exporte vom 08 Nov, neue Features nicht im Export
**Lösung:** Regelmäßig synchen mit `tools/sync_exports.ps1`

### ❌ Stolperstein 5: Daten-Typen (Date vs. Text)
**Problem:** Access-Date-Fields als Text in HTML
**Lösung:** `<input type="date">` für Datum, Konvertierung in JS

### ❌ Stolperstein 6: Image-Handling (MA_Bild)
**Problem:** Fotos aus Access-DB zu HTML
**Lösung:** Base64-Encoding oder URL-Pfad in Bridge-Event

---

## ABHÄNGIGKEITEN (Critical Path)

✓ **Vorhanden:**
- JSON-Exporte in `11_json_Export/000_Consys_Eport_11_25/`
- Templates in `templates/webform/`
- Access-Test-Frontend: `Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb`
- Backend: `Consec_BE_V1.55ANALYSETEST.accdb`

⚠️ **Nötig für Etappe B:**
- VBA-Modul `mod_N_WebForm_Handler` (Bridge-Events)
- WebView2-Control in `frm_WebHost` (Access-Frontend)
- API-Server läuft? (`localhost:5000`)

---

## WICHTIGE DATEIEN & ORTE

| Datei/Ordner | Pfad | Beschreibung |
|---|---|---|
| **Wissensbasis** | `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE` | Root für Exporte, Templates, Generated Forms |
| **JSON-Exporte** | `11_json_Export/000_Consys_Eport_11_25/30_forms/` | Access-Form-Definitionen |
| **Synced Exports** | `claude/knowledge/exports/` | Lokale Kopie (regelmäßig aktualisiert) |
| **Templates** | `templates/webform/` | HTML/CSS/JS Vorlagen |
| **Generated Forms** | `generated/forms/<FormName>/` | Neue WebForms (Arbeitsverzeichnis) |
| **Memory** | `claude/memory/` | PATTERNS.md, DECISIONS.md, TODO_NEXT.md |
| **Finale Output** | `C:\users\guenther.siegert\documents\006_HTML_FERTIG` | Production-Ready HTML |

---

## ETAPPEN-ÜBERBLICK

| Etappe | Fokus | Status |
|---|---|---|
| **A** | UI-Scaffold, HTML Layout, CSS | ✅ DONE |
| **B** | Bridge-Integration, Events, Navigation | ✅ DONE |
| **C** | SubForms, Validierung, SaveRecord | 🔲 TODO |
| **D** | Foto-Upload, Performance, Tests, Build | 🔲 TODO |

### Etappe B Details (✅ Komplett)
- VBA-Modul `mod_N_WebForm_Handler.bas` erstellt (LoadForm, NavigateRecord, DeleteRecord, FieldChanged)
- form.js für Bridge-Events aktualisiert (Bridge.callAccess + Bridge.on)
- Python Import-Script `import_webform_module.py`
- ETAPPE_B_ANLEITUNG.md mit detaillierten Testing-Instructions

---

## PERFORMANCE-NOTES

- **Nicht optimiert in Etappe A:**
  - CSS ist extern (später: Critical Path inline)
  - Liste mit <table> (später: VirtualScroller für >500)
  - Keine Lazy-Loading Images
  - JS nicht minified

- **Später in Etappe D optimieren:**
  - CSS inline + defer
  - JS bundeln/minify
  - Images lazy-load
  - Critical metrics überwachen

---

## DEBUGGING-TIPPS

**Bridge nicht verfügbar?**
```javascript
if (!window.chrome || !window.chrome.webview) {
  console.warn('Bridge not available');
}
```

**State debuggen:**
```javascript
console.log('Current state:', state);
console.log('Current record:', state.currentRecord);
console.log('isDirty:', state.isDirty);
```

**Bridge-Call testen:**
```javascript
window.Bridge.callAccess('Ping', {});
window.Bridge.on('pong', () => console.log('Pong!'));
```

**Tab-Navigation debuggen:**
```javascript
console.log('Switching to tab:', tabId);
console.log('Active tab now:', state.currentTab);
```

---

## QUICK-LINKS

- **CLAUDE.md:** Globale Regeln & Konventionen
- **README.md (im Form):** Form-spezifische Doku
- **PATTERNS.md:** Wiederverwendbare Patterns
- **DECISIONS.md:** Architektur-Entscheidungen & Gründe
- **TODO_NEXT.md:** Nächste Schritte für Etappen B+C+D
