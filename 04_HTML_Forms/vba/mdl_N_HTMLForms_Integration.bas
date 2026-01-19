Attribute VB_Name = "mdl_N_HTMLForms_Integration"
' =====================================================
' mdl_N_HTMLForms_Integration
' Vollständige Integration der HTML-Formulare
' Version 2.0 - Stand: 30.12.2025
' =====================================================
Option Compare Database
Option Explicit

' Konstanten für HTML-Pfade
Private Const HTML_BASE As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"

' =====================================================
' ÖFFNEN DER HTML-FORMULARE
' =====================================================

' Mitarbeiterstamm HTML öffnen
Public Sub OpenMitarbeiterstammHTML(Optional MA_ID As Long = 0)
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE & "mitarbeiterverwaltung\frm_N_MA_Mitarbeiterstamm_V2.html"
    
    If MA_ID > 0 Then
        jsonData = LoadMitarbeiterstammJSON(MA_ID)
    Else
        jsonData = "{}"
    End If
    
    ' Öffne im Browser oder WebView2
    OpenHTMLForm htmlPath, "Mitarbeiterstamm", 1400, 900, jsonData
End Sub

' Kundenstamm HTML öffnen
Public Sub OpenKundenstammHTML(Optional KD_ID As Long = 0)
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE & "kundenverwaltung\frm_N_KD_Kundenstamm.html"
    
    If KD_ID > 0 Then
        jsonData = LoadKundenstammJSON(KD_ID)
    Else
        jsonData = "{}"
    End If
    
    OpenHTMLForm htmlPath, "Kundenstamm", 1300, 800, jsonData
End Sub

' Auftragsverwaltung HTML öffnen
Public Sub OpenAuftragsverwaltungHTML(Optional VA_ID As Long = 0, Optional FilterDatum As Date)
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE & "auftragsverwaltung\frm_N_VA_Auftragstamm.html"
    
    If VA_ID > 0 Then
        jsonData = LoadAuftragsverwaltungJSON(VA_ID)
    ElseIf FilterDatum > 0 Then
        jsonData = LoadAuftraegeForDatum(FilterDatum)
    Else
        jsonData = LoadAuftraegeForDatum(Date)
    End If
    
    OpenHTMLForm htmlPath, "Auftragsverwaltung", 1500, 900, jsonData
End Sub

