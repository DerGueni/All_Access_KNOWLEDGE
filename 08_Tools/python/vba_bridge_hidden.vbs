' CONSEC VBA Bridge - Versteckter Starter
' Startet den Python VBA Bridge Server im Hintergrund

Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Arbeitsverzeichnis
strWorkDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
strPyScript = strWorkDir & "\vba_bridge.py"

' Pruefen ob Python-Script existiert
If Not objFSO.FileExists(strPyScript) Then
    MsgBox "VBA Bridge Script nicht gefunden:" & vbCrLf & strPyScript, vbCritical, "CONSEC VBA Bridge"
    WScript.Quit 1
End If

' Pruefen ob bereits laeuft (Port 5002)
On Error Resume Next
Set objHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
objHTTP.Open "GET", "http://localhost:5002/api/vba/status", False
objHTTP.setTimeouts 1000, 1000, 1000, 1000
objHTTP.Send

If objHTTP.Status = 200 Then
    ' Bereits am Laufen - nichts tun
    WScript.Quit 0
End If
On Error Goto 0

' Python-Pfade die wir probieren
Dim pythonPaths(4)
pythonPaths(0) = "pythonw.exe"
pythonPaths(1) = "python.exe"
pythonPaths(2) = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Programs\Python\Python311\pythonw.exe"
pythonPaths(3) = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Programs\Python\Python312\pythonw.exe"
pythonPaths(4) = "C:\Python311\pythonw.exe"

' VBA Bridge starten
WshShell.CurrentDirectory = strWorkDir

Dim started
started = False

For Each pyPath In pythonPaths
    On Error Resume Next
    ' 0 = versteckt, False = nicht warten
    WshShell.Run """" & pyPath & """ """ & strPyScript & """", 0, False
    If Err.Number = 0 Then
        started = True
        Exit For
    End If
    Err.Clear
    On Error Goto 0
Next

If Not started Then
    MsgBox "Python konnte nicht gestartet werden!" & vbCrLf & vbCrLf & _
           "Bitte pruefen ob Python installiert ist.", vbCritical, "CONSEC VBA Bridge"
    WScript.Quit 1
End If

' Kurz warten und pruefen ob gestartet
WScript.Sleep 3000

On Error Resume Next
Set objHTTP2 = CreateObject("MSXML2.ServerXMLHTTP.6.0")
objHTTP2.Open "GET", "http://localhost:5002/api/vba/status", False
objHTTP2.setTimeouts 2000, 2000, 2000, 2000
objHTTP2.Send

If objHTTP2.Status <> 200 Then
    ' Nicht gestartet - Log pruefen
    strLogFile = strWorkDir & "\logs\vba_bridge.log"
    If objFSO.FileExists(strLogFile) Then
        MsgBox "VBA Bridge konnte nicht starten." & vbCrLf & vbCrLf & _
               "Log-Datei: " & strLogFile, vbExclamation, "CONSEC VBA Bridge"
    Else
        MsgBox "VBA Bridge konnte nicht starten." & vbCrLf & vbCrLf & _
               "Keine Log-Datei gefunden.", vbExclamation, "CONSEC VBA Bridge"
    End If
End If
On Error Goto 0
