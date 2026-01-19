Attribute VB_Name = "mdl_ObjektlistenImport"
Public Function ImportObjektlisteAusExcel(strDateiPfad As String) As String
    Dim xlApp As Object
    Dim xlWb As Object
    Dim xlWs As Object
    Dim strOrt As String
    Dim strObjekt As String
    Dim strSheetName As String
    Dim lngObjektID As Long
    Dim lngRow As Long
    Dim lngSort As Long
    Dim strGruppe As String
    Dim strZusatztext As String
    Dim lngAnzahl As Long
    Dim iColGesamt As Integer
    Dim iColPosition As Integer
    Dim iColInfo As Integer
    
    On Error Resume Next
    
    Set xlApp = CreateObject("Excel.Application")
    If xlApp Is Nothing Then
        ImportObjektlisteAusExcel = "FEHLER: Excel konnte nicht gestartet werden"
        Exit Function
    End If
    
    xlApp.Visible = False
    xlApp.DisplayAlerts = False
    
    Set xlWb = xlApp.Workbooks.Open(strDateiPfad, False, True)
    If Err.Number <> 0 Or xlWb Is Nothing Then
        ImportObjektlisteAusExcel = "FEHLER beim Oeffnen: " & Err.description
        xlApp.Quit
        Exit Function
    End If
    
    ' Sheet finden
    strSheetName = ""
    For Each xlWs In xlWb.Worksheets
        If xlWs.Name = "Kalkulation" Then
            strSheetName = "Kalkulation"
            Exit For
        End If
    Next
    If strSheetName = "" Then strSheetName = xlWb.Worksheets(1).Name
    
    Set xlWs = xlWb.Worksheets(strSheetName)
    Err.clear
    
    ' Ort und Objekt aus Zeile 2 lesen
    strOrt = Trim(Nz(xlWs.Cells(2, 4).Value, ""))
    If strOrt = "" Or IsNumeric(strOrt) Then strOrt = Trim(Nz(xlWs.Cells(2, 3).Value, ""))
    
    strObjekt = Trim(Nz(xlWs.Cells(2, 5).Value, ""))
    If strObjekt = "" Or IsNumeric(strObjekt) Then strObjekt = Trim(Nz(xlWs.Cells(2, 4).Value, ""))
    
    If strOrt = "" Or strObjekt = "" Then
        ImportObjektlisteAusExcel = "FEHLER: Ort/Objekt nicht gefunden (Ort=" & strOrt & ", Objekt=" & strObjekt & ")"
        xlWb.Close False
        xlApp.Quit
        Exit Function
    End If
    
    ' Spalten ermitteln
    iColGesamt = 2
    iColPosition = 3
    iColInfo = 5
    
    If Trim(Nz(xlWs.Cells(4, 1).Value, "")) = "Nr." Or Trim(Nz(xlWs.Cells(4, 1).Value, "")) = "Nr" Then
        If Trim(Nz(xlWs.Cells(4, 2).Value, "")) = "Gesamt" Then
            iColGesamt = 2
            iColPosition = 3
            iColInfo = 4
        End If
    End If
    
    On Error GoTo ErrHandler
    
    ' Pruefen ob Objekt bereits existiert in tbl_OB_Objekt
    lngObjektID = Nz(DLookup("ID", "tbl_OB_Objekt", "Ort = '" & Replace(strOrt, "'", "''") & "' AND Objekt = '" & Replace(strObjekt, "'", "''") & "'"), 0)
    
    If lngObjektID > 0 Then
        ' Bestehende Positionen loeschen
        CurrentDb.Execute "DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngObjektID
    Else
        ' Neues Objekt erstellen
        CurrentDb.Execute "INSERT INTO tbl_OB_Objekt (Ort, Objekt, Erst_am) VALUES ('" & Replace(strOrt, "'", "''") & "', '" & Replace(strObjekt, "'", "''") & "', Now())"
        lngObjektID = DMax("ID", "tbl_OB_Objekt")
    End If
    
    ' Positionen einlesen ab Zeile 5
    lngRow = 5
    lngSort = 10
    
    Do While lngRow < 100
        strGruppe = Trim(Nz(xlWs.Cells(lngRow, iColPosition).Value, ""))
        
        If Len(strGruppe) = 0 Then Exit Do
        
        strZusatztext = Trim(Nz(xlWs.Cells(lngRow, iColInfo).Value, ""))
        If strZusatztext = "0" Then strZusatztext = ""
        
        lngAnzahl = 0
        On Error Resume Next
        lngAnzahl = CLng(xlWs.Cells(lngRow, iColGesamt).Value)
        On Error GoTo ErrHandler
        
        If Len(strGruppe) > 0 Then
            CurrentDb.Execute "INSERT INTO tbl_OB_Objekt_Positionen (OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Anzahl, TagesNr, TagesArt) VALUES (" & _
                lngObjektID & ", " & lngSort & ", '" & Replace(strGruppe, "'", "''") & "', '" & Replace(strZusatztext, "'", "''") & "', " & lngAnzahl & ", 1, 1)"
            lngSort = lngSort + 10
        End If
        
        lngRow = lngRow + 1
    Loop
    
    xlWb.Close False
    xlApp.Quit
    Set xlWs = Nothing
    Set xlWb = Nothing
    Set xlApp = Nothing
    
    ImportObjektlisteAusExcel = "OK: " & strOrt & " - " & strObjekt & " (" & ((lngSort - 10) / 10) & " Pos.)"
    Exit Function
    
ErrHandler:
    Dim strErr As String
    strErr = Err.description
    On Error Resume Next
    If Not xlWb Is Nothing Then xlWb.Close False
    If Not xlApp Is Nothing Then xlApp.Quit
    ImportObjektlisteAusExcel = "FEHLER: " & strErr
End Function

Public Sub ImportObjektlisteMitDialog()
    Dim fd As Object
    Dim strResult As String
    Dim vFile As Variant
    Dim strMsg As String
    
    Set fd = Application.FileDialog(3)
    
    With fd
        .title = "Objektliste(n) auswaehlen"
        .Filters.clear
        .Filters.Add "Excel-Dateien", "*.xls; *.xlsx; *.xlsm"
        .AllowMultiSelect = True
        .InitialFileName = "S:\CONSEC\CONSEC PLANUNG AKTUELL\"
        
        If .Show = -1 Then
            strMsg = ""
            For Each vFile In .SelectedItems
                strResult = ImportObjektlisteAusExcel(CStr(vFile))
                strMsg = strMsg & Dir(CStr(vFile)) & ": " & strResult & vbCrLf
            Next vFile
            MsgBox strMsg, vbInformation, "Import abgeschlossen"
        End If
    End With
    
    Set fd = Nothing
End Sub

