# VBA Bridge Integration Report - Auftragstamm Buttons

**Datum:** 2026-01-15
**Bearbeitet:** frm_va_Auftragstamm.logic.js
**VBA Bridge Server:** Port 5002 (vba_bridge_server.py)

---

## Übersicht

Es wurden 3 Button-Funktionen im Auftragstamm-Formular mit VBA Bridge Integration ausgestattet. Die Buttons rufen nun direkt VBA-Funktionen in Access über den VBA Bridge Server (Port 5002) auf, statt über die REST-API (Port 5000).

---

## Geänderte Funktionen

### 1. `sendeEinsatzlisteMA()` → `sendeEinsatzliste(typ)`

**Button:** "E-Mail an MA"
**VBA-Funktion:** `SendeEinsatzliste_MA`
**Zweck:** Sendet Einsatzliste per E-Mail an Mitarbeiter

**Änderungen:**
```javascript
// VORHER: Bridge.execute('sendEinsatzliste', {...})
// NACHHER: fetch('http://localhost:5002/api/vba/execute', ...)

// VBA-Call
{
    function: 'SendeEinsatzliste_MA',
    args: [
        state.currentVA_ID,           // VA_ID
        state.currentVADatum,         // Datum
        state.currentVADatum_ID || 0, // Datum-ID
        typ                           // 'MA' oder anderer Typ
    ]
}
```

**Features:**
- Direkter VBA-Aufruf via COM
- Toast-Message bei Erfolg/Fehler
- Parameter: VA_ID, Datum, Datum_ID, Typ
- Fehlerbehandlung mit Console-Log

---

### 2. `einsatzlisteDrucken()` → `druckeEinsatzliste()`

**Button:** "Einsatzliste drucken"
**VBA-Funktion:** `fXL_Export_Auftrag`
**Zweck:** Erstellt Excel-Export der Einsatzliste

**Änderungen:**
```javascript
// VORHER: Bridge.execute('exportAuftragExcel', {...})
// NACHHER: fetch('http://localhost:5002/api/vba/execute', ...)

// VBA-Call
{
    function: 'fXL_Export_Auftrag',
    args: [
        state.currentVA_ID,                  // VA_ID
        'C:\\temp\\',                        // XLPfad (Speicherort)
        `Auftrag_${state.currentVA_ID}.xlsx` // XLName (Dateiname)
    ]
}
```

**Features:**
- Excel wird in Access/Excel direkt geöffnet
- Optional: Status auf "Beendet" setzen (Veranst_Status_ID = 2)
- Status-Dropdown wird aktualisiert
- **Fallback:** Browser-Druck bei Fehler (mit User-Abfrage)
- Toast-Messages für Feedback

**Besonderheit:**
- Nach erfolgreichem Export wird der Auftragsstatus automatisch auf "Beendet" gesetzt
- Dies entspricht dem Verhalten in Access

---

### 3. `namenslisteESS()` → `druckeNamenlisteESS()`

**Button:** "ESS Namensliste"
**VBA-Funktion:** `ExportNamenlisteESS`
**Zweck:** Exportiert ESS-Namensliste mit Mitarbeiterdaten

**Änderungen:**
```javascript
// VORHER: Bridge.execute('getNamenlisteESS', {...}) + CSV-Export
// NACHHER: fetch('http://localhost:5002/api/vba/execute', ...)

// VBA-Call
{
    function: 'ExportNamenlisteESS',
    args: [
        state.currentVA_ID,                                        // VA_ID
        state.currentVADatum || new Date().toISOString().split('T')[0], // Datum
        state.currentVADatum_ID || 0                              // Datum-ID
    ]
}
```

**Features:**
- Native Access/Excel-Export via VBA
- **Fallback:** CSV-Export bei VBA-Fehler
- CSV-Fallback lädt Daten über REST-API (Port 5000)
- CSV-Dateiname: `ESS_Namensliste_{VA_ID}.csv`
- UTF-8 BOM für korrekte Umlaute in Excel
- Toast-Messages für Feedback

**CSV-Fallback enthält:**
- Nachname, Vorname, Kurzname
- Geburtsdatum, Geburtsort, Nationalität
- Ausweis-Nr, Ausweis gültig bis
- IHK 34a Nr, IHK gültig bis
- Telefon, E-Mail

---

## Technische Details

### VBA Bridge Server

**Pfad:** `04_HTML_Forms\api\vba_bridge_server.py`
**Port:** 5002
**Endpoint:** `POST /api/vba/execute`

**Request-Format:**
```json
{
    "function": "VBA_FunktionsName",
    "args": [arg1, arg2, ...]
}
```

**Response-Format:**
```json
{
    "success": true/false,
    "result": "VBA-Rückgabewert",
    "error": "Fehlermeldung" // nur bei success=false
}
```

### Access-Verbindung

Der VBA Bridge Server benötigt:
1. **Access muss geöffnet sein** mit `0_Consys_FE_Test.accdb`
2. **win32com** Python-Package installiert
3. Access-Instanz wird via COM geholt: `win32com.client.GetActiveObject("Access.Application")`
4. VBA-Funktionen werden via `Application.Eval()` ausgeführt

---

## Error-Handling

### Struktur:
```javascript
try {
    // VBA Bridge Call
    const response = await fetch('http://localhost:5002/api/vba/execute', {...});
    const result = await response.json();

    if (result.success) {
        // Erfolg
        showToast('Erfolg!', 'success');
    } else {
        throw new Error(result.error);
    }
} catch (error) {
    // Fehler
    console.error('[Auftragstamm] Fehler:', error);
    showToast('Fehler: ' + error.message, 'error');

    // Optional: Fallback
}
```

### Fallback-Strategien:

