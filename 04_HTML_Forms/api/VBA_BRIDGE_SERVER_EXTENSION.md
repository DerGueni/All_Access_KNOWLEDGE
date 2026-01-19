# VBA Bridge Server - Button-Event Extension

**Datum:** 15.01.2026
**Status:** Implementiert
**Server:** vba_bridge_server.py (Port 5002)

## Übersicht

Der VBA Bridge Server wurde um drei neue Endpoints erweitert, um die Button-Events im Auftragstamm-Formular zu unterstützen.

## Neue Endpoints

### 1. POST /api/vba/namensliste-ess

Erstellt die Namensliste ESS (Einsatzstundenliste) für einen Auftrag.

**VBA-Funktion:** `Stundenliste_erstellen(VA_ID, MA_ID, kun_ID)`
**Modul:** `zmd_Listen.bas`

**Request Body:**
```json
{
    "VA_ID": 12345,
    "MA_ID": 0,          // optional, 0 = alle MA
    "kun_ID": 456        // Veranstalter/Kunden-ID
}
```

**Response (Erfolg):**
```json
{
    "success": true,
    "message": "Namensliste ESS erfolgreich erstellt"
}
```

**Response (Fehler):**
```json
{
    "success": false,
    "error": "Fehlermeldung"
}
```

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/namensliste-ess', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        VA_ID: state.currentAuftragId,
        MA_ID: 0,
        kun_ID: state.currentAuftrag?.Veranstalter_ID || 0
    })
});
const result = await response.json();
```

---

### 2. POST /api/vba/el-drucken

Druckt die Einsatzliste (EL) für einen Auftrag als Excel-Export.

**VBA-Funktion:** `EinsatzlisteDruckenFromHTML(VA_ID, VADatum_ID)`
**Modul:** `mod_N_HTMLButtons_Wrapper.bas`
**Backend:** Ruft `fXL_Export_Auftrag()` aus `mdl_Excel_Export.bas` auf

**Request Body:**
```json
{
    "va_id": 12345,
    "vadatum_id": 67890    // optional
}
```

**Response (Erfolg):**
```json
{
    "success": true,
    "message": "Einsatzliste erfolgreich erstellt"
}
```

**Response (Fehler):**
```json
{
    "success": false,
    "error": "Fehlermeldung"
}
```

**VBA-Rückgabewerte:**
- `>OK` - Erfolgreich
- `>FEHLER: ...` - Fehler mit Beschreibung
- `>AUFTRAG NICHT GEFUNDEN` - Auftrag existiert nicht

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/el-drucken', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        va_id: state.currentAuftragId,
        vadatum_id: state.currentVADatumId || 0
    })
});
const result = await response.json();
```

---

### 3. POST /api/vba/el-senden

Sendet die Einsatzliste (EL) per E-Mail an Mitarbeiter (Bewachungsnachweise).

**VBA-Funktion:** `SendeBewachungsnachweiseFromHTML(VA_ID, VADatum_ID)`
**Modul:** `mod_N_HTMLButtons_Wrapper.bas`
**Backend:** Ruft `SendeBewachungsnachweise()` aus `mod_N_Messezettel.bas` auf

**Request Body:**
```json
{
    "va_id": 12345,
    "vadatum_id": 67890    // optional
}
```

**Response (Erfolg):**
```json
{
    "success": true,
    "message": "Einsatzliste erfolgreich gesendet"
}
```

**Response (Fehler):**
```json
{
    "success": false,
    "error": "Fehlermeldung"
}
```

**VBA-Rückgabewerte:**
- `>OK` - Erfolgreich
- `>OK (nicht implementiert)` - Funktion noch nicht vollständig implementiert
- `>OK (Formular nicht offen)` - Formular nicht geöffnet, aber kein Fehler
- `>FEHLER: ...` - Fehler mit Beschreibung

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/el-senden', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        va_id: state.currentAuftragId,
        vadatum_id: state.currentVADatumId || 0
    })
});
const result = await response.json();
```

---

## Server-Anforderungen

### 1. Access MUSS geöffnet sein
Der VBA Bridge Server benötigt eine laufende Access-Instanz mit dem Frontend:
- **Frontend:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb`
- **Backend:** `\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb`

