# GAP-ANALYSE: frm_DP_Einzeldienstplaene

**Erstellt:** 2026-01-12
**Status:** ⚠️ **NUR PLACEHOLDER** - Keine funktionale Implementierung
**Access-Export:** ❌ Nicht verfügbar (nicht im JSON-Export 11/25)

---

## 🔴 KRITISCHE FESTSTELLUNG

Das HTML-Formular ist **nur ein Platzhalter** ohne jegliche Funktionalität:
- Zeigt nur eine Meldung "Diese Ansicht wird noch implementiert"
- Keine Controls, keine Daten, keine Logik
- Wird von `frm_DP_Dienstplan_MA.html` aufgerufen, wenn User auf "Einzeldienstpläne" klickt

---

## 1. AKTUELLER STAND HTML

### 1.1 Datei-Informationen
- **HTML:** `04_HTML_Forms\forms3\frm_DP_Einzeldienstplaene.html`
- **Logic-JS:** ❌ Nicht vorhanden
- **WebView2-Bridge:** ❌ Nicht vorhanden
- **Größe:** 43 Zeilen (nur Placeholder)
- **Encoding:** ✅ UTF-8 mit BOM

### 1.2 Implementierter Content
```html
<body data-form="frm_DP_Einzeldienstplaene">
    <div class="placeholder-container">
        <div class="placeholder-icon">📋</div>
        <div class="placeholder-title">Einzeldienstpläne</div>
        <div class="placeholder-text">Diese Ansicht wird noch implementiert.</div>
        <div class="placeholder-params" id="params"></div>
    </div>
    <script>
        // Parse URL parameters
        const params = new URLSearchParams(window.location.search);
        // Display parameters
    </script>
</body>
```

