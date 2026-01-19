# HTML-Struktur Korrekturen - Detaillierte Anleitung

**Stand:** 01.01.2026
**Basis:** HTML_STRUCTURE_AUDIT.md

---

## Übersicht

| Priorität | Anzahl | Aufwand | Status |
|-----------|--------|---------|--------|
| HIGH | 3 | ~4h | ⏳ Offen |
| MEDIUM | 2 | ~2h | ⏳ Offen |
| LOW | 1 | ~1h | ⏳ Offen |

---

## HIGH PRIORITY

### 1. frm_MA_Abwesenheit.html - Vollständige Überarbeitung

**Problem:** Komplett abweichende Struktur mit externen CSS-Dateien

**Dateien betroffen:**
- `04_HTML_Forms/forms/frm_MA_Abwesenheit.html`
- `04_HTML_Forms/forms/styles/frm_MA_Abwesenheit.css`

#### Schritt 1: CSS inline verschieben

**VORHER (Zeilen 7-11):**
```html
<link rel="stylesheet" href="../css/design-system.css">
<link rel="stylesheet" href="../css/app-layout.css">
<link rel="stylesheet" href="../theme/consys_theme.css">
<link rel="stylesheet" href="styles/frm_MA_Abwesenheit.css">
```

**NACHHER:**
```html
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        font-size: 11px;
    }

    body {
        background-color: #8080c0;
        overflow: hidden;
        height: 100vh;
    }

    .window-frame {
        background-color: #8080c0;
        height: 100vh;
        display: flex;
        flex-direction: column;
    }

    /* Title Bar */
    .title-bar {
        background: linear-gradient(to right, #000080, #1084d0);
        color: white;
        padding: 2px 5px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        height: 22px;
        flex-shrink: 0;
    }

    /* ... REST DES CSS AUS EXTERNEN DATEIEN ... */
</style>
```

#### Schritt 2: Klassen umstellen

**VORHER:**
```html
<body>
    <div class="app-container">
        <aside class="app-sidebar">...</aside>
        <main class="app-main">...</main>
    </div>
</body>
```

**NACHHER:**
```html
<body data-active-menu="abwesenheit">
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
    </div>

    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <div class="window-frame">
        <!-- Title Bar -->
        <div class="title-bar">
            <div class="title-bar-left">
                <span>&#128197;</span>
                <span>Abwesenheitsplanung</span>
            </div>
            <div class="title-bar-buttons">
                <button class="title-btn" onclick="Bridge.sendEvent('minimize')">_</button>
                <button class="title-btn">&#9633;</button>
                <button class="title-btn close" onclick="closeForm()">&#10005;</button>
            </div>
        </div>

        <!-- Main Container -->
        <div class="main-container">
            <!-- Left Menu -->
            <div class="left-menu">
                <div class="menu-header">HAUPTMENU</div>
                <div class="menu-buttons">
                    <!-- ... Menu Items ... -->
                </div>
            </div>

            <!-- Content Area -->
            <div class="content-area">
                <!-- ... Content ... -->
            </div>
        </div>
    </div>
</body>
```

#### Schritt 3: Script inline verschieben

**VORHER (Zeilen 164-165):**
```html
<script type="module" src="../js/sidebar.js"></script>
<script type="module" src="logic/frm_MA_Abwesenheit.logic.js"></script>
```

