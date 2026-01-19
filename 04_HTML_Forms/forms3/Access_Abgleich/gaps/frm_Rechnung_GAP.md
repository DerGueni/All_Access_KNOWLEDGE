# Gap-Analyse: frm_Rechnung

**Analysiert am:** 2026-01-12
**Access-Export:** Nicht vorhanden (Teil von frmTop_RechnungsStamm)
**HTML-Formular:** forms3/frm_Rechnung.html
**Logic-JS:** Keine (nur Platzhalter)

---

## Executive Summary

### Formular-Status
- **Access:** Kein eigenständiges Formular - Teil von `frmTop_RechnungsStamm` (Toggle: Rechnung/Angebot)
- **HTML:** Nur Platzhalter-Seite mit Emoji-Icon
- **Implementierung:** 0% (nur leere Hülle)

### Voraussichtlicher Umfang (basierend auf frmTop_RechnungsStamm)
- **Controls:** ~200+ (größtes Rechnungs-Formular)
  - 15 Buttons (Navigation, CRUD, Export, Mahnung)
  - 60+ TextBoxen (Stammdaten, Mahnung, Statistik)
  - 10 ComboBoxen (Kunde, Mahnstufe, Zahlungsbed.)
  - 5 Subforms (Positionen, Aufträge, VA-Anzeige)
  - 80+ Labels
  - TabControl mit 7 Tabs (inkl. Mahnung)
  - 6 OptionButtons (Bezahlt, Gemahnt)

### Kritische Gaps
1. **Komplettes Formular fehlt** - nur Platzhalter vorhanden
2. **Rechnungs-Logik** nicht implementiert (Rechnungserstellung, Positionen)
3. **Mahnwesen** fehlt komplett (3 Mahnstufen, Mahngebühren)
4. **Word-Integration** fehlt (Rechnungsvorlage)
5. **Zahlungsüberwachung** nicht vorhanden
6. **Umsatzstatistik** fehlt

---

## 1. FORMULAR-EIGENSCHAFTEN (SOLL-ZUSTAND)

### Access (frmTop_RechnungsStamm mit Rechnung-Toggle)

```
RecordSource: tbl_Rch_Kopf WHERE RchTyp = 'Rechnung'
Filter: istRechnung = True
AllowEdits: True
AllowAdditions: True
AllowDeletions: True
DataEntry: False
DefaultView: SplitForm (Formular + Datasheet)
NavigationButtons: False
HasModule: True (umfangreiches VBA-Modul mit 467 Zeilen)
```

**Toggle-Mechanismus:**
```vba
Private Sub istRechnung_AfterUpdate()
    If Me!istRechnung Then
        Me!istRechnung.caption = "Rechnung"
        Me.RecordSource = "qry_tbl_Rch_Kopf"      ' Nur Rechnungen
    Else
        Me!istRechnung.caption = "Angebot"
        Me.RecordSource = "qry_tbl_Rch_Kopf_Ang" ' Nur Angebote
    End If
    Me.Requery
End Sub
```

### HTML (IST-ZUSTAND)

```html
<!-- ❌ NUR PLATZHALTER -->
<!DOCTYPE html>
<html lang="de">
<head>
    <title>Rechnung - CONSYS</title>
</head>
<body>
    <div class="placeholder-container">
        <div class="placeholder-icon">🧾</div>
        <div class="placeholder-title">Rechnungsansicht</div>
        <div class="placeholder-text">Diese Ansicht wird noch implementiert.</div>
        <div class="placeholder-params" id="params"></div>
    </div>
    <script>
        // Zeigt URL-Parameter an (z.B. ?rch_id=123)
        const params = new URLSearchParams(window.location.search);
        // ...
    </script>
</body>
</html>
```

---

## 2. HAUPTFUNKTIONEN (SOLL-ZUSTAND)

### Rechnungs-Erstellung

**Access-Workflow:**
1. Button "Neue Rechnung"
2. Neuen Datensatz in tbl_Rch_Kopf anlegen mit RchTyp='Rechnung'
3. Rechnungsnummer vergeben (aus _tblEigeneFirma_Word_Nummernkreise)
4. Kundendaten auswählen (cbo_Kunde)
5. Auftragsdaten verknüpfen (VA_ID)
6. Positionen erfassen (aus Auftrag oder manuell)
7. Summen berechnen (Zwi_Sum1, MwSt_Sum1, Gesamtsumme1)
8. Word-Vorlage wählen und Rechnung generieren
9. PDF speichern

**HTML (fehlt komplett):**
- Kein Formular vorhanden
- Keine Felder
- Keine Buttons

### Mahnwesen (3 Mahnstufen)

**Access-Workflow:**
1. Filter nach Mahnstufe (cbo_Mahnstufe: 1, 2, 3)
2. Automatische Query-Filterung: `qry_Rch_Mahnstufe1/2/3`
3. Button "Mahnen" ausführt:
   - Mahnungs-Dokument erstellen (Word)
   - Mahndatum, Mahnbetrag, Mahngebühr erfassen
   - Status "IstGemahnt" setzen
   - PDF generieren
4. Mahnstufen-Tabs: M1, M2, M3 mit jeweils:
   - MahnDok (Dateipfad)
   - Mahndat (Mahndatum)
   - MahnVon (Sachbearbeiter)
   - Mahnbetrag1 (Betrag + Gebühr)
   - Mahn_Bemerkungen