### 1.3 Features
✅ **Vorhanden:**
- UTF-8 Encoding
- Placeholder-Design mit Icon
- URL-Parameter-Parsing (start-Datum)
- Visuell konsistent (Hintergrund #8080c0)

❌ **Fehlend:**
- Alle Dienstplan-Features
- Datenanbindung
- Controls
- Navigation
- Filter/Suche
- Export-Funktionen

---

## 2. ERWARTETE FUNKTIONALITÄT (GESCHÄTZT)

Da kein Access-Export vorliegt, Schätzung basierend auf:
1. Formularname "Einzeldienstpläne" (Plural)
2. Aufruf aus `frm_DP_Dienstplan_MA` mit Start-Datum
3. Typische Features von Dienstplan-Druck/Export-Formularen

### 2.1 Vermutete Hauptfunktionen

#### A) Mitarbeiter-Auswahl
- **Liste aller Mitarbeiter** mit Checkboxen
- Filter: Aktive MA, Abteilung, Qualifikation
- "Alle auswählen" / "Alle abwählen" Buttons

#### B) Zeitraum-Einstellung
- **Von-Datum / Bis-Datum** Picker
- Vorlagen: "Diese Woche", "Dieser Monat", "Nächste 14 Tage"
- Oder: Einzelner Tag für alle MA

#### C) Format-Optionen
- **Druckformat:** A4 Hochformat/Querformat
- **Detail-Level:** Kompakt / Ausführlich
- **Gruppierung:** Pro Mitarbeiter / Pro Tag
- **Sortierung:** Nach Name / Nach Einsatzzeit

#### D) Filteroptionen
- Nur Einsätze mit Zuordnung
- Nur bestätigte Einsätze
- Objekt-Filter
- Kunde-Filter

#### E) Vorschau & Export
- **Vorschau-Bereich** mit Print-Layout
- **Drucken-Button** → native Print-Dialog
- **PDF-Export** (via Browser oder API)
- **Excel-Export** (falls wie andere Formulare)

---

## 3. VERGLEICH MIT ÄHNLICHEN FORMULAREN

### 3.1 frm_N_Dienstplanuebersicht.html (als Referenz)
**Funktionen:**
- Wochen-Kalenderansicht (Mo-So)
- Navigation: Vorwoche/Nachwoche/Heute
- Kalender-Grid mit Zeitachse (6-22 Uhr)
- Einsätze als Blöcke im Grid
- Filter: Ansicht, Objekt, Status
- Detail-Panel bei Klick auf Einsatz
- Export-Funktionen

**Ähnlichkeiten zu erwarteten Features:**
- Beide sind Dienstplan-Übersichtsformulare
- Beide benötigen MA-Liste
- Beide zeigen Zeitraum an
- Beide haben Filter

**Unterschiede:**
- Dienstplanübersicht: **Interaktive Kalenderansicht**
- Einzeldienstpläne: **Druckbare Einzelblätter pro MA**

### 3.2 frm_DP_Dienstplan_MA.html (Aufrufendes Formular)
**Aufruf-Context:**
```javascript
function openEinzeldienstplaene() {
    const startDatum = formatDateForInput(state.startDate);
    const url = `frm_DP_Einzeldienstplaene.html?start=${startDatum}`;
    window.open(url, 'Einzeldienstplaene', 'width=800,height=600,...');
}
```

**Übergabewerte:**
- `start`: Start-Datum (ISO-Format YYYY-MM-DD)

**Erwarteter Workflow:**
1. User ist im Dienstplan-MA Formular
2. Klickt auf "Einzeldienstpläne" Button
3. Neues Fenster öffnet sich → frm_DP_Einzeldienstplaene.html
4. Voreingestelltes Start-Datum aus Parent-Formular
5. User wählt MA, Zeitraum, Format
6. User druckt/exportiert

---

## 4. DETAILLIERTE GAP-LISTE

### 4.1 STRUKTUR
| Feature | Access | HTML | Status | Priorität |
|---------|--------|------|--------|-----------|
| Hauptformular | ❓ | ✅ Placeholder | 🔴 | Hoch |
| Header-Bereich | ❓ | ❌ | 🔴 | Hoch |
| Filter-Bereich | ❓ | ❌ | 🔴 | Hoch |
| Vorschau-Bereich | ❓ | ❌ | 🔴 | Mittel |
| Button-Leiste | ❓ | ❌ | 🔴 | Hoch |
| Status-Bar | ❓ | ❌ | 🟡 | Niedrig |

### 4.2 CONTROLS (GESCHÄTZT)
| Control | Typ | Access | HTML | Gap |
|---------|-----|--------|------|-----|
| **Mitarbeiter-Auswahl** |
| lstMitarbeiter | ListBox (Multi-Select) | ❓ | ❌ | 🔴 |
| btnAlleAuswaehlen | Button | ❓ | ❌ | 🔴 |
| btnKeineAuswaehlen | Button | ❓ | ❌ | 🔴 |
| txtSuche | TextBox | ❓ | ❌ | 🟡 |
| **Zeitraum** |
| dtVon | Date Picker | ❓ | ❌ | 🔴 |
| dtBis | Date Picker | ❓ | ❌ | 🔴 |
| cboZeitraumVorlage | ComboBox | ❓ | ❌ | 🟡 |
| **Format** |
| optFormatA4Hoch | OptionButton | ❓ | ❌ | 🟡 |
| optFormatA4Quer | OptionButton | ❓ | ❌ | 🟡 |
| cboDetailLevel | ComboBox | ❓ | ❌ | 🟡 |
| **Filter** |
| chkNurBestaetigte | CheckBox | ❓ | ❌ | 🟡 |
| cboObjekt | ComboBox | ❓ | ❌ | 🟡 |
| cboKunde | ComboBox | ❓ | ❌ | 🟡 |
| **Vorschau** |
| pnlVorschau | Panel/Div | ❓ | ❌ | 🔴 |
| **Aktionen** |
| btnVorschau | Button | ❓ | ❌ | 🔴 |
| btnDrucken | Button | ❓ | ❌ | 🔴 |
| btnPDF | Button | ❓ | ❌ | 🟡 |
| btnExcel | Button | ❓ | ❌ | 🟡 |
| btnSchliessen | Button | ❓ | ❌ | 🔴 |

### 4.3 LOGIK (GESCHÄTZT)
| Feature | Access | HTML | Gap |
|---------|--------|------|-----|
| **Daten laden** |
| MA-Liste laden | ❓ | ❌ | 🔴 |
| Dienstplan-Daten laden | ❓ | ❌ | 🔴 |
| Objekt-Liste laden | ❓ | ❌ | 🟡 |
| Kunden-Liste laden | ❓ | ❌ | 🟡 |
| **Filter/Suche** |
| MA-Suche (Name) | ❓ | ❌ | 🟡 |
| Zeitraum-Filter | ❓ | ❌ | 🔴 |
| Status-Filter | ❓ | ❌ | 🟡 |
| **Vorschau** |
| Dienstplan-Rendering | ❓ | ❌ | 🔴 |
| Pro-MA Layout | ❓ | ❌ | 🔴 |
| Paginierung | ❓ | ❌ | 🟡 |
| **Export** |
| Drucken (Browser) | ❓ | ❌ | 🔴 |
| PDF-Export | ❓ | ❌ | 🟡 |
| Excel-Export | ❓ | ❌ | 🟡 |

### 4.4 API-ENDPOINTS (BENÖTIGT)
| Endpoint | Methode | Parameter | Status |
|----------|---------|-----------|--------|
| `/api/mitarbeiter` | GET | aktiv=1, sort=nachname | ✅ Vorhanden |
| `/api/dienstplan/einzelplaene` | POST | ma_ids, von, bis | ❌ Fehlt |
| `/api/dienstplan/export/pdf` | POST | ma_ids, von, bis, format | ❌ Fehlt |
| `/api/objekte` | GET | aktiv=1 | ✅ Vorhanden |
| `/api/kunden` | GET | aktiv=1 | ✅ Vorhanden |

---

## 5. IMPLEMENTIERUNGS-VORSCHLAG

### Phase 1: GRUNDSTRUKTUR (2-3h)
```html
<body>
    <div class="form-container">
        <!-- Header -->
        <div class="form-header">
            <h2>Einzeldienstpläne erstellen</h2>
            <button id="btnSchliessen">✖</button>
        </div>

        <!-- Filter-Bereich (links) -->
        <div class="filter-panel">
            <!-- Mitarbeiter-Auswahl -->
            <div class="section">
                <h3>Mitarbeiter</h3>
                <input type="search" id="txtSuche" placeholder="Suche...">
                <select id="lstMitarbeiter" multiple size="15"></select>
                <button id="btnAlleAuswaehlen">Alle</button>
                <button id="btnKeineAuswaehlen">Keine</button>
            </div>

            <!-- Zeitraum -->
            <div class="section">
                <h3>Zeitraum</h3>
                <label>Von: <input type="date" id="dtVon"></label>
                <label>Bis: <input type="date" id="dtBis"></label>
                <select id="cboZeitraumVorlage">
                    <option value="">Vorlage wählen...</option>
                    <option value="week">Diese Woche</option>
                    <option value="month">Dieser Monat</option>
                    <option value="14days">Nächste 14 Tage</option>
                </select>
            </div>

            <!-- Format -->
            <div class="section">
                <h3>Format</h3>
                <label><input type="radio" name="format" value="compact" checked> Kompakt</label>
                <label><input type="radio" name="format" value="detailed"> Ausführlich</label>
            </div>

            <!-- Filter -->
            <div class="section">
                <h3>Filter</h3>
                <label><input type="checkbox" id="chkNurBestaetigte"> Nur bestätigte</label>
                <label>Objekt: <select id="cboObjekt"></select></label>
            </div>

            <!-- Aktionen -->
            <div class="actions">
                <button id="btnVorschau" class="primary">Vorschau</button>
                <button id="btnDrucken">Drucken</button>
                <button id="btnExcel">Excel</button>
            </div>
        </div>

        <!-- Vorschau-Bereich (rechts) -->
        <div class="preview-panel">
            <div id="pnlVorschau" class="preview-content">
                <!-- Dienstplan-Seiten werden hier gerendert -->
            </div>
        </div>

        <!-- Status -->
        <div class="form-footer">
            <span id="lblStatus">Bereit</span>
        </div>
    </div>
</body>
```

### Phase 2: CSS LAYOUT (1h)
```css
.form-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
}

.form-header {
    display: flex;
    justify-content: space-between;
    padding: 12px 20px;
    background: #000080;
    color: white;
}

.form-container > div:nth-child(2) {
    display: flex;
    flex: 1;
    overflow: hidden;
}

.filter-panel {
    width: 300px;
    background: #f0f0f0;
    padding: 15px;
    overflow-y: auto;
    border-right: 1px solid #ccc;
}

.preview-panel {
    flex: 1;
    background: white;
    overflow-y: auto;
    padding: 20px;
}

#lstMitarbeiter {
    width: 100%;
    height: 300px;
}

.section {
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #ddd;
}

.actions {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.actions button {
    padding: 8px 12px;
}
```

### Phase 3: JAVASCRIPT LOGIK (4-5h)

**Datei:** `logic/frm_DP_Einzeldienstplaene.logic.js`

```javascript
// State
const state = {
    mitarbeiter: [],
    selectedMAIds: [],
    vonDatum: null,
    bisDatum: null,
    format: 'compact',
    filter: {
        nurBestaetigte: false,
        objektId: null
    }
};

// Init
async function init() {
    // Parse URL params
    const params = new URLSearchParams(window.location.search);
    const startDatum = params.get('start');

    // Set default dates
    state.vonDatum = startDatum || new Date().toISOString().split('T')[0];
    state.bisDatum = addDays(state.vonDatum, 7);

    document.getElementById('dtVon').value = state.vonDatum;
    document.getElementById('dtBis').value = state.bisDatum;

    // Load data
    await loadMitarbeiter();
    await loadObjekte();

    // Setup listeners
    setupEventListeners();
}

// Mitarbeiter laden
async function loadMitarbeiter() {
    const response = await fetch('http://localhost:5000/api/mitarbeiter?aktiv=1');
    state.mitarbeiter = await response.json();

    const lst = document.getElementById('lstMitarbeiter');
    lst.innerHTML = state.mitarbeiter
        .map(m => `<option value="${m.ID}">${m.Nachname}, ${m.Vorname}</option>`)
        .join('');
}

// Vorschau generieren
async function generatePreview() {
    const maIds = Array.from(document.getElementById('lstMitarbeiter').selectedOptions)
        .map(opt => parseInt(opt.value));

    if (maIds.length === 0) {
        alert('Bitte mindestens einen Mitarbeiter auswählen');
        return;
    }

    setStatus('Lade Dienstplandaten...');

    // Daten für jeden MA laden
    const plaene = [];
    for (const maId of maIds) {
        const response = await fetch(
            `http://localhost:5000/api/dienstplan/ma/${maId}?von=${state.vonDatum}&bis=${state.bisDatum}`
        );
        const daten = await response.json();
        plaene.push({ ma: state.mitarbeiter.find(m => m.ID === maId), daten });
    }

    // Vorschau rendern
    renderPreview(plaene);
    setStatus(`${plaene.length} Dienstpläne erstellt`);
}

