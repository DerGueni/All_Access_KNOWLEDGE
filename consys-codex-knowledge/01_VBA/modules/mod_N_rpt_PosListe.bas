Attribute VB_Name = "mod_N_rpt_PosListe"
' ============================================================================
' mdl_rpt_Positionsliste - Report-Generierung fuer Positionsliste
' ============================================================================

Public Sub OpenReport_Positionsliste(lngVA_Akt_Kopf_ID As Long)
    DoCmd.OpenReport "rpt_VA_Positionsliste", acViewPreview, , "VA_Akt_Objekt_Kopf_ID = " & lngVA_Akt_Kopf_ID
End Sub

Public Sub ExportPositionslisteExcel(lngVA_Akt_Kopf_ID As Long, Optional strFilePath As String = "")
    Dim xlApp As Object
    Dim xlWb As Object
    Dim xlWs As Object
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim i As Long
    Dim strAuftrag As String, strObjekt As String, strOrt As String
    Dim dtVADatum As Date
    
    On Error GoTo ErrHandler
    
    Set db = CurrentDb
    
    strSQL = "SELECT va.Auftrag, va.Objekt, va.Ort, vak.VADatum " & _
             "FROM tbl_VA_Akt_Objekt_Kopf AS vak " & _
             "INNER JOIN tbl_VA_Auftragstamm AS va ON vak.VA_ID = va.ID " & _
             "WHERE vak.ID = " & lngVA_Akt_Kopf_ID
    Set rs = db.OpenRecordset(strSQL)
    
    If rs.EOF Then
        MsgBox "Keine Daten gefunden!", vbExclamation
        Exit Sub
    End If
    
    strAuftrag = Nz(rs!Auftrag, "")
    strObjekt = Nz(rs!Objekt, "")
    strOrt = Nz(rs!Ort, "")
    dtVADatum = rs!VADatum
    rs.Close
    
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True
    Set xlWb = xlApp.Workbooks.Add
    Set xlWs = xlWb.Worksheets(1)
    
    xlWs.Cells(1, 1).Value = "CONSEC SECURITY NUERNBERG"
    xlWs.Cells(2, 1).Value = strAuftrag
    xlWs.Cells(2, 4).Value = strOrt
    xlWs.Cells(2, 5).Value = strObjekt
    xlWs.Cells(2, 6).Value = dtVADatum
    
    xlWs.Cells(4, 1).Value = "Nr."
    xlWs.Cells(4, 2).Value = "Anzahl"
    xlWs.Cells(4, 3).Value = "Position"
    xlWs.Cells(4, 4).Value = "Info"
    xlWs.Cells(4, 5).Value = "m/w"
    xlWs.Cells(4, 6).Value = "Beginn"
    xlWs.Cells(4, 7).Value = "Ende"
    xlWs.Cells(4, 8).Value = "Mitarbeiter"
    
    xlWs.Range("A4:H4").Font.Bold = True
    xlWs.Range("A4:H4").Interior.color = RGB(200, 200, 200)
    
    strSQL = "SELECT vap.Sort, vap.Anzahl, vap.Gruppe, vap.Zusatztext, vap.Geschlecht, " & _
             "vap.Abs_Beginn, vap.Abs_Ende, " & _
             "ma.MA_Nachname & ', ' & ma.MA_Vorname AS MA_Name " & _
             "FROM tbl_VA_Akt_Objekt_Pos AS vap " & _
             "LEFT JOIN tbl_MA_VA_Zuordnung AS zuo ON zuo.VAStart_ID = vap.ID " & _
             "LEFT JOIN tbl_MA_Mitarbeiterstamm AS ma ON zuo.MA_ID = ma.MA_ID " & _
             "WHERE vap.VA_Akt_Objekt_Kopf_ID = " & lngVA_Akt_Kopf_ID & " " & _
             "ORDER BY vap.Sort"
    
    Set rs = db.OpenRecordset(strSQL)
    
    i = 5
    Do While Not rs.EOF
        xlWs.Cells(i, 1).Value = rs!Sort
        xlWs.Cells(i, 2).Value = Nz(rs!Anzahl, 0)
        xlWs.Cells(i, 3).Value = Nz(rs!Gruppe, "")
        xlWs.Cells(i, 4).Value = Nz(rs!Zusatztext, "")
        xlWs.Cells(i, 5).Value = Nz(rs!Geschlecht, "")
        
        If Not IsNull(rs!Abs_Beginn) Then
            xlWs.Cells(i, 6).Value = Format(rs!Abs_Beginn, "HH:NN")
        End If
        If Not IsNull(rs!Abs_Ende) Then
            xlWs.Cells(i, 7).Value = Format(rs!Abs_Ende, "HH:NN")
        End If
        
        xlWs.Cells(i, 8).Value = Nz(rs!MA_Name, "")
        
        i = i + 1
        rs.MoveNext
    Loop
    
    rs.Close
    xlWs.Columns("A:H").AutoFit
    
    If Len(strFilePath) > 0 Then
        xlWb.SaveAs strFilePath
    End If
    
    Set rs = Nothing
    Set db = Nothing
    Set xlWs = Nothing
    Set xlWb = Nothing
    Set xlApp = Nothing
    
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
    On Error Resume Next
    rs.Close
    Set xlApp = Nothing
End Sub

Public Sub ZuordneMAzuPosition(lngVA_Akt_Pos_ID As Long, lngMA_ID As Long)
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim lngVA_ID As Long, lngVADatum_ID As Long
    Dim dtVADatum As Date
    Dim dtBeginn As Date, dtEnde As Date
    
    Set db = CurrentDb
    
    strSQL = "SELECT vak.VA_ID, vak.VADatum_ID, vak.VADatum, vap.Abs_Beginn, vap.Abs_Ende " & _
             "FROM tbl_VA_Akt_Objekt_Pos AS vap " & _
             "INNER JOIN tbl_VA_Akt_Objekt_Kopf AS vak ON vap.VA_Akt_Objekt_Kopf_ID = vak.ID " & _
             "WHERE vap.ID = " & lngVA_Akt_Pos_ID
    
    Set rs = db.OpenRecordset(strSQL)
    
    If rs.EOF Then
        MsgBox "Position nicht gefunden!", vbExclamation
        Exit Sub
    End If
    
    lngVA_ID = rs!VA_ID
    lngVADatum_ID = rs!VADatum_ID
    dtVADatum = rs!VADatum
    dtBeginn = Nz(rs!Abs_Beginn, dtVADatum)
    dtEnde = Nz(rs!Abs_Ende, DateAdd("h", 8, dtBeginn))
    rs.Close
    
    strSQL = "INSERT INTO tbl_MA_VA_Zuordnung " & _
             "(VA_ID, VADatum_ID, VAStart_ID, VADatum, MA_ID, MVA_Start, MVA_Ende, Erst_von, Erst_am) " & _
             "VALUES (" & lngVA_ID & ", " & lngVADatum_ID & ", " & lngVA_Akt_Pos_ID & ", " & _
             SQLDatum(dtVADatum) & ", " & lngMA_ID & ", " & _
             SQLDatum(dtBeginn) & ", " & SQLDatum(dtEnde) & ", " & _
             "'" & Environ("USERNAME") & "', Now())"
    
    db.Execute strSQL
    Set db = Nothing
End Sub
