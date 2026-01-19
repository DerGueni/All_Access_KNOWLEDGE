# HTML-Struktur Template für CONSYS Forms

## Ideale Struktur (Referenz-Template)

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Formular-Titel] - CONSYS</title>

    <!-- Critical CSS inline (optional, für Performance) -->
    <style>
        /* Basis-Reset, Loading-State */
    </style>

    <!-- External CSS -->
    <link rel="stylesheet" href="../css/main.css">
</head>
<body data-active-menu="[menu-key]">
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
                <span>[Icon]</span>
                <span>[Formular-Titel]</span>
            </div>
            <div class="title-bar-buttons">
                <button class="title-btn" onclick="Bridge.sendEvent('minimize')">_</button>
                <button class="title-btn">&#9633;</button>
                <button class="title-btn close" onclick="closeForm()">&#10005;</button>
            </div>
        </div>

        <!-- Main Container -->
        <div class="main-container">
            <!-- Left Menu (Sidebar) -->
            <div class="left-menu">
                <div class="menu-header">HAUPTMENU</div>
                <div class="menu-buttons">
                    <!-- Menu Items -->
                </div>
            </div>

            <!-- Content Area -->
            <div class="content-area">
                <!-- Header Row -->
                <div class="header-row">
                    <div class="logo-box">[Logo]</div>
                    <span class="title-text">[Titel]</span>
                    <!-- Action Buttons -->
                </div>

                <!-- Work Area -->
                <div class="work-area">
                    <!-- Form Content -->
                </div>

                <!-- Status Bar -->
                <div class="status-bar">
                    <!-- Status Sections -->
                </div>
            </div>
        </div>
    </div>

    <!-- WebView2 Bridge -->
    <script src="../js/webview2-bridge.js"></script>

    <!-- Main Logic Script -->
    <script>
        'use strict';
        const API_BASE = 'http://localhost:5000/api';

        // State Management
        const state = {
            // State properties
        };

        // Initialization
        document.addEventListener('DOMContentLoaded', async function() {
            // Init code
        });

        // Helper Functions
        function closeForm() {
            Bridge.close();
            if (!window.chrome || !window.chrome.webview) {
                window.close();
            }
        }
    </script>
</body>
</html>
```

## Kategorien der Formulare

### 1. Standard-Formulare (mit Sidebar)
- **Merkmal:** Vollständiges Layout mit Left-Menu
- **Beispiele:** frm_MA_Mitarbeiterstamm, frm_KD_Kundenstamm, frm_OB_Objekt
- **Struktur:** window-frame > main-container > (left-menu + content-area)

### 2. Access-Nachbildungen (präzise)
- **Merkmal:** Pixel-genaue Nachbildung aus JSON-Export
- **Beispiele:** frm_va_Auftragstamm
- **Struktur:** Absolute Positionierung, Scaling-Container
- **Besonderheit:** `form-container` mit Transform-Scaling

### 3. Sidebar-Only (Menu-Formulare)
- **Merkmal:** Schmales Format, nur Menü-Buttons
- **Beispiele:** frm_Menuefuehrung1
- **Struktur:** Reduzierte window-frame (width: 200px)

### 4. Modern Layout (CSS-Grid basiert)
- **Merkmal:** Flexibles, responsives Layout
- **Beispiele:** frm_MA_Abwesenheit
- **Struktur:** app-container > (app-sidebar + app-main)
- **CSS:** Externe Stylesheets (design-system.css, app-layout.css)

---

## Strukturelle Abweichungen (Analyse)

### ✅ KORREKT (frm_MA_Mitarbeiterstamm, frm_KD_Kundenstamm)
```
✓ DOCTYPE vorhanden
✓ html lang="de"
✓ Korrekte Meta-Tags
✓ Inline CSS für alle Styles (self-contained)
✓ Strukturiertes Layout: window-frame > main-container > (left-menu + content-area)
✓ Loading Overlay + Toast Container
✓ WebView2 Bridge eingebunden
✓ Script am Ende mit 'use strict'
✓ Einheitliche Helper-Funktionen
```

### ⚠️ ABWEICHUNGEN (nach Formular)

#### **frm_OB_Objekt**
```diff
+ Gute Strukturierung
+ Korrekte Navigation
- Kein Toast Container (nur einzelnes Toast-DIV)
- Statusbar-Struktur abweichend (direktes Span statt sections)
- Menu-Buttons ohne gap in Flexbox
```

#### **frm_va_Auftragstamm**
```diff
- Komplett abweichende Struktur (Access-Nachbildung)
- Absolut positionierte Controls statt semantischem Layout
- Scaling-Container mit Transform
- Inline-Styles direkt in HTML (nicht über CSS-Klassen)
+ Korrekt für Zweck (1:1 Access-Nachbildung)
+ Tab-System funktional
```

#### **frm_Menuefuehrung1**
```diff
+ Korrekte Minimal-Struktur
- Nur 200px breit (Sonderfall Menu)
- Kein main-container (reduziertes Layout)
- Sections statt einzelne Menu-Buttons
+ Funktional korrekt für Zweck
```

#### **frm_MA_Abwesenheit**
```diff
- Externe Stylesheets statt inline CSS
- Andere Klassen-Konvention (app-container statt window-frame)
- Moderne Layout-Struktur (app-sidebar, app-main)
- Sidebar nicht als left-menu sondern app-sidebar
+ Moderne, wartbare Struktur
+ Responsive Design
- Inkonsistent mit anderen Formularen
```

---

## Kritische Inkonsistenzen

### 1. CSS-Einbindung
| Formular | Methode | Status |
|----------|---------|--------|
| frm_MA_Mitarbeiterstamm | Inline `<style>` | ✅ Standard |
| frm_KD_Kundenstamm | Inline `<style>` | ✅ Standard |
| frm_OB_Objekt | Inline `<style>` | ✅ Standard |
| frm_va_Auftragstamm | Inline `<style>` | ✅ Spezial |
| frm_MA_Abwesenheit | Externe CSS-Files | ⚠️ Abweichung |

**Empfehlung:** Inline CSS für Konsistenz und Unabhängigkeit

### 2. Klassen-Konventionen
| Klasse | Verwendet in | Zweck |
|--------|--------------|-------|
| `.window-frame` | MA/KD/OB/Auftrag | Standard-Container |
| `.app-container` | MA_Abwesenheit | Moderne Alternative |
| `.left-menu` | MA/KD/OB | Sidebar Navigation |
| `.app-sidebar` | MA_Abwesenheit | Moderne Sidebar |
| `.content-area` | MA/KD/OB | Hauptbereich |
| `.app-main` | MA_Abwesenheit | Moderner Hauptbereich |

**Empfehlung:** Einheitlich `.window-frame`, `.left-menu`, `.content-area`

### 3. Script-Struktur
**Standard (gut):**
```javascript
'use strict';
const API_BASE = 'http://localhost:5000/api';
const state = { ... };

