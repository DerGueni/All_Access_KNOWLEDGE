# WebView2 Bridge - VBA ↔ HTML Kommunikation

## Übersicht

Das WebView2 Bridge-System ermöglicht die bidirektionale Kommunikation zwischen Access-VBA und HTML-Formularen via Microsoft Edge WebView2 Control.

## Architektur

```
┌─────────────────────────────────────────────────────────────┐
│                    Access-Formular                          │
│  ┌──────────────────────────────────────────────────┐      │
│  │         WebView2 ActiveX Control                  │      │
│  │  ┌────────────────────────────────────────────┐  │      │
│  │  │         HTML-Formular                       │  │      │
│  │  │  ┌──────────────────────────────────┐      │  │      │
│  │  │  │    webview2-bridge.js             │      │  │      │
│  │  │  │  - sendMessage()                  │      │  │      │
│  │  │  │  - loadData(), list(), save()     │      │  │      │
│  │  │  └──────────────────────────────────┘      │  │      │
│  │  │              ↕ PostMessage                   │  │      │
│  │  └────────────────────────────────────────────┘  │      │
│  │              ↕ WebMessageReceived                 │      │
│  └──────────────────────────────────────────────────┘      │
│              ↕ Formular Event-Handler                       │
│  ┌──────────────────────────────────────────────────┐      │
│  │      mod_N_WebHost_Bridge.bas                     │      │
│  │  - WebView2_MessageHandler()                      │      │
│  │  - ProcessLoadData(), ProcessList()               │      │
│  │  - ProcessSave(), ProcessDelete()                 │      │
│  └──────────────────────────────────────────────────┘      │
│              ↕ DAO.Database                                 │
│  ┌──────────────────────────────────────────────────┐      │
│  │           Access Backend                          │      │
│  │  - tbl_MA_Mitarbeiterstamm                        │      │
│  │  - tbl_KD_Kundenstamm                             │      │
│  │  - tbl_VA_Auftragstamm                            │      │
│  │  - ...                                             │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Komponenten

### 1. VBA-Module

#### `mod_N_WebHost_Bridge.bas` - Generischer Message-Handler
- **Hauptfunktion:** `WebView2_MessageHandler(webview, args)`
- **Unterstützte Actions:**
  - `loadData` - Einzelnen Datensatz laden
  - `list` - Liste von Datensätzen laden
  - `save` - INSERT oder UPDATE
  - `delete` - DELETE

#### `TEMPLATE_WebView2_FormularCode.bas` - Formular-Template
- Beispiel-Code für Access-Formular
- Muss in Formular-Modul kopiert werden (nicht separates Modul!)

### 2. JavaScript Bridge (HTML-Seite)

```javascript
// Beispiel: webview2-bridge.js (zu erstellen)
const Bridge = {
    sendMessage(action, data) {
        const requestId = generateRequestId();
        return new Promise((resolve, reject) => {
            // Promise registrieren
            pendingRequests[requestId] = { resolve, reject };

            // Message an VBA senden
            window.chrome.webview.postMessage({
                requestId,
                action,
                ...data
            });
        });
    },

    async loadData(type, id) {
        return this.sendMessage('loadData', { type, id });
    },

    async list(type, filters = {}, orderBy = '', limit = 0) {
        return this.sendMessage('list', { type, filters, orderBy, limit });
    },

    async save(type, data) {
        return this.sendMessage('save', { type, data });
    },

    async delete(type, id) {
        return this.sendMessage('delete', { type, id });
    }
};

