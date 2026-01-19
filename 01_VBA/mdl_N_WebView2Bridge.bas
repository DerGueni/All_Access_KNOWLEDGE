Attribute VB_Name = "mdl_N_WebView2Bridge"
' =====================================================
' mdl_N_WebView2Bridge - WebView2 Bridge fuer Access
' Version 3.2 - Standalone EXE Ansatz mit API-Server Auto-Start
' Korrigiert: 05.01.2026 - Application.Wait durch Sleep ersetzt
' =====================================================

' =====================================================
' KONFIGURATION
' =====================================================
Private Const EXE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe"
Private Const HTML_BASE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"
Private Const API_SERVER_PATH As String = "C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py"
Private Const API_SERVER_PORT As Long = 5000

' Windows API fuer Sleep (ersetzt Application.Wait)
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)

' Globale Variable fuer Server-Status
Private g_APIServerStarted As Boolean

' =====================================================
' OEFFENTLICHE FUNKTIONEN - Formulare oeffnen
' =====================================================

' Oeffnet das Mitarbeiterstammblatt als HTML
Public Sub OpenMitarbeiterstammHTML(Optional MA_ID As Long = 0)
    Dim htmlPath As String
    Dim jsonData As String

    ' API-Server sicherstellen (unsichtbar im Hintergrund)
    If Not EnsureAPIServerRunning() Then
        If MsgBox("API-Server nicht verfuegbar. Formular trotzdem oeffnen?", vbYesNo + vbQuestion) = vbNo Then
            Exit Sub
        End If
    End If

    htmlPath = HTML_BASE_PATH & "frm_MA_Mitarbeiterstamm.html"

    ' Falls HTML nicht existiert, Test-Seite verwenden
    If Dir(htmlPath) = "" Then
        htmlPath = HTML_BASE_PATH & "webview2_test.html"
    End If

    ' Daten laden falls ID angegeben
    If MA_ID > 0 Then
        jsonData = LoadMitarbeiterData(MA_ID)
    Else
        jsonData = "{}"
    End If

    ' Formular oeffnen
    OpenWebViewForm htmlPath, "Mitarbeiterstammblatt", 1400, 900, jsonData
End Sub

' Oeffnet die Auftragsverwaltung als HTML
Public Sub OpenAuftragstammHTML(Optional VA_ID As Long = 0)
    Dim htmlPath As String
    Dim jsonData As String

    ' API-Server sicherstellen (unsichtbar im Hintergrund)
    If Not EnsureAPIServerRunning() Then
        If MsgBox("API-Server nicht verfuegbar. Formular trotzdem oeffnen?", vbYesNo + vbQuestion) = vbNo Then
            Exit Sub
        End If
    End If

    htmlPath = HTML_BASE_PATH & "frm_va_Auftragstamm.html"

    If Dir(htmlPath) = "" Then
        htmlPath = HTML_BASE_PATH & "webview2_test.html"
    End If

    If VA_ID > 0 Then
        jsonData = LoadAuftragData(VA_ID)
    Else
        jsonData = "{}"
    End If

    OpenWebViewForm htmlPath, "Auftragsverwaltung", 1600, 1000, jsonData
End Sub

' Oeffnet das Kundenstammblatt als HTML
Public Sub OpenKundenstammHTML(Optional KD_ID As Long = 0)
    Dim htmlPath As String
    Dim jsonData As String

    ' API-Server sicherstellen (unsichtbar im Hintergrund)
    If Not EnsureAPIServerRunning() Then
        If MsgBox("API-Server nicht verfuegbar. Formular trotzdem oeffnen?", vbYesNo + vbQuestion) = vbNo Then
            Exit Sub
        End If
    End If

    htmlPath = HTML_BASE_PATH & "frm_KD_Kundenstamm.html"

    If Dir(htmlPath) = "" Then
        htmlPath = HTML_BASE_PATH & "webview2_test.html"
    End If

    If KD_ID > 0 Then
        jsonData = LoadKundenData(KD_ID)
    Else
        jsonData = "{}"
    End If

    OpenWebViewForm htmlPath, "Kundenstammblatt", 1400, 900, jsonData
