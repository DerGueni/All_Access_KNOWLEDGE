# Gap-Analyse: frmTop_RechnungsStamm

**Analysiert am:** 2026-01-12
**Access-Export:** forms3/Access_Abgleich/forms/frmTop_RechnungsStamm.md
**HTML-Formular:** Nicht vorhanden (wird durch frm_Rechnung.html + frm_Angebot.html ersetzt)
**Logic-JS:** Keine

---

## Executive Summary

### Formular-Status
- **Access:** Zentrales Rechnungs- und Angebots-Formular mit Toggle
- **HTML:** Nicht als eigenständiges Formular vorhanden - aufgeteilt in:
  - `frm_Rechnung.html` (0% implementiert - nur Platzhalter)
  - `frm_Angebot.html` (0% implementiert - nur Platzhalter)
- **Implementierung:** 0%

### Formular-Umfang (Access)
- **Controls:** 206 (größtes Formular im System!)
  - 13 Buttons (Navigation, CRUD, Export)
  - 66 TextBoxen (Stammdaten, Mahnung, Zahlungsdaten)
  - 9 ComboBoxen (Filter, Daten)
  - 6 OptionButtons (Status-Flags)
  - 5 Subforms (Positionen, Aufträge)
  - 94 Labels
  - 1 TabControl mit 7 Tabs
  - 12 sonstige (Rectangles, Lines, Pages)

### Besonderheit
Dieses Formular ist ein **Master-Formular** das BEIDE Dokumenttypen verwaltet:
- **Rechnung** (RchTyp = 'Rechnung')
- **Angebot** (RchTyp = 'Angebot')

Toggle via `istRechnung` Rectangle (OnClick Event)

### Kritische Gaps
1. **Master-Formular fehlt komplett** - HTML hat zwei separate Platzhalter
2. **Toggle-Mechanismus** nicht implementiert
3. **Mahnwesen** (3 Stufen) fehlt komplett
4. **Word-Integration** fehlt (467 Zeilen VBA-Code!)
5. **Filter-System** (Kunde, Mahnstufe, Rch-ID) nicht vorhanden
6. **SplitForm-View** (Formular + Datasheet) fehlt

---

## 1. FORMULAR-EIGENSCHAFTEN

### Access

```
Name: frmTop_RechnungsStamm
RecordSource: tbl_Rch_Kopf
AllowEdits: True
AllowAdditions: True
AllowDeletions: True
DataEntry: False
DefaultView: SplitForm (Formular + Datasheet)
NavigationButtons: False
HasModule: True (467 Zeilen VBA-Code!)
FilterOn: False
Filter: Keine
```

**SplitForm-Eigenschaften:**
- Oberer Teil: Einzelformular mit Details
- Unterer Teil: Datasheet (Tabellen-Ansicht) aller Rechnungen/Angebote
- Synchronisation zwischen beiden Ansichten

### HTML (IST-ZUSTAND)

**Entscheidung: Zwei separate Formulare statt Toggle**

| Formular | Datei | Status | Begründung |
|----------|-------|--------|------------|
| **Rechnung** | frm_Rechnung.html | 0% (Platzhalter) | Einfachere Logik |
| **Angebot** | frm_Angebot.html | 0% (Platzhalter) | Einfachere Logik |

**Alternative A (wie Access):**
```html
<!-- Ein Formular mit Toggle -->
<div class="form-header">
    <button class="toggle-button" id="btnToggleType">
        Rechnung / Angebot
    </button>
</div>
<div class="form-body">
    <!-- Gemeinsame Felder für beide Typen -->
</div>
```

**Alternative B (HTML - gewählt):**
- Zwei separate Formulare
- Einfachere Wartung
- Klarere Trennung
- Weniger Komplexität

---

## 2. VBA-CODE ANALYSE (467 Zeilen!)

### OnLoad Event

```vba
Private Sub Form_Load()
    DoCmd.Maximize
End Sub
```

### OnCurrent Event (Mahnung-Felder setzen)

