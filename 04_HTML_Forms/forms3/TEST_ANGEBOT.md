# Test-Anleitung: frm_Angebot.html

**Version:** 1.0
**Datum:** 2026-01-13
**Phase:** 2 - VBA-Bridge Integration (Word/PDF/Nummernkreis)

---

## Überblick

Das Angebots-Formular wurde NEU erstellt mit vollständiger **VBA-Bridge Integration**.

**Features:**
- ✅ Kundenliste laden via REST API (Port 5000)
- ✅ Automatische Angebotsnummer via VBA-Bridge (Port 5002)
- ✅ Dynamische Angebotspositionen
- ✅ Gültigkeitsdatum (Standard: 30 Tage)
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
- GET /api/vba/nummern/current/2 - Aktuelle Angebotsnummer
- POST /api/vba/nummern/next - Nächste Angebotsnummer (mit Inkrement, ID=2)
- POST /api/vba/word/fill-template - Word-Template füllen
- POST /api/vba/pdf/convert - Word zu PDF konvertieren

### 4. VBA-Funktionen vorhanden

Diese Funktionen müssen in Access VBA existieren:
- `Update_Rch_Nr(iID As Long) As Long` (mdl_Rechnungsschreibung.bas)
- `Textbau_Replace_Felder_Fuellen(iDocNr As Long)` (mdl_Textbaustein.bas)
- `fReplace_Table_Felder_Ersetzen(...)` (mdl_Textbaustein.bas)

### 5. Word-Template konfiguriert

In Access-Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen`:
- Datensatz mit `ID = 2` (Angebotsvorlage)
- Pfad zur Word-Vorlage (.docx)

**WICHTIG:** Unterschied zur Rechnung:
- Rechnung: ID = 1, Nummernkreis-ID = 1
- Angebot: ID = 2, Nummernkreis-ID = 2

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

**Angebotsnummer testen:**
```bash
curl http://localhost:5002/api/vba/nummern/current/2
```
**Erwartung:**
```json
{
  "success": true,
  "nummer": 5678
}
```

---

### Schritt 2: Formular öffnen

```bash
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Angebot.html"
```

**Was passiert:**
1. Kundenliste wird geladen
2. Nächste Angebotsnummer wird angezeigt (z.B. 5679)
3. Angebotsdatum = Heute
4. Gültig bis = Heute + 30 Tage
5. Eine leere Position wird angelegt

**Browser Console prüfen:**
```
[Angebot] Initializing...
[Angebot] 50 Kunden geladen
[Angebot] Nächste Angebotsnummer: 5679
[Angebot] Ready
```

---

### Schritt 3: Angebot ausfüllen

1. **Kunde wählen:**
   - Dropdown `Kunde` öffnen
   - Kunde auswählen (z.B. "Musterfirma GmbH")

2. **Angebotsdatum prüfen:**
   - Sollte auf heutigem Datum sein
   - Optional ändern

3. **Gültigkeitsdatum prüfen:**
   - Sollte 30 Tage nach Angebotsdatum sein
   - Optional ändern
   - **Validierung:** Muss nach Angebotsdatum liegen!

4. **Positionen ausfüllen:**
   - Position 1: Beschreibung = "Sicherheitsdienst (24h)", Menge = 30, Preis = 500,00
   - Button **"+ Position hinzufügen"** klicken
   - Position 2: Beschreibung = "Zusätzliche Ausrüstung", Menge = 10, Preis = 50,00

**Erwartung:**
- Summen werden automatisch berechnet:
  - Netto: 15.500,00 €
  - MwSt. 19%: 2.945,00 €
  - Gesamt: 18.445,00 €

---

### Schritt 4: Angebot erstellen (Word)

Button **"Angebot erstellen (Word)"** klicken.

**Was passiert:**
```javascript
// 1. Nächste Angebotsnummer holen und inkrementieren
POST http://localhost:5002/api/vba/nummern/next
{
  "id": 2  // 2 = Angebot (nicht 1!)
}
→ Response: { "success": true, "nummer": 5679 }

