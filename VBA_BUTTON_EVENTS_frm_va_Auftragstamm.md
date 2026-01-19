# VBA Button Events - frm_va_Auftragstamm

**Analysedatum:** 2026-01-15
**Formular:** frm_va_Auftragstamm (Auftragsverwaltung)
**Quelle:** `11_json_Export\_AccessExport_20251230_210526\frm_va_Auftragstamm.txt`

---

## Übersicht der analysierten Buttons

| Button Name | Caption (Beschriftung) | OnClick Event | VBA-Funktion |
|-------------|------------------------|---------------|--------------|
| btn_ListeStd | Namensliste ESS | [Event Procedure] | Stundenliste_erstellen() |
| btnDruckZusage | Einsatzliste drucken | [Event Procedure] | fXL_Export_Auftrag() |
| btnMailEins | Einsatzliste senden MA | [Event Procedure] | Form_frm_MA_Serien_eMail_Auftrag.Autosend() |

---

## 1. btn_ListeStd - Namensliste ESS

### Button-Definition
```vba
' Position: X=12903, Y=735, Breite=1995, Höhe=360
Name ="btn_ListeStd"
Caption ="Namensliste ESS"
OnClick ="[Event Procedure]"
```

### Click-Event Code (Zeile 6141-6143)
```vba
'Liste Stundennachweis erstellen
Private Sub btn_ListeStd_Click()
    Stundenliste_erstellen Me.ID, , Me.Veranstalter_ID
End Sub
```

### Parameter beim Aufruf
- **VA_ID**: `Me.ID` - Die ID des aktuellen Auftrags
- **MA_ID**: (Optional, nicht übergeben) - Für einzelnen Mitarbeiter
- **kun_ID**: `Me.Veranstalter_ID` - Die Kunden-ID (Veranstalter)

### Aufgerufene Funktion
**Modul:** `zmd_Listen.bas`
**Funktion:** `Stundenliste_erstellen(VA_ID As Long, Optional MA_ID As Long, Optional kun_ID As Long)`

### Funktionsweise
Die Funktion erstellt eine Excel-Liste mit allen Mitarbeiter-Zuordnungen für einen Auftrag:

**Excel-Spalten (Standard):**
- A: Datum
- B: Name
- C: Vorname
- D: von (Startzeit)
- E: bis (Endzeit)
- F: Gesamt (Stunden)
- G: Tag (Tag-Stunden)
- H: Nacht (Nacht-Stunden)
- I: Sonntag (Sonntag-Stunden)
- J: Feiertag (Feiertag-Stunden)
- K: Bezeichnung / Bemerkungen
- L: Fahrtkosten / Ist-Position

**Spezielle ESS-Kunden (kun_ID 20730, 20760, 20761):**
- L: Ist-Position
- M: Halle / Stand
- N: Name Standbetreiber
- O: Kommentar ESS (rot markiert)

**Sortierung:** Nach Datum, von-Zeit, Nachname

**Datenquelle:** `tbl_MA_VA_Zuordnung WHERE VA_ID = [VA_ID]`

**Besonderheiten:**
- Automatische Berechnung von Tag-, Nacht-, Sonntag- und Feiertagsstunden
- Spezielle Logik für ESS-Kunden (Bemerkungen werden gesplittet nach "Halle")
- Excel-Datei wird sichtbar geöffnet mit maximiertem Fenster

---

## 2. btnDruckZusage - Einsatzliste drucken

### Button-Definition
```vba
' Position: X=15195, Y=735, Breite=2295, Höhe=360
Name ="btnDruckZusage"
Caption ="Einsatzliste drucken"
OnClick ="[Event Procedure]"
```

### Click-Event Code (Zeile 7295-7357)
```vba
Private Sub btnDruckZusage_Click()

Dim Datum As Date
Dim SDatum As String
Dim Auftrag As String
Dim c As Integer

' Datum formatieren
Datum = Me.Controls("Dat_VA_Von")
SDatum = Mid(Datum, 4, 2) & "-" & Left(Datum, 2) & "-" & Right(Datum, 2)
Auftrag = Me.Controls("Auftrag")

' Excel-Export aufrufen
Call fXL_Export_Auftrag(ID, CONSYS & "\CONSEC\CONSEC PLANUNG AKTUELL\", _
                        SDatum & " " & Auftrag & " " & Objekt & ".xlsm")

'Warten
Sleep 1000
For c = 1 To 10000
    DoEvents
Next c
Sleep 1000

'Status Beendet setzen
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
On Error Resume Next
Me.Veranst_Status_ID = 2  ' Status = Beendet
Wait 2
DoCmd.RunCommand acCmdSaveRecord
On Error GoTo 0

End Sub
```