```vba
Private Sub Form_Current()
    If Me!reg_Rech.Pages(Me!reg_Rech).Name = "pgMahnen" And Nz(Me!cboMahnstufe.Column(0), 0) > 0 Then
        Call fMahnsetz
    End If
End Sub
```

### Filter-ComboBoxen Events

#### cboKunde_AfterUpdate (Filter nach Kunde)

```vba
Private Sub cboKunde_AfterUpdate()
    Me.RecordSource = "SELECT * FROM tbl_Rch_Kopf WHERE kun_ID = " & Me!cboKunde.Column(0)
    Me.Requery
End Sub
```

#### cboMahnstufe_AfterUpdate (Filter nach Mahnstufe)

```vba
Private Sub cboMahnstufe_AfterUpdate()
    Dim i As Long
    i = Me!cboMahnstufe.Column(0)

    ' Wechselt RecordSource zu spezieller Query
    Me.RecordSource = "qry_Rch_Mahnstufe" & i
    Me.Requery

    ' Setzt Mahnfelder
    Call fMahnsetz
End Sub
```

**Benötigte Queries:**
- qry_Rch_Mahnstufe1 - Ungemahnteoder 1. Mahnstufe
- qry_Rch_Mahnstufe2 - 2. Mahnstufe
- qry_Rch_Mahnstufe3 - 3. Mahnstufe

#### cboRchID_AfterUpdate (Springe zu Rechnung)

```vba
Private Sub cboRchID_AfterUpdate()
    Me.Recordset.FindFirst "ID = " & Me!cboRchID
End Sub
```

### Toggle Rechnung/Angebot

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

**Benötigte Queries:**
- qry_tbl_Rch_Kopf - `SELECT * FROM tbl_Rch_Kopf WHERE RchTyp='Rechnung'`
- qry_tbl_Rch_Kopf_Ang - `SELECT * FROM tbl_Rch_Kopf WHERE RchTyp='Angebot'`

### Filter löschen

```vba
Private Sub btnFIlterLoesch_Click()
    Me!kun_firma.ControlSource = ""
    Me!kun_BriefKopf.ControlSource = ""
    Me!cboKunde = ""
    Me!cboMahnstufe = ""
    Me.RecordSource = "tbl_Rch_Kopf"
    Me.Requery
End Sub
```

### Mahnung erstellen (KOMPLEX - 150 Zeilen!)

