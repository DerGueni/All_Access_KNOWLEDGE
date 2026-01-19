# WebView2 Direkt-Anbindung an Access Backend

## NEU: Kein API-Server mehr nötig!

Die HTML-Formulare kommunizieren jetzt **direkt** über WebView2 mit dem Access-Backend.
Es wird kein Python-Server (api_server.py) mehr benötigt!

## Architektur

```
┌────────────────────────────────────────────────────────────┐
│  HTML-Formular (im WebView2)                               │
│  ├── webview2-bridge.js                                    │
│  └── postMessage({ action, params, requestId })            │
└──────────────────────┬─────────────────────────────────────┘
                       │ WebMessageReceived
                       ▼
┌────────────────────────────────────────────────────────────┐
│  ConsysWebView2.dll (.NET / COM)                           │
│  ├── WebView2Host / WebFormHost                            │
│  └── OnWebMessageReceived() → AccessDataBridge             │
└──────────────────────┬─────────────────────────────────────┘
                       │ OleDb
                       ▼
┌────────────────────────────────────────────────────────────┐
│  Access Backend                                            │
│  S:\CONSEC\...\0_Consec_V1_BE_V1.55_Test.accdb            │
└────────────────────────────────────────────────────────────┘
```

## Komponenten

### 1. AccessDataBridge.cs (NEU!)
Direkte Datenbank-Anbindung via OleDb:
- `ProcessRequest(jsonMessage)` - Verarbeitet JSON-Requests aus JavaScript
- Unterstützt alle CRUD-Operationen
- Automatisches Mapping von Type zu Tabelle

**Unterstützte Actions:**
| Action | Beschreibung |
|--------|--------------|
| `loadData` | Einzelnen Datensatz laden |
| `list` | Liste laden |
| `search` | Suche durchführen |
| `save` | Insert/Update |
| `delete` | Löschen |
| `getAuftrag` | Auftrag mit ID laden |
| `listAuftraege` | Auftragsliste |
| `getMitarbeiter` | MA mit ID laden |
| `listMitarbeiter` | MA-Liste |
| `getZuordnungen` | MA-Zuordnungen für VA |
| `createZuordnung` | Neue Zuordnung |
| `deleteZuordnung` | Zuordnung löschen |
| `getSchichten` | Schichten für VA |
| `getEinsatztage` | Einsatztage für VA |
| `executeSQL` | Custom SELECT ausführen |
| `ping` | Health-Check |

### 2. WebView2Host.cs (erweitert)
- Initialisiert automatisch `AccessDataBridge`
- `OnWebMessageReceived_Host()` leitet Requests an Bridge weiter
- Antwort wird automatisch an JavaScript zurückgesendet

### 3. webview2-bridge.js (angepasst)
- Erkennt WebView2-Modus automatisch
- Parst JSON-Responses von AccessDataBridge
- Fallback auf REST-API (localhost:5000) für Browser-Tests

## Installation

### 1. DLL kompilieren
```batch
cd WebView2_Access\COM_Wrapper\ConsysWebView2
msbuild ConsysWebView2.csproj -p:Configuration=Release -p:Platform=x64
```

### 2. COM registrieren (als Administrator!)
```batch
register_com.bat
```

### 3. VBA-Code
```vba
' Formular öffnen
Dim host As Object
Set host = CreateObject("ConsysWebView2.WebFormHost")

host.ShowForm "C:\...\forms3\frm_MA_Mitarbeiterstamm.html", "Mitarbeiter", 1200, 800

' Fertig! Die Bridge kommuniziert automatisch mit der DB.
```

## Vorteile

1. **Kein Server-Prozess** - Kein Python, Flask, oder ähnliches nötig
2. **Direkter Zugriff** - OleDb im selben Prozess wie WebView2
3. **Schneller** - Keine HTTP-Overhead
4. **Einfacher** - Weniger Komponenten zu verwalten
5. **Offline-fähig** - Funktioniert ohne Netzwerkstack

## Backend-Pfade

Die AccessDataBridge sucht automatisch nach dem Backend:
1. `S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\0_Consec_V1_BE_V1.55_Test.accdb`
2. `S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb`
3. `C:\Users\guenther.siegert\Documents\Consec_BE_LOCAL.accdb` (Fallback)

## Request/Response Format

### Request (JS → C#)
```json
{
    "requestId": 1,
    "action": "getAuftrag",
    "params": {
        "id": 123
    }
}
```

### Response (C# → JS)
```json
{
    "requestId": 1,
    "ok": true,
    "data": {
        "VA_ID": 123,
        "Auftrag": "Messe München",
        "Objekt": "ICM",
        ...
    }
}
```

### Error Response
```json
{
    "requestId": 1,
    "ok": false,
    "error": {
        "code": "ERROR",
        "message": "Auftrag nicht gefunden"
    }
}
```

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| `AccessDataBridge.cs` | OleDb-Datenbankzugriff |
| `WebView2Host.cs` | WebView2 COM-Wrapper |
| `webview2-bridge.js` | JavaScript Bridge |
| `register_com.bat` | COM-Registrierung |
| `ConsysWebView2.dll` | Kompilierte Bibliothek |

## Fallback: REST-API

Für Browser-Tests (ohne WebView2) ist weiterhin der API-Server nutzbar:
```bash
cd "C:\...\04_HTML_Forms\api"
python api_server.py
```

Die Bridge erkennt automatisch, ob WebView2 verfügbar ist und wählt den passenden Modus.
