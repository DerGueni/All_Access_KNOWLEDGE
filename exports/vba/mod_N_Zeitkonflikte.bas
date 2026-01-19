Attribute VB_Name = "mod_N_Zeitkonflikte"

Option Compare Database
Option Explicit

Public Sub AutoPruefeZeitkonflikte()
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strMsg As String
    Dim intAntwort As Integer
    Dim intZaehler As Integer
    
    On Error GoTo ErrHandler
    
    Set db = CurrentDb()
    
    strSQL = "SELECT " & _
             "m.Vorname & ' ' & m.Nachname AS Mitarbeiter, " & _
             "DateValue(z1.MVA_Start) AS Datum, " & _
             "a1.Auftrag AS Auftrag1, " & _
             "Format(z1.MVA_Start, 'hh:nn') & '-' & Format(z1.MVA_Ende, 'hh:nn') AS Zeit1, " & _
             "a2.Auftrag AS Auftrag2, " & _
             "Format(z2.MVA_Start, 'hh:nn') & '-' & Format(z2.MVA_Ende, 'hh:nn') AS Zeit2, " & _
             "IIf(z1.VA_ID = z2.VA_ID, 'DUPLIKAT', 'KONFLIKT') AS Typ " & _
             "FROM (((tbl_MA_VA_Zuordnung AS z1 " & _
             "INNER JOIN tbl_MA_VA_Zuordnung AS z2 ON z1.MA_ID = z2.MA_ID) " & _
             "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON z1.MA_ID = m.ID) " & _
             "LEFT JOIN tbl_VA_Auftragstamm AS a1 ON z1.VA_ID = a1.ID) " & _
             "LEFT JOIN tbl_VA_Auftragstamm AS a2 ON z2.VA_ID = a2.ID " & _
             "WHERE z1.ID < z2.ID " & _
             "AND DateValue(z1.MVA_Start) = DateValue(z2.MVA_Start) " & _
             "AND z1.MVA_Start < z2.MVA_Ende " & _
             "AND z1.MVA_Ende > z2.MVA_Start " & _
             "AND m.Anstellungsart_ID IN (3, 5) " & _
             "AND DateValue(z1.MVA_Start) >= Date() " & _
             "ORDER BY DateValue(z1.MVA_Start)"
    
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
    
    If rs.EOF Then
        Set rs = Nothing
        Set db = Nothing
        Exit Sub
    End If
    
    intZaehler = 0
    Do While Not rs.EOF
        intZaehler = intZaehler + 1
        
        strMsg = rs!Typ & " erkannt!" & vbCrLf & vbCrLf
        strMsg = strMsg & "Mitarbeiter: " & rs!Mitarbeiter & vbCrLf
        strMsg = strMsg & "Datum: " & Format(rs!Datum, "dd.mm.yyyy") & vbCrLf & vbCrLf
        strMsg = strMsg & "Auftrag 1: " & Nz(rs!Auftrag1, "") & vbCrLf
        strMsg = strMsg & "Zeit 1: " & rs!Zeit1 & vbCrLf & vbCrLf
        strMsg = strMsg & "Auftrag 2: " & Nz(rs!Auftrag2, "") & vbCrLf
        strMsg = strMsg & "Zeit 2: " & rs!Zeit2
        
        intAntwort = MsgBox(strMsg, vbOKOnly + vbExclamation, rs!Typ & " " & intZaehler)
        
        rs.MoveNext
    Loop
    
    If intZaehler > 0 Then
        intAntwort = MsgBox("Insgesamt " & intZaehler & " Problem(e) gefunden." & vbCrLf & vbCrLf & _
                           "Gesamtuebersicht anzeigen?", _
                           vbYesNo + vbQuestion, "Planungsprobleme")
        
        If intAntwort = vbYes Then
            DoCmd.OpenQuery "qry_N_Zeitkonflikte_Anzeige"
        End If
    End If
    
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Sub

ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set db = Nothing
End Sub