```vba
Private Sub btnMahnen_Click()
    Dim i As Long
    Dim ikun_ID As Long
    Dim Mah_ID As Long
    Dim Mah_Num As String
    Dim Praefix As String
    Dim Praefix1 As String
    Dim Mah_Dateiname As String
    Dim Mah_PDFDateiname As String
    Dim iDokVorlage_ID As Long
    Dim vorlPfad As String
    Dim VorlNamen As String
    Dim DokPfad As String
    Dim strVorlage As String
    Dim strDokument As String
    Dim strPDFDokument As String
    Dim iRch_KopfID As Long
    Dim strSQL As String

    ' 1. Prüfe ob Kundenrechnung
    ikun_ID = Nz(TLookup("kun_ID", "tbl_Rch_Kopf", "ID = " & Me!ID), 0)
    If ikun_ID = 0 Then
        MsgBox "Keine Kundenrechnung - Keine Mahnung"
        Exit Sub
    End If

    ' 2. Mahnungsnummer erzeugen
    i = 15  ' Mahnung = Nummernkreis 15
    Mah_ID = Update_Rch_Nr(i)
    Praefix = Nz(TLookup("Praefix", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & i))
    Praefix1 = Nz(TLookup("Praefix1", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & i))
    Mah_Num = Praefix1 & Right("00000" & Mah_ID, 5)
    Mah_Dateiname = Praefix & "_" & Mah_Num & ".docx"
    Mah_PDFDateiname = Praefix & "_" & Mah_Num & ".pdf"

    ' 3. Pfade ermitteln
    vorlPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 5"))
    DokPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))
    If Right(vorlPfad, 1) <> "\" Then vorlPfad = vorlPfad & "\"
    If Right(DokPfad, 1) <> "\" Then DokPfad = DokPfad & "\"

    ' 4. Vorlage je nach Mahnstufe
    Select Case Me!cboMahnstufe.Column(0)
        Case 1: iDokVorlage_ID = 19
        Case 2: iDokVorlage_ID = 20
        Case 3: iDokVorlage_ID = 21
    End Select

    VorlNamen = Nz(TLookup("Docname", "_tblEigeneFirma_TB_Dok_Dateinamen", "ID = " & iDokVorlage_ID))

    strVorlage = vorlPfad & VorlNamen
    DokPfad = DokPfad & "KD_" & ikun_ID & "\"
    strDokument = DokPfad & Mah_Dateiname
    strPDFDokument = DokPfad & Mah_PDFDateiname

    iRch_KopfID = Me!ID

    ' 5. Mahnfelder setzen
    Me!Mahndok = strDokument

    i = Me!cboMahnstufe.Column(0)

    ' 6. In DB speichern
    strSQL = ""
    strSQL = strSQL & "UPDATE tbl_Rch_Kopf SET"
    strSQL = strSQL & " tbl_Rch_Kopf.M" & i & "Mahndok = '" & Nz(Me!Mahndok) & "'"
    strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "Mahndat = " & SQLDatum(Me!Mahndat)
    strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "MahnVon = '" & Nz(Me!MahnVon) & "'"
    strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "Mahnbetrag1 = " & str(Me!MahnBetrag)
    strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "IstGemahnt1 = " & CLng(Me!IstGemahnt)
    strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "Mahn_Bemerkungen = '" & Nz(Me!Mahn_Bemerkungen) & "'"
    strSQL = strSQL & " , tbl_Rch_Kopf.Aend_von = '" & atCNames(1) & "'"
    strSQL = strSQL & " , tbl_Rch_Kopf.Aend_am = " & SQLDatum(Date)
    strSQL = strSQL & " WHERE ((tbl_Rch_Kopf.ID)= " & iRch_KopfID & ");"
    CurrentDb.Execute (strSQL)

    DoEvents

    ' 7. Word-Dokument erstellen
    Call Textbau_Replace_Felder_Fuellen(iDokVorlage_ID)
    Call fReplace_Table_Felder_Ersetzen(Me!ID, ikun_ID, 0, Me!VA_ID)
    DoEvents
    Call WordReplace(strVorlage, strDokument)

    ' 8. PDF erstellen
    PDF_Print strDokument

    ' 9. Word-Objekt zurücksetzen
    Reset_Word_Objekt
End Sub
```

**Abhängigkeiten:**
- `Update_Rch_Nr(i)` - Vergibt nächste Nummer
- `TLookup(field, table, where)` - Lookup-Funktion
- `Get_Priv_Property(name)` - Liest System-Einstellung
- `SQLDatum(date)` - Formatiert Datum für SQL
- `atCNames(1)` - Aktueller Benutzername
- `Textbau_Replace_Felder_Fuellen(id)` - Füllt Platzhalter
- `fReplace_Table_Felder_Ersetzen(...)` - Ersetzt Tabellen
- `WordReplace(vorlage, dokument)` - Erstellt Word-Dokument
- `PDF_Print(dokument)` - Konvertiert zu PDF
- `Reset_Word_Objekt()` - Cleanup

### Mahnung-Helper-Funktion

```vba
Public Function fMahnsetz()
    Dim iRch_KopfID As Long
    Dim strSQL As String

    Me!kun_firma.ControlSource = "kun_Firma"
    Me!kun_BriefKopf.ControlSource = "kun_BriefKopf"
    Me!lbl_Mahnstufe.caption = Me!cboMahnstufe.Column(1)
    Me!MahnBetrag = Me!ZahlBetrag_Netto1
    Me!Mahndat = Date
    Me!MahnVon = atCNames(1)
    Me!IstGemahnt = True

    DoEvents
End Function
```

### Dateiname DblClick (Öffne Dokument)

