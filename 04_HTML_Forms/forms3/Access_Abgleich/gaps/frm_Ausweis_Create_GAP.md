# Gap-Analyse: frm_Ausweis_Create

**Analysiert am:** 2026-01-12
**Access-Export:** forms3/Access_Abgleich/forms/frm_Ausweis_Create.md
**HTML-Formular:** forms3/frm_Ausweis_Create.html
**Logic-JS:** forms3/logic/frm_Ausweis_Create.logic.js

---

## Executive Summary

### Formular-Umfang
- **Access Controls:** 50
  - 20 Buttons (14 Ausweis-/Karten-Druck, 6 Utility)
  - 2 ListBoxen (MA-Auswahl, Ausweisliste)
  - 1 TextBox (Gültigkeitsdatum)
  - 1 ComboBox (Kartendrucker)
  - 1 SubForm (Menüführung)
  - 7 Labels
  - 18 versteckte/System-Buttons

### Implementierungsstatus
- **HTML-Struktur:** ✅ **Sehr gut implementiert** (90%)
- **Feldmapping:** ✅ **Vollständig** (100%)
- **Button-Logik:** ⚠️ **Teilweise** (60%)
- **Druck-Integration:** ❌ **Fehlt komplett** (0%)
- **API-Integration:** ✅ **WebView2 Bridge vorhanden** (80%)

### Kritische Gaps
1. **PDF/Ausweis-Druck** nicht implementiert (VBA-Bridge benötigt)
2. **Kartendruck** auf physischen Druckern fehlt
3. **Foto-Upload** für Ausweise nicht vorhanden
4. **Ausweis-Nummerierung** (DienstausweisNr) nicht synchronisiert
5. **Filter nach Anstellungsart** (3 oder 5) fehlt in HTML

---

## 1. FORMULAR-EIGENSCHAFTEN

### Access
```
RecordSource: Keine (ungebundenes Formular)
AllowEdits: True
AllowAdditions: True
AllowDeletions: True
DataEntry: False
DefaultView: Other (Einzelformular)
NavigationButtons: False
Zweck: Ausweis-Erstellung für MA mit Anstellungsart 3 oder 5
```

### HTML
```javascript
// Ungebundenes Formular - nur State Management
state = {
    allEmployees: [],      // Alle MA (Filter: aktiv)
    selectedEmployees: [], // Ausgewählte MA für Ausweis
    validUntil: null       // Gültigkeitsdatum
}

// Datenquelle via WebView2 Bridge
Bridge.loadData('mitarbeiter', { aktiv: true })
```

### Status: ⚠️ Filter fehlt
**Gap:** Access filtert nach Anstellungsart 3 oder 5, HTML nur nach "aktiv"

```javascript
// ❌ FEHLT: Anstellungsart-Filter
// Access SQL: "SELECT * FROM tbl_MA WHERE Anstellungsart_ID IN (3, 5)"
// HTML: Kein Anstellungsart-Filter

// EMPFOHLEN:
Bridge.loadData('mitarbeiter', {
    aktiv: true,
    anstellungsarten: [3, 5] // Freie MA, Honorarkräfte
})
```

---

## 2. LISTBOXEN (2 Stück)

### lstMA_Alle (Alle Mitarbeiter)

| Eigenschaft | Access | HTML | Status |
|-------------|--------|------|--------|
| **RowSource** | SELECT mit Anstellungsart 3 oder 5 | Bridge API | ⚠️ Filter fehlt |
| **ColumnCount** | 7 | 1 (formatiert) | ✅ OK |
| **Spalten** | ID, Nachname, Vorname, AusweisNr, GueltBis, Foto, Anstellungsart | Formatierter String | ✅ OK |
| **MultiSelect** | Extended | multiple | ✅ OK |
| **OnDblClick** | Procedure (addSelected) | Nicht vorhanden | ⚠️ Fehlt |
| **OnKeyDown** | Procedure (addSelected bei Enter) | Nicht vorhanden | ⚠️ Fehlt |

**Gap-Details:**
```javascript
// ❌ FEHLT: Doppelklick zum Hinzufügen
document.getElementById('lstMA_Alle').addEventListener('dblclick', (e) => {
    if (e.target.tagName === 'OPTION') {
        e.target.selected = true;
        addSelected();
    }
});

// ❌ FEHLT: Enter-Taste zum Hinzufügen
document.getElementById('lstMA_Alle').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
        addSelected();
    }
});
```

