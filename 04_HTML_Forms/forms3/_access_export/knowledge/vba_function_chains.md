# VBA-Funktionsketten des CONSEC Planungssystems

## Uebersicht

Dieses Dokument beschreibt die wichtigsten VBA-Module und deren Funktionsketten.

---

## 1. E-Mail-Versand

### Modul: mdlOutlook_HTML_Serienemail_SAP

#### Hauptfunktion
```vba
Sub xSendMessage(
    ByRef theSubject,           ' E-Mail-Betreff
    theRecipient,               ' Empfaenger
    ByVal html As String,       ' HTML-Body
    Optional theCCRecepients,   ' CC (mit Semikolon getrennt)
    Optional theBCCRecepients,  ' BCC
    Optional iImportance As Long = 1,  ' 0=Low, 1=Normal, 2=High
    Optional myattach,          ' Array mit Dateipfaden
    Optional theVoting As String = ""  ' Voting-Optionen
)
```

#### Ablauf
1. HTML-Body mit Standard-Header/Footer umschliessen
2. Outlook-Objekt erstellen: `CreateObject("Outlook.Application")`
3. MailItem erstellen: `objOutlook.CreateItem(olMailItem)`
4. Eigenschaften setzen: .HTMLBody, .Subject, .Importance
5. Empfaenger hinzufuegen: `.Recipients.Add(theRecipient)`
6. Anhaenge hinzufuegen (falls vorhanden)
7. E-Mail anzeigen und senden: `.Display` + `SendKeys "%s"`
8. Log-Eintrag schreiben

#### Hilfsfunktionen
```vba
Function xTestsend1()  ' Test mit Platzhaltern
Function xTestsend2()  ' Test mit CC/BCC
Function xTestsend3()  ' Einfacher Test
```

### E-Mail-Templates

#### Speicherort
- Tabelle: `_tblEigeneFIrma` (Property-System)
- Funktion: `Get_Priv_Property("prp_HTML_...")`

#### Template-Variablen
| Variable | Ersetzung |
|----------|-----------|
| `*$*LocalReviewer*$*` | MA-Name |
| `*$*Handover_Date*$*` | Datum |
| `*$*AssetName*$*` | Auftragsname |
| `*$*LaunchDate*$*` | Startdatum |

---

## 2. Druckfunktionen / Berichte

### Modul: mdl_CreateReport

#### Verfuegbare Berichte
| Bericht | Beschreibung | Datenquelle |
|---------|--------------|-------------|
| rpt_Einsatzliste | Einsatzliste pro Auftrag | qry_Einsatzliste |
| rpt_Namensliste_ESS | Namensliste fuer ESS | qry_Namensliste |
| rpt_Bewachungsnachweis | BWN-Druck | qry_BWN |
| rpt_Rechnung | Rechnung | qry_Rch_Kopf |
| rpt_Berechnungsliste | Pos-Details | qry_Rch_Pos |
| rpt_Dienstplan | Wochen-Dienstplan | tbltmp_DP_Grund_2 |

### Aufruf-Kette: Einsatzliste drucken

```
btnDruckZusage_Click()
    |
    v
btn_std_check_Click()
    |-- Status auf 3 setzen (falls nicht abgerechnet)
    |
    v
DoCmd.OpenReport "rpt_Einsatzliste", acViewPreview, , "VA_ID = " & Me.ID
```

### Aufruf-Kette: Rechnung PDF

```
btnPDFKopf_Click()
    |
    v
DoCmd.OpenReport "rpt_Rechnung", acViewPreview, , "VA_ID = " & Me.ID
    |
    v
DoCmd.OutputTo acOutputReport, "rpt_Rechnung", acFormatPDF, strPath
```

### Modul: mdl_Rechnungsschreibung