// Response-Listener
window.chrome.webview.addEventListener('message', (event) => {
    const response = JSON.parse(event.data);
    const { requestId, success, data, error } = response;

    const request = pendingRequests[requestId];
    if (!request) return;

    if (success) {
        request.resolve(data);
    } else {
        request.reject(new Error(error));
    }

    delete pendingRequests[requestId];
});
```

## Datentyp-Mapping

| dataType | Tabellenname |
|----------|-------------|
| `mitarbeiter` | `tbl_MA_Mitarbeiterstamm` |
| `kunden` | `tbl_KD_Kundenstamm` |
| `auftraege` | `tbl_VA_Auftragstamm` |
| `objekte` | `tbl_OB_Objekt` |
| `zuordnungen` | `tbl_MA_VA_Planung` |
| `anfragen` | `tbl_MA_VA_Anfragen` |
| `schichten` | `tbl_VA_Start` |
| `einsatztage` | `tbl_VA_AnzTage` |
| `abwesenheiten` | `tbl_MA_NVerfuegZeiten` |
| `bewerber` | `tbl_MA_Bewerber` |
| `lohnabrechnungen` | `tbl_Lohn_Abrechnungen` |
| `zeitkonten` | `tbl_Zeitkonten_Importfehler` |

Weitere Typen können in `GetTableName()` hinzugefügt werden.

## Message-Protokoll

### Request (HTML → VBA)

```json
{
  "requestId": "req_1234567890",
  "action": "loadData",
  "type": "mitarbeiter",
  "id": 123
}
```

### Response (VBA → HTML)

**Success:**
```json
{
  "requestId": "req_1234567890",
  "success": true,
  "data": {
    "ID": 123,
    "Nachname": "Mustermann",
    "Vorname": "Max",
    "IstAktiv": true
  }
}
```

**Error:**
```json
{
  "requestId": "req_1234567890",
  "success": false,
  "error": "Datensatz nicht gefunden: ID=123"
}
```

## Verwendungs-Beispiele

### HTML-Seite: Mitarbeiter laden

```javascript
// Einzelnen Mitarbeiter laden
try {
    const mitarbeiter = await Bridge.loadData('mitarbeiter', 123);
    console.log(mitarbeiter); // { ID: 123, Nachname: "...", ... }
} catch (error) {
    console.error('Fehler beim Laden:', error.message);
}

// Liste aller aktiven Mitarbeiter
const mitarbeiterListe = await Bridge.list('mitarbeiter', {
    filters: { IstAktiv: true },
    orderBy: 'Nachname, Vorname',
    limit: 100
});

// Neuen Mitarbeiter speichern
const neuerMA = await Bridge.save('mitarbeiter', {
    Nachname: 'Müller',
    Vorname: 'Anna',
    IstAktiv: true,
    Tel_Mobil: '0171 1234567'
});
console.log('Neue ID:', neuerMA.id);

// Mitarbeiter aktualisieren
await Bridge.save('mitarbeiter', {
    ID: 123,
    Tel_Mobil: '0171 9999999'
});

// Mitarbeiter löschen
await Bridge.delete('mitarbeiter', 123);
```

### VBA: Formular-Setup

```vba
' Im Formular-Modul (z.B. frm_N_MA_WebView)

Private Sub Form_Load()
    Me.webview.Navigate "file:///C:/Pfad/zu/formular.html"
End Sub

Private Sub webview_WebMessageReceived(ByVal args As Object)
    ' An generischen Handler delegieren
    Call mod_N_WebHost_Bridge.WebView2_MessageHandler(Me.webview, args)
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Set Me.webview = Nothing
End Sub
```

## Installation

### Voraussetzungen

1. **WebView2 Runtime installieren**
   - Download: https://developer.microsoft.com/en-us/microsoft-edge/webview2/
   - Wird für alle WebView2-Controls benötigt

2. **JsonConverter.bas importieren**
   - Download: https://github.com/VBA-tools/VBA-JSON
   - `JsonConverter.bas` in Access-VBA-Projekt importieren
   - Wird für JSON-Parsing benötigt

3. **mod_N_WebHost_Bridge.bas importieren**
   - Pfad: `01_VBA\mod_N_WebHost_Bridge.bas`
   - Enthält generischen Message-Handler

### Formular erstellen

1. **Neues Formular erstellen**
   - Name: `frm_N_IhrFormular`
   - Formularansicht: Einzelnes Formular

2. **WebView2 Control hinzufügen**
   - Design-Ansicht öffnen
   - Steuerelemente → ActiveX-Steuerelemente
   - "Microsoft Edge WebView2 Control" auswählen
   - Control über gesamtes Formular ziehen
   - **Name setzen auf:** `webview`

3. **Event-Handler einfügen**
   - Code aus `TEMPLATE_WebView2_FormularCode.bas` kopieren
   - In Formular-Modul einfügen
   - `htmlPath` anpassen

4. **Testen**
   - Formular öffnen
   - F12 drücken für DevTools (falls WebView2 dies unterstützt)
   - Console auf Fehler prüfen

## Debugging

### VBA-Seite

```vba
' Debug-Output aktiviert in mod_N_WebHost_Bridge
Debug.Print "[WebHost Bridge] Message: " & jsonString
Debug.Print "[ProcessLoadData] SQL: " & sql
Debug.Print "[ProcessSave] UPDATE: " & tableName & " ID=" & recordId
```

Immediate Window (Strg+G) öffnen zum Ansehen.

### HTML-Seite

```javascript
// Console-Logs
console.log('Message gesendet:', { action, type, id });
console.log('Response empfangen:', response);

