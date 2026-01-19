VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Menuefuehrung1_20260609"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub Befehl22_Click()
DoCmd.OpenForm "frmTop_neue_Vorlagen"
End Sub

Private Sub Befehl24_Click()
DoCmd.OpenReport "rpt_monatsstunden", acViewPreview

End Sub

Private Sub Befehl26_Click()
DoCmd.OpenQuery "qry_lst_row_auftrag abfrage"
End Sub

Private Sub Befehl28_Click()

End Sub

Private Sub Befehl29_Click()
    DoCmd.OpenForm "zfrm_copy_to_mail"
End Sub

Private Sub Befehl37_Click()
DoCmd.OpenForm "frm_Lex_Aktiv"
End Sub

Private Sub btn_1_Click()
DoCmd.OpenReport "rpt_telefonliste", acViewPreview

End Sub

Private Sub btn_2_Click()
DoCmd.OpenForm "frm_kundenpreise"

End Sub

Private Sub btn_3_Click()
DoCmd.OpenForm "frmoff_outlook_aufrufen"
End Sub

Private Sub btn_4_click()
DoCmd.OpenReport "rpt_jahresuebersicht_mitarbeiter", acViewPreview

End Sub

Private Sub btn_Abwesenheiten_Click()

Dim Jahr As String

On Error GoTo Err

    Jahr = InputBox("Jahr:", "Zeitraum")
    If Jahr = "" Then
        DoCmd.OpenForm "frm_MA_Abwesenheiten_Urlaub_Gueni", acFormDS
    Else
        DoCmd.OpenForm "frm_MA_Abwesenheiten_krank_gueni_" & Jahr, acFormDS
    End If

Ende:
    Exit Sub
Err:
    MsgBox Err.Number & ": " & Err.description
    Resume Ende
End Sub

Private Sub btn_EmailVorlagen_Click()
DoCmd.Close
End Sub

Private Sub btn_mailvorlage_Click()
DoCmd.OpenForm "frm_ma_serien_email_vorlage"
End Sub

' Mitarbeiterstamm nach Excel
Private Sub btn_MAStamm_Excel_Click()
Dim Datei   As String
Dim oeffnen As Boolean
    'DoCmd.OpenQuery "qry_MA_Mitarbeiterstamm"
    
    Datei = PfadPlanungAktuell & "Mitarbeiterstamm_" & Left(Now(), 10) & ".xlsx"

    If MsgBox("Datei:" & vbCrLf & Datei & vbCrLf & "wird erstellt - direkt öffnen?", vbYesNo) = vbYes Then
        oeffnen = True
    Else
        oeffnen = False
    End If

    DoCmd.OutputTo acQuery, "qry_MA_Mitarbeiterstamm", acFormatXLSX, Datei, oeffnen
    
End Sub


Private Sub btn_menue2_close_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
DoCmd.Close
'DoCmd.Echo False
End Sub

Private Sub Btn_Personalvorlagen_Click()
DoCmd.Close
End Sub


'Auswertung Sub Stunden
Private Sub btn_stunden_sub_Click()
Dim strExcelPath As String

Dim objExcel As Object
    Dim objWorkbook As Object
    Dim objWorksheet As Object
    Dim strTabelle As String
    Dim lastRow As Long


    strExcelPath = PfadPlanungAktuell & "Stunden_Sub_" & Left(Now(), 10) & ".xlsx"
    DoCmd.TransferSpreadsheet acExport, acSpreadsheetTypeExcel12Xml, "zqry_MA_VA_ZUO_PLAN_SUB", strExcelPath, True
    'DoCmd.OpenQuery "zqry_MA_VA_ZUO_PLAN_SUB"
        ' Excel öffnen und Formatierungen anwenden
    On Error Resume Next
    Set objExcel = GetObject(, "Excel.Application") ' Prüfen, ob Excel läuft
    If objExcel Is Nothing Then
        Set objExcel = CreateObject("Excel.Application") ' Falls nicht, Excel starten
    End If
    On Error GoTo 0

    objExcel.Visible = True ' Excel sichtbar machen
    Set objWorkbook = objExcel.Workbooks.Open(strExcelPath)
    Set objWorksheet = objWorkbook.Sheets(1) ' Erstes Blatt auswählen

    ' Letzte Zeile ermitteln (Annahme: Spalte A hat durchgehend Werte)
    lastRow = objWorksheet.Cells(objWorksheet.rows.Count, 1).End(-4162).row ' -4162 = xlUp

    ' Spaltenbreiten automatisch anpassen
    objWorksheet.Cells.EntireColumn.AutoFit

    ' Spalte "VADatum" ins Datumsformat "TT.MM.JJ" setzen (Spaltenindex anpassen!)
    objWorksheet.Columns("B").NumberFormat = "DD.MM.YY" ' <-- Falls "VADatum" in Spalte A ist, anpassen falls nötig

    ' Spalten B, D, E zentrieren
    objWorksheet.Columns("B").HorizontalAlignment = -4108 ' xlCenter
    objWorksheet.Columns("D").HorizontalAlignment = -4108 ' xlCenter
    objWorksheet.Columns("E").HorizontalAlignment = -4108 ' xlCenter


    ' Spalten umbenennen (Überschriften ändern)
    objWorksheet.Cells(1, 2).Value = "Datum"  ' Spalte B
    objWorksheet.Cells(1, 4).Value = "Std"    ' Spalte D
    objWorksheet.Cells(1, 7).Value = "Anzahl" ' Spalte G

    ' Datei speichern (aber nicht schließen!)
    objWorkbook.Save

    ' Excel bleibt offen für den Benutzer
    MsgBox "Export abgeschlossen! Die Datei ist jetzt geöffnet.", vbInformation

    ' Objekte bereinigen (Excel bleibt geöffnet)
    Set objWorksheet = Nothing
    Set objWorkbook = Nothing
    Set objExcel = Nothing
    ' Datei speichern und schließen
