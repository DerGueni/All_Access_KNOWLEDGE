---
name: Professional UI Design
description: Erstellt professionelle, konsistente UI-Designs für HTML-Formulare. Vermeidet generische AI-Ästhetik, nutzt mutige Design-Entscheidungen und Access-typische Business-Anwendungs-Optik.
when_to_use: UI Design, professionelles Layout, Business-Anwendung, Formular-Styling, Dashboard, konsistentes Design
version: 1.0.0
auto_trigger: design, ui, professionell, styling, look, aussehen, optik
---

# Professional UI Design für CONSYS

## 🎯 Design-Philosophie

**NIEMALS generische AI-Ästhetik verwenden:**
- ❌ Übernutzte Fonts (Inter, Roboto, Arial)
- ❌ Klischee-Farbschemata (lila Gradienten auf weiß)
- ❌ Vorhersagbare Layouts
- ❌ Cookie-Cutter-Designs ohne Kontext

**STATTDESSEN für Business-Anwendungen:**
- ✅ Präzision & Dichte (kompakte, informationsreiche Layouts)
- ✅ Klare Hierarchie (wichtige Elemente hervorgehoben)
- ✅ Professionelle Farbpaletten (gedämpft, geschäftlich)
- ✅ Konsistente Abstände (4px/8px Grid)

---

## 🎨 CONSYS Design-System

### Farben (Access-typisch)

```css
:root {
  /* Primärfarben */
  --primary-blue: #0066CC;      /* Buttons, Links */
  --primary-dark: #004499;      /* Hover-States */
  
  /* Hintergrund */
  --bg-form: #F0F0F0;           /* Formular-Hintergrund */
  --bg-header: #E0E0E0;         /* Header-Bereich */
  --bg-white: #FFFFFF;          /* Eingabefelder */
  
  /* Text */
  --text-primary: #000000;      /* Haupttext */
  --text-secondary: #333333;    /* Sekundärtext */
  --text-label: #000000;        /* Labels */
  
  /* Rahmen */
  --border-input: #7F9DB9;      /* Eingabefeld-Rahmen */
  --border-section: #808080;    /* Sektions-Rahmen */
  
  /* Status */
  --status-success: #28A745;
  --status-warning: #FFC107;
  --status-error: #DC3545;
  --status-info: #17A2B8;
}
```

### Typografie

```css
/* Business-Anwendung = Lesbarkeit */
body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  font-size: 11px;
  line-height: 1.4;
}

.form-title {
  font-size: 15px;
  font-weight: bold;
  color: #000000;
}

.section-title {
  font-size: 12px;
  font-weight: bold;
  color: #333333;
}

label {
  font-size: 11px;
  color: #000000;
}

input, select, textarea {
  font-size: 11px;
  font-family: inherit;
}
```

### Abstände (4px Grid)

```css
/* Konsistente Abstände */
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 12px;
--spacing-lg: 16px;
--spacing-xl: 24px;

/* Formular-Elemente */
.form-group {
  margin-bottom: 8px;
}

.form-section {
  padding: 12px;
  margin-bottom: 16px;
}
```

---

## 📐 Layout-Patterns

### 1. Header-Bereich (Access-typisch)

```html
<div class="form-header">
  <div class="header-left">
    <span class="form-title">Formularname</span>
    <span class="record-info">Datensatz: 1 von 150</span>
  </div>
  <div class="header-right">
    <button class="btn-nav">◀</button>
    <button class="btn-nav">▶</button>
    <button class="btn-close">✕</button>
  </div>
</div>
```

```css
.form-header {
  background: linear-gradient(180deg, #E8E8E8 0%, #D0D0D0 100%);
  border-bottom: 1px solid #808080;
  padding: 8px 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

### 2. Formular-Sektionen (Feldgruppen)

```html
<fieldset class="form-section">
  <legend>Stammdaten</legend>
  <div class="form-row">
    <label for="txtName">Name:</label>
    <input type="text" id="txtName">
  </div>