**NACHHER:**
```html
<script src="../js/webview2-bridge.js"></script>

<script>
    'use strict';

    const API_BASE = 'http://localhost:5000/api';

    // State
    const state = {
        mitarbeiterList: [],
        abwesenheitenList: [],
        currentMA_ID: null
    };

    // ============================================
    // INITIALISIERUNG
    // ============================================
    document.addEventListener('DOMContentLoaded', async function() {
        document.getElementById('lblDatum').textContent = formatDate(new Date());

        // Load Mitarbeiter
        await loadMitarbeiter();

        // Event Handlers
        document.getElementById('cboMitarbeiter').addEventListener('change', onMitarbeiterChange);
        document.getElementById('btnUebernehmen').addEventListener('click', uebernehmen);
        document.getElementById('radGanztaegig').addEventListener('change', onZeitartChange);
        document.getElementById('radStundenweise').addEventListener('change', onZeitartChange);

        // Bridge Events
        Bridge.on('onDataReceived', function(data) {
            if (data.ma_id) {
                loadAbwesenheiten(data.ma_id);
            }
        });

        hideLoading();
    });

    // ============================================
    // API FUNCTIONS
    // ============================================
    async function apiCall(endpoint, method = 'GET', data = null) {
        // ... wie in anderen Formularen ...
    }

    async function loadMitarbeiter() {
        // ... Implementation ...
    }

    async function loadAbwesenheiten(ma_id) {
        // ... Implementation ...
    }

    // ============================================
    // UI FUNCTIONS
    // ============================================
    function onMitarbeiterChange() {
        // ... Implementation ...
    }

    function onZeitartChange() {
        const stundenweise = document.getElementById('radStundenweise').checked;
        document.getElementById('txtZeitVon').disabled = !stundenweise;
        document.getElementById('txtZeitBis').disabled = !stundenweise;
    }

    function uebernehmen() {
        // ... Implementation ...
    }

    // ============================================
    // HELPER FUNCTIONS
    // ============================================
    function formatDate(date) {
        if (!date) return '';
        const d = new Date(date);
        return d.toLocaleDateString('de-DE');
    }

    function showLoading() {
        document.getElementById('loadingOverlay').classList.add('active');
    }

    function hideLoading() {
        document.getElementById('loadingOverlay').classList.remove('active');
    }

    function showToast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = 'toast ' + type;
        toast.textContent = message;
        container.appendChild(toast);
        setTimeout(() => toast.remove(), 3000);
    }

    function closeForm() {
        Bridge.close();
        if (!window.chrome || !window.chrome.webview) {
            window.close();
        }
    }

    console.log('[Abwesenheitsplanung] Script geladen');
</script>
```

**Aufwand:** ~2h
**Risiko:** Mittel (Funktionalität aus .logic.js muss portiert werden)

---

### 2. Formulare ohne Loading/Toast - Komponenten ergänzen

**Betroffene Formulare (vermutlich 6):**
- frm_N_Dienstplanuebersicht.html
- frm_VA_Planungsuebersicht.html
- frm_N_MA_VA_Schnellauswahl.html
- frm_N_Stundenauswertung.html
- frm_DP_Dienstplan_MA.html
- frm_DP_Dienstplan_Objekt.html

#### Schritt 1: Loading Overlay ergänzen

**Position:** Direkt nach `<body>` Tag

```html
<body data-active-menu="[key]">
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
    </div>

    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <div class="window-frame">
        <!-- ... Rest ... -->
    </div>
</body>
```

#### Schritt 2: CSS ergänzen

**Position:** Im `<style>` Block

```css
/* Loading Overlay */
.loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(128, 128, 192, 0.8);
    display: none;
    justify-content: center;
    align-items: center;
    z-index: 1000;
}

.loading-overlay.active {
    display: flex;
}

.loading-spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #fff;
    border-top-color: #000080;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

/* Toast */
.toast-container {
    position: fixed;
    top: 30px;
    right: 10px;
    z-index: 1002;
}

.toast {
    background: #333;
    color: white;
    padding: 10px 20px;
    margin-bottom: 5px;
    border-radius: 4px;
    animation: slideIn 0.3s ease;
}

.toast.success { background: #2e7d32; }
.toast.error { background: #c62828; }
.toast.warning { background: #f57f17; }

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}
```

#### Schritt 3: JavaScript-Funktionen ergänzen

**Position:** Im `<script>` Block

