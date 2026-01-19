' Startet Test und zeigt Ergebnis
Set WshShell = CreateObject("WScript.Shell")
strWorkDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
WshShell.CurrentDirectory = strWorkDir
WshShell.Run "cmd /c python test_vba_bridge.py && type test_startup.log && pause", 1, True
