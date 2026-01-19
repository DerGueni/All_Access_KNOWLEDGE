' =========================================
' API Server Watchdog - Silent Starter
' =========================================
' Startet den Watchdog unsichtbar im Hintergrund
' Kein Fenster, kein Popup - nur Log-Datei
' =========================================

Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

' Pfad zum Script
strPath = FSO.GetParentFolderName(WScript.ScriptFullName)
strCommand = "python """ & strPath & "\api_server_watchdog.py"""

' Starte unsichtbar (0 = Hidden, False = nicht warten)
WshShell.Run strCommand, 0, False

Set WshShell = Nothing
Set FSO = Nothing