```javascript
function showLoading() {
    document.getElementById('loadingOverlay').classList.add('active');
}

function hideLoading() {
    document.getElementById('loadingOverlay').classList.remove('active');
}

function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}
```

**Aufwand pro Formular:** ~15 Min
**Gesamt:** ~1.5h
**Risiko:** Niedrig (rein additiv)

---

### 3. frm_OB_Objekt.html - Toast Container statt Single DIV

**Problem:** Verwendet einzelnes Toast-DIV statt Container

#### Schritt 1: HTML anpassen

**VORHER (Zeile 866):**
```html
<!-- Toast Notification -->
<div class="toast" id="toast"></div>
```

**NACHHER:**
```html
<!-- Toast Container -->
<div class="toast-container" id="toastContainer"></div>
```

#### Schritt 2: CSS anpassen

**VORHER (Zeilen 583-609):**
```css
/* Toast Notification */
.toast {
    position: fixed;
    bottom: 60px;
    right: 20px;
    background: #000080;
    color: white;
    padding: 10px 20px;
    border: 2px solid;
    border-color: #4040a0 #000040 #000040 #4040a0;
    z-index: 1001;
    display: none;
    font-size: 11px;
}

.toast.success {
    background: #308030;
    border-color: #60c060 #205020 #205020 #60c060;
}

.toast.error {
    background: #c04040;
    border-color: #e06060 #802020 #802020 #e06060;
}

.toast.show {
    display: block;
}
```

**NACHHER:**
```css
/* Toast Container */
.toast-container {
    position: fixed;
    top: 30px;
    right: 10px;
    z-index: 1002;
}

.toast {
    background: #333;
    color: white;
    padding: 10px 20px;
    margin-bottom: 5px;
    border-radius: 4px;
    animation: slideIn 0.3s ease;
}

.toast.success { background: #2e7d32; }
.toast.error { background: #c62828; }
.toast.warning { background: #f57f17; }

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}
```

#### Schritt 3: JavaScript anpassen

**VORHER (Zeilen 1450-1458):**
```javascript
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast show ${type}`;

    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}
```

**NACHHER:**
```javascript
function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}
```

**Aufwand:** ~15 Min
**Risiko:** Niedrig (nur UI-Änderung)

---

## MEDIUM PRIORITY

### 4. Logic.js Entscheidung - Entweder ALLE inline ODER ALLE in .logic.js

**Betroffene Formulare:**
- frm_MA_Abwesenheit.html (hat .logic.js)
- frm_va_Auftragstamm.html (hat .logic.js)
- Weitere 2-3 Formulare

#### Option A: ALLE inline verschieben (EMPFOHLEN)

**Vorteile:**
- Self-contained HTML-Dateien
- Einfachere Distribution
- Keine zusätzlichen HTTP-Requests
- Konsistent mit Referenz-Formularen

**Nachteile:**
- Größere HTML-Dateien
- Schwieriger zu debuggen (keine Source Maps)

**Vorgehen:**
1. Inhalt von .logic.js in `<script>` Block kopieren
2. `export` Statements entfernen
3. `import` Statements entfernen
4. Module-Type aus Script-Tag entfernen
5. .logic.js Datei löschen (optional archivieren)

#### Option B: ALLE auf .logic.js umstellen

**Vorteile:**
- Saubere Trennung HTML/Logic
- Bessere IDE-Unterstützung
- Einfacheres Testing (Module können isoliert getestet werden)
- Wiederverwendbare Module möglich

**Nachteile:**
- Zusätzliche Dateien zu verwalten
- Zusätzliche HTTP-Requests
- Mehr Overhead bei kleinen Formularen

**Vorgehen:**
1. Logic aus `<script>` Block in neue .logic.js Datei extrahieren
2. `export` für relevante Funktionen hinzufügen
3. `<script type="module" src="logic/[formular].logic.js">` einbinden
4. Gemeinsame Funktionen in shared-utils.js auslagern

**Empfehlung:** Option A (ALLE inline) für Konsistenz mit bestehenden Referenz-Formularen

**Aufwand:** ~2h (alle Formulare)
**Risiko:** Mittel (Tests erforderlich)

---

### 5. Klassen-Konventionen vereinheitlichen

**Problem:** Mischung aus `.app-*` und Standard-Klassen

**Betroffene Formulare:**
- frm_MA_Abwesenheit.html
- Vermutlich weitere moderne Layouts

#### Mapping

| Alt (app-*) | Neu (Standard) |
|-------------|----------------|
| `.app-container` | `.window-frame` |
| `.app-sidebar` | `.left-menu` |
| `.app-main` | `.content-area` |
| `.sidebar-header` | `.menu-header` |
| `.sidebar-menu` | `.menu-buttons` |
| `.sidebar-btn` | `.menu-btn` |

**Vorgehen:**
1. CSS: Alle `.app-*` zu Standard umbenennen
2. HTML: Alle Klassen-Referenzen anpassen
3. JavaScript: Selektoren anpassen (falls vorhanden)

**Aufwand pro Formular:** ~30 Min
**Gesamt:** ~1h
**Risiko:** Niedrig (nur Umbenennungen)

---

## LOW PRIORITY

### 6. Semantisches HTML verbessern

**Problem:** Zu viele generische `<div>` Tags

#### Beispiel-Verbesserungen

**VORHER:**
```html
<div class="left-menu">
    <div class="menu-header">HAUPTMENU</div>
    <div class="menu-buttons">
        <button class="menu-btn">Item 1</button>
        <button class="menu-btn">Item 2</button>
    </div>
