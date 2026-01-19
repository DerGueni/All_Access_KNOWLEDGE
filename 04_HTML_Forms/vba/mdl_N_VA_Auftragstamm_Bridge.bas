' =====================================================
' mdl_N_VA_Auftragstamm_Bridge
' Backend-Anbindung für HTML-Auftragsverwaltung
' Version 1.0 - 29.12.2025
' =====================================================
Option Compare Database
Option Explicit

' =====================================================
' KONFIGURATION
' =====================================================
Private Const EXE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe"
Private Const HTML_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_N_VA_Auftragstamm.html"

' =====================================================
' HAUPTFUNKTION: Auftragsverwaltung öffnen
' =====================================================
Public Sub OpenAuftragsverwaltungHTML(Optional FilterDatum As Date = 0)
    Dim jsonData As String
    Dim dataFile As String
    Dim cmd As String
    
    ' Standard: Heute
    If FilterDatum = 0 Then FilterDatum = Date
    
    ' Alle Daten laden
    jsonData = LoadAuftragsverwaltungData(FilterDatum)
    
    ' JSON in Datei speichern (zu groß für Kommandozeile)
    dataFile = Environ("TEMP") & "\consys_auftraege.json"
    WriteTextFile dataFile, jsonData
    
    ' Prüfe ob EXE existiert
    If Dir(EXE_PATH) = "" Then
        MsgBox "WebView2 App nicht gefunden:" & vbCrLf & EXE_PATH, vbCritical, "Fehler"
        Exit Sub
    End If
    
    ' Starte die Anwendung
    cmd = """" & EXE_PATH & """ " & _
          "-html """ & HTML_PATH & """ " & _
          "-title ""Auftragsverwaltung"" " & _
          "-width 1550 -height 950 " & _
          "-datafile """ & dataFile & """"
    
    Shell cmd, vbNormalFocus
    Debug.Print "Auftragsverwaltung gestartet mit Daten ab " & Format(FilterDatum, "dd.mm.yyyy")
End Sub

' =====================================================
' DATEN LADEN: Alle Daten für die Auftragsverwaltung
' =====================================================
Public Function LoadAuftragsverwaltungData(FilterDatum As Date) As String
    Dim result As String
    
    result = "{"
    
    ' 1. Aufträge ab Datum
    result = result & """auftraege"":" & LoadAuftraege(FilterDatum) & ","
    
    ' 2. Stammdaten für Dropdowns
    result = result & """orte"":" & LoadOrte() & ","
    result = result & """objekte"":" & LoadObjekte() & ","
    result = result & """kleidung"":" & LoadKleidung() & ","
    result = result & """kunden"":" & LoadKunden() & ","
    result = result & """mitarbeiter"":" & LoadMitarbeiter() & ","
    result = result & """status"":" & LoadStatus() & ","
    
    ' 3. Meta-Daten
    result = result & """filterDatum"":""" & Format(FilterDatum, "dd.mm.yyyy") & ""","
    result = result & """timestamp"":""" & Format(Now, "yyyy-mm-dd hh:nn:ss") & """"
    
    result = result & "}"
    
    LoadAuftragsverwaltungData = result
End Function