// 2. Word-Template füllen
POST http://localhost:5002/api/vba/word/fill-template
{
  "doc_nr": 2,  // 2 = Angebotsvorlage (nicht 1!)
  "iRch_KopfID": 5679,
  "kun_ID": 123
}
→ Response: { "success": true, "message": "Textbausteine gefüllt" }
```

**Erwartetes Verhalten:**
- Loading-Overlay erscheint
- Status: "Angebot wird erstellt (Word)..."
- Nach 2-3 Sekunden: Erfolgs-Meldung
- **Word-Dokument** wird in Access geöffnet
- Formular-Feld `Angebotsnummer` zeigt neue Nummer (5679)

**VBA-Bridge Server Log prüfen:**
```
[2026-01-13 00:05:01] === /api/vba/nummern/next aufgerufen ===
[2026-01-13 00:05:01] Request Data: {"id": 2}
[2026-01-13 00:05:01] VBA Eval: Update_Rch_Nr(2)
[2026-01-13 00:05:02] VBA Ergebnis: 5679
[2026-01-13 00:05:03] === /api/vba/word/fill-template aufgerufen ===
[2026-01-13 00:05:03] Request Data: {"doc_nr": 2, ...}
[2026-01-13 00:05:03] VBA Eval: Textbau_Replace_Felder_Fuellen(2)
[2026-01-13 00:05:04] VBA Eval: fReplace_Table_Felder_Ersetzen(5679, 123, 0, 0)
```

---

### Schritt 5: Angebot erstellen (PDF)

Button **"Angebot erstellen (PDF)"** klicken.

**Was passiert:**
```javascript
// 1. Nummern holen (wie oben)
// 2. Word-Template füllen (wie oben)

// 3. PDF erstellen
POST http://localhost:5002/api/vba/pdf/convert
{
  "word_path": "C:\\Temp\\Angebot_5680.docx"
}
→ Response: { "success": true, "pdf_path": "C:\\Temp\\Angebot_5680.pdf" }
```

**Erwartetes Verhalten:**
- Loading-Overlay erscheint
- Status: "Angebot wird erstellt (Word + PDF)..."
- Nach 5-10 Sekunden: Erfolgs-Meldung
- **Word-Dokument UND PDF** werden erstellt

---

### Schritt 6: Formular zurücksetzen

Button **"Zurücksetzen"** klicken.

**Was passiert:**
- Bestätigungsdialog erscheint
- Nach Bestätigung:
  - Kunde wird deselektiert
  - Angebotsdatum wird auf heute zurückgesetzt
  - Gültig bis wird auf heute + 30 Tage zurückgesetzt
  - Alle Positionen werden gelöscht
  - Eine neue leere Position wird angelegt
  - Nächste Angebotsnummer wird neu geladen

---

## Fehlersuche (Troubleshooting)

### Problem 1: "Gültigkeitsdatum muss nach dem Angebotsdatum liegen"

**Ursache:** Gültig-bis-Datum ist vor oder gleich dem Angebotsdatum

**Lösung:**
- Gültig-bis-Datum auf ein späteres Datum setzen
- Standard: Angebotsdatum + 30 Tage

---

### Problem 2: "Angebotsnummer konnte nicht geladen werden"

**Ursache:** VBA-Bridge Server nicht erreichbar oder falsche Nummernkreis-ID

**Lösung:**
1. VBA-Bridge Server läuft?
   ```bash
   curl http://localhost:5002/api/vba/status
   ```

2. Nummernkreis-ID = 2 prüfen:
   ```bash
   curl http://localhost:5002/api/vba/nummern/current/2
   ```

3. Access-Tabelle prüfen:
   ```sql
   SELECT * FROM _tblEigeneFirma_Word_Nummernkreise WHERE ID = 2
   ```
   **Muss Datensatz mit ID=2 enthalten!**

---

### Problem 3: "Word-Template konnte nicht gefüllt werden"

**Ursache:** Angebotsvorlage nicht konfiguriert (doc_nr = 2 fehlt)

**Lösung:**
1. Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen` prüfen:
   ```sql
   SELECT * FROM _tblEigeneFirma_TB_Dok_Dateinamen WHERE ID = 2
   ```
   **Muss Datensatz mit ID=2 enthalten!**

