# zfrm_MA_Stunden_Lexware

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | zfrm_MA_Stunden_Lexware |
| **Datensatzquelle** | SELECT tbl_MA_Mitarbeiterstamm.* FROM tbl_MA_Mitarbeiterstamm;  |
| **Datenquellentyp** | SQL |
| **Default View** | SingleForm |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Ja |
| **Navigation Buttons** | Nein |

## Controls


### ComboBoxen (Auswahllisten)

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------|
| cboMA | - | 2464 / 690 | 2676 x 300 | 0 |
| cboZeitraum | - | 6878 / 915 | 2685 x 315 | 1 |
| cboAnstArt | - | 2490 / 1080 | 2685 x 315 | 6 |

### Buttons (Schaltflaechen)

| Name | Caption | Position (L/T) | Groesse (W/H) | Events |
|------|---------|----------------|---------------|--------|
| btnImport | Zeitkonten Importieren | 17956 / 127 | 2166 x 568 | OnClick: [Event Procedure] |
| btnExport | Lexware Importdatei erstellen | 17956 / 802 | 2136 x 568 | OnClick: [Event Procedure] |
| btnAbgleich | Abgleich  | 25398 / 0 | 1986 x 283 | OnClick: [Event Procedure] |
| btnZKMini | Einsätze übertragen MJ | 12690 / 800 | 2316 x 568 | OnClick: [Event Procedure] |
| btnZKFest | Einsätze übertragen FA | 12690 / 120 | 2316 x 568 | OnClick: [Event Procedure] |
| btnZKeinzel | Einsätze übertragen einzeln | 10148 / 113 | 2316 x 568 | OnClick: [Event Procedure] |
| btnImporteinzel | Zeitkonto Importieren einzeln | 10148 / 793 | 2316 x 568 | OnClick: [Event Procedure] |
| btnExportDiff | Export Differenzreport | 20535 / 450 | 2256 x 568 | OnClick: [Event Procedure] |
| btnZKMiniAbrech | Einsätze übertragen MJ Abrechnung | 15298 / 800 | 2316 x 568 | OnClick: [Event Procedure] |
| btnZKFestAbrech | Einsätze übertragen FA Abrechnung | 15298 / 120 | 2316 x 568 | OnClick: [Event Procedure] |
### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------||
| Bezeichnungsfeld10 | 60 / 60 | 6645 x 450 | 0 (Schwarz) |
| ID_Bezeichnungsfeld | 220 / 680 | 1680 x 285 | 0 (Schwarz) |
| Bezeichnungsfeld366 | 5895 / 915 | 1800 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld368 | 6405 / 510 | 420 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld370 | 8100 / 510 | 300 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld39 | 225 / 1083 | 2385 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld22 | 396 / 3004 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld24 | 396 / 3401 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld26 | 680 / 4081 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld28 | 396 / 3798 | 1725 x 315 | 8355711 (Grau) |

### Subforms (Unterformulare)

| Name | Source Object | Position (L/T) | Groesse (W/H) |
|------|---------------|----------------|---------------|
| Sub_MA_Stunden | - | 325 / 601 | 22686 x 10191 |
| sub_Abgleich | - | 325 / 601 | 22686 x 10206 |
| sub_Importfehler | - | 325 / 601 | 22686 x 10206 |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------||
| AU_von | - | 6945 / 510 | 1063 x 315 | 2 |
| AU_bis | - | 8445 / 510 | 1155 x 315 | 3 |
| Anstellungsart_ID | Anstellungsart_ID | 2097 / 3004 | 1701 x 300 | 0 |
| Text23 | Anstellungsart_ID | 2097 / 3401 | 1701 x 300 | 1 |
| Text25 | Anstellungsart_ID | 2381 / 4081 | 1701 x 300 | 2 |
| Text27 | Anstellungsart_ID | 2097 / 3798 | 1701 x 300 | 3 |

### Unknown (123)s

| Name | Caption | Position (L/T) | Groesse (W/H) |
|------|---------|----------------|---------------|
| RegLex | - | 165 / 60 | 22920 x 10875 |

