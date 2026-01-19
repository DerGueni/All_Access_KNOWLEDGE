# Button-Logik und Spezialfunktionen Report

**Erstellt:** 2026-01-06
**Projekt:** CONSEC HTML-Formulare
**Vergleich:** Access VBA vs. HTML/JavaScript

---

## 1. Uebersicht: Button-Inventar

### 1.1 frm_va_Auftragstamm - Hauptformular

| HTML-Button ID | Button-Text | onclick-Handler | Status |
|----------------|-------------|-----------------|--------|
| btnReq | Aktualisieren | refreshData() | IMPLEMENTIERT |
| btn_N_HTMLAnsicht | HTML | openHtmlAnsicht() | STUB |
| btnSchnellPlan | Mitarbeiterauswahl | openMitarbeiterauswahl() | IMPLEMENTIERT |
| btn_Posliste_oeffnen | Positionen | openPositionen() | IMPLEMENTIERT |
| btnmailpos | Zusatzdateien | openZusatzdateien() | IMPLEMENTIERT |
| Befehl640 | Auftrag kopieren | auftragKopieren() | IMPLEMENTIERT |
| mcobtnDelete | Auftrag loeschen | auftragLoeschen() | IMPLEMENTIERT |
| btnMailEins | Einsatzliste senden MA | sendeEinsatzlisteMA() | IMPLEMENTIERT (API-Call) |
| btn_Autosend_BOS | Einsatzliste senden BOS | sendeEinsatzlisteBOS() | IMPLEMENTIERT (API-Call) |
| btnMailSub | Einsatzliste senden SUB | sendeEinsatzlisteSUB() | IMPLEMENTIERT (API-Call) |
| btnXLEinsLst | Excel Export | exportEinsatzlisteExcel() | FEHLEND |
| btnneuveranst | Neuer Auftrag | neuerAuftrag() | IMPLEMENTIERT |
| btn_ListeStd | Namensliste ESS | namenslisteESS() | IMPLEMENTIERT (CSV-Export) |
| btnDruckZusage | Einsatzliste drucken | einsatzlisteDrucken() | IMPLEMENTIERT (Browser-Print) |
| btnStdBerech | Stunden berechnen | berechneStunden() | FEHLEND |
| btnAuftrBerech | Auftrag berechnen | auftragBerechnen() | FEHLEND |
| Befehl709 | EL gesendet | showELGesendet() | IMPLEMENTIERT |
| btn_BWN_Druck | BWN drucken | bwnDrucken() | IMPLEMENTIERT (Fallback) |
| cmd_BWN_send | BWN senden | bwnSenden() | IMPLEMENTIERT (API-Call) |
| cmd_Messezettel_NameEintragen | Messezettel | messezettelNameEintragen() | IMPLEMENTIERT (API-Call) |
| btnNeuAttach | Neuen Attach hinzufuegen | neuenAttachHinzufuegen() | IMPLEMENTIERT |
| btn_Rueckmeld | Rueckmelde-Statistik | openRueckmeldStatistik() | IMPLEMENTIERT |
| btnSyncErr | Syncfehler | openSyncfehler() | IMPLEMENTIERT |

### 1.2 Navigation Buttons

| HTML-Button ID | Funktion | Status |
|----------------|----------|--------|
| Befehl43 | Erster Datensatz | IMPLEMENTIERT |
| Befehl41 | Vorheriger Datensatz | IMPLEMENTIERT |
| Befehl40 | Naechster Datensatz | IMPLEMENTIERT |
| btn_letzer_Datensatz | Letzter Datensatz | IMPLEMENTIERT |
| btn_rueck | Aenderungen rueckgaengig | IMPLEMENTIERT |
| Befehl38 | Formular schliessen | IMPLEMENTIERT |
| btnDatumLeft | Datum zurueck | IMPLEMENTIERT |
| btnDatumRight | Datum vor | IMPLEMENTIERT |

### 1.3 Filter Buttons

| HTML-Button ID | Funktion | Status |
|----------------|----------|--------|
| btn_AbWann | Filter anwenden | IMPLEMENTIERT |
| btnTgBack | 7 Tage zurueck | IMPLEMENTIERT |
| btnTgVor | 7 Tage vor | IMPLEMENTIERT |
| btnHeute | Ab Heute | IMPLEMENTIERT |

### 1.4 frm_MA_VA_Schnellauswahl - Mitarbeiterauswahl

