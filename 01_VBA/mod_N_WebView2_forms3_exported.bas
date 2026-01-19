Attribute VB_Name = "mod_N_WebView2_forms3"
' =====================================================
' mod_N_WebView2_forms3
' WebView2 Integration fuer forms3 HTML-Formulare
' Korrigiert: 05.01.2026 - Parameter via -data statt URL-Query
' =====================================================

' Pfade
Private Const FORMS3_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\"
Private Const WEBVIEW2_EXE As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe"
Private Const API_SERVER_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts\mini_api.py"
Private Const API_PORT As Integer = 5000
Private Const HTML_PORT As Integer = 8081

' Windows API fuer Sleep
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)

' =====================================================
' HAUPT-FUNKTIONEN: HTML-Formulare oeffnen
' =====================================================

Public Sub OpenAuftragstamm_WebView2(Optional VA_ID As Long = 0)
    ' Fallback zu Browser-Modus wenn WebView2App nicht existiert
    If Dir(WEBVIEW2_EXE) = "" Then
        Debug.Print "[WebView2] WebView2App.exe fehlt - Fallback zu Browser-Modus"
        OpenAuftragstamm_Browser VA_ID
        Exit Sub
    End If

    Dim jsonData As String
    jsonData = "{""form"":""frm_va_Auftragstamm"""
    If VA_ID > 0 Then
        jsonData = jsonData & ",""id"":" & VA_ID
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Auftragsverwaltung", 1500, 900, jsonData
End Sub

Public Sub OpenMitarbeiterstamm_WebView2(Optional MA_ID As Long = 0)
    ' Fallback zu Browser-Modus wenn WebView2App nicht existiert
    If Dir(WEBVIEW2_EXE) = "" Then
        Debug.Print "[WebView2] WebView2App.exe fehlt - Fallback zu Browser-Modus"
        OpenMitarbeiterstamm_Browser MA_ID
        Exit Sub
    End If

    Dim jsonData As String
    jsonData = "{""form"":""frm_MA_Mitarbeiterstamm"""
    If MA_ID > 0 Then
        jsonData = jsonData & ",""id"":" & MA_ID
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Mitarbeiterstamm", 1400, 900, jsonData
End Sub

Public Sub OpenKundenstamm_WebView2(Optional KD_ID As Long = 0)
    ' Fallback zu Browser-Modus wenn WebView2App nicht existiert
    If Dir(WEBVIEW2_EXE) = "" Then
        Debug.Print "[WebView2] WebView2App.exe fehlt - Fallback zu Browser-Modus"
        OpenKundenstamm_Browser KD_ID
        Exit Sub
    End If

    Dim jsonData As String
    jsonData = "{""form"":""frm_KD_Kundenstamm"""
    If KD_ID > 0 Then
        jsonData = jsonData & ",""id"":" & KD_ID
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Kundenstamm", 1300, 800, jsonData
End Sub

