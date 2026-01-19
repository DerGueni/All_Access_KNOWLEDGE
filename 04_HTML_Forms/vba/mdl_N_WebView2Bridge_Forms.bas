Attribute VB_Name = "mdl_N_WebView2Bridge_Forms"
' =====================================================
' mdl_N_WebView2Bridge_Forms - DataService für Schnellauswahl & Dienstpläne
' Version 1.0 - Stand: 29.12.2025
' =====================================================
Option Compare Database
Option Explicit

Private Const HTML_BASE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"

' =====================================================
' SCHNELLAUSWAHL
' =====================================================
Public Sub OpenMitarbeiterSchnellauswahl(VA_ID As Long)
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE_PATH & "frm_N_MA_VA_Schnellauswahl.html"
    jsonData = LoadSchnellauswahlData(VA_ID)
    
    Call OpenWebViewForm(htmlPath, "Mitarbeiterauswahl", 1400, 900, jsonData)
End Sub

Public Function LoadSchnellauswahlData(VA_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Set db = CurrentDb
    
    Dim result As String
    result = "{"
    result = result & """auftrag"":" & LoadAuftragInfo(db, VA_ID) & ","
    result = result & """schichten"":" & LoadSchichten(db, VA_ID) & ","
    result = result & """mitarbeiter"":" & LoadVerfuegbareMitarbeiter(db, VA_ID) & ","
    result = result & """geplant"":" & LoadGeplanteMitarbeiter(db, VA_ID) & ","
    result = result & """parallele"":" & LoadParalleleEinsaetze(db, VA_ID)
    result = result & "}"
    
    LoadSchnellauswahlData = result
    Exit Function
ErrorHandler:
    LoadSchnellauswahlData = "{""error"":""" & Err.Description & """}"
End Function

Private Function LoadAuftragInfo(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    
    sql = "SELECT ID, Auftrag, Objekt, Ort, Dat_VA_Von FROM tbl_VA_Auftragstamm WHERE ID = " & VA_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadAuftragInfo = "{}"
    Else
        LoadAuftragInfo = "{""id"":" & rs!ID & "," & _
            """auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & """," & _
            """objekt"":""" & EscapeJson(Nz(rs!Objekt, "")) & """," & _
            """ort"":""" & EscapeJson(Nz(rs!Ort, "")) & """," & _
            """datVon"":""" & Format(rs!Dat_VA_Von, "dd.mm.yyyy") & """," & _
            """soll"":" & GetAuftragSoll(db, VA_ID) & "," & _
            """ist"":" & GetAuftragIst(db, VA_ID) & "}"
    End If
    rs.Close
End Function