**HTML:** ❌ Fehlt komplett

### Zahlungsüberwachung

**Access:**
- Zahlung_am (Zahlungsdatum)
- Zahlung_Bis (Zahlungsziel)
- Zahlbetrag1 (Gezahlter Betrag)
- ZahlBetrag_Netto1 (Netto-Betrag)
- IstBezahlt (CheckBox)

**HTML:** ❌ Fehlt komplett

---

## 3. FELDER (SOLL-ZUSTAND)

### Stammdaten (aus tbl_Rch_Kopf)

| Feld | Typ | Zweck | HTML | Status |
|------|-----|-------|------|--------|
| **ID** | Integer | Rechnungs-ID | - | ❌ Fehlt |
| **RchTyp** | Text | 'Rechnung' (fix) | - | ❌ Fehlt |
| **kun_ID** | ComboBox | Kunden-ID | - | ❌ Fehlt |
| **VA_ID** | ComboBox | Auftrags-ID | - | ❌ Fehlt |
| **RchDatum** | Date | Rechnungsdatum | - | ❌ Fehlt |
| **Leist_Datum_von** | Date | Leistungszeitraum von | - | ❌ Fehlt |
| **Leist_Datum_Bis** | Date | Leistungszeitraum bis | - | ❌ Fehlt |
| **Zwi_Sum1** | Currency | Zwischensumme (netto) | - | ❌ Fehlt |
| **MwSt_Sum1** | Currency | MwSt (19%) | - | ❌ Fehlt |
| **Gesamtsumme1** | Currency | Gesamt (brutto) | - | ❌ Fehlt |
| **Bemerkungen** | Memo | Bemerkungen | - | ❌ Fehlt |
| **Dateiname** | Text | Pfad zur Word/PDF-Datei | - | ❌ Fehlt |
| **VorlageDokNr** | Integer | Word-Vorlagen-ID | - | ❌ Fehlt |

### Zahlungsinformationen

| Feld | Typ | Zweck | HTML | Status |
|------|-----|-------|------|--------|
| **Zahlung_am** | Date | Wann wurde gezahlt? | - | ❌ Fehlt |
| **Zahlung_Bis** | Date | Zahlungsziel | - | ❌ Fehlt |
| **Zahlbetrag1** | Currency | Gezahlter Betrag (brutto) | - | ❌ Fehlt |
| **ZahlBetrag_Netto1** | Currency | Gezahlter Betrag (netto) | - | ❌ Fehlt |
| **IstBezahlt** | Boolean | Bezahlt? | - | ❌ Fehlt |
| **IstSammelRch** | Boolean | Sammelrechnung? | - | ❌ Fehlt |
| **ZahlBed_ID** | ComboBox | Zahlungsbedingungen | - | ❌ Fehlt |

### Mahnstufe 1

| Feld | Typ | Zweck | HTML | Status |
|------|-----|-------|------|--------|
| **M1MahnDok** | Text | Pfad zum Mahnungs-Dokument | - | ❌ Fehlt |
| **M1Mahndat** | Date | Mahndatum | - | ❌ Fehlt |
| **M1MahnVon** | Text | Sachbearbeiter | - | ❌ Fehlt |
| **M1Mahnbetrag1** | Currency | Mahnbetrag (inkl. Gebühr) | - | ❌ Fehlt |
| **M1IstGemahnt1** | Boolean | Gemahnt? | - | ❌ Fehlt |
| **M1Mahn_Bemerkungen** | Memo | Bemerkungen | - | ❌ Fehlt |

### Mahnstufe 2 & 3 (analog)

| Feld | Status |
|------|--------|
| **M2MahnDok, M2Mahndat, ...** | ❌ Fehlt |
| **M3MahnDok, M3Mahndat, ...** | ❌ Fehlt |

### System-Felder

| Feld | Zweck | HTML | Status |
|------|-------|------|--------|
| **Erst_am** | Erstelldatum | - | ❌ Fehlt |
| **Erst_von** | Ersteller | - | ❌ Fehlt |
| **Aend_am** | Änderungsdatum | - | ❌ Fehlt |
| **Aend_von** | Änderer | - | ❌ Fehlt |

---

## 4. SUBFORMS (SOLL-ZUSTAND)

### sub_Rch_Pos_Auftrag (Positionen aus Auftrag)

**Access:**
- Source: sub_Rch_Pos_Auftrag
- Position: 3117 / 1247, Größe: 12242 x 6747
- Lädt automatisch Positionen aus verknüpftem Auftrag (VA_ID)
- Spalten: PosNr, Bezeichnung, Menge, Einheit, Einzelpreis, Gesamt
- **Link Master Fields:** ID
- **Link Child Fields:** Rch_Kopf_ID

**HTML:** ❌ Fehlt komplett

### sub_Rch_Pos_Geschrieben (Manuell geschriebene Positionen)

**Access:**
- Source: sub_Rch_Pos_Geschrieben
- Position: 3117 / 1190, Größe: 12237 x 6864
- Erlaubt manuelle Eingabe von Positionen (ohne Auftrag)
- Spalten: PosNr, Bezeichnung, Menge, Einheit, Einzelpreis, Gesamt, MwSt