// Vorschau rendern (pro MA eine Seite)
function renderPreview(plaene) {
    const container = document.getElementById('pnlVorschau');

    container.innerHTML = plaene.map((plan, index) => `
        <div class="dienstplan-page" data-ma-id="${plan.ma.ID}">
            <div class="page-header">
                <h3>Dienstplan: ${plan.ma.Vorname} ${plan.ma.Nachname}</h3>
                <p class="zeitraum">${formatDate(state.vonDatum)} - ${formatDate(state.bisDatum)}</p>
            </div>
            <table class="dienstplan-table">
                <thead>
                    <tr>
                        <th>Datum</th>
                        <th>Wochentag</th>
                        <th>Objekt</th>
                        <th>Von</th>
                        <th>Bis</th>
                        <th>Stunden</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    ${renderDienstplanRows(plan.daten)}
                </tbody>
            </table>
            ${index < plaene.length - 1 ? '<div class="page-break"></div>' : ''}
        </div>
    `).join('');
}

// Dienstplan-Zeilen
function renderDienstplanRows(daten) {
    if (!daten || daten.length === 0) {
        return '<tr><td colspan="7" class="no-data">Keine Einsätze im gewählten Zeitraum</td></tr>';
    }

    return daten.map(einsatz => `
        <tr>
            <td>${formatDate(einsatz.VADatum)}</td>
            <td>${getWeekday(einsatz.VADatum)}</td>
            <td>${einsatz.Objekt || '-'}</td>
            <td>${formatTime(einsatz.MVA_Start)}</td>
            <td>${formatTime(einsatz.MVA_Ende)}</td>
            <td>${calculateHours(einsatz.MVA_Start, einsatz.MVA_Ende)}</td>
            <td class="status status-${einsatz.VAStatus}">${einsatz.VAStatus}</td>
        </tr>
    `).join('');
}

