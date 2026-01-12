# Test-Anleitung: frm_Rechnung.html

**Version:** 1.0
**Datum:** 2026-01-12
**Phase:** 2 - VBA-Bridge Integration (Word/PDF/Nummernkreis)

---

## Überblick

Das Rechnungs-Formular wurde NEU erstellt mit vollständiger **VBA-Bridge Integration**.

**Features:**
- ✅ Kundenliste laden via REST API (Port 5000)
- ✅ Automatische Rechnungsnummer via VBA-Bridge (Port 5002)
- ✅ Dynamische Rechnungspositionen
- ✅ Automatische Summenberechnung (Netto/MwSt/Brutto)
- ✅ Word-Template-Erstellung via VBA-Bridge
- ✅ PDF-Generierung via VBA-Bridge

---

## Voraussetzungen

### 1. Access-Frontend geöffnet
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb
```
**Wichtig:** Access MUSS geöffnet sein!

### 2. REST API Server (Port 5000)
```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```
**Endpoints:**
- GET /api/kunden - Kundenliste

### 3. VBA-Bridge Server (Port 5002)
```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py
```
**Endpoints:**
- GET /api/vba/nummern/current/1 - Aktuelle Rechnungsnummer
- POST /api/vba/nummern/next - Nächste Rechnungsnummer (mit Inkrement)
- POST /api/vba/word/fill-template - Word-Template füllen
- POST /api/vba/pdf/convert - Word zu PDF konvertieren

### 4. VBA-Funktionen vorhanden

Diese Funktionen müssen in Access VBA existieren:
- `Update_Rch_Nr(iID As Long) As Long` (mdl_Rechnungsschreibung.bas)
- `Textbau_Replace_Felder_Fuellen(iDocNr As Long)` (mdl_Textbaustein.bas)
- `fReplace_Table_Felder_Ersetzen(...)` (mdl_Textbaustein.bas)

### 5. Word-Template konfiguriert

In Access-Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen`:
- Datensatz mit `ID = 1` (Rechnungsvorlage)
- Pfad zur Word-Vorlage (.docx)

---

## Test-Ablauf

### Schritt 1: Server-Status prüfen

**REST API (Port 5000):**
```bash
curl http://localhost:5000/api/kunden
```
**Erwartung:** JSON-Array mit Kunden

**VBA-Bridge (Port 5002):**
```bash
curl http://localhost:5002/api/vba/status
```
**Erwartung:**
```json
{
  "status": "running",
  "access_connected": true
}
```

**Rechnungsnummer testen:**
```bash
curl http://localhost:5002/api/vba/nummern/current/1
```
**Erwartung:**
```json
{
  "success": true,
  "nummer": 12345
}
```

---

### Schritt 2: Formular öffnen

```bash
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Rechnung.html"
```

**Was passiert:**
1. Kundenliste wird geladen
2. Nächste Rechnungsnummer wird angezeigt (z.B. 12346)
3. Eine leere Position wird angelegt

**Browser Console prüfen:**
```
[Rechnung] Initializing...
[Rechnung] 50 Kunden geladen
[Rechnung] Nächste Rechnungsnummer: 12346
[Rechnung] Ready
```

---

### Schritt 3: Rechnung ausfüllen

1. **Kunde wählen:**
   - Dropdown `Kunde` öffnen
   - Kunde auswählen (z.B. "Musterfirma GmbH")

2. **Rechnungsdatum prüfen:**
   - Sollte auf heutigem Datum sein
   - Optional ändern

3. **Zahlungsziel prüfen:**
   - Standard: 30 Tage

4. **Positionen ausfüllen:**
   - Position 1: Beschreibung = "Dienstleistung", Menge = 10, Preis = 50,00
   - Button **"+ Position hinzufügen"** klicken
   - Position 2: Beschreibung = "Material", Menge = 5, Preis = 20,00

**Erwartung:**
- Summen werden automatisch berechnet:
  - Netto: 600,00 €
  - MwSt. 19%: 114,00 €
  - Gesamt: 714,00 €

