' ========================================
' CONSEC VBA Bridge - Komplett-Setup
' ========================================
' Dieses Script:
' 1. Prüft Voraussetzungen (Python, Flask)
' 2. Startet die VBA Bridge sofort
' 3. Richtet den Autostart ein
' ========================================

Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strWorkDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
strVBSPath = strWorkDir & "\vba_bridge_hidden.vbs"

WScript.Echo "========================================" & vbCrLf & _
    "   CONSEC VBA Bridge Setup" & vbCrLf & _
    "========================================" & vbCrLf

' ----------------------------------------
' 1. Python prüfen
' ----------------------------------------
On Error Resume Next
WshShell.Run "python --version", 0, True
If Err.Number <> 0 Then
    WScript.Echo "FEHLER: Python nicht gefunden!" & vbCrLf & _
        "Bitte Python installieren: https://www.python.org/downloads/"
    WScript.Quit 1
End If
On Error Goto 0

WScript.Echo "✓ Python gefunden" & vbCrLf

' ----------------------------------------
' 2. Flask prüfen/installieren
' ----------------------------------------
WshShell.CurrentDirectory = strWorkDir
intRC = WshShell.Run("python -c ""import flask""", 0, True)
If intRC <> 0 Then
    WScript.Echo "Flask wird installiert..." & vbCrLf
    WshShell.Run "pip install flask flask-cors pywin32", 1, True
End If

WScript.Echo "✓ Flask verfügbar" & vbCrLf

' ----------------------------------------
' 3. VBA Bridge jetzt starten
' ----------------------------------------
' Prüfen ob bereits läuft
On Error Resume Next
Set objHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
objHTTP.Open "GET", "http://localhost:5002/api/vba/status", False
objHTTP.setTimeouts 2000, 2000, 2000, 2000
objHTTP.Send
blnRunning = (objHTTP.Status = 200)
On Error Goto 0

If Not blnRunning Then
    WScript.Echo "VBA Bridge wird gestartet..." & vbCrLf
    WshShell.Run "pythonw vba_bridge.py", 0, False
    WScript.Sleep 3000
    
    ' Nochmal prüfen
    On Error Resume Next
    Set objHTTP2 = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    objHTTP2.Open "GET", "http://localhost:5002/api/vba/status", False
    objHTTP2.setTimeouts 3000, 3000, 3000, 3000
    objHTTP2.Send
    blnRunning = (objHTTP2.Status = 200)
    On Error Goto 0
End If

If blnRunning Then
    WScript.Echo "✓ VBA Bridge läuft auf http://localhost:5002/" & vbCrLf
Else
    WScript.Echo "⚠ VBA Bridge konnte nicht gestartet werden" & vbCrLf
End If

' ----------------------------------------
' 4. Autostart einrichten
' ----------------------------------------
strStartupFolder = WshShell.SpecialFolders("Startup")
strShortcutPath = strStartupFolder & "\CONSEC VBA Bridge.lnk"

Set oShellLink = WshShell.CreateShortcut(strShortcutPath)
oShellLink.TargetPath = "wscript.exe"
oShellLink.Arguments = """" & strVBSPath & """"
oShellLink.WorkingDirectory = strWorkDir
oShellLink.Description = "CONSEC VBA Bridge Server (Hintergrund)"
oShellLink.WindowStyle = 7
oShellLink.Save

WScript.Echo "✓ Autostart eingerichtet" & vbCrLf

' ----------------------------------------
' Fertig!
' ----------------------------------------
WScript.Echo "========================================" & vbCrLf & _
    "   Setup abgeschlossen!" & vbCrLf & _
    "========================================" & vbCrLf & vbCrLf & _
    "Die VBA Bridge:" & vbCrLf & _
    "• Läuft jetzt im Hintergrund" & vbCrLf & _
    "• Startet automatisch bei Windows-Anmeldung" & vbCrLf & _
    "• Verbindet HTML-Formulare mit Access VBA" & vbCrLf & vbCrLf & _
    "Du kannst jetzt im HTML-Formular den 'Anfragen'" & vbCrLf & _
    "Button klicken - es funktioniert wie in Access!"