End Sub

' Oeffnet die Test-Seite
Public Sub OpenWebView2Test()
    Dim htmlPath As String
    htmlPath = HTML_BASE_PATH & "webview2_test.html"

    Dim testData As String
    testData = "{""test"":""Hallo aus Access!"",""timestamp"":""" & Format(Now, "yyyy-mm-dd hh:nn:ss") & """}"

    OpenWebViewForm htmlPath, "WebView2 Bridge Test", 1000, 700, testData
End Sub

' =====================================================
' KERN-FUNKTION: WebView-Formular oeffnen
' =====================================================
Public Sub OpenWebViewForm(htmlPath As String, title As String, width As Long, height As Long, Optional jsonData As String = "{}")
    Dim cmd As String
    Dim dataFile As String

    ' Pruefe ob EXE existiert
    If Dir(EXE_PATH) = "" Then
        MsgBox "WebView2 App nicht gefunden:" & vbCrLf & EXE_PATH, vbCritical, "Fehler"
        Exit Sub
    End If

    ' Pruefe ob HTML existiert
    If Dir(htmlPath) = "" Then
        MsgBox "HTML-Datei nicht gefunden:" & vbCrLf & htmlPath, vbCritical, "Fehler"
        Exit Sub
    End If

    ' JSON-Daten in temporaere Datei schreiben (fuer komplexe Daten)
    If Len(jsonData) > 500 Then
        dataFile = Environ("TEMP") & "\consys_webview_data.json"
        WriteTextFile dataFile, jsonData
        jsonData = "@" & dataFile  ' Signalisiert: Lade aus Datei
    End If

    ' Kommandozeile bauen
    cmd = """" & EXE_PATH & """ " & _
          "-html """ & htmlPath & """ " & _
          "-title """ & title & """ " & _
          "-width " & width & " " & _
          "-height " & height

    ' Daten nur anhaengen wenn nicht zu lang
    If Left(jsonData, 1) <> "@" And Len(jsonData) > 2 Then
        ' Einfache Daten direkt uebergeben
        ' Escaping fuer Kommandozeile
        Dim escapedData As String
        escapedData = Replace(jsonData, """", "\""")
        cmd = cmd & " -data """ & escapedData & """"
    End If

    ' Starte den Prozess
    Shell cmd, vbNormalFocus

    Debug.Print "WebView gestartet: " & cmd
End Sub

' =====================================================
' DATEN-SERVICE: Laedt Daten aus Access-Tabellen
' =====================================================

' Laedt Mitarbeiter-Daten als JSON
Public Function LoadMitarbeiterData(MA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT * FROM tbl_MA_Mitarbeiter WHERE MA_ID = " & MA_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        LoadMitarbeiterData = "{""error"":""Mitarbeiter nicht gefunden""}"
    Else
        LoadMitarbeiterData = "{""mitarbeiter"":" & RecordToJson(rs) & "}"
    End If

    rs.Close
    Exit Function

ErrorHandler:
    LoadMitarbeiterData = "{""error"":""" & Err.Description & """}"
End Function

' Laedt Auftrags-Daten als JSON
Public Function LoadAuftragData(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim result As String

    Set db = CurrentDb

    ' Hauptdaten
    sql = "SELECT * FROM tbl_VA_Veranstaltung WHERE VA_ID = " & VA_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        LoadAuftragData = "{""error"":""Auftrag nicht gefunden""}"
        rs.Close
        Exit Function
    End If

    result = "{""auftrag"":" & RecordToJson(rs) & ","
    rs.Close

    ' Zuordnungen laden
    sql = "SELECT z.*, m.MA_Nachname, m.MA_Vorname " & _
          "FROM tbl_MA_VA_Zuordnung z " & _
          "LEFT JOIN tbl_MA_Mitarbeiter m ON z.MA_ID = m.MA_ID " & _
          "WHERE z.VA_ID = " & VA_ID & " ORDER BY z.ZU_Beginn"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    result = result & """zuordnungen"":" & RecordsetToJsonArray(rs) & "}"
    rs.Close

    LoadAuftragData = result
    Exit Function