```vba
Private Sub Dateiname_DblClick(Cancel As Integer)
    Dim Datei As String

    On Error GoTo Err

    Application.FollowHyperlink Me!Dateiname

Ende:
    Exit Sub
Err:
    Datei = Dateiauswahl("Rechnung auswählen", "*.pdf,*.doc,*.docx", consys)
    If Datei <> "" Then Me.Dateiname = Datei
    Resume Ende
End Sub
```

### UI-Toggle-Buttons (Ribbon/DatNav)

```vba
Private Sub btnDaBaAus_Click()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End Sub

Private Sub btnDaBaEin_Click()
    DoCmd.SelectObject acTable, , True
End Sub

Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub

Private Sub btnRibbonEin_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub
```

---

## 3. CONTROLS ÜBERSICHT

### Buttons (13 Stück)

| Button | Caption | Position | Events | HTML | Status |
|--------|---------|----------|--------|------|--------|
| **Befehl38** | Formular schließen | 9653/90 | Makro | - | ❌ Fehlt |
| **Befehl39** | Letzter DS | 9194/90 | Makro | - | ❌ Fehlt |
| **Befehl40** | Datensatz vor | 8735/90 | Makro | - | ❌ Fehlt |
| **Befehl41** | Datensatz zurück | 8276/90 | Makro | - | ❌ Fehlt |
| **Befehl42** | Drucken | 7358/90 | Makro | - | ❌ Fehlt |
| **Befehl43** | Erster DS | 7817/90 | Makro | - | ❌ Fehlt |
| **Befehl46** | Neue Rechnung | 10204/945 | Makro | - | ❌ Fehlt |
| **btnHilfe** | Hilfe | 6899/90 | Makro | - | ❌ Fehlt |
| **mcobtnDelete** | Rechnung löschen | 10204/520 | Makro | - | ❌ Fehlt |
| **btnFIlterLoesch** | Filter löschen | 10204/75 | Procedure | - | ❌ Fehlt |
| **btnRibbonAus/Ein** | Ribbon | 1248/283-613 | Procedure | - | N/A (Web) |
| **btnDaBaAus/Ein** | DatNav | 963-1533/448 | Procedure | - | N/A (Web) |
| **btnMahnen** | Mahnen | 12292/5499 | Procedure (150 Zeilen!) | - | ❌ Fehlt |

### ComboBoxen (9 Stück)

| ComboBox | ControlSource | RowSource | Position | HTML | Status |
|----------|---------------|-----------|----------|------|--------|
| **cboKunde** | - (Filter) | tbl_KD_Kundenstamm | 13372/521 | - | ❌ Fehlt |
| **cboMahnstufe** | - (Filter) | Hardcoded 1-3 | 13372/946 | - | ❌ Fehlt |
| **cboRchID** | - (Filter) | tbl_Rch_Kopf.ID | 13372/75 | - | ❌ Fehlt |
| **kun_ID** | kun_ID | tbl_KD_Kundenstamm | 3929/2190 | - | ❌ Fehlt |
| **RchTyp** | RchTyp | 'Rechnung'/'Angebot' | 10834/1290 | - | ❌ Fehlt |
| **Kombinationsfeld448** | VA_ID | tbl_VA_Auftragstamm | 3914/1290 | - | ❌ Fehlt |
| **lbl_Auftragsdatum** | VA_ID | tbl_VA_Auftragstamm | 3914/1725 | - | ❌ Fehlt |
| **MA_ID** | MA_ID | tbl_MA_Mitarbeiterstamm | 5135/2655 | - | ❌ Fehlt |
| **ZahlBed_ID** | ZahlBed_ID | tbl_Zahlungsbedingungen | 5135/3236 | - | ❌ Fehlt |

### TextBoxen (66 Stück)

#### Stammdaten (15 Felder)

