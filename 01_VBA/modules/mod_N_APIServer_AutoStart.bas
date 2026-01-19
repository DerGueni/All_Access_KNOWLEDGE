Attribute VB_Name = "mod_N_APIServer_AutoStart"
' =====================================================
' mod_N_APIServer_AutoStart
' Startet API-Server automatisch beim Access-Start
' Version: 13.01.2026
' =====================================================

' Wird aus mdlAutoexec aufgerufen
Public Sub StartAPIServer()
    On Error Resume Next
    ' Rufe die Funktion aus mod_N_WebView2_forms3 auf
    mod_N_WebView2_forms3.StartAPIServerIfNeeded
    On Error GoTo 0
End Sub

Public Sub StartVBABridge()
    ' VBA Bridge Server wird beim ersten Bedarf gestartet
    ' Hier nur eine Platzhalter-Funktion
    Debug.Print "[AutoStart] VBA Bridge wird bei Bedarf gestartet"
End Sub
