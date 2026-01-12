# VBA Bridge Server - Dokumentation

**Version:** 2.0 (erweitert für Phase 2)
**Port:** 5002
**Erstellt:** 2026-01-12

## Übersicht

Der VBA-Bridge Server ermöglicht HTML-Formularen den Aufruf von VBA-Funktionen in Microsoft Access via REST API.

### Neue Features (Phase 2)

- ✅ **Word-Integration** - Textbausteine und Vorlagen-Erstellung
- ✅ **PDF-Generierung** - Word zu PDF Konvertierung
- ✅ **Nummernkreis-System** - Rechnungs-/Angebots-Nummern
- ✅ **Ausweis-Druck** - Mitarbeiter-Ausweise drucken und nummerieren

---

## Server starten

### Voraussetzungen

1. **Access muss geöffnet sein** mit `0_Consys_FE_Test.accdb`
2. **Python-Pakete** installiert:
   ```bash
   pip install flask flask-cors pywin32
   ```

### Start

```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py
```

Server läuft auf: `http://localhost:5002`

---

## API Endpoints

### 1. Word-Integration

#### POST `/api/vba/word/fill-template`

Füllt Word-Vorlage mit Daten aus Access-Datenbank.

**Request:**
```json
{
    "doc_nr": 1,              // Dokument-Nummer in _tblEigeneFirma_TB_Dok_Dateinamen
    "iRch_KopfID": 123,       // Rechnungs-ID (optional)
    "kun_ID": 456,            // Kunden-ID (optional)
    "MA_ID": 789,             // Mitarbeiter-ID (optional)
    "VA_ID": 012              // Auftrags-ID (optional)
}
```

**Response:**
```json
{
    "success": true,
    "message": "Textbausteine gefüllt und ersetzt",
    "doc_nr": 1
}
```

**VBA-Funktionen:**
- `Textbau_Replace_Felder_Fuellen(iDocNr)`
- `fReplace_Table_Felder_Ersetzen(iRch_KopfID, kun_ID, MA_ID, VA_ID)`

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/word/fill-template', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        doc_nr: 1,
        kun_ID: 456,
        iRch_KopfID: 123
    })
});
const result = await response.json();
```

---

### 2. PDF-Generierung

#### POST `/api/vba/pdf/convert`

Konvertiert Word-Dokument zu PDF.

**Request:**
```json
{
    "word_path": "C:\\Pfad\\zum\\Dokument.docx"
}
```

**Response:**
```json
{
    "success": true,
    "pdf_path": "C:\\Pfad\\zum\\Dokument.pdf"
}
```

**Technologie:**
- Verwendet `win32com.client` mit Word.Application
- Export-Format: `wdFormatPDF = 17`

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/pdf/convert', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        word_path: 'C:\\Dokumente\\Rechnung_123.docx'
    })
});
const result = await response.json();
console.log('PDF erstellt:', result.pdf_path);
```

---

### 3. Nummernkreis-System

#### POST `/api/vba/nummern/next`

Holt nächste Nummer aus Nummernkreis und inkrementiert.

**Request:**
```json
{
    "id": 1   // 1 = Rechnung, 2 = Angebot, 3 = Brief, etc.
}
```

**Response:**
```json
{
    "success": true,
    "nummer": 12345
}
```

**VBA-Funktion:**
- `Update_Rch_Nr(iID)` - Inkrementiert Nummernkreis

**Nummernkreis-IDs:**
- `1` = Rechnung
- `2` = Angebot
- `3` = Brief
- `4` = Mahnung

**Verwendung in HTML:**
```javascript
// Nächste Rechnungsnummer holen
const response = await fetch('http://localhost:5002/api/vba/nummern/next', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id: 1 })
});
const { nummer } = await response.json();
document.getElementById('rechnungsnummer').value = nummer;
```

---

#### GET `/api/vba/nummern/current/{id}`

Holt aktuelle Nummer OHNE Inkrement (nur Anzeige).

**Request:**
```http
GET http://localhost:5002/api/vba/nummern/current/1
```

**Response:**
```json
{
    "success": true,
    "nummer": 12344
}
```

**VBA-Funktion:**
- `TLookup("NummernKreis", "_tblEigeneFirma_Word_Nummernkreise", "ID = {id}")`

**Verwendung in HTML:**
```javascript
// Aktuelle Nummer anzeigen (ohne zu inkrementieren)
const response = await fetch('http://localhost:5002/api/vba/nummern/current/1');
const { nummer } = await response.json();
console.log('Aktuelle Rechnungsnummer:', nummer);
```

---

### 4. Ausweis-System

#### POST `/api/vba/ausweis/drucken`

Druckt Ausweis für Mitarbeiter.

**Request:**
```json
{
    "MA_ID": 123,
    "drucker": "Canon Drucker"  // optional
}
```

**Response:**
```json
{
    "success": true,
    "result": true
}
```

**VBA-Funktion:**
- `Ausweis_Drucken(MA_ID, DruckerName)`

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/ausweis/drucken', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        MA_ID: 123,
        drucker: 'Canon iP7250'
    })
});
```

---

#### POST `/api/vba/ausweis/nummer`

Vergibt Ausweis-Nummer für Mitarbeiter.

**Request:**
```json
{
    "MA_ID": 123
}
```

**Response:**
```json
{
    "success": true,
    "ausweis_nr": 12345
}
```

**VBA-Funktion:**
- `Ausweis_Nr_Vergeben(MA_ID)`

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/ausweis/nummer', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ MA_ID: 123 })
});
const { ausweis_nr } = await response.json();
console.log('Ausweis-Nummer vergeben:', ausweis_nr);
```