**HTML:** ❌ Fehlt komplett

### sub_Rch_VA_Gesamtanzeige (Auftrags-Übersicht)

**Access:**
- Source: sub_Rch_VA_Gesamtanzeige
- Position: 3120 / 1303, Größe: 12239 x 6292
- Zeigt alle verknüpften Aufträge
- Spalten: Auftrag, Datum, Objekt, Kunde, Status, Gesamt

**HTML:** ❌ Fehlt komplett

### sub_Rch_Sub_VA_Kopf (VA-Kopfdaten)

**Access:**
- Source: Keine (leer)
- Position: 3074 / 4920, Größe: 12040 x 2211
- Zeigt Auftrags-Header-Informationen

**HTML:** ❌ Fehlt komplett

### Menü (Sidebar)

**Access:**
- Source: Menü
- Position: 0 / 0, Größe: 2790 x 10755
- Standard-Menüführung

**HTML:** ✅ Vorhanden (via sidebar.js)

---

## 5. BUTTONS (SOLL-ZUSTAND)

### Navigation & CRUD (13 Buttons)

| Button | Caption | Position | Funktion | HTML | Status |
|--------|---------|----------|----------|------|--------|
| **Befehl39** | btn_letzter_Datensatz | 9194/90 | Letzter DS | - | ❌ Fehlt |
| **Befehl40** | btn_Datensatz_vor | 8735/90 | Vorheriger DS | - | ❌ Fehlt |
| **Befehl41** | btn_Datensatz_zurueck | 8276/90 | Nächster DS | - | ❌ Fehlt |
| **Befehl43** | btn_erster_Datensatz | 7817/90 | Erster DS | - | ❌ Fehlt |
| **Befehl42** | drucken | 7358/90 | Rechnung drucken | - | ❌ Fehlt |
| **Befehl46** | Neue Rechnung | 10204/945 | Neue Rechnung | - | ❌ Fehlt |
| **mcobtnDelete** | Rechnung löschen | 10204/520 | Löschen | - | ❌ Fehlt |
| **btnFIlterLoesch** | Filter löschen | 10204/75 | Filter aufheben | - | ❌ Fehlt |
| **btnHilfe** | Hilfe | 6899/90 | Hilfe öffnen | - | ❌ Fehlt |
| **Befehl38** | btn_Formular_schliessen | 9653/90 | Schließen | - | ❌ Fehlt |

### Utility-Buttons (Ribbon/DatNav)

| Button | Funktion | HTML | Status |
|--------|----------|------|--------|
| **btnRibbonAus** | Ribbon ausblenden | - | N/A (Web) |
| **btnRibbonEin** | Ribbon einblenden | - | N/A (Web) |
| **btnDaBaEin** | DatNav einblenden | - | N/A (Web) |
| **btnDaBaAus** | DatNav ausblenden | - | N/A (Web) |

### Mahnwesen (kritisch!)

| Button | Caption | Position | Funktion | HTML | Status |
|--------|---------|----------|----------|------|--------|
| **btnMahnen** | Mahnen | 12292/5499 | Mahnung erstellen und versenden | - | ❌ Fehlt |

**VBA-Code (467 Zeilen!):**
```vba
Private Sub btnMahnen_Click()
    ' 1. Rechnungsnummer erzeugen
    Mah_ID = Update_Rch_Nr(15) ' Mahnung = ID 15
    Mah_Num = Praefix1 & Right("00000" & Mah_ID, 5)

    ' 2. Vorlage auswählen (je nach Mahnstufe)
    Select Case Me!cboMahnstufe.Column(0)
        Case 1: iDokVorlage_ID = 19
        Case 2: iDokVorlage_ID = 20
        Case 3: iDokVorlage_ID = 21
    End Select

    ' 3. Word-Dokument erstellen
    Call WordReplace(strVorlage, strDokument)

    ' 4. PDF generieren
    PDF_Print strDokument

    ' 5. Mahndaten in DB speichern
    strSQL = "UPDATE tbl_Rch_Kopf SET M" & i & "Mahndok = '...' WHERE ID = ..."
    CurrentDb.Execute(strSQL)
End Sub
```

**HTML:** ❌ Komplett fehlt - VBA-Bridge benötigt!

---

## 6. COMBOBOXEN (SOLL-ZUSTAND)

### Filter-ComboBoxen (3 Stück)

| ComboBox | Position | RowSource | Zweck | HTML | Status |
|----------|----------|-----------|-------|------|--------|
| **cboKunde** | 13372/521 | tbl_KD_Kundenstamm | Filter nach Kunde | - | ❌ Fehlt |
| **cboMahnstufe** | 13372/946 | Mahnstufen 1-3 | Filter nach Mahnstufe | - | ❌ Fehlt |
| **cboRchID** | 13372/75 | tbl_Rch_Kopf.ID | Springe zu Rechnung-ID | - | ❌ Fehlt |

