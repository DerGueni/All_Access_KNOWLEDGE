Attribute VB_Name = "mod_VBA_Bridge"
Option Compare Database
Option Explicit

' ============================================
' CONSEC Server Auto-Starter
' ============================================
' Startet API Server und VBA Bridge automatisch
' beim Oeffnen des Access-Frontends.
'
' EINRICHTUNG:
' 1. Dieses Modul importieren
' 2. In fAutoexec() aufrufen:
'    - StartAPIServer
'    - StartVBABridge
' ============================================

Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
    ByVal hwnd As LongPtr, _
    ByVal lpOperation As String, _
    ByVal lpFile As String, _
    ByVal lpParameters As String, _
    ByVal lpDirectory As String, _
    ByVal nShowCmd As Long) As LongPtr

Private Const SW_HIDE As Long = 0

' Pfade zu den Server-Startern
Private Const API_SERVER_PATH As String = "C:\Users\guenther.siegert\Documents\Access Bridge\start_api_silent.vbs"
' GEAENDERT 18.01.2026: Watchdog statt direkter Start (automatischer Neustart bei Crash)
Private Const VBA_BRIDGE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\start_vba_bridge_watchdog.vbs"

' ============================================
' API SERVER (Port 5000)
' ============================================

Public Function StartAPIServer() As Boolean
    On Error GoTo Err_Handler

    ' Pruefen ob bereits laeuft
    If IsAPIServerRunning() Then
        Debug.Print "[API Server] Laeuft bereits"
        StartAPIServer = True
        Exit Function
    End If

    ' Server starten (versteckt)
    Debug.Print "[API Server] Starte..."
    ShellExecute 0, "open", "wscript.exe", """" & API_SERVER_PATH & """", "", SW_HIDE

    ' Kurz warten und pruefen
    Dim i As Integer
    For i = 1 To 10
        DoEvents
        Call SleepMs(500)
        If IsAPIServerRunning() Then
            Debug.Print "[API Server] Erfolgreich gestartet"
            StartAPIServer = True
            Exit Function
        End If
    Next i

    Debug.Print "[API Server] Konnte nicht gestartet werden"
    StartAPIServer = False
    Exit Function

Err_Handler:
    Debug.Print "[API Server] Fehler: " & Err.Description
    StartAPIServer = False
End Function

Public Function IsAPIServerRunning() As Boolean
    On Error GoTo Err_Handler

    Dim http As Object
    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")

    http.Open "GET", "http://localhost:5000/api/health", False
    http.setTimeouts 1000, 1000, 1000, 1000
    http.send

    IsAPIServerRunning = (http.Status = 200)

    Set http = Nothing
    Exit Function

Err_Handler:
    IsAPIServerRunning = False
End Function

Public Function StopAPIServer() As Boolean
    On Error GoTo Err_Handler

    Shell "powershell -WindowStyle Hidden -Command ""Get-Process pythonw | Where-Object {$_.MainWindowTitle -eq ''} | Stop-Process""", vbHide
    StopAPIServer = True
    Exit Function

Err_Handler:
    StopAPIServer = False
End Function

' ============================================
' VBA BRIDGE (Port 5002)
' ============================================

Public Function StartVBABridge() As Boolean
    On Error GoTo Err_Handler

    ' Pruefen ob bereits laeuft
    If IsVBABridgeRunning() Then
        Debug.Print "[VBA Bridge] Laeuft bereits"
        StartVBABridge = True
        Exit Function
    End If

    ' Bridge starten (versteckt)
    Debug.Print "[VBA Bridge] Starte..."
    ShellExecute 0, "open", "wscript.exe", """" & VBA_BRIDGE_PATH & """", "", SW_HIDE

    ' Kurz warten und pruefen
    Dim i As Integer
    For i = 1 To 10
        DoEvents
        Call SleepMs(500)
        If IsVBABridgeRunning() Then
            Debug.Print "[VBA Bridge] Erfolgreich gestartet"
            StartVBABridge = True
            Exit Function
        End If
    Next i

    Debug.Print "[VBA Bridge] Konnte nicht gestartet werden"
    StartVBABridge = False
    Exit Function

Err_Handler:
    Debug.Print "[VBA Bridge] Fehler: " & Err.Description
    StartVBABridge = False
End Function

Public Function IsVBABridgeRunning() As Boolean
    On Error GoTo Err_Handler

    Dim http As Object
    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")

    http.Open "GET", "http://localhost:5002/api/vba/status", False
    http.setTimeouts 1000, 1000, 1000, 1000
    http.send

    IsVBABridgeRunning = (http.Status = 200)

    Set http = Nothing
    Exit Function

Err_Handler:
    IsVBABridgeRunning = False
End Function

Public Function StopVBABridge() As Boolean
    On Error GoTo Err_Handler

    Shell "wscript.exe ""C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\stop_vba_bridge.vbs""", vbHide
    StopVBABridge = True
    Exit Function

Err_Handler:
    StopVBABridge = False
End Function

' ============================================
' HELPER FUNCTIONS
' ============================================

Private Sub SleepMs(ms As Long)
    Dim endTime As Double
    endTime = Timer + (ms / 1000)
    Do While Timer < endTime
        DoEvents
    Loop
End Sub
