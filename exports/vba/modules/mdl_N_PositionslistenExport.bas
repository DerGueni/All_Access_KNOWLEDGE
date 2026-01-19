Attribute VB_Name = "mdl_N_PositionslistenExport"
Option Compare Database
Option Explicit

' Excel-Export fuer Positionslisten

Public Sub ExportPositionslisteToExcel(lngObjektID As Long)
    On Error GoTo ErrHandler
    
    If lngObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    Dim xlApp As Object, xlWb As Object, xlWs As Object
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim strSQL As String, strObjektNr As String
    Dim lngRow As Long
    Dim strFileName As String
    Dim fd As Object
    
    ' Objektnummer holen
    strObjektNr = Nz(DLookup("ObjektNr", "tbl_OB_Objekt", "ID = " & lngObjektID), "Objekt_" & lngObjektID)
    
    ' Speichern-Dialog
    Set fd = Application.FileDialog(2) ' msoFileDialogSaveAs
    fd.title = "Positionsliste speichern als"
    fd.InitialFileName = "Positionsliste_" & strObjektNr & "_" & Format(Now, "yyyymmdd") & ".xlsx"
    
    If fd.Show <> -1 Then Exit Sub
    strFileName = fd.SelectedItems(1)
    If Right(LCase(strFileName), 5) <> ".xlsx" Then strFileName = strFileName & ".xlsx"
    
    ' Excel starten
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    xlApp.DisplayAlerts = False
    Set xlWb = xlApp.Workbooks.Add
    Set xlWs = xlWb.Sheets(1)
    xlWs.Name = "Positionen"
    
    ' Header schreiben
    xlWs.Cells(1, 1).Value = "PosNr"
    xlWs.Cells(1, 2).Value = "Gruppe"
    xlWs.Cells(1, 3).Value = "Zusatztext"
    xlWs.Cells(1, 4).Value = Nz(DLookup("Zeit1_Label", "tbl_OB_Objekt", "ID = " & lngObjektID), "Zeit1")
    xlWs.Cells(1, 5).Value = Nz(DLookup("Zeit2_Label", "tbl_OB_Objekt", "ID = " & lngObjektID), "Zeit2")
    xlWs.Cells(1, 6).Value = Nz(DLookup("Zeit3_Label", "tbl_OB_Objekt", "ID = " & lngObjektID), "Zeit3")
    xlWs.Cells(1, 7).Value = Nz(DLookup("Zeit4_Label", "tbl_OB_Objekt", "ID = " & lngObjektID), "Zeit4")
    xlWs.Cells(1, 8).Value = "Gesamt"
    
    ' Header formatieren
    xlWs.Range("A1:H1").Font.Bold = True
    xlWs.Range("A1:H1").Interior.color = RGB(200, 200, 200)
    
    ' Daten holen
    Set db = CurrentDb
    strSQL = "SELECT PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4 " & _
             "FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngObjektID & _
             " ORDER BY Sort, PosNr"
    Set rs = db.OpenRecordset(strSQL)
    
    lngRow = 2
    Do While Not rs.EOF
        xlWs.Cells(lngRow, 1).Value = Nz(rs!PosNr, lngRow - 1)
        xlWs.Cells(lngRow, 2).Value = Nz(rs!Gruppe, "")
        xlWs.Cells(lngRow, 3).Value = Nz(rs!Zusatztext, "")
        xlWs.Cells(lngRow, 4).Value = Nz(rs!Zeit1, 0)
        xlWs.Cells(lngRow, 5).Value = Nz(rs!Zeit2, 0)
        xlWs.Cells(lngRow, 6).Value = Nz(rs!Zeit3, 0)
        xlWs.Cells(lngRow, 7).Value = Nz(rs!Zeit4, 0)
        xlWs.Cells(lngRow, 8).Formula = "=SUM(D" & lngRow & ":G" & lngRow & ")"
        lngRow = lngRow + 1
        rs.MoveNext
    Loop
    rs.Close
    
    ' Summenzeile
    If lngRow > 2 Then
        xlWs.Cells(lngRow, 3).Value = "SUMME:"
        xlWs.Cells(lngRow, 3).Font.Bold = True
        xlWs.Cells(lngRow, 4).Formula = "=SUM(D2:D" & (lngRow - 1) & ")"
        xlWs.Cells(lngRow, 5).Formula = "=SUM(E2:E" & (lngRow - 1) & ")"
        xlWs.Cells(lngRow, 6).Formula = "=SUM(F2:F" & (lngRow - 1) & ")"
        xlWs.Cells(lngRow, 7).Formula = "=SUM(G2:G" & (lngRow - 1) & ")"
        xlWs.Cells(lngRow, 8).Formula = "=SUM(H2:H" & (lngRow - 1) & ")"
        xlWs.Range("A" & lngRow & ":H" & lngRow).Font.Bold = True
        xlWs.Range("A" & lngRow & ":H" & lngRow).Interior.color = RGB(220, 220, 220)
    End If
    
    ' Spaltenbreite anpassen
    xlWs.Columns("A:H").AutoFit
    
    ' Speichern
    xlWb.SaveAs strFileName, 51 ' xlOpenXMLWorkbook
    xlWb.Close False
    xlApp.Quit
    
    Set rs = Nothing: Set db = Nothing
    Set xlWs = Nothing: Set xlWb = Nothing: Set xlApp = Nothing
    
    MsgBox "Positionsliste erfolgreich exportiert!" & vbCrLf & strFileName, vbInformation
    Exit Sub
    
ErrHandler:
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    If Not xlWb Is Nothing Then xlWb.Close False
    If Not xlApp Is Nothing Then xlApp.Quit
    MsgBox "Fehler beim Export: " & Err.description, vbCritical
End Sub

