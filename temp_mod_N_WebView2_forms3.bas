Attribute VB_Name = "mod_N_WebView2_forms3"

' =====================================================
' mod_N_WebView2_forms3
' WebView2 Integration fuer forms3 HTML-Formulare
' Korrigiert: 05.01.2026 - Sleep-Deklaration und Shell-Aufruf
' =====================================================

' Pfade
Private Const FORMS3_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\"
Private Const WEBVIEW2_EXE As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe"
Private Const API_SERVER_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\mini_api.py"
Private Const API_PORT As Integer = 5000

' Windows API fuer Sleep
' WICHTIG: dwMilliseconds ist DWORD (32-bit), daher LONG, nicht LongPtr!
#If VBA7 Then
    Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
#Else
    Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
#End If

' Windows Script Host fuer robusteren Shell-Aufruf
Private Function ShellAndWait(cmd As String, Optional windowStyle As Integer = 0) As Long
    Dim wsh As Object
    Set wsh = CreateObject("WScript.Shell")
    ShellAndWait = wsh.Run(cmd, windowStyle, False)
    Set wsh = Nothing
End Function

' =====================================================
' HAUPT-FUNKTIONEN: HTML-Formulare oeffnen
' =====================================================

Public Sub OpenAuftragstamm_WebView2(Optional VA_ID As Long = 0)
    Dim jsonData As String
    jsonData = "{""form"":""frm_va_Auftragstamm"""
    If VA_ID > 0 Then
        jsonData = jsonData & ",""id"":" & VA_ID
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Auftragsverwaltung", 1500, 900, jsonData
End Sub

Public Sub OpenMitarbeiterstamm_WebView2(Optional MA_ID As Long = 0)
    Dim jsonData As String
    jsonData = "{""form"":""frm_MA_Mitarbeiterstamm"""
    If MA_ID > 0 Then
        jsonData = jsonData & ",""id"":" & MA_ID
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Mitarbeiterstamm", 1400, 900, jsonData
End Sub

Public Sub OpenKundenstamm_WebView2(Optional KD_ID As Long = 0)
    Dim jsonData As String
    jsonData = "{""form"":""frm_KD_Kundenstamm"""
    If KD_ID > 0 Then
        jsonData = jsonData & ",""id"":" & KD_ID
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Kundenstamm", 1300, 800, jsonData
End Sub

Public Sub OpenDienstplan_WebView2(Optional StartDatum As Date)
    Dim jsonData As String
    jsonData = "{""form"":""frm_N_DP_Dienstplan_MA"""
    If StartDatum > 0 Then
        jsonData = jsonData & ",""datum"":""" & Format(StartDatum, "yyyy-mm-dd") & """"
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Dienstplan MA", 1400, 800, jsonData
End Sub

Public Sub OpenObjekt_WebView2(Optional OB_ID As Long = 0)
    Dim jsonData As String
    jsonData = "{""form"":""frm_OB_Objekt"""
    If OB_ID > 0 Then
        jsonData = jsonData & ",""id"":" & OB_ID
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Objektverwaltung", 1200, 700, jsonData
End Sub