#### Wichtige Funktionen
```vba
' PDF-Dateiname aus Rechnungspfad ableiten
Function fPDF_Datei(s As String) As String

' Zahlungsbedingungen-Text generieren
Public Function Zahlbed_Text(ZahlBed_ID As Long, betrag As Currency) As String

' Rechnungsnummer hochzaehlen
Function Update_Rch_Nr(iID As Long) As Long
```

---

## 3. Datenvalidierung

### Modul: mdl_CONSEC_Divers1

#### Allgemeine Validierungen
```vba
' Prueft ob String leer oder Null ist
Function IsNullOrEmpty(val) As Boolean

' Trimmt und prueft auf Laenge
Function HasValue(val) As Boolean

' Prueft Datumsformat
Function IsValidDate(val) As Boolean
```

### Formular-spezifische Validierung

#### frm_VA_Auftragstamm - BeforeUpdate
```vba
Private Sub Form_BeforeUpdate(Cancel As Integer)
    ' Pflichtfelder pruefen
    If IsNullOrEmpty(Me.Auftrag) Then
        MsgBox "Auftragsname fehlt!"
        Cancel = True
        Exit Sub
    End If

    If IsNull(Me.Dat_VA_Von) Then
        MsgBox "Startdatum fehlt!"
        Cancel = True
        Exit Sub
    End If

    ' Datumslogik pruefen
    If Nz(Me.Dat_VA_Bis, Me.Dat_VA_Von) < Me.Dat_VA_Von Then
        MsgBox "Enddatum vor Startdatum!"
        Cancel = True
        Exit Sub
    End If
End Sub
```

#### frm_MA_VA_Schnellauswahl - Verfuegbarkeitspruefung
```vba
Function IstMAVerfuegbar(lngMA_ID As Long, dtDatum As Date) As Boolean
    ' Prueft ob MA an diesem Tag bereits verplant ist
    IstMAVerfuegbar = (DCount("*", "tbl_MA_VA_Planung", _
        "MA_ID = " & lngMA_ID & _
        " AND VADatum = " & SQLDatum(dtDatum) & _
        " AND Status_ID NOT IN (4,5)") = 0)
End Function
```

---

## 4. Automatisierungen

### Modul: mdlAutoexec

#### AutoExec_Macro (wird bei DB-Start ausgefuehrt)
```vba
Function AutoExec()
    ' 1. Backend-Verbindung pruefen
    Call CheckBackendConnection()

    ' 2. Version pruefen
    Call CheckVersion()

    ' 3. User-Einstellungen laden
    Call LoadUserSettings()

    ' 4. Hauptformular oeffnen
    DoCmd.OpenForm "frm_Menuefuehrung1"
End Function
```

### Modul: mdl_CONSEC_AutoUpdater

#### Versionspruefung
```vba
Function CheckVersion()
    Dim strServerVersion As String
    Dim strLocalVersion As String

    strServerVersion = TLookup("Version", "_tblInternalSystemBE", "1=1")
    strLocalVersion = TLookup("Version", "_tblInternalSystemFE", "1=1")

    If strServerVersion > strLocalVersion Then
        MsgBox "Neue Version verfuegbar!"
        ' Auto-Update starten
    End If
End Function
```

### Modul: mdl_Menu_Neu

#### Ribbon-Callback-Funktionen
```vba
' Ribbon ausblenden
Sub RibbonAusblenden()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub

' Ribbon einblenden
Sub RibbonEinblenden()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub

' Datenbankfenster ein/aus
Sub NavigationEin()
    DoCmd.SelectObject acTable, , True
End Sub

Sub NavigationAus()
    DoCmd.NavigateTo "acNavigationCategoryObjectType"
    DoCmd.RunCommand acCmdWindowHide
End Sub
```

---

## 5. Dienstplan-Erstellung

### Modul: mdl_DP_Create

#### Haupt-Funktion
```vba
Function fCreate_DP_tmptable(
    dtstartdat As Date,              ' Start-Datum (Montag)
    bNurIstNichtZugeordnet As Boolean,  ' Nur unbesetzte Positionen
    iPosAusblendAb As Long           ' Positionen >= X ausblenden
)
```

