# DEBUGGING GUIDE - VBA-HTML Button Integration

**Version:** 1.0
**Datum:** 15.01.2026
**Zielgruppe:** Entwickler & Support

---

## ÜBERSICHT

Dieser Guide hilft bei der Fehlersuche und Problembehebung der VBA-HTML Button Integration.

**Betroffene Komponenten:**
1. **Access Frontend** - `0_Consys_FE_Test.accdb`
2. **API Server** - `api_server.py` (Port 5000)
3. **VBA Bridge Server** - `vba_bridge_server.py` (Port 5002)
4. **HTML Formulare** - `forms3/*.html` + `logic/*.logic.js`
5. **VBA Module** - `zmd_Mail.bas`, `mod_N_HTMLButtons.bas`

---

## SYSTEMATISCHES DEBUGGING

### Phase 1: System-Status prüfen

#### 1.1 Server-Status

```bash
# API Server (Port 5000)
curl http://localhost:5000/api/health
# Expected: {"status":"ok","timestamp":"..."}

# VBA Bridge Server (Port 5002)
curl http://localhost:5002/api/health
# Expected: {"status":"ok","port":5002,"service":"vba-bridge"}

# VBA Status (Access-Verbindung)
curl http://localhost:5002/api/vba/status
# Expected: {"access_open":true,"access_connected":true,"frontend":"0_Consys_FE_Test.accdb"}
```

**Fehlerfall: Connection Refused**
```
curl: (7) Failed to connect to localhost port 5000: Connection refused
```
→ Server läuft nicht! Starten mit:
```bash
# API Server
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py

# VBA Bridge Server
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py
```

**Fehlerfall: Access nicht verbunden**
```json
{"access_open":false,"access_connected":false,"frontend":null}
```
→ Access ist nicht geöffnet oder COM-Verbindung fehlgeschlagen!

#### 1.2 Process-Status prüfen

```bash
# Windows: Laufende Python-Prozesse
netstat -ano | findstr :5000
netstat -ano | findstr :5002

# Prozess-Details (PID aus netstat)
tasklist | findstr [PID]
```

**Erwartete Ausgabe:**
```
TCP    127.0.0.1:5000    0.0.0.0:0    LISTENING    12345
TCP    127.0.0.1:5002    0.0.0.0:0    LISTENING    67890
```

#### 1.3 Access-Status prüfen

**VBA Direktfenster (Strg+G in Access):**
```vba
' Prüfen ob Modul existiert
?CurrentDb.AllModules("zmd_Mail").Name
' Expected: "zmd_Mail"

' Prüfen ob Funktion existiert
?TypeName(Application.Run("MA_Anfragen_Email_Send", 1, 2, 3, Array(1,2,3), True))
' Expected: "String" oder Wert

' Outlook verfügbar?
?CreateObject("Outlook.Application").Name
' Expected: "Outlook"
```

### Phase 2: Request-Flow tracen

#### 2.1 Browser → VBA Bridge → Access

**Browser Console (F12):**
```javascript
// Enable verbose logging
localStorage.setItem('debug', 'true');

// Reload page
location.reload();

// Check logs
// Expected: [Debug] Empfangene Parameter: VA_ID=..., VADatum_ID=..., VAStart_ID=...
```

**Network-Tab (F12 > Network):**
1. Filter auf "Fetch/XHR"
2. Button klicken
3. Request zu `localhost:5002` suchen
4. Klicken → Request/Response Details

**Erfolgreicher Request:**
```
Request URL: http://localhost:5002/api/vba/anfragen
Request Method: POST
Status Code: 200 OK

Request Payload:
{
  "VA_ID": 12345,
  "VADatum_ID": 67890,
  "VAStart_ID": 111,
  "MA_IDs": [1, 2, 3],
  "selectedOnly": true
}

Response:
{
  "success": true,
  "message": "E-Mail-Anfrage erfolgreich gesendet",
  "count": 3
}
```

**Fehlerfall: 500 Internal Server Error**
```
Response:
{
  "success": false,
  "error": "Fehler beim Ausführen der VBA-Funktion",
  "details": "..."
}
```
→ Siehe Server-Logs!