// Drucken
function printDienstplaene() {
    window.print();
}

// Excel-Export
function exportExcel() {
    // CSV erstellen und downloaden
    const csv = generateCSV();
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `Einzeldienstplaene_${state.vonDatum}.csv`;
    link.click();
}
```

### Phase 4: PRINT STYLES (1h)
```css
@media print {
    .filter-panel,
    .form-header,
    .form-footer {
        display: none !important;
    }

    .preview-panel {
        padding: 0;
    }

    .page-break {
        page-break-after: always;
    }

    .dienstplan-page {
        page-break-inside: avoid;
    }

    .dienstplan-table {
        width: 100%;
        border-collapse: collapse;
    }

    .dienstplan-table th,
    .dienstplan-table td {
        border: 1px solid #000;
        padding: 4px 8px;
    }
}
```

---

## 6. GESCHÄTZTE KOMPLEXITÄT

### 6.1 Komponenten-Aufwand
| Komponente | Stunden | Schwierigkeit |
|------------|---------|---------------|
| HTML-Struktur | 2 | Mittel |
| CSS Layout + Print | 2 | Mittel |
| JavaScript Logik | 4 | Hoch |
| API-Integration | 2 | Mittel |
| Vorschau-Rendering | 3 | Hoch |
| Excel-Export | 2 | Mittel |
| Testing | 2 | Mittel |
| **GESAMT** | **17h** | - |

### 6.2 Risiken
🔴 **Hoch:**
- Keine Access-Referenz verfügbar → Features müssen geschätzt werden
- Dienstplan-Daten-Struktur könnte komplex sein
- Print-Layout für verschiedene MA-Mengen (1 vs. 50 MA)

🟡 **Mittel:**
- PDF-Export benötigt externe Library (z.B. jsPDF)
- Performance bei vielen MA / langen Zeiträumen
- Browser-Kompatibilität für Print-Styles

### 6.3 Abhängigkeiten
✅ **Vorhanden:**
- `/api/mitarbeiter` (GET)
- `/api/dienstplan/ma/:id` (GET mit von/bis)
- Basis-CSS (consys-common.css)

❌ **Fehlt:**
- Spezifischer Endpoint für "Einzeldienstpläne" (oder Verwendung bestehender Endpoints)
- PDF-Export-Funktion (falls gewünscht)

---

## 7. EMPFEHLUNGEN

### 7.1 Sofortmaßnahmen (Kritisch)
1. ✅ **Access-Export holen** (falls Formular in Access existiert)
   - Genaue Feature-Liste ermitteln
   - Control-Layout analysieren
   - VBA-Code für Button-Funktionen prüfen

2. 🔴 **Mindest-Implementierung** (falls Access-Export nicht verfügbar)
   - Basis-Version mit MA-Auswahl, Zeitraum, Drucken
   - Einfaches Tabellen-Layout
   - Browser-Print verwenden

3. 🔴 **API-Endpoint prüfen/erstellen**
   - Klären ob `/api/dienstplan/ma/:id` ausreicht
   - Oder neuer Endpoint `/api/dienstplan/einzelplaene` nötig

### 7.2 Mittelfristig
1. **PDF-Export** via jsPDF hinzufügen
2. **Vorlagen-System** (verschiedene Layouts)
3. **E-Mail-Versand** (Pläne direkt an MA senden)

### 7.3 Langfristig
1. **Template-Editor** (User kann Layout anpassen)
2. **Automatischer Versand** (Scheduler)
3. **Unterschriften-Feld** (für gedruckte Pläne)

---

## 8. ZUSAMMENFASSUNG

### 8.1 Status Quo
- ❌ **HTML:** Nur Placeholder, keine Funktionalität
- ❌ **Logic-JS:** Nicht vorhanden
- ❌ **Access-Export:** Nicht verfügbar
- ⚠️ **Implementierung:** 0% (keine echte Funktion)

### 8.2 Geschätzte Vollständigkeit
| Bereich | Access (geschätzt) | HTML | % Fertig |
|---------|-------------------|------|----------|
| Struktur | 100% | 5% | 5% |
| Controls | 100% | 0% | 0% |
| Logik | 100% | 0% | 0% |
| Design | 100% | 5% | 5% |
| API | 100% | 0% | 0% |
| **GESAMT** | **100%** | **2%** | **2%** |

### 8.3 Prioritäten für Implementierung
1. 🔴 **CRITICAL:** Access-Export beschaffen (falls vorhanden)
2. 🔴 **HIGH:** Basis-HTML mit MA-Auswahl + Zeitraum + Drucken
3. 🟡 **MEDIUM:** Vorschau-Rendering mit Tabellen-Layout
4. 🟡 **MEDIUM:** Excel-Export
5. 🟢 **LOW:** PDF-Export, erweiterte Formatierungen

---

## 9. NÄCHSTE SCHRITTE

### Schritt 1: KLÄRUNG (User-Input benötigt)
- [ ] Existiert dieses Formular in Access? Wenn ja, Export holen
- [ ] Falls nicht: Welche Features sind **Muss**, welche **Nice-to-have**?
- [ ] Welche Export-Formate sind wichtig? (Druck / PDF / Excel)

### Schritt 2: PLANUNG
- [ ] API-Endpoints definieren/testen
- [ ] Mockup des Layouts erstellen (Skizze/Wireframe)
- [ ] Datenstruktur für Dienstplan-Rendering festlegen

### Schritt 3: ENTWICKLUNG
- [ ] HTML-Struktur (Phase 1) - 2h
- [ ] CSS Layout (Phase 2) - 2h
- [ ] JavaScript Logik (Phase 3) - 4h
- [ ] Testing & Fixes - 2h

---

## 10. OFFENE FRAGEN

1. **Existiert dieses Formular in Access?** → Export beschaffen?
2. **Welche MA sollen vorausgewählt sein?** Alle? Nur aktive? Keiner?
3. **Default-Zeitraum?** Aktuelle Woche? Nächste 7 Tage? Übergabewert aus frm_DP_Dienstplan_MA?
4. **Druckformat:** Eine Seite pro MA oder alles auf einer langen Seite?
5. **Status-Filter:** Welche Status gibt es? (Geplant/Bestätigt/Abgesagt/...)
6. **Excel-Format:** Einfaches CSV oder formattiertes XLSX?
7. **E-Mail-Versand:** Gewünscht? Dann via VBA-Bridge wie bei anderen Formularen?

---

**FAZIT:**
Das Formular ist aktuell nur ein **leerer Platzhalter**. Ohne Access-Export muss die Funktionalität komplett neu entwickelt werden (ca. 17h). Es wird empfohlen, zunächst zu klären ob das Formular in Access existiert und welche Features Priorität haben.