'    objWorkbook.Save
'    objWorkbook.Close False
'    objExcel.Quit

    ' Objekte bereinigen
    Set objWorksheet = Nothing
    Set objWorkbook = Nothing
    Set objExcel = Nothing

    MsgBox "Export abgeschlossen!", vbInformation
End Sub


Private Sub btn_weitere_Masken_Click()
DoCmd.OpenForm "__frmHlpMenu_Weitere_Masken"
End Sub


Private Sub btnLetzterEinsatz_Click()
    'DoCmd.OpenForm "frm_Letzter_Einsatz_MA_Gueni", acFormDS
    DoCmd.OpenQuery "qry_MA_letzter _Einsatz_Gueni"
End Sub

'Lohnabrechnungen
Private Sub btnLohnabrech_Click()

    DoCmd.OpenForm "zfrm_Lohnabrechnungen"

End Sub

Private Sub btnLohnarten_Click()

    DoCmd.OpenForm "zfrm_ZK_Lohnarten_Zuschlag"
    
End Sub

'Fürth Namensliste
Private Sub btnNamensliste_Click()

Dim xlApp           As Object, xlWb As Object, xlWs As Object
Dim Datei           As String
Dim Veranstalter_ID As Long
Dim VA_ID           As Long
Dim frm             As String
Dim rs              As Recordset
Dim i               As Integer
Dim such            As String
Dim Nachname        As String
Dim Vorname         As String
Dim Bemerkung       As String