' =====================================================
' ZENTRALE WEBVIEW2 FORM-OEFFNUNG
' WebView2-Modus: Daten werden direkt via C# AccessDataBridge geladen
' KEIN API-Server noetig!
' =====================================================
Private Sub OpenWebView2Form(htmlPath As String, title As String, width As Long, height As Long, Optional jsonData As String = "{}")
    On Error GoTo ErrorHandler

    Dim cmd As String

    ' WICHTIG: WebView2-Modus braucht KEINEN API-Server!
    ' Daten werden direkt via C# AccessDataBridge aus Access geladen.
    ' StartAPIServerIfNeeded  ' <-- AUSKOMMENTIERT

    ' Pruefen ob HTML-Datei existiert
    If Dir(htmlPath) = "" Then
        MsgBox "HTML-Datei nicht gefunden:" & vbCrLf & htmlPath, vbExclamation, "CONSYS"
        Exit Sub
    End If

    ' Pruefen ob WebView2App.exe existiert
    If Dir(WEBVIEW2_EXE) = "" Then
        MsgBox "WebView2App.exe nicht gefunden:" & vbCrLf & WEBVIEW2_EXE, vbCritical, "CONSYS"
        Exit Sub
    End If

    ' JSON escapen fuer Kommandozeile
    Dim escapedJson As String
    escapedJson = Replace(jsonData, """", "\""")

    ' Kommandozeile bauen
    cmd = """" & WEBVIEW2_EXE & """ -html """ & htmlPath & """ -title """ & title & """ -width " & width & " -height " & height

    ' Daten anhaengen falls vorhanden
    If Len(jsonData) > 2 Then
        cmd = cmd & " -data """ & escapedJson & """"
    End If

    Debug.Print "[WebView2] Starte: " & cmd

    ' Ausfuehren via WScript.Shell (robuster als VBA Shell)
    ShellAndWait cmd, 1

    Debug.Print "[WebView2] Geoeffnet: " & htmlPath
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Oeffnen des HTML-Formulars:" & vbCrLf & Err.description, vbCritical, "CONSYS"
    Debug.Print "[WebView2] ERROR: " & Err.description
End Sub

' =====================================================
' TEST-FUNKTIONEN
' =====================================================
Public Sub Test_Auftragstamm()
    OpenAuftragstamm_WebView2
End Sub

Public Sub Test_Auftragstamm_ID()
    OpenAuftragstamm_WebView2 1
End Sub

Public Sub Test_Mitarbeiterstamm()
    OpenMitarbeiterstamm_WebView2
End Sub

Public Sub Test_Mitarbeiterstamm_ID()
    OpenMitarbeiterstamm_WebView2 707
End Sub

Public Sub Test_Kundenstamm()
    OpenKundenstamm_WebView2
End Sub

' =====================================================
' API-SERVER FUNKTIONEN
' =====================================================

' Prueft ob API-Server auf Port 5000 laeuft (mit Timeout)
Private Function IsAPIServerRunning() As Boolean
    On Error Resume Next

    Dim objHTTP As Object
    Set objHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

    ' Timeouts setzen: resolve, connect, send, receive (in Millisekunden)
    objHTTP.setTimeouts 1000, 1000, 1000, 2000

    objHTTP.Open "GET", "http://localhost:" & API_PORT & "/api/health", False
    objHTTP.setRequestHeader "Content-Type", "application/json"
    objHTTP.Send

    IsAPIServerRunning = (Err.Number = 0 And objHTTP.Status = 200)

    Set objHTTP = Nothing
    On Error GoTo 0
End Function

' Startet API-Server falls nicht bereits aktiv
Public Sub StartAPIServerIfNeeded()
    On Error GoTo ErrorHandler

    ' Erst pruefen ob Server bereits laeuft
    If IsAPIServerRunning() Then
        Debug.Print "[API] Server laeuft bereits auf Port " & API_PORT
        Exit Sub
    End If

    ' Pruefen ob mini_api.py existiert
    If Dir(API_SERVER_PATH) = "" Then
        Debug.Print "[API] mini_api.py nicht gefunden: " & API_SERVER_PATH
        MsgBox "mini_api.py nicht gefunden:" & vbCrLf & API_SERVER_PATH, vbExclamation, "CONSYS"
        Exit Sub
    End If

    Dim workDir As String
    workDir = Left(API_SERVER_PATH, InStrRev(API_SERVER_PATH, "\") - 1)

    ' Python API-Server im Hintergrund starten via WScript.Shell
    Dim wsh As Object
    Dim cmd As String

    Set wsh = CreateObject("WScript.Shell")

    ' Start minimiert im Hintergrund
    cmd = "cmd /c cd /d """ & workDir & """ && start /min ""API Server"" python mini_api.py"

    Debug.Print "[API] Starte Server: " & cmd
    wsh.Run cmd, 0, False

    Set wsh = Nothing

    Debug.Print "[API] Server wird gestartet auf Port " & API_PORT

    ' Warten bis Server hochgefahren (max 5 Sekunden)
    Dim i As Integer
    For i = 1 To 10
        DoEvents
        Sleep 500
        If IsAPIServerRunning() Then
            Debug.Print "[API] Server antwortet nach " & (i * 500) & "ms"
            Exit Sub
        End If
    Next i

    Debug.Print "[API] WARNUNG: Server antwortet nicht nach 5 Sekunden"
    Exit Sub

ErrorHandler:
    Debug.Print "[API] Fehler: " & Err.description
    MsgBox "Fehler beim Starten des API-Servers:" & vbCrLf & Err.description, vbExclamation, "CONSYS"
End Sub

' Manuell API-Server starten
Public Sub StartAPIServer()
    StartAPIServerIfNeeded
End Sub

' API-Server Status pruefen
Public Sub CheckAPIServer()
    If IsAPIServerRunning() Then
        MsgBox "API-Server laeuft auf Port " & API_PORT, vbInformation, "CONSYS"
    Else
        If MsgBox("API-Server laeuft NICHT." & vbCrLf & vbCrLf & _
                  "Soll der Server jetzt gestartet werden?", _
                  vbQuestion + vbYesNo, "CONSYS") = vbYes Then
            StartAPIServerIfNeeded
        End If
    End If
End Sub

' API-Server stoppen
Public Sub StopAPIServer()
    On Error Resume Next

    Dim wsh As Object
    Set wsh = CreateObject("WScript.Shell")

    ' Python-Prozess beenden der mini_api.py ausfuehrt
    wsh.Run "taskkill /f /fi ""WINDOWTITLE eq API Server""", 0, True

    Set wsh = Nothing
    Debug.Print "[API] Server gestoppt"
End Sub



' =====================================================
' TEST-FUNKTION fuer externen Aufruf (gibt Ergebnis zurueck)
' =====================================================
Public Function TestAPIServerConnection() As String
    On Error Resume Next
    
    If IsAPIServerRunning() Then
        TestAPIServerConnection = "OK: Server laeuft auf Port " & API_PORT
    Else
        TestAPIServerConnection = "FEHLER: Server nicht erreichbar"
    End If
    
    On Error GoTo 0
End Function

Public Function GetAPIServerStatus() As Boolean
    GetAPIServerStatus = IsAPIServerRunning()
End Function

