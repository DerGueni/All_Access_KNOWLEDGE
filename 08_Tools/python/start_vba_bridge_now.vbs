' CONSEC VBA Bridge - Jetzt starten
' Startet die VBA Bridge sofort im Hintergrund und zeigt Status an

Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strWorkDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"

' Prüfen ob bereits läuft
On Error Resume Next
Set objHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
objHTTP.Open "GET", "http://localhost:5002/api/vba/status", False
objHTTP.setTimeouts 2000, 2000, 2000, 2000
objHTTP.Send

If objHTTP.Status = 200 Then
    WScript.Echo "VBA Bridge läuft bereits!" & vbCrLf & vbCrLf & _
        "Status: http://localhost:5002/" & vbCrLf & _
        "Die HTML-Formulare können die Access VBA-Funktionen nutzen."
    WScript.Quit
End If
On Error Goto 0

' Starten
WshShell.CurrentDirectory = strWorkDir
WshShell.Run "pythonw vba_bridge.py", 0, False

WScript.Echo "VBA Bridge wird gestartet..." & vbCrLf & vbCrLf & _
    "Bitte warten..."

' Warten und prüfen
WScript.Sleep 3000

On Error Resume Next
Set objHTTP2 = CreateObject("MSXML2.ServerXMLHTTP.6.0")
objHTTP2.Open "GET", "http://localhost:5002/api/vba/status", False
objHTTP2.setTimeouts 3000, 3000, 3000, 3000
objHTTP2.Send

If objHTTP2.Status = 200 Then
    strResponse = objHTTP2.responseText
    WScript.Echo "VBA Bridge erfolgreich gestartet!" & vbCrLf & vbCrLf & _
        "Server: http://localhost:5002/" & vbCrLf & vbCrLf & _
        "Die HTML-Formulare können jetzt Access VBA-Funktionen aufrufen." & vbCrLf & _
        "(z.B. E-Mail Anfragen über den 'Anfragen' Button)"
Else
    WScript.Echo "Fehler: VBA Bridge konnte nicht gestartet werden." & vbCrLf & vbCrLf & _
        "Mögliche Ursachen:" & vbCrLf & _
        "- Python nicht installiert" & vbCrLf & _
        "- Flask nicht installiert (pip install flask flask-cors pywin32)" & vbCrLf & _
        "- Port 5002 bereits belegt"
End If
On Error Goto 0
