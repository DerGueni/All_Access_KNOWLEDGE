Option Compare Database
Option Explicit

' Excel-Import fuer Positionslisten
' Erwartet Excel-Datei mit Spalten: PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4

Public Sub ImportPositionslisteFromExcel(strFilePath As String, lngObjektID As Long)
    On Error GoTo ErrHandler
    
    Dim xlApp As Object
    Dim xlWb As Object
    Dim xlWs As Object
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim lngRow As Long
    Dim lngLastRow As Long
    Dim lngImported As Long
    Dim strSQL As String
    
    ' Pruefe ob Objekt-ID gueltig
    If lngObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    ' Excel oeffnen
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    xlApp.DisplayAlerts = False
    
    Set xlWb = xlApp.Workbooks.Open(strFilePath)
    Set xlWs = xlWb.Sheets(1)
    
    ' Letzte Zeile finden
    lngLastRow = xlWs.Cells(xlWs.rows.Count, 1).End(-4162).row ' xlUp = -4162
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("tbl_OB_Objekt_Positionen", dbOpenDynaset)
    
    lngImported = 0
    
    ' Ab Zeile 2 (Zeile 1 = Header)
    For lngRow = 2 To lngLastRow
        ' Pruefe ob Zeile Daten enthaelt
        If Not IsEmpty(xlWs.Cells(lngRow, 1).Value) Then
            rs.AddNew
            rs!OB_Objekt_Kopf_ID = lngObjektID
            rs!PosNr = Nz(xlWs.Cells(lngRow, 1).Value, lngRow - 1)
            rs!Gruppe = Nz(xlWs.Cells(lngRow, 2).Value, "")
            rs!Zusatztext = Nz(xlWs.Cells(lngRow, 3).Value, "")
            rs!Zeit1 = Nz(xlWs.Cells(lngRow, 4).Value, 0)
            rs!Zeit2 = Nz(xlWs.Cells(lngRow, 5).Value, 0)
            rs!Zeit3 = Nz(xlWs.Cells(lngRow, 6).Value, 0)
            rs!Zeit4 = Nz(xlWs.Cells(lngRow, 7).Value, 0)
            rs!Sort = lngRow - 1
            rs.update
            lngImported = lngImported + 1
        End If
    Next lngRow
    
    rs.Close
    xlWb.Close False
    xlApp.Quit
    
    Set rs = Nothing
    Set db = Nothing
    Set xlWs = Nothing
    Set xlWb = Nothing
    Set xlApp = Nothing
    
    MsgBox lngImported & " Positionen erfolgreich importiert!", vbInformation
    Exit Sub
    
ErrHandler:
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    If Not xlWb Is Nothing Then xlWb.Close False
    If Not xlApp Is Nothing Then xlApp.Quit
    MsgBox "Fehler beim Import: " & Err.description, vbCritical
End Sub

Public Sub ImportPositionslisteDialog(lngObjektID As Long)
    On Error GoTo ErrHandler
    
    Dim fd As Object
    Dim strFile As String
    Dim intChoice As Integer
    
    If lngObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    ' Frage ob bestehende Positionen geloescht werden sollen
    intChoice = MsgBox("Sollen die bestehenden Positionen vor dem Import geloescht werden?" & vbCrLf & vbCrLf & _
        "Ja = Alle bestehenden Positionen loeschen" & vbCrLf & _
        "Nein = Neue Positionen hinzufuegen" & vbCrLf & _
        "Abbrechen = Import abbrechen", vbYesNoCancel + vbQuestion, "Positionsliste importieren")
    
    If intChoice = vbCancel Then Exit Sub
    
    If intChoice = vbYes Then
        ' Bestehende Positionen loeschen
        CurrentDb.Execute "DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngObjektID
    End If
    
    ' FileDialog oeffnen
    Set fd = Application.FileDialog(1) ' msoFileDialogFilePicker
    fd.title = "Excel-Positionsliste auswaehlen"
    fd.Filters.clear
    fd.Filters.Add "Excel-Dateien", "*.xlsx;*.xls"
    fd.AllowMultiSelect = False
    
    If fd.Show = -1 Then
        strFile = fd.SelectedItems(1)
        ImportPositionslisteFromExcel strFile, lngObjektID
    End If
    
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub