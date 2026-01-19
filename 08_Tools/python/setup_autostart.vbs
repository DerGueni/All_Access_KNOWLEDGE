' CONSEC VBA Bridge - Autostart einrichten
' Fügt die VBA Bridge zum Windows-Autostart hinzu

Set WshShell = CreateObject("WScript.Shell")

' Pfad zum versteckten Starter
strVBSPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\vba_bridge_hidden.vbs"

' Autostart-Ordner ermitteln
strStartupFolder = WshShell.SpecialFolders("Startup")

' Verknüpfung erstellen
Set oShellLink = WshShell.CreateShortcut(strStartupFolder & "\CONSEC VBA Bridge.lnk")
oShellLink.TargetPath = "wscript.exe"
oShellLink.Arguments = """" & strVBSPath & """"
oShellLink.WorkingDirectory = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
oShellLink.Description = "CONSEC VBA Bridge Server (Hintergrund)"
oShellLink.WindowStyle = 7  ' Minimiert
oShellLink.Save

WScript.Echo "VBA Bridge wurde zum Autostart hinzugefügt!" & vbCrLf & vbCrLf & _
    "Speicherort: " & strStartupFolder & "\CONSEC VBA Bridge.lnk" & vbCrLf & vbCrLf & _
    "Der Server startet ab jetzt automatisch bei jeder Windows-Anmeldung."
