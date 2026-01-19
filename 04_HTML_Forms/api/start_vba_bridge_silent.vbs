Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

' Zum Script-Verzeichnis wechseln
ScriptDir = FSO.GetParentFolderName(WScript.ScriptFullName)

' VBA Bridge Server KOMPLETT UNSICHTBAR starten (windowless)
WshShell.Run "pythonw """ & ScriptDir & "\vba_bridge_server.py""", 0, False

' 0 = verstecktes Fenster, False = nicht warten