' Dienstplan MA HTML öffnen
Public Sub OpenDienstplanMAHTML(Optional StartDatum As Date)
    Dim htmlPath As String
    htmlPath = HTML_BASE & "frm_N_DP_Dienstplan_MA.html"
    
    If StartDatum = 0 Then StartDatum = Date
    OpenHTMLForm htmlPath, "Dienstplan Mitarbeiter", 1400, 800, "{""startDatum"":""" & Format(StartDatum, "yyyy-mm-dd") & """}"
End Sub

' Dienstplan Objekt HTML öffnen
Public Sub OpenDienstplanObjektHTML(Optional StartDatum As Date)
    Dim htmlPath As String
    htmlPath = HTML_BASE & "frm_N_DP_Dienstplan_Objekt.html"
    
    If StartDatum = 0 Then StartDatum = Date
    OpenHTMLForm htmlPath, "Planungsübersicht", 1400, 800, "{""startDatum"":""" & Format(StartDatum, "yyyy-mm-dd") & """}"
End Sub

' Stundenauswertung HTML öffnen
Public Sub OpenStundenauswertungHTML()
    Dim htmlPath As String
    htmlPath = HTML_BASE & "frm_N_Stundenauswertung.html"
    OpenHTMLForm htmlPath, "Stundenauswertung", 1300, 700, "{}"
End Sub

' Mitarbeiter Schnellauswahl HTML öffnen
Public Sub OpenSchnellauswahlHTML(VA_ID As Long, Datum As Date)
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE & "frm_N_MA_VA_Schnellauswahl.html"
    jsonData = LoadSchnellauswahlJSON(VA_ID, Datum)
    
    OpenHTMLForm htmlPath, "Mitarbeiterauswahl", 1200, 700, jsonData
End Sub

' Abwesenheiten HTML öffnen
Public Sub OpenAbwesenheitenHTML(Optional MA_ID As Long = 0)
    Dim htmlPath As String
    htmlPath = HTML_BASE & "frm_N_MA_Abwesenheiten.html"
    OpenHTMLForm htmlPath, "Abwesenheitsplanung", 900, 600, "{""maId"":" & MA_ID & "}"
End Sub

' Lohnabrechnungen HTML öffnen
Public Sub OpenLohnabrechnungenHTML()
    Dim htmlPath As String
    htmlPath = HTML_BASE & "frm_N_Lohnabrechnungen_V2.html"
    OpenHTMLForm htmlPath, "Lohnabrechnungen", 1100, 700, "{}"
End Sub

' =====================================================
' ZENTRALE FORM-ÖFFNUNG
' =====================================================
Private Sub OpenHTMLForm(htmlPath As String, title As String, width As Long, height As Long, jsonData As String)
    ' Prüfe ob WebView2 verfügbar ist
    On Error Resume Next
    Dim webView As Object
    Set webView = CreateObject("ConsysWebView2.WebFormHost")
    
    If Err.Number = 0 Then
        ' WebView2 verfügbar - nutze es
        On Error GoTo 0
        If Len(jsonData) > 0 And jsonData <> "{}" Then
            webView.ShowFormWithData htmlPath, title, width, height, jsonData
        Else
            webView.ShowForm htmlPath, title, width, height
        End If
    Else
        ' Fallback: Öffne im Standard-Browser
        On Error GoTo 0
        Dim url As String
        url = "file:///" & Replace(htmlPath, "\", "/")
        
        ' JSON als URL-Parameter (nur wenn klein genug)
        If Len(jsonData) < 2000 And jsonData <> "{}" Then
            url = url & "?data=" & EncodeURL(jsonData)
        End If
        
        Shell "cmd /c start """" """ & url & """", vbHide
    End If
End Sub

' =====================================================
' JSON-DATEN LADEN
' =====================================================
Private Function LoadMitarbeiterstammJSON(MA_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim result As String
    
    Set db = CurrentDb
    
    ' Stammdaten laden
    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadMitarbeiterstammJSON = "{}"
        Exit Function
    End If
    
    result = "{"
    result = result & """stammdaten"":{"
    result = result & """id"":" & rs!ID & ","
    result = result & """nachname"":""" & EscapeJSON(Nz(rs!Nachname, "")) & ""","
    result = result & """vorname"":""" & EscapeJSON(Nz(rs!Vorname, "")) & ""","
    result = result & """strasse"":""" & EscapeJSON(Nz(rs!Strasse, "")) & ""","
    result = result & """plz"":""" & EscapeJSON(Nz(rs!PLZ, "")) & ""","
    result = result & """ort"":""" & EscapeJSON(Nz(rs!Ort, "")) & ""","
    result = result & """telMobil"":""" & EscapeJSON(Nz(rs!Tel_Mobil, "")) & ""","
    result = result & """email"":""" & EscapeJSON(Nz(rs!Email, "")) & ""","
    result = result & """istAktiv"":" & IIf(Nz(rs!IstAktiv, False), "true", "false")
    result = result & "}"
    
    ' Alle Mitarbeiter für Liste
    result = result & ",""alleMitarbeiter"":" & LoadAlleMitarbeiterJSON(db)
    
    result = result & "}"
    rs.Close
    
    LoadMitarbeiterstammJSON = result
    Exit Function
    
ErrorHandler:
    LoadMitarbeiterstammJSON = "{""error"":""" & EscapeJSON(Err.Description) & """}"
End Function

Private Function LoadKundenstammJSON(KD_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim result As String
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Id = " & KD_ID, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadKundenstammJSON = "{}"
        Exit Function
    End If
    
    result = "{"
    result = result & """stammdaten"":{"
    result = result & """id"":" & rs!kun_Id & ","
    result = result & """firma"":""" & EscapeJSON(Nz(rs!kun_Firma, "")) & ""","
    result = result & """kuerzel"":""" & EscapeJSON(Nz(rs!kun_Matchcode, "")) & ""","
    result = result & """strasse"":""" & EscapeJSON(Nz(rs!kun_Strasse, "")) & ""","
    result = result & """plz"":""" & EscapeJSON(Nz(rs!kun_PLZ, "")) & ""","
    result = result & """ort"":""" & EscapeJSON(Nz(rs!kun_Ort, "")) & ""","
    result = result & """telefon"":""" & EscapeJSON(Nz(rs!kun_telefon, "")) & ""","
    result = result & """email"":""" & EscapeJSON(Nz(rs!kun_email, "")) & ""","
    result = result & """istAktiv"":" & IIf(Nz(rs!kun_IstAktiv, True), "true", "false")
    result = result & "}"
    
    result = result & ",""alleKunden"":" & LoadAlleKundenJSON(db)
    result = result & "}"
    
    rs.Close
    LoadKundenstammJSON = result
    Exit Function
    
ErrorHandler:
    LoadKundenstammJSON = "{""error"":""" & EscapeJSON(Err.Description) & """}"
End Function

Private Function LoadAuftragsverwaltungJSON(VA_ID As Long) As String
    On Error GoTo ErrorHandler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim result As String
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tbl_VA_Auftragstamm WHERE ID = " & VA_ID, dbOpenSnapshot)
    
    If rs.EOF Then
        LoadAuftragsverwaltungJSON = "{}"
        Exit Function
    End If
    
    result = "{"
    result = result & """stammdaten"":{"
    result = result & """id"":" & rs!ID & ","
    result = result & """auftrag"":""" & EscapeJSON(Nz(rs!Auftrag, "")) & ""","
    result = result & """objekt"":""" & EscapeJSON(Nz(rs!Objekt, "")) & ""","
    result = result & """ort"":""" & EscapeJSON(Nz(rs!Ort, "")) & ""","
    result = result & """datVon"":""" & Format(Nz(rs!Dat_VA_Von, ""), "dd.mm.yyyy") & ""","
    result = result & """datBis"":""" & Format(Nz(rs!Dat_VA_Bis, ""), "dd.mm.yyyy") & """"
    result = result & "}"
    
    ' Schichten laden
    result = result & ",""schichten"":" & LoadSchichtenJSON(db, VA_ID)
    
    ' Zuordnungen laden
    result = result & ",""zuordnungen"":" & LoadZuordnungenJSON(db, VA_ID)
    
    result = result & "}"
    rs.Close
    
    LoadAuftragsverwaltungJSON = result
    Exit Function
    
ErrorHandler:
    LoadAuftragsverwaltungJSON = "{""error"":""" & EscapeJSON(Err.Description) & """}"
End Function

Private Function LoadAuftraegeForDatum(Datum As Date) As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim result As String
    Dim first As Boolean
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT ID, Auftrag, Ort, Dat_VA_Von FROM tbl_VA_Auftragstamm WHERE Dat_VA_Von >= #" & Format(Datum, "yyyy-mm-dd") & "# ORDER BY Dat_VA_Von", dbOpenSnapshot)
    
    result = "{""alleAuftraege"":["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{"
        result = result & """id"":" & rs!ID & ","
        result = result & """auftrag"":""" & EscapeJSON(Nz(rs!Auftrag, "")) & ""","
        result = result & """ort"":""" & EscapeJSON(Nz(rs!Ort, "")) & ""","
        result = result & """datum"":""" & Format(rs!Dat_VA_Von, "dd.mm.yyyy") & """"
        result = result & "}"
        rs.MoveNext
    Loop
    
    result = result & "]}"
    rs.Close
    LoadAuftraegeForDatum = result
End Function

Private Function LoadSchnellauswahlJSON(VA_ID As Long, Datum As Date) As String
    ' Implementierung für Schnellauswahl
    LoadSchnellauswahlJSON = "{""vaId"":" & VA_ID & ",""datum"":""" & Format(Datum, "dd.mm.yyyy") & """}"
End Function

' =====================================================
' HILFSFUNKTIONEN
' =====================================================
Private Function LoadAlleMitarbeiterJSON(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim result As String
    Dim first As Boolean
    
    Set rs = db.OpenRecordset("SELECT ID, Nachname, Vorname, Ort, IstAktiv FROM tbl_MA_Mitarbeiterstamm ORDER BY Nachname", dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!ID & ",""nachname"":""" & EscapeJSON(Nz(rs!Nachname, "")) & """,""vorname"":""" & EscapeJSON(Nz(rs!Vorname, "")) & """,""ort"":""" & EscapeJSON(Nz(rs!Ort, "")) & """,""aktiv"":" & IIf(Nz(rs!IstAktiv, False), "true", "false") & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadAlleMitarbeiterJSON = result
End Function

Private Function LoadAlleKundenJSON(db As DAO.Database) As String
    Dim rs As DAO.Recordset
    Dim result As String
    Dim first As Boolean
    
    Set rs = db.OpenRecordset("SELECT kun_Id, kun_Firma, kun_Ort, kun_IstAktiv FROM tbl_KD_Kundenstamm ORDER BY kun_Firma", dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!kun_Id & ",""firma"":""" & EscapeJSON(Nz(rs!kun_Firma, "")) & """,""ort"":""" & EscapeJSON(Nz(rs!kun_Ort, "")) & """,""aktiv"":" & IIf(Nz(rs!kun_IstAktiv, True), "true", "false") & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadAlleKundenJSON = result
End Function

Private Function LoadSchichtenJSON(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim result As String
    Dim first As Boolean
    
    Set rs = db.OpenRecordset("SELECT * FROM tbl_VA_Start WHERE VA_ID = " & VA_ID & " ORDER BY DB_von", dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""id"":" & rs!ID & ",""soll"":" & Nz(rs!MA_Anzahl, 0) & ",""beginn"":""" & Format(rs!DB_von, "hh:nn") & """,""ende"":""" & Format(rs!DB_bis, "hh:nn") & """}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadSchichtenJSON = result
End Function

Private Function LoadZuordnungenJSON(db As DAO.Database, VA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim result As String
    Dim first As Boolean
    
    Set rs = db.OpenRecordset("SELECT z.*, m.Nachname, m.Vorname FROM tbl_MA_VA_Zuordnung AS z LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON z.MA_ID = m.ID WHERE z.VA_ID = " & VA_ID & " ORDER BY z.ZU_Lfd", dbOpenSnapshot)
    
    result = "["
    first = True
    
    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & "{""lfd"":" & Nz(rs!ZU_Lfd, 0) & ",""maId"":" & Nz(rs!MA_ID, 0) & ",""nachname"":""" & EscapeJSON(Nz(rs!Nachname, "")) & """,""vorname"":""" & EscapeJSON(Nz(rs!Vorname, "")) & """,""von"":""" & Format(Nz(rs!ZU_Beginn, ""), "hh:nn") & """,""bis"":""" & Format(Nz(rs!ZU_Ende, ""), "hh:nn") & """,""stunden"":" & Replace(Nz(rs!ZU_Stunden, 0), ",", ".") & "}"
        rs.MoveNext
    Loop
    
    result = result & "]"
    rs.Close
    LoadZuordnungenJSON = result
End Function

Private Function EscapeJSON(s As String) As String
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCr, "")
    s = Replace(s, vbLf, "")
    s = Replace(s, vbTab, " ")
    EscapeJSON = s
End Function

Private Function EncodeURL(s As String) As String
    Dim i As Long
    Dim c As String
    Dim result As String
    
    For i = 1 To Len(s)
        c = Mid(s, i, 1)
        Select Case Asc(c)
            Case 48 To 57, 65 To 90, 97 To 122, 45, 46, 95, 126
                result = result & c
            Case Else
                result = result & "%" & Right("0" & Hex(Asc(c)), 2)
        End Select
    Next i
    
    EncodeURL = result
End Function
