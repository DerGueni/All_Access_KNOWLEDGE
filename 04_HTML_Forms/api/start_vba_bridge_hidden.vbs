' VBA Bridge Server - Unsichtbarer Start
' Startet den Python VBA Bridge Server ohne sichtbares Fenster
'
' Verwendung:
'   - Doppelklick auf diese Datei
'   - Oder von VBA: Shell "wscript.exe start_vba_bridge_hidden.vbs", vbHide

Set WshShell = CreateObject("WScript.Shell")

' Pfad zum API-Ordner ermitteln
strScriptPath = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))

' In den API-Ordner wechseln und Server starten
' 0 = vbHide (unsichtbar), True = warten bis fertig (False = nicht warten)
WshShell.CurrentDirectory = strScriptPath
WshShell.Run "python vba_bridge_server.py", 0, False

Set WshShell = Nothing