document.addEventListener('DOMContentLoaded', async function() {
    // Init
});

// Helper Functions
function closeForm() { ... }
```

**Abweichend (frm_MA_Abwesenheit):**
```javascript
// Nur Datum-Anzeige inline
// Logic in separater Datei (logic/frm_MA_Abwesenheit.logic.js)
```

**Empfehlung:** Logic inline ODER konsistent in separaten .logic.js Files

### 4. Toast/Loading-Komponenten
**Vollständig (MA/KD):**
```html
<div class="loading-overlay" id="loadingOverlay">...</div>
<div class="toast-container" id="toastContainer"></div>
```

**Minimal (OB):**
```html
<div class="loading-overlay" id="loadingOverlay">...</div>
<div class="toast" id="toast"></div>
```

**Fehlend (Abwesenheit):**
- Keine Loading/Toast-Komponenten im Template

---

## Empfohlene Standard-Struktur

### Für ALLE neuen/überarbeiteten Formulare:

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Titel] - CONSYS</title>
    <style>
        /* Alle Styles inline - KEIN externes CSS */
        /* Basis-Reset */
        /* Komponenten-Styles */
        /* Form-spezifisches CSS */
    </style>
</head>
<body data-active-menu="[key]">
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
    </div>

    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <div class="window-frame">
        <div class="title-bar">...</div>
        <div class="main-container">
            <div class="left-menu">...</div>
            <div class="content-area">
                <div class="header-row">...</div>
                <div class="work-area">...</div>
                <div class="status-bar">...</div>
            </div>
        </div>
    </div>

    <script src="../js/webview2-bridge.js"></script>
    <script>
        'use strict';
        const API_BASE = 'http://localhost:5000/api';
        const state = {};

        document.addEventListener('DOMContentLoaded', async function() {
            // Initialize
        });

        function closeForm() {
            Bridge.close();
            if (!window.chrome || !window.chrome.webview) {
                window.close();
            }
        }
    </script>
</body>
</html>
```

---

## Spezialfälle

### Access-Nachbildungen (frm_va_Auftragstamm-Typ)
- **Behalten:** Absolute Positionierung, Scaling
- **Grund:** 1:1 Nachbildung erforderlich
- **Struktur:** Abweichend erlaubt

### Menu-Formulare (frm_Menuefuehrung1-Typ)
- **Behalten:** Reduzierte window-frame (200px)
- **Grund:** Seitenleiste, keine Full-App
- **Struktur:** Vereinfacht erlaubt

### Moderne Layouts (frm_MA_Abwesenheit-Typ)
- **Anpassen an Standard ODER**
- **Als Zukunfts-Standard definieren**
- **Entscheidung erforderlich!**

---

## Nächste Schritte

1. ✅ Template dokumentiert
2. ⚠️ Entscheidung: Inline CSS vs. Externe Stylesheets
3. ⚠️ Entscheidung: window-frame vs. app-container
4. ⏳ Alle Formulare vereinheitlichen
5. ⏳ Validierungs-Script erstellen