Private Function LoadSchichten(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT ID, MA_Anzahl, DB_von, DB_bis FROM tbl_VA_Start WHERE VA_ID = " & VA_ID & " ORDER BY DB_von"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!ID & ",""soll"":" & Nz(rs!MA_Anzahl, 0) & _
            ",""ist"":0,""beginn"":""" & Format(rs!DB_von, "hh:nn") & _
            """,""ende"":""" & Format(rs!DB_bis, "hh:nn") & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadSchichten = result
End Function

Private Function LoadVerfuegbareMitarbeiter(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT MA_ID, MA_Nachname, MA_Vorname, MA_Ort, MA_Anstellungsart, MA_aktiv " & _
          "FROM tbl_MA_Mitarbeiterstamm WHERE MA_aktiv = True ORDER BY MA_Nachname"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!MA_ID & _
            ",""name"":""" & EscapeJson(rs!MA_Nachname & " " & Nz(rs!MA_Vorname, "")) & """" & _
            ",""nachname"":""" & EscapeJson(rs!MA_Nachname) & """" & _
            ",""vorname"":""" & EscapeJson(Nz(rs!MA_Vorname, "")) & """" & _
            ",""anstellung"":""" & Nz(rs!MA_Anstellungsart, "Minijobber") & """" & _
            ",""aktiv"":true,""verfuegbar"":true,""grund"":""""}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadVerfuegbareMitarbeiter = result
End Function

Private Function LoadGeplanteMitarbeiter(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT z.MA_ID, z.ZU_Beginn, z.ZU_Ende, m.MA_Nachname, m.MA_Vorname " & _
          "FROM tbl_MA_VA_Zuordnung AS z LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON z.MA_ID = m.MA_ID " & _
          "WHERE z.VA_ID = " & VA_ID & " AND z.MA_ID > 0 ORDER BY z.ZU_Lfd"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""maId"":" & rs!MA_ID & _
            ",""nachname"":""" & EscapeJson(Nz(rs!MA_Nachname, "")) & """" & _
            ",""vorname"":""" & EscapeJson(Nz(rs!MA_Vorname, "")) & """" & _
            ",""beginn"":""" & Format(Nz(rs!ZU_Beginn, ""), "hh:nn") & """" & _
            ",""ende"":""" & Format(Nz(rs!ZU_Ende, ""), "hh:nn") & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadGeplanteMitarbeiter = result
End Function

Private Function LoadParalleleEinsaetze(db As DAO.Database, VA_ID As Long) As String
    LoadParalleleEinsaetze = "[]"
End Function

' =====================================================
' DIENSTPLAN NACH MITARBEITER
' =====================================================
Public Sub OpenDienstplanMA(Optional startDatum As Date = 0)
    Dim htmlPath As String
    Dim jsonData As String
    
    If startDatum = 0 Then startDatum = Date
    htmlPath = HTML_BASE_PATH & "frm_N_DP_Dienstplan_MA.html"
    jsonData = LoadDienstplanMAData(startDatum, 7, "Festangestellte")
    
    Call OpenWebViewForm(htmlPath, "Dienstplanübersicht", 1400, 900, jsonData)
End Sub

Public Function LoadDienstplanMAData(startDatum As Date, anzahlTage As Integer, anstellung As String) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Set db = CurrentDb
    
    Dim result As String
    result = "{"
    result = result & """mitarbeiter"":" & LoadMitarbeiterFuerDienstplan(db, anstellung) & ","
    result = result & """einsaetze"":" & LoadEinsaetzeFuerZeitraum(db, startDatum, anzahlTage) & ","
    result = result & """abwesenheiten"":" & LoadAbwesenheitenFuerZeitraum(db, startDatum, anzahlTage)
    result = result & "}"
    
    LoadDienstplanMAData = result
    Exit Function
ErrorHandler:
    LoadDienstplanMAData = "{""error"":""" & Err.Description & """}"
End Function

Private Function LoadMitarbeiterFuerDienstplan(db As DAO.Database, anstellung As String) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT MA_ID, MA_Nachname, MA_Vorname FROM tbl_MA_Mitarbeiterstamm WHERE MA_aktiv = True"
    If anstellung = "Festangestellte" Then
        sql = sql & " AND MA_Anstellungsart = 'Festangestellter'"
    ElseIf anstellung = "Minijobber" Then
        sql = sql & " AND MA_Anstellungsart = 'Minijobber'"
    End If
    sql = sql & " ORDER BY MA_Nachname"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!MA_ID & ",""name"":""" & EscapeJson(rs!MA_Nachname & " " & Nz(rs!MA_Vorname, "")) & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadMitarbeiterFuerDienstplan = result
End Function

Private Function LoadEinsaetzeFuerZeitraum(db As DAO.Database, startDatum As Date, anzahlTage As Integer) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    Dim endDatum As Date
    
    endDatum = DateAdd("d", anzahlTage, startDatum)
    
    sql = "SELECT z.MA_ID, z.VA_ID, v.Dat_VA_Von, v.Auftrag, v.Ort, z.ZU_Beginn, z.ZU_Ende " & _
          "FROM tbl_MA_VA_Zuordnung AS z INNER JOIN tbl_VA_Auftragstamm AS v ON z.VA_ID = v.ID " & _
          "WHERE v.Dat_VA_Von >= #" & Format(startDatum, "yyyy-mm-dd") & "# " & _
          "AND v.Dat_VA_Von < #" & Format(endDatum, "yyyy-mm-dd") & "# " & _
          "AND z.MA_ID > 0 ORDER BY z.MA_ID, v.Dat_VA_Von"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""maId"":" & rs!MA_ID & _
            ",""vaId"":" & rs!VA_ID & _
            ",""datum"":""" & Format(rs!Dat_VA_Von, "yyyy-mm-dd") & """" & _
            ",""auftrag"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ", " & EscapeJson(Nz(rs!Ort, "")) & """" & _
            ",""von"":""" & Format(Nz(rs!ZU_Beginn, ""), "hh:nn") & """" & _
            ",""bis"":""" & Format(Nz(rs!ZU_Ende, ""), "hh:nn") & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadEinsaetzeFuerZeitraum = result
End Function

Private Function LoadAbwesenheitenFuerZeitraum(db As DAO.Database, startDatum As Date, anzahlTage As Integer) As String
    LoadAbwesenheitenFuerZeitraum = "[]"
End Function

' =====================================================
' PLANUNGSÜBERSICHT (NACH AUFTRAG/OBJEKT)
' =====================================================
Public Sub OpenPlanungsuebersicht(Optional startDatum As Date = 0)
    Dim htmlPath As String
    Dim jsonData As String
    
    If startDatum = 0 Then startDatum = Date
    htmlPath = HTML_BASE_PATH & "frm_N_DP_Dienstplan_Objekt.html"
    jsonData = LoadPlanungsuebersichtData(startDatum, 7)
    
    Call OpenWebViewForm(htmlPath, "Planungsübersicht", 1400, 900, jsonData)
End Sub

Public Function LoadPlanungsuebersichtData(startDatum As Date, anzahlTage As Integer) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Set db = CurrentDb
    
    Dim result As String
    result = "{"
    result = result & """auftraege"":" & LoadAuftraegeFuerZeitraum(db, startDatum, anzahlTage) & ","
    result = result & """zuordnungen"":" & LoadZuordnungenFuerZeitraum(db, startDatum, anzahlTage)
    result = result & "}"
    
    LoadPlanungsuebersichtData = result
    Exit Function
ErrorHandler:
    LoadPlanungsuebersichtData = "{""error"":""" & Err.Description & """}"
End Function

Private Function LoadAuftraegeFuerZeitraum(db As DAO.Database, startDatum As Date, anzahlTage As Integer) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    Dim endDatum As Date
    
    endDatum = DateAdd("d", anzahlTage, startDatum)
    
    sql = "SELECT DISTINCT ID, Auftrag, Objekt, Ort FROM tbl_VA_Auftragstamm " & _
          "WHERE Dat_VA_Von >= #" & Format(startDatum, "yyyy-mm-dd") & "# " & _
          "AND Dat_VA_Von < #" & Format(endDatum, "yyyy-mm-dd") & "# ORDER BY Auftrag"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!ID & _
            ",""name"":""" & EscapeJson(Nz(rs!Auftrag, "")) & ", " & EscapeJson(Nz(rs!Ort, "")) & """" & _
            ",""objekt"":""" & EscapeJson(Nz(rs!Objekt, "")) & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadAuftraegeFuerZeitraum = result
End Function

Private Function LoadZuordnungenFuerZeitraum(db As DAO.Database, startDatum As Date, anzahlTage As Integer) As String
    LoadZuordnungenFuerZeitraum = "{}"
End Function

' =====================================================
' HILFSFUNKTIONEN (falls nicht in Hauptmodul)
' =====================================================
Private Function GetAuftragSoll(db As DAO.Database, VA_ID As Long) As Long
    Dim rs As DAO.Recordset
    Set rs = db.OpenRecordset("SELECT Sum(MA_Anzahl) AS S FROM tbl_VA_Start WHERE VA_ID = " & VA_ID, dbOpenSnapshot)
    GetAuftragSoll = Nz(rs!S, 0)
    rs.Close
End Function

Private Function GetAuftragIst(db As DAO.Database, VA_ID As Long) As Long
    Dim rs As DAO.Recordset
    Set rs = db.OpenRecordset("SELECT Count(*) AS C FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & VA_ID & " AND MA_ID > 0", dbOpenSnapshot)
    GetAuftragIst = Nz(rs!C, 0)
    rs.Close
End Function

Private Function EscapeJson(s As String) As String
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCr, "")
    s = Replace(s, vbLf, "")
    s = Replace(s, vbTab, " ")
    EscapeJson = s
End Function


' =====================================================
' STUNDENAUSWERTUNG / ZEITKONTEN
' =====================================================
Public Sub OpenStundenauswertung()
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE_PATH & "frm_N_Stundenauswertung.html"
    jsonData = LoadZeitkontenData("aktuell", "Minijobber")
    
    Call OpenWebViewForm(htmlPath, "Datenimport Zeitkonten für Lexware", 1200, 800, jsonData)
End Sub

Public Function LoadZeitkontenData(zeitraum As String, anstellung As String) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Set db = CurrentDb
    
    Dim result As String
    result = "{"
    result = result & """zeitkonten"":" & LoadZeitkontenliste(db, zeitraum, anstellung) & ","
    result = result & """mitarbeiter"":" & LoadMitarbeiterListe(db)
    result = result & "}"
    
    LoadZeitkontenData = result
    Exit Function
ErrorHandler:
    LoadZeitkontenData = "{""error"":""" & Err.Description & """}"
End Function

Private Function LoadZeitkontenliste(db As DAO.Database, zeitraum As String, anstellung As String) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    Dim startDat As Date, endDat As Date
    
    ' Zeitraum berechnen
    Select Case zeitraum
        Case "aktuell"
            startDat = DateSerial(Year(Date), Month(Date), 1)
            endDat = DateAdd("m", 1, startDat) - 1
        Case "vormonat"
            startDat = DateSerial(Year(Date), Month(Date) - 1, 1)
            endDat = DateAdd("m", 1, startDat) - 1
        Case Else
            startDat = DateSerial(Year(Date), 1, 1)
            endDat = Date
    End Select
    
    sql = "SELECT z.*, m.MA_Nachname, m.MA_Vorname FROM tbl_MA_Zeitkonto AS z " & _
          "LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON z.MA_ID = m.MA_ID " & _
          "WHERE z.ZK_Datum >= #" & Format(startDat, "yyyy-mm-dd") & "# " & _
          "AND z.ZK_Datum <= #" & Format(endDat, "yyyy-mm-dd") & "#"
    
    If anstellung <> "" Then
        sql = sql & " AND m.MA_Anstellungsart = '" & anstellung & "'"
    End If
    sql = sql & " ORDER BY m.MA_Nachname, z.ZK_Datum"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""jahr"":" & Year(rs!ZK_Datum) & _
            ",""monat"":" & Month(rs!ZK_Datum) & _
            ",""name"":""" & EscapeJson(Nz(rs!MA_Nachname, "") & " " & Nz(rs!MA_Vorname, "")) & """" & _
            ",""lohnart"":" & Nz(rs!ZK_Lohnart, 0) & _
            ",""wert"":" & Replace(Nz(rs!ZK_Wert, 0), ",", ".") & _
            ",""faktor"":" & Replace(Nz(rs!ZK_Faktor, 0), ",", ".") & "}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadZeitkontenliste = result
End Function

' =====================================================
' LOHNABRECHNUNGEN
' =====================================================
Public Sub OpenLohnabrechnungen()
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE_PATH & "frm_N_Lohnabrechnungen_V2.html"
    jsonData = LoadLohnabrechnungenData(Year(Date), Month(Date), "Fest + Mini")
    
    Call OpenWebViewForm(htmlPath, "Lohnabrechnungen", 1200, 800, jsonData)
End Sub

Public Function LoadLohnabrechnungenData(jahr As Integer, monat As Integer, anstellung As String) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Set db = CurrentDb
    
    Dim result As String
    result = "{""lohnabrechnungen"":" & LoadLohnabrechnungenListe(db, jahr, monat, anstellung) & "}"
    
    LoadLohnabrechnungenData = result
    Exit Function
ErrorHandler:
    LoadLohnabrechnungenData = "{""error"":""" & Err.Description & """}"
End Function

Private Function LoadLohnabrechnungenListe(db As DAO.Database, jahr As Integer, monat As Integer, anstellung As String) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT MA_ID, MA_Nachname, MA_Vorname, MA_Anstellungsart " & _
          "FROM tbl_MA_Mitarbeiterstamm WHERE MA_aktiv = True"
    
    If anstellung = "Festangestellter" Then
        sql = sql & " AND MA_Anstellungsart = 'Festangestellter'"
    ElseIf anstellung = "Minijobber" Then
        sql = sql & " AND MA_Anstellungsart = 'Minijobber'"
    End If
    sql = sql & " ORDER BY MA_Nachname"
    
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""monat"":" & monat & _
            ",""name"":""" & EscapeJson(rs!MA_Nachname & " " & Nz(rs!MA_Vorname, "")) & """" & _
            ",""versenden"":true,""datei"":"""",""versendetAm"":"""",""protokoll"":""""}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadLohnabrechnungenListe = result
End Function

' =====================================================
' ABWESENHEITSPLANUNG
' =====================================================
Public Sub OpenAbwesenheitsplanung(Optional MA_ID As Long = 0)
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE_PATH & "frm_N_MA_Abwesenheiten.html"
    jsonData = LoadAbwesenheitenData(MA_ID)
    
    Call OpenWebViewForm(htmlPath, "Abwesenheitsplanung", 900, 600, jsonData)
End Sub

Public Function LoadAbwesenheitenData(MA_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Set db = CurrentDb
    
    Dim result As String
    result = "{"
    result = result & """mitarbeiter"":" & LoadMitarbeiterListe(db)
    If MA_ID > 0 Then
        result = result & ",""abwesenheiten"":" & LoadAbwesenheitenListe(db, MA_ID)
    End If
    result = result & "}"
    
    LoadAbwesenheitenData = result
    Exit Function
ErrorHandler:
    LoadAbwesenheitenData = "{""error"":""" & Err.Description & """}"
End Function

Private Function LoadAbwesenheitenListe(db As DAO.Database, MA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT * FROM tbl_MA_Abwesenheit WHERE MA_ID = " & MA_ID & " ORDER BY Abw_DatVon"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""datVon"":""" & Format(rs!Abw_DatVon, "yyyy-mm-dd") & """" & _
            ",""datBis"":""" & Format(Nz(rs!Abw_DatBis, rs!Abw_DatVon), "yyyy-mm-dd") & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadAbwesenheitenListe = result
End Function

Private Function LoadMitarbeiterListe(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String
    Dim first As Boolean
    
    sql = "SELECT MA_ID, MA_Nachname, MA_Vorname FROM tbl_MA_Mitarbeiterstamm WHERE MA_aktiv = True ORDER BY MA_Nachname"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    
    result = "["
    first = True
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!MA_ID & ",""name"":""" & EscapeJson(rs!MA_Nachname & " " & Nz(rs!MA_Vorname, "")) & """}"
        rs.MoveNext
    Loop
    result = result & "]"
    rs.Close
    LoadMitarbeiterListe = result
End Function
