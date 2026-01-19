---
name: Form Component Library
description: Wiederverwendbare HTML-Komponenten für CONSYS-Formulare. Buttons, Inputs, Tabellen, Tabs, Dialoge - alle Access-kompatibel und konsistent gestylt.
when_to_use: Komponente erstellen, Button hinzufügen, Tabelle erstellen, Input-Feld, Select-Box, Tab-Control, Dialog
version: 1.0.0
auto_trigger: komponente, component, tabelle, table, dialog, modal, tab, input
---

# Form Component Library für CONSYS

## 📦 Verfügbare Komponenten

### 1. Buttons

#### Standard-Button
```html
<button type="button" class="btn" onclick="myFunction()">
  Beschriftung
</button>
```

#### Primär-Button (Hauptaktion)
```html
<button type="button" class="btn btn-primary" onclick="saveData()">
  Speichern
</button>
```

#### Icon-Button
```html
<button type="button" class="btn btn-icon" onclick="refresh()" title="Aktualisieren">
  🔄
</button>
```

#### Button-Gruppe
```html
<div class="btn-group">
  <button class="btn">◀ Zurück</button>
  <button class="btn">Weiter ▶</button>
</div>
```

#### Navigation-Buttons (Datensatz)
```html
<div class="record-nav">
  <button class="btn-nav" onclick="firstRecord()">|◀</button>
  <button class="btn-nav" onclick="prevRecord()">◀</button>
  <button class="btn-nav" onclick="nextRecord()">▶</button>
  <button class="btn-nav" onclick="lastRecord()">▶|</button>
</div>
```

---

### 2. Input-Felder

#### Text-Input
```html
<div class="form-group">
  <label for="txtName">Name:</label>
  <input type="text" id="txtName" name="Name" class="form-control">
</div>
```

#### Nummer-Input
```html
<div class="form-group">
  <label for="txtAnzahl">Anzahl:</label>
  <input type="number" id="txtAnzahl" name="Anzahl" class="form-control" min="0" step="1">
</div>
```

#### Datum-Input
```html
<div class="form-group">
  <label for="txtDatum">Datum:</label>
  <input type="date" id="txtDatum" name="Datum" class="form-control">
</div>
```

#### Zeit-Input
```html
<div class="form-group">
  <label for="txtZeit">Uhrzeit:</label>
  <input type="time" id="txtZeit" name="Zeit" class="form-control">
</div>
```

#### Readonly-Feld (Anzeige)
```html
<div class="form-group">
  <label for="txtID">ID:</label>
  <input type="text" id="txtID" name="ID" class="form-control" readonly>
</div>
```

#### Mehrzeiliges Textfeld
```html
<div class="form-group">
  <label for="txtBemerkung">Bemerkung:</label>
  <textarea id="txtBemerkung" name="Bemerkung" class="form-control" rows="3"></textarea>
</div>
```

---

### 3. Select-Boxen (ComboBox)

#### Einfache Select-Box
```html
<div class="form-group">
  <label for="cboStatus">Status:</label>
  <select id="cboStatus" name="Status" class="form-control">
    <option value="">-- Bitte wählen --</option>
    <option value="1">Aktiv</option>
    <option value="2">Inaktiv</option>
  </select>
</div>
```

#### Select mit Daten-Laden
```html
<div class="form-group">
  <label for="cboKunde">Kunde:</label>
  <select id="cboKunde" name="KundeID" class="form-control" data-source="/api/kunden">
    <option value="">-- Bitte wählen --</option>
    <!-- Wird per JS befüllt -->
  </select>
</div>
```

```javascript
// Befüllung per API
async function loadKunden() {
  const response = await fetch('/api/kunden');
  const kunden = await response.json();
  const select = document.getElementById('cboKunde');
  kunden.forEach(k => {
    const option = document.createElement('option');
    option.value = k.ID;
    option.textContent = k.Name;
    select.appendChild(option);
  });
}
```

---

### 4. Checkboxen & Radio-Buttons

#### Einzelne Checkbox
```html
<div class="form-check">
  <input type="checkbox" id="chkAktiv" name="Aktiv" class="form-check-input">
  <label for="chkAktiv" class="form-check-label">Aktiv</label>
</div>
```

#### Checkbox-Gruppe
```html
<div class="form-group">
  <label>Optionen:</label>
  <div class="checkbox-group">
    <div class="form-check">
      <input type="checkbox" id="chkOpt1" name="Optionen" value="1">
      <label for="chkOpt1">Option 1</label>
    </div>
    <div class="form-check">
      <input type="checkbox" id="chkOpt2" name="Optionen" value="2">
      <label for="chkOpt2">Option 2</label>
    </div>
  </div>
</div>
```

#### Radio-Buttons (OptionGroup)
```html
<div class="form-group">
  <label>Auswahl:</label>
  <div class="radio-group">
    <div class="form-radio">
      <input type="radio" id="optA" name="Auswahl" value="A">
      <label for="optA">Option A</label>
    </div>
    <div class="form-radio">
      <input type="radio" id="optB" name="Auswahl" value="B">
      <label for="optB">Option B</label>
    </div>
  </div>
</div>
```