#### Ablauf-Kette
```
fCreate_DP_tmptable()
    |
    +-- 1. Query "qry_DP_Alle_Zt" erstellen (Zeitraum-Filter)
    |
    +-- 2. Query "qry_DP_Kreuztabelle" erstellen (Pivot)
    |
    +-- 3. tbltmp_DP_Grund fuellen (INSERT ... SELECT)
    |
    +-- 4. tbltmp_DP_Grund_2 fuellen
    |
    +-- 5. MA-Daten eintragen (Recordset-Loop)
    |
    +-- 6. Property speichern (Startdatum merken)
```

#### Hilfs-Funktionen
```vba
' Zeile im Array nach ZuordID suchen
Function fSuchZl(i As Long) As Long

' Spaltenbreiten setzen
Function fcolw()

' MA-Ansicht Spaltenbreiten
Function fcolw_MA()
```

### Query-Struktur
```sql
-- qry_DP_Alle_Obj (Basis)
SELECT p.ID AS ZuordID, p.VA_ID, p.VADatum, p.MA_ID,
       m.Nachname & ", " & m.Vorname AS Name,
       p.MVA_Start, p.MVA_Ende, p.Status_ID,
       o.Objekt & " - " & o.Ort AS ObjOrt,
       op.PosNr
FROM tbl_MA_VA_Planung p
LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.ID
LEFT JOIN tbl_OB_Objekt o ON a.Objekt_ID = o.ID
LEFT JOIN tbl_OB_Objekt_Positionen op ON ...
```

---

## 6. MA-Schnellauswahl

### Modul: mdl_frm_MA_VA_Schnellauswahl_Code

#### Standard-Ansicht
```vba
Public Function cmdListMA_Standard_Click() As Variant
    Dim frm As Form
    Set frm = Screen.ActiveForm
    frm!List_MA.RowSource = "ztbl_MA_Schnellauswahl"
    frm!List_MA.ColumnWidths = "0;0;2835;454;852;852"
    frm!List_MA.Requery
End Function
```

#### Sortierung nach Entfernung
```vba
Public Function cmdListMA_Entfernung_Click() As Variant
    ' 1. Objekt_ID aus Auftrag holen
    lngObjektID = DLookup("Objekt_ID", "tbl_VA_Auftragstamm", "ID=" & lngVA_ID)

    ' 2. Entfernungs-Filter Query erstellen
    db.CreateQueryDef "ztmp_Entf_Filter", _
        "SELECT MA_ID, Entf_KM FROM tbl_MA_Objekt_Entfernung WHERE Objekt_ID = " & lngObjektID

    ' 3. MA-Liste mit Entfernung joinen
    strSQL = "SELECT ... FROM ztbl_MA_Schnellauswahl AS S " & _
             "LEFT JOIN ztmp_Entf_Filter AS E ON E.MA_ID = S.ID " & _
             "ORDER BY IIf(E.Entf_KM Is Null, 999, E.Entf_KM)"

    ' 4. ListBox aktualisieren
    frm!List_MA.RowSource = "ztmp_MA_Entfernung"
End Function
```

---

## 7. Geocoding / Entfernungsberechnung

### Module: mdl_GeoDistanz, mdl_AutoGeocode, mdl_BatchGeocode

#### Koordinaten aus Adresse ermitteln
```vba
Function GetGeoCoordinates(strAdresse As String) As Variant
    ' Google Maps API oder OpenStreetMap aufrufen
    ' Gibt Array(Lat, Lng) zurueck
End Function
```