### lstMA_Ausweis (Ausgewählte Mitarbeiter)

| Eigenschaft | Access | HTML | Status |
|-------------|--------|------|--------|
| **RowSource** | qry_Ausweis_Selekt | State Array | ✅ OK |
| **ColumnCount** | 3 | 1 (formatiert) | ✅ OK |
| **Spalten** | ID, Name, AusweisNr | Formatierter String | ✅ OK |
| **OnDblClick** | Procedure (removeSelected) | Nicht vorhanden | ⚠️ Fehlt |

---

## 3. TEXTBOX & COMBOBOX

### GueltBis (Gültigkeitsdatum)

| Eigenschaft | Access | HTML | Status |
|-------------|--------|------|--------|
| **DefaultValue** | `=DateSerial(Year(Date()),12,31)` | JavaScript Berechnung | ✅ OK |
| **Format** | dd/mm/yy | type="date" | ✅ OK |
| **Value** | Jahresende | Korrekt gesetzt | ✅ OK |

### cbo_Kartendrucker (Druckerauswahl)

| Eigenschaft | Access | HTML | Status |
|-------------|--------|------|--------|
| **RowSource** | Dynamische Druckerliste (VBA) | Statische Optionen | ⚠️ Keine echte Druckerliste |

**Gap:**
```javascript
// ❌ FEHLT: Dynamische Druckerliste via Bridge
// Access: Liest verfügbare Drucker aus System
// HTML: Hardcodierte Liste

// EMPFOHLEN:
Bridge.sendEvent('getPrinters', {}, (printers) => {
    const select = document.getElementById('cbo_Kartendrucker');
    select.innerHTML = '<option value="">--- Drucker wählen ---</option>';
    printers.forEach(p => {
        select.innerHTML += `<option value="${p.name}">${p.name}</option>`;
    });
});
```

---

## 4. BUTTONS (20 Stück)

### Transfer-Buttons (5 Stück)

| Access-Button | HTML-ID | onclick | Status |
|---------------|---------|---------|--------|
| **btnAddSelected** | btnAddSelected | ✅ `addSelected()` | ✅ OK |
| **btnDelSelected** | btnDelSelected | ✅ `removeSelected()` | ✅ OK |
| **btnAddAll** | btnAddAll | ✅ `addAll()` | ✅ Hidden (wie Access) |
| **btnDelAll** | btnDelAll | ✅ `removeAll()` | ✅ Hidden (wie Access) |
| **btnDeselect** | btnDeselect | ✅ `deselectAll()` | ✅ Hidden (wie Access) |

### Ausweis-Buttons (6 Stück)

| Access-Button | HTML-ID | Funktion | Status |
|---------------|---------|----------|--------|
| **btn_ausweiseinsatzleitung** | btn_ausweiseinsatzleitung | Ausweis Einsatzleitung | ⚠️ Kein VBA-Call |
| **btn_ausweisBereichsleiter** | btn_ausweisBereichsleiter | Ausweis Bereichsleiter | ⚠️ Kein VBA-Call |
| **btn_ausweissec** | btn_ausweissec | Ausweis Security | ⚠️ Kein VBA-Call |
| **btn_ausweisservice** | btn_ausweisservice | Ausweis Service | ⚠️ Kein VBA-Call |
| **btn_ausweisplatzanweiser** | btn_ausweisplatzanweiser | Ausweis Platzanweiser | ⚠️ Kein VBA-Call |
| **btn_ausweisstaff** | btn_ausweisstaff | Ausweis Staff | ⚠️ Kein VBA-Call |

**Farben korrekt:**
- Grün (Management/Security): Einsatzleitung, Bereichsleiter, Security ✅
- Gelb (Service/Staff): Service, Platzanweiser, Staff ✅

**Gap-Details:**
```javascript
// ⚠️ VORHANDEN: Bridge-Event wird gesendet
function printBadge(badgeType) {
    Bridge.sendEvent('createBadge', {
        badgeType: badgeType,
        employees: state.selectedEmployees,
        validUntil: state.validUntil
    });
}

// ❌ FEHLT: VBA-Handler in Access
// Access benötigt: Sub OnBridgeEvent_createBadge(data)
//   1. Report öffnen: rpt_Ausweis_Typ (mit BadgeType-Parameter)
//   2. Daten filtern nach employee IDs
//   3. PDF generieren
//   4. An Drucker senden
```

