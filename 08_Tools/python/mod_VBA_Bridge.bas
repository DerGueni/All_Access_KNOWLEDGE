Attribute VB_Name = "mod_VBA_Bridge"
Option Compare Database
Option Explicit

' ============================================
' CONSEC VBA Bridge - Auto-Starter
' ============================================
' Startet die VBA Bridge automatisch beim
' Öffnen des Access-Frontends.
'
' EINRICHTUNG:
' 1. Dieses Modul importieren
' 2. In AutoExec-Makro aufrufen: RunCode "StartVBABridge()"
'    ODER im Form_Load des Startformulars aufrufen
' ============================================

Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
    ByVal hwnd As LongPtr, _
    ByVal lpOperation As String, _
    ByVal lpFile As String, _
    ByVal lpParameters As String, _
    ByVal lpDirectory As String, _
    ByVal nShowCmd As Long) As LongPtr

Private Const SW_HIDE As Long = 0

' Pfad zum VBA Bridge Starter
Private Const VBA_BRIDGE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\vba_bridge_hidden.vbs"

' ============================================
' Hauptfunktion - Beim DB-Start aufrufen
' ============================================
Public Function StartVBABridge() As Boolean
    On Error GoTo Err_Handler
    
    ' Prüfen ob bereits läuft
    If IsVBABridgeRunning() Then
        Debug.Print "[VBA Bridge] Läuft bereits"
        StartVBABridge = True
        Exit Function
    End If
    
    ' Bridge starten (versteckt)
    Debug.Print "[VBA Bridge] Starte..."
    ShellExecute 0, "open", "wscript.exe", """" & VBA_BRIDGE_PATH & """", "", SW_HIDE
    
    ' Kurz warten und prüfen
    Dim i As Integer
    For i = 1 To 10  ' Max 5 Sekunden warten
        DoEvents
        Sleep 500
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

' ============================================
' Prüft ob VBA Bridge läuft
' ============================================
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

' ============================================
' VBA Bridge stoppen (optional)
' ============================================
Public Function StopVBABridge() As Boolean
    On Error GoTo Err_Handler
    
    Shell "wscript.exe ""C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\stop_vba_bridge.vbs""", vbHide
    StopVBABridge = True
    Exit Function
    
Err_Handler:
    StopVBABridge = False
End Function

' ============================================
' Sleep-Funktion
' ============================================
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
