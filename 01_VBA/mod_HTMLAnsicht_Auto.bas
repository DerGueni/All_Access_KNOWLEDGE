Attribute VB_Name = "mod_HTMLAnsicht_Auto"
' =====================================================
' mod_HTMLAnsicht_Auto
' Automatischer Start beim HTML Ansicht Button-Klick
' Erstellt: 14.01.2026
' =====================================================

' Windows API
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)

' Pfade
Private Const SCRIPT_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_scripts\START_ALLES.bat"
Private Const API_PORT As Integer = 5000
Private Const API_HEALTH_URL As String = "http://localhost:5000/api/health"
Private Const SHELL_HTML_URL As String = "http://localhost:5000/shell.html"

' =====================================================
' HAUPTFUNKTION: HTML ANSICHT BUTTON
' Dies ist die Funktion die der Button aufruft
' =====================================================
Public Sub HTMLAnsicht()
    On Error GoTo ErrorHandler
    
    Debug.Print "[HTMLAnsicht] Button geklickt - starte automatisch..."
    
    ' Schritt 1: START_ALLES.bat ausführen (startet alle Server)
    StartAllServers
    
    Debug.Print "[HTMLAnsicht] Alle Server sollten jetzt laufen"
    OpenHTMLAnsicht = True
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler:" & vbCrLf & Err.Description, vbCritical, "HTML Ansicht Fehler"
    Debug.Print "[HTMLAnsicht] ERROR: " & Err.Description
End Sub

' =====================================================
' STARTET START_ALLES.BAT (alle Server automatisch)
' =====================================================
Private Sub StartAllServers()
    ' Prüfe ob Datei existiert
    If Dir(SCRIPT_PATH) = "" Then
        MsgBox "START_ALLES.bat nicht gefunden:" & vbCrLf & SCRIPT_PATH, vbCritical, "CONSYS"
        Exit Sub
    End If
    
    Debug.Print "[Servers] Führe aus: " & SCRIPT_PATH
    
    ' Starte START_ALLES.bat (mit sichtbarem Fenster)
    Shell SCRIPT_PATH, vbNormalFocus
    
    Debug.Print "[Servers] START_ALLES.bat gestartet"
    Debug.Print "[Servers] - Mini API Server startet..."
    Debug.Print "[Servers] - Browser wird geöffnet..."
    Debug.Print "[Servers] - Access Frontend wird geladen..."
End Sub

' =====================================================
' ALTERNATIV: Direkt OpenHTMLAnsicht() aufrufen
' (Falls Button direkt diese Funktion aufruft)
' =====================================================
Public Function OpenHTMLAnsicht() As Boolean
    On Error GoTo ErrorHandler
    
    ' START_ALLES.bat ausführen
    If Dir(SCRIPT_PATH) = "" Then
        MsgBox "START_ALLES.bat nicht gefunden!", vbCritical, "CONSYS"
        OpenHTMLAnsicht = False
        Exit Function
    End If
    
    Debug.Print "[OpenHTML] Starte START_ALLES.bat..."
    Shell SCRIPT_PATH, vbNormalFocus
    
    OpenHTMLAnsicht = True
    Exit Function
    
ErrorHandler:
    MsgBox "Fehler: " & Err.Description, vbCritical, "CONSYS"
    OpenHTMLAnsicht = False
End Function

' =====================================================
' PRÜFE OB API-SERVER LÄUFT
' =====================================================
Public Function IsAPIServerRunning() As Boolean
    On Error Resume Next
    
    Dim objHTTP As Object
    Set objHTTP = CreateObject("MSXML2.XMLHTTP")
    
    objHTTP.Open "GET", API_HEALTH_URL, False
    objHTTP.setRequestHeader "Content-Type", "application/json"
    objHTTP.Send
    
    IsAPIServerRunning = (objHTTP.Status = 200)
    
    Set objHTTP = Nothing
    On Error GoTo 0
End Function

' =====================================================
' ÖFFNE SHELL.HTML IM BROWSER (Fallback)
' =====================================================
Public Sub OpenShellHTML()
    If Not IsAPIServerRunning Then
        MsgBox "API Server läuft nicht - starte START_ALLES.bat", vbExclamation, "CONSYS"
        StartAllServers
        Sleep 3000  ' Warte 3 Sekunden bis Server hochgefahren
    End If
    
    Shell "cmd /c start """" """ & SHELL_HTML_URL & """", vbHide
    Debug.Print "[Shell] Öffne: " & SHELL_HTML_URL
End Sub

' =====================================================
' TEST-FUNKTIONEN
' =====================================================
Public Sub Test_StartAll()
    StartAllServers
End Sub

Public Sub Test_IsServerRunning()
    If IsAPIServerRunning() Then
        MsgBox "API Server LÄUFT auf Port " & API_PORT, vbInformation, "Status"
    Else
        MsgBox "API Server LÄUFT NICHT", vbExclamation, "Status"
    End If
End Sub