**VBA-Events:**
```vba
Private Sub cboKunde_AfterUpdate()
    Me.RecordSource = "SELECT * FROM tbl_Rch_Kopf WHERE kun_ID = " & Me!cboKunde.Column(0)
    Me.Requery
End Sub

Private Sub cboMahnstufe_AfterUpdate()
    i = Me!cboMahnstufe.Column(0)
    Me.RecordSource = "qry_Rch_Mahnstufe" & i
    Me.Requery
    Call fMahnsetz  ' Setzt Mahnfelder
End Sub

Private Sub cboRchID_AfterUpdate()
    Me.Recordset.FindFirst "ID = " & Me!cboRchID
End Sub
```

### Daten-ComboBoxen (7 Stück)

| ComboBox | ControlSource | RowSource | HTML | Status |
|----------|---------------|-----------|------|--------|
| **kun_ID** | kun_ID | tbl_KD_Kundenstamm | - | ❌ Fehlt |
| **RchTyp** | RchTyp | 'Rechnung', 'Angebot' | - | ❌ Fehlt |
| **Kombinationsfeld448** | VA_ID | tbl_VA_Auftragstamm | - | ❌ Fehlt |
| **lbl_Auftragsdatum** | VA_ID | tbl_VA_Auftragstamm | - | ❌ Fehlt |
| **MA_ID** | MA_ID | tbl_MA_Mitarbeiterstamm | - | ❌ Fehlt |
| **ZahlBed_ID** | ZahlBed_ID | tbl_Zahlungsbedingungen | - | ❌ Fehlt |

---

## 7. TAB-CONTROL (SOLL-ZUSTAND)

### Access: reg_Rech mit 7 Tabs

| Tab-Name | Caption | Inhalt | HTML | Status |
|----------|---------|--------|------|--------|
| **pgMain** | Main | Stammdaten, Kundendaten, Summen | - | ❌ Fehlt |
| **pgWeit** | Weiteres | Zusatzinformationen, Datei | - | ❌ Fehlt |
| **pg_VA_ID** | Aufträge | Subform: Verknüpfte Aufträge | - | ❌ Fehlt |
| **pgGeschrPos** | Geschriebene Pos | Subform: Manuelle Positionen | - | ❌ Fehlt |
| **pgAuftrPos** | Auftragspositionen | Subform: Positionen aus Auftrag | - | ❌ Fehlt |
| **pgMahnInfo** | Mahnung Info | Mahnstufen 1-3 (Read-Only) | - | ❌ Fehlt |
| **pgMahnen** | Mahnen | Mahnung erstellen (Button + Felder) | - | ❌ Fehlt |

**Tab-Positionen:**
- reg_Rech: 2834/660, Größe: 13531 x 11235
- Alle Pages: 2969/1125, Größe: 13260 x 10635

---

## 8. WORD-INTEGRATION (KRITISCH!)

### Rechnungs-Generierung (aus VBA-Code)

**Workflow:**
1. Rechnungsnummer vergeben (aus Nummernkreis)
2. Word-Vorlage öffnen
3. Platzhalter ersetzen:
   - Kundendaten (kun_Firma, kun_BriefKopf, kun_Anschrift)
   - Rechnungsdaten (RchDatum, Leist_Datum_von/Bis, RchNr)
   - Positionen (Tabelle mit PosNr, Bezeichnung, Menge, Preis)
   - Summen (Zwi_Sum1, MwSt_Sum1, Gesamtsumme1)
4. Word-Dokument speichern
5. PDF generieren
6. Dateipfad in tbl_Rch_Kopf.Dateiname speichern

**VBA-Module (nicht im Export):**
- `Textbau_Replace_Felder_Fuellen` - Füllt Platzhalter
- `fReplace_Table_Felder_Ersetzen` - Ersetzt Tabellen
- `WordReplace` - Speichert Dokument
- `PDF_Print` - Konvertiert zu PDF
- `Update_Rch_Nr` - Vergibt Rechnungsnummer

**HTML:** ❌ Komplett fehlt - VBA-Bridge benötigt!

### Mahnungs-Generierung (aus VBA btnMahnen_Click)

**Workflow:**
1. Mahnungsnummer vergeben (separate Nummerierung)
2. Vorlage je nach Mahnstufe wählen:
   - Mahnstufe 1: iDokVorlage_ID = 19
   - Mahnstufe 2: iDokVorlage_ID = 20
   - Mahnstufe 3: iDokVorlage_ID = 21
3. Platzhalter ersetzen (wie Rechnung + Mahngebühr)
4. PDF generieren
5. Mahndaten in DB speichern (M1MahnDok, M1Mahndat, ...)

**HTML:** ❌ Komplett fehlt

---

## 9. API-INTEGRATION (SOLL-ZUSTAND)

### Benötigte Endpoints