</div>
```

**NACHHER:**
```html
<aside class="left-menu">
    <header class="menu-header">HAUPTMENU</header>
    <nav class="menu-buttons">
        <button class="menu-btn">Item 1</button>
        <button class="menu-btn">Item 2</button>
    </nav>
</aside>
```

**VORHER:**
```html
<div class="content-area">
    <div class="header-row">...</div>
    <div class="work-area">...</div>
    <div class="status-bar">...</div>
</div>
```

**NACHHER:**
```html
<main class="content-area">
    <header class="header-row">...</header>
    <section class="work-area">...</section>
    <footer class="status-bar">...</footer>
</main>
```

#### Accessibility ergänzen

```html
<!-- ARIA Labels -->
<button class="title-btn" onclick="Bridge.sendEvent('minimize')" aria-label="Minimieren">_</button>
<button class="title-btn close" onclick="closeForm()" aria-label="Schließen">&#10005;</button>

<!-- Role Attributes -->
<nav class="menu-buttons" role="navigation">...</nav>
<main class="content-area" role="main">...</main>
```

**Aufwand:** ~1h (schrittweise)
**Risiko:** Niedrig (falls CSS korrekt)

---

## Zusammenfassung Gesamt-Aufwand

| Task | Aufwand | Formulare | Gesamt |
|------|---------|-----------|--------|
| 1. frm_MA_Abwesenheit überarbeiten | 2h | 1 | 2h |
| 2. Loading/Toast ergänzen | 15 Min | 6 | 1.5h |
| 3. Toast Container (OB_Objekt) | 15 Min | 1 | 0.25h |
| 4. Logic.js Entscheidung | 30 Min | 4 | 2h |
| 5. Klassen vereinheitlichen | 30 Min | 2 | 1h |
| 6. Semantisches HTML | 1h | Alle | 1h |
| **TOTAL** | - | - | **~8h** |

---

## Nächste Schritte

1. ✅ Korrekturen dokumentiert
2. ⏳ Entscheidungen treffen:
   - CSS inline ODER extern für ALLE?
   - Logic inline ODER .logic.js für ALLE?
3. ⏳ HIGH PRIORITY Korrekturen durchführen
4. ⏳ Tests nach jeder Korrektur
5. ⏳ MEDIUM PRIORITY Korrekturen
6. ⏳ LOW PRIORITY schrittweise
