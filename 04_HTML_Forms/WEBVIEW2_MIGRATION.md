# WebView2 Migration - Auftragsformulare

## Übersicht

Die Auftragsformulare wurden von REST API (localhost:5000) auf **WebView2-Bridge** umgestellt für direkte Kommunikation mit Access-Backend.

## Umgestellte Formulare

### Hauptformulare
1. **frm_va_Auftragstamm.html** + `.logic.js`
   - Auftragsverwaltung Hauptformular
   - Import geändert: `../api/bridgeClient.js` → `../js/webview2-bridge.js`
   - Alle Bridge-Aufrufe bleiben API-kompatibel

2. **frm_va_AuftragstammALT.html**
   - Legacy-Version des Auftragsformulars
   - WebView2-Bridge eingebunden

3. **frm_OB_Objekt.html** + `.logic.js`
   - Objektverwaltung
   - Import geändert: `../api/bridgeClient.js` → `../js/webview2-bridge.js`
   - Alle CRUD-Operationen über Bridge

## Neue Datei

### webview2-bridge.js
**Pfad:** `04_HTML_Forms\NEUHTML\02_web\js\webview2-bridge.js`

#### Features
- Direkte Kommunikation mit Access via `window.chrome.webview`
- API-kompatibel zu `bridgeClient.js` (gleiche Methoden)
- Event-System für bidirektionale Kommunikation
- Request/Response-Pattern mit Promise-Support
- Timeout-Handling (30 Sekunden)

#### Hauptmethoden
```javascript
// Daten laden
await Bridge.loadData('auftrag', 123);

// Liste abrufen
await Bridge.list('auftraege', { limit: 50 });

// Speichern
await Bridge.save('auftrag', formData);

// Löschen
await Bridge.delete('auftrag', 123);

// Suche
await Bridge.search('auftraege', 'NERVY');

// Navigation
Bridge.navigate('frm_MA_Mitarbeiterstamm', 456);

// Events
Bridge.on('onDataReceived', (data) => { ... });
```

#### Execute-API (Kompatibilität)
```javascript
// Funktioniert weiterhin:
await Bridge.execute('getAuftrag', { id: 123 });
await Bridge.execute('saveAuftrag', auftragData);
await Bridge.execute('deleteAuftrag', { id: 123 });
```

#### Direktzugriff-API
```javascript
// Objekt-orientierte API:
await Bridge.auftraege.list({ limit: 50 });
await Bridge.auftraege.get(123);
await Bridge.auftraege.create(data);
await Bridge.auftraege.update(123, data);
await Bridge.auftraege.delete(123);

// Weitere Endpoints:
Bridge.mitarbeiter.*
Bridge.kunden.*
Bridge.objekte.*
```

## Änderungen im Detail

### 1. frm_va_Auftragstamm.logic.js
**Vorher:**
```javascript
import { Bridge } from '../api/bridgeClient.js';
```

**Nachher:**
```javascript
import { Bridge } from '../js/webview2-bridge.js';
```

**Keine weiteren Code-Änderungen nötig** - Bridge-API ist kompatibel!

### 2. frm_OB_Objekt.logic.js
**Vorher:**
```javascript
import { Bridge } from '../api/bridgeClient.js';
```

**Nachher:**
```javascript
import { Bridge } from '../js/webview2-bridge.js';
```

### 3. HTML-Formulare
**Script-Import hinzugefügt:**
```html
<!-- WebView2 Bridge -->
<script type="module" src="../js/webview2-bridge.js"></script>
<!-- Logic-Modul einbinden -->
<script type="module" src="frm_va_Auftragstamm.logic.js"></script>
```

## WebView2 Message-Format

### Request (HTML → Access)
```javascript
{
    requestId: 1234,
    action: "loadData",
    params: {
        type: "auftrag",
        id: 123
    }
}
```

### Response (Access → HTML)
```javascript
{
    requestId: 1234,
    data: {
        VA_ID: 123,
        VA_Bezeichnung: "NERVY Nürnberg",
        VA_Ort: "Nürnberg",
        ...
    }
}
```

### Error Response
```javascript
{
    requestId: 1234,
    error: "Auftrag nicht gefunden"
}
```

### Event (Access → HTML)
```javascript
{
    event: "onDataReceived",
    data: {
        auftrag: { ... }
    }
}
```

## Access-seitige Implementierung (VBA)

Die Access-Seite muss folgende VBA-Funktionen implementieren:

```vba
' In WebView2-Host-Modul
Private Sub WebView_WebMessageReceived(ByVal message As String)
    Dim json As Object
    Set json = ParseJSON(message)

    Select Case json("action")
        Case "loadData"
            HandleLoadData json("requestId"), json("params")
        Case "save"
            HandleSave json("requestId"), json("params")
        Case "delete"
            HandleDelete json("requestId"), json("params")
        Case "list"
            HandleList json("requestId"), json("params")
    End Select
End Sub

Private Sub HandleLoadData(reqId As Long, params As Object)
    Dim data As String
    ' Daten aus Access laden
    data = LoadDataFromAccess(params("type"), params("id"))

    ' Response senden
    WebView.PostWebMessageAsJson "{""requestId"":" & reqId & ",""data"":" & data & "}"
End Sub
```

## Vorteile der WebView2-Bridge

1. **Kein REST API Server nötig** - Direkte Kommunikation
2. **Schneller** - Kein HTTP-Overhead
3. **Sicherer** - Keine offenen Ports
4. **Offline-fähig** - Funktioniert ohne Netzwerk
5. **Einfacher Deployment** - Eine exe-Datei

## Rückwärtskompatibilität

Die Bridge ist **vollständig kompatibel** zur alten REST API:
- Alle `Bridge.execute()` Aufrufe funktionieren
- Alle Direktzugriff-APIs (`Bridge.auftraege.*`) funktionieren
- Keine Logic-Code-Änderungen außer Import nötig

## Testing

1. Formular in WebView2-Host öffnen
2. Prüfen ob `window.chrome.webview` verfügbar
3. Auftrag laden: `Bridge.loadData('auftrag', 123)`
4. Console-Logs prüfen
5. Response-Daten validieren

## Nächste Schritte

1. Access VBA-Host implementieren
2. Message-Handler in Access erstellen
3. JSON-Parsing in VBA implementieren
4. Formulare in Access testen
5. Fehlerbehandlung verfeinern

## Bekannte Einschränkungen

- Benötigt Windows 10/11
- Benötigt WebView2 Runtime
- Nur in WebView2-Umgebung lauffähig (nicht im Browser)
- Synchrone Aufrufe nicht möglich (nur async/await)

## Debugging

```javascript
// Bridge-Status prüfen
console.log('WebView2 verfügbar:', !!(window.chrome && window.chrome.webview));

// Test-Request senden
Bridge.loadData('auftrag', 123)
    .then(data => console.log('Erfolg:', data))
    .catch(err => console.error('Fehler:', err));

// Event-Handler testen
Bridge.on('onDataReceived', (data) => {
    console.log('Event empfangen:', data);
});
```

## Support

Bei Problemen:
1. Browser-Console öffnen (F12)
2. Fehler-Meldungen kopieren
3. Network-Tab prüfen (sollte leer sein)
4. Access VBA Debug.Print Ausgaben prüfen