#### 2.2 VBA Bridge Server Logs

**Terminal-Ausgabe beobachten:**
```
[2026-01-15 17:00:00] INFO: Server gestartet auf Port 5002
[2026-01-15 17:00:05] INFO: Access verbunden: 0_Consys_FE_Test.accdb
[2026-01-15 17:00:10] POST /api/vba/anfragen - Params: {...}
[2026-01-15 17:00:10] INFO: Führe VBA-Funktion aus: MA_Anfragen_Email_Send
[2026-01-15 17:00:12] INFO: VBA-Funktion erfolgreich: E-Mail-Anfrage gesendet
[2026-01-15 17:00:12] Response 200: {"success":true,...}
```

**Fehlerfall: VBA-Fehler**
```
[2026-01-15 17:00:10] ERROR: VBA-Funktion fehlgeschlagen
[2026-01-15 17:00:10] ERROR: Traceback:
  File "vba_bridge_server.py", line 123, in execute_vba
    result = self.access_app.Run(function_name, *args)
  pywintypes.com_error: (-2147352567, 'Exception occurred.', ...)
```
→ Siehe VBA-Fehler in Access!

#### 2.3 VBA-Fehler in Access

**VBA-Fehlerbehandlung aktivieren:**
```vba
' In zmd_Mail.bas: MA_Anfragen_Email_Send
On Error GoTo ErrorHandler

' ... Code ...

ErrorHandler:
    Debug.Print "VBA-Fehler: " & Err.Number & " - " & Err.Description
    Debug.Print "   Source: " & Err.Source
    Debug.Print "   VA_ID: " & VA_ID
    Debug.Print "   MA_IDs: " & Join(MA_IDs, ", ")
    MsgBox "Fehler: " & Err.Description, vbCritical
    Exit Function
```

**Häufige VBA-Fehler:**

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| 91 - Object variable not set | `Set olApp = Nothing` vor Verwendung | Outlook-Init prüfen |
| 438 - Object doesn't support property/method | Falsche Methode aufgerufen | Methodennamen prüfen |
| 5 - Invalid procedure call | Falsche Parameter | Parameter-Typen prüfen |
| 9 - Subscript out of range | Array-Index ungültig | MA_IDs Array prüfen |
| 13 - Type mismatch | Falscher Datentyp | Variant → Long/String |

---

## HÄUFIGE PROBLEME & LÖSUNGEN

### Problem 1: Button macht nichts (keine Reaktion)

**Symptome:**
- Button-Click erzeugt kein Toast
- Keine Console-Logs
- Keine Network-Requests

**Debug-Schritte:**

1. **Browser-Console öffnen (F12)**
   ```javascript
   // Prüfen ob Event-Listener registriert sind
   document.querySelector('#btnAnfragen')
   // Expected: <button id="btnAnfragen" ...>

   // Manuell testen
   document.querySelector('#btnAnfragen').click()
   ```

2. **JavaScript-Fehler suchen**
   - Rote Fehler in Console?
   - Syntax-Fehler in `.logic.js`?
   - Fehlende Variablen?

3. **Cache leeren**
   ```
   Strg + Shift + Entf → Cache löschen → Seite neu laden
   ```

4. **Script-Loading prüfen**
   ```html
   <!-- In HTML: Ist logic.js geladen? -->
   <script src="logic/frm_MA_VA_Schnellauswahl.logic.js"></script>
   ```
   → Network-Tab: 200 OK oder 404 Not Found?

**Lösung:**
- Häufig: **Cache-Problem** → Cache leeren
- Oder: **Pfad falsch** → Script nicht gefunden (404)

### Problem 2: Toast "Verbindung zum VBA-Server fehlgeschlagen"

**Symptome:**
- Button-Click erzeugt roten Toast
- Console: `Failed to fetch`
- Network: Request zu localhost:5002 fehlgeschlagen

**Debug-Schritte:**

