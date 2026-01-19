# AUDIT: Shell/Sidebar-Integration und Navigation

**Datum:** 2026-01-05
**Dateien analysiert:**
- `/forms3/shell.html`
- `/forms3/js/webview2-bridge.js`

---

## 1. CHECKLISTE SHELL-FUNKTIONEN

### 1.1 Sidebar-Navigation

| Feature | Status | Details |
|---------|--------|---------|
| Menuepunkte werden angezeigt | OK | 13 Menu-Buttons definiert in shell.html |
| Aktives Menu hervorgehoben | OK | `.menu-btn.active` Klasse mit CSS-Styling |
| Sidebar bleibt sichtbar | OK | Sidebar ist permanent, iframe wechselt Content |
| Separator zwischen Gruppen | OK | `.menu-separator` fuer visuelle Trennung |
| Menu 2 Popup | OK | Overlay-basiertes Popup fuer frm_Menuefuehrung1 |

### 1.2 Navigation

| Feature | Status | Details |
|---------|--------|---------|
| loadForm() Funktion | OK | Laedt Formular in iframe mit `?shell=1` Parameter |
| Active-Button Update | OK | `document.querySelectorAll('.menu-btn')` entfernt/setzt active-Klasse |
| Browser History | OK | `history.pushState()` fuer Back/Forward |
| URL-Parameter beim Start | OK | `URLSearchParams` liest `?form=` und `?id=` |
| ESC schliesst Popup | OK | `keydown` Event Listener fuer Escape |

### 1.3 WebView2 Integration

| Feature | Status | Details |
|---------|--------|---------|
| WebView2 Detection | OK | `window.chrome && window.chrome.webview` |
| Mode-Indicator | OK | Zeigt "WebView2" oder "Browser" in Status-Bar |
| Bridge.on('onDataReceived') | OK | Handler registriert in initWebView2Bridge() |
| Bridge.on('onRefresh') | OK | Reload iframe bei onRefresh Event |
| Bridge.sendEvent('navigate') | OK | Informiert Access ueber Formularwechsel |

### 1.4 Datenuebergabe

| Feature | Status | Details |
|---------|--------|---------|
| `-data` JSON empfangen | OK | `Bridge.onDataReceived()` in webview2-bridge.js Zeile 681-700 |
| JSON Parsing | OK | try/catch mit Error-Logging |
| Event-System | OK | `_fireEvent()` an alle Handler |
| Initial-Daten an iframe | OK | `sendDataToIframe()` nach iframe.onload |
| ID-Uebergabe in URL | OK | `formUrl += '&id=' + recordId` |

### 1.5 iframe-Kommunikation

| Feature | Status | Details |
|---------|--------|---------|
| postMessage Navigation | OK | NAVIGATE Message-Type implementiert |
| CLOSE_MENU Message | OK | Schliesst Menu-Popup |
| CLOSE Message | OK | Wechselt zu Dashboard |
| REFRESH Message | OK | Reload iframe.contentWindow |
| STATUS Message | OK | Update Status-Bar Text |
| Daten an iframe senden | OK | `sendDataToIframe()` mit postMessage |
| Events vom iframe empfangen | OK | `window.addEventListener('message', handleIframeMessage)` |

### 1.6 Performance

| Feature | Status | Details |
|---------|--------|---------|
| Kein Sidebar-Reload | OK | Nur iframe-Content wird gewechselt |
| Loading Overlay | OK | Zeigt Spinner waehrend iframe laedt |
| Request Caching (Bridge) | OK | `_cache` Map mit TTL pro Endpoint |
| Cache Deduplication | OK | `_pending` Map verhindert parallele Requests |
| Auto Cache Cleanup | OK | setInterval alle 2 Minuten (Zeile 174) |

---

## 2. FEHLENDE NAVIGATION-FEATURES / PROBLEME

### 2.1 KRITISCH: Dateinamen-Mismatch (Umlaute)

**Problem:** shell.html verwendet Dateinamen mit Umlauten, aber Dateien haben keine Umlaute:

| shell.html erwartet | Tatsaechlicher Dateiname | Status |
|---------------------|--------------------------|--------|
| `frm_N_Dienstplanübersicht.html` | `frm_N_Dienstplanuebersicht.html` | FEHLER |
| `frm_VA_Planungsübersicht.html` | `frm_VA_Planungsuebersicht.html` | FEHLER |
| `frm_Einsatzübersicht.html` | **DATEI FEHLT KOMPLETT** | FEHLER |

**Auswirkung:** Navigation zu Dienstplanuebersicht, Planungsuebersicht und Einsatzuebersicht funktioniert NICHT!

### 2.2 Fehlende Formulare

| Formular | Status |
|----------|--------|
| `frm_Einsatzübersicht.html` / `frm_Einsatzuebersicht.html` | FEHLT |