// Error-Handling
try {
    const data = await Bridge.loadData('mitarbeiter', 123);
} catch (error) {
    console.error('Fehler:', error);
    alert('Fehler beim Laden: ' + error.message);
}
```

## Erweiterung: Eigene Actions

Falls ein Formular spezielle Actions benötigt (z.B. Report-Generierung, Bulk-Operations):

### VBA erweitern

```vba
Private Sub webview_WebMessageReceived(ByVal args As Object)
    On Error GoTo ErrorHandler

    Dim jsonString As String
    Dim data As Object

    jsonString = args.WebMessageAsJson
    Set data = JsonConverter.ParseJson(jsonString)

    ' Prüfen ob eigene Action
    Select Case data("action")

        Case "generateReport"
            Call HandleGenerateReport(Me.webview, data)

        Case "bulkUpdate"
            Call HandleBulkUpdate(Me.webview, data)

        Case Else
            ' Standard-Handler verwenden
            Call mod_N_WebHost_Bridge.WebView2_MessageHandler(Me.webview, args)

    End Select

    Exit Sub

ErrorHandler:
    Debug.Print "[Formular] ERROR: " & Err.Description
End Sub

Private Sub HandleGenerateReport(ByVal webview As Object, ByVal data As Object)
    Dim reportName As String
    reportName = data("reportName")
    DoCmd.OpenReport reportName, acViewPreview
    Call SendResponse(webview, data("requestId"), "{""success"": true}")
End Sub
```

### HTML erweitern

```javascript
Bridge.generateReport = async function(reportName) {
    return this.sendMessage('generateReport', { reportName });
};

// Verwendung
await Bridge.generateReport('rpt_Mitarbeiterliste');
```

## Bekannte Einschränkungen

1. **JsonConverter benötigt**
   - VBA hat keine native JSON-Unterstützung
   - JsonConverter-Modul muss separat importiert werden

2. **Keine Auto-Refresh**
   - HTML-Formulare werden nicht automatisch aktualisiert bei DB-Änderungen
   - Muss manuell via Reload oder erneutes loadData() erfolgen

3. **Single-Threaded**
   - Alle Messages werden sequentiell verarbeitet
   - Lange laufende Queries blockieren UI

4. **Fehlerbehandlung**
   - SQL-Fehler werden als Error-Response zurückgegeben
   - HTML-Seite muss Error-Handling implementieren

## Vergleich: WebView2 vs. API Server

| Aspekt | WebView2 Bridge | API Server (Python) |
|--------|-----------------|---------------------|
| **Setup** | Einfach (nur VBA) | Komplex (Python, Flask) |
| **Performance** | Gut | Sehr gut |
| **Debugging** | VBA Debug.Print | HTTP-Logs, Postman |
| **Skalierung** | Nicht möglich | Horizontal skalierbar |
| **Authentifizierung** | Nicht nötig | JWT, OAuth möglich |
| **Offline** | Ja | Nein (Server muss laufen) |
| **Verwendung** | Access-intern | Auch extern nutzbar |

**Empfehlung:**
- **WebView2 Bridge:** Für Access-interne HTML-Formulare (einfach, direkt)
- **API Server:** Für externe Web-Clients, Mobile Apps, Multi-User (professionell)

## Weiterführende Ressourcen

- [Microsoft WebView2 Docs](https://docs.microsoft.com/en-us/microsoft-edge/webview2/)
- [VBA-JSON GitHub](https://github.com/VBA-tools/VBA-JSON)
- [Access VBA Reference](https://docs.microsoft.com/en-us/office/vba/api/overview/access)

## Lizenz

Internes Projekt - Consec Planning