| Feld | ControlSource | HTML | Status |
|------|---------------|------|--------|
| **ID** | ID | - | ❌ Fehlt |
| **RchDatum** | RchDatum | - | ❌ Fehlt |
| **Leist_Datum_von** | Leist_Datum_von | - | ❌ Fehlt |
| **Leist_Datum_Bis** | Leist_Datum_Bis | - | ❌ Fehlt |
| **Ang_Gueltig_Bis** | Ang_Gueltig_Bis | - | ❌ Fehlt |
| **VA_ID** | VA_ID | - | ❌ Fehlt |
| **Dateiname** | Dateiname | - | ❌ Fehlt |
| **VorlageDokNr** | VorlageDokNr | - | ❌ Fehlt |
| **Bemerkungen** | Bemerkungen | - | ❌ Fehlt |
| **Zwi_Sum1** | Zwi_Sum1 | - | ❌ Fehlt |
| **MwSt_Sum1** | MwSt_Sum1 | - | ❌ Fehlt |
| **Gesamtsumme1** | Gesamtsumme1 | - | ❌ Fehlt |

#### Zahlungsdaten (6 Felder)

| Feld | ControlSource | HTML | Status |
|------|---------------|------|--------|
| **Zahlung_am** | Zahlung_am | - | ❌ Fehlt |
| **Zahlung_Bis** | Zahlung_Bis | - | ❌ Fehlt |
| **Zahlbetrag1** | Zahlbetrag1 | - | ❌ Fehlt |
| **ZahlBetrag_Netto1** | ZahlBetrag_Netto1 | - | ❌ Fehlt |

#### Mahnstufe 1 (6 Felder)

| Feld | ControlSource | HTML | Status |
|------|---------------|------|--------|
| **M1Mahn** | M1MahnDok | - | ❌ Fehlt |
| **M1Mahndat** | M1Mahndat | - | ❌ Fehlt |
| **M1MahnVon** | M1MahnVon | - | ❌ Fehlt |
| **M1Mahnbetrag1** | M1Mahnbetrag1 | - | ❌ Fehlt |
| **M1Mahn_Bemerkungen** | M1Mahn_Bemerkungen | - | ❌ Fehlt |

#### Mahnstufe 2 & 3 (jeweils 5 Felder)

| Felder | Status |
|--------|--------|
| M2MahnDok, M2Mahndat, M2MahnVon, M2Mahnbetrag1, M2Mahn_Bemerkungen | ❌ Fehlt |
| M3MahnDok, M3Mahndat, M3MahnVon, M3Mahnbetrag1, M3Mahn_Bemerkungen | ❌ Fehlt |

#### Mahnen-Tab (virtuelle Felder)

| Feld | ControlSource | HTML | Status |
|------|---------------|------|--------|
| **MahnBetrag** | - (nicht gebunden) | - | ❌ Fehlt |
| **Mahndat** | - (nicht gebunden) | - | ❌ Fehlt |
| **MahnVon** | - (nicht gebunden) | - | ❌ Fehlt |
| **Mahndok** | - (nicht gebunden) | - | ❌ Fehlt |
| **Mahn_Bemerkungen** | - (nicht gebunden) | - | ❌ Fehlt |

#### Kundendaten (2 Felder - ungebunden)

| Feld | ControlSource | HTML | Status |
|------|---------------|------|--------|
| **kun_Firma** | - (dynamisch) | - | ❌ Fehlt |
| **kun_BriefKopf** | - (dynamisch) | - | ❌ Fehlt |

#### System-Felder (4 Felder)

| Feld | ControlSource | HTML | Status |
|------|---------------|------|--------|
| **Erst_am** | Erst_am | - | ❌ Fehlt |
| **Erst_von** | Erst_von | - | ❌ Fehlt |
| **Aend_am** | Aend_am | - | ❌ Fehlt |
| **Aend_von** | Aend_von | - | ❌ Fehlt |

### OptionButtons (6 Stück)

| OptionButton | ControlSource | Position | HTML | Status |
|--------------|---------------|----------|------|--------|
| **IstBezahlt** | - (nicht gebunden) | 12585/1405 | - | ❌ Fehlt |
| **IstSammelRch** | IstSammelRch | 5082/3798 | - | ❌ Fehlt |
| **M1IstGemahnt1** | M1IstGemahnt1 | 5264/2970 | - | ❌ Fehlt |
| **M2IstGemahnt1** | M2IstGemahnt1 | 9467/2978 | - | ❌ Fehlt |
| **M3IstGemahnt1** | M3IstGemahnt1 | 13435/2978 | - | ❌ Fehlt |
| **IstGemahnt** | - (virtuell) | 5268/2965 | - | ❌ Fehlt |