Const xlMaximized As Long = -4137&
Const xlNormal    As Long = -4143&
    
    
    Datei = PfadPlanungAktuell & "XY_Namensliste Fürth.xlsm"
    frm = "frm_VA_Auftragstamm"
    
    If fctIsFormOpen(frm) = False Then
        MsgBox frm & " nix offen!", vbCritical
        Exit Sub
    End If
    
    VA_ID = Forms(frm).Form.Controls("ID")
    Veranstalter_ID = Forms(frm).Form.Controls("Veranstalter_ID")
    
    If Veranstalter_ID <> 20737 Then
        MsgBox "Kunde " & Veranstalter_ID & " nix gut!"
        Exit Sub
    End If
     
    If FileExists(Datei) Then Kill Datei
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    xlApp.WindowState = xlMaximized
    Set xlWb = xlApp.Workbooks.Add
    Set xlWs = xlWb.Sheets(1)
    
    With xlWs
        .Range("A1") = "Vorname"
        .Range("B1") = "Nachname"
        .Range("C1") = "ePin"
        i = 2
        Set rs = Forms(frm).Form.Controls("sub_MA_VA_Zuordnung").Form.RecordsetClone
        rs.MoveFirst
        Do While Not rs.EOF
            Vorname = Nz(TLookup("Vorname", MASTAMM, "ID = " & rs.fields("MA_ID")), "")
            Nachname = Nz(TLookup("Nachname", MASTAMM, "ID = " & rs.fields("MA_ID")), "")
            Bemerkung = Nz(rs.fields("Bemerkungen"), "")
             Select Case Nachname & " " & Vorname
                Case "Sec Concept"
                    If Bemerkung <> "" Then Nachname = Left(Bemerkung, InStr(Bemerkung, " ") - 1)
                    If Bemerkung <> "" Then Vorname = Mid(Bemerkung, InStr(Bemerkung, " ") + 1, Len(Bemerkung) - InStr(Bemerkung, " "))
                    
                Case "KS Security"
                    If Bemerkung <> "" Then Nachname = Left(Bemerkung, InStr(Bemerkung, " ") - 1)
                    If Bemerkung <> "" Then Vorname = Mid(Bemerkung, InStr(Bemerkung, " ") + 1, Len(Bemerkung) - InStr(Bemerkung, " "))
                    
            End Select
            .Range("C" & i) = TLookup("Epin_DFB", MASTAMM, "ID = " & rs.fields("MA_ID"))
            If .Range("C" & i) = "" Then .Range("C" & i) = TLookup("Geb_Dat", MASTAMM, "ID = " & rs.fields("MA_ID"))
            .Range("A" & i) = Vorname
            .Range("B" & i) = Nachname
            
            i = i + 1
            rs.MoveNext
    
        Loop
        rs.Close
    End With
    
    xlWb.SaveAs Datei, 52 'xlOpenXMLWorkbookMacroEnabled
    xlWb.Close
    Set xlWb = xlApp.Workbooks.Open(Datei)
    
    such = "Mengengerüst_StadionFürth_*"
    Datei = Dir(PfadPlanungAktuell & "*" & such & "*")
    
    If Datei <> "" Then
        Set xlApp = CreateObject("Excel.Application")
        xlApp.Visible = True
        xlApp.WindowState = xlNormal
        Set xlWb = xlApp.Workbooks.Open(PfadPlanungAktuell & Datei)
        
    End If
    
    Set xlApp = Nothing
    Set xlWb = Nothing
    Set xlWs = Nothing
    Set rs = Nothing
    
End Sub

'FCN Meldeliste
Private Sub btnFCN_Meldeliste_Click()

Dim xlApp           As Object, xlWb As Object
Dim Vorlage         As String
Dim Dateiname       As String
Dim Veranstalter_ID As Long
Dim VA_ID           As Long
Dim frm             As String
Dim Soll            As Integer
Dim Ist             As Integer
Const xlMaximized As Long = -4137&
    
    Dateiname = "ZZ - Mitarbeiterliste 1.FCN VORLAGE.xlsm"
    Vorlage = PfadPlanungAktuell & Dateiname
    frm = "frm_VA_Auftragstamm"
    
    
    If fctIsFormOpen(frm) = False Then
        MsgBox frm & " nix offen!", vbCritical
        Exit Sub
    End If
    
    If FileExists(Vorlage) = False Then
        MsgBox "Nix Vorlage gefunden!", vbCritical
        Exit Sub
    End If
    
    VA_ID = Forms(frm).Form.Controls("ID")
    Veranstalter_ID = Forms(frm).Form.Controls("Veranstalter_ID")
    
    If Veranstalter_ID <> 20771 Then
        MsgBox "Kunde " & Veranstalter_ID & " nix gut!"
        Exit Sub
    End If
    
    Soll = TSum("Soll", "qry_lst_Row_Auftrag", "tbl_VA_Auftragstamm.ID = " & VA_ID)
    Ist = TSum("Ist", "qry_lst_Row_Auftrag", "tbl_VA_Auftragstamm.ID = " & VA_ID)
    
    If Soll > Ist Then
        MsgBox Soll - Ist & " Postitionen leer!"
        Exit Sub
    End If
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    xlApp.WindowState = xlMaximized
    Set xlWb = xlApp.Workbooks.Open(Vorlage, , True)
    xlWb.Sheets(2).Range("G1") = VA_ID
    xlApp.Run "'" & Dateiname & "'!btnAusfuellen"
    xlWb.Sheets(2).Range("G1") = ""
    
    Set xlApp = Nothing
    Set xlWb = Nothing
    
End Sub


' Kreuztabelle Stunden Mitarbeiter
Private Sub btnStundenMA_Click()

    DoCmd.OpenQuery "zqry_MA_VA_Stunden_Plan_Ist_aktJahr_Kreuztabelle"
    
End Sub


Private Sub Detailbereich_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
Forms!frm_menuefuehrung1.Visible = True
End Sub



Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
DoCmd.Close
End Sub

Private Sub Formularfuß_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
DoCmd.Close
End Sub

Private Sub lbl_Menue2_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
DoCmd.Close
End Sub