### Karten-Buttons (4 Stück)

| Access-Button | HTML-ID | Funktion | Status |
|---------------|---------|----------|--------|
| **btn_Karte_Sicherheit** | btn_Karte_Sicherheit | Karte Sicherheit | ⚠️ Kein VBA-Call |
| **btn_Karte_Service** | btn_Karte_Service | Karte Service | ⚠️ Kein VBA-Call |
| **btn_Karte_Rueck** | btn_Karte_Rück | Karte Rückseite | ⚠️ Kein VBA-Call |
| **btn_Sonder** | btn_Sonder | Sonderkarte | ⚠️ Kein VBA-Call |

**Gap:** Wie Ausweis-Buttons - VBA-Handler fehlt

### Utility-Buttons (5 Stück)

| Access-Button | HTML | Status |
|---------------|------|--------|
| **btnRibbonAus** | ❌ Nicht vorhanden | N/A (Web-Kontext) |
| **btnRibbonEin** | ❌ Nicht vorhanden | N/A (Web-Kontext) |
| **btnDaBaEin** | ❌ Nicht vorhanden | N/A (Web-Kontext) |
| **btnDaBaAus** | ❌ Nicht vorhanden | N/A (Web-Kontext) |
| **btnDienstauswNr** | ❌ Nicht vorhanden | ⚠️ Fehlt (Ausweis-Nr vergeben) |

**Kritischer Gap:**
```javascript
// ❌ FEHLT: Button "Dienstausweis-Nr vergeben"
// Access: btnDienstauswNr -> VBA-Procedure
// Funktion: Nächste freie Ausweis-Nummer vergeben und in DB speichern

// EMPFOHLEN: Button hinzufügen
<button id="btnDienstauswNr" onclick="vergibeDienstausweisNr()">
    Ausweis-Nr vergeben
</button>

async function vergibeDienstausweisNr() {
    if (state.selectedEmployees.length === 0) {
        showToast('Keine Mitarbeiter ausgewählt', 'warning');
        return;
    }

    // Via Bridge: VBA-Funktion aufrufen
    Bridge.sendEvent('vergibeDienstausweisNr', {
        employeeIds: state.selectedEmployees.map(e => e.ID)
    });
}
```

---

## 5. EVENTS

### Formular-Events

| Event | Access | HTML | Status |
|-------|--------|------|--------|
| **OnOpen** | Procedure | - | ⚠️ Nicht übertragbar |
| **OnLoad** | Procedure | DOMContentLoaded | ✅ OK |

### ListBox-Events

| Control | Event | Access | HTML | Status |
|---------|-------|--------|------|--------|
| lstMA_Alle | OnDblClick | Procedure (addSelected) | ❌ Fehlt | ⚠️ Gap |
| lstMA_Alle | OnKeyDown | Procedure (Enter = addSelected) | ❌ Fehlt | ⚠️ Gap |
| lstMA_Ausweis | OnDblClick | Procedure (removeSelected) | ❌ Fehlt | ⚠️ Gap |

---

## 6. FUNKTIONALITÄT

### Implementierte Features ✅

1. **Mitarbeiterliste laden** via Bridge ✅
2. **Transfer-Operationen** (Hinzufügen, Entfernen) ✅
3. **Gültigkeitsdatum** automatisch auf Jahresende setzen ✅
4. **Zähler** (Anzahl MA links/rechts) ✅
5. **Formatierung** der MA-Zeilen mit AusweisNr und GueltBis ✅
6. **Bridge-Events senden** für Ausweis/Karten-Druck ✅

### Fehlende Features ❌

1. **Ausweis-Druck** (PDF-Generierung via VBA-Bridge) ❌
2. **Kartendruck** auf physischen Druckern ❌
3. **Foto-Upload** für Ausweise ❌
4. **Ausweis-Nr vergeben** (Button + VBA-Funktion) ❌
5. **Dynamische Druckerliste** ❌
6. **Doppelklick/Enter** in Listen ❌
7. **Filter Anstellungsart** 3 oder 5 ❌

---

## 7. DATENANBINDUNG

### Access-Queries

