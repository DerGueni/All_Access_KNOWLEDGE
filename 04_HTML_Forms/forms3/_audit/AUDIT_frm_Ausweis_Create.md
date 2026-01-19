# AUDIT-REPORT: frm_Ausweis_Create.html

**Datum:** 2026-01-03
**Formular:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Ausweis_Create.html`
**Logic-Datei:** `logic\frm_Ausweis_Create.logic.js`
**Status:** ✅ WEBVIEW2-KONFORM (nach Umstellung)

---

## PHASE 1: FUNKTIONALITÄTS-AUDIT

### 1. Formular-Zweck
Das Formular dient zur **Erstellung und zum Druck von Dienstausweisen** für Mitarbeiter der CONSEC Security. Es unterstützt verschiedene Ausweis-Typen sowie Kartendruck auf speziellen Druckern.

### 2. Funktionale Bereiche

#### **A. Mitarbeiter-Auswahl (Dual-List-Box)**
- **Linke Liste:** Alle aktiven Mitarbeiter
- **Rechte Liste:** Für Ausweis-Erstellung ausgewählte Mitarbeiter
- **Transfer-Buttons:**
  - `>` - Ausgewählte hinzufügen
  - `<` - Ausgewählte entfernen
  - `>>` - Alle hinzufügen (versteckt)
  - `<<` - Alle entfernen (versteckt)
  - `✕` - Auswahl aufheben (versteckt)
- **Counter:** Zeigt Anzahl in beiden Listen
- **Format:** `Nachname, Vorname | Ausweis: Nr | Gültig: Datum`

#### **B. Einstellungen (Right Panel)**
1. **Gültig bis:** Datumseingabe (Standard: 31.12. des aktuellen Jahres)
2. **Kartendrucker:** Dropdown mit 3 Optionen
   - Kartendrucker 1
   - Kartendrucker 2
   - Standard-Drucker

#### **C. Ausweis-Druckfunktionen (6 Typen)**
**Grüne Ausweise (Management/Security):**
- Einsatzleitung
- Bereichsleiter
- Security

**Gelbe Ausweise (Service/Staff):**
- Service
- Platzanweiser
- Staff

#### **D. Karten-Druckfunktionen (4 Typen)**
- Sicherheit
- Service
- Rückseite
- Sonder

### 3. Validierungen
- ✅ Mindestens 1 Mitarbeiter ausgewählt vor Druck
- ✅ Gültigkeitsdatum muss gesetzt sein
- ✅ Kartendrucker muss für Kartendruck ausgewählt sein
- ✅ Toast-Benachrichtigungen für alle Aktionen

### 4. UI/UX-Features
- Counter für beide Listen
- Footer-Statusmeldung: "Ausgewählte MA: X"
- Farbcodierte Buttons (grün/gelb je nach Ausweis-Typ)
- Responsive Layout mit fixed Right-Panel (320px)
- Header mit Aktualisierungs-Button

---

## PHASE 2: WEBVIEW2-BRIDGE ANALYSE

### Original-Implementierung (VOR Umstellung)

**Gefundene Probleme:**
1. ❌ `webview2-bridge.js` **nicht eingebunden** im HTML
2. ❌ Falscher DataType: `Bridge.loadData('badge', ...)` statt `'mitarbeiter'`
3. ❌ Keine `sendEvent`-Calls für Ausweis/Kartendruck
4. ❌ Nur Client-seitige Preview, keine Backend-Integration

### Bridge-Methoden (aus webview2-bridge.js)

**Verfügbare Funktionen:**
- `Bridge.init(options)` - Auto-initialisiert
- `Bridge.loadData(dataType, id)` - Daten vom Backend laden
- `Bridge.sendEvent(eventType, data)` - Events an Access senden
- `Bridge.on(eventName, handler)` - Event-Handler registrieren
- `Bridge.onDataReceived(jsonData)` - Daten vom Access empfangen
- `Bridge.fillForm(data)` - Formularfelder automatisch befüllen

**Unterstützte DataTypes:**
- `'mitarbeiter'` - Mitarbeiterstamm-Daten
- `'kunde'` - Kundenstamm
- `'auftrag'` - Auftragsdaten

**Event-Types:**
- `'save'`, `'delete'`, `'navigate'`, `'refresh'`, `'close'`
- **Custom:** `'createBadge'`, `'printCard'` (neu)

---

## PHASE 3: DURCHGEFÜHRTE FIXES

### 1. WebView2-Bridge Einbindung
```html
<!-- VORHER -->
<script src="../js/sidebar.js"></script>
<script src="logic/frm_Ausweis_Create.logic.js"></script>