#### Entfernung berechnen (Haversine)
```vba
Function CalcDistance(lat1, lng1, lat2, lng2) As Double
    ' Haversine-Formel fuer Luftlinie
    Dim R As Double: R = 6371  ' Erdradius in km
    Dim dLat, dLng, a, c

    dLat = (lat2 - lat1) * (3.14159 / 180)
    dLng = (lng2 - lng1) * (3.14159 / 180)

    a = Sin(dLat / 2) ^ 2 + Cos(lat1 * (3.14159 / 180)) * _
        Cos(lat2 * (3.14159 / 180)) * Sin(dLng / 2) ^ 2
    c = 2 * Application.WorksheetFunction.Atan2(Sqr(a), Sqr(1 - a))

    CalcDistance = R * c
End Function
```

#### Batch-Update Entfernungen
```vba
Function BatchUpdateDistances(lngObjektID As Long)
    ' Fuer alle MA die Entfernung zum Objekt berechnen
    ' und in tbl_MA_Objekt_Entfernung speichern
End Function
```

---

## 8. Formular-Hilfsfunktionen

### Modul: mdlNavigationsschaltflaechen

```vba
' Datensatz-Navigation
Sub GotoFirst(): DoCmd.GoToRecord , , acFirst: End Sub
Sub GotoPrev():  DoCmd.GoToRecord , , acPrevious: End Sub
Sub GotoNext():  DoCmd.GoToRecord , , acNext: End Sub
Sub GotoLast():  DoCmd.GoToRecord , , acLast: End Sub

' Aenderungen rueckgaengig
Sub UndoChanges()
    Me.Undo
End Sub

' Formular aktualisieren
Sub RefreshForm()
    Me.Requery
End Sub
```

### Modul: mdlSonstiges1

```vba
' SQL-Datum formatieren
Function SQLDatum(dt As Date) As String
    SQLDatum = "#" & Format(dt, "yyyy-mm-dd") & "#"
End Function

' TLookup (sicherer DLookup)
Function TLookup(strField, strTable, strWhere) As Variant
    On Error Resume Next
    TLookup = DLookup(strField, strTable, strWhere)
End Function

' Datei existiert?
Function File_exist(strPath As String) As Boolean
    File_exist = (Dir(strPath) <> "")
End Function
```

### Modul: mdlClipboard

```vba
' Text in Zwischenablage kopieren
Sub CopyToClipboard(strText As String)
    Dim objData As New MSForms.DataObject
    objData.SetText strText
    objData.PutInClipboard
End Sub

' Text aus Zwischenablage holen
Function GetFromClipboard() As String
    Dim objData As New MSForms.DataObject
    objData.GetFromClipboard
    GetFromClipboard = objData.GetText
End Function
```

---

## 9. Excel-Export

### Modul: mdl_CONSEC_Excel, mdl_Excel_Export

#### Formular-Daten nach Excel exportieren
```vba
Function ExportToExcel(strQuery As String, strFilename As String)
    ' 1. Excel starten
    Dim xlApp As Object
    Set xlApp = CreateObject("Excel.Application")

    ' 2. Neue Arbeitsmappe
    Dim xlWB As Object
    Set xlWB = xlApp.Workbooks.Add

    ' 3. Daten aus Query holen
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset(strQuery)

    ' 4. Spaltenkoepfe schreiben
    For i = 0 To rs.Fields.Count - 1
        xlWB.Sheets(1).Cells(1, i + 1) = rs.Fields(i).Name
    Next i

    ' 5. Daten schreiben
    xlWB.Sheets(1).Cells(2, 1).CopyFromRecordset rs

    ' 6. Speichern
    xlWB.SaveAs strFilename

    ' 7. Aufraumen
    xlWB.Close
    xlApp.Quit
End Function
```

### Modul: mdlExcelExportMAEinzel

```vba
' MA-Einzelauswertung nach Excel
Function ExportMAEinzelauswertung(lngMA_ID As Long, dtVon As Date, dtBis As Date)
    ' Exportiert alle Einsaetze eines MA im Zeitraum
End Function
```

---