| HTML-Button ID | Access-Name | Funktion | Status |
|----------------|-------------|----------|--------|
| btnAddSelected | btnAddSelected | Mitarbeiter zuordnen | IMPLEMENTIERT |
| btnDelSelected | btnDelSelected | Zuordnung entfernen | IMPLEMENTIERT |
| btnSchnellGo | btnSchnellGo | GO (Aktualisieren) | IMPLEMENTIERT |
| btnMailSelected | btnMailSelected | Nur Selektierte anfragen | IMPLEMENTIERT |
| btnMail | btnMail | Alle Mitarbeiter anfragen | IMPLEMENTIERT |
| btnAuftrag | btnAuftrag | Zurueck zum Auftrag | IMPLEMENTIERT |
| btnClose | Befehl38 | Formular schliessen | IMPLEMENTIERT |
| cmdListMA_Standard | cmdListMA_Standard | Standard-Ansicht | FEHLEND |
| cmdListMA_Entfernung | cmdListMA_Entfernung | Entfernungs-Sortierung | FEHLEND |

---

## 2. Funktionsvergleich: Access VBA vs. HTML/JavaScript

### 2.1 Schnellauswahl - Entfernungsberechnung

#### Access VBA (mdl_frm_MA_VA_Schnellauswahl_Code.bas)
```vba
Public Function cmdListMA_Entfernung_Click() As Variant
    ' 1. Objekt_ID aus Auftrag holen
    lngObjektID = Nz(DLookup("Objekt_ID", "tbl_VA_Auftragstamm", "ID=" & lngVA_ID), 0)

    ' 2. Temporaere Query mit Entfernungen erstellen
    db.CreateQueryDef "ztmp_Entf_Filter",
        "SELECT MA_ID, Entf_KM FROM tbl_MA_Objekt_Entfernung WHERE Objekt_ID = " & lngObjektID

    ' 3. MA-Liste mit Entfernung sortieren
    strSQL = "SELECT S.ID, S.IstSubunternehmer, S.Name, " & _
             "Format(IIf(E.Entf_KM Is Null,999,E.Entf_KM),'0.0') & ' km' AS Std, " & _
             "... ORDER BY IIf(E.Entf_KM Is Null,999,E.Entf_KM), S.Name"
```

**Datenquelle:** `tbl_MA_Objekt_Entfernung` mit vorberechneten Distanzen

#### Entfernungsberechnung (mdl_GeoDistanz.bas)
```vba
' Haversine-Formel fuer Entfernung
' Lat/Lon aus tbl_MA_Geo und tbl_OB_Geo
' Geocoding via Nominatim (OpenStreetMap)
Private Const PI As Double = 3.14159265358979
Private Const EARTH_RADIUS_KM As Double = 6371
```

#### HTML/JavaScript Status: NICHT IMPLEMENTIERT

**Fehlende Komponenten:**
1. API-Endpoint `/api/entfernungen` fuer MA-Objekt-Distanzen
2. Button-Handler `cmdListMA_Entfernung()` in frm_MA_VA_Schnellauswahl.logic.js
3. Geo-Koordinaten Abruf (MA + Objekt)
4. Sortierung nach Entfernung

**Prioritaet:** HOCH (Wichtige Planungsfunktion)

---

### 2.2 E-Mail Auftragsanfragen

#### Access VBA
- Outlook Automation via COM-Object
- HTML-formatierte E-Mails
- Empfaenger aus tbl_MA_Mitarbeiterstamm.Email
- Anhaenge aus Dateisystem

#### HTML/JavaScript (frm_MA_VA_Schnellauswahl.logic.js)
```javascript
async function versendeAnfragen(alle) {
    // mailto-Link als Fallback
    const subject = encodeURIComponent(`Anfrage Auftrag ${state.selectedAuftrag}`);
    const body = encodeURIComponent(`Anfrage für Auftrag ${state.selectedAuftrag}`);
    window.open(`mailto:siegert@consec-nuernberg.de?subject=${subject}&body=${body}`);
}
```

**Status:** TEILWEISE IMPLEMENTIERT
- mailto-Link funktioniert
- Keine Outlook-Automation
- Keine automatischen Anhaenge
- Keine HTML-Formatierung

**Prioritaet:** MITTEL

---

### 2.3 ESS-Namenslisten (btn_ListeStd)

#### Access VBA
- Excel-Export via COM-Automation
- Formatierte Spalten
- Logo/Header im Dokument
- Druckbereich definiert

#### HTML/JavaScript (frm_va_Auftragstamm.logic.js)
```javascript
async function druckeNamenlisteESS() {
    // CSV fuer Excel erstellen
    let csv = '\uFEFF'; // BOM fuer UTF-8 in Excel
    csv += `ESS Namensliste: ${auftrag.Auftrag}\n`;

    // Header
    csv += 'Nachname;Vorname;Kurzname;Geburtsdatum;Geburtsort;Nationalitaet;';
    csv += 'Ausweis-Nr;Ausweis gueltig bis;IHK 34a Nr;IHK gueltig bis;Telefon;E-Mail\n';

    // Download
    downloadCSV(csv, `ESS_Namensliste_${state.currentVA_ID}.csv`);
}
```

