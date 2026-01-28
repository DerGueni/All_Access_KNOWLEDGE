Attribute VB_Name = "mod_HTMLAnsicht_Vollautomatisch"
' =====================================================
' mod_HTMLAnsicht_Vollautomatisch
' VOLLAUTOMATISCHER START beim HTML Ansicht Button-Klick
' Startet API-Server mit WATCHDOG fuer Auto-Restart bei Crash
' Erstellt: 14.01.2026 | Aktualisiert: 17.01.2026
' =====================================================

' Windows API
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)

' Pfade - WATCHDOG statt quick_api_server
Private Const API_SERVER_DIR As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\"
Private Const WATCHDOG_SCRIPT As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\api_server_watchdog.py"
Private Const WATCHDOG_VBS As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\START_API_WATCHDOG_SILENT.vbs"
Private Const API_PORT As Integer = 5000
Private Const SHELL_URL As String = "http://localhost:3000/shell.html"

' Chrome mit Remote Debugging (fuer DevTools MCP)
Private Const CHROME_DEBUG_PORT As Integer = 9222
Private Const CHROME_PATH_1 As String = "C:\Program Files\Google\Chrome\Application\chrome.exe"
Private Const CHROME_PATH_2 As String = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

' =====================================================
' HAUPTFUNKTION - WIRD VOM BUTTON AUFGERUFEN
' =====================================================
Public Sub HTMLAnsicht()
    On Error GoTo ErrorHandler

    Debug.Print "[HTMLAnsicht] Button geklickt - starte ALLES automatisch..."

    ' Schritt 1: Pruefe ob Server bereits laeuft
    If IsAPIServerRunning() Then
        Debug.Print "[HTMLAnsicht] API Server laeuft bereits - oeffne Browser direkt"
        OpenBrowser
        Exit Sub
    End If

    ' Schritt 2: Starte Watchdog (ueberwacht und startet API-Server automatisch)
    Debug.Print "[HTMLAnsicht] Starte API-Server mit Watchdog..."
    StartWatchdogServer

    ' Schritt 3: Warte bis Server hochgefahren (Watchdog startet Server)
    Debug.Print "[HTMLAnsicht] Warte auf Server-Start (5 Sekunden)..."
    Sleep 5000

    ' Schritt 4: Pruefe ob Server jetzt laeuft
    If Not IsAPIServerRunning() Then
        Debug.Print "[HTMLAnsicht] Server noch nicht bereit - warte weitere 3 Sekunden..."
        Sleep 3000
    End If

    ' Schritt 5: Oeffne Browser mit shell.html
    Debug.Print "[HTMLAnsicht] Oeffne Browser..."
    OpenBrowser

    Debug.Print "[HTMLAnsicht] FERTIG - Watchdog ueberwacht Server!"
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Starten:" & vbCrLf & Err.Description, vbCritical, "HTML Ansicht"
    Debug.Print "[HTMLAnsicht] ERROR: " & Err.Description
End Sub

' =====================================================
' PRUEFE OB API SERVER LAEUFT
' =====================================================
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