### Parameter beim Aufruf
- **VA_ID**: `Me.ID` - Die ID des aktuellen Auftrags
- **XLPfad**: `CONSYS & "\CONSEC\CONSEC PLANUNG AKTUELL\"` - Zielverzeichnis
- **XLName**: `SDatum & " " & Auftrag & " " & Objekt & ".xlsm"` - Dateiname
  - Format: `MM-DD-YY Auftragsname Objektname.xlsm`

### Aufgerufene Funktion
**Modul:** `mdl_Excel_Export.bas`
**Funktion:** `fXL_Export_Auftrag(VA_ID As Long, XLPfad As String, XLName As String)`

### Funktionsweise
Die Funktion erstellt eine Excel-Datei (.xlsm) mit Makros basierend auf einer Vorlage:

**Excel-Struktur:**
- Mehrere Arbeitsblätter ("Liste", "Liste 2", "Liste 3", etc.)
- Bis zu 5 Blätter je nach Anzahl der Mitarbeiter (max. 41 MA pro Blatt)

**Teil 1 - Auftragskopf:**
- Datenquelle: `qry_Excel_Export_Teil1`
- Enthält: Auftragsdaten, Veranstalter, Objekt, Datum, etc.

**Teil 2 - Schichten:**
- Datenquelle: `qry_Excel_Export_Teil2`
- Enthält: Schichtzeiten (von, bis)
- Sortierung: Nach vonStr, BisStr

**Teil 3 - Mitarbeiter-Einsatzliste:**
- Datenquelle: `qry_Excel_Export_Teil3`
- Bis zu 45 Nutzzeilen pro Blatt
- Sortierung: Nach VADatum, PosNr
- Zeitformatierung: "00:00" wird zu "24:00" konvertiert

**Vorlage:** Wird aus `prp_XL_DocVorlage` Property gelesen

**Nachbearbeitung:**
- Automatisches Setzen von `Veranst_Status_ID = 2` (Beendet)
- Wartezeiten für Excel-Verarbeitung (Sleep 1000ms)
- Cache-Refresh nach Änderung

---

## 3. btnMailEins - Einsatzliste senden MA

### Button-Definition
```vba
' Position: X=15195, Y=165, Breite=2295, Höhe=360
Name ="btnMailEins"
Caption ="Einsatzliste senden MA"
OnClick ="[Event Procedure]"
```

### Click-Event Code (Zeile 7392-7424)
```vba
Private Sub btnMailEins_Click()
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim i1 As Long

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

' Kein Filter auf Zeitraum
Set_Priv_Property "prp_Report1_Auftrag_IstTage", "-1"

' Prüfen ob Mitarbeiter zugeordnet sind
i1 = TCount("*", "tbl_MA_VA_Zuordnung", _
           "VADatum_ID = " & Me!cboVADatum & " AND VA_ID = " & Me!ID & " AND MA_ID > 0")

If Len(Trim(Nz(Me!ID))) > 0 And i1 > 0 Then
    iVA_ID = Me!ID
    iVADatum_ID = Me!cboVADatum

    ' Serien-E-Mail Formular öffnen
    DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
    DoEvents
    Wait 2 'Sekunden

    ' Autosend-Funktion aufrufen
    Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(2, iVA_ID, iVADatum_ID)
Else
    MsgBox "Keine Mitarbeiter vorhanden"
End If

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub
```

### Parameter beim Aufruf
- **iVA_ID**: `Me.ID` - Die ID des aktuellen Auftrags
- **iVADatum_ID**: `Me.cboVADatum` - Die ID des gewählten Datums (aus Dropdown)

### Aufgerufene Funktion
**Formular:** `frm_MA_Serien_eMail_Auftrag`
**Funktion:** `Form_frm_MA_Serien_eMail_Auftrag.Autosend(2, iVA_ID, iVADatum_ID)`

**Parameter an Autosend:**
1. **Modus:** `2` (Bedeutung: Einsatzliste an Mitarbeiter senden)
2. **VA_ID:** Die Auftrags-ID
3. **VADatum_ID:** Die Datums-ID

### Funktionsweise
Die Funktion sendet E-Mails an alle zugeordneten Mitarbeiter:

**Voraussetzungen:**
- Mindestens 1 Mitarbeiter muss zugeordnet sein (`MA_ID > 0`)
- Auftrag muss eine gültige ID haben