' =====================================================
' AUFTRÄGE LADEN
' =====================================================
Public Function LoadAuftraege(FilterDatum As Date) As String
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    Set db = CurrentDb
    
    ' Aufträge mit Soll/Ist aus tbl_VA_Start
    sql = "SELECT a.ID, a.Auftrag, a.Dat_VA_Von, a.Dat_VA_Bis, a.Ort, a.Objekt, " & _
          "a.Treffpunkt, a.Dienstkleidung, a.Ansprechpartner, a.Veranst_Status_ID, " & _
          "a.Veranstalter_ID, a.Fahrtkosten, a.Autosend_EL, " & _
          "k.Kun_Firma AS Auftraggeber, " & _
          "(SELECT Sum(s.MA_Anzahl) FROM tbl_VA_Start s WHERE s.VA_ID = a.ID) AS Soll, " & _
          "(SELECT Sum(s.MA_Anzahl_Ist) FROM tbl_VA_Start s WHERE s.VA_ID = a.ID) AS Ist " & _
          "FROM tbl_VA_Auftragstamm a " & _
          "LEFT JOIN tbl_KD_Kunde k ON a.Veranstalter_ID = k.KD_ID " & _
          "WHERE a.Dat_VA_Von >= #" & Format(FilterDatum, "yyyy-mm-dd") & "# " & _
          "ORDER BY a.Dat_VA_Von"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        
        result = result & "{"
        result = result & """id"":" & Nz(rs!ID, 0) & ","
        result = result & """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ""","
        result = result & """datVon"":""" & Format(Nz(rs!Dat_VA_Von, Date), "dd.mm.yyyy") & ""","
        result = result & """datBis"":""" & Format(Nz(rs!Dat_VA_Bis, rs!Dat_VA_Von), "dd.mm.yyyy") & ""","
        result = result & """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & ""","
        result = result & """objekt"":""" & EscapeJson(Nz(rs!Objekt, "")) & ""","
        result = result & """treffpunkt"":""" & EscapeJson(Nz(rs!Treffpunkt, "")) & ""","
        result = result & """kleidung"":""" & EscapeJson(Nz(rs!Dienstkleidung, "")) & ""","
        result = result & """ansprech"":""" & EscapeJson(Nz(rs!Ansprechpartner, "")) & ""","
        result = result & """statusId"":" & Nz(rs!Veranst_Status_ID, 0) & ","
        result = result & """kundId"":" & Nz(rs!Veranstalter_ID, 0) & ","
        result = result & """auftraggeber"":""" & EscapeJson(Nz(rs!Auftraggeber, "")) & ""","
        result = result & """fahrtkosten"":" & Replace(CStr(Nz(rs!Fahrtkosten, 0)), ",", ".") & ","
        result = result & """autosend"":" & IIf(Nz(rs!Autosend_EL, False), "true", "false") & ","
        result = result & """soll"":" & Nz(rs!Soll, 0) & ","
        result = result & """ist"":" & Nz(rs!Ist, 0) & ","
        result = result & """wochentag"":""" & GetWochentag(rs!Dat_VA_Von) & """"
        result = result & "}"
        
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadAuftraege = result
    Exit Function
    
ErrorHandler:
    LoadAuftraege = "[]"
    Debug.Print "Fehler LoadAuftraege: " & Err.Description
End Function

' =====================================================
' SCHICHTEN FÜR EINEN AUFTRAG LADEN
' =====================================================
Public Function LoadSchichten(VA_ID As Long) As String
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    Set db = CurrentDb
    
    sql = "SELECT ID, VA_ID, VADatum, VA_Start, VA_Ende, MA_Anzahl, MA_Anzahl_Ist, Bemerkungen " & _
          "FROM tbl_VA_Start " & _
          "WHERE VA_ID = " & VA_ID & " " & _
          "ORDER BY VADatum, VA_Start"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """vaId"":" & rs!VA_ID & ","
        result = result & """datum"":""" & Format(Nz(rs!VADatum, Date), "dd.mm.yyyy") & ""","
        result = result & """von"":""" & Format(Nz(rs!VA_Start, "00:00"), "hh:nn") & ""","
        result = result & """bis"":""" & Format(Nz(rs!VA_Ende, "00:00"), "hh:nn") & ""","
        result = result & """anzahl"":" & Nz(rs!MA_Anzahl, 0) & ","
        result = result & """anzahlIst"":" & Nz(rs!MA_Anzahl_Ist, 0) & ","
        result = result & """bemerkungen"":""" & EscapeJson(Nz(rs!Bemerkungen, "")) & """"
        result = result & "}"
        
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadSchichten = result
    Exit Function
    
ErrorHandler:
    LoadSchichten = "[]"
    Debug.Print "Fehler LoadSchichten: " & Err.Description
End Function

