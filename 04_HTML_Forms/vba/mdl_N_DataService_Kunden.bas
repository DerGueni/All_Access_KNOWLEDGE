Attribute VB_Name = "mdl_N_DataService_Kunden"
' =====================================================
' mdl_N_DataService_Kunden - Kunden DataService
' Korrigierte Spaltennamen für tbl_KD_Kundenstamm
' Version 2.0 - Stand: 30.12.2025
' =====================================================
Option Compare Database
Option Explicit

' =====================================================
' KUNDENSTAMM - VOLLSTÄNDIG
' =====================================================
Public Function LoadKundenstammComplete(KD_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Dim result As String
    
    Set db = CurrentDb
    
    result = "{"
    result = result & """stammdaten"":" & LoadKDStammdaten(db, KD_ID) & ","
    result = result & """ansprechpartner"":" & LoadKDAnsprechpartner(db, KD_ID) & ","
    result = result & """konditionen"":" & LoadKDKonditionen(db, KD_ID) & ","
    result = result & """auftraege"":" & LoadKDAuftraege(db, KD_ID) & ","
    result = result & """alleKunden"":" & LoadAlleKunden(db)
    result = result & "}"
    
    LoadKundenstammComplete = result
    Exit Function
ErrorHandler:
    LoadKundenstammComplete = "{""error"":""" & EscapeJson(Err.Description) & """}"
End Function

Private Function LoadKDStammdaten(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Id = " & KD_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadKDStammdaten = "{}"
        rs.Close
        Exit Function
    End If
    
    Dim result As String
    result = "{"
    result = result & """id"":" & rs!kun_Id & ","
    result = result & """firma"":""" & EscapeJson(Nz(rs!kun_Firma, "")) & ""","
    result = result & """bezeichnung"":""" & EscapeJson(Nz(rs!kun_Bezeichnung, "")) & ""","
    result = result & """kuerzel"":""" & EscapeJson(Nz(rs!kun_Matchcode, "")) & ""","
    result = result & """strasse"":""" & EscapeJson(Nz(rs!kun_Strasse, "")) & ""","
    result = result & """plz"":""" & EscapeJson(Nz(rs!kun_PLZ, "")) & ""","
    result = result & """ort"":""" & EscapeJson(Nz(rs!kun_Ort, "")) & ""","
    result = result & """land"":""" & EscapeJson(Nz(rs!kun_LKZ, "DE")) & ""","
    result = result & """telefon"":""" & EscapeJson(Nz(rs!kun_telefon, "")) & ""","
    result = result & """mobil"":""" & EscapeJson(Nz(rs!kun_mobil, "")) & ""","
    result = result & """email"":""" & EscapeJson(Nz(rs!kun_email, "")) & ""","
    result = result & """homepage"":""" & EscapeJson(Nz(rs!kun_URL, "")) & ""","
    result = result & """kreditinstitut"":""" & EscapeJson(Nz(rs!kun_kreditinstitut, "")) & ""","
    result = result & """iban"":""" & EscapeJson(Nz(rs!kun_iban, "")) & ""","
    result = result & """bic"":""" & EscapeJson(Nz(rs!kun_bic, "")) & ""","
    result = result & """ustIdNr"":""" & EscapeJson(Nz(rs!kun_ustidnr, "")) & ""","
    result = result & """zahlbed"":""" & EscapeJson(Nz(rs!kun_Zahlbed, "")) & ""","
    result = result & """istAktiv"":" & IIf(Nz(rs!kun_IstAktiv, True), "true", "false") & ","
    result = result & """erstVon"":""" & EscapeJson(Nz(rs!Erst_von, "")) & ""","
    result = result & """erstAm"":""" & FormatDatumKD(rs!Erst_am) & ""","
    result = result & """aendVon"":""" & EscapeJson(Nz(rs!Aend_von, "")) & ""","
    result = result & """aendAm"":""" & FormatDatumKD(rs!Aend_am) & """"
    result = result & "}"
    
    rs.Close
    LoadKDStammdaten = result
End Function

Private Function LoadKDAnsprechpartner(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    On Error Resume Next
    sql = "SELECT * FROM tbl_KD_Ansprechpartner WHERE Kun_ID = " & KD_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Err.Number <> 0 Then
        LoadKDAnsprechpartner = "[]"
        Exit Function
    End If
    On Error GoTo 0
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """name"":""" & EscapeJson(Nz(rs!AP_Name, "")) & ""","
        result = result & """funktion"":""" & EscapeJson(Nz(rs!AP_Funktion, "")) & ""","
        result = result & """telefon"":""" & EscapeJson(Nz(rs!AP_Telefon, "")) & ""","
        result = result & """email"":""" & EscapeJson(Nz(rs!AP_eMail, "")) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadKDAnsprechpartner = result
End Function

Private Function LoadKDKonditionen(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    On Error Resume Next
    sql = "SELECT * FROM tbl_KD_Standardpreise WHERE Kun_ID = " & KD_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If Err.Number <> 0 Then
        LoadKDKonditionen = "[]"
        Exit Function
    End If
    On Error GoTo 0
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """bezeichnung"":""" & EscapeJson(Nz(rs!Bezeichnung, "")) & ""","
        result = result & """preis"":" & Replace(Nz(rs!Preis, 0), ",", ".")
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadKDKonditionen = result
End Function

Private Function LoadKDAuftraege(db As DAO.Database, KD_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, Auftrag, Ort, Dat_VA_Von FROM tbl_VA_Auftragstamm WHERE Veranstalter_ID = " & KD_ID & " ORDER BY Dat_VA_Von DESC"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """datum"":""" & FormatDatumKD(rs!Dat_VA_Von) & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadKDAuftraege = result
End Function

Private Function LoadAlleKunden(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT kun_Id, kun_Firma, kun_Ort, kun_IstAktiv FROM tbl_KD_Kundenstamm ORDER BY kun_Firma"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!kun_Id & ","
        result = result & """firma"":""" & EscapeJson(Nz(rs!kun_Firma, "")) & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!kun_Ort, "")) & ""","
        result = result & """aktiv"":" & IIf(Nz(rs!kun_IstAktiv, True), "true", "false")
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadAlleKunden = result
End Function

' =====================================================
' HILFSFUNKTIONEN
' =====================================================
Private Function EscapeJson(s As String) As String
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCr, "")
    s = Replace(s, vbLf, "")
    s = Replace(s, vbTab, " ")
    EscapeJson = s
End Function

Private Function FormatDatumKD(d As Variant) As String
    If IsNull(d) Or IsEmpty(d) Then
        FormatDatumKD = ""
    Else
        FormatDatumKD = Format(d, "dd.mm.yyyy")
    End If
End Function