2. Pfad zur Angebotsvorlage (.docx) muss gültig sein

3. Falls nur Rechnungsvorlage (ID=1) existiert:
   - Neuen Datensatz mit ID=2 anlegen
   - Pfad zur Angebotsvorlage eintragen

---

### Problem 4: Vergleich Rechnung vs. Angebot

| Eigenschaft | Rechnung | Angebot |
|-------------|----------|---------|
| Nummernkreis-ID | 1 | 2 |
| doc_nr (Template) | 1 | 2 |
| Feld "Gültig bis" | - | ✅ 30 Tage |
| Feld "Zahlungsziel" | ✅ 14/30/60 | - |
| Word-Pfad | `C:\Temp\Rechnung_{nr}.docx` | `C:\Temp\Angebot_{nr}.docx` |

**Wichtig:** Beide nutzen dieselben VBA-Funktionen, aber mit unterschiedlichen IDs!

---

## Erfolgs-Kriterien

✅ **Kundenliste laden:** Dropdown zeigt aktive Kunden
✅ **Angebotsnummer anzeigen:** Formular zeigt nächste Nummer
✅ **Gültigkeitsdatum:** Standard = +30 Tage, Validierung funktioniert
✅ **Positionen hinzufügen:** Dynamische Zeilen funktionieren
✅ **Summen berechnen:** Netto/MwSt/Brutto automatisch
✅ **Angebot erstellen (Word):** Word-Dokument wird erstellt
✅ **Angebot erstellen (PDF):** PDF wird generiert
✅ **Nummernkreis-Inkrement:** Jedes Angebot erhöht die Nummer (ID=2)
✅ **Fehlerbehandlung:** Toasts zeigen Fehler bei Server-Ausfall

---

## Logs prüfen

**VBA-Bridge Server Log:**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\vba_bridge.log
```

**Browser Console:**
- F12 → Console-Tab
- Filter: "Angebot"

**Netzwerk-Tab:**
- F12 → Network-Tab
- Filter: "localhost:5002"
- Requests zu `/api/vba/nummern/*` prüfen
- **WICHTIG:** Parameter `{"id": 2}` für Angebot (nicht 1!)

---

## Bekannte Einschränkungen

1. **Word-Pfad hardcoded:**
   - Aktuell: `C:\Temp\Angebot_{nr}.docx`
   - Produktiv: Pfad sollte von VBA zurückgegeben werden

2. **Angebotspositionen nur im Frontend:**
   - Positionen werden nicht in Access-Datenbank gespeichert
   - Nur im Word-Template verwendet
   - Für Produktiv-Einsatz: Positions-Tabelle in Backend anlegen

3. **Angebotsvorlage muss existieren:**
   - Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen` muss ID=2 enthalten
   - Falls nicht: Manuell anlegen oder aus Rechnungsvorlage kopieren

---

## Nächste Schritte

Nach erfolgreichem Test:
1. ✅ VBA-Bridge Word/PDF-Integration funktioniert für Angebote
2. ✅ Nummernkreis-Trennung (Rechnung/Angebot) funktioniert
3. ⏳ Angebotspositionen in Backend speichern
4. ⏳ Angebot-zu-Rechnung Konvertierung
5. ⏳ Mahnwesen integrieren (Nummernkreis-ID = 4)

---

**Letzte Änderung:** 2026-01-13 00:10
**Autor:** Claude Code
**Version:** 1.0