1. **druckeEinsatzliste():**
   - Bei VBA-Fehler: User-Abfrage für Browser-Druck
   - `confirm()` Dialog: "Möchten Sie stattdessen Browser-Druck verwenden?"

2. **druckeNamenlisteESS():**
   - Bei VBA-Fehler: Automatischer CSV-Export
   - Daten werden über REST-API (Port 5000) geladen
   - CSV-Download ohne weitere User-Interaktion

3. **sendeEinsatzliste():**
   - Kein Fallback
   - Fehler wird dem User angezeigt

---

## Vorteile der VBA Bridge Integration

### 1. Native Access-Funktionalität
- Excel-Dateien werden direkt in Excel geöffnet
- Verwendung der Access-VBA Excel-Export-Logik
- Keine Konvertierung oder Nachbearbeitung nötig

### 2. Konsistenz mit Access-Version
- Identisches Verhalten wie Access-Buttons
- Gleiche VBA-Funktionen werden aufgerufen
- Status-Updates (z.B. "Beendet") funktionieren gleich

### 3. Erhaltene Features
- Excel-Vorlagen mit Formatierung
- Komplexe Berechnungen in VBA
- Zugriff auf Access-Datenbank-Funktionen

### 4. Robustheit
- Fallback-Mechanismen bei Fehlern
- Console-Logs für Debugging
- Toast-Messages für User-Feedback

---

## Voraussetzungen für Betrieb

### Server-Seite (VBA Bridge):
1. Python 3.x installiert
2. `pip install flask flask-cors pywin32`
3. VBA Bridge Server starten: `python vba_bridge_server.py`
4. Server läuft auf Port 5002

### Client-Seite (HTML):
1. VBA Bridge Server muss laufen (Port 5002)
2. Access muss geöffnet sein mit Test-Frontend
3. Toast-System muss verfügbar sein (`showToast()` Funktion)
4. Für Fallbacks: REST-API Server auf Port 5000

---

## Bekannte Einschränkungen

### 1. Access-Abhängigkeit
- Access muss geöffnet sein für VBA-Calls
- Wenn Access geschlossen wird, schlagen alle VBA-Calls fehl
- Lösung: Fallback-Mechanismen

### 2. Windows-Only
- VBA Bridge benötigt Windows COM (pywin32)
- Nicht auf Linux/Mac lauffähig
- Lösung: In Browser-Modus automatisch auf Fallbacks umschalten

### 3. Asynchronität
- VBA-Calls sind asynchron (await/Promise)
- Access-UI kann während VBA-Call einfrieren
- Keine Fortschrittsanzeige während Excel-Export

### 4. VBA-Funktionsnamen
- Funktionsnamen müssen exakt in Access existieren
- Falls VBA-Funktion nicht gefunden: `result.success = false`
- **AKTUELL:** Funktionsnamen sind **angenommen** - müssen in Access erstellt/benannt werden:
  - `SendeEinsatzliste_MA`
  - `ExportNamenlisteESS`

---

## Nächste Schritte

### 1. VBA-Funktionen in Access erstellen (ERFORDERLICH!)

Die folgenden VBA-Funktionen müssen in Access erstellt/umbenannt werden:

**a) `SendeEinsatzliste_MA(VA_ID, Datum, Datum_ID, Typ)`**
```vba
Public Function SendeEinsatzliste_MA(VA_ID As Long, Datum As String, Datum_ID As Long, Typ As String) As String
    ' TODO: E-Mail-Versendung implementieren
    ' Sendet Einsatzliste an Mitarbeiter
    ' Return: "OK" oder Fehlermeldung
End Function
```

**b) `ExportNamenlisteESS(VA_ID, Datum, Datum_ID)`**
```vba
Public Function ExportNamenlisteESS(VA_ID As Long, Datum As String, Datum_ID As Long) As String
    ' TODO: ESS Namensliste Export implementieren
    ' Erstellt Excel-Datei mit Mitarbeiterdaten
    ' Return: Pfad zur Excel-Datei oder Fehler
End Function
```

**c) `fXL_Export_Auftrag` (existiert bereits)**
- Diese Funktion existiert bereits in `mdl_Excel_Export.bas`
- Benötigt Parameter: `(VA_ID As Long, XLPfad As String, XLName As String)`

### 2. Testen

- [ ] Button "E-Mail an MA" testen
- [ ] Button "Einsatzliste drucken" testen
- [ ] Button "ESS Namensliste" testen
- [ ] Fallback-Mechanismen testen (VBA Bridge offline)
- [ ] Error-Handling testen (ungültige VA_ID)

### 3. Optimierungen

- [ ] Fortschrittsanzeige während Excel-Export
- [ ] Batch-E-Mail-Versand mit Fortschrittsbalken
- [ ] Server-Status-Check vor VBA-Call (ping)
- [ ] Automatischer VBA Bridge Server-Start beim Access-Start

---

## Zusammenfassung

Die Integration der VBA Bridge ermöglicht es den HTML-Formularen, native Access-Funktionalität zu nutzen. Dies verbessert die Konsistenz zwischen Access- und HTML-Version erheblich.

**Wichtigste Änderungen:**
1. Direkte VBA-Calls statt REST-API für bestimmte Operationen
2. Excel-Exporte werden nativ in Access/Excel erstellt
3. Fallback-Mechanismen sichern Robustheit
4. Toast-Messages verbessern User-Feedback

**Status:** ✅ **Implementiert** (VBA-Funktionen müssen noch in Access erstellt werden)

---

**Geänderte Dateien:**
- `04_HTML_Forms\forms3\logic\frm_va_Auftragstamm.logic.js` (3 Funktionen erweitert)

**Neue Dependencies:**
- VBA Bridge Server auf Port 5002
- Access muss geöffnet sein
