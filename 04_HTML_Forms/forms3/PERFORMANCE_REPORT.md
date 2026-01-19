# Performance Report - HTML-Formulare forms3

**Erstellt:** 2026-01-07
**Pfad:** C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\

---

## 1. TOP 10 GROESSTE HTML-DATEIEN

| Rang | Datei | Groesse | Problem-Einschaetzung |
|------|-------|---------|----------------------|
| 1 | Auftragsverwaltung2.html | 169 KB | KRITISCH - zu gross |
| 2 | frm_KD_Kundenstamm.html | 150 KB | KRITISCH - zu gross |
| 3 | frm_MA_Mitarbeiterstamm.html | 141 KB | KRITISCH - zu gross |
| 4 | frm_va_Auftragstamm_V03.html | 134 KB | KRITISCH - zu gross |
| 5 | frm_va_Auftragstamm.html | 123 KB | KRITISCH - zu gross |
| 6 | frm_va_Auftragstamm_mitEventdaten.html | 109 KB | HOCH - sehr gross |
| 7 | frm_OB_Objekt.html | 84 KB | HOCH - gross |
| 8 | sidebar_varianten/variante5_tabs.html | 69 KB | MITTEL |
| 9 | frm_MA_VA_Schnellauswahl.html | 68 KB | MITTEL |
| 10 | frm_va_Auftragstamm_Stammdaten_NEU.html | 60 KB | MITTEL |

**Empfehlung:** Formulare > 50KB sollten in HTML + externe Logic-JS aufgeteilt werden.

---

## 2. TOP 10 GROESSTE JS-DATEIEN

| Rang | Datei | Groesse | Zweck |
|------|-------|---------|-------|
| 1 | js/global-handlers.js | 62 KB | Button-Handler fuer alle Formulare |
| 2 | logic/frm_va_Auftragstamm.logic.js | 62 KB | Auftragstamm Business-Logik |
| 3 | logic/frm_MA_Mitarbeiterstamm.logic.js | 49 KB | Mitarbeiterstamm Business-Logik |
| 4 | logic/frm_va_Auftragstamm.logicALT.js | 47 KB | VERALTET - sollte entfernt werden |
| 5 | logic/frm_KD_Kundenstamm.logic.js | 40 KB | Kundenstamm Business-Logik |
| 6 | js/webview2-bridge.js | 38 KB | WebView2-Kommunikation |
| 7 | logic/frm_Einsatzuebersicht.logic.js | 32 KB | Einsatzuebersicht |
| 8 | logic/frm_N_Optimierung.logic.js | 31 KB | Optimierungs-Tool |
| 9 | logic/frm_MA_VA_Schnellauswahl.logic.js | 25 KB | Schnellauswahl |
| 10 | tools/form_validator.js | 24 KB | Validierungs-Tool |

---

## 3. CSS-DATEIEN (Gesamt: 47 KB)

| Datei | Groesse | Inhalt |
|-------|---------|--------|
| css/app-layout.css | 19.2 KB | Haupt-Layout |
| css/variables.css | 10.7 KB | CSS Custom Properties |
| theme/consys_theme.css | 8.5 KB | Theme-Farben |
| consys-common.css | 6.0 KB | Gemeinsame Styles |
| css/design-system.css | 1.7 KB | Design-System Wrapper |

**Beobachtung:** Kein separates Critical CSS vorhanden - alle Formulare laden komplettes CSS.

---

## 4. API-NUTZUNG ANALYSE

### 4.1 Haeufigste API-Endpoints (basierend auf fetch-Aufrufen)

| Endpoint | Anzahl Calls | Genutzt in |
|----------|--------------|------------|
| /api/auftraege | 15+ | Auftragstamm, Schnellauswahl, Kundenstamm |
| /api/mitarbeiter | 10+ | Mitarbeiterstamm, Schnellauswahl, Dienstplan |
| /api/kunden | 8+ | Kundenstamm, Auftragstamm |
| /api/zuordnungen | 8+ | Schnellauswahl, Dienstplan, Auftragstamm |
| /api/dienstplan/gruende | 5+ | Abwesenheit, Dienstplan |
| /api/objekte | 5+ | Objekt, Schnellauswahl |
| /api/eventdaten | 4 | Auftragstamm mit Eventdaten |
| /api/attachments | 4 | Kundenstamm, Objekt |
| /api/ansprechpartner | 3 | Kundenstamm |
| /api/preise | 3 | Kundenstamm |