---

### Schritt 4: Rechnung erstellen (Word)

Button **"Rechnung erstellen (Word)"** klicken.

**Was passiert:**
```javascript
// 1. Nächste Rechnungsnummer holen und inkrementieren
POST http://localhost:5002/api/vba/nummern/next
{
  "id": 1
}
→ Response: { "success": true, "nummer": 12346 }

// 2. Word-Template füllen
POST http://localhost:5002/api/vba/word/fill-template
{
  "doc_nr": 1,
  "iRch_KopfID": 12346,
  "kun_ID": 123
}
→ Response: { "success": true, "message": "Textbausteine gefüllt" }
```

**Erwartetes Verhalten:**
- Loading-Overlay erscheint
- Status: "Rechnung wird erstellt (Word)..."
- Nach 2-3 Sekunden: Erfolgs-Meldung
- **Word-Dokument** wird in Access geöffnet
- Formular-Feld `Rechnungsnummer` zeigt neue Nummer (12346)

**VBA-Bridge Server Log prüfen:**
```
[2026-01-12 23:45:01] === /api/vba/nummern/next aufgerufen ===
[2026-01-12 23:45:01] VBA Eval: Update_Rch_Nr(1)
[2026-01-12 23:45:02] VBA Ergebnis: 12346
[2026-01-12 23:45:03] === /api/vba/word/fill-template aufgerufen ===
[2026-01-12 23:45:03] VBA Eval: Textbau_Replace_Felder_Fuellen(1)
[2026-01-12 23:45:04] VBA Eval: fReplace_Table_Felder_Ersetzen(12346, 123, 0, 0)
```

---

### Schritt 5: Rechnung erstellen (PDF)

Button **"Rechnung erstellen (PDF)"** klicken.

**Was passiert:**
```javascript
// 1. Nummern holen (wie oben)
// 2. Word-Template füllen (wie oben)

// 3. PDF erstellen
POST http://localhost:5002/api/vba/pdf/convert
{
  "word_path": "C:\\Temp\\Rechnung_12347.docx"
}
→ Response: { "success": true, "pdf_path": "C:\\Temp\\Rechnung_12347.pdf" }
```

**Erwartetes Verhalten:**
- Loading-Overlay erscheint
- Status: "Rechnung wird erstellt (Word + PDF)..."
- Nach 5-10 Sekunden: Erfolgs-Meldung
- **Word-Dokument UND PDF** werden erstellt

**WICHTIG:**
- PDF-Konvertierung nutzt `win32com.client` mit Word.Application
- Word muss auf dem System installiert sein
- Falls PDF fehlschlägt: Word-Dokument existiert trotzdem

---

### Schritt 6: Formular zurücksetzen

Button **"Zurücksetzen"** klicken.

**Was passiert:**
- Bestätigungsdialog erscheint
- Nach Bestätigung:
  - Kunde wird deselektiert
  - Datum wird auf heute zurückgesetzt
  - Alle Positionen werden gelöscht
  - Eine neue leere Position wird angelegt
  - Nächste Rechnungsnummer wird neu geladen

---

## Fehlersuche (Troubleshooting)

### Problem 1: "Kunden konnten nicht geladen werden"

**Ursache:** REST API (Port 5000) läuft nicht

**Lösung:**
```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

**Prüfen:**
```bash
curl http://localhost:5000/api/kunden
```

---

### Problem 2: "Rechnungsnummer konnte nicht geladen werden"

**Ursache:** VBA-Bridge Server (Port 5002) läuft nicht oder Access nicht geöffnet

**Lösung:**
1. Access öffnen mit `0_Consys_FE_Test.accdb`
2. VBA-Bridge Server starten:
   ```bash
   cd "04_HTML_Forms\api"
   python vba_bridge_server.py
   ```

**Prüfen:**
```bash
curl http://localhost:5002/api/vba/status
```
Muss `"access_connected": true` zeigen!

---

### Problem 3: "Word-Template konnte nicht gefüllt werden"

**Ursache:** VBA-Funktionen fehlen oder Template nicht konfiguriert

**Lösung:**
1. In Access VBA prüfen:
   - Modul `mdl_Textbaustein` existiert?
   - Funktionen `Textbau_Replace_Felder_Fuellen` und `fReplace_Table_Felder_Ersetzen` vorhanden?

2. Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen` prüfen:
   ```sql
   SELECT * FROM _tblEigeneFirma_TB_Dok_Dateinamen WHERE ID = 1
   ```
   - Muss Datensatz mit ID=1 enthalten
   - Pfad zur Word-Vorlage muss gültig sein

