# WebView2 Access Integration - Installationsanleitung

## Übersicht

Diese Lösung ermöglicht die Anzeige moderner HTML-Formulare in Microsoft Access 2021 (64-Bit) mit Insert/Update-Funktionalität gegen ein zentrales Access-Backend.

### Architektur

```
┌─────────────────────────────────────────────────────────────┐
│  Access Frontend                                            │
│  ├── VBA: mod_N_WebView2 (Steuerung)                       │
│  └── Browser-Integration oder COM-Wrapper                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Lokaler Python-Server (Port 5000)                         │
│  ├── Static Files: HTML/CSS/JS aus Consys_HTML             │
│  └── REST API: /api/load, /api/save                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Access Backend (Netzwerk)                                  │
│  0_Consec_V1_BE_V1.55_Test.accdb                           │
└─────────────────────────────────────────────────────────────┘
```

## Voraussetzungen

| Komponente | Version | Hinweis |
|------------|---------|---------|
| Microsoft Access | 2021, 64-Bit | Kein Microsoft 365 |
| Python | 3.8+ | python.exe im PATH |
| Flask | 2.0+ | `pip install flask` |
| Flask-CORS | 3.0+ | `pip install flask-cors` |
| pyodbc | 4.0+ | `pip install pyodbc` |
| WebView2 Runtime | Evergreen | Optional für COM-Modus |
| ACE OLEDB | 16.0, 64-Bit | Mit Office installiert |

### Voraussetzungen prüfen

```batch
cd C:\Users\guenther.siegert\Documents\WebView2_Access\Deploy
check_requirements.bat
```

## Installation (pro Arbeitsplatz)

### Schritt 1: Dateien kopieren

Die Ordnerstruktur liegt unter:
```
C:\Users\guenther.siegert\Documents\WebView2_Access\
├── API\
│   └── api_server_wv2.py       # Python REST-Server
├── VBA\
│   └── mod_N_WebView2.bas      # VBA-Modul
├── COM_Wrapper\                 # Optional: C# COM-Wrapper
└── Deploy\
    ├── install.bat             # Installations-Skript
    └── check_requirements.bat  # Voraussetzungen prüfen
```

### Schritt 2: Python-Pakete installieren

```batch
pip install flask flask-cors pyodbc
```

### Schritt 3: VBA-Modul importieren

1. Access öffnen: `0_Consys_FE_Test.accdb`
2. VBA-Editor (Alt+F11)
3. Datei → Datei importieren
4. Wählen: `C:\Users\guenther.siegert\Documents\WebView2_Access\VBA\mod_N_WebView2.bas`

### Schritt 4: Server testen

Im VBA-Direktfenster (Strg+G):

```vba
WV2_Test
```

Ausgabe sollte sein:
```
=== WebView2 Test ===
Server laeuft: True
Lade Mitarbeiter...
{"success":true,"data":[...]}
=== Test Ende ===
```

## Verwendung

### Server starten/stoppen

```vba
' Server starten
WV2_StartServer

' Server stoppen
WV2_StopServer

' Status prüfen
Debug.Print WV2_IsServerRunning()
```

### HTML-Formular öffnen

```vba
' Im Standard-Browser öffnen (empfohlen)
WV2_OpenInBrowser "frm_MA_Mitarbeiterstamm"

' Mit Parametern
WV2_OpenInBrowser "frm_MA_Mitarbeiterstamm", "id=42"
```

### Daten laden/speichern via VBA

```vba
' Daten laden
Dim json As String
json = WV2_LoadData("tbl_MA_Mitarbeiterstamm", 42)  ' Einzelner MA
json = WV2_LoadData("tbl_MA_Mitarbeiterstamm")       ' Alle MA

' Daten speichern (Update)
json = WV2_SaveData("tbl_MA_Mitarbeiterstamm", _
       "{""Nachname"":""Müller"",""Vorname"":""Max""}", 42)

' Daten speichern (Insert)
json = WV2_SaveData("tbl_MA_Mitarbeiterstamm", _
       "{""Nachname"":""Neu"",""Vorname"":""Eintrag""}")
```

## REST-API Referenz

### Generische Endpoints

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| GET | `/api/load?table=xxx` | Alle Datensätze |
| GET | `/api/load?table=xxx&id=123` | Einzelner Datensatz |
| POST | `/api/save` | Insert/Update |
| POST | `/api/delete` | Löschen |
| GET | `/api/health` | Server-Status |

### Spezifische Endpoints

| Endpoint | Beschreibung |
|----------|--------------|
| `/api/mitarbeiter` | Mitarbeiter-Liste |
| `/api/mitarbeiter/<id>` | Einzelner MA |
| `/api/kunden` | Kunden-Liste |
| `/api/auftraege` | Auftrags-Liste |
| `/api/dienstplan/ma/<id>` | Dienstplan MA |

### Beispiel: JavaScript im HTML-Formular

```javascript
// Daten laden
const response = await fetch('http://127.0.0.1:5000/api/load?table=tbl_MA_Mitarbeiterstamm&id=42');
const result = await response.json();
if (result.success) {
    console.log(result.data);
}

// Daten speichern
const saveResponse = await fetch('http://127.0.0.1:5000/api/save', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        table: 'tbl_MA_Mitarbeiterstamm',
        id: 42,
        data: { Nachname: 'Müller', Vorname: 'Max' }
    })
});
```

## Multiuser & Locking

### Verhalten bei gleichzeitigem Zugriff

- **Read:** Keine Einschränkungen
- **Write:** Automatisches Retry bei Locking-Konflikten (max 3 Versuche)
- **Timeout:** 30 Sekunden für Verbindung, 60 Sekunden für Queries

### Locking-Fehler behandeln

Der Server versucht automatisch 3x bei Locking-Fehlern (Error 3218, 3262).

Im HTML-Formular:
```javascript
const result = await fetch('/api/save', {...});
const json = await result.json();

if (!json.success && json.error.includes('Locking')) {
    // Retry nach Wartezeit
    setTimeout(() => saveData(), 2000);
}
```

## Fehlerbehandlung

### Server startet nicht

1. Prüfen: `python --version` (muss 3.8+ sein)
2. Pakete installieren: `pip install flask flask-cors pyodbc`
3. Port frei? `netstat -an | findstr 5000`

### Backend nicht erreichbar

1. Netzwerkpfad prüfen: `dir "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\"`
2. ACE-Treiber 64-Bit installiert?

### Logs prüfen

Logs unter: `C:\Users\guenther.siegert\Documents\WebView2_Access\API\api_server.log`

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| `API\api_server_wv2.py` | Python REST-Server |
| `VBA\mod_N_WebView2.bas` | VBA-Modul für Access |
| `COM_Wrapper\WebView2Host.cs` | Optional: C# COM-Wrapper |
| `Deploy\install.bat` | Installations-Skript |
| `Deploy\check_requirements.bat` | Voraussetzungen prüfen |

## Hinweise für Produktion

1. **Autostart:** Server bei Windows-Anmeldung starten (Task Scheduler)
2. **Firewall:** Port 5000 ist nur localhost, keine Firewall-Regel nötig
3. **Updates:** HTML-Formulare können jederzeit aktualisiert werden (kein Server-Neustart)