' =====================================================
' STARTE API SERVER MIT WATCHDOG
' =====================================================
Private Sub StartWatchdogServer()
    On Error GoTo ErrorHandler

    Dim objShell As Object
    Set objShell = CreateObject("WScript.Shell")

    ' Pruefe ob Watchdog VBS existiert (bevorzugt - startet unsichtbar)
    If Dir(WATCHDOG_VBS) <> "" Then
        Debug.Print "[Watchdog] Starte via VBS (unsichtbar)..."
        objShell.Run """" & WATCHDOG_VBS & """", 0, False
        Debug.Print "[Watchdog] VBS gestartet - Watchdog ueberwacht Server"
        Set objShell = Nothing
        Exit Sub
    End If

    ' Fallback: Pruefe ob Python Watchdog existiert
    If Dir(WATCHDOG_SCRIPT) = "" Then
        MsgBox "Watchdog nicht gefunden:" & vbCrLf & WATCHDOG_SCRIPT & vbCrLf & vbCrLf & _
               "Bitte pruefen ob die Datei existiert.", _
               vbCritical, "HTML Ansicht"
        Exit Sub
    End If

    Debug.Print "[Watchdog] api_server_watchdog.py gefunden"

    ' Pruefe ob Python installiert ist
    Dim objExec As Object
    Set objExec = objShell.Exec("python --version")

    If objExec.Status <> 0 Then
        MsgBox "Python ist nicht installiert!" & vbCrLf & _
               "Bitte Python 3.9+ installieren: https://python.org", _
               vbCritical, "HTML Ansicht"
        Exit Sub
    End If

    Debug.Print "[Watchdog] Python OK"

    ' Starte Watchdog im Hintergrund (ueberwacht und startet API-Server)
    Debug.Print "[Watchdog] Starte api_server_watchdog.py..."

    Dim cmd As String
    cmd = "cmd /c cd /d """ & API_SERVER_DIR & """ && python api_server_watchdog.py"

    objShell.Run cmd, 6, False

    Debug.Print "[Watchdog] API Server Watchdog gestartet - ueberwacht automatisch!"

    Set objExec = Nothing
    Set objShell = Nothing
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Watchdog-Start:" & vbCrLf & Err.Description, vbCritical, "HTML Ansicht"
    Debug.Print "[Watchdog] ERROR: " & Err.Description
End Sub

' =====================================================
' PRUEFE OB CHROME MIT REMOTE DEBUGGING LAEUFT
' =====================================================
Private Function IsChromeDebugRunning() As Boolean
    On Error Resume Next

    Dim objHTTP As Object
    Set objHTTP = CreateObject("MSXML2.XMLHTTP")

    ' Pruefe ob DevTools Port erreichbar ist
    objHTTP.Open "GET", "http://localhost:" & CHROME_DEBUG_PORT & "/json/version", False
    objHTTP.Send

    IsChromeDebugRunning = (objHTTP.Status = 200)

    Set objHTTP = Nothing
    On Error GoTo 0
End Function

' =====================================================
' FINDE CHROME PFAD
' =====================================================
Private Function GetChromePath() As String
    If Dir(CHROME_PATH_1) <> "" Then
        GetChromePath = CHROME_PATH_1
    ElseIf Dir(CHROME_PATH_2) <> "" Then
        GetChromePath = CHROME_PATH_2
    Else
        ' Versuche ueber Registry
        On Error Resume Next
        Dim objShell As Object
        Set objShell = CreateObject("WScript.Shell")
        GetChromePath = objShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe\")
        Set objShell = Nothing
        On Error GoTo 0
    End If
End Function

' =====================================================
' STARTE CHROME MIT REMOTE DEBUGGING
' =====================================================
Private Sub StartChromeWithDebug()
    On Error GoTo ErrorHandler

    Dim chromePath As String
    chromePath = GetChromePath()

    If chromePath = "" Then
        Debug.Print "[Chrome] Chrome nicht gefunden - nutze Standard-Browser"
        Exit Sub
    End If

    Debug.Print "[Chrome] Starte Chrome mit Remote Debugging auf Port " & CHROME_DEBUG_PORT

    Dim objShell As Object
    Set objShell = CreateObject("WScript.Shell")

    ' Chrome mit Remote Debugging starten
    Dim cmd As String
    cmd = """" & chromePath & """ --remote-debugging-port=" & CHROME_DEBUG_PORT & _
          " --user-data-dir=""%TEMP%\chrome-debug-consys"" """ & SHELL_URL & """"

    objShell.Run cmd, 1, False

    Debug.Print "[Chrome] Chrome mit DevTools gestartet - Port " & CHROME_DEBUG_PORT

    Set objShell = Nothing
    Exit Sub

ErrorHandler:
    Debug.Print "[Chrome] Fehler: " & Err.Description
End Sub

' =====================================================
' OEFFNE BROWSER MIT SHELL.HTML
' =====================================================
Private Sub OpenBrowser()
    On Error GoTo ErrorHandler

    Debug.Print "[Browser] Oeffne: " & SHELL_URL

    Dim objShell As Object
    Set objShell = CreateObject("WScript.Shell")

    ' Pruefe ob Chrome mit Remote Debugging bereits laeuft
    If IsChromeDebugRunning() Then
        Debug.Print "[Browser] Chrome Debug laeuft bereits - oeffne neuen Tab"
        ' Oeffne URL in bestehendem Chrome mit Debug
        objShell.Run "cmd /c start """" """ & SHELL_URL & """", 0, False
    Else
        ' Starte Chrome mit Remote Debugging
        Debug.Print "[Browser] Starte Chrome mit Remote Debugging..."
        StartChromeWithDebug
    End If

    Debug.Print "[Browser] Shell.html oeffnet sich..."

    Set objShell = Nothing
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Browser-Start:" & vbCrLf & Err.Description, vbCritical, "HTML Ansicht"
    Debug.Print "[Browser] ERROR: " & Err.Description
End Sub

' =====================================================
' TEST-FUNKTIONEN (fuer Debugging)
' =====================================================

Public Sub Test_IsServerRunning()
    If IsAPIServerRunning() Then
        MsgBox "API Server LAEUFT auf Port " & API_PORT, vbInformation, "Status"
    Else
        MsgBox "API Server LAEUFT NICHT", vbExclamation, "Status"
    End If
End Sub

Public Sub Test_StartWatchdog()
    MsgBox "Starte Watchdog..." & vbCrLf & vbCrLf & _
           "Der Watchdog startet den API-Server und" & vbCrLf & _
           "startet ihn automatisch bei Crash neu.", vbInformation, "Test"
    StartWatchdogServer
    Sleep 5000
    If IsAPIServerRunning() Then
        MsgBox "Watchdog laeuft - Server ist aktiv!" & vbCrLf & vbCrLf & _
               "Bei Server-Crash wird automatisch neu gestartet.", vbInformation, "Test"
    Else
        MsgBox "Server konnte nicht gestartet werden" & vbCrLf & _
               "Bitte Watchdog-Log pruefen.", vbExclamation, "Test"
    End If
End Sub

Public Sub Test_OpenBrowser()
    If IsAPIServerRunning() Then
        OpenBrowser
    Else
        MsgBox "Server laeuft nicht - starte zuerst mit HTMLAnsicht()", vbExclamation, "Test"
    End If
End Sub

' =====================================================
' STOP WATCHDOG (falls noetig)
' =====================================================
Public Sub StopWatchdog()
    On Error Resume Next
    Dim objShell As Object
    Set objShell = CreateObject("WScript.Shell")

    ' Beende alle Python-Prozesse (Watchdog + API-Server)
    objShell.Run "taskkill /F /IM python.exe", 0, True
    objShell.Run "taskkill /F /IM pythonw.exe", 0, True

    MsgBox "Watchdog und API-Server wurden gestoppt.", vbInformation, "Stop"
    Set objShell = Nothing
End Sub