<!-- NACHHER -->
<script src="../js/webview2-bridge.js"></script>
<script src="../js/sidebar.js"></script>
<script src="logic/frm_Ausweis_Create.logic.js"></script>
```

### 2. Mitarbeiter-Laden korrigiert
```javascript
// VORHER
Bridge.loadData('badge', { aktiv: true });

// NACHHER
Bridge.loadData('mitarbeiter', { aktiv: true });
```

### 3. Ausweis-Druck über Bridge
```javascript
// NEU: createBadge Event
Bridge.sendEvent('createBadge', {
    badgeType: badgeType,               // 'Einsatzleitung', 'Security', etc.
    employees: [
        { id: 123, nachname: 'Müller', vorname: 'Hans', ausweisNr: 'A12345' },
        // ...
    ],
    validUntil: '2026-12-31',
    count: 5
});
```

### 4. Kartendruck über Bridge
```javascript
// NEU: printCard Event
Bridge.sendEvent('printCard', {
    cardType: cardType,                 // 'Sicherheit', 'Service', etc.
    employees: [...],
    printer: 'CardPrinter1',
    validUntil: '2026-12-31',
    count: 5
});
```

### 5. Fallback-Logik beibehalten
- Preview-Fenster öffnet sich weiterhin wenn Bridge nicht verfügbar
- Toast-Benachrichtigungen bleiben erhalten
- Console-Logging für Debugging

---

## PHASE 4: ACCESS-VBA INTEGRATION (ERFORDERLICH)

### VBA-Module (noch zu erstellen)

**1. Event-Handler in frm_Ausweis_Create (Access)**
```vba
' Reagiert auf Browser-Events
Private Sub WebView_WebMessageReceived(args)
    Dim json As String
    json = args.WebMessageAsJson

    ' Parse JSON
    Dim data As Object
    Set data = JsonConverter.ParseJson(json)

    Select Case data("type")
        Case "loadData"
            If data("dataType") = "mitarbeiter" Then
                SendMitarbeiterDaten
            End If

        Case "createBadge"
            CreateBadgeReport data("employees"), data("badgeType"), data("validUntil")

        Case "printCard"
            PrintCardToPrinter data("employees"), data("cardType"), data("printer")
    End Select
End Sub