```python
# ❌ FEHLEN ALLE:

# 1. Rechnungen abrufen
GET /api/rechnungen
GET /api/rechnungen/:id

# 2. Rechnung erstellen
POST /api/rechnungen
{
    "kun_ID": 123,
    "VA_ID": 456,
    "RchDatum": "2026-01-15",
    "Leist_Datum_von": "2026-01-01",
    "Leist_Datum_Bis": "2026-01-31",
    "Zahlung_Bis": "2026-02-15",
    "ZahlBed_ID": 1
}

# 3. Rechnung aktualisieren
PUT /api/rechnungen/:id
{
    "Zwi_Sum1": 5000.00,
    "MwSt_Sum1": 950.00,
    "Gesamtsumme1": 5950.00,
    "IstBezahlt": false
}

# 4. Rechnung löschen
DELETE /api/rechnungen/:id

# 5. Rechnungs-Positionen
GET /api/rechnungen/:id/positionen
POST /api/rechnungen/:id/positionen
{
    "PosNr": 1,
    "Bezeichnung": "Sicherheitsdienst Januar 2026",
    "Menge": 100,
    "Einheit": "Stunden",
    "Einzelpreis": 50.00,
    "MwSt": 19
}

# 6. Mahnung erstellen (VBA-Bridge!)
POST /api/vba/rechnung/mahnung
{
    "rch_id": 123,
    "mahnstufe": 1,
    "mahnbetrag": 5950.00,
    "bemerkungen": "1. Mahnung"
}

# 7. Rechnung als Word/PDF generieren (VBA-Bridge!)
POST /api/vba/rechnung/generate
{
    "rch_id": 123,
    "vorlage_id": 8
}

# 8. Filter-Queries
GET /api/rechnungen?kun_id=123
GET /api/rechnungen?mahnstufe=1
GET /api/rechnungen?unbezahlt=true
GET /api/rechnungen?von=2026-01-01&bis=2026-01-31

# 9. Zahlungseingang buchen
POST /api/rechnungen/:id/zahlung
{
    "Zahlung_am": "2026-01-20",
    "Zahlbetrag1": 5950.00,
    "IstBezahlt": true
}

# 10. Umsatzstatistik
GET /api/rechnungen/statistik?jahr=2026
{
    "gesamt_netto": 120000.00,
    "gesamt_brutto": 142800.00,
    "offen": 25000.00,
    "ueberfaellig": 5000.00,
    "pro_monat": [...]
}
```

---

## 10. VBA-BRIDGE INTEGRATION (KRITISCH!)

### Benötigte VBA-Funktionen

```vba
' ❌ FEHLT: Bridge-Event-Handler in Access

' 1. Rechnung generieren
Public Sub OnBridgeEvent_generiereRechnung(data As String)
    Dim json As Object
    Set json = ParseJSON(data)

    Dim rch_id As Long
    Dim vorlage_id As Long
    rch_id = json("rch_id")
    vorlage_id = json("vorlage_id")

    ' Rechnungsnummer vergeben
    Dim RchNr As String
    RchNr = VergabeRechnungsnummer()

    ' Word-Dokument erstellen
    Dim strVorlage As String
    Dim strDokument As String
    strVorlage = GetVorlagePfad(vorlage_id)
    strDokument = GetRechnungsPfad(rch_id) & RchNr & ".docx"

    ' Platzhalter füllen
    Call Textbau_Replace_Felder_Fuellen(vorlage_id)
    Call fReplace_Table_Felder_Ersetzen(rch_id, ...)

    ' Word erstellen
    Call WordReplace(strVorlage, strDokument)

    ' PDF generieren
    Dim pdfPath As String
    pdfPath = Replace(strDokument, ".docx", ".pdf")
    PDF_Print strDokument

    ' Pfad in DB speichern
    CurrentDb.Execute "UPDATE tbl_Rch_Kopf SET Dateiname='" & pdfPath & "' WHERE ID=" & rch_id

    ' Zurück an HTML
    WebView2Bridge.PostWebMessage "{""event"":""rechnungErstellt"",""path"":""" & pdfPath & """}"
End Sub

' 2. Mahnung erstellen
Public Sub OnBridgeEvent_erstelle Mahnung(data As String)
    Dim json As Object
    Set json = ParseJSON(data)

    Dim rch_id As Long
    Dim mahnstufe As Integer
    rch_id = json("rch_id")
    mahnstufe = json("mahnstufe")

    ' Mahnungsnummer vergeben
    Dim MahnNr As String
    MahnNr = VergabeMahnungsnummer()

    ' Vorlage je nach Mahnstufe
    Dim vorlage_id As Long
    Select Case mahnstufe
        Case 1: vorlage_id = 19
        Case 2: vorlage_id = 20
        Case 3: vorlage_id = 21
    End Select

    ' Word-Dokument erstellen (analog zu Rechnung)
    ' ...

    ' Mahndaten in DB speichern
    Dim sql As String
    sql = "UPDATE tbl_Rch_Kopf SET "
    sql = sql & "M" & mahnstufe & "MahnDok='" & strDokument & "', "
    sql = sql & "M" & mahnstufe & "Mahndat=#" & Date & "#, "
    sql = sql & "M" & mahnstufe & "MahnVon='" & atCNames(1) & "', "
    sql = sql & "M" & mahnstufe & "Mahnbetrag1=" & json("mahnbetrag") & ", "
    sql = sql & "M" & mahnstufe & "IstGemahnt1=True "
    sql = sql & "WHERE ID=" & rch_id
    CurrentDb.Execute sql

    ' Zurück an HTML
    WebView2Bridge.PostWebMessage "{""event"":""mahnungErstellt"",""mahnstufe"":" & mahnstufe & "}"
End Sub

' 3. Rechnungsnummer vergeben
Private Function VergabeRechnungsnummer() As String
    Dim ID As Long
    ID = Update_Rch_Nr(8) ' Rechnung = ID 8
    Dim Praefix As String
    Praefix = TLookup("Praefix1", "_tblEigeneFirma_Word_Nummernkreise", "ID=8")
    VergabeRechnungsnummer = Praefix & Right("00000" & ID, 5)
End Function
```

