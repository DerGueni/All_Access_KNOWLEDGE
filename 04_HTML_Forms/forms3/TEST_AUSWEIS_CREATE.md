# Test-Anleitung: frm_Ausweis_Create.html

**Version:** 1.0
**Datum:** 2026-01-12
**Phase:** 2 - VBA-Bridge Integration

---

## Überblick

Das Ausweis-Formular wurde von **WebView2 Bridge** auf **VBA-Bridge Server (REST API)** umgestellt.

**Änderungen:**
- ✅ Mitarbeiter-Laden via REST API (Port 5000)
- ✅ Ausweis-Nummer Vergabe via VBA-Bridge (Port 5002)
- ✅ Ausweis-Druck via VBA-Bridge (Port 5002)
- ✅ Karten-Druck via VBA-Bridge (Port 5002)

---

## Voraussetzungen

### 1. Access-Frontend geöffnet
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb
```
**Wichtig:** Access MUSS geöffnet sein, da VBA-Bridge auf Access-Instanz zugreift!

### 2. REST API Server laufen lassen
```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```
**Port:** 5000
**Endpoint:** http://localhost:5000/api/mitarbeiter

### 3. VBA-Bridge Server starten
```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py
```
**Port:** 5002
**Endpoints:**
- POST /api/vba/ausweis/nummer
- POST /api/vba/ausweis/drucken
- POST /api/vba/execute

### 4. VBA-Funktionen vorhanden

Diese Funktionen müssen in Access VBA vorhanden sein:
- `Ausweis_Nr_Vergeben(MA_ID As Long) As Long`
- `Ausweis_Drucken(MA_ID As Long, Optional DruckerName As String) As Boolean`
- `Karte_Drucken(MA_ID As Long, CardType As String, Drucker As String) As Boolean`

---

## Test-Ablauf

### Schritt 1: Server-Status prüfen

**REST API (Port 5000):**
```bash
curl http://localhost:5000/api/mitarbeiter?aktiv=true
```
**Erwartung:** JSON-Array mit Mitarbeitern

**VBA-Bridge (Port 5002):**
```bash
curl http://localhost:5002/api/vba/status
```
**Erwartung:**
```json
{
  "status": "running",
  "access_connected": true,
  "win32com_available": true
}
```

---

### Schritt 2: Formular öffnen

```bash
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Ausweis_Create.html"
```

**Was passiert:**
1. HTML lädt Mitarbeiter via `fetch('http://localhost:5000/api/mitarbeiter?aktiv=true')`
2. Linke Liste (`lstMA_Alle`) wird gefüllt
3. Counter wird aktualisiert

**Browser Console prüfen:**
```
[Ausweis Create] Initializing...
[Ausweis Create] 150 Mitarbeiter geladen
[Ausweis Create] Ready
```

---

### Schritt 3: Mitarbeiter auswählen

1. In linker Liste (`lstMA_Alle`) Mitarbeiter markieren
2. Button **">"** klicken
3. Mitarbeiter erscheinen in rechter Liste (`lstMA_Ausweis`)

**Console:**
```
[Toast success] 3 Mitarbeiter hinzugefügt
```

---

### Schritt 4: Gültigkeitsdatum setzen

1. Feld `GueltBis` prüfen (sollte Ende des Jahres sein)
2. Optional: Datum ändern

---

### Schritt 5: Ausweis drucken (Badge)

1. Badge-Typ wählen (z.B. **"Security"** Button klicken)
2. Browser Console prüfen

**Was passiert:**
```javascript
// Für JEDEN ausgewählten Mitarbeiter:

// 1. Falls keine Ausweis-Nummer: Nummer vergeben
POST http://localhost:5002/api/vba/ausweis/nummer
{
  "MA_ID": 123
}
→ Response: { "success": true, "ausweis_nr": 12345 }

