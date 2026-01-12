# Test-Anleitung: frm_Mahnung.html

**Version:** 1.0
**Datum:** 2026-01-13
**Phase:** 2 - VBA-Bridge Integration (Word/PDF/Nummernkreis)

---

## Überblick

Das Mahnungs-Formular wurde NEU erstellt mit vollständiger **VBA-Bridge Integration**.

**Features:**
- ✅ Überfällige Rechnungen laden via REST API (Port 5000)
- ✅ Automatische Mahnungsnummer via VBA-Bridge (Port 5002)
- ✅ Mahnstufen-Auswahl (1./2./3. Mahnung)
- ✅ Farbcodierung nach Überfälligkeit (30+/60+ Tage)
- ✅ Rechnungsauswahl mit Summierung
- ✅ Mahngebühr konfigurierbar
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
- GET /api/rechnungen/offen - Offene Rechnungen

### 3. VBA-Bridge Server (Port 5002)
```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py
```
**Endpoints:**
- GET /api/vba/nummern/current/4 - Aktuelle Mahnungsnummer
- POST /api/vba/nummern/next - Nächste Mahnungsnummer (mit Inkrement, ID=4)
- POST /api/vba/word/fill-template - Word-Template füllen
- POST /api/vba/pdf/convert - Word zu PDF konvertieren

### 4. VBA-Funktionen vorhanden

Diese Funktionen müssen in Access VBA existieren:
- `Update_Rch_Nr(iID As Long) As Long` (mdl_Rechnungsschreibung.bas)
- `Textbau_Replace_Felder_Fuellen(iDocNr As Long)` (mdl_Textbaustein.bas)
- `fReplace_Table_Felder_Ersetzen(...)` (mdl_Textbaustein.bas)
- `fMahnDat(iStufe As Long) As Long` (mdl_Rechnungsschreibung.bas)

### 5. Word-Template konfiguriert

In Access-Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen`:
- Datensatz mit `ID = 4` (Mahnungsvorlage)
- Pfad zur Word-Vorlage (.docx)

**WICHTIG:** Unterschied zu Rechnung und Angebot:
- Rechnung: ID = 1, Nummernkreis-ID = 1
- Angebot: ID = 2, Nummernkreis-ID = 2
- Brief: ID = 3, Nummernkreis-ID = 3
- Mahnung: ID = 4, Nummernkreis-ID = 4

### 6. Überfällige Rechnungen vorhanden

Für den Test sollten überfällige Rechnungen in der Datenbank existieren:
```sql
SELECT * FROM tbl_RG_Kopf
WHERE RG_IstBezahlt = 0
  AND DATEADD(d, Zahlungsziel, Rechnungsdatum) < DATE()
