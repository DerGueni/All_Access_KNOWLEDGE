Option Compare Database
Option Explicit


' Hauptfunktion: liest qry_WA_Reminder_Kandidaten und schreibt nach ztbl_WA_Reminder
Public Sub WA_Reminder_OffeneAnfragen()
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    
    Set db = CurrentDb
    sql = "SELECT * FROM qry_WA_Reminder_Kandidaten"
    
    On Error GoTo Err_Handler
    Set rs = db.OpenRecordset(sql, dbOpenDynaset)
    
    If rs.EOF Then
        MsgBox "Keine Einträge für WhatsApp-Reminder gefunden.", vbInformation
        GoTo Cleanup
    End If
    
    Do While Not rs.EOF
        Call WA_Reminder_EintragAnlegen( _
            Nz(rs!MA_ID, 0), _
            GetFieldSafe(rs, "VAStart_ID"), _
            GetFieldSafe(rs, "VADatum"), _
            GetFieldSafe(rs, "VA_Bezeichnung"), _
            GetFieldSafe(rs, "VA_Start"), _
            GetFieldSafe(rs, "VA_Ende"), _
            GetFieldSafe(rs, "VA_Ort"), _
            Nz(rs!Vorname, ""), _
            Nz(rs!WhatsAppNr, "") _
        )
        rs.MoveNext
    Loop
    
    MsgBox "WA-Reminder erstellt.", vbInformation
    
Cleanup:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Sub
    
Err_Handler:
    MsgBox "Fehler in WA_Reminder_OffeneAnfragen: " & Err.Number & " - " & Err.description, vbCritical
    Resume Cleanup
End Sub

Private Function GetFieldSafe(ByVal rs As DAO.Recordset, ByVal fieldName As String) As Variant
    On Error GoTo Err_Handler
    GetFieldSafe = rs.fields(fieldName).Value
    Exit Function
Err_Handler:
    GetFieldSafe = Null
End Function

Private Sub WA_Reminder_EintragAnlegen( _
    ByVal MA_ID As Long, _
    ByVal VAStart_ID As Variant, _
    ByVal VADatum As Variant, _
    ByVal VABez As Variant, _
    ByVal vaStart As Variant, _
    ByVal vaEnde As Variant, _
    ByVal VAOrt As Variant, _
    ByVal Vorname As String, _
    ByVal WhatsAppNr As String _
)
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim msgText As String
    Dim payloadJa As String
    Dim payloadNein As String
    
    If IsNull(WhatsAppNr) Or WhatsAppNr = "" Then Exit Sub
    
    msgText = " Erinnerung an offene Auftragsanfragen" & vbCrLf & vbCrLf & _
              "Hallo " & Vorname & "," & vbCrLf & vbCrLf & _
              "du hast noch offene Auftragsanfragen." & vbCrLf & vbCrLf & _
              "Einsatz:" & vbCrLf & _
              " Auftrag: " & Nz(VABez, "") & vbCrLf & _
              " Datum: " & IIf(Not IsNull(VADatum), Format(VADatum, "dd.mm.yyyy"), "") & vbCrLf & _
              " Zeit: " & IIf(Not IsNull(vaStart), Format(vaStart, "hh:nn"), "") & _
                         "  " & IIf(Not IsNull(vaEnde), Format(vaEnde, "hh:nn"), "") & vbCrLf & _
              " Ort: " & Nz(VAOrt, "") & vbCrLf & vbCrLf & _
              "Bitte wähle eine Option."
    
    payloadJa = "CONFIRM|" & CStr(Nz(VAStart_ID, 0)) & "|" & CStr(MA_ID)
    payloadNein = "DECLINE|" & CStr(Nz(VAStart_ID, 0)) & "|" & CStr(MA_ID)
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("ztbl_WA_Reminder", dbOpenDynaset)
    
    rs.AddNew
    rs!MA_ID = MA_ID
    rs!VAStart_ID = Nz(VAStart_ID, 0)
    rs!VADatum = VADatum
    rs!VA_Bezeichnung = Nz(VABez, "")
    rs!VA_Start = vaStart
    rs!VA_Ende = vaEnde
    rs!VA_Ort = Nz(VAOrt, "")
    rs!WhatsAppNr = WhatsAppNr
    rs!Vorname = Vorname
    rs!msgText = msgText
    rs!payloadJa = payloadJa
    rs!payloadNein = payloadNein
    rs!Status = "zu senden"
    rs!Erst_von = VBA.Environ("USERNAME")
    rs!Erst_am = Now()
    rs.update

    rs.Close
End Sub