ErrorHandler:
    LoadAuftragData = "{""error"":""" & Err.Description & """}"
End Function

' Laedt Kunden-Daten als JSON
Public Function LoadKundenData(KD_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT * FROM tbl_KD_Kunde WHERE KD_ID = " & KD_ID
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If rs.EOF Then
        LoadKundenData = "{""error"":""Kunde nicht gefunden""}"
    Else
        LoadKundenData = "{""kunde"":" & RecordToJson(rs) & "}"
    End If

    rs.Close
    Exit Function

ErrorHandler:
    LoadKundenData = "{""error"":""" & Err.Description & """}"
End Function

' =====================================================
' JSON-HILFSFUNKTIONEN
' =====================================================

' Konvertiert einen einzelnen Record zu JSON
Private Function RecordToJson(rs As DAO.Recordset) As String
    Dim i As Long
    Dim fld As DAO.Field
    Dim result As String
    Dim val As String

    result = "{"

    For i = 0 To rs.Fields.Count - 1
        Set fld = rs.Fields(i)

        If i > 0 Then result = result & ","

        result = result & """" & fld.Name & """:"

        If IsNull(fld.Value) Then
            result = result & "null"
        ElseIf fld.Type = dbBoolean Then
            result = result & IIf(fld.Value, "true", "false")
        ElseIf fld.Type = dbDate Then
            result = result & """" & Format(fld.Value, "yyyy-mm-dd hh:nn:ss") & """"
        ElseIf IsNumeric(fld.Value) And fld.Type <> dbText And fld.Type <> dbMemo Then
            result = result & Replace(CStr(fld.Value), ",", ".")
        Else
            val = CStr(fld.Value)
            val = Replace(val, "\", "\\")
            val = Replace(val, """", "\""")
            val = Replace(val, vbCrLf, "\n")
            val = Replace(val, vbCr, "\n")
            val = Replace(val, vbLf, "\n")
            val = Replace(val, vbTab, "\t")
            result = result & """" & val & """"
        End If
    Next i

    result = result & "}"
    RecordToJson = result
End Function

' Konvertiert ein Recordset zu JSON-Array
Private Function RecordsetToJsonArray(rs As DAO.Recordset) As String
    Dim result As String
    Dim first As Boolean

    result = "["
    first = True

    Do While Not rs.EOF
        If Not first Then result = result & ","
        first = False
        result = result & RecordToJson(rs)
        rs.MoveNext
    Loop

    result = result & "]"
    RecordsetToJsonArray = result
End Function

' =====================================================
' DATEI-HILFSFUNKTIONEN
' =====================================================

' Schreibt Text in eine Datei
Private Sub WriteTextFile(filePath As String, content As String)
    Dim fNum As Integer
    fNum = FreeFile
    Open filePath For Output As #fNum
    Print #fNum, content
    Close #fNum
End Sub

' =====================================================
' SUCHE (fuer kuenftige Nutzung)
' =====================================================

' Sucht Mitarbeiter
Public Function SearchMitarbeiter(searchTerm As String) As String
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim term As String

    Set db = CurrentDb
    term = Replace(searchTerm, "'", "''")

    sql = "SELECT TOP 50 MA_ID, MA_Nachname, MA_Vorname, MA_Ort " & _
          "FROM tbl_MA_Mitarbeiter " & _
          "WHERE MA_Nachname LIKE '*" & term & "*' " & _
          "OR MA_Vorname LIKE '*" & term & "*' " & _
          "ORDER BY MA_Nachname, MA_Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    SearchMitarbeiter = "{""results"":" & RecordsetToJsonArray(rs) & "}"
    rs.Close
    Exit Function

ErrorHandler:
    SearchMitarbeiter = "{""error"":""" & Err.Description & """}"
End Function

' =====================================================
' API-SERVER MANAGEMENT
' =====================================================

' Prueft ob der API-Server laeuft und startet ihn falls noetig
Public Function EnsureAPIServerRunning() As Boolean
    On Error GoTo ErrorHandler

    ' Bereits gestartet in dieser Session?
    If g_APIServerStarted Then
        If IsServerResponding() Then
            EnsureAPIServerRunning = True
            Exit Function
        End If
    End If

    ' Pruefe ob Server bereits laeuft
    If IsServerResponding() Then
        g_APIServerStarted = True
        Debug.Print "[API] Server laeuft bereits auf Port " & API_SERVER_PORT
        EnsureAPIServerRunning = True
        Exit Function
    End If

    ' Server starten
    Debug.Print "[API] Starte API-Server..."
    If StartAPIServer() Then
        ' Warten bis Server antwortet (max 10 Sekunden)
        Dim i As Integer
        For i = 1 To 20
            DoEvents
            Sleep 500  ' 500ms warten (statt Application.Wait)
            If IsServerResponding() Then
                g_APIServerStarted = True
                Debug.Print "[API] Server gestartet nach " & i * 0.5 & " Sekunden"
                EnsureAPIServerRunning = True
                Exit Function
            End If
        Next i

        Debug.Print "[API] Server-Start Timeout"
        EnsureAPIServerRunning = False
    Else
        Debug.Print "[API] Server-Start fehlgeschlagen"
        EnsureAPIServerRunning = False
    End If
    Exit Function

ErrorHandler:
    Debug.Print "[API] Fehler: " & Err.Description
    EnsureAPIServerRunning = False
End Function

' Prueft ob der Server antwortet
Public Function IsServerResponding() As Boolean
    On Error Resume Next

    Dim http As Object
    Set http = CreateObject("MSXML2.XMLHTTP")

    http.Open "GET", "http://localhost:" & API_SERVER_PORT & "/api/tables", False
    http.setRequestHeader "Content-Type", "application/json"
    http.Send

    If Err.Number = 0 And http.Status = 200 Then
        IsServerResponding = True
    Else
        IsServerResponding = False
    End If

    Set http = Nothing
End Function

' Startet den API-Server als Hintergrund-Prozess (minimiert)
Private Function StartAPIServer() As Boolean
    On Error GoTo ErrorHandler

    Dim cmd As String

    ' Pruefe ob Python-Skript existiert
    If Dir(API_SERVER_PATH) = "" Then
        Debug.Print "[API] Server-Datei nicht gefunden: " & API_SERVER_PATH
        StartAPIServer = False
        Exit Function
    End If

    ' Kommando bauen (minimiert starten - UNSICHTBAR)
    cmd = "cmd /c start /min python """ & API_SERVER_PATH & """"

    ' Shell ausfuehren
    Shell cmd, vbMinimizedNoFocus

    Debug.Print "[API] Server-Prozess gestartet"
    StartAPIServer = True
    Exit Function

ErrorHandler:
    Debug.Print "[API] Start-Fehler: " & Err.Description
    StartAPIServer = False
End Function

' Stoppt den API-Server
Public Sub StopAPIServer()
    On Error Resume Next

    Dim wsh As Object
    Set wsh = CreateObject("WScript.Shell")

    ' Alle Python-Prozesse mit api_server.py beenden
    wsh.Run "taskkill /F /IM python.exe /FI ""WINDOWTITLE eq api_server*""", 0, True

    g_APIServerStarted = False
    Debug.Print "[API] Server gestoppt"

    Set wsh = Nothing
End Sub
