' ============================================
' CONSYS API Server - Versteckter Start
' Startet den API-Server ohne sichtbares Fenster
' ============================================

Set WshShell = CreateObject("WScript.Shell")

' Prüfe ob Python vorhanden
pythonPath = "python"

' Server-Pfad
serverPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\api_server.py"

' Starte Python Server versteckt (0 = versteckt, False = nicht warten)
WshShell.Run pythonPath & " """ & serverPath & """", 0, False

Set WshShell = Nothing