### Unknown (124)s

| Name | Caption | Position (L/T) | Groesse (W/H) |
|------|---------|----------------|---------------|
| Importierte Stunden | Importierte Daten | 240 / 525 | 22771 x 10335 |
| Abgleich | Stundenvergleich | 240 / 525 | 22771 x 10335 |
| Importfehler | - | 240 / 525 | 22771 x 10335 |

## Events

### Formular-Events
- OnOpen: [Event Procedure]
- OnLoad: Keine
- OnClose: Keine
- OnCurrent: Keine
- BeforeUpdate: Keine
- AfterUpdate: Keine
- OnActivate: Keine
- OnDeactivate: Keine

## VBA-Code

```vba
Option Compare Database



Private Sub AU_bis_BeforeUpdate(Cancel As Integer)

    Call filtern
    
End Sub


Private Sub AU_von_BeforeUpdate(Cancel As Integer)

    Call filtern
    
End Sub


'Stundenabgleich
Private Sub btnAbgleich_Click()

    Me.Abgleich.SetFocus
    
End Sub


'Lexware Importdatei erstellen
Private Sub btnExport_Click()

Dim SQL         As String
Dim WHERE       As String
Dim QRY         As String
Dim pfad        As String
Dim fileName    As String

    pfad = PfadPlanungAktuell & "A  - Lexware Datenträger\3 - Lex Import\"

    If IsNull(Me.AU_von) Then
    
        MsgBox "Bitte Zeitraum auswählen", vbCritical
               
    Else
        WHERE = Me.Sub_MA_Stunden.Form.filter
        SQL = "SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert_korr " & _
            "FROM [zqry_MA_Stunden] WHERE " & WHERE
        SQL = Replace(SQL, "[zsub_MA_Stunden].", "")
        
        'SQL = "SELECT Jahr, Monat, Personalnummer, Lohnartnummer, Wert " & _
            "FROM [ztbl_Stunden_Lexware] WHERE [Jahr] = " & Year(Me.AU_von) & " AND [Monat] = " & Month(Me.AU_von) & " AND Personalnummer <> 0;"
        
        QRY = "temp"
        
        If QueryExists(QRY) Then DoCmd.DeleteObject acQuery, QRY
        
        Set db = CurrentDb
        Set qdf = db.CreateQueryDef(QRY, SQL)
         
        fileName = pfad & "Lexware_Import.txt"
        DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE", QRY, fileName
        'DoCmd.TransferText acExportDelim, "Export_TXT_LEX", QRY, PfadPlanungAktuell & "A  - Lexware Datenträger\Lexware_Import.txt"
        
        'Export mit Namen
        SQL = "SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert_korr, Stundensatz, Währung, Name " & _
        "FROM [zqry_MA_Stunden] WHERE " & WHERE
        SQL = Replace(SQL, "[zsub_MA_Stunden].", "")
    
        
        If QueryExists(QRY) Then DoCmd.DeleteObject acQuery, QRY
        
        Set db = CurrentDb
        Set qdf = db.CreateQueryDef(QRY, SQL)
        
        fileName = pfad & "Lexware_Import_mit_Namen.txt"
        'DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE_NAME", qry, PfadPlanungAktuell & "A  - Lexware Datenträger\Lexware_Import_mit_Namen.txt"
        'DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE_FULL", qry, PfadPlanungAktuell & "A  - Lexware Datenträger\Lexware_Import_mit_Namen.txt"
        DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE_FULL_SPALTEN", QRY, fileName
        
        MsgBox "Importdatei wurde erstellt"
        
    End If
    
End Sub

'Export Differenzreport
Private Sub btnExportDiff_Click()

Dim qdf     As QueryDef
Dim Datei   As String
Dim Jahr    As Integer
Dim Monat   As Integer
Dim oeffnen As Boolean
Dim old_sql As String

On Error GoTo Err

    If IsNull(Me.AU_von) Then
    
        MsgBox "Bitte Zeitraum auswählen", vbCritical
               
    Else
    
        'Set qdf = CurrentDb.QueryDefs("zqry_MA_Stunden_Differenz")
        Jahr = Year(Me.AU_von)
        Monat = Month(Me.AU_von)
        Datei = PfadPlanungAktuell & "Differenzen_Lohnabrechnung_" & Jahr & "-" & Monat & ".xlsx"
        
        '1:
        'qdf.SQL = "SELECT zqry_MA_Stunden_Differenz_prepare.*, [Stunden_ZK_abger]-[Stunden_ZK_ges] AS Differenz FROM zqry_MA_Stunden_Differenz_prepare" & _
            " WHERE ((([Stunden_ZK_abger]-[Stunden_ZK_ges])<>0) AND ((zqry_MA_Stunden_Differenz_prepare.Jahr)=" & Jahr & ") AND ((zqry_MA_Stunden_Differenz_prepare.Monat)=" & Monat & "));"
    
        'qdf.sql = "SELECT zqry_MA_Stunden_Differenz_prepare.Jahr, zqry_MA_Stunden_Differenz_prepare.Monat, zqry_MA_Stunden_Differenz_prepare.Name," & _
            '" zqry_MA_Stunden_Differenz_prepare.Anstellungsart_ID AS [FA/MJ], zqry_MA_Stunden_Differenz_prepare.Stunden_Consys AS Consys," & _
            '" zqry_MA_Stunden_Differenz_prepare.Stunden_ZK_ges AS ZK_aktuell, zqry_MA_Stunden_Differenz_prepare.Stunden_ZK_abger AS ZK_abger," & _
            '" [Stunden_ZK_abger]-[Stunden_ZK_ges] AS Differenz FROM zqry_MA_Stunden_Differenz_prepare" & _
            '" WHERE ((([Stunden_ZK_abger]-[Stunden_ZK_ges])<>0) AND ((zqry_MA_Stunden_Differenz_prepare.Jahr)=" & Jahr & ") AND ((zqry_MA_Stunden_Differenz_prepare.Monat)=" & Monat & "));"
        
        
        'DoCmd.TransferSpreadsheet acExport, 10, "zqry_MA_Stunden_Differenz", Datei, True
        
        '2:
        'qdf.sql = Left(Me.sub_Abgleich.Form.RecordSource, Len(Me.sub_Abgleich.Form.RecordSource) - 2) & " WHERE " & Me.sub_Abgleich.Form.filter
        'CurrentDb.QueryDefs.Refresh
        'DoCmd.TransferSpreadsheet acExport, 10, "zqry_MA_Stunden_Differenz", Datei, True
        
        '3:
        'ExportFormToExcel Datei, Me.sub_Abgleich.Form
        
        'MsgBox "Datei:" & vbCrLf & Datei & vbCrLf & "wurde erstellt"
        
        If MsgBox("Datei:" & vbCrLf & Datei & vbCrLf & "wird erstellt - direkt öffnen?", vbYesNo) = vbYes Then
            oeffnen = True
        Else
            oeffnen = False
        End If
        
        Set qdf = CurrentDb.QueryDefs("zqry_MA_Stunden_Abgleich_tmp")
        old_sql = qdf.SQL
        qdf.SQL = Replace(qdf.SQL, ";", "") & " AND Differenz <> 0"
        DoCmd.OutputTo acForm, Me.sub_Abgleich.Form.Name, acFormatXLSX, Datei, oeffnen
        qdf.SQL = old_sql
        
    End If
    
Ende:
    Exit Sub
Err:
    MsgBox "Fehler! - ist die Datei geöffnet?", vbCritical
    Resume Ende
End Sub

'Zeitkonten importieren
Private Sub btnImport_Click()

Dim Jahr  As Integer
Dim Monat As Integer

    'monat = InputBox("Welcher Monat soll importiert werden?")
    Monat = Mid(Me.AU_von, 4, 2)
    Jahr = Year(Now)
    
    If Monat > 12 Or Monat = 0 Then GoTo Ende
    
    Call import_Zeitkonten(Monat, Jahr)
    
    Me.Sub_MA_Stunden.Requery
    Me.sub_Abgleich.Requery
    Me.sub_Importfehler.Requery
    
    
Ende:
End Sub


'Einzelnes Zeitkonto Importieren
Private Sub btnImporteinzel_Click()

Dim Jahr    As Integer
Dim Monat   As Integer
Dim DateiZK As String
Dim MA_ID   As Integer
Dim Name    As String
Dim xlApp   As Object
Dim xlWB    As Object

On Error GoTo Err

    Monat = Mid(Me.AU_von, 4, 2)
    Jahr = Year(Now)
    
    If Monat > 12 Or Monat = 0 Then GoTo Ende
    
    Select Case Me.RegLex.Value
        Case 0
            Name = Me.Sub_MA_Stunden.Form.Controls("Name")
            MA_ID = Me.Sub_MA_Stunden.Form.Controls("ID")
        Case 1
            Name = Me.sub_Abgleich.Form.Controls("Name")
            MA_ID = Me.sub_Abgleich.Form.Controls("ID")
    End Select
    
    'Datei Zeitkonto ermitteln
    DateiZK = ZK_Datei_ermitteln(MA_ID)
    
    'Exit, wenn Zeitkonto nicht gefunden
    If DateiZK = "" Then Err.Raise 76, , "Excel-Datei Zeitkonto " & Name & " nicht gefunden!"
    
    Me.btnZKeinzel.Enabled = False
    Me.btnAbgleich.Enabled = False
    Me.btnExport.Enabled = False
    Me.btnImport.Enabled = False
    Me.btnZKFest.Enabled = False
    Me.btnZKMini.Enabled = False
    Me.btnImporteinzel.Enabled = False
    
    'Excel starten
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    
    Set xlWB = xlApp.Workbooks.Open(DateiZK, False, False)
    
    Call ZK_Import_einzel(xlWB, Jahr, Monat, MA_ID)
    
    Me.Sub_MA_Stunden.Requery
    Me.sub_Abgleich.Requery
    Me.sub_Importfehler.Requery
    
    Me.btnZKeinzel.Enabled = True
    Me.btnAbgleich.Enabled = True
    Me.btnExport.Enabled = True
    Me.btnImport.Enabled = True
    Me.btnZKFest.Enabled = True
    Me.btnZKMini.Enabled = True
    Me.btnImporteinzel.Enabled = True
    
Ende:
On Error Resume Next
    xlWB.Close False
    xlApp.Quit
    Set xlWB = Nothing
    Set xlApp = Nothing
    Me.sub_Abgleich.Form.Requery
    Me.sub_Importfehler.Form.Requery
    Me.Sub_MA_Stunden.Form.Requery
    Exit Sub
Err:
    MsgBox Err.description
    Resume Ende
End Sub

'Selektiertes Zeitkonto fortschreiben
Private Sub btnZKeinzel_Click()

Dim Name    As String
Dim MA_ID   As Integer
Dim von     As Date
Dim bis     As Date

    Select Case Me.RegLex.Value
        Case 0
            Name = Me.Sub_MA_Stunden.Form.Controls("Name")
            MA_ID = Me.Sub_MA_Stunden.Form.Controls("ID")
        Case 1
            Name = Me.sub_Abgleich.Form.Controls("Name")
            MA_ID = Me.sub_Abgleich.Form.Controls("ID")
    End Select
    
    von = Me.AU_von
    bis = Me.AU_bis
    
    If Name = "" Then Exit Sub
   ' If MsgBox("Einsätze von  " & Name & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "in das Zeitkonto übertragen?", vbYesNoCancel) <> vbYes Then Exit Sub
    
    Me.btnZKeinzel.Enabled = False
    Me.btnAbgleich.Enabled = False
    Me.btnExport.Enabled = False
    Me.btnImport.Enabled = False
    Me.btnZKFest.Enabled = False
    Me.btnZKMini.Enabled = False
    Me.btnImporteinzel.Enabled = False
    
    rc = "Einzelsatz: " & ZK_Daten_uebertragen(MA_ID, von, bis, True)
    CurrentDb.Execute "INSERT INTO [ztbl_ZK_Log] VALUES (" & DatumUhrzeitSQL(Now()) & ", '" & Environ("UserName") & "', '" & rc & "');"
    
    Me.btnZKeinzel.Enabled = True
    Me.btnAbgleich.Enabled = True
    Me.btnExport.Enabled = True
    Me.btnImport.Enabled = True
    Me.btnZKFest.Enabled = True
    Me.btnZKMini.Enabled = True
    Me.btnImporteinzel.Enabled = True
    'MsgBox "Einsätze wurden in Zeitkonto " & Name & " übertragen"

On Error Resume Next
    Me.sub_Abgleich.Form.Requery
    Me.sub_Importfehler.Form.Requery
    Me.Sub_MA_Stunden.Form.Requery
    
End Sub


'Zeitkonten Festangestellte fortschreiben
Private Sub btnZKFest_Click()

    Call fa_uebertragen(False)
    
End Sub


'Zeitkonten Festangestellte fortschreiben Abrechnung
Private Sub btnZKFestAbrech_Click()

    Call fa_uebertragen(True)
    
End Sub


'Zeitkonten Minijobber fortschreiben
Private Sub btnZKMini_Click()

    Call mj_uebertragen(False)
    
End Sub


'Zeitkonten Minijobber fortschreiben Abrechnung
Private Sub btnZKMiniAbrech_Click()

    Call mj_uebertragen(True)
    
End Sub


Private Sub cboAnstArt_AfterUpdate()

    Me.cboMA = Null
    Call filtern
    
End Sub


Private Sub cboMA_BeforeUpdate(Cancel As Integer)

    Me.cboAnstArt = Null
    Call filtern

End Sub


Private Sub cboZeitraum_AfterUpdate()

Dim dtvon As Date
Dim dtbis As Date

    Call StdZeitraum_Von_Bis(Me!cboZeitraum, dtvon, dtbis)
    Me.AU_von = dtvon
    Me.AU_bis = dtbis
    Call filtern
    
End Sub


Function filtern()

Dim filter      As String
Dim qryAbgleich As String
Dim qryTmp      As String
Dim qdfTmp      As QueryDef
Dim SQL         As String

    'Falls auswertung aus fe kommen soll
    'refresh_zuoplanfe
    
    qryAbgleich = "zqry_MA_Stunden_Abgleich"
    qryTmp = qryAbgleich & "_tmp"
    
    Select Case True
        Case Not IsNull(Me.cboMA)
            filter = "ID = " & Me.cboMA.Column(0)
        Case Not IsNull(Me.cboAnstArt)
            If Me.cboAnstArt.Column(0) = 13 Then 'Fest + Mini + Midi
                filter = "( Anstellungsart_ID = 3 OR Anstellungsart_ID = 5 OR Anstellungsart_ID = 4)"
            Else
                filter = "Anstellungsart_ID = " & Me.cboAnstArt.Column(0)
            End If
            
    End Select
    
    
    Select Case True
        Case Not IsNull(Me.AU_von) And Not IsNull(Me.AU_bis)
            If filter <> "" Then filter = filter & " AND "
            filter = filter & "Datum BETWEEN " & DatumSQL(Me.AU_von) & " AND " & DatumSQL(Me.AU_bis)
        Case Not IsNull(Me.AU_von)
            If filter <> "" Then filter = filter & " AND "
            filter = filter & "Datum > " & DatumSQL(Me.AU_von)
        Case Not IsNull(Me.AU_bis)
            If filter <> "" Then filter = filter & " AND "
            filter = filter & "Datum < " & DatumSQL(Me.AU_bis)
    End Select
    
    ' Beim Abgleich muss wegen dem Export des Formulars die Datensatzquelle geändert werden!!!
    If filter <> "" Then
        Me.Sub_MA_Stunden.Form.filter = filter
        Me.Sub_MA_Stunden.Form.FilterOn = True
        
        'Me.sub_Abgleich.Form.filter = filter
        'Me.sub_Abgleich.Form.FilterOn = True
        
        SQL = "SELECT * FROM " & qryAbgleich & " WHERE " & filter
        
    Else
        SQL = "SELECT * FROM " & qryAbgleich
        
    End If
    
    If QueryExists(qryTmp) Then
        Set qdfTmp = CurrentDb.QueryDefs(qryTmp)
        qdfTmp.SQL = SQL
    Else
        Set qdfTmp = CurrentDb.CreateQueryDef(qryTmp, SQL)
    End If
    
    Me.sub_Abgleich.Form.RecordSource = qryTmp
    
    
End Function



Private Sub Form_Open(Cancel As Integer)

    Me.cboMA = Null
    Me.cboAnstArt.Value = 5
    Call cboZeitraum_AfterUpdate
    
End Sub


'Summe Stunden gesamt für Abgleich
Function fSumme_Stunden_ges(PersNr As Integer, Jahr As Integer, Monat As Integer) As Double

On Error Resume Next

    Select Case CInt(Me.cboZeitraum)
        Case 8, 9, 13, 14
            fSumme_Stunden_ges = TSum("Wert", "ztbl_Stunden_Lexware", "Personalnummer = " & PersNr & _
                " AND Lohnartnummer = 99999" & " AND Jahr = " & Jahr & " AND Monat = " & Monat)
        Case 11, 12
            fSumme_Stunden_ges = TSum("Wert", "ztbl_Stunden_Lexware", "Personalnummer = " & PersNr & _
                " AND Lohnartnummer = 99999" & " AND Jahr = " & Jahr)
    End Select

End Function


'Summe Stunden abgerechnet für Abgleich
Function fSumme_Stunden_abger(PersNr As Integer, Jahr As Integer, Monat As Integer) As Double

On Error Resume Next

    Select Case CInt(Me.cboZeitraum)
        Case 8, 9, 13, 14
            fSumme_Stunden_abger = TSum("Wert", "ztbl_Stunden_Lexware", "Personalnummer = " & PersNr & _
                " AND Lohnartnummer = 88888" & " AND Jahr = " & Jahr & " AND Monat = " & Monat)
        Case 11, 12
            fSumme_Stunden_abger = TSum("Wert", "ztbl_Stunden_Lexware", "Personalnummer = " & PersNr & _
                " AND Lohnartnummer = 88888" & " AND Jahr = " & Jahr)
    End Select

End Function

'Betrag ausgezahlt laut Zeitkonto
Function fZKausgezahlt(PersNr As Integer, Jahr As Integer, Monat As Integer) As Double

On Error Resume Next

    Select Case CInt(Me.cboZeitraum)
        Case 8, 9, 13, 14
            fZKausgezahlt = TSum("Wert", "ztbl_Stunden_Lexware", "Personalnummer = " & PersNr & _
                " AND Lohnartnummer = 77777" & " AND Jahr = " & Jahr & " AND Monat = " & Monat)
        Case 11, 12
            fZKausgezahlt = TSum("Wert", "ztbl_Stunden_Lexware", "Personalnummer = " & PersNr & _
                " AND Lohnartnummer = 77777" & " AND Jahr = " & Jahr)
    End Select

End Function


'Summe Stunden Consys für Abgleich
Function fSumme_stunden_consys(MA_ID As Integer, Jahr As Integer, Monat As Integer) As Double

On Error Resume Next

    Select Case CInt(Me.cboZeitraum)
        Case 8, 9, 13, 14
            fSumme_stunden_consys = Round(TLookup("SummevonMA_Netto_Std2", "qry_MA_VA_Zuordnung_Stunden_Monat", _
            "MA_ID = " & MA_ID & " AND Jahr = " & Jahr & " AND Monat = " & Monat), 2)
        Case 11, 12
            fSumme_stunden_consys = Round(TLookup("SummevonMA_Netto_Std2", "qry_MA_VA_Zuordnung_Stunden_Monat", _
            "MA_ID = " & MA_ID & " AND Jahr = " & Jahr), 2)
    End Select

End Function



Function fa_uebertragen(abrechnung As Boolean)

Dim rs  As Recordset
Dim rc  As String
Dim von As Date
Dim bis As Date

    
    von = Me.AU_von
    bis = Me.AU_bis
    
    If abrechnung = True Then
        If MsgBox("Einsätze der Festangestellten zur Abrechnung  " & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "in die Zeitkonten übertragen ?", vbYesNoCancel) <> vbYes Then Exit Function
    Else
        If MsgBox("Einsätze der Festangestellten  " & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "in die Zeitkonten übertragen ?", vbYesNoCancel) <> vbYes Then Exit Function
    End If
    
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & MASTAMM & _
        " WHERE [IstAktiv] = TRUE AND [IstSubunternehmer] = FALSE AND (Anstellungsart_ID = 3 OR Anstellungsart_ID = 4) ORDER BY Nachname ASC;")
    rs.MoveLast
    rs.MoveFirst
    'Ladebalken starten
    Application.SysCmd acSysCmdInitMeter, "Einsätze Festangestellte werden übertragen ...", rs.RecordCount

    Do While Not rs.EOF
        rc = "Festangestellte: " & ZK_Daten_uebertragen(rs.fields("ID"), von, bis, , abrechnung)
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Log] VALUES (" & DatumUhrzeitSQL(Now()) & ", '" & Environ("UserName") & "', '" & rc & "');"
        rs.MoveNext
        'Ladebalken aktualisieren
        If rs.AbsolutePosition > 0 Then Application.SysCmd acSysCmdUpdateMeter, rs.AbsolutePosition
    Loop
    Set rs = Nothing
    
    'Ladebalken entfernen
    Application.SysCmd acSysCmdRemoveMeter
    
    Me.Sub_MA_Stunden.Requery
    Me.sub_Importfehler.Requery
    Me.sub_Abgleich.Requery
    
    If abrechnung = True Then
        MsgBox "Einsätze der Festangestellten wurden zur Abrechnung in die Zeitkonten übertragen!"
    Else
        MsgBox "Einsätze der Festangestellten wurden in die Zeitkonten übertragen!"
    End If
    
    
    
End Function



Function mj_uebertragen(abrechnung As Boolean)

Dim rs  As Recordset
Dim rc  As String
Dim von As Date
Dim bis As Date

    
    von = Me.AU_von
    bis = Me.AU_bis
    
    If abrechnung = True Then
        If MsgBox("Einsätze der Minijobber zur Abrechnung  " & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "in die Zeitkonten übertragen ?", vbYesNoCancel) <> vbYes Then Exit Function
    Else
        If MsgBox("Einsätze der Minijobber  " & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "in die Zeitkonten übertragen ?", vbYesNoCancel) <> vbYes Then Exit Function
    End If
    
    
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & MASTAMM & _
        " WHERE [IstAktiv] = TRUE AND [IstSubunternehmer] = FALSE AND Anstellungsart_ID = 5 ORDER BY Nachname ASC;")
    rs.MoveLast
    rs.MoveFirst
    
    'Ladebalken starten
    Application.SysCmd acSysCmdInitMeter, "Einsätze Minijobber werden übertragen ...", rs.RecordCount
    
    Do While Not rs.EOF
        rc = "Minijobber: " & ZK_Daten_uebertragen(rs.fields("ID"), von, bis, , abrechnung)
        rc = Replace(rc, "'", "")
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Log] VALUES (" & DatumUhrzeitSQL(Now()) & ", '" & Environ("UserName") & "', '" & rc & "');"
        rs.MoveNext
        'Ladebalken aktualisieren
        If rs.AbsolutePosition > 0 Then Application.SysCmd acSysCmdUpdateMeter, rs.AbsolutePosition
    Loop
    Set rs = Nothing
    
    'Ladebalken entfernen
    Application.SysCmd acSysCmdRemoveMeter
    
    Me.Sub_MA_Stunden.Requery
    Me.sub_Importfehler.Requery
    Me.sub_Abgleich.Requery
    
    If abrechnung = True Then
        MsgBox "Einsätze der Minijobber wurden zur Abrechnung in die Zeitkonten übertragen!"
    Else
        MsgBox "Einsätze der Minijobber wurden in die Zeitkonten übertragen!"
    End If
    
    
    
End Function
```
