' restart_api_server.vbs
' Startet den API-Server neu

Set WshShell = CreateObject("WScript.Shell")

' Erst Python-Prozesse beenden
WshShell.Run "cmd /c taskkill /F /IM python.exe", 0, True

' 2 Sekunden warten
WScript.Sleep 2000

' API-Server starten
WshShell.CurrentDirectory = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
WshShell.Run "cmd /k python api_server.py", 1, False

MsgBox "API-Server wird gestartet..." & vbCrLf & vbCrLf & "Bitte warten Sie 5 Sekunden, dann testen Sie erneut.", vbInformation, "CONSEC API Server"