```

Falls keine überfälligen Rechnungen existieren:
- Testdaten anlegen mit altem Rechnungsdatum
- Oder Zahlungsziel verkürzen (z.B. auf 1 Tag)

---

## Test-Ablauf

### Schritt 1: Server-Status prüfen

**REST API (Port 5000):**
```bash
curl http://localhost:5000/api/rechnungen/offen
```
**Erwartung:** JSON-Array mit offenen Rechnungen

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

**Mahnungsnummer testen:**
```bash
curl http://localhost:5002/api/vba/nummern/current/4
```
**Erwartung:**
```json
{
  "success": true,
  "nummer": 100
}
```

---

### Schritt 2: Formular öffnen

```bash
start "" "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Mahnung.html"
```

**Was passiert:**
1. Überfällige Rechnungen werden geladen
2. Nächste Mahnungsnummer wird angezeigt (z.B. 101)
3. Mahndatum = Heute
4. Mahnstufe = 1. Mahnung (Standard)
5. Mahngebühr = 5,00 € (Standard)

**Browser Console prüfen:**
```
[Mahnung] Initializing...
[Mahnung] 15 überfällige Rechnungen geladen
[Mahnung] Nächste Mahnungsnummer: 101
[Mahnung] Ready
```

**Visuelle Prüfung:**
- Tabelle zeigt überfällige Rechnungen
- **Gelbe Zeilen:** 30+ Tage überfällig
- **Rote Zeilen:** 60+ Tage überfällig
- Spalten: ✓, Rech-Nr., Kunde, Datum, Betrag (€), Tage

---

### Schritt 3: Rechnungen auswählen

1. **Erste Rechnung anklicken:**
   - Zeile wird grün hervorgehoben
   - Häkchen ✓ erscheint in der ersten Spalte
   - Zusammenfassung wird eingeblendet

2. **Weitere Rechnungen desselben Kunden auswählen:**
   - Klicken auf weitere Zeilen desselben Kunden
   - Zusammenfassung aktualisiert sich automatisch

**Erwartung:**
```
Zusammenfassung:
┌─────────────────────────────────────┬─────────────┐
│ Ausgewählte Rechnungen:             │ 3           │
│ Rechnungsbetrag gesamt:             │ 1.500,00 €  │
│ Mahngebühr:                         │ 5,00 €      │
├─────────────────────────────────────┼─────────────┤
│ Forderung gesamt:                   │ 1.505,00 €  │
└─────────────────────────────────────┴─────────────┘
```

---

### Schritt 4: Mahnstufe und Gebühr anpassen

1. **Mahnstufe ändern:**
   - Dropdown `Mahnstufe` öffnen
   - Auswahl: 2. Mahnung (für Wiederholungsmahnung)

2. **Mahngebühr anpassen:**
   - Feld `Mahngebühr` auf 10,00 € ändern
   - Zusammenfassung aktualisiert sich automatisch
   - Forderung gesamt: 1.510,00 €

---

### Schritt 5: Mahnung erstellen (Word)

Button **"Mahnung erstellen (Word)"** klicken.

**Was passiert:**
```javascript
// 1. Nächste Mahnungsnummer holen und inkrementieren
POST http://localhost:5002/api/vba/nummern/next
{
  "id": 4  // 4 = Mahnung (nicht 1, 2 oder 3!)
}
→ Response: { "success": true, "nummer": 101 }

// 2. Word-Template füllen
POST http://localhost:5002/api/vba/word/fill-template
{
  "doc_nr": 4,  // 4 = Mahnungsvorlage (nicht 1!)
  "iRch_KopfID": 101,
  "kun_ID": 456
}
→ Response: { "success": true, "message": "Textbausteine gefüllt" }
```

**Erwartetes Verhalten:**
- Loading-Overlay erscheint
- Status: "Mahnung wird erstellt (Word)..."
- Nach 2-3 Sekunden: Erfolgs-Meldung
- **Word-Dokument** wird in Access geöffnet
- Formular-Feld `Mahnungsnummer` zeigt neue Nummer (101)
- Auswahl wird zurückgesetzt (Tabelle deselektiert)

**VBA-Bridge Server Log prüfen:**
```
[2026-01-13 00:15:01] === /api/vba/nummern/next aufgerufen ===
[2026-01-13 00:15:01] Request Data: {"id": 4}
[2026-01-13 00:15:01] VBA Eval: Update_Rch_Nr(4)
[2026-01-13 00:15:02] VBA Ergebnis: 101
[2026-01-13 00:15:03] === /api/vba/word/fill-template aufgerufen ===
[2026-01-13 00:15:03] Request Data: {"doc_nr": 4, ...}
[2026-01-13 00:15:03] VBA Eval: Textbau_Replace_Felder_Fuellen(4)
[2026-01-13 00:15:04] VBA Eval: fReplace_Table_Felder_Ersetzen(101, 456, 0, 0)
```

---

### Schritt 6: Mahnung erstellen (PDF)

Button **"Mahnung erstellen (PDF)"** klicken.

**Was passiert:**
```javascript
// 1. Nummern holen (wie oben)
// 2. Word-Template füllen (wie oben)

