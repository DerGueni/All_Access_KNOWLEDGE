# FROZEN FEATURES - Baseline Dokumentation

**Erstellt:** 2026-01-09
**Status:** FROZEN - Keine Aenderungen ohne explizite Anweisung!

Diese Datei dokumentiert alle eingefrorenen Features als Baseline. Aenderungen an diesen Features erfordern explizite Anweisung.

---

## 1. AUFTRAGSTAMM (frm_va_Auftragstamm.html)

### 1.1 Einsatzliste (gridZuordnungen)

| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Table-Layout | `table-layout: fixed;` | frm_va_Auftragstamm.html:1379 | FROZEN |
| Zellenhoehe | `height: 22px; line-height: 22px;` | frm_va_Auftragstamm.html:1127-1128 | FROZEN |
| Zellenpadding | `padding: 1px 3px;` | frm_va_Auftragstamm.html:1129 | FROZEN |
| Text-Overflow | `white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 0;` | frm_va_Auftragstamm.html:1123-1126 | FROZEN |

**Checkboxen (klein):**
| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Checkbox-Groesse | `width: 14px; height: 14px;` | frm_va_Auftragstamm.html:1137-1138 | FROZEN |
| Checkbox-Margin | `margin: 0; vertical-align: middle;` | frm_va_Auftragstamm.html:1139-1140 | FROZEN |

**Spaltenbreiten (schmal):**
| Spalte | Breite | Datei:Zeile | Status |
|--------|--------|-------------|--------|
| Lfd | `width: 30px` | frm_va_Auftragstamm.html:1382 | FROZEN |
| Mitarbeiter | `width: 70px` | frm_va_Auftragstamm.html:1383 | FROZEN |
| von | `width: 45px` | frm_va_Auftragstamm.html:1384 | FROZEN |
| bis | `width: 45px` | frm_va_Auftragstamm.html:1385 | FROZEN |
| Std | `width: 45px` | frm_va_Auftragstamm.html:1386 | FROZEN |
| Bemerkungen | `width: 120px` | frm_va_Auftragstamm.html:1387 | FROZEN |
| ? (Fraglich) | `width: 28px` | frm_va_Auftragstamm.html:1388 | FROZEN |
| PKW | `width: 38px` | frm_va_Auftragstamm.html:1389 | FROZEN |
| EL | `width: 28px` | frm_va_Auftragstamm.html:1390 | FROZEN |
| RE | `width: 28px` | frm_va_Auftragstamm.html:1391 | FROZEN |

**Zahlenfelder:**
| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Input-Number-Breite | `width: 30px !important;` | frm_va_Auftragstamm.html:1144 | FROZEN |
| Input-Number-Ausrichtung | `text-align: right;` | frm_va_Auftragstamm.html:1146 | FROZEN |

**Bedingte Sichtbarkeit:**
| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| col-hidden Klasse | `display: none;` | frm_va_Auftragstamm.html:1149-1151 | FROZEN |

---

### 1.2 Auftragsliste rechts (right-panel)

| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Panel-Breite | `width: 415px;` | frm_va_Auftragstamm.html:852 | FROZEN |
| Min-Breite | `min-width: 380px;` | frm_va_Auftragstamm.html:853 | FROZEN |
| Max-Breite | `max-width: 480px;` | frm_va_Auftragstamm.html:854 | FROZEN |

**Tabellenstil (auftraege-table):**
| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Schriftgroesse | `font-size: var(--base-font-size);` (11px) | frm_va_Auftragstamm.html:941 | FROZEN |
| Schriftgewicht | `font-weight: normal;` | frm_va_Auftragstamm.html:962 | FROZEN |
| Zellenhoehe | `height: 20px;` | frm_va_Auftragstamm.html:961 | FROZEN |
| Padding | `padding: 2px 4px;` | frm_va_Auftragstamm.html:958 | FROZEN |

**Spalten:**
- Datum
- Auftrag (+ Tag-Info bei mehrtaegigen)
- Ort

---

### 1.3 Sidebar

| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Sidebar-Breite | `width: 182px;` | shell.html:31 | FROZEN |
| Menu-Schrift | `font-weight: bold;` | shell.html:86 | FROZEN |

