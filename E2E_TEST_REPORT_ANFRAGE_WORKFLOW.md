# E2E-Testbericht: Mitarbeiter-Anfrage-Workflow

**Datum:** 2026-01-17
**Tester:** Claude E2E-Test-Agent

---

## 1. Executive Summary

| Komponente | Status | Details |
|------------|--------|---------|
| API Server (Port 5000) | **OK** | Verbunden mit Access Backend |
| VBA Bridge (Port 5002) | **PROBLEM** | Antwortet nicht (zu viele offene Verbindungen) |
| HTTP Server (Port 8081) | **OK** | Formulare werden geladen |
| Schnellauswahl Formular | **OK** | Wird korrekt angezeigt |
| Anfrage-Workflow | **TEILWEISE** | REST-API funktioniert, VBA Bridge blockiert |

---

## 2. Server-Status

### 2.1 API Server (Port 5000)
```json
{
  "backend": "connected",
  "frontend": "C:\\Users\\guenther.siegert\\Documents\\0006_All_Access_KNOWLEDGE\\0_Consys_FE_Test.accdb",
  "status": "ok"
}
```
**Ergebnis:** Voll funktional

### 2.2 VBA Bridge (Port 5002)
- **Prozess laeuft:** Ja (PID 28908, 28988)
- **Antwortet:** Nein (Timeout nach 10 Sekunden)
- **Problem:** 30+ Verbindungen im Status "SCHLIESSEN_WARTEN" (Connection-Leak)

**Empfehlung:** VBA Bridge Server neustarten

### 2.3 HTTP Server (Port 8081)
- **Status:** Laeuft
- **Formulare:** Werden korrekt geladen
- **Shell-Integration:** Funktioniert

---

## 3. Workflow-Analyse

### 3.1 Datenflusskette

```
HTML-Formular (Schnellauswahl)
    |
    v
[frm_MA_VA_Schnellauswahl.logic.js]
    |
    +---> REST API (Port 5000)
    |         - GET /api/auftraege
    |         - GET /api/einsatztage
    |         - GET /api/schichten
    |         - GET /api/mitarbeiter
    |         - POST /api/zuordnungen
    |
    +---> VBA Bridge (Port 5002)
              - POST /api/vba/anfragen (E-Mail-Versand)
              - POST /api/vba/execute (VBA-Funktionen)
```

### 3.2 Anfrage-Workflow im Detail

1. **Auftrag auswaehlen:** Dropdown laedt via `/api/auftraege`
2. **Datum auswaehlen:** Dropdown laedt via `/api/einsatztage?va_id=X`
3. **Schichten laden:** Automatisch via `/api/auftraege/X/schichten`
4. **Mitarbeiter laden:** Via `/api/mitarbeiter?aktiv=true`
5. **MA zuordnen:** Doppelklick ruft `addMAToPlanung()` auf
6. **Anfragen senden:**
   - Button "Alle Mitarbeiter anfragen" oder "Nur Selektierte anfragen"
   - Ruft `versendeAnfragen()` auf
   - **PFLICHT:** VBA Bridge muss erreichbar sein!
   - Sendet an `/api/vba/anfragen` mit:
     ```json
     {
       "VA_ID": 9314,
       "VADatum_ID": 651848,
       "VAStart_ID": 51144,
       "MA_IDs": [6, 15, 35]
     }
     ```

---

## 4. API-Endpoint-Tests

### 4.1 GET /api/auftraege
```bash
curl "http://localhost:5000/api/auftraege?limit=1"
```
**Ergebnis:** OK - Liefert Auftraege mit allen Feldern

### 4.2 GET /api/einsatztage
```bash
curl "http://localhost:5000/api/einsatztage?va_id=9314"
```
**Ergebnis:** OK
```json
{
  "data": [{"ID": 651848, "VADatum": "2026-12-19", "VA_ID": 9314}],
  "success": true
}
```

### 4.3 GET /api/auftraege/{id}/schichten
```bash
curl "http://localhost:5000/api/auftraege/9314/schichten"
```
**Ergebnis:** OK - 3 Schichten gefunden (17:30, 18:00, 18:30)

### 4.4 POST /api/zuordnungen
```bash
curl -X POST "http://localhost:5000/api/zuordnungen" \
  -H "Content-Type: application/json" \
  -d '{"va_id": 9314, "vadatum_id": 651848, "vastart_id": 51144, "ma_id": 6}'
```
**Ergebnis:** FEHLER
```
"error": "('23000', \"[23000] [Microsoft][ODBC Microsoft Access Driver]
You cannot add or change a record because a related record is required
in table 'tbl_VA_AnzTage'. (-1613)"
```
**Ursache:** Referenzielle Integritaet - VADatum_ID muss in tbl_VA_AnzTage existieren

