# Entscheidungen

## Etappe A: UI-Scaffold für frm_MA_Mitarbeiterstamm

### 2025-12-24: Layout = Flexbox statt Grid
**Entscheidung:** Flexbox für `.main-container` + Sidebar, nicht CSS Grid
**Grund:**
- Einfacher für variabler Sidebar-Breite (280px)
- Bessere Mobile-Anpassung (flex-direction: column)
- Kompatibilität mit älteren Browsern

**Konsequenz:**
- Responsive gut machbar
- Grid bei vielen Spalten später möglich

---

### 2025-12-24: TabControl = Buttons + Hide/Show
**Entscheidung:** Manuelle Tab-Simulation statt HTML `<details>` oder andere Komponenten
**Grund:**
- Volle Kontrolle über Styling
- Einfaches Event-Handling
- Nah an Access-Verhalten

**Konsequenz:**
- `tab-active` Klasse als State
- CSS: `.tab-page { display: none; } .tab-page.tab-active { display: block; }`
- JavaScript: `switchTab(id)` Funktion

---

### 2025-12-24: Bridge für alle Access-Calls
**Entscheidung:** Alle Daten-Operationen über Bridge, kein direktes Fetch zur API
**Grund:**
- Einzige Schnittstelle zwischen HTML-Form und Access
- Einfacher zu mocking/testen
- Zentraler Kontrollpunkt

**Konsequenz:**
- Datenlad erst nach `Bridge.on('loadForm', ...)` Event
- Alle Buttons rufen `Bridge.callAccess()` auf
- Dependencies auf API-Server nicht in diesem Form

---

### 2025-12-24: fieldMap für Daten-Binding
**Entscheidung:** Zentrale Mapping-Tabelle (fieldName → DOM Element)
**Grund:**
- Keine `.getElementById()` bei jedem Aufruf
- Leicht zu testen/debuggen
- Single Source of Truth für Feldlisten

**Konsequenz:**
- `populateFormFields()` nutzt `fieldMap`
- Bei neuen Feldern: einfach in Map eintragen
- Bei Element-ID-Änderungen: nur Map updaten

---

### 2025-12-24: state.isDirty für Änderungsverfolgung
**Entscheidung:** Flag `isDirty` statt jedem Field `.pristine` Klasse
**Grund:**
- Einfacher zu implementieren
- Global sichtbar (für Speichern-Button Disable)
- Standard UI-Pattern

**Konsequenz:**
- `isDirty = true` bei Field-Change
- `isDirty = false` nach Speichern
- Später: "Wirklich schließen ohne zu speichern?" Dialog

---

### 2025-12-24: Employee-List = HTML Table statt virtuales Scrolling
**Entscheidung:** Standard HTML `<table>` statt VirtualScroller
**Grund:**
- Erste Etappe: nicht auf Performance optimieren
- Einfaches Row-Selection-Pattern
- Später: bei >500 Mitarbeitern → VirtualScroller

**Konsequenz:**
- `<table>` mit `overflow-y: auto`
- Sticky `<thead>`
- Row-Klick → `state.currentRecord` setzen

---

### 2025-12-24: 3 Tabs statt 1 großes Formular
**Entscheidung:** pgAdresse | pgBank | pgArbeit Tabs
**Grund:**
- Access-Form hat TabControl → 1:1 Nachbildung
- Bessere UX auf Tablets/Mobile
- Logische Gruppierung (Adresse / Finanzen / Anstellung)

**Konsequenz:**
- Struktur aus JSON-Export respektieren
- Später: Lazy-Loading von Tab-Inhalten möglich

---

### 2025-12-24: Sidebar = Menü + Toggles
**Entscheidung:** frm_Menuefuehrung SubForm + Toggle-Buttons in Sidebar
**Grund:**
- Access-Form hat Sidebar-Menü (Menue SubForm)
- Toggle-Buttons: `btnRibbonAus`, `btnRibbonEin`, `btnDaBaAus`, `btnDaBaEin`
- Ribbon/DataArea Visibility kann User kontrollieren

**Konsequenz:**
- `<aside class="sidebar">` mit flex-direction: column
- Subform als Placeholder (wird in Etappe C implementiert)
- Toggle-Buttons verstecken/zeigen `.sidebar`, `.content-area`

---

### 2025-12-24: Keine Option Compare Database in VBA-Code
**Entscheidung:** Bridge entfernt automatisch `Option Compare Database` Zeilen
**Grund:**
- Access-VBA hat global `Option Compare Database`
- Duplikate würden Fehler auslösen
- CLAUDE.md Punkt 3 vorgegeben

**Konsequenz:**
- VBA-Code ohne diese Zeile schreiben
- Bridge importiert sauber

---

### 2025-12-24: CSS Critical Path (Inline später)
**Entscheidung:** `form.css` extern, nicht inline (noch nicht optimiert)
**Grund:**
- Etappe A = Funktionalität, nicht Performance
- Später: Critical CSS inline + defered loading

**Konsequenz:**
- `<link rel="stylesheet" href="./form.css">`
- In Etappe D: Critical-Path-Optimierung

---

### 2025-12-24: Keine SubForms in Etappe A
**Entscheidung:** SubForm-Placeholders statt Implementierung
**Grund:**
- frm_Menuefuehrung: separate Form, komplexe Dependencies
- sub_MA_ErsatzEmail: eigene Logik nötig
- Etappe C = SubForms + PostMessage

**Konsequenz:**
- `<div class="subform-placeholder">` in HTML
- form.js hat `setupBridgeListeners()` für Events
- Etappe C: iframe + postMessage

---

## Abhängigkeits-Notizen (Etappe B nötig)

- [ ] Access Backend-Query für Mitarbeiterliste (Filter: Anstellungsart_ID IN (3,5))
- [ ] VBA-Modul für `LoadForm`, `NavigateRecord`, `DeleteRecord`, `PrintEmployeeList`, etc.
- [ ] WebView2 Control im Access-Frontend (frm_WebHost)
- [ ] Foto-Speicherung (Base64 oder URL-Path)