' Sendet Mitarbeiter-Daten an Browser
Private Sub SendMitarbeiterDaten()
    Dim rs As DAO.Recordset
    Dim json As String

    Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True")

    ' JSON generieren
    json = "{ ""mitarbeiter"": ["
    Do While Not rs.EOF
        json = json & "{"
        json = json & """ID"": " & rs!ID & ","
        json = json & """Nachname"": """ & rs!Nachname & ""","
        json = json & """Vorname"": """ & rs!Vorname & ""","
        json = json & """DienstausweisNr"": """ & Nz(rs!DienstausweisNr, "") & ""","
        json = json & """Ausweis_GueltBis"": """ & Nz(rs!Ausweis_GueltBis, "") & """"
        json = json & "},"
        rs.MoveNext
    Loop
    json = Left(json, Len(json) - 1) ' Letztes Komma entfernen
    json = json & "]}"

    rs.Close

    ' An Browser senden
    WebView.PostWebMessageAsJson json
End Sub

' Erstellt Ausweis-Bericht
Private Sub CreateBadgeReport(employees As Collection, badgeType As String, validUntil As String)
    ' Temporäre Tabelle mit ausgewählten MA füllen
    Dim db As DAO.Database
    Set db = CurrentDb

    db.Execute "DELETE FROM tbl_TEMP_AusweisListe"

    Dim emp As Variant
    For Each emp In employees
        db.Execute "INSERT INTO tbl_TEMP_AusweisListe (MA_ID, Nachname, Vorname, GueltBis, AusweisTyp) " & _
                   "VALUES (" & emp("id") & ", '" & emp("nachname") & "', '" & emp("vorname") & "', " & _
                   "#" & validUntil & "#, '" & badgeType & "')"
    Next

    ' Bericht öffnen
    DoCmd.OpenReport "rpt_Dienstausweis_" & badgeType, acViewPreview
End Sub

' Druckt Karten auf speziellem Drucker
Private Sub PrintCardToPrinter(employees As Collection, cardType As String, printer As String)
    ' Temporäre Tabelle füllen
    ' Drucker setzen
    ' Report drucken
    ' ...
End Sub
```

**2. Access-Reports (zu erstellen)**
- `rpt_Dienstausweis_Einsatzleitung`
- `rpt_Dienstausweis_Bereichsleiter`
- `rpt_Dienstausweis_Security`
- `rpt_Dienstausweis_Service`
- `rpt_Dienstausweis_Platzanweiser`
- `rpt_Dienstausweis_Staff`
- `rpt_Karte_Sicherheit`
- `rpt_Karte_Service`
- `rpt_Karte_Rueckseite`
- `rpt_Karte_Sonder`

**3. Temporäre Tabelle**
```sql
CREATE TABLE tbl_TEMP_AusweisListe (
    ID AUTOINCREMENT PRIMARY KEY,
    MA_ID LONG,
    Nachname TEXT(100),
    Vorname TEXT(100),
    AusweisNr TEXT(20),
    GueltBis DATETIME,
    AusweisTyp TEXT(50)
);
```

---

## ZUSAMMENFASSUNG

### ✅ Abgeschlossen
1. WebView2-Bridge eingebunden
2. Daten-Laden korrigiert (`'mitarbeiter'` statt `'badge'`)
3. `createBadge` Event implementiert
4. `printCard` Event implementiert
5. Fallback-Preview beibehalten

### 📋 Noch zu tun (Access-Backend)
1. VBA Event-Handler erstellen
2. JSON-Parser implementieren (JsonConverter)
3. Access-Reports für alle 10 Ausweis/Karten-Typen
4. Temporäre Tabelle `tbl_TEMP_AusweisListe` erstellen
5. Drucker-Integration für Kartendrucker

### 🔧 Event-Flow
```
[Browser] User wählt MA + klickt "Einsatzleitung"
    ↓
[JS] Bridge.sendEvent('createBadge', {...})
    ↓
[WebView2] PostMessage → Access VBA
    ↓
[VBA] WebView_WebMessageReceived()
    ↓
[VBA] CreateBadgeReport()
    ↓
[Access] tbl_TEMP_AusweisListe füllen
    ↓
[Access] DoCmd.OpenReport "rpt_Dienstausweis_Einsatzleitung"
    ↓
[User] Ausweis-Preview / Drucken
```

---

## TECHNISCHE DETAILS

**Dateien:**
- HTML: `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_Ausweis_Create.html`
- Logic: `logic\frm_Ausweis_Create.logic.js`
- Bridge: `../js/webview2-bridge.js`

**Dependencies:**
- webview2-bridge.js (v2.0)
- sidebar.js (gemeinsame Komponente)
- consys-common.css
- consys_theme.css
- app-layout.css

**State Management:**
```javascript
const state = {
    allEmployees: [],       // Alle MA aus tbl_MA_Mitarbeiterstamm
    selectedEmployees: [],  // Für Druck ausgewählte MA
    validUntil: null        // Gültigkeitsdatum
};
```

**Event-Handler:**
```javascript
Bridge.on('onDataReceived', handleDataReceived);

function handleDataReceived(data) {
    if (data.mitarbeiter) {
        state.allEmployees = data.mitarbeiter;
        renderAllEmployees();
    }
}
```

---

## WEBVIEW2-KONFORMITÄT: ✅ BESTÄTIGT

**Alle Kriterien erfüllt:**
- [x] webview2-bridge.js eingebunden
- [x] Kein direkter fetch() mehr
- [x] Alle Datenlade-Operationen via Bridge.loadData()
- [x] Alle Actions via Bridge.sendEvent()
- [x] Event-Handler registriert
- [x] Fallback-Logik vorhanden

**Nächster Schritt:** Access-VBA Implementation