1. **Server-Status prüfen**
   ```bash
   curl http://localhost:5002/api/health
   ```
   - Connection Refused? → Server läuft nicht!
   - 200 OK? → Server läuft, aber Access-Verbindung prüfen!

2. **Firewall prüfen**
   ```bash
   # Windows Firewall: Python erlauben?
   netsh advfirewall firewall show rule name=all | findstr Python
   ```

3. **Port bereits belegt?**
   ```bash
   netstat -ano | findstr :5002
   ```
   - Anderer Prozess auf Port 5002? → Port ändern oder Prozess beenden

**Lösung:**
```bash
# Server (neu) starten
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py

# Warten bis: "Server gestartet auf Port 5002"
```

### Problem 3: Toast "Access ist nicht geöffnet"

**Symptome:**
- Server läuft
- Response: `{"access_open":false}`
- VBA-Funktion wird nicht ausgeführt

**Debug-Schritte:**

1. **Access-Status prüfen**
   ```bash
   curl http://localhost:5002/api/vba/status
   ```
   Response analysieren:
   ```json
   {
     "access_open": false,  // Access nicht geöffnet!
     "access_connected": false,
     "frontend": null,
     "error": "Access-Anwendung nicht gefunden"
   }
   ```

2. **COM-Verbindung prüfen**
   ```python
   # In Python-Shell
   import win32com.client
   app = win32com.client.GetObject(None, "Access.Application")
   print(app.CurrentDb().Name)
   # Expected: "0_Consys_FE_Test.accdb"
   ```
   - Fehler? → Access COM-Interface nicht registriert

3. **Access-Version prüfen**
   - VBA Bridge unterstützt Access 2016+
   - Access im "Sandbox"-Modus? → Makros deaktiviert?

**Lösung:**
1. Access öffnen: `0_Consys_FE_Test.accdb`
2. Makros aktivieren (gelber Balken oben)
3. VBA Bridge neu starten

### Problem 4: VBA-Funktion schlägt fehl (500 Error)

**Symptome:**
- Server läuft, Access verbunden
- Response: 500 Internal Server Error
- Server-Logs: "VBA-Funktion fehlgeschlagen"

**Debug-Schritte:**

1. **Server-Logs analysieren**
   ```
   ERROR: VBA-Funktion fehlgeschlagen
   ERROR: pywintypes.com_error: (-2147352567, 'Exception occurred.', ...)
   ```
   → VBA-Fehler in Access!

2. **VBA-Fehler reproduzieren**
   ```vba
   ' In Access VBA Direktfenster (Strg+G)
   ?MA_Anfragen_Email_Send(12345, 67890, 111, Array(1,2,3), True)

   ' Fehler? → Debugger startet → F8 (Step Into)
   ```

3. **Häufige VBA-Fehler:**
   - **Outlook nicht geöffnet** → `Set olApp = CreateObject("Outlook.Application")` schlägt fehl
   - **Falscher Parameter-Typ** → MA_IDs ist kein Array
   - **Fehlende Tabellen-Daten** → Query liefert keine Daten

4. **Parameter-Typen prüfen**
   ```vba
   Debug.Print TypeName(VA_ID)          ' Expected: Long
   Debug.Print TypeName(VADatum_ID)     ' Expected: Long
   Debug.Print TypeName(MA_IDs)         ' Expected: Variant() oder Long()
   Debug.Print UBound(MA_IDs) - LBound(MA_IDs) + 1  ' Anzahl Elemente
   ```

**Lösung:**
- **Outlook starten** → `CreateObject("Outlook.Application")` funktioniert
- **Parameter-Typen korrigieren** → Python: `int()` statt `str()`
- **VBA-Code korrigieren** → Fehlerbehandlung verbessern

### Problem 5: Outlook öffnet nicht / E-Mail fehlt

**Symptome:**
- Toast zeigt "Erfolgreich gesendet"
- Aber: Outlook öffnet sich nicht
- Oder: E-Mail fehlt in Outlook

**Debug-Schritte:**