```sql
-- lstMA_Alle RowSource
SELECT ID, Nachname, Vorname, DienstausweisNr, Ausweis_GueltBis, Foto, Anstellungsart_ID
FROM tbl_MA_Mitarbeiterstamm
WHERE Anstellungsart_ID IN (3, 5) AND IstAktiv = True
ORDER BY Nachname, Vorname

-- lstMA_Ausweis RowSource
SELECT * FROM qry_Ausweis_Selekt
-- (Temporäre Query, gefiltert nach ausgewählten MA-IDs)
```

### HTML/Bridge

```javascript
// ⚠️ FEHLT: Anstellungsart-Filter
// Aktuell:
Bridge.loadData('mitarbeiter', { aktiv: true })

// Benötigt:
Bridge.loadData('mitarbeiter', {
    aktiv: true,
    anstellungsarten: [3, 5]
})
```

### Benötigte API-Endpoints

```javascript
// ✅ VORHANDEN:
GET /api/mitarbeiter?aktiv=1

// ❌ FEHLT:
GET /api/mitarbeiter?aktiv=1&anstellungsart_in=3,5
POST /api/mitarbeiter/:id/ausweisNr  // Ausweis-Nr vergeben
GET /api/druckers                     // Verfügbare Drucker
```

---

## 8. VBA-BRIDGE INTEGRATION

### Benötigte VBA-Funktionen (in Access)

```vba
' ❌ FEHLT: Bridge-Event-Handler in Access

' 1. Ausweis-Druck
Public Sub OnBridgeEvent_createBadge(data As String)
    Dim json As Object
    Set json = ParseJSON(data)

    Dim badgeType As String
    badgeType = json("badgeType")

    ' Report öffnen und drucken
    DoCmd.OpenReport "rpt_Ausweis_" & badgeType, acViewPreview, , _
        "ID IN (" & Join(json("employeeIds"), ",") & ")"

    ' PDF speichern
    Dim pdfPath As String
    pdfPath = GetAusweisPfad() & "Ausweise_" & Format(Now, "yyyy-mm-dd_hhnnss") & ".pdf"
    DoCmd.OutputTo acOutputReport, "rpt_Ausweis_" & badgeType, acFormatPDF, pdfPath

    ' Zurück an HTML senden
    WebView2Bridge.PostWebMessage "{""event"":""badgeCreated"",""path"":""" & pdfPath & """}"
End Sub

' 2. Kartendruck
Public Sub OnBridgeEvent_printCard(data As String)
    Dim json As Object
    Set json = ParseJSON(data)

    Dim cardType As String
    Dim printer As String
    cardType = json("cardType")
    printer = json("printer")

    ' Auf Kartendrucker drucken
    Application.Printer = Application.Printers(printer)
    DoCmd.OpenReport "rpt_Karte_" & cardType, acViewNormal, , _
        "ID IN (" & Join(json("employeeIds"), ",") & ")"
End Sub

' 3. Ausweis-Nr vergeben
Public Sub OnBridgeEvent_vergibeDienstausweisNr(data As String)
    Dim json As Object
    Set json = ParseJSON(data)

    Dim rs As DAO.Recordset
    Dim nextNr As Long
    nextNr = Nz(DMax("DienstausweisNr", "tbl_MA_Mitarbeiterstamm"), 0) + 1

    For Each empId In json("employeeIds")
        Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID=" & empId)
        If Not rs.EOF Then
            rs.Edit
            rs!DienstausweisNr = nextNr
            rs!Ausweis_GueltBis = CDate(json("validUntil"))
            rs.Update
            nextNr = nextNr + 1
        End If
        rs.Close
    Next

    ' Erfolg zurückmelden
    WebView2Bridge.PostWebMessage "{""event"":""ausweisNrVergeben"",""count"":" & json("employeeIds").Count & "}"
End Sub

' 4. Druckerliste abrufen
Public Function GetPrinters() As String
    Dim printers As String
    Dim p As Printer

    printers = "["
    For Each p In Application.Printers
        If printers <> "[" Then printers = printers & ","
        printers = printers & "{""name"":""" & p.DeviceName & """}"
    Next
    printers = printers & "]"

    GetPrinters = printers
End Function
```

---

## 9. COMPLETION-ANALYSE

### Controls (50 gesamt)