**Eingabefelder (+50px = 210px gesamt):**
| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| input-wide | `width: 210px;` | frm_va_Auftragstamm.html:536 | FROZEN |
| input-medium | `width: 160px;` | frm_va_Auftragstamm.html:535 | FROZEN |
| input-narrow | `width: 80px;` | frm_va_Auftragstamm.html:534 | FROZEN |

---

### 1.4 Header

| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Titel-Schriftgroesse | `--title-font-size: 23px;` | frm_va_Auftragstamm.html:21 | FROZEN |
| Title-Bar | `display: none;` (ausgeblendet) | frm_va_Auftragstamm.html:47-48 | FROZEN |
| Header-Hintergrund | `background-color: #8080c0;` | frm_va_Auftragstamm.html:234 | FROZEN |

---

### 1.5 Veranstalter-Regeln

**JS-Logik in:** `frm_va_Auftragstamm.logic.js:1223-1300`

| Veranstalter_ID | Regel | Status |
|-----------------|-------|--------|
| 20760 | BWN-Buttons sichtbar (btn_BWN_Druck, cmd_BWN_send, cmd_Messezettel_NameEintragen) | FROZEN |
| 20750 | EL/PKW Spalten ausgeblendet | FROZEN |
| 20760 | RE-Spalte sichtbar (nur bei diesem Veranstalter) | FROZEN |

**Code-Referenz:**
```javascript
// frm_va_Auftragstamm.logic.js:1223-1250
function applyVeranstalterRules(value) {
    const veranstalterId = Number(value || 0);
    const isMesse = veranstalterId === 20760;
    const isSpecialClient = veranstalterId === 20750;

    setVisible('cmd_Messezettel_NameEintragen', isMesse);
    setVisible('cmd_BWN_send', isMesse);
    setVisible('btn_BWN_Druck', isMesse);
    // ...
}

// frm_va_Auftragstamm.logic.js:1257-1300
function applyGridZuordnungenColumnRules(veranstalterId) {
    // EL und PKW: unsichtbar wenn Veranstalter_ID = 20750
    // RE: NUR sichtbar wenn Veranstalter_ID = 20760
}
```

---

### 1.6 Auto-Load

| Feature | Beschreibung | Datei:Zeile | Status |
|---------|--------------|-------------|--------|
| Erster Auftrag | Erster Auftrag ab heute aufsteigend | frm_va_Auftragstamm.logic.js:335-346 | FROZEN |
| Sortierung | ASC wenn datum_ab gesetzt | api_server.py (siehe STAND) | FROZEN |
| Filter | Automatisch auf heutiges Datum | frm_va_Auftragstamm.logic.js:590-596 | FROZEN |

**Code-Referenz:**
```javascript
// frm_va_Auftragstamm.logic.js:335-346
async function loadInitialData() {
    await loadCombos();
    setAuftraegeFilterToday(); // Setzt Filter auf heute
}

// frm_va_Auftragstamm.logic.js:590-596
function setAuftraegeFilterToday() {
    const datumInput = document.getElementById('Auftraege_ab');
    if (datumInput) {
        datumInput.value = formatDate(new Date());
        applyAuftraegeFilter();
    }
}
```

---

### 1.7 Combo-Laden (Datalist-Fix)

| Feature | Beschreibung | Datei:Zeile | Status |
|---------|--------------|-------------|--------|
| fillCombo-Funktion | Unterstuetzt sowohl SELECT als auch INPUT+DATALIST | frm_va_Auftragstamm.logic.js:380-410 | FROZEN |

**Code-Referenz:**
```javascript
// frm_va_Auftragstamm.logic.js:380-410
function fillCombo(comboId, data, valueField, textField) {
    const combo = document.getElementById(comboId);
    if (!combo || !data) return;

    // Datalist-Input (input mit list-Attribut)?
    if (combo.tagName === 'INPUT' && combo.list) {
        const datalist = combo.list;
        datalist.innerHTML = '';
        data.forEach(item => {
            const opt = document.createElement('option');
            opt.value = item[textField] || '';
            datalist.appendChild(opt);
        });
        return;
    }
    // ... normales Select-Element
}
```

---

### 1.8 Schichten-Tabelle

| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Anz-Spalte | `width: 28px; text-align: right;` | frm_va_Auftragstamm.html:1346 | FROZEN |
| von-Spalte | `width: 49px; text-align: center;` | frm_va_Auftragstamm.html:1347 | FROZEN |
| bis-Spalte | `width: 49px; text-align: center;` | frm_va_Auftragstamm.html:1348 | FROZEN |
| Input-Hintergrund | `background: transparent;` | frm_va_Auftragstamm.html:817 | FROZEN |