### 4.2 Caching-Status

**VORHANDEN (in performance.js):**
- RequestCache mit konfigurierbarem TTL pro Endpoint
- Request-Deduplication (verhindert parallele identische Requests)
- Automatischer Cache-Cleanup alle 2 Minuten

**NICHT GENUTZT:**
- Die meisten HTML-Formulare nutzen direktes `fetch()` statt `RequestCache.fetch()`
- Nur wenige Logic-Dateien importieren performance.js

### 4.3 Problematische Patterns

1. **Kein Caching in Hauptformularen:**
   - `frm_KD_Kundenstamm.html` - 17x direktes fetch() ohne Cache
   - `frm_MA_Mitarbeiterstamm.html` - via Bridge, kein explizites Caching
   - `frm_va_Auftragstamm.html` - 9x direktes fetch() ohne Cache

2. **Mehrfaches Laden gleicher Daten:**
   - Mitarbeiterliste wird bei jedem Tab-Wechsel neu geladen
   - Abwesenheitsgruende werden pro Formular einzeln geladen (sollten global gecacht sein)

3. **Fehlende Request-Bundling:**
   - `frm_N_Dienstplanuebersicht.html` macht 3 sequentielle Requests statt Promise.all()
   ```javascript
   const maResponse = await fetch(...);
   const dpResponse = await fetch(...);
   const abwResponse = await fetch(...);
   ```

---

## 5. FEHLENDE PERFORMANCE-OPTIMIERUNGEN

### 5.1 Fehlende Debounce bei Suchfeldern

| Formular | Suchfeld | Debounce |
|----------|----------|----------|
| frm_MA_Mitarbeiterstamm.html | searchInput | FEHLT |
| frm_KD_Kundenstamm.html | searchInput | FEHLT |
| frm_OB_Objekt.html | searchInput | FEHLT |
| frm_Kundenpreise_gueni.html | oninput | FEHLT |
| frm_N_Bewerber.html | txtSuche onkeyup | FEHLT |
| frm_N_Stundenauswertung.html | searchBox | FEHLT |

**Problem:** Jeder Tastendruck triggert Filter/Render - bei grossen Listen sehr langsam.

### 5.2 Fehlende Pagination / Virtual Scrolling

| Formular | Listengroesse | Pagination |
|----------|---------------|------------|
| frm_MA_Mitarbeiterstamm.html | ~500 MA | FEHLT (limit=100 hardcoded) |
| frm_KD_Kundenstamm.html | ~300 Kunden | FEHLT |
| frm_va_Auftragstamm.html | ~1000 Auftraege | limit=100 hardcoded |
| frm_MA_VA_Schnellauswahl.html | Alle MA | FEHLT |

**VirtualScroller in performance.js vorhanden aber NICHT genutzt!**

### 5.3 Fehlende Lazy Loading

- Alle Sub-Formulare werden direkt geladen (keine data-lazy-src)
- Tabs laden sofort alle Daten statt On-Demand
- iframes in Subformularen laden sofort

---

## 6. KONKRETE OPTIMIERUNGSVORSCHLAEGE

### 6.1 SOFORT UMSETZBAR (Low Effort / High Impact)

#### A) Debounce fuer Suchfelder (5 Min pro Formular)
```javascript
// In jedem Formular mit Suche:
import { debounce } from '../js/performance.js';

const debouncedSearch = debounce(renderList, 300);
document.getElementById('searchInput').addEventListener('input', debouncedSearch);
```

**Betroffene Formulare:**
- frm_MA_Mitarbeiterstamm.html
- frm_KD_Kundenstamm.html
- frm_OB_Objekt.html
- frm_N_Stundenauswertung.html

#### B) RequestCache nutzen statt direktem fetch (10 Min pro Formular)
```javascript
// VORHER:
const response = await fetch('http://localhost:5000/api/mitarbeiter');

// NACHHER:
import { RequestCache } from '../js/performance.js';
const data = await RequestCache.fetch('http://localhost:5000/api/mitarbeiter');
```