1. **Outlook-Status prüfen**
   ```vba
   ' In Access VBA Direktfenster
   Set olApp = CreateObject("Outlook.Application")
   ?olApp.Name
   ' Expected: "Outlook"

   Set olMail = olApp.CreateItem(0)
   olMail.Display  ' Öffnet leere E-Mail
   ```

2. **E-Mail-Erstellung tracen**
   ```vba
   ' In zmd_Mail.bas: MA_Anfragen_Email_Send
   Debug.Print "Outlook initialisiert"
   Set olMail = olApp.CreateItem(0)
   Debug.Print "E-Mail erstellt"

   ' Empfänger hinzufügen
   For Each ma In MA_Liste
       Debug.Print "Füge hinzu: " & ma!Email
       olMail.Recipients.Add ma!Email
   Next
   Debug.Print "Empfänger hinzugefügt: " & olMail.Recipients.Count

   olMail.Display
   Debug.Print "E-Mail angezeigt"
   ```

3. **Häufige Ursachen:**
   - **Outlook im Hintergrund** → E-Mail erstellt, aber nicht sichtbar
   - **Empfänger-Fehler** → Ungültige E-Mail-Adresse blockiert `.Display`
   - **Security-Warning** → Outlook blockiert programmatischen Zugriff

**Lösung:**
- **Outlook in Vordergrund bringen**
  ```vba
  olApp.ActiveWindow.Activate
  ```
- **E-Mail-Adressen validieren**
  ```vba
  If Not IsNull(ma!Email) And Len(ma!Email) > 0 Then
      olMail.Recipients.Add ma!Email
  End If
  ```
- **Security-Warnung umgehen** → Redemption-DLL verwenden (für Produktiv)

### Problem 6: Daten nicht synchronisiert (falsche Werte)

**Symptome:**
- Button funktioniert, aber E-Mail enthält falsche Daten
- Falsche Mitarbeiter-Namen / Auftragsnummer / Datum

**Debug-Schritte:**

1. **Parameter-Übergabe prüfen**
   ```javascript
   // Browser Console
   console.log('VA_ID:', params.get('va_id'));
   console.log('VADatum_ID:', params.get('vadatum_id'));
   console.log('VAStart_ID:', params.get('vastart_id'));
   ```
   → Werte korrekt aus Access übergeben?

2. **API-Daten prüfen**
   ```bash
   # Mitarbeiter-Liste
   curl "http://localhost:5000/api/mitarbeiter?aktiv=true"

   # Auftragsdaten
   curl "http://localhost:5000/api/auftraege/12345"

   # Schichten
   curl "http://localhost:5000/api/auftraege/12345/schichten?vadatum_id=67890"
   ```
   → Daten aus DB korrekt?

3. **VBA-Query prüfen**
   ```vba
   ' In Access VBA Direktfenster
   Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID=1")
   ?rs!Nachname, rs!Vorname, rs!Tel_Mobil
   ```
   → Daten in Access-DB korrekt?

**Lösung:**
- **Parameter-Namen prüfen** → Case-Sensitive! `VA_ID` ≠ `va_id`
- **API-Endpoints korrigieren** → Falsche JOINs / WHERE-Klauseln
- **Cache leeren** → Alte Daten gecacht

---

## LOGGING & MONITORING

### Browser-Console aktivieren

**Persistent Logging:**
```javascript
// In Browser Console (F12)
localStorage.setItem('debug', 'true');
location.reload();
```

**Custom Logger:**
```javascript
// In .logic.js
window.DEBUG = true;

function log(...args) {
    if (window.DEBUG) {
        console.log('[Debug]', ...args);
    }
}

log('Button geklickt', { VA_ID, VADatum_ID });
```

### Server-Logging erweitern

**vba_bridge_server.py:**
```python
import logging

# Logging konfigurieren
logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s] %(levelname)s: %(message)s',
    handlers=[
        logging.FileHandler('vba_bridge.log'),
        logging.StreamHandler()
    ]
)

# In Routen
@app.route('/api/vba/anfragen', methods=['POST'])
def anfragen():
    data = request.get_json()
    logging.debug(f"Anfragen-Request: {data}")

    try:
        result = access_bridge.run_vba(...)
        logging.info(f"VBA-Result: {result}")
        return jsonify({'success': True, ...})
    except Exception as e:
        logging.error(f"VBA-Fehler: {e}", exc_info=True)
        return jsonify({'success': False, 'error': str(e)}), 500
```