**Status:** IMPLEMENTIERT (CSV-Export)
- Funktioniert, aber ohne Excel-Formatierung
- Fehlende Felder: Kurzname existiert nicht in DB
- Kein Logo/Header

**Prioritaet:** NIEDRIG (Funktional)

---

### 2.4 Messezettel (cmd_Messezettel_NameEintragen)

#### Access VBA (mod_N_Messezettel.bas)
```vba
Public Function FuelleMessezettel(auftragsID As Long) As Boolean
    ' 1. Stand/Datum Kombinationen ermitteln aus Bemerkungen
    ' 2. PDF-Dateien im Netzwerk finden
    ' 3. Python-Script aufrufen zum Stempeln
    strCommand = "python """ & PYTHON_SCRIPT & """ """ & _
                 strPDFPfad & """ """ & strPDFPfad & """ """ & _
                 Replace(colTemp(1), """", """""") & """ 1"
```

**Komponenten:**
- PDF-Ordner: `\\vConSYS01-NBG\Consys\CONSEC PLANUNG AKTUELL\D - Messezettel`
- Python-Script: `pdf_stempel.py`
- Standnummer-Extraktion aus Bemerkungen

#### HTML/JavaScript Status
```javascript
async function cmdMessezettelNameEintragen() {
    const result = await Bridge.execute('messezettelNameEintragen', {
        va_id: state.currentVA_ID,
        vadatum: state.currentVADatum
    });
}
```

**Status:** API-CALL IMPLEMENTIERT
- Bridge-Call vorhanden
- API-Endpoint muss implementiert werden
- PDF-Verarbeitung nur serverseitig moeglich

**Prioritaet:** HOCH (Messe-spezifisch)

---

### 2.5 BWN senden (cmd_BWN_send)

#### Access VBA (mod_N_Messezettel.bas)
```vba
Public Sub SendeBewachungsnachweise(frm As Form)
    ' Outlook-Automation
    Set outlookApp = CreateObject("Outlook.Application")
    Set outlookMail = outlookApp.CreateItem(0)

    With outlookMail
        .TO = Trim$(empfaenger)
        .Subject = "Bewachungsnachweise Messe - " & mitarbeiterName
        .HTMLBody = ErzeugeMailTextHTML()

        For Each pdfDatei In colPDFs
            .Attachments.Add CStr(pdfDatei)
        Next

        .send
    End With
```

#### HTML/JavaScript Status
```javascript
async function cmdBWNSend() {
    const result = await Bridge.execute('sendBWN', {
        va_id: state.currentVA_ID,
        vadatum: state.currentVADatum
    });
}
```

**Status:** API-CALL IMPLEMENTIERT
- Bridge-Call vorhanden
- E-Mail-Versand nur serverseitig via Python/API

**Prioritaet:** HOCH

---

### 2.6 Excel Export Einsatzliste (btnXLEinsLst)

#### Access VBA
- Direkter Excel-Export via COM
- Formatierung (Spaltenbreiten, Farben)
- Mehrere Sheets moeglich

#### HTML/JavaScript Status: NICHT IMPLEMENTIERT

**Fehlende Funktion:** `exportEinsatzlisteExcel()`

**Prioritaet:** MITTEL

---

### 2.7 Stunden berechnen (btnStdBerech)

#### Access VBA
- Summiert Stunden aller Schichten
- Beruecksichtigt Pausen
- Speichert in Auftrag

#### HTML/JavaScript Status: NICHT IMPLEMENTIERT

**Prioritaet:** MITTEL

---

## 3. Zusammenfassung: Implementierungsstatus

### Vollstaendig implementiert (16 Buttons)
- Navigation (6)
- Filter (4)
- Basis-Aktionen: Aktualisieren, Kopieren, Loeschen, Neu (4)
- ESS-Namensliste (CSV-Export) (1)
- Zurueck zum Auftrag (1)

### Teilweise implementiert (8 Buttons)
- E-Mail senden MA/BOS/SUB - nur API-Call, kein echter Versand
- BWN drucken - Browser-Fallback, kein nativer Druck
- BWN senden - nur API-Call
- Messezettel - nur API-Call
- Mitarbeiter anfragen - nur mailto-Link

### Nicht implementiert (1 Button)
| Button | Prioritaet | Aufwand |
|--------|------------|---------|
| openHtmlAnsicht | NIEDRIG | Gering |

### Neu implementiert (5 Buttons) - Stand 2026-01-06
| Button | Status | Beschreibung |
|--------|--------|--------------|
| cmdListMA_Entfernung | IMPLEMENTIERT | Entfernungssortierung mit Haversine-Fallback |
| cmdListMA_Standard | IMPLEMENTIERT | Standard-Ansicht wiederherstellen |
| btnXLEinsLst | VORHANDEN | Excel-Export via Bridge/WebView2 |
| btnStdBerech | VORHANDEN | Stundenberechnung aus Zuordnungen |
| btnAuftrBerech | VORHANDEN | Auftrag berechnen via Bridge |