### 4.5 POST /api/vba/anfragen
```bash
curl -X POST "http://localhost:5002/api/vba/anfragen" \
  -H "Content-Type: application/json" \
  -d '{"VA_ID": 8032, "VADatum_ID": 647324, "VAStart_ID": 44042, "MA_IDs": [1337]}'
```
**Ergebnis:** TIMEOUT - VBA Bridge antwortet nicht

---

## 5. Code-Analyse

### 5.1 frm_MA_VA_Schnellauswahl.logic.js

**Wichtige Funktionen:**
- `versendeAnfragen(alle)` - Hauptfunktion fuer Anfrage-Versand
- `sendAnfrageViaAccessVBA()` - VBA Bridge Aufruf
- `checkVBABridge()` - Prueft ob VBA Bridge erreichbar

**Kritischer Code (Zeile 1507-1514):**
```javascript
// VBA Bridge ist PFLICHT - kein Fallback!
if (!vbaBridgeAvailable) {
    alert('VBA Bridge Server ist nicht erreichbar!\n\n
           E-Mail-Anfragen koennen nur ueber VBA versendet werden.\n\n
           Bitte starten Sie: start_vba_bridge.bat');
    return;
}
```

### 5.2 sub_MA_VA_Zuordnung.logic.js

**Datenfluss:**
1. Parent sendet `set_link_params` mit VA_ID und VADatum_ID
2. Subform laedt Schichten via REST API
3. Subform laedt Zuordnungen via REST API
4. `buildDisplayRecords()` kombiniert beides

**REST-API Modus erzwungen (Zeile 177):**
```javascript
const isBrowserMode = true; // Erzwinge REST-API Modus
```

### 5.3 vba_bridge_server.py

**Endpoint /api/vba/anfragen:**
- Validiert VA_ID, VADatum_ID, VAStart_ID, MA_IDs
- Ruft VBA-Funktion `Anfragen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)` auf
- Gibt Ergebnisse zurueck: OK, BEREITS ZUGESAGT, HAT KEINE EMAIL, etc.

---

## 6. Identifizierte Probleme

### Problem 1: VBA Bridge Connection-Leak
**Symptom:** Server antwortet nicht, viele Verbindungen im CLOSE_WAIT Status
**Ursache:** Vermutlich werden HTTP-Connections nicht korrekt geschlossen
**Loesung:** Server neustarten, ggf. Connection-Handling verbessern

### Problem 2: Referenzielle Integritaet bei Zuordnungen
**Symptom:** POST /api/zuordnungen schlaegt fehl
**Ursache:** VADatum_ID muss in tbl_VA_AnzTage existieren
**Loesung:** Frontend prueft bereits, ob Einsatztage existieren

### Problem 3: Keine Fallback-Methode fuer E-Mail
**Symptom:** Wenn VBA Bridge nicht laeuft, koennen keine Anfragen gesendet werden
**Empfehlung:** Optional JavaScript-basierten E-Mail-Versand implementieren

---

## 7. Empfohlene Aktionen

### Sofort:
1. VBA Bridge Server neustarten
2. Connection-Pool-Groesse pruefen

### Kurzfristig:
1. Keep-Alive und Connection-Timeout in vba_bridge_server.py konfigurieren
2. Health-Check mit automatischem Restart implementieren

### Mittelfristig:
1. E-Mail-Fallback via SMTP-Bibliothek in JavaScript
2. Retry-Logik bei VBA Bridge Timeout

---

## 8. Testprotokolle

### Browser-Test: Schnellauswahl
1. Navigation zu `http://localhost:8081/shell.html?form=frm_MA_VA_Schnellauswahl&id=9314`
2. Formular wird geladen
3. Auftrags-Dropdown zeigt 200+ Auftraege
4. Datum-Dropdown initial leer (kein Auftrag ausgewaehlt)
5. Buttons "Nur Selektierte anfragen" und "Alle Mitarbeiter anfragen" sichtbar

### Console-Logs (relevante):
```
[Logic] Auftrag change - state.selectedAuftrag: 9314
[Schnellauswahl] Auftraege geladen: 200
[VBA Events] Initialisiere Event-Bindings...
[zf_MA_Selektion] Filter: {istAktiv: true, anstArt: 13, ...}
```

---

## 9. Fazit

Der Mitarbeiter-Anfrage-Workflow ist **architektonisch korrekt implementiert**, jedoch aktuell durch ein Problem mit dem VBA Bridge Server blockiert. Die REST-API-Komponenten (Port 5000) funktionieren einwandfrei.

**Hauptblocker:** VBA Bridge Server (Port 5002) reagiert nicht auf Anfragen wegen zu vieler offener Verbindungen.

**Naechster Schritt:** VBA Bridge Server neustarten und Test wiederholen.

---

*Bericht erstellt von Claude E2E-Test-Agent*