// 3. PDF erstellen
POST http://localhost:5002/api/vba/pdf/convert
{
  "word_path": "C:\\Temp\\Mahnung_102.docx"
}
→ Response: { "success": true, "pdf_path": "C:\\Temp\\Mahnung_102.pdf" }
```

**Erwartetes Verhalten:**
- Loading-Overlay erscheint
- Status: "Mahnung wird erstellt (Word + PDF)..."
- Nach 5-10 Sekunden: Erfolgs-Meldung
- **Word-Dokument UND PDF** werden erstellt

---

### Schritt 7: Auswahl aufheben

Button **"Auswahl aufheben"** klicken.

**Was passiert:**
- Alle Häkchen verschwinden
- Grüne Hervorhebung wird entfernt
- Zusammenfassung wird ausgeblendet

---

## Fehlersuche (Troubleshooting)

### Problem 1: "Keine überfälligen Rechnungen gefunden"

**Ursache:** Alle Rechnungen sind bezahlt oder nicht überfällig

**Lösung:**
1. Prüfen ob offene Rechnungen existieren:
   ```sql
   SELECT * FROM tbl_RG_Kopf WHERE RG_IstBezahlt = 0
   ```

2. Prüfen ob Rechnungen überfällig sind:
   ```sql
   SELECT Rechnungsnummer, Rechnungsdatum, Zahlungsziel,
          DATEADD(d, Zahlungsziel, Rechnungsdatum) AS Faellig
   FROM tbl_RG_Kopf
   WHERE RG_IstBezahlt = 0
   ```

3. Falls nötig: Testdaten mit altem Datum anlegen

---

### Problem 2: "Mahnungsnummer konnte nicht geladen werden"

**Ursache:** VBA-Bridge Server nicht erreichbar oder falsche Nummernkreis-ID

**Lösung:**
1. VBA-Bridge Server läuft?
   ```bash
   curl http://localhost:5002/api/vba/status
   ```

2. Nummernkreis-ID = 4 prüfen:
   ```bash
   curl http://localhost:5002/api/vba/nummern/current/4
   ```

3. Access-Tabelle prüfen:
   ```sql
   SELECT * FROM _tblEigeneFirma_Word_Nummernkreise WHERE ID = 4
   ```
   **Muss Datensatz mit ID=4 enthalten!**

---

### Problem 3: "Word-Template konnte nicht gefüllt werden"

**Ursache:** Mahnungsvorlage nicht konfiguriert (doc_nr = 4 fehlt)

**Lösung:**
1. Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen` prüfen:
   ```sql
   SELECT * FROM _tblEigeneFirma_TB_Dok_Dateinamen WHERE ID = 4
   ```
   **Muss Datensatz mit ID=4 enthalten!**

2. Pfad zur Mahnungsvorlage (.docx) muss gültig sein

3. Falls nur Rechnungs-/Angebotsvorlage existiert:
   - Neuen Datensatz mit ID=4 anlegen
   - Pfad zur Mahnungsvorlage eintragen
   - Oder: Rechnungsvorlage kopieren und als Mahnungsvorlage verwenden

---

### Problem 4: "Alle ausgewählten Rechnungen müssen vom selben Kunden sein"

**Ursache:** Es wurden Rechnungen von verschiedenen Kunden ausgewählt

**Lösung:**
- Eine Mahnung kann nur für EINEN Kunden erstellt werden
- Auswahl aufheben und nur Rechnungen desselben Kunden auswählen
- Für anderen Kunden: Separate Mahnung erstellen

---

### Problem 5: Vergleich Rechnung/Angebot/Mahnung

