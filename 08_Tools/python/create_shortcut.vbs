Set WshShell = CreateObject("WScript.Shell")
Set oShellLink = WshShell.CreateShortcut(WshShell.SpecialFolders("Desktop") & "\CONSEC VBA Bridge.lnk")
oShellLink.TargetPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python\start_vba_bridge.bat"
oShellLink.WorkingDirectory = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
oShellLink.Description = "Startet den CONSEC VBA Bridge Server"
oShellLink.Save
WScript.Echo "Desktop-Verknuepfung erstellt!"