### 2. VBA-Module MÜSSEN importiert sein
Folgende VBA-Module müssen im Frontend vorhanden sein:
- `mod_N_HTMLButtons_Wrapper.bas` - Wrapper-Funktionen für HTML-Buttons
- `mod_N_Messezettel.bas` - Bewachungsnachweise und PDF-Funktionen
- `mdl_Excel_Export.bas` - Excel-Export-Funktionen
- `zmd_Listen.bas` - Stundenlisten-Generierung

### 3. win32com Python-Package
```bash
pip install pywin32
```

---

## Server starten

### Manueller Start:
```bash
cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api
python vba_bridge_server.py
```

### Start via Batch:
```bash
start_vba_bridge.bat
```

### Start via VBS (versteckt):
```vbs
start_vba_bridge_silent.vbs
```

---

## Health-Check

Prüfen ob der Server läuft:

```bash
curl http://localhost:5002/api/health
```

**Response:**
```json
{
    "status": "ok",
    "port": 5002,
    "service": "vba-bridge"
}
```

Prüfen ob Access verbunden ist:

```bash
curl http://localhost:5002/api/vba/status
```

**Response:**
```json
{
    "status": "running",
    "port": 5002,
    "win32com_available": true,
    "access_connected": true,
    "access_database": "C:\\...\\0_Consys_FE_Test.accdb",
    "timestamp": "2026-01-15T10:30:00"
}
```

---

## Error-Handling

### Fehlertypen:

1. **Server nicht erreichbar**
   - Status: Connection refused
   - Lösung: Server starten

2. **Access nicht geöffnet**
   - `"access_connected": false`
   - Lösung: Access Frontend öffnen

3. **VBA-Funktion nicht gefunden**
   - Error: "Name not found: 'FunktionsName'"
   - Lösung: VBA-Modul importieren und kompilieren

4. **win32com nicht verfügbar**
   - `"win32com_available": false`
   - Lösung: `pip install pywin32`

5. **VBA-Laufzeitfehler**
   - Error: VBA-Fehlermeldung aus Access
   - Lösung: VBA-Code debuggen in Access

---

## Logging