' =====================================================
' ZUORDNUNGEN FÜR EINEN AUFTRAG LADEN
' =====================================================
Public Function LoadZuordnungen(VA_ID As Long) As String
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    Set db = CurrentDb
    
    sql = "SELECT z.ID, z.VA_ID, z.MA_ID, z.ZU_Beginn, z.ZU_Ende, z.ZU_Bemerkungen, " & _
          "z.Zu_Info, z.ZU_PKW, z.ZU_Antwort, " & _
          "m.MA_Nachname, m.MA_Vorname " & _
          "FROM tbl_MA_VA_Zuordnung z " & _
          "LEFT JOIN tbl_MA_Mitarbeiter m ON z.MA_ID = m.MA_ID " & _
          "WHERE z.VA_ID = " & VA_ID & " " & _
          "ORDER BY z.ZU_Beginn, m.MA_Nachname"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """vaId"":" & rs!VA_ID & ","
        result = result & """maId"":" & Nz(rs!MA_ID, 0) & ","
        result = result & """maName"":""" & EscapeJson(Nz(rs!MA_Nachname, "") & ", " & Nz(rs!MA_Vorname, "")) & ""","
        result = result & """von"":""" & Format(Nz(rs!ZU_Beginn, "00:00"), "hh:nn") & ""","
        result = result & """bis"":""" & Format(Nz(rs!ZU_Ende, "00:00"), "hh:nn") & ""","
        result = result & """bemerkungen"":""" & EscapeJson(Nz(rs!ZU_Bemerkungen, "")) & ""","
        result = result & """info"":" & IIf(Nz(rs!Zu_Info, False), "true", "false") & ","
        result = result & """pkw"":" & Replace(CStr(Nz(rs!ZU_PKW, 0)), ",", ".") & ","
        result = result & """antwort"":" & IIf(Nz(rs!ZU_Antwort, False), "true", "false")
        result = result & "}"
        
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    
    LoadZuordnungen = result
    Exit Function
    
ErrorHandler:
    LoadZuordnungen = "[]"
    Debug.Print "Fehler LoadZuordnungen: " & Err.Description
End Function

' =====================================================
' STAMMDATEN FÜR DROPDOWNS
' =====================================================
Private Function LoadOrte() As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim result As String, first As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT DISTINCT Ort FROM tbl_VA_Auftragstamm WHERE Ort IS NOT NULL AND Ort <> '' ORDER BY Ort", dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & """" & EscapeJson(rs!Ort) & """"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadOrte = result
    Exit Function
ErrorHandler:
    LoadOrte = "[]"
End Function

Private Function LoadObjekte() As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim result As String, first As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT DISTINCT Objekt FROM tbl_VA_Auftragstamm WHERE Objekt IS NOT NULL AND Objekt <> '' ORDER BY Objekt", dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & """" & EscapeJson(rs!Objekt) & """"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadObjekte = result
    Exit Function
ErrorHandler:
    LoadObjekte = "[]"
End Function

Private Function LoadKleidung() As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim result As String, first As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT DISTINCT Dienstkleidung FROM tbl_VA_Auftragstamm WHERE Dienstkleidung IS NOT NULL AND Dienstkleidung <> '' ORDER BY Dienstkleidung", dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & """" & EscapeJson(rs!Dienstkleidung) & """"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadKleidung = result
    Exit Function
ErrorHandler:
    LoadKleidung = "[]"
End Function

Private Function LoadKunden() As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim result As String, first As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT KD_ID, Kun_Firma FROM tbl_KD_Kunde WHERE Kun_Aktiv = True ORDER BY Kun_Firma", dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!KD_ID & ",""firma"":""" & EscapeJson(Nz(rs!Kun_Firma, "")) & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadKunden = result
    Exit Function
ErrorHandler:
    LoadKunden = "[]"
End Function

Private Function LoadMitarbeiter() As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim result As String, first As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT MA_ID, MA_Nachname, MA_Vorname FROM tbl_MA_Mitarbeiter WHERE MA_aktiv = True ORDER BY MA_Nachname, MA_Vorname", dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!MA_ID & ",""name"":""" & EscapeJson(Nz(rs!MA_Nachname, "") & ", " & Nz(rs!MA_Vorname, "")) & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadMitarbeiter = result
    Exit Function
ErrorHandler:
    LoadMitarbeiter = "[]"
End Function

Private Function LoadStatus() As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database, rs As DAO.Recordset
    Dim result As String, first As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT ID, Status FROM tbl_VA_Status ORDER BY ID", dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!ID & ",""name"":""" & EscapeJson(Nz(rs!Status, "")) & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadStatus = result
    Exit Function
ErrorHandler:
    LoadStatus = "[]"
End Function

' =====================================================
' HILFSFUNKTIONEN
' =====================================================
Private Function EscapeJson(s As String) As String
    Dim result As String
    result = s
    result = Replace(result, "\", "\\")
    result = Replace(result, """", "\""")
    result = Replace(result, vbCrLf, "\n")
    result = Replace(result, vbCr, "\n")
    result = Replace(result, vbLf, "\n")
    result = Replace(result, vbTab, "\t")
    EscapeJson = result
End Function

Private Function GetWochentag(d As Variant) As String
    If IsNull(d) Then
        GetWochentag = ""
        Exit Function
    End If
    
    Dim wt As String
    Select Case Weekday(d, vbMonday)
        Case 1: wt = "Mo"
        Case 2: wt = "Di"
        Case 3: wt = "Mi"
        Case 4: wt = "Do"
        Case 5: wt = "Fr"
        Case 6: wt = "Sa"
        Case 7: wt = "So"
    End Select
    
    GetWochentag = wt & ". " & Format(d, "dd.mm.yy")
End Function

Private Sub WriteTextFile(filePath As String, content As String)
    Dim fNum As Integer
    fNum = FreeFile
    Open filePath For Output As #fNum
    Print #fNum, content
    Close #fNum
End Sub

' =====================================================
' TEST-FUNKTION
' =====================================================
Public Sub TestLoadAuftraege()
    Dim json As String
    json = LoadAuftraege(Date)
    Debug.Print Left(json, 2000)
    Debug.Print "..."
    Debug.Print "Länge: " & Len(json) & " Zeichen"
End Sub