## 10. Modul-Verzeichnis (alphabetisch)

| Modul | Beschreibung |
|-------|--------------|
| mdl_AutoGeocode | Automatisches Geocoding |
| mdl_BatchGeocode | Massen-Geocoding |
| mdl_CONSEC_AutoUpdater | Versions-Pruefung |
| mdl_CONSEC_Divers1 | Allgemeine Hilfsfunktionen |
| mdl_CONSEC_Excel | Excel-Automation |
| mdl_CreateReport | Bericht-Erstellung |
| mdl_Debug | Debug-Funktionen |
| mdl_Diagnose | System-Diagnose |
| mdl_DP_Create | Dienstplan-Erstellung |
| mdl_Excel_Export | Excel-Export |
| mdl_Fix_Final | Reparatur-Funktionen |
| mdl_frm_MA_VA_Schnellauswahl_Code | Schnellauswahl-Logik |
| mdl_frm_OB_Objekt_Code | Objekt-Formular-Logik |
| mdl_GeoAdmin | Geo-Verwaltung |
| mdl_GeoDistanz | Entfernungsberechnung |
| mdl_GeoFormFunctions | Geo-UI-Funktionen |
| mdl_Geocoding | Geocoding-API |
| mdl_Maintainance | Wartungsfunktionen |
| mdl_Menu_Neu | Ribbon-Steuerung |
| mdl_N_MA_Import | MA-Import |
| mdl_N_MA_WordTemplates | Word-Vorlagen |
| mdl_N_ObjektFilter | Objekt-Filter |
| mdl_N_PositionslistenExport | Positionslisten |
| mdl_N_PositionslistenImport | Positionslisten-Import |
| mdl_N_ZeitHeader | Zeit-Kopfzeilen |
| mdl_ObjektlistenImport | Objektlisten-Import |
| mdl_Prepare_Hauptformular | Formular-Initialisierung |
| mdl_Query_Creator | Dynamische Queries |
| mdl_Rechnungsschreibung | Rechnungserstellung |
| mdl_Restore_Subforms | Subform-Wiederherstellung |
| mdl_Ribbon_DaBaFenster_EinAus | Ribbon/Navigation |
| mdl_Setup_Monatsuebersicht | Monats-Setup |
| mdl_TempFormat | Temp-Formatierung |
| mdl_TempFormCreator | Temp-Formulare |
| mdl_TestAuto | Test-Automatisierung |
| mdl_Universal_Filter | Filter-Funktionen |
| mdlAutoexec | Autostart |
| mdlClipboard | Zwischenablage |
| mdlCreateTextFromMDB | DB-Dokumentation |
| mdlDatasheetSettings | Datenblatt-Einstellungen |
| mdlExcelExportMAEinzel | MA-Excel-Export |
| mdlFensterposition | Fenster-Positionierung |
| mdlFestplatteSnr | Hardware-Info |
| mdlGetTimeZone | Zeitzone |
| mdlNavigationsschaltflaechen | Navigation |
| mdlOutlook_HTML_Serienemail_SAP | E-Mail-Versand |
| mdlProtokoll | Protokollierung |
| mdlRecreateDeleteQuery | Query-Management |
| mdlRegistryRead | Registry-Zugriff |
| mdlSaveScreenToFile | Screenshot |
| mdlSonstiges1-4 | Diverses |
| mdlStartDoc | Dokument-Oeffnung |
| mdlsysinfo | System-Info |
| mdlUnitConversion | Einheiten-Umrechnung |
| mdlWaehrungsumrechnung | Waehrung |
| zmd_Const | Konstanten |
| zmd_Funktionen | Basis-Funktionen |
| zmd_MD5 | MD5-Hash |
| zmd_Registry | Registry |
| zmd_Whatsapp | WhatsApp-Integration |

---

*Dokumentation erstellt: 2026-01-08*
*Basierend auf: VBA-Module aus 01_VBA\modules\*