### Rectangles (1 Stück - Toggle!)

| Rectangle | Caption | Position | Events | HTML | Status |
|-----------|---------|----------|--------|------|--------|
| **istRechnung** | Rechnung | 12649/90 | Procedure (Toggle) | - | ❌ Fehlt |

**Funktion:** Wechselt zwischen Rechnung und Angebot

### TabControl (1 Stück)

| TabControl | Position | Größe | HTML | Status |
|------------|----------|-------|------|--------|
| **reg_Rech** | 2834/660 | 13531 x 11235 | - | ❌ Fehlt |

**7 Pages:**
- pgMain - Stammdaten
- pgWeit - Weiteres
- pg_VA_ID - Aufträge
- pgGeschrPos - Geschriebene Positionen
- pgAuftrPos - Auftragspositionen
- pgMahnInfo - Mahnung Info (Read-Only)
- pgMahnen - Mahnen (Button + Felder)

### Subforms (5 Stück)

| Subform | SourceObject | Position | HTML | Status |
|---------|--------------|----------|------|--------|
| **sub_Rch_Sub_VA_Kopf** | - | 3074/4920 | - | ❌ Fehlt |
| **sub_Rch_VA_Gesamtanzeige** | - | 3120/1303 | - | ❌ Fehlt |
| **sub_Rch_Pos_Geschrieben** | - | 3117/1190 | - | ❌ Fehlt |
| **sub_Rch_Pos_Auftrag** | - | 3117/1247 | - | ❌ Fehlt |
| **Menü** | - | 0/0 | ✅ sidebar.js | ✅ Vorhanden |

---

## 4. DATENMODELL

### tbl_Rch_Kopf (Haupt-Tabelle)

```sql
CREATE TABLE tbl_Rch_Kopf (
    -- Stammdaten
    ID INTEGER PRIMARY KEY,
    RchTyp TEXT,              -- 'Rechnung' oder 'Angebot'
    kun_ID INTEGER,
    VA_ID INTEGER,
    MA_ID INTEGER,
    ZahlBed_ID INTEGER,

    -- Rechnungsdaten
    RchDatum DATE,
    Leist_Datum_von DATE,
    Leist_Datum_Bis DATE,
    Ang_Gueltig_Bis DATE,     -- Nur Angebot
    Dateiname TEXT,
    VorlageDokNr INTEGER,
    Bemerkungen MEMO,

    -- Summen
    Zwi_Sum1 CURRENCY,        -- Netto
    MwSt_Sum1 CURRENCY,
    Gesamtsumme1 CURRENCY,    -- Brutto

    -- Zahlungsdaten
    Zahlung_am DATE,
    Zahlung_Bis DATE,
    Zahlbetrag1 CURRENCY,
    ZahlBetrag_Netto1 CURRENCY,
    IstSammelRch BIT,

    -- Mahnstufe 1
    M1MahnDok TEXT,
    M1Mahndat DATE,
    M1MahnVon TEXT,
    M1Mahnbetrag1 CURRENCY,
    M1IstGemahnt1 BIT,
    M1Mahn_Bemerkungen MEMO,

    -- Mahnstufe 2
    M2MahnDok TEXT,
    M2Mahndat DATE,
    M2MahnVon TEXT,
    M2Mahnbetrag1 CURRENCY,
    M2IstGemahnt1 BIT,
    M2Mahn_Bemerkungen MEMO,

    -- Mahnstufe 3
    M3MahnDok TEXT,
    M3Mahndat DATE,
    M3MahnVon TEXT,
    M3Mahnbetrag1 CURRENCY,
    M3IstGemahnt1 BIT,
    M3Mahn_Bemerkungen MEMO,

    -- System
    Erst_am DATE,
    Erst_von TEXT,
    Aend_am DATE,
    Aend_von TEXT
);
```