**Ablauf:**
1. Property `prp_Report1_Auftrag_IstTage` auf "-1" setzen (kein Zeitraum-Filter)
2. Anzahl zugeordneter Mitarbeiter prüfen
3. Serien-E-Mail Formular öffnen (`frm_MA_Serien_eMail_Auftrag`)
4. 2 Sekunden warten (Formular laden)
5. Autosend-Funktion mit Modus 2 (Einsatzliste) aufrufen
6. Cache-Refresh

**E-Mail-Inhalt (vermutlich):**
- Einsatzdetails (Datum, Zeit, Ort, Objekt)
- Persönliche Zuordnungsdaten
- Möglicherweise PDF-Anhang mit Einsatzliste

**Hinweis:** Der genaue Code der `Autosend`-Funktion konnte nicht gefunden werden. Das Formular `frm_MA_Serien_eMail_Auftrag` ist in einem separaten Export und muss noch analysiert werden.

---

## 4. btnDruckZusage1 - Mehrtagesliste drucken

**Hinweis:** Dieser Button wurde ebenfalls gefunden (Zeile 7358-7391), aber war nicht in der ursprünglichen Anfrage enthalten.

### Kurzbeschreibung
- **Caption:** "Mehrtagesliste drucken"
- **Funktion:** Öffnet Report `rpt_Auftrag_Zusage` in Vorschau
- **Besonderheit:** Prüft ob Daten >= Heute vorhanden sind über Property `prp_Report1_Auftrag_IstTage`

---

## Abhängigkeiten und Helper-Funktionen

### Verwendete Module
1. **zmd_Listen.bas** - Stundenlisten-Export
2. **mdl_Excel_Export.bas** - Excel-Einsatzlisten-Export
3. **zmd_Funktionen.bas** - Helper-Funktionen (TCount, TLookup, etc.)
4. **zmd_Const.bas** - Konstanten (AUFTRAGSTAMM, ZUORDNUNG, MASTAMM, CONSYS, etc.)

### Verwendete Helper-Funktionen
- `TLookup()` - Einzelwert aus Tabelle holen
- `TCount()` - Anzahl Datensätze zählen
- `stunden()` - Stunden zwischen zwei Zeiten berechnen
- `Stunden_Zuschlag()` - Zuschlagsstunden berechnen (Nacht, Sonntag, Feiertag)
- `Get_Priv_Property()` - Private Property lesen
- `Set_Priv_Property()` - Private Property setzen
- `ArrFill_DAO()` - Recordset in Array laden
- `Wait()` - Wartefunktion
- `Sleep()` - Windows Sleep API

### Verwendete Abfragen
- `qry_Excel_Export_Teil1` - Auftragskopf
- `qry_Excel_Export_Teil2` - Schichten
- `qry_Excel_Export_Teil3` - Mitarbeiter-Einsatzliste
- `qry_Excel_Sel_Import_Felder` - Feldmapping für Excel-Import
- `qry_Report_Auftrag_Sort_Select_All` - Report-Datenselektion

### Verwendete Tabellen
- `tbl_VA_Auftragstamm` - Auftragsstammdaten
- `tbl_MA_VA_Zuordnung` - Mitarbeiter-Zuordnungen
- `tbl_VA_Start` - Schichten
- `tbl_MA_Mitarbeiterstamm` - Mitarbeiterstammdaten
- `tbl_KD_Kundenstamm` - Kundenstammdaten

---

## Implementierungs-Empfehlungen für HTML/JavaScript

### 1. btn_ListeStd → API Endpoint
```javascript
// POST /api/auftraege/{va_id}/stundenliste-export
// Parameter:
{
    "va_id": 12345,           // Pflicht
    "ma_id": null,            // Optional (für einzelnen MA)
    "kun_id": 20730,          // Pflicht (für ESS-Logik)
    "format": "xlsx"          // xlsx oder pdf
}

// Response:
{
    "success": true,
    "file_url": "http://localhost:5000/exports/2026-01-15_Auftrag_Stundenliste.xlsx",
    "filename": "2026-01-15_Auftrag_Stundenliste.xlsx"
}
```

### 2. btnDruckZusage → API Endpoint
```javascript
// POST /api/auftraege/{va_id}/einsatzliste-export
// Parameter:
{
    "va_id": 12345,           // Pflicht
    "dat_va_von": "2026-01-15",
    "auftrag": "Messe München",
    "objekt": "Halle A1",
    "xl_pfad": "\\\\server\\pfad",  // Optional
    "xl_name": "01-15-26 Messe München Halle A1.xlsm"
}

// Response:
{
    "success": true,
    "file_path": "\\\\server\\CONSEC\\CONSEC PLANUNG AKTUELL\\01-15-26 Messe München Halle A1.xlsm",
    "status_updated": true,    // Veranst_Status_ID auf 2 gesetzt
    "record_saved": true
}
```

