' VBA Bridge Watchdog Starter - Unsichtbar
' =========================================
' Startet den VBA Bridge Watchdog im Hintergrund.
' Der Watchdog überwacht die VBA Bridge und startet sie bei Bedarf neu.

Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Pfade ermitteln
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
pythonScript = scriptDir & "\vba_bridge_watchdog.py"

' Prüfe ob Script existiert
If Not fso.FileExists(pythonScript) Then
    MsgBox "VBA Bridge Watchdog nicht gefunden: " & pythonScript, vbCritical, "Fehler"
    WScript.Quit 1
End If

' Starte Watchdog unsichtbar (0 = versteckt, False = nicht warten)
WshShell.Run "pythonw """ & pythonScript & """", 0, False

' Optional: Log-Eintrag
' WshShell.LogEvent 4, "VBA Bridge Watchdog gestartet"

WScript.Quit 0