### Benötigte Queries

```sql
-- qry_tbl_Rch_Kopf (nur Rechnungen)
SELECT * FROM tbl_Rch_Kopf WHERE RchTyp = 'Rechnung' ORDER BY RchDatum DESC;

-- qry_tbl_Rch_Kopf_Ang (nur Angebote)
SELECT * FROM tbl_Rch_Kopf WHERE RchTyp = 'Angebot' ORDER BY RchDatum DESC;

-- qry_Rch_Mahnstufe1 (1. Mahnung fällig)
SELECT * FROM tbl_Rch_Kopf
WHERE RchTyp = 'Rechnung'
  AND (IstBezahlt = False OR IstBezahlt IS NULL)
  AND Zahlung_Bis < Date()
  AND (M1IstGemahnt1 = False OR M1IstGemahnt1 IS NULL)
ORDER BY Zahlung_Bis;

-- qry_Rch_Mahnstufe2 (2. Mahnung fällig)
SELECT * FROM tbl_Rch_Kopf
WHERE RchTyp = 'Rechnung'
  AND M1IstGemahnt1 = True
  AND DateDiff('d', M1Mahndat, Date()) > 14
  AND (M2IstGemahnt1 = False OR M2IstGemahnt1 IS NULL)
ORDER BY M1Mahndat;

-- qry_Rch_Mahnstufe3 (3. Mahnung fällig)
SELECT * FROM tbl_Rch_Kopf
WHERE RchTyp = 'Rechnung'
  AND M2IstGemahnt1 = True
  AND DateDiff('d', M2Mahndat, Date()) > 14
  AND (M3IstGemahnt1 = False OR M3IstGemahnt1 IS NULL)
ORDER BY M2Mahndat;
```

---

## 5. COMPLETION-ANALYSE

### Controls (206 gesamt)

| Typ | Access | HTML | Prozent |
|-----|--------|------|---------|
| Buttons | 13 | 0 | 0% |
| ComboBox | 9 | 0 | 0% |
| TextBox | 66 | 0 | 0% |
| OptionButton | 6 | 0 | 0% |
| Subforms | 5 | 0 (1 Menü via sidebar.js) | 0% |
| Labels | 94 | 0 | 0% |
| TabControl | 1 (7 Tabs) | 0 | 0% |
| Rectangles/Lines | 12 | 0 | 0% |
| **GESAMT** | **206** | **0** | **0%** |

### Funktionalität

| Feature | Soll | Ist | Prozent |
|---------|------|-----|---------|
| Toggle Rechnung/Angebot | VBA | Separate Formulare | 0% |
| Filter (Kunde, Mahnstufe, ID) | VBA Events | Keine | 0% |
| SplitForm-View | Access | Keine | 0% |
| Mahnwesen (3 Stufen) | VBA (150 Zeilen) | Keine | 0% |
| Word-Integration | VBA-Module | Keine | 0% |
| PDF-Generierung | VBA | Keine | 0% |
| Zahlungsüberwachung | Felder + Logik | Keine | 0% |
| Navigation (First/Prev/Next/Last) | Makros | Keine | 0% |
| CRUD (New/Save/Delete) | Makros | Keine | 0% |
| **GESAMT** | | | **0%** |

---

## 6. AUFWAND-SCHÄTZUNG (KOMPLETT-IMPLEMENTIERUNG)

**Annahme:** Zwei separate Formulare statt Toggle

### Phase 1: frm_Rechnung.html (MVP ohne Mahnwesen)
- HTML-Struktur, Felder, Buttons - 16h
- API-Endpoints (CRUD, Positionen) - 16h
- Logic.js - 12h
- VBA-Bridge (Word/PDF) - 20h
- **Subtotal:** 64h

### Phase 2: Mahnwesen für frm_Rechnung.html
- Mahnung-Tab (3 Stufen) - 8h
- Filter cboMahnstufe - 4h
- Button "Mahnen" + VBA-Bridge - 12h
- Mahnungs-Queries - 4h
- **Subtotal:** 28h