</fieldset>
```

```css
.form-section {
  border: 1px solid #808080;
  background: #F5F5F5;
  padding: 12px;
  margin-bottom: 12px;
}

.form-section legend {
  font-weight: bold;
  padding: 0 8px;
  color: #333;
}
```

### 3. Tabellen/Datengrids

```css
.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 11px;
}

.data-table th {
  background: #D0D0D0;
  border: 1px solid #808080;
  padding: 4px 8px;
  text-align: left;
  font-weight: bold;
}

.data-table td {
  border: 1px solid #C0C0C0;
  padding: 4px 8px;
}

.data-table tr:nth-child(even) {
  background: #F8F8F8;
}

.data-table tr:hover {
  background: #E8F4FF;
}

.data-table tr.selected {
  background: #0066CC;
  color: white;
}
```

### 4. Buttons (Access-Style)

```css
.btn {
  font-size: 11px;
  padding: 4px 12px;
  border: 1px solid #808080;
  background: linear-gradient(180deg, #F8F8F8 0%, #E0E0E0 100%);
  cursor: pointer;
  min-width: 75px;
}

.btn:hover {
  background: linear-gradient(180deg, #E8E8E8 0%, #D0D0D0 100%);
}

.btn:active {
  background: linear-gradient(180deg, #D0D0D0 0%, #E0E0E0 100%);
}

.btn-primary {
  background: linear-gradient(180deg, #4A90D9 0%, #0066CC 100%);
  color: white;
  border-color: #004499;
}

.btn-primary:hover {
  background: linear-gradient(180deg, #5A9FE9 0%, #0077DD 100%);
}
```

---

## 🔧 Komponenten-Bibliothek

### Input-Felder

```css
input[type="text"],
input[type="number"],
input[type="date"],
select {
  border: 1px solid #7F9DB9;
  padding: 2px 4px;
  background: white;
  font-size: 11px;
}

input:focus,
select:focus {
  border-color: #0066CC;
  outline: none;
  box-shadow: 0 0 3px rgba(0,102,204,0.3);
}

input:disabled,
select:disabled {
  background: #E8E8E8;
  color: #666;
}
```

### Checkboxen & Radio-Buttons

```css
input[type="checkbox"],
input[type="radio"] {
  margin-right: 4px;
  vertical-align: middle;
}

.checkbox-label,
.radio-label {
  display: inline-flex;
  align-items: center;
  cursor: pointer;
}
```

### Tabs (Access TabControl)

```css
.tab-container {
  border: 1px solid #808080;
}

.tab-header {
  display: flex;
  background: #E0E0E0;
  border-bottom: 1px solid #808080;
}

.tab-button {
  padding: 6px 16px;
  border: none;
  background: transparent;
  cursor: pointer;
  border-right: 1px solid #808080;
}

.tab-button.active {
  background: #F5F5F5;
  border-bottom: 1px solid #F5F5F5;
  margin-bottom: -1px;
}

.tab-content {
  padding: 12px;
  background: #F5F5F5;
}
```

---

## ✅ Design-Checkliste

Vor Abschluss prüfen:

- [ ] Konsistente Schriftgröße (11px Standard)
- [ ] Einheitliche Abstände (4px/8px Grid)
- [ ] Access-typische Farben verwendet
- [ ] Hover-States für interaktive Elemente
- [ ] Focus-States für Eingabefelder
- [ ] Disabled-States definiert
- [ ] Tabellen mit alternierenden Zeilen
- [ ] Buttons mit Gradient-Effekt
- [ ] Header-Bereich mit Titel und Navigation
- [ ] Responsive? (nur wenn explizit gewünscht)

---

## 📁 Dateipfade

- **CSS-Haupt:** `04_HTML_Forms/forms3/css/consys.css`
- **Formular-spezifisch:** `04_HTML_Forms/forms3/css/form-[name].css`
- **Unified Header:** `04_HTML_Forms/forms3/css/unified-header.css`
- **Titel-Styles:** `04_HTML_Forms/forms3/css/form-titles.css`
