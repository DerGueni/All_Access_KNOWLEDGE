' =====================================================
' mdl_N_APIServer_AutoStart - Automatischer API-Server Start
' Version 1.1
' Startet den Flask API-Server automatisch beim Öffnen
' der HTML-Formulare
' =====================================================

' Konfiguration
Private Const API_SERVER_PATH As String = "C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py"
Private Const API_SERVER_PORT As Long = 5000
Private Const PYTHON_PATH As String = "python"

' Globale Variable für Server-Status
Private g_APIServerStarted As Boolean

' =====================================================
' ÖFFENTLICHE FUNKTIONEN
' =====================================================

' Prüft ob der API-Server läuft und startet ihn falls nötig
Public Function EnsureAPIServerRunning() As Boolean
    On Error GoTo ErrorHandler

    ' Bereits gestartet in dieser Session?
    If g_APIServerStarted Then
        If IsServerResponding() Then
            EnsureAPIServerRunning = True
            Exit Function
        End If
    End If

    ' Prüfe ob Server bereits läuft
    If IsServerResponding() Then
        g_APIServerStarted = True
        Debug.Print "[API] Server läuft bereits auf Port " & API_SERVER_PORT
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
            Application.Wait Now + TimeValue("00:00:00.5")
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

' Prüft ob der Server antwortet
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

' Startet den API-Server als Hintergrund-Prozess
Private Function StartAPIServer() As Boolean
    On Error GoTo ErrorHandler

    Dim cmd As String
    Dim wsh As Object

    ' Prüfe ob Python-Skript existiert
    If Dir(API_SERVER_PATH) = "" Then
        Debug.Print "[API] Server-Datei nicht gefunden: " & API_SERVER_PATH
        StartAPIServer = False
        Exit Function
    End If

    ' Kommando bauen (minimiert starten)
    cmd = "cmd /c start /min """ & PYTHON_PATH & """ """ & API_SERVER_PATH & """"

    ' Alternativ: Direkt Python starten (sichtbar für Debugging)
    ' cmd = """" & PYTHON_PATH & """ """ & API_SERVER_PATH & """"

    ' Shell ausführen
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

' =====================================================
' AUTOEXEC-INTEGRATION
' =====================================================

' Diese Funktion kann aus AutoExec aufgerufen werden
Public Sub AutoExec_StartAPIServer()
    ' Nur starten wenn HTML-Funktionen genutzt werden sollen
    ' Kann bei Bedarf automatisch beim DB-Start aufgerufen werden

    Debug.Print "[API] AutoExec: API-Server wird geprüft..."

    If EnsureAPIServerRunning() Then
        Debug.Print "[API] AutoExec: Server bereit"
    Else
        Debug.Print "[API] AutoExec: Server nicht verfügbar"
    End If
End Sub

' =====================================================
' WRAPPER FÜR HTML-FORMULAR AUFRUF
' =====================================================

' Öffnet ein HTML-Formular mit automatischem Server-Start
Public Sub OpenHTMLFormWithServer(formName As String, Optional ID As Long = 0)
    ' Stelle sicher dass Server läuft
    If Not EnsureAPIServerRunning() Then
        Dim answer As VbMsgBoxResult
        answer = MsgBox("Der API-Server konnte nicht gestartet werden." & vbCrLf & _
                       "HTML-Formular trotzdem öffnen?" & vbCrLf & vbCrLf & _
                       "(Daten werden nicht geladen)", _
                       vbYesNo + vbQuestion, "API-Server nicht verfügbar")
        If answer = vbNo Then Exit Sub
    End If

    ' Formular öffnen
    Select Case LCase(formName)
        Case "auftragstamm", "frm_va_auftragstamm"
            OpenAuftragstammHTML ID
        Case "mitarbeiterstamm", "frm_ma_mitarbeiterstamm"
            OpenMitarbeiterstammHTML ID
        Case "kundenstamm", "frm_kd_kundenstamm"
            OpenKundenstammHTML ID
        Case Else
            MsgBox "Unbekanntes Formular: " & formName, vbExclamation
    End Select
End Sub