---

## 2. MITARBEITERSTAMM (frm_MA_Mitarbeiterstamm.html)

### 2.1 Auto-Load

| Feature | Beschreibung | Status |
|---------|--------------|--------|
| Erster MA | Erster Mitarbeiter alphabetisch geladen | FROZEN |

### 2.2 Row-Click

| Feature | Beschreibung | Status |
|---------|--------------|--------|
| MA laden | Klick auf Zeile laedt Mitarbeiter-Details | FROZEN |

### 2.3 Header

| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Titel-Schriftgroesse | `font-size: 23px !important;` | frm_MA_Mitarbeiterstamm.html:209 | FROZEN |
| Title-Bar | `display: none;` | frm_MA_Mitarbeiterstamm.html:30 | FROZEN |

---

## 3. KUNDENSTAMM (frm_KD_Kundenstamm.html)

| Feature | Beschreibung | Status |
|---------|--------------|--------|
| Row-Click | Klick auf Zeile laedt Kunden-Details | FROZEN |
| Auto-Load | Erster Kunde automatisch geladen | FROZEN |

---

## 4. OBJEKTSTAMM (frm_OB_Objekt.html)

| Feature | Beschreibung | Status |
|---------|--------------|--------|
| Row-Click | Klick auf Zeile laedt Objekt-Details | FROZEN |
| Auto-Load | Erstes Objekt automatisch geladen | FROZEN |
| Positionen laden | Objekt-Positionen werden geladen | FROZEN |

---

## 5. SHELL (shell.html)

### 5.1 Sidebar

| Feature | CSS/JS Wert | Datei:Zeile | Status |
|---------|-------------|-------------|--------|
| Breite | `width: 182px;` | shell.html:31 | FROZEN |
| Hintergrund | `background-color: #6060a0;` | shell.html:32 | FROZEN |
| Border | `border-right: 2px solid #404080;` | shell.html:36 | FROZEN |
| Menu-Schrift | `font-weight: bold;` | shell.html:86 | FROZEN |
| Button-Groesse | `font-size: 11px;` | shell.html:84 | FROZEN |

### 5.2 FORM_TITLES Mapping

| Form | Titel | Status |
|------|-------|--------|
| frm_N_Dienstplanuebersicht | Dienstplanuebersicht | FROZEN |
| frm_VA_Planungsuebersicht | Planungsuebersicht | FROZEN |
| frm_va_Auftragstamm | Auftragsverwaltung | FROZEN |
| frm_MA_Mitarbeiterstamm | Mitarbeiterstamm | FROZEN |
| frm_KD_Kundenstamm | Kundenstamm | FROZEN |
| frm_OB_Objekt | Objektverwaltung | FROZEN |
| frm_MA_Zeitkonten | Zeitkonten | FROZEN |
| frm_N_Stundenauswertung | Stundenauswertung | FROZEN |
| frm_MA_Abwesenheit | Abwesenheiten | FROZEN |
| frm_N_Lohnabrechnungen | Lohnabrechnungen | FROZEN |
| frm_MA_VA_Schnellauswahl | Schnellauswahl | FROZEN |
| frm_Einsatzuebersicht | Einsatzuebersicht | FROZEN |

---

## 6. CSS-VARIABLEN (GLOBAL)

| Variable | Wert | Verwendung | Status |
|----------|------|------------|--------|
| --base-font-size | 11px | Basis-Schriftgroesse | FROZEN |
| --small-font-size | 10px | Kleine Schrift | FROZEN |
| --header-font-size | 12px | Header-Schrift | FROZEN |
| --title-font-size | 23px | Formular-Titel (+8px) | FROZEN |

**Definiert in:** `frm_va_Auftragstamm.html:17-22`

---

## AENDERUNGSPROTOKOLL

| Datum | Aenderung | Genehmigt |
|-------|-----------|-----------|
| 2026-01-09 | Baseline erstellt | - |

---

**WICHTIG:** Vor jeder Aenderung an einem FROZEN Feature:
1. Diese Datei konsultieren
2. Explizite Anweisung von Guenther einholen
3. Aenderung im Aenderungsprotokoll dokumentieren