| Eigenschaft | Rechnung | Angebot | Mahnung |
|-------------|----------|---------|---------|
| Nummernkreis-ID | 1 | 2 | 4 |
| doc_nr (Template) | 1 | 2 | 4 |
| Feld "Gültig bis" | - | ✅ 30 Tage | - |
| Feld "Zahlungsziel" | ✅ 14/30/60 | - | - |
| Feld "Mahnstufe" | - | - | ✅ 1/2/3 |
| Feld "Mahngebühr" | - | - | ✅ 5,00 € |
| Rechnungsauswahl | - | - | ✅ Tabelle |
| Word-Pfad | `C:\Temp\Rechnung_{nr}.docx` | `C:\Temp\Angebot_{nr}.docx` | `C:\Temp\Mahnung_{nr}.docx` |

**Wichtig:** Alle nutzen dieselben VBA-Funktionen, aber mit unterschiedlichen IDs!

---

## Erfolgs-Kriterien

✅ **Überfällige Rechnungen laden:** Tabelle zeigt nur überfällige Rechnungen
✅ **Farbcodierung:** Gelb (30+), Rot (60+)
✅ **Rechnungsauswahl:** Klick togglet Selektion
✅ **Zusammenfassung:** Automatische Berechnung Gesamt + Gebühr
✅ **Mahnungsnummer anzeigen:** Formular zeigt nächste Nummer
✅ **Mahnstufe:** Auswahl 1./2./3. Mahnung funktioniert
✅ **Mahnung erstellen (Word):** Word-Dokument wird erstellt
✅ **Mahnung erstellen (PDF):** PDF wird generiert
✅ **Nummernkreis-Inkrement:** Jede Mahnung erhöht die Nummer (ID=4)
✅ **Validierung:** Fehler bei unterschiedlichen Kunden
✅ **Fehlerbehandlung:** Toasts zeigen Fehler bei Server-Ausfall

---

## Logs prüfen

**VBA-Bridge Server Log:**
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\vba_bridge.log
```

**Browser Console:**
- F12 → Console-Tab
- Filter: "Mahnung"

**Netzwerk-Tab:**
- F12 → Network-Tab
- Filter: "localhost:5002"
- Requests zu `/api/vba/nummern/*` prüfen
- **WICHTIG:** Parameter `{"id": 4}` für Mahnung (nicht 1, 2 oder 3!)

---

## Bekannte Einschränkungen

1. **Word-Pfad hardcoded:**
   - Aktuell: `C:\Temp\Mahnung_{nr}.docx`
   - Produktiv: Pfad sollte von VBA zurückgegeben werden

2. **Rechnungsliste nur im Frontend:**
   - Ausgewählte Rechnungen werden nicht in Mahntabelle gespeichert
   - Nur im Word-Template verwendet
   - Für Produktiv-Einsatz: Mahnung-Rechnung-Verknüpfung in Backend anlegen

3. **Mahnungsvorlage muss existieren:**
   - Tabelle `_tblEigeneFirma_TB_Dok_Dateinamen` muss ID=4 enthalten
   - Falls nicht: Manuell anlegen oder aus Rechnungsvorlage kopieren

4. **Kein Mahnlauf:**
   - Aktuell: Manuelle Auswahl von Rechnungen
   - Produktiv: Automatischer Mahnlauf mit Mahnhistorie und Eskalation

---

## Nächste Schritte

Nach erfolgreichem Test:
1. ✅ VBA-Bridge Word/PDF-Integration funktioniert für Mahnungen
2. ✅ Nummernkreis-Trennung (Rechnung/Angebot/Mahnung) funktioniert
3. ⏳ Mahnhistorie in Backend speichern (welche Rechnungen wurden gemahnt)
4. ⏳ Automatischer Mahnlauf (Batch-Verarbeitung aller überfälligen Rechnungen)
5. ⏳ Mahnstufen-Eskalation (1.→2.→3. Mahnung automatisch)
6. ⏳ Integration mit Buchhaltung (DATEV-Export)

---

**Letzte Änderung:** 2026-01-13 00:20
**Autor:** Claude Code
**Version:** 1.0
