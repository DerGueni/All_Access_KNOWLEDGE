# REST-API Fallback Implementation für 4 Subforms

**Status:** Abgeschlossen (16.01.2026)

## Zusammenfassung

4 Subforms wurden mit REST-API Fallback implementiert um Timeout-Probleme bei der WebView2-Bridge zu vermeiden, die bei iframes auftreten.

## Implementierte Subforms

### 1. sub_DP_Grund.logic.js
- **Endpoint:** `/api/dienstplan/gruende`
- **Funktion:** Lädt Abwesenheitsgründe
- **Fallback:** WebView2-Bridge (`Bridge.sendEvent`)

### 2. sub_DP_Grund_MA.logic.js
- **Endpoint:** `/api/dienstplan/ma/{MA_ID}`
- **Funktion:** Lädt Abwesenheitsgründe pro Mitarbeiter
- **Fallback:** WebView2-Bridge
- **Parameter:** `state.MA_ID` (gesetzt via `postMessage`)

### 3. sub_MA_Offene_Anfragen.logic.js
- **Endpoint:** `/api/anfragen`
- **Funktion:** Lädt offene Planungsanfragen mit Zusagen/Absagen Buttons
- **Fallback:** WebView2-Bridge
- **Parameter:** `state.MA_ID`, `state.VA_ID` (mit Client-seitiger Filterung)

### 4. sub_MA_VA_Planung_Absage.logic.js
- **Endpoint:** `/api/auftraege/{VA_ID}/absagen`
- **Funktion:** Lädt Absagen-Liste pro Auftrag
- **Fallback:** WebView2-Bridge
- **Parameter:** `state.VA_ID` (gesetzt via `postMessage`)

## Implementation Pattern

### In jeder logic.js:

```javascript
function loadData() {
    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[SubformName] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        loadDataViaAPI();
    } else if (window.Bridge) {
        Bridge.sendEvent('loadSubformData', {
            type: 'event_type',
            // ... parameters
        });
    } else {
        console.warn('[SubformName] Bridge nicht verfuegbar...');
        setTimeout(loadData, 100);
    }
}

async function loadDataViaAPI() {
    try {
        const response = await fetch('http://localhost:5000/api/endpoint');
        if (!response.ok) throw new Error(`API Fehler: ${response.status}`);

        const records = await response.json();
        console.log('[SubformName] API Daten geladen:', records.length);

        state.records = records;
        render();
    } catch (err) {
        console.error('[SubformName] API Fehler:', err);
        // Fallback: versuche Bridge
        if (window.Bridge) {
            console.log('[SubformName] Fallback zu Bridge...');
            Bridge.sendEvent('loadSubformData', { ... });
        }
    }
}
```

## Debugging

### Console-Logs prüfen:

```javascript
// Erfolg (REST-API):
[sub_DP_Grund] Verwende REST-API Modus (erzwungen)
[sub_DP_Grund] API Daten geladen: 5 Eintraege

// Fallback (WebView2):
[sub_DP_Grund] API Fehler: TypeError: Failed to fetch
[sub_DP_Grund] Fallback zu Bridge...
```

### API Server Status:

```bash
# Prüfe ob API Server läuft
netstat -ano | findstr :5000

# Oder: Browser öffnen
http://localhost:5000/api/dienstplan/gruende
```

## Wichtige Regeln (NIEMALS ÄNDERN)

1. `const isBrowserMode = true;` MUSS auf `true` sein
2. REST-API Aufrufe MÜSSEN mit `http://localhost:5000` beginnen
3. WebView2-Bridge Code MUSS als Fallback behalten bleiben
4. Console-Logs MÜSSEN erhalten bleiben für Debugging

## Wenn API-Server nicht läuft

Falls Timeout bei REST-API:
1. Server auf Port 5000 starten: `python api_server.py`
2. Reload im Browser (F5)
3. Console prüfen: sollte Fallback zu Bridge verwenden

## Zukünftige Subforms

Wenn weitere Subforms mit REST-API Fallback aktualisiert werden:

1. Kopiere das Pattern oben
2. Ersetze Endpoint und Parameter
3. Behalte Fallback-Code bei
4. Teste mit und ohne API-Server

---

**Dokumentiert:** 16.01.2026
**Skala:** iframe-timeout Probleme GELÖST