#### C) Parallele Requests mit Promise.all (5 Min)
```javascript
// VORHER (in frm_N_Dienstplanuebersicht.html):
const maResponse = await fetch(maUrl);
const dpResponse = await fetch(dpUrl);
const abwResponse = await fetch(abwUrl);

// NACHHER:
const [maData, dpData, abwData] = await Promise.all([
    RequestCache.fetch(maUrl),
    RequestCache.fetch(dpUrl),
    RequestCache.fetch(abwUrl)
]);
```

### 6.2 MITTELFRISTIG (Medium Effort / High Impact)

#### D) Critical CSS extrahieren
Erstelle `css/critical.css` mit nur den Styles fuer First Paint:
- Body/HTML Reset
- Loading-Spinner
- Sidebar-Grundstruktur
- Erste sichtbare Formular-Felder

```html
<head>
    <style>/* critical.css inline */</style>
    <link rel="stylesheet" href="../css/app-layout.css" media="print" onload="this.media='all'">
</head>
```

#### E) Virtual Scrolling fuer lange Listen
```javascript
import { VirtualScroller } from '../js/performance.js';

const scroller = new VirtualScroller('#mitarbeiterBody', {
    itemHeight: 32,
    renderItem: (ma) => `<tr><td>${ma.Nachname}</td><td>${ma.Vorname}</td></tr>`
});
scroller.setItems(state.mitarbeiterList);
```

### 6.3 LANGFRISTIG (High Effort / Very High Impact)

#### F) HTML-Dateien aufteilen
Grosse Formulare sollten getrennt werden:
- `frm_KD_Kundenstamm.html` (150KB) -> HTML (~30KB) + Logic.js (~50KB) + Inline-Styles entfernen

#### G) Lazy Tab-Loading
Tabs erst laden wenn geklickt:
```javascript
function switchTab(tabName) {
    if (!tabsLoaded[tabName]) {
        loadTabData(tabName);
        tabsLoaded[tabName] = true;
    }
    showTab(tabName);
}
```

#### H) Service Worker fuer Offline-Caching
Stammdaten wie Mitarbeiter, Kunden, Objekte koennen offline gecacht werden.

---

## 7. PRIORITAETEN-MATRIX

| Optimierung | Aufwand | Impact | Prioritaet |
|-------------|---------|--------|------------|
| Debounce Suchfelder | 30 Min | HOCH | 1 |
| RequestCache nutzen | 2 Std | HOCH | 2 |
| Promise.all parallele Requests | 1 Std | MITTEL | 3 |
| Virtual Scrolling | 4 Std | HOCH | 4 |
| Critical CSS | 3 Std | MITTEL | 5 |
| HTML/JS Splitting | 8 Std | MITTEL | 6 |
| Lazy Tab Loading | 4 Std | MITTEL | 7 |
| Service Worker | 8 Std | NIEDRIG | 8 |

---

## 8. PERFORMANCE.JS NUTZUNGS-STATUS

**Verfuegbare Features in performance.js:**
- RequestCache (mit TTL und Deduplication)
- debounce() / throttle()
- LazyLoader (IntersectionObserver)
- DOMBatcher (requestAnimationFrame)
- VirtualScroller (fuer lange Listen)
- SkeletonLoader (Loading-Placeholder)
- Preloader (Daten vorladen)
- PerfMonitor (Zeitmessung)

**Aktuelle Nutzung:**
- RequestCache: NUR in wenigen Logic-Dateien
- debounce/throttle: NUR in 4 Logic-Dateien
- VirtualScroller: NICHT genutzt
- LazyLoader: NICHT genutzt
- SkeletonLoader: NICHT genutzt

**Empfehlung:** Diese bereits vorhandenen Tools muessen in allen Formularen eingesetzt werden!

---

## 9. NAECHSTE SCHRITTE

1. **Diese Woche:** Debounce in alle Suchfelder einbauen
2. **Naechste Woche:** RequestCache in den 5 groessten Formularen nutzen
3. **Bis Ende Monat:** Virtual Scrolling fuer Mitarbeiter- und Kundenlisten

---

*Report erstellt durch Performance-Analyse der forms3-Codebasis*