3. VBA kompilieren:
   ```vba
   DoCmd.RunCommand acCmdCompileAndSaveAllModules
   ```

---

### Problem 4: "PDF-Konvertierung fehlgeschlagen"

**Ursache:** Word-Pfad existiert nicht oder Word.Application Fehler

**Lösung:**
1. Prüfen ob Word-Dokument erstellt wurde:
   ```
   C:\Temp\Rechnung_12346.docx
   ```

2. Word manuell öffnen und als PDF speichern

3. **Pfad anpassen:**
   - In `frm_Rechnung.logic.js` Zeile ~280:
   ```javascript
   const wordPath = `C:\\Temp\\Rechnung_${rechnungsnummer}.docx`;
   ```
   - Pfad muss mit VBA-Ergebnis übereinstimmen!

**Produktiv-Lösung:**
- VBA-Funktion sollte Word-Pfad zurückgeben
- JavaScript verwendet dann den echten Pfad

---

### Problem 5: CORS-Fehler in Browser

**Ursache:** Browser blockiert Cross-Origin-Requests

**Lösung:**
- VBA-Bridge Server hat bereits CORS aktiviert:
  ```python
  from flask_cors import CORS
  CORS(app)
  ```
- Falls Problem bleibt: Browser-Console Log prüfen

---

## Erfolgs-Kriterien

✅ **Kundenliste laden:** Dropdown zeigt aktive Kunden
✅ **Rechnungsnummer anzeigen:** Formular zeigt nächste Nummer
✅ **Positionen hinzufügen:** Dynamische Zeilen funktionieren
✅ **Summen berechnen:** Netto/MwSt/Brutto automatisch
✅ **Rechnung erstellen (Word):** Word-Dokument wird erstellt
✅ **Rechnung erstellen (PDF):** PDF wird generiert
✅ **Nummernkreis-Inkrement:** Jede Rechnung erhöht die Nummer
✅ **Fehlerbehandlung:** Toasts zeigen Fehler bei Server-Ausfall

---

## Logs prüfen

**VBA-Bridge Server Log:**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\vba_bridge.log
```

**Browser Console:**
- F12 → Console-Tab
- Filter: "Rechnung"

**Netzwerk-Tab:**
- F12 → Network-Tab
- Filter: "localhost:5002"
- Requests zu `/api/vba/nummern/*` und `/api/vba/word/*` prüfen

---

## Bekannte Einschränkungen

1. **Word-Pfad hardcoded:**
   - Aktuell: `C:\Temp\Rechnung_{nr}.docx`
   - Produktiv: Pfad sollte von VBA zurückgegeben werden

2. **Rechnungspositionen nur im Frontend:**
   - Positionen werden nicht in Access-Datenbank gespeichert
   - Nur im Word-Template verwendet
   - Für Produktiv-Einsatz: Positions-Tabelle in Backend anlegen

3. **Keine Validierung der Kundendaten:**
   - Kunde muss existieren
   - Keine Prüfung ob Kunde aktiv ist

---

## Nächste Schritte

Nach erfolgreichem Test:
1. ✅ VBA-Bridge Word/PDF-Integration funktioniert
2. ⏳ Rechnungspositionen in Backend speichern
3. ⏳ Angebot-Formular erstellen (ähnliche Struktur)
4. ⏳ Mahnwesen integrieren

---

**Letzte Änderung:** 2026-01-12 23:50
**Autor:** Claude Code
**Version:** 1.0