Der Server loggt alle Aktionen in:
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\vba_bridge.log
```

**Log-Format:**
```
[2026-01-15 10:30:00] === /api/vba/namensliste-ess aufgerufen ===
[2026-01-15 10:30:00] Erstelle Namensliste ESS: VA_ID=12345, MA_ID=0, kun_ID=456
[2026-01-15 10:30:01] VBA Eval: Stundenliste_erstellen(12345, 0, 456)
[2026-01-15 10:30:05] VBA Ergebnis: True
[2026-01-15 10:30:05] Namensliste ESS erfolgreich erstellt
```

---

## Integration im HTML-Formular

Das Auftragstamm-Formular (`frm_va_Auftragstamm.html`) nutzt die Endpoints wie folgt:

### 1. Namensliste ESS Button
```javascript
async function namenslisteESS() {
    if (!state.currentAuftragId) {
        showToast('Bitte zuerst einen Auftrag auswählen', 'warning');
        return;
    }

    showToast('Namensliste ESS wird erstellt...', 'info');

    const kunId = state.currentAuftrag?.Veranstalter_ID || 0;

    try {
        const response = await fetch('http://localhost:5002/api/vba/namensliste-ess', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                VA_ID: state.currentAuftragId,
                MA_ID: 0,
                kun_ID: kunId
            })
        });

        const result = await response.json();

        if (result.success) {
            showToast('Namensliste ESS erfolgreich erstellt', 'success');
        } else {
            showToast(`Fehler: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error('Fehler bei Namensliste ESS:', error);
        showToast('Verbindung zum VBA Bridge Server fehlgeschlagen', 'error');
    }
}
```

### 2. EL drucken Button
```javascript
async function einsatzlisteDrucken() {
    if (!state.currentAuftragId) {
        showToast('Bitte zuerst einen Auftrag auswählen', 'warning');
        return;
    }

    showToast('Einsatzliste wird erstellt...', 'info');

    try {
        const response = await fetch('http://localhost:5002/api/vba/el-drucken', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                va_id: state.currentAuftragId,
                vadatum_id: state.currentVADatumId || 0
            })
        });

        const result = await response.json();

        if (result.success) {
            showToast('Einsatzliste erfolgreich erstellt', 'success');
        } else {
            showToast(`Fehler: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error('Fehler beim Drucken:', error);
        showToast('Verbindung zum VBA Bridge Server fehlgeschlagen', 'error');
    }
}
```

### 3. EL senden Button
```javascript
async function sendeEinsatzlisteMA() {
    if (!state.currentAuftragId) {
        showToast('Bitte zuerst einen Auftrag auswählen', 'warning');
        return;
    }

    showToast('Einsatzliste wird gesendet...', 'info');

    try {
        const response = await fetch('http://localhost:5002/api/vba/el-senden', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                va_id: state.currentAuftragId,
                vadatum_id: state.currentVADatumId || 0
            })
        });

        const result = await response.json();

        if (result.success) {
            showToast('Einsatzliste erfolgreich gesendet', 'success');
        } else {
            showToast(`Fehler: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error('Fehler beim Senden:', error);
        showToast('Verbindung zum VBA Bridge Server fehlgeschlagen', 'error');
    }
}
```

---

## Test-Szenario

### 1. Server starten
```bash
cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api
python vba_bridge_server.py
```

### 2. Access öffnen
- Frontend: `0_Consys_FE_Test.accdb` öffnen
- Backend-Verbindung prüfen

### 3. Health-Check
```bash
curl http://localhost:5002/api/vba/status
```

Erwartete Antwort:
```json
{
    "access_connected": true,
    "access_database": "...\\0_Consys_FE_Test.accdb"
}
```

### 4. HTML-Formular öffnen
- Browser: `http://localhost:5000` (API Server)
- Shell öffnen: `shell.html`
- Auftragstamm öffnen mit gültiger VA_ID

### 5. Button-Tests
1. **Namensliste ESS** Button klicken
   - Toast: "Namensliste ESS wird erstellt..."
   - Nach 2-5 Sekunden: "Erfolgreich erstellt"
   - Excel-Datei wird geöffnet

2. **EL drucken** Button klicken
   - Toast: "Einsatzliste wird erstellt..."
   - Excel-Export wird erstellt im Consys-Verzeichnis
   - Toast: "Erfolgreich erstellt"

3. **EL senden** Button klicken (optional)
   - Toast: "Einsatzliste wird gesendet..."
   - E-Mails werden via Outlook versendet
   - Toast: "Erfolgreich gesendet"

---

## Bekannte Einschränkungen

1. **Access MUSS geöffnet sein**
   - Ohne Access-Instanz funktionieren die VBA-Aufrufe nicht
   - Server gibt dann "Access nicht geöffnet" zurück

2. **Nur ein Benutzer gleichzeitig**
   - Der Server verbindet sich mit der ERSTEN Access-Instanz
   - Mehrere Benutzer am selben PC sind nicht unterstützt

3. **Excel-Export blockiert**
   - Während Excel-Export läuft, reagiert Access nicht
   - Große Aufträge (>100 MA) können 10-30 Sekunden dauern

4. **E-Mail-Versand**
   - Benötigt installiertes Outlook
   - Benutzer muss Outlook-Berechtigung erteilen
   - Bei vielen Mails (>50) kann Outlook timeout

5. **Keine Echtzeit-Updates**
   - HTML-Formular weiß nicht, wann Excel fertig ist
   - Nur Toast-Meldung nach VBA-Aufruf

---

## Nächste Schritte

### OFFEN:
- [ ] HTML-Button-Integration testen
- [ ] Fehlerbehandlung bei timeout
- [ ] Progress-Indicator für lange Excel-Exports
- [ ] E-Mail-Status in HTML zurückmelden

### FERTIG:
- [x] Endpoints implementiert (15.01.2026)
- [x] VBA-Wrapper-Funktionen existieren
- [x] Logging eingebaut
- [x] Error-Handling implementiert
- [x] Dokumentation erstellt

---

**Ende der Dokumentation**
