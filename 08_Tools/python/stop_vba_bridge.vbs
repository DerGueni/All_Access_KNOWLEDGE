' CONSEC VBA Bridge - Stoppen
' Beendet den VBA Bridge Server

Set WshShell = CreateObject("WScript.Shell")

' Python-Prozess finden und beenden
WshShell.Run "taskkill /f /im pythonw.exe /fi ""WINDOWTITLE eq *vba_bridge*""", 0, True

' Alle pythonw Prozesse die auf Port 5002 lauschen beenden
WshShell.Run "cmd /c for /f ""tokens=5"" %a in ('netstat -ano ^| findstr :5002 ^| findstr LISTENING') do taskkill /f /pid %a", 0, True

WScript.Sleep 1000

' Prüfen ob gestoppt
On Error Resume Next
Set objHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
objHTTP.Open "GET", "http://localhost:5002/api/vba/status", False
objHTTP.setTimeouts 1000, 1000, 1000, 1000
objHTTP.Send

If objHTTP.Status = 200 Then
    WScript.Echo "VBA Bridge läuft noch. Bitte manuell im Task-Manager beenden."
Else
    WScript.Echo "VBA Bridge wurde gestoppt."
End If
On Error Goto 0