### 3. btnMailEins → API Endpoint
```javascript
// POST /api/auftraege/{va_id}/einsatzliste-senden
// Parameter:
{
    "va_id": 12345,           // Pflicht
    "vadatum_id": 67890,      // Pflicht (ID des gewählten Datums)
    "modus": 2                // 2 = Einsatzliste, 3 = Positionsanfrage
}

// Response:
{
    "success": true,
    "emails_sent": 15,        // Anzahl versendeter E-Mails
    "recipients": [
        { "ma_id": 1, "name": "Mustermann, Max", "email": "max@example.com" },
        { "ma_id": 2, "name": "Musterfrau, Maria", "email": "maria@example.com" }
    ],
    "errors": []              // Liste von Fehlern, falls welche auftraten
}
```

### HTML Button Integration
```html
<!-- Im Auftragstamm-Formular -->
<div class="button-group">
    <button id="btnListeStd" onclick="exportStundenliste()">
        Namensliste ESS
    </button>

    <button id="btnDruckZusage" onclick="exportEinsatzliste()">
        Einsatzliste drucken
    </button>

    <button id="btnMailEins" onclick="sendeEinsatzliste()">
        Einsatzliste senden MA
    </button>
</div>

<script>
async function exportStundenliste() {
    const va_id = document.getElementById('ID').value;
    const kun_id = document.getElementById('Veranstalter_ID').value;

    const response = await fetch(`http://localhost:5000/api/auftraege/${va_id}/stundenliste-export`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ va_id, kun_id, format: 'xlsx' })
    });

    const result = await response.json();
    if (result.success) {
        window.open(result.file_url, '_blank');
    }
}

async function exportEinsatzliste() {
    const va_id = document.getElementById('ID').value;
    const dat_va_von = document.getElementById('Dat_VA_Von').value;
    const auftrag = document.getElementById('Auftrag').value;
    const objekt = document.getElementById('Objekt').value;

    const response = await fetch(`http://localhost:5000/api/auftraege/${va_id}/einsatzliste-export`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ va_id, dat_va_von, auftrag, objekt })
    });

    const result = await response.json();
    if (result.success) {
        alert('Einsatzliste wurde erstellt und Status auf "Beendet" gesetzt.');
        // Formular neu laden oder Status-Feld aktualisieren
        location.reload();
    }
}

async function sendeEinsatzliste() {
    const va_id = document.getElementById('ID').value;
    const vadatum_id = document.getElementById('cboVADatum').value;

    // Prüfen ob Mitarbeiter zugeordnet sind
    const checkResponse = await fetch(`http://localhost:5000/api/auftraege/${va_id}/zuordnungen?vadatum_id=${vadatum_id}`);
    const zuordnungen = await checkResponse.json();

    if (zuordnungen.length === 0) {
        alert('Keine Mitarbeiter vorhanden');
        return;
    }

    const response = await fetch(`http://localhost:5000/api/auftraege/${va_id}/einsatzliste-senden`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ va_id, vadatum_id, modus: 2 })
    });

    const result = await response.json();
    if (result.success) {
        alert(`E-Mails wurden an ${result.emails_sent} Mitarbeiter versendet.`);
    }
}
</script>
```

---

## Zusammenfassung

### Kritische Erkenntnisse
1. **btnDruckZusage ändert Daten:** Setzt `Veranst_Status_ID = 2` nach Export
2. **Lange Wartezeiten:** Sleep-Funktionen und DoEvents für Excel-Verarbeitung
3. **ESS-Speziallogik:** Kunde 20730, 20760, 20761 haben Sonderbehandlung
4. **Autosend-Funktion fehlt:** Code von `frm_MA_Serien_eMail_Auftrag.Autosend()` konnte nicht gefunden werden

### Fehlende Informationen
- Genaue Logik der `Autosend()`-Funktion im Serien-E-Mail Formular
- E-Mail-Templates und -Inhalte
- Property-Definitionen (`prp_XL_DocVorlage`, `prp_Report1_Auftrag_IstTage`, etc.)
- Struktur der Excel-Vorlagen-Datei

### Nächste Schritte für HTML-Integration
1. API-Endpoints für die 3 Funktionen implementieren
2. Excel-Export-Logik nach Python/Flask portieren
3. E-Mail-Versand-Logik analysieren und portieren
4. Frontend-Buttons mit Event-Handlern verknüpfen
5. Fehlerbehandlung und User-Feedback implementieren

---

**Ende des Reports**
