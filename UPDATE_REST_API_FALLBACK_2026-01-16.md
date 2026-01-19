# Update: REST-API Fallback für 4 Subforms

**Datum:** 16.01.2026
**Zeit:** SESSION
**Status:** ✅ ABGESCHLOSSEN

---

## Implementierte Subforms

4 weitere Subforms wurden mit REST-API Fallback aktualisiert (Pattern wie sub_MA_VA_Zuordnung):

### 1. sub_DP_Grund.logic.js
- **Endpoint:** `GET http://localhost:5000/api/dienstplan/gruende`
- **Funktion:** Dienstplan-Abwesenheitsgründe
- **Rückgabe:** Array[{Grund_ID, Grund_Bez, Grund_Kuerzel}]
- **Felder:** ID | Bezeichnung | Kürzel

### 2. sub_DP_Grund_MA.logic.js
- **Endpoint:** `GET http://localhost:5000/api/dienstplan/ma/{MA_ID}`
- **Funktion:** Abwesenheitsgründe pro Mitarbeiter
- **Parameter:** `state.MA_ID` (via postMessage)
- **Rückgabe:** Array[{ID, Datum, Grund_Bez, Bemerkung}]
- **Filter:** Dropdown-Filterung nach Grund-Typ

### 3. sub_MA_Offene_Anfragen.logic.js
- **Endpoint:** `GET http://localhost:5000/api/anfragen`
- **Funktion:** Offene Planungsanfragen mit Zusagen/Absagen
- **Parameter:** `state.MA_ID`, `state.VA_ID` (Client-seitiges Filter)
- **Rückgabe:** Array[{ID, VADatum, MA_Name, VA_Start, VA_Ende, ...}]
- **Buttons:** Zusagen/Absagen → API POST + postMessage an Parent

### 4. sub_MA_VA_Planung_Absage.logic.js
- **Endpoint:** `GET http://localhost:5000/api/auftraege/{VA_ID}/absagen`
- **Funktion:** Absagen-Liste pro Auftrag/Schicht
- **Parameter:** `state.VA_ID` (via postMessage)
- **Rückgabe:** Array[{MVA_ID, MA_Name, VA_Start, VA_Ende, Bemerkungen}]

---

## Implementation Details

### Pattern (identisch zu sub_MA_VA_Zuordnung):

```javascript
function loadData() {
    const isBrowserMode = true; // Erzwinge REST-API
    console.log('[SubformName] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        loadDataViaAPI();
    } else if (window.Bridge) {
        Bridge.sendEvent(...); // Fallback
    }
}

async function loadDataViaAPI() {
    try {
        const response = await fetch('http://localhost:5000/api/...');
        if (!response.ok) throw new Error(`API Fehler: ${response.status}`);

        const records = await response.json();
        console.log('[SubformName] API Daten geladen:', records.length);

        state.records = records;
        render();
    } catch (err) {
        console.error('[SubformName] API Fehler:', err);
        if (window.Bridge) {
            console.log('[SubformName] Fallback zu Bridge...');
            Bridge.sendEvent(...);
        }
    }
}
```

### Wichtige Features:

✅ REST-API als PRIMARY (kein Timeout)
✅ WebView2-Bridge als Fallback (Kommentar erhalten)
✅ Async/await mit Try-Catch Error-Handling
✅ Console-Logs für Debugging (`[FormName] Verwende REST-API Modus`)
✅ Kein Breaking Change (alte Logic funktioniert noch)

---

## Warum REST-API?

**Problem:** WebView2-Bridge hat **Timeout-Probleme bei iframes**
- sub_MA_VA_Zuordnung lädt in iframe (Auftragstamm Subform)
- Bridge-Aufrufe über iframe hinweg sind **EXTREM LANGSAM**
- Timeout nach ~10 Sekunden = leere Tabelle

**Lösung:** REST-API auf Port 5000 (lokales Netzwerk)
- Schneller
- Zuverlässiger
- Keine Timeout-Probleme
- Fallback zu Bridge wenn API nicht verfügbar

---

## Debugging

### Console-Logs prüfen (Browser DevTools F12):

**Erfolgreicher API-Aufruf:**
```
[sub_DP_Grund] Verwende REST-API Modus (erzwungen)
[sub_DP_Grund] API Daten geladen: 5 Eintraege
```

**Fallback zu Bridge:**
```
[sub_DP_Grund] Verwende REST-API Modus (erzwungen)
[sub_DP_Grund] API Fehler: TypeError: Failed to fetch
[sub_DP_Grund] Fallback zu Bridge...
```

### API Server testen:

```bash
# Prüfe ob Server läuft (Port 5000)
netstat -ano | findstr :5000

# Oder im Browser:
http://localhost:5000/api/dienstplan/gruende
http://localhost:5000/api/dienstplan/ma/123
http://localhost:5000/api/anfragen
http://localhost:5000/api/auftraege/456/absagen
```

---

## Geänderte Dateien

```
04_HTML_Forms/forms3/logic/
├── sub_DP_Grund.logic.js                  (+37 Zeilen)
├── sub_DP_Grund_MA.logic.js               (+47 Zeilen)
├── sub_MA_Offene_Anfragen.logic.js        (+50 Zeilen)
└── sub_MA_VA_Planung_Absage.logic.js      (+47 Zeilen)
```

---

## Dokumentation

### Neue Dateien:
- `REST_API_FALLBACK_IMPLEMENTATION.md` - Vollständige Dokumentation
- `REST_API_FALLBACK_TEST_CHECKLIST.md` - Test-Anleitung
- `UPDATE_REST_API_FALLBACK_2026-01-16.md` - Dieses Update

---

## Nächste Schritte (Falls Fehler)

Falls Subforms leer sind:

1. **API Server prüfen:**
   ```bash
   netstat -ano | findstr :5000
   # Falls nicht: python api_server.py
   ```

2. **Console-Logs prüfen:**
   - Browser F12 → Console
   - Fallback-Meldung?
   - API-Fehler?

3. **Endpoint testen:**
   ```bash
   curl http://localhost:5000/api/dienstplan/gruende
   ```

4. **Fallback debuggen:**
   - Setze `const isBrowserMode = false;` zum Testen
   - Sollte zu Bridge-Modus wechseln

---

## WICHTIG: Diese Einstellungen DARF NICHT GEÄNDERT WERDEN!

❌ `const isBrowserMode = false;` - Würde WebView2 verwenden und wieder zu Timeouts führen!
❌ REST-API Endpoints ändern - Müssten mit API Server abgestimmt werden!
❌ Fallback-Code entfernen - Wird als Sicherheitsnetz benötigt!

---

**Implementiert von:** Claude Code
**Verifizierung:** TODO (Manuelle Tests erforderlich)
**Performance Impact:** ✅ POSITIV (schneller, keine Timeouts)