### VBA-Logging

**Debug-Prints in zmd_Mail.bas:**
```vba
Public Function MA_Anfragen_Email_Send(...) As String
    On Error GoTo ErrorHandler

    Debug.Print "=== MA_Anfragen_Email_Send START ==="
    Debug.Print "   VA_ID: " & VA_ID
    Debug.Print "   VADatum_ID: " & VADatum_ID
    Debug.Print "   MA_IDs Count: " & UBound(MA_IDs) - LBound(MA_IDs) + 1

    ' ... Code ...

    Debug.Print "   Outlook initialisiert"
    Debug.Print "   E-Mail erstellt"
    Debug.Print "   Empfänger hinzugefügt: " & olMail.Recipients.Count
    Debug.Print "   E-Mail angezeigt"

    Debug.Print "=== MA_Anfragen_Email_Send END ==="
    Exit Function

ErrorHandler:
    Debug.Print "=== MA_Anfragen_Email_Send ERROR ==="
    Debug.Print "   Err.Number: " & Err.Number
    Debug.Print "   Err.Description: " & Err.Description
    Debug.Print "   Err.Source: " & Err.Source
End Function
```

### Log-Dateien

**Speicherorte:**
```
API Server:           C:\Users\guenther.siegert\Documents\Access Bridge\api_server.log
VBA Bridge:           C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\vba_bridge.log
Browser:              F12 > Console (nicht persistent)
Access VBA:           Direktfenster (Strg+G) → nur aktuell
```

---

## PERFORMANCE-DEBUGGING

### Langsame Response-Zeiten

**Symptome:**
- Button-Click → Toast erscheint erst nach >5 Sekunden
- Outlook öffnet spät
- Browser wirkt "hängend"

**Debug-Schritte:**

1. **Network-Timing prüfen**
   ```
   Browser F12 > Network > Request anklicken > Timing-Tab

   - Queueing: Zeit in Browser-Queue (sollte <10ms sein)
   - Stalled: Zeit bis Request startet (sollte <50ms sein)
   - DNS Lookup: DNS-Auflösung (sollte 0ms sein für localhost)
   - Initial connection: TCP-Verbindung (sollte <10ms sein)
   - Waiting (TTFB): Zeit bis erster Response-Byte (KRITISCH!)
   - Content Download: Download-Zeit (sollte <10ms sein)
   ```

2. **TTFB (Time To First Byte) analysieren**
   - **<500ms** = Gut
   - **500-2000ms** = Akzeptabel
   - **>2000ms** = PROBLEM! → VBA-Funktion zu langsam

3. **VBA-Performance messen**
   ```vba
   Public Function MA_Anfragen_Email_Send(...) As String
       Dim startTime As Double
       startTime = Timer

       ' ... Code ...

       Debug.Print "Ausführungszeit: " & Format(Timer - startTime, "0.000") & " Sekunden"
   End Function
   ```

4. **Bottleneck identifizieren**
   ```vba
   Debug.Print "1. Outlook Init: " & Format(Timer - startTime, "0.000") & "s"
   Set olApp = CreateObject("Outlook.Application")
   Debug.Print "2. Query laden: " & Format(Timer - startTime, "0.000") & "s"
   Set rs = CurrentDb.OpenRecordset(sql)
   Debug.Print "3. Empfänger hinzufügen: " & Format(Timer - startTime, "0.000") & "s"
   ' ...
   ```

**Häufige Bottlenecks:**
- **Outlook-Init** (500-1000ms) → CreateObject ist langsam
- **Große Queries** (>1000ms) → DB-Abfrage optimieren (Index!)
- **Viele Empfänger** (>2000ms) → Recipients.Add in Schleife