| Typ | Access | HTML | Implementiert | Prozent |
|-----|--------|------|---------------|---------|
| ListBox | 2 | 2 | 2 (ohne Events) | 80% |
| TextBox | 1 | 1 | 1 | 100% |
| ComboBox | 1 | 1 | 1 (statisch) | 70% |
| Buttons (Transfer) | 5 | 5 | 5 | 100% |
| Buttons (Ausweis) | 6 | 6 | 6 (ohne VBA) | 50% |
| Buttons (Karten) | 4 | 4 | 4 (ohne VBA) | 50% |
| Buttons (Utility) | 5 | 0 | 0 | 0% |
| Labels | 7 | 7 | 7 | 100% |
| SubForm | 1 | 0 | 0 | 0% |
| **GESAMT** | **32** | **26** | **26 teilweise** | **65%** |

### Funktionalität

| Feature | Status | Prozent |
|---------|--------|---------|
| MA-Liste laden | ✅ Gut (Filter fehlt) | 80% |
| Transfer-Operationen | ✅ Vollständig | 100% |
| Gültigkeitsdatum | ✅ Vollständig | 100% |
| Ausweis-Druck | ⚠️ Event gesendet, VBA fehlt | 30% |
| Kartendruck | ⚠️ Event gesendet, VBA fehlt | 30% |
| Ausweis-Nr vergeben | ❌ Fehlt komplett | 0% |
| Foto-Upload | ❌ Fehlt komplett | 0% |
| Dynamische Drucker | ❌ Fehlt komplett | 0% |
| ListBox-Events | ❌ DblClick/Enter fehlt | 0% |
| **GESAMT** | | **38%** |

---

## 10. AUFWAND-SCHÄTZUNG

### Quick Wins (4-8 Stunden)
1. **ListBox-Events** (DblClick, Enter) - 2h
2. **Filter Anstellungsart** in Bridge-Call - 1h
3. **Button "Ausweis-Nr vergeben"** (HTML) - 2h
4. **Dynamische Druckerliste** (Bridge-Call) - 3h

### Medium Effort (8-16 Stunden)
5. **VBA-Bridge-Handler** in Access (createBadge, printCard, vergibeDienstausweisNr) - 12h
6. **Report-Anpassungen** für Ausweis-Typen - 8h

### High Effort (16-40 Stunden)
7. **Foto-Upload** + Speicherung - 20h
8. **PDF-Preview** in HTML vor Druck - 16h

**Gesamt-Aufwand:** 64 Stunden

---

## 11. PRIORITÄTEN

### P1 - Kritisch (Blockiert Produktivbetrieb)
1. ✅ MA-Liste laden (ERLEDIGT)
2. ✅ Transfer-Operationen (ERLEDIGT)
3. ❌ VBA-Bridge-Handler für Ausweis-Druck
4. ❌ Button "Ausweis-Nr vergeben"

### P2 - Wichtig (Workflow-Verbesserung)
5. ❌ Filter Anstellungsart 3, 5
6. ❌ Dynamische Druckerliste
7. ❌ ListBox DblClick/Enter Events
8. ❌ VBA-Handler für Kartendruck

### P3 - Nice-to-Have
9. ❌ Foto-Upload für Ausweise
10. ❌ PDF-Preview vor Druck

---

## 12. FAZIT

### Stärken
- ✅ Grundstruktur sehr gut umgesetzt
- ✅ Transfer-Logik vollständig funktionsfähig
- ✅ UI/UX entspricht Access-Look
- ✅ Bridge-Events werden korrekt gesendet

### Schwächen
- ❌ Keine VBA-Bridge-Handler für Druck-Funktionen
- ❌ Ausweis-Nr-Vergabe fehlt komplett
- ❌ Keine Foto-Upload-Möglichkeit
- ❌ Filter Anstellungsart nicht implementiert
- ❌ ListBox-Events fehlen

### Empfehlung
**Formular ist zu 65% funktionsfähig** für Auswahl und Vorbereitung, aber **nicht production-ready** ohne VBA-Bridge-Integration für Druck-Funktionen.

**Nächste Schritte:**
1. VBA-Bridge-Handler implementieren (12h)
2. Button "Ausweis-Nr vergeben" hinzufügen (2h)
3. Filter Anstellungsart implementieren (1h)
4. ListBox-Events ergänzen (2h)

**Nach diesen Fixes:** 85% Completion, production-ready für Basis-Workflow.