### Phase 3: frm_Angebot.html
- HTML-Struktur (ähnlich Rechnung) - 12h
- API-Endpoints (ähnlich Rechnung) - 12h
- Logic.js (ähnlich Rechnung) - 8h
- VBA-Bridge (Word/PDF) - 12h
- **Subtotal:** 44h

### Phase 4: Gemeinsame Features
- Filter (Kunde, Rch-ID) - 4h
- SplitForm-ähnliche Liste - 8h
- Subforms (Positionen, Aufträge) - 24h
- **Subtotal:** 36h

**Gesamt-Aufwand:** 172 Stunden

**Alternative (mit Toggle - wie Access):**
Gesamt-Aufwand: 140 Stunden (weniger Redundanz)

---

## 7. PRIORITÄTEN

### P1 - Kritisch
1. ❌ frm_Rechnung.html MVP (64h)
2. ❌ frm_Angebot.html MVP (44h)
3. ❌ VBA-Bridge für Word/PDF (20h)

**MVP-Aufwand:** 128 Stunden (Rechnung + Angebot ohne Mahnwesen)

### P2 - Wichtig
4. ❌ Mahnwesen (28h)
5. ❌ Filter-System (4h)
6. ❌ Subforms (24h)

### P3 - Nice-to-Have
7. ❌ SplitForm-View (8h)
8. ❌ Statistiken/Auswertungen
9. ❌ Toggle-Mechanismus (statt 2 Formulare)

---

## 8. FAZIT

### Aktueller Status
- **Implementierung:** 0% (nur Platzhalter)
- **Geschätzter Aufwand (2 Formulare):** 172 Stunden
- **Geschätzter Aufwand (1 Formular mit Toggle):** 140 Stunden
- **MVP-Aufwand (ohne Mahnwesen):** 128 Stunden

### Komplexität
**frmTop_RechnungsStamm ist das GRÖSSTE Formular im System:**
- 206 Controls (größtes Formular!)
- 467 Zeilen VBA-Code
- Master für Rechnung UND Angebot
- Mahnwesen mit 3 Stufen
- Word/PDF-Integration
- Filter-System
- SplitForm-View

### Empfehlung

**Option A: Zwei separate Formulare (HTML-Stil)**
- frm_Rechnung.html
- frm_Angebot.html
- Einfachere Wartung
- Klarere Trennung
- **Aufwand:** 172 Stunden

**Option B: Ein Formular mit Toggle (Access-Stil)**
- frm_RechnungStamm.html
- Toggle Button wie Access
- Weniger Redundanz
- Komplexere Logik
- **Aufwand:** 140 Stunden

**Option C: MVP - Nur Rechnung (ohne Mahnwesen)**
- frm_Rechnung.html
- Später: frm_Angebot.html
- Mahnwesen in Phase 2
- **Aufwand:** 64 Stunden (nur Rechnung MVP)

### Bevorzugte Option
**Option C (MVP - Nur Rechnung)** - Schneller Einstieg, iterative Erweiterung.

**Zeitplan:**
1. Phase 1: frm_Rechnung.html MVP - 2 Wochen
2. Phase 2: Mahnwesen hinzufügen - 1 Woche
3. Phase 3: frm_Angebot.html - 1.5 Wochen
4. Phase 4: Subforms & Filter - 1 Woche

**Gesamt:** 5.5 Wochen bei Vollzeit-Entwicklung

### Kritische Abhängigkeiten
- **VBA-Bridge:** Absolut kritisch für Word/PDF-Generierung
- **Nummernkreis-System:** Muss vorhanden sein
- **Word-Vorlagen:** Müssen dokumentiert werden
- **Platzhalter-System:** Muss bekannt sein
- **467 Zeilen VBA-Code:** Müssen analysiert und portiert werden

### Nächste Schritte
1. Detaillierte VBA-Code-Analyse (467 Zeilen!)
2. Word-Vorlagen dokumentieren
3. Platzhalter-System dokumentieren
4. VBA-Module identifizieren und dokumentieren
5. HTML-Struktur für frm_Rechnung.html erstellen (MVP)