---

## 11. VORGESCHLAGENE HTML-STRUKTUR

### Formular-Layout (Komplex!)

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Rechnungsverwaltung - CONSYS</title>
    <link rel="stylesheet" href="consys-common.css">
</head>
<body data-form="frm_Rechnung">
    <div class="app-container">
        <!-- Sidebar -->
        <div class="app-sidebar"></div>

        <!-- Main Area -->
        <div class="app-main">
            <!-- Header -->
            <div class="app-header">
                <h1>Rechnungsverwaltung</h1>
                <div class="header-actions">
                    <button onclick="neueRechnung()">Neue Rechnung</button>
                    <button onclick="speichern()">Speichern</button>
                    <button onclick="loeschen()">Löschen</button>
                    <button onclick="generiereRechnung()">Rechnung erstellen</button>
                </div>
            </div>

            <!-- Content -->
            <div class="app-content">
                <!-- Filter-Toolbar -->
                <div class="filter-toolbar">
                    <label>Kunde:</label>
                    <select id="cboKunde" onchange="filterByKunde()">
                        <option value="">Alle</option>
                    </select>

                    <label>Mahnstufe:</label>
                    <select id="cboMahnstufe" onchange="filterByMahnstufe()">
                        <option value="">Alle</option>
                        <option value="1">Mahnstufe 1</option>
                        <option value="2">Mahnstufe 2</option>
                        <option value="3">Mahnstufe 3</option>
                    </select>

                    <label>Status:</label>
                    <select id="cboStatus" onchange="filterByStatus()">
                        <option value="">Alle</option>
                        <option value="offen">Offen</option>
                        <option value="bezahlt">Bezahlt</option>
                        <option value="ueberfaellig">Überfällig</option>
                    </select>

                    <button onclick="clearFilter()">Filter löschen</button>
                </div>

                <!-- Navigation -->
                <div class="record-nav">
                    <button onclick="gotoFirst()">|◄</button>
                    <button onclick="gotoPrev()">◄</button>
                    <span id="recordInfo">1 / 50</span>
                    <button onclick="gotoNext()">►</button>
                    <button onclick="gotoLast()">►|</button>
                </div>

                <!-- Tab Control -->
                <div class="tab-control">
                    <div class="tabs">
                        <button class="tab active" data-tab="main">Stammdaten</button>
                        <button class="tab" data-tab="positionen">Positionen</button>
                        <button class="tab" data-tab="auftraege">Aufträge</button>
                        <button class="tab" data-tab="mahnung">Mahnung</button>
                        <button class="tab" data-tab="weiteres">Weiteres</button>
                    </div>

                    <!-- Tab: Stammdaten -->
                    <div class="tab-content active" id="tab-main">
                        <div class="form-grid">
                            <!-- Rechnungsdaten -->
                            <div class="form-section">
                                <h3>Rechnungsdaten</h3>
                                <div class="form-group">
                                    <label>Rechnungs-Nr:</label>
                                    <input type="text" id="ID" readonly>
                                </div>
                                <div class="form-group">
                                    <label>Kunde:</label>
                                    <select id="kun_ID"></select>
                                </div>
                                <div class="form-group">
                                    <label>Auftrag:</label>
                                    <select id="VA_ID"></select>
                                </div>
                                <div class="form-group">
                                    <label>Rechnungsdatum:</label>
                                    <input type="date" id="RchDatum">
                                </div>
                                <div class="form-group">
                                    <label>Leistungszeitraum:</label>
                                    <input type="date" id="Leist_Datum_von">
                                    <span> bis </span>
                                    <input type="date" id="Leist_Datum_Bis">
                                </div>
                                <div class="form-group">
                                    <label>Zahlungsziel:</label>
                                    <input type="date" id="Zahlung_Bis">
                                </div>
                                <div class="form-group">
                                    <label>Zahlungsbedingungen:</label>
                                    <select id="ZahlBed_ID"></select>
                                </div>
                            </div>

                            <!-- Zahlungsinformationen -->
                            <div class="form-section">
                                <h3>Zahlung</h3>
                                <div class="form-group">
                                    <label>Gezahlt am:</label>
                                    <input type="date" id="Zahlung_am">
                                </div>
                                <div class="form-group">
                                    <label>Betrag gezahlt:</label>
                                    <input type="number" id="Zahlbetrag1" step="0.01">
                                </div>
                                <div class="form-group">
                                    <label><input type="checkbox" id="IstBezahlt"> Bezahlt</label>
                                </div>
                            </div>

                            <!-- Summen -->
                            <div class="summen-box">
                                <div class="summe-row">
                                    <span>Zwischensumme (netto):</span>
                                    <input type="number" id="Zwi_Sum1" step="0.01" readonly>
                                </div>
                                <div class="summe-row">
                                    <span>MwSt (19%):</span>
                                    <input type="number" id="MwSt_Sum1" step="0.01" readonly>
                                </div>
                                <div class="summe-row total">
                                    <span>Gesamtsumme (brutto):</span>
                                    <input type="number" id="Gesamtsumme1" step="0.01" readonly>
                                </div>
                            </div>

                            <!-- Bemerkungen -->
                            <div class="form-group full-width">
                                <label>Bemerkungen:</label>
                                <textarea id="Bemerkungen" rows="5"></textarea>
                            </div>
                        </div>
                    </div>

                    <!-- Tab: Positionen -->
                    <div class="tab-content" id="tab-positionen">
                        <div class="toolbar">
                            <button onclick="neuePosition()">Neue Position</button>
                            <button onclick="positionLoeschen()">Löschen</button>
                            <button onclick="positionenAusAuftrag()">Aus Auftrag übernehmen</button>
                        </div>
                        <table class="data-table" id="tblPositionen">
                            <thead>
                                <tr>
                                    <th>Pos</th>
                                    <th>Bezeichnung</th>
                                    <th>Menge</th>
                                    <th>Einheit</th>
                                    <th>Einzelpreis</th>
                                    <th>MwSt%</th>
                                    <th>Gesamt</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                    <!-- Tab: Aufträge -->
                    <div class="tab-content" id="tab-auftraege">
                        <iframe src="sub_Rch_VA_Gesamtanzeige.html"></iframe>
                    </div>

                    <!-- Tab: Mahnung -->
                    <div class="tab-content" id="tab-mahnung">
                        <div class="mahnung-grid">
                            <!-- Mahnstufe 1 -->
                            <div class="mahnung-section">
                                <h3>Mahnstufe 1</h3>
                                <div class="form-group">
                                    <label>Mahndatum:</label>
                                    <input type="date" id="M1Mahndat" readonly>
                                </div>
                                <div class="form-group">
                                    <label>Mahnbetrag:</label>
                                    <input type="number" id="M1Mahnbetrag1" step="0.01" readonly>
                                </div>
                                <div class="form-group">
                                    <label>Sachbearbeiter:</label>
                                    <input type="text" id="M1MahnVon" readonly>
                                </div>
                                <div class="form-group">
                                    <label><input type="checkbox" id="M1IstGemahnt1" disabled> Gemahnt</label>
                                </div>
                                <div class="form-group">
                                    <label>Dokument:</label>
                                    <input type="text" id="M1MahnDok" readonly>
                                    <button onclick="oeffneMahnung(1)">Öffnen</button>
                                </div>
                                <div class="form-group full-width">
                                    <label>Bemerkungen:</label>
                                    <textarea id="M1Mahn_Bemerkungen" rows="3" readonly></textarea>
                                </div>
                            </div>

                            <!-- Mahnstufe 2 & 3 analog -->
                            <!-- ... -->

                            <!-- Mahnung erstellen -->
                            <div class="mahnung-actions">
                                <label>Mahnstufe:</label>
                                <select id="mahnstufAuswahl">
                                    <option value="1">Mahnstufe 1</option>
                                    <option value="2">Mahnstufe 2</option>
                                    <option value="3">Mahnstufe 3</option>
                                </select>
                                <button onclick="erstell mahnung()">Mahnung erstellen</button>
                            </div>
                        </div>
                    </div>

                    <!-- Tab: Weiteres -->
                    <div class="tab-content" id="tab-weiteres">
                        <div class="form-group">
                            <label>Dateipfad (Word/PDF):</label>
                            <input type="text" id="Dateiname" readonly>
                            <button onclick="oeffneDatei()">Öffnen</button>
                        </div>
                        <div class="button-group">
                            <button onclick="generiereRechnungPDF()">Rechnung als PDF</button>
                            <button onclick="generierePositionenPDF()">Positionen als PDF</button>
                        </div>
                        <div class="system-info">
                            <h3>System-Info</h3>
                            <div>Erstellt am: <span id="Erst_am"></span> von <span id="Erst_von"></span></div>
                            <div>Geändert am: <span id="Aend_am"></span> von <span id="Aend_von"></span></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="app-footer">
                <span id="statusMessage">Bereit</span>
            </div>
        </div>
    </div>

    <script src="js/webview2-bridge.js"></script>
    <script src="js/sidebar.js"></script>
    <script src="logic/frm_Rechnung.logic.js"></script>