---

### 5. Tabellen (Datengrids)

#### Standard-Tabelle
```html
<div class="table-container">
  <table class="data-table" id="tblDaten">
    <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Status</th>
        <th>Datum</th>
      </tr>
    </thead>
    <tbody>
      <!-- Zeilen werden per JS eingefügt -->
    </tbody>
  </table>
</div>
```

#### Tabelle mit Auswahl
```html
<table class="data-table selectable" id="tblMitarbeiter">
  <thead>
    <tr>
      <th style="width:30px;"></th>
      <th>Name</th>
      <th>Abteilung</th>
    </tr>
  </thead>
  <tbody>
    <tr data-id="1" onclick="selectRow(this)">
      <td><input type="checkbox" class="row-select"></td>
      <td>Müller</td>
      <td>Vertrieb</td>
    </tr>
  </tbody>
</table>
```

```javascript
function selectRow(row) {
  document.querySelectorAll('.data-table tr.selected').forEach(r => r.classList.remove('selected'));
  row.classList.add('selected');
  const id = row.dataset.id;
  // Weiteres verarbeiten
}
```

---

### 6. Tab-Control

```html
<div class="tab-container">
  <div class="tab-header">
    <button class="tab-button active" data-tab="tab1" onclick="showTab('tab1')">Allgemein</button>
    <button class="tab-button" data-tab="tab2" onclick="showTab('tab2')">Details</button>
    <button class="tab-button" data-tab="tab3" onclick="showTab('tab3')">Historie</button>
  </div>
  
  <div class="tab-content active" id="tab1">
    <!-- Inhalt Tab 1 -->
  </div>
  <div class="tab-content" id="tab2">
    <!-- Inhalt Tab 2 -->
  </div>
  <div class="tab-content" id="tab3">
    <!-- Inhalt Tab 3 -->
  </div>
</div>
```

```javascript
function showTab(tabId) {
  // Alle Tabs deaktivieren
  document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
  
  // Gewählten Tab aktivieren
  document.querySelector(`[data-tab="${tabId}"]`).classList.add('active');
  document.getElementById(tabId).classList.add('active');
}
```

---

### 7. Dialoge/Modals

```html
<div class="modal" id="dlgBestaetigung">
  <div class="modal-overlay" onclick="closeModal('dlgBestaetigung')"></div>
  <div class="modal-content">
    <div class="modal-header">
      <span class="modal-title">Bestätigung</span>
      <button class="modal-close" onclick="closeModal('dlgBestaetigung')">×</button>
    </div>
    <div class="modal-body">
      <p>Möchten Sie den Datensatz wirklich löschen?</p>
    </div>
    <div class="modal-footer">
      <button class="btn" onclick="closeModal('dlgBestaetigung')">Abbrechen</button>
      <button class="btn btn-primary" onclick="confirmDelete()">Löschen</button>
    </div>
  </div>
</div>
```

```javascript
function openModal(modalId) {
  document.getElementById(modalId).classList.add('show');
}

function closeModal(modalId) {
  document.getElementById(modalId).classList.remove('show');
}
```

```css
.modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1000;
}

.modal.show {
  display: block;
}

.modal-overlay {
  position: absolute;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
}

.modal-content {
  position: relative;
  background: white;
  width: 400px;
  margin: 100px auto;
  border: 1px solid #808080;
  box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}

.modal-header {
  background: #E0E0E0;
  padding: 8px 12px;
  border-bottom: 1px solid #808080;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-body {
  padding: 16px;
}

.modal-footer {
  padding: 8px 12px;
  border-top: 1px solid #E0E0E0;
  text-align: right;
}

.modal-footer .btn {
  margin-left: 8px;
}
```

---

### 8. Statusleiste

```html
<div class="status-bar">
  <span class="status-text" id="lblStatus">Bereit</span>
  <span class="status-info">Datensatz 1 von 150</span>
  <span class="status-user">Benutzer: Admin</span>
</div>
```

```css
.status-bar {
  background: #E8E8E8;
  border-top: 1px solid #808080;
  padding: 4px 12px;
  font-size: 10px;
  display: flex;
  justify-content: space-between;
}

.status-text {
  flex: 1;
}
```

---

## 📁 CSS-Klassen Übersicht

| Klasse | Verwendung |
|--------|------------|
| `.btn` | Standard-Button |
| `.btn-primary` | Primärer Button |
| `.btn-icon` | Icon-Button |
| `.btn-nav` | Navigation-Button |
| `.form-group` | Formular-Feldgruppe |
| `.form-control` | Input/Select/Textarea |
| `.form-check` | Checkbox/Radio Container |
| `.data-table` | Daten-Tabelle |
| `.tab-container` | Tab-Control |
| `.modal` | Dialog/Modal |
| `.status-bar` | Statusleiste |

---

## ✅ Verwendung

1. Komponente aus dieser Bibliothek wählen
2. HTML-Code kopieren und anpassen
3. IDs und Namen eindeutig vergeben
4. onclick-Handler implementieren
5. In CLAUDE2.md dokumentieren
