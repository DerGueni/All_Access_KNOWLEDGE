' CONSEC API Server Neustart Script
' Dieses Script startet den API Server automatisch neu

Set WshShell = CreateObject("WScript.Shell")

' 1. Python Prozesse beenden
WshShell.Run "taskkill /F /IM python.exe", 0, True

' 2. Kurz warten
WScript.Sleep 2000

' 3. API Server starten
WshShell.CurrentDirectory = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
WshShell.Run "cmd /c python api_server.py", 1, False

' 4. Warten bis Server bereit
WScript.Sleep 5000

' 5. Browser öffnen zum Testen
WshShell.Run "http://localhost:5000/", 1, False

MsgBox "API Server wurde neu gestartet!" & vbCrLf & vbCrLf & "Email-Endpoint: http://localhost:5000/api/email/send", vbInformation, "CONSEC API Server"