### 2.3 Inkonsistente Formular-Referenzen

Die shell.html verwendet:
```javascript
data-form="frm_N_Dienstplanübersicht"  // Mit Umlaut
```

Aber die Datei heisst:
```
frm_N_Dienstplanuebersicht.html  // Ohne Umlaut (ue statt ü)
```

### 2.4 Fehlende Features (Nice-to-Have)

| Feature | Status | Prioritaet |
|---------|--------|------------|
| Keyboard Navigation (Pfeiltasten) | FEHLT | Niedrig |
| Breadcrumb-Navigation | FEHLT | Niedrig |
| Recent Forms History | FEHLT | Niedrig |
| Form-Preloading | FEHLT | Mittel |
| Error-Fallback bei fehlendem Formular | FEHLT | Mittel |

### 2.5 Menu 2 (frm_Menuefuehrung1) Problem

**Potentielles Problem:** Das Menu2-Popup verwendet einen relativen Pfad:
```javascript
frame.src = 'frm_Menuefuehrung1.html';
```

Dies funktioniert nur wenn shell.html im gleichen Verzeichnis liegt.

---

## 3. KORREKTURVORSCHLAEGE

### 3.1 SOFORT: Dateinamen in shell.html korrigieren

**Datei:** `/forms3/shell.html`

**Zeile 248-249 aendern:**
```html
<!-- ALT (FALSCH) -->
<button class="menu-btn" data-form="frm_N_Dienstplanübersicht">Dienstplanübersicht</button>
<button class="menu-btn" data-form="frm_VA_Planungsübersicht">Planungsübersicht</button>

<!-- NEU (KORREKT) -->
<button class="menu-btn" data-form="frm_N_Dienstplanuebersicht">Dienstplanübersicht</button>
<button class="menu-btn" data-form="frm_VA_Planungsuebersicht">Planungsübersicht</button>
```

**Zeile 268 aendern:**
```html
<!-- ALT (FALSCH) -->
<button class="menu-btn" data-form="frm_Einsatzübersicht">Einsatzübersicht</button>

<!-- NEU - Option A: Formular erstellen -->
<button class="menu-btn" data-form="frm_Einsatzuebersicht">Einsatzübersicht</button>

<!-- NEU - Option B: Temporaer entfernen bis Formular existiert -->
<!-- Button auskommentiert bis frm_Einsatzuebersicht.html erstellt -->
```

### 3.2 Fehlendes Formular erstellen

Erstelle `/forms3/frm_Einsatzuebersicht.html` oder entferne den Menu-Button temporaer.

### 3.3 Error-Handling fuer fehlende Formulare

In `loadForm()` Funktion ergaenzen:

```javascript
function loadForm(formName, recordId) {
    if (!formName) return;

    // Error-Handler fuer fehlende Formulare
    ShellState.iframe.onerror = function() {
        hideLoading();
        updateStatus('Formular nicht gefunden: ' + formName);
        console.error('[Shell] Formular nicht gefunden:', formName);
    };

    // ... bestehender Code ...
}
```

### 3.4 Einheitliche Namenskonvention etablieren

**Empfehlung:** Alle Dateinamen OHNE Umlaute verwenden:
- `ue` statt `ü`
- `ae` statt `ä`
- `oe` statt `ö`
- `ss` statt `ß`

Dies verhindert Encoding-Probleme und ist URL-sicher.

---

## 4. CODE-QUALITAET BEWERTUNG

### 4.1 Positiv

- Saubere Trennung Shell/Content via iframe
- Robustes Event-System mit Handler-Registrierung
- Gutes Caching mit konfigurierbarem TTL
- WebView2/Browser Fallback gut implementiert
- ESC-Taste fuer Popup-Schliessen implementiert
- Browser History funktioniert

### 4.2 Verbesserungswuerdig

- Keine Fehlerbehandlung fuer fehlende Formulare
- Keine Validierung der data-form Attribute gegen existierende Dateien
- Umlaute in HTML data-Attributen problematisch
- Kein Preloading von Formularen

---

## 5. ZUSAMMENFASSUNG

| Kategorie | Bewertung |
|-----------|-----------|
| Sidebar-Grundfunktion | 95% OK |
| WebView2 Integration | 100% OK |
| Datenuebergabe | 100% OK |
| iframe-Kommunikation | 100% OK |
| Caching/Performance | 100% OK |
| **Navigation (Dateinamen)** | **30% - KRITISCH** |

### Naechste Schritte

1. **SOFORT:** Umlaute in shell.html data-form Attributen korrigieren
2. **SOFORT:** Fehlende Einsatzuebersicht erstellen oder Button entfernen
3. **OPTIONAL:** Error-Handling fuer 404 bei Formularen
4. **OPTIONAL:** Form-Preloading implementieren

---

*Generiert am 2026-01-05 durch Claude Code Audit*