---

### 5. Allgemeine Endpoints (bereits vorhanden)

#### GET `/api/vba/status`

Server-Status und Access-Verbindung prüfen.

**Response:**
```json
{
    "status": "running",
    "port": 5002,
    "win32com_available": true,
    "access_connected": true,
    "access_database": "C:\\...\\0_Consys_FE_Test.accdb",
    "timestamp": "2026-01-12T23:15:30"
}
```

---

#### POST `/api/vba/execute`

Führt beliebige VBA-Funktion aus.

**Request:**
```json
{
    "function": "FunktionsName",
    "args": [arg1, arg2, ...]
}
```

**Response:**
```json
{
    "success": true,
    "result": ...
}
```

**Verwendung in HTML:**
```javascript
const response = await fetch('http://localhost:5002/api/vba/execute', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        function: 'MeineVBAFunktion',
        args: ['param1', 123, true]
    })
});
```

---

#### POST `/api/vba/anfragen`

Sendet Anfragen an Mitarbeiter (E-Mail).

**Request:**
```json
{
    "VA_ID": 12345,
    "VADatum_ID": 67890,
    "VAStart_ID": 111,
    "MA_IDs": [1, 2, 3],
    "selectedOnly": false
}
```

**Response:**
```json
{
    "success": true,
    "results": [
        {"MA_ID": 1, "status": "OK"},
        {"MA_ID": 2, "status": "BEREITS ZUGESAGT"}
    ],
    "total": 3,
    "sent": 2
}
```

---

## Technische Details

### VBA-Funktion via Eval()

Der Server verwendet `Application.Eval()` statt `Application.Run()` für VBA-Aufrufe:

```python
def run_vba_function(func_name, *args):
    access_app = get_access_app()

    # Argumente formatieren
    formatted_args = []
    for arg in args:
        if isinstance(arg, str):
            formatted_args.append(f'"{arg}"')
        else:
            formatted_args.append(str(arg))

    # Eval-Ausdruck
    eval_expr = f"{func_name}({', '.join(formatted_args)})"

    # VBA ausführen
    result = access_app.Eval(eval_expr)
    return {"success": True, "result": result}
```

### COM Threading

- `pythoncom.CoInitialize()` vor COM-Zugriff
- `pythoncom.CoUninitialize()` nach COM-Zugriff
- Single-threaded Flask-Server (`threaded=False`)

### Error Handling

Alle Endpoints haben standardisiertes Error-Handling:

```python
try:
    # ... Logik ...
    return jsonify({"success": True, ...})
except Exception as e:
    error_msg = traceback.format_exc()
    log(f"Fehler: {error_msg}")
    return jsonify({"success": False, "error": str(e)}), 500
```

---

## Logging

Alle Requests werden geloggt in: `vba_bridge.log`

```
[2026-01-12 23:15:30] === /api/vba/word/fill-template aufgerufen ===
[2026-01-12 23:15:30] Request Data: {...}
[2026-01-12 23:15:31] VBA Eval: Textbau_Replace_Felder_Fuellen(1)
[2026-01-12 23:15:31] VBA Ergebnis: True
```

---

## Verwendung in HTML-Formularen

### Beispiel: Rechnung erstellen

```javascript
// 1. Nächste Rechnungsnummer holen
const nummerResponse = await fetch('http://localhost:5002/api/vba/nummern/next', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id: 1 }) // 1 = Rechnung
});
const { nummer } = await nummerResponse.json();

// 2. Word-Vorlage füllen
const wordResponse = await fetch('http://localhost:5002/api/vba/word/fill-template', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        doc_nr: 1,
        iRch_KopfID: nummer,
        kun_ID: 456
    })
});

// 3. PDF erstellen
const pdfResponse = await fetch('http://localhost:5002/api/vba/pdf/convert', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        word_path: `C:\\Rechnungen\\Rechnung_${nummer}.docx`
    })
});
const { pdf_path } = await pdfResponse.json();

console.log('Rechnung erstellt:', pdf_path);
```

---

## Troubleshooting

### Access nicht verbunden

**Problem:**
```json
{
    "success": false,
    "error": "Access nicht geöffnet!"
}
```

**Lösung:**
1. Access öffnen mit `0_Consys_FE_Test.accdb`
2. Server neu starten

---

### win32com nicht verfügbar

**Problem:**
```json
{
    "success": false,
    "error": "win32com nicht verfügbar"
}
```

**Lösung:**
```bash
pip install pywin32
```

---

### VBA-Funktion nicht gefunden

**Problem:**
```json
{
    "success": false,
    "error": "Compile error: Sub or Function not defined"
}
```

**Lösung:**
1. VBA-Funktion muss `Public` sein
2. VBA-Modul muss in Access vorhanden sein
3. Access VBA kompilieren: `DoCmd.RunCommand acCmdCompileAndSaveAllModules`

---

## Phase 2 Status

✅ **Implementiert:**
- Word-Integration (Textbausteine)
- PDF-Generierung
- Nummernkreis-System
- Ausweis-Druck

⏳ **Noch zu tun:**
- Vollständige Word-Dokument-Generierung (aktuell nur Textbausteine)
- Mahnwesen-Integration
- Weitere Ausweis-Funktionen (Karte_Drucken)

---

## Kontakt

Bei Fragen oder Problemen: Siehe `vba_bridge.log` für Details.

**Version:** 2.0 (Phase 2)
**Letztes Update:** 2026-01-12 23:15