// 2. Ausweis drucken
POST http://localhost:5002/api/vba/ausweis/drucken
{
  "MA_ID": 123,
  "badgeType": "Security",
  "validUntil": "2026-12-31"
}
→ Response: { "success": true, "result": true }
```

**Erwartetes Verhalten:**
- Toast: "3 Ausweise erfolgreich gedruckt (Security)"
- Console: Details zu jedem Druck
- Mitarbeiter-Liste wird neu geladen (aktualisierte Ausweis-Nummern)

**Fehlerfall (VBA-Bridge nicht erreichbar):**
- Toast: "Fehler beim Drucken: ..."
- Fallback: Print-Preview-Fenster öffnet sich

---

### Schritt 6: Karte drucken (Card)

1. Kartendrucker auswählen (`cbo_Kartendrucker`)
2. Karten-Typ wählen (z.B. **"Sicherheit"**)

**Was passiert:**
```javascript
// Für JEDEN ausgewählten Mitarbeiter:
POST http://localhost:5002/api/vba/execute
{
  "function": "Karte_Drucken",
  "args": [123, "Sicherheit", "Canon iP7250"]
}
→ Response: { "success": true, "result": true }
```

**Erwartung:**
- Toast: "3 Karten erfolgreich gedruckt (Sicherheit)"
- Console: Details zu jedem Karten-Druck

---

## Fehlersuche (Troubleshooting)

### Problem 1: "Mitarbeiter konnten nicht geladen werden"

**Ursache:** REST API (Port 5000) läuft nicht

**Lösung:**
```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

---

### Problem 2: "Fehler beim Drucken: Failed to fetch"

**Ursache:** VBA-Bridge Server (Port 5002) läuft nicht

**Lösung:**
```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py
```

---

### Problem 3: "Access nicht geöffnet!"

**Ursache:** VBA-Bridge findet keine Access-Instanz

**Lösung:**
1. Access öffnen mit `0_Consys_FE_Test.accdb`
2. VBA-Bridge Server neu starten

**Prüfen:**
```bash
curl http://localhost:5002/api/vba/status
```
Muss `"access_connected": true` zeigen!

---

### Problem 4: "Compile error: Sub or Function not defined"

**Ursache:** VBA-Funktionen fehlen oder sind nicht Public

**Lösung:**
1. In Access VBA prüfen:
   - `Ausweis_Nr_Vergeben` in Modul `mod_N_Ausweis_Create_Bridge`
   - `Ausweis_Drucken` in Modul `mod_N_Ausweis_Create_Bridge`
   - `Karte_Drucken` in Modul `mod_N_Ausweis_Create_Bridge`

2. Funktionen müssen `Public` sein:
   ```vba
   Public Function Ausweis_Nr_Vergeben(MA_ID As Long) As Long
       ' ...
   End Function
   ```

3. VBA kompilieren:
   ```vba
   DoCmd.RunCommand acCmdCompileAndSaveAllModules
   ```

---

### Problem 5: CORS-Fehler in Browser

**Ursache:** Browser blockiert Cross-Origin-Requests

**Lösung:** VBA-Bridge Server hat bereits CORS aktiviert:
```python
from flask_cors import CORS
CORS(app)
```

Falls Problem bleibt:
1. Browser-Console prüfen
2. VBA-Bridge Server Log prüfen (`vba_bridge.log`)

---

## Erfolgs-Kriterien

✅ **Mitarbeiter laden:** Linke Liste zeigt aktive Mitarbeiter
✅ **Transfer funktioniert:** Mitarbeiter können zwischen Listen verschoben werden
✅ **Ausweis-Nummer vergeben:** Mitarbeiter ohne Nummer bekommen eine
✅ **Ausweis drucken:** VBA-Funktion wird aufgerufen
✅ **Karte drucken:** VBA-Funktion wird aufgerufen
✅ **Fehlerbehandlung:** Toast zeigt Fehler bei Server-Ausfall
✅ **Fallback:** Print-Preview bei VBA-Bridge Fehler

---

## Logs prüfen

**VBA-Bridge Server Log:**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\vba_bridge.log
```

**Browser Console:**
- F12 → Console-Tab
- Filter: "Ausweis"

**Netzwerk-Tab:**
- F12 → Network-Tab
- Filter: "localhost:5002"
- Requests zu `/api/vba/ausweis/*` prüfen

---

## Nächste Schritte

Nach erfolgreichem Test:
1. ✅ VBA-Bridge Integration funktioniert
2. ⏳ Foto-Upload implementieren (Phase 3)
3. ⏳ Weitere Formulare migrieren (Rechnung, Angebot)

---

**Letzte Änderung:** 2026-01-12 23:30
**Autor:** Claude Code
**Version:** 1.0
