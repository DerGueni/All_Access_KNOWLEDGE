Attribute VB_Name = "mod_N_WebView2_Diagnose"
Option Compare Database
Option Explicit

' Einfache Pfad-Pruefung (ohne COM/GUI)
Public Function CheckPaths() As String
    On Error Resume Next
    Dim result As String
    result = ""

    ' HTML-Pfad
    Dim htmlPath As String
    htmlPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\shell.html"
    If Dir(htmlPath) <> "" Then
        result = result & "HTML:OK|"
    Else
        result = result & "HTML:FEHLT|"
    End If

    ' EXE-Pfad
    Dim exePath As String
    exePath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WebView2_Access\COM_Wrapper\ConsysWebView2App\bin\Release\ConsysWebView2App.exe"
    If Dir(exePath) <> "" Then
        result = result & "EXE:OK"
    Else
        result = result & "EXE:FEHLT"
    End If

    CheckPaths = result
End Function

' Nicht-interaktive Diagnose - gibt String zurueck
Public Function DiagnoseWebView2Silent() As String
    On Error Resume Next

    Dim webHost As Object
    Dim result As String

    result = "START|"

    Set webHost = CreateObject("Consys.WebView2Host")

    If Err.Number <> 0 Then
        DiagnoseWebView2Silent = result & "COM_ERROR:" & Err.Number & ":" & Err.Description
        Exit Function
    End If

    result = result & "COM_OK|"

    ' Initialize testen
    Err.Clear
    Dim initResult As Boolean
    initResult = webHost.Initialize()

    If Err.Number <> 0 Then
        DiagnoseWebView2Silent = result & "INIT_ERROR:" & Err.Number & ":" & Err.Description
        Exit Function
    End If

    If Not initResult Then
        DiagnoseWebView2Silent = result & "INIT_FAILED:" & webHost.LastError
        Exit Function
    End If

    result = result & "INIT_OK|"

    ' HTML-Pfad testen
    Dim htmlPath As String
    htmlPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_va_Auftragstamm.html"

    If Dir(htmlPath) = "" Then
        DiagnoseWebView2Silent = result & "HTML_NOT_FOUND:" & htmlPath
        Exit Function
    End If

    result = result & "HTML_OK|"

    ' Navigate
    Err.Clear
    webHost.Navigate htmlPath

    If Err.Number <> 0 Then
        DiagnoseWebView2Silent = result & "NAV_ERROR:" & Err.Number & ":" & Err.Description
        Exit Function
    End If

    result = result & "NAV_OK|"

    ' Show (ohne Warten)
    webHost.SetBounds 100, 50, 1400, 900
    webHost.Show

    result = result & "SHOW_OK|SUCCESS"
    DiagnoseWebView2Silent = result
End Function

' Test mit Daten
Public Function TestAuftragstammMitDaten() As String
    On Error Resume Next

    Dim webHost As Object
    Dim htmlPath As String
    Dim jsonData As String
    Dim result As String

    result = "TEST_START|"

    ' COM erstellen
    Set webHost = CreateObject("Consys.WebView2Host")
    If Err.Number <> 0 Then
        TestAuftragstammMitDaten = result & "COM_ERROR:" & Err.Description
        Exit Function
    End If
    result = result & "COM_OK|"

    ' Initialize
    If Not webHost.Initialize() Then
        TestAuftragstammMitDaten = result & "INIT_FAILED:" & webHost.LastError
        Exit Function
    End If
    result = result & "INIT_OK|"

    ' HTML laden
    htmlPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_va_Auftragstamm.html"
    webHost.SetBounds 100, 50, 1500, 900
    webHost.Navigate htmlPath
    webHost.Show
    result = result & "SHOW_OK|"

    ' Warten bis geladen
    Dim i As Integer
    For i = 1 To 20
        DoEvents
    Next i

    ' Test-Daten senden
    jsonData = "{""event"":""onDataReceived"",""data"":{""type"":""auftraege_liste"",""records"":[{""ID"":1,""Auftrag"":""Test Auftrag"",""Objekt"":""Test Objekt"",""Ort"":""Nuernberg"",""Dat_VA_Von"":""2026-01-15""}]}}"

    Err.Clear
    webHost.PostWebMessage jsonData
    If Err.Number <> 0 Then
        TestAuftragstammMitDaten = result & "MSG_ERROR:" & Err.Description
        Exit Function
    End If

    result = result & "MSG_OK|SUCCESS"
    TestAuftragstammMitDaten = result
End Function