---

## 4. Priorisierte Implementierungsempfehlung

### Phase 1: Kritische Funktionen (HOCH)

1. **Entfernungsberechnung fuer Schnellauswahl**
   - API-Endpoint: `GET /api/entfernungen?objekt_id=X`
   - JS-Handler: `cmdListMA_Entfernung()`
   - Sortierung nach Distanz

2. **Messezettel API-Backend**
   - Python-Endpoint fuer PDF-Stempel
   - Erfordert Zugriff auf Netzwerk-PDFs

3. **BWN Versand API-Backend**
   - SMTP-basierter E-Mail-Versand
   - PDF-Anhaenge aus Dateisystem

### Phase 2: Wichtige Funktionen (MITTEL)

4. **Excel Export Einsatzliste**
   - SheetJS/xlsx.js Bibliothek
   - Formatierte Spalten

5. **Stunden berechnen**
   - Client-seitig aus Schichten-Daten
   - Summe anzeigen

6. **Standard-Ansicht Schnellauswahl**
   - Einfacher Button-Handler

### Phase 3: Nice-to-have (NIEDRIG)

7. **HTML-Ansicht Button**
8. **Auftrag berechnen**

---

## 5. Technische Hinweise

### API-Server Erweiterungen benoetigt

```python
# api_server.py - Fehlende Endpoints

@app.route('/api/entfernungen', methods=['GET'])
def get_entfernungen():
    objekt_id = request.args.get('objekt_id')
    # SELECT MA_ID, Entf_KM FROM tbl_MA_Objekt_Entfernung WHERE Objekt_ID = ?

@app.route('/api/namensliste-ess/<int:va_id>', methods=['GET'])
def get_namensliste_ess(va_id):
    # Alle MA mit persoenlichen Daten fuer Auftrag

@app.route('/api/messezettel', methods=['POST'])
def process_messezettel():
    # PDF-Stempel via Python subprocess

@app.route('/api/bwn/send', methods=['POST'])
def send_bwn():
    # E-Mail mit SMTP, PDF-Anhaenge
```

### JavaScript-Implementierungen - ERLEDIGT

Die Entfernungsberechnung wurde in `frm_MA_VA_Schnellauswahl.logic.js` implementiert:

**Neue Funktionen (2026-01-06):**
- `cmdListMA_Standard()` - Standard-Ansicht aktivieren
- `cmdListMA_Entfernung()` - Entfernungssortierung mit API-Call
- `calculateEntfernungenClientside()` - Haversine-Fallback
- `haversineDistanz()` - Haversine-Formel fuer Distanzberechnung
- `renderMitarbeiterListeMitEntfernung()` - Render mit Farbcodierung

**State-Erweiterungen:**
- `state.entfernungen` - Map mit MA_ID -> Entf_KM
- `state.currentObjektId` - Aktuelles Objekt fuer Entfernung
- `state.sortMode` - 'standard' oder 'entfernung'

**Farbcodierung:**
- Gruen: <= 15 km
- Gelb: <= 30 km
- Rot: > 30 km
- Grau/Kursiv: Unbekannt

---

## 6. Fazit

Die HTML-Formulare haben eine solide Basis-Implementierung der Button-Funktionen.

### Erledigte Aufgaben (2026-01-06)

1. **Entfernungsberechnung** - IMPLEMENTIERT
   - Vollstaendige Haversine-Formel in JavaScript
   - Farbcodierte Anzeige (gruen/gelb/rot)
   - Fallback fuer fehlende API-Daten
   - Entspricht 1:1 der Access VBA-Logik

2. **Standard/Entfernung Toggle** - IMPLEMENTIERT
   - cmdListMA_Standard() und cmdListMA_Entfernung()
   - Button-Highlight fuer aktiven Modus

### Verbleibende serverseitige Aufgaben

Die folgenden Funktionen erfordern API-Erweiterungen:

1. **Messezettel-Verarbeitung** - PDF-Zugriff nur serverseitig
2. **BWN Versand** - SMTP E-Mail-Versand
3. **Excel-Export nativer Modus** - COM-Automation

### Empfehlung fuer naechste Schritte

1. API-Endpoint `/api/entfernungen` implementieren (nutzt vorhandene tbl_MA_Objekt_Entfernung)
2. Geo-Daten fuer MA und Objekte pflegen (tbl_MA_Geo, tbl_OB_Geo)
3. Python-basierter E-Mail-Service fuer Outlook-unabhaengigen Versand