Public Sub OpenDienstplan_WebView2(Optional StartDatum As Date)
    ' Fallback zu Browser-Modus wenn WebView2App nicht existiert
    If Dir(WEBVIEW2_EXE) = "" Then
        Debug.Print "[WebView2] WebView2App.exe fehlt - Fallback zu Browser-Modus"
        OpenDienstplan_Browser StartDatum
        Exit Sub
    End If

    Dim jsonData As String
    jsonData = "{""form"":""frm_N_DP_Dienstplan_MA"""
    If StartDatum > 0 Then
        jsonData = jsonData & ",""datum"":""" & Format(StartDatum, "yyyy-mm-dd") & """"
    End If
    jsonData = jsonData & "}"

    OpenWebView2Form FORMS3_PATH & "shell.html", "Dienstplan MA", 1400, 800, jsonData
End Sub

Public Sub OpenObjekt_WebView2(Optional OB_ID As Long = 0)
    ' Fallback zu Browser-Modus wenn WebView2App nicht existiert
    If Dir(WEBVIEW2_EXE) = "" Then
        Debug.Print "[WebView2] WebView2App.exe fehlt - Fallback zu Browser-Modus"
        OpenObjekt_Browser OB_ID
        Exit Sub
    End If

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
' =====================================================
Private Sub OpenWebView2Form(htmlPath As String, title As String, width As Long, height As Long, Optional jsonData As String = "{}")
    On Error GoTo ErrorHandler

    Dim cmd As String

    ' API-Server deaktiviert - WebView2 nutzt direkte Kommunikation
    ' StartAPIServerIfNeeded

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

    ' Ausfuehren
    Shell cmd, vbNormalFocus

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
' API-SERVER FUNKTIONEN (fuer Browser-Fallback)
' =====================================================

' Prueft ob API-Server auf Port 5000 laeuft
Private Function IsAPIServerRunning() As Boolean
    On Error Resume Next

    Dim objHTTP As Object
    Set objHTTP = CreateObject("MSXML2.XMLHTTP")

    objHTTP.Open "GET", "http://localhost:" & API_PORT & "/api/health", False
    objHTTP.setRequestHeader "Content-Type", "application/json"
    objHTTP.Send

    IsAPIServerRunning = (objHTTP.Status = 200)

    Set objHTTP = Nothing
    On Error GoTo 0
End Function

' Startet API-Server falls nicht bereits aktiv
Public Sub StartAPIServerIfNeeded()
    On Error GoTo ErrorHandler

    If IsAPIServerRunning() Then
        Debug.Print "[API] Server laeuft bereits auf Port " & API_PORT
        Exit Sub
    End If

    ' Pruefen ob mini_api.py existiert
    If Dir(API_SERVER_PATH) = "" Then
        Debug.Print "[API] mini_api.py nicht gefunden: " & API_SERVER_PATH
        Exit Sub
    End If

    Dim cmd As String
    Dim workDir As String
    workDir = Left(API_SERVER_PATH, InStrRev(API_SERVER_PATH, "\") - 1)

    ' Python API-Server im Hintergrund starten
    cmd = "cmd /c cd /d """ & workDir & """ && start /min python mini_api.py"
    Shell cmd, vbHide

    Debug.Print "[API] Server gestartet auf Port " & API_PORT

    ' Kurz warten bis Server hochgefahren (2 Sekunden)
    DoEvents
    Sleep 2000

    Exit Sub

ErrorHandler:
    Debug.Print "[API] Fehler: " & Err.description
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

' =====================================================
' BROWSER-MODUS: Formulare im Standard-Browser oeffnen
' Der API-Server serviert HTML + Daten auf localhost:5000
' =====================================================

' Auftragsverwaltung im Browser oeffnen (via shell.html fuer Sidebar!)
Public Sub OpenAuftragstamm_Browser(Optional VA_ID As Long = 0)
    StartAPIServerIfNeeded

    Dim url As String
    url = "http://localhost:" & HTML_PORT & "/shell.html?form=frm_va_Auftragstamm"
    If VA_ID > 0 Then url = url & "&id=" & VA_ID

    Shell "cmd /c start """" """ & url & """", vbHide
    Debug.Print "[Browser] Geoeffnet: " & url
End Sub

' Mitarbeiterstamm im Browser oeffnen (via shell.html fuer Sidebar!)
Public Sub OpenMitarbeiterstamm_Browser(Optional MA_ID As Long = 0)
    StartAPIServerIfNeeded

    Dim url As String
    url = "http://localhost:" & HTML_PORT & "/shell.html?form=frm_MA_Mitarbeiterstamm"
    If MA_ID > 0 Then url = url & "&id=" & MA_ID

    Shell "cmd /c start """" """ & url & """", vbHide
    Debug.Print "[Browser] Geoeffnet: " & url
End Sub

' Kundenstamm im Browser oeffnen (via shell.html fuer Sidebar!)
Public Sub OpenKundenstamm_Browser(Optional KD_ID As Long = 0)
    StartAPIServerIfNeeded

    Dim url As String
    url = "http://localhost:" & HTML_PORT & "/shell.html?form=frm_KD_Kundenstamm"
    If KD_ID > 0 Then url = url & "&id=" & KD_ID

    Shell "cmd /c start """" """ & url & """", vbHide
    Debug.Print "[Browser] Geoeffnet: " & url
End Sub

' Objektverwaltung im Browser oeffnen (via shell.html fuer Sidebar!)
Public Sub OpenObjekt_Browser(Optional OB_ID As Long = 0)
    StartAPIServerIfNeeded

    Dim url As String
    url = "http://localhost:" & HTML_PORT & "/shell.html?form=frm_OB_Objekt"
    If OB_ID > 0 Then url = url & "&id=" & OB_ID

    Shell "cmd /c start """" """ & url & """", vbHide
    Debug.Print "[Browser] Geoeffnet: " & url
End Sub

' Dienstplan im Browser oeffnen (via shell.html fuer Sidebar!)
Public Sub OpenDienstplan_Browser(Optional StartDatum As Date)
    StartAPIServerIfNeeded

    Dim url As String
    url = "http://localhost:" & HTML_PORT & "/shell.html?form=frm_N_DP_Dienstplan_MA"
    If StartDatum > 0 Then url = url & "&datum=" & Format(StartDatum, "yyyy-mm-dd")

    Shell "cmd /c start """" """ & url & """", vbHide
    Debug.Print "[Browser] Geoeffnet: " & url
End Sub

' Hauptmenue/Dashboard im Browser oeffnen (shell.html ohne Form = Menuefuehrung)
Public Sub OpenHTMLAnsicht()
    StartAPIServerIfNeeded

    Dim url As String
    url = "http://localhost:" & HTML_PORT & "/shell.html"

    Shell "cmd /c start """" """ & url & """", vbHide
    Debug.Print "[Browser] Geoeffnet: " & url
End Sub