</body>
</html>
```

---

## 12. COMPLETION-ANALYSE

### IST-Zustand (nur Platzhalter)

| Komponente | Soll | Ist | Prozent |
|------------|------|-----|---------|
| HTML-Struktur | 1 Formular | Platzhalter | 0% |
| Felder | 60+ | 0 | 0% |
| Buttons | 15 | 0 | 0% |
| ComboBoxen | 10 | 0 | 0% |
| Subforms | 5 | 0 | 0% |
| API-Integration | 10 Endpoints | 0 | 0% |
| Word-Integration | VBA-Bridge | 0 | 0% |
| Mahnwesen | 3 Stufen | 0 | 0% |
| Tab-Control | 7 Tabs | 0 | 0% |
| **GESAMT** | | | **0%** |

---

## 13. AUFWAND-SCHÄTZUNG (KOMPLETT-IMPLEMENTIERUNG)

### Phase 1: Grundstruktur (24-32 Stunden)
1. **HTML-Formular erstellen** - 16h
2. **Felder mappen** (60+ Felder) - 8h
3. **Tab-Control implementieren** (7 Tabs) - 8h

### Phase 2: API-Integration (24-32 Stunden)
4. **API-Endpoints** in api_server.py - 16h
   - GET/POST/PUT/DELETE /api/rechnungen
   - Positionen CRUD
   - Filter-Queries
   - Zahlungseingang
   - Statistik
5. **Logic.js** für CRUD - 12h
6. **Formular-Validierung** - 4h

### Phase 3: Subforms (24-32 Stunden)
7. **sub_Rch_Pos_Geschrieben** (Positionen-Editor) - 12h
8. **sub_Rch_Pos_Auftrag** (Positionen aus Auftrag) - 8h
9. **sub_Rch_VA_Gesamtanzeige** (Auftrags-Übersicht) - 8h
10. **Positionen-Summen automatisch berechnen** - 4h

### Phase 4: Mahnwesen (24-32 Stunden)
11. **Mahnstufen-Filter** (cboMahnstufe, Queries) - 4h
12. **Mahnung-Tab** mit 3 Stufen - 8h
13. **Button "Mahnen"** + VBA-Bridge - 12h
14. **Mahnungs-Vorlagen** (Word) - 8h

### Phase 5: Word/PDF-Integration (32-40 Stunden)
15. **VBA-Bridge für Rechnungs-Generierung** - 20h
16. **VBA-Bridge für Mahnungs-Generierung** - 12h
17. **Word-Vorlagen anpassen** - 8h
18. **PDF-Generierung** - 8h

### Phase 6: Zahlungsüberwachung (8-12 Stunden)
19. **Zahlungseingang buchen** - 4h
20. **Status-Berechnung** (Offen, Überfällig) - 4h
21. **Zahlungs-Erinnerungen** - 4h

**Gesamt-Aufwand:** 136-180 Stunden

---

## 14. PRIORITÄTEN

### P1 - Kritisch (Minimum Viable Product)
1. ❌ HTML-Formular mit Stammdaten (16h)
2. ❌ API-Endpoints (CRUD) (16h)
3. ❌ Positionen-Editor (12h)
4. ❌ Summen-Berechnung (4h)
5. ❌ Word/PDF-Generierung via VBA-Bridge (20h)

**MVP-Aufwand:** 68 Stunden

### P2 - Wichtig
6. ❌ Mahnwesen (3 Stufen) (32h)
7. ❌ Zahlungsüberwachung (12h)
8. ❌ Filter (Kunde, Mahnstufe, Status) (4h)

### P3 - Nice-to-Have
9. ❌ Statistiken/Umsatzauswertungen
10. ❌ Export als Excel
11. ❌ Druck-Vorschau

---

## 15. FAZIT

### Aktueller Status
- **Implementierung:** 0% (nur leerer Platzhalter)
- **Geschätzter Aufwand:** 136-180 Stunden für Vollimplementierung
- **MVP-Aufwand:** 68 Stunden (ohne Mahnwesen)
- **MVP + Mahnwesen:** 100 Stunden

### Komplexität
**Rechnungsformular ist das KOMPLEXESTE Formular im System:**
- Über 200 Controls
- 467 Zeilen VBA-Code in Access
- 7 Tabs mit verschiedenen Funktionen
- Mahnwesen mit 3 Stufen
- Word/PDF-Integration
- Zahlungsüberwachung
- Umfangreiche Filter-Optionen

### Empfehlung

**Option A: Vollimplementierung (180h)**
- Komplettes Formular nach Vorbild von frmTop_RechnungsStamm
- Alle Features (Positionen, Mahnwesen, Word-Integration)
- Production-ready
- **Aufwand:** 4-5 Wochen Vollzeit

**Option B: MVP ohne Mahnwesen (68h)**
- Stammdaten + CRUD
- Positionen-Editor
- Summen-Berechnung
- Word/PDF-Generierung
- Reicht für Rechnungserstellung
- Mahnwesen separat in Phase 2
- **Aufwand:** 1.5-2 Wochen Vollzeit

**Option C: Verzicht (0h)**
- Verwende frmTop_RechnungsStamm mit Toggle
- HTML-Formular bleibt Platzhalter
- Bei Klick auf "Rechnung" → Access-Formular öffnen

### Bevorzugte Option
**Option B (MVP ohne Mahnwesen)** - Bietet schnellen Einstieg. Mahnwesen kann in Phase 2 ergänzt werden (+32h).

### Nächste Schritte (wenn MVP gewünscht)
1. frmTop_RechnungsStamm.md detailliert analysieren
2. HTML-Struktur aufbauen (16h)
3. API-Endpoints implementieren (16h)
4. VBA-Bridge für Word-Generierung einrichten (20h)
5. Positionen-Editor implementieren (12h)
6. Summen-Berechnung (4h)

**Zeitrahmen MVP:** 2 Wochen (bei Vollzeit-Entwicklung)
**Zeitrahmen Vollversion:** 5 Wochen (bei Vollzeit-Entwicklung)

### Kritische Abhängigkeiten
- VBA-Bridge MUSS funktionieren (Word/PDF-Generierung ist Kern-Feature)
- Word-Vorlagen müssen vorhanden sein
- Nummernkreis-Tabelle (_tblEigeneFirma_Word_Nummernkreise) muss existieren
- Platzhalter-Module (Textbau_Replace_Felder_Fuellen, etc.) müssen dokumentiert werden