**Optimierungen:**
```vba
' VORHER: Outlook jedes Mal neu erstellen (langsam)
Set olApp = CreateObject("Outlook.Application")

' NACHHER: Outlook einmal erstellen, wiederverwenden
Static olApp As Object
If olApp Is Nothing Then
    Set olApp = CreateObject("Outlook.Application")
End If

' VORHER: Empfänger einzeln hinzufügen
For Each ma In rs
    olMail.Recipients.Add ma!Email
Next

' NACHHER: Empfänger als String sammeln und einmal hinzufügen
Dim emailList As String
For Each ma In rs
    emailList = emailList & ma!Email & ";"
Next
olMail.BCC = Left(emailList, Len(emailList) - 1)  ' Letztes ";" entfernen
```

---

## TESTING-STRATEGIEN

### Unit-Tests (VBA)

**Test einzelner VBA-Funktionen:**
```vba
' In mod_N_Tests.bas
Public Sub Test_MA_Anfragen_Email_Send()
    Dim result As String
    Dim testMA_IDs() As Long

    ' Arrange
    ReDim testMA_IDs(0 To 2)
    testMA_IDs(0) = 1
    testMA_IDs(1) = 2
    testMA_IDs(2) = 3

    ' Act
    result = MA_Anfragen_Email_Send(12345, 67890, 111, testMA_IDs, True)

    ' Assert
    Debug.Assert Len(result) > 0
    Debug.Print "Test_MA_Anfragen_Email_Send: PASSED"
End Sub
```

### Integration-Tests (curl)

**Test kompletter Request-Flow:**
```bash
# Test 1: Health-Check
curl -s http://localhost:5002/api/health | jq

# Test 2: VBA-Status
curl -s http://localhost:5002/api/vba/status | jq

# Test 3: Anfragen senden (mit echten IDs!)
curl -X POST http://localhost:5002/api/vba/anfragen \
  -H "Content-Type: application/json" \
  -d '{"VA_ID":12345,"VADatum_ID":67890,"VAStart_ID":111,"MA_IDs":[1,2,3],"selectedOnly":true}' \
  | jq

# Expected: {"success":true,"message":"...","count":3}
```

### End-to-End Tests (manuell)

**Checkliste:**
- [ ] Access öffnen, Formular laden
- [ ] HTML-Ansicht öffnen
- [ ] Mitarbeiter auswählen
- [ ] Button klicken
- [ ] Toast prüfen
- [ ] Outlook prüfen
- [ ] E-Mail prüfen (Empfänger, Betreff, Text)
- [ ] E-Mail senden (optional)

---

## TROUBLESHOOTING-CHECKLISTE

**Bei JEDEM Problem durchgehen:**

1. [ ] **Server laufen?**
   - `curl http://localhost:5000/api/health`
   - `curl http://localhost:5002/api/health`

2. [ ] **Access geöffnet?**
   - `curl http://localhost:5002/api/vba/status`
   - `access_open: true`?

3. [ ] **Browser-Cache geleert?**
   - Strg+Shift+Entf → Cache löschen

4. [ ] **VBA kompiliert?**
   - Access: Debug > Compile VBA Project

5. [ ] **Console-Logs geprüft?**
   - F12 > Console → Rote Fehler?

6. [ ] **Network-Requests geprüft?**
   - F12 > Network → 404 / 500 Errors?

7. [ ] **VBA Direktfenster geprüft?**
   - Strg+G in Access → Fehlermeldungen?

8. [ ] **Server-Logs geprüft?**
   - Terminal-Ausgabe → Errors?

---

## KONTAKT & SUPPORT

**Bei unlösbaren Problemen:**

1. **Log-Dateien sammeln:**
   - Browser-Console (Screenshot)
   - Network-Tab (Screenshot)
   - Server-Logs (Textdatei)
   - VBA Direktfenster (Screenshot)

2. **Problem beschreiben:**
   - Welches Formular?
   - Welcher Button?
   - Was haben Sie gemacht?
   - Was war die Fehlermeldung?
   - Wann trat das Problem auf?

3. **Kontakt:**
   - IT-Support: [E-Mail/Telefon]
   - Entwickler: Günther Siegert

---

**Ende des Debugging Guides**
