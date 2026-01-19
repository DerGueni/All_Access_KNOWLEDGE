' ============================================================================
' ImportAndRunClaudeExport.vbs - Importiert Modul und führt Export aus
' ============================================================================

Option Explicit

Dim accessApp, dbPath, modulePath, exportPath
Dim fso

Set fso = CreateObject("Scripting.FileSystemObject")

dbPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"
modulePath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\mod_ClaudeExport.bas"
exportPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\"

' Prüfen ob Dateien existieren
If Not fso.FileExists(dbPath) Then
    WScript.Echo "FEHLER: Datenbank nicht gefunden: " & dbPath
    WScript.Quit 1
End If

If Not fso.FileExists(modulePath) Then
    WScript.Echo "FEHLER: VBA Modul nicht gefunden: " & modulePath
    WScript.Quit 1
End If

' Export-Ordner erstellen
CreateFolderStructure exportPath

WScript.Echo "Starte Access..."

' Access starten
On Error Resume Next
Set accessApp = CreateObject("Access.Application")
If Err.Number <> 0 Then
    WScript.Echo "FEHLER beim Starten von Access: " & Err.Description
    WScript.Quit 1
End If
On Error GoTo 0

accessApp.Visible = True
WScript.Echo "Öffne Datenbank: " & dbPath
accessApp.OpenCurrentDatabase dbPath

' Kurz warten bis DB geladen
WScript.Sleep 2000

' Prüfen ob Modul bereits existiert, wenn ja löschen
On Error Resume Next
accessApp.DoCmd.DeleteObject 5, "mod_ClaudeExport"  ' acModule = 5
On Error GoTo 0

' VBA Modul importieren
WScript.Echo "Importiere VBA Modul: " & modulePath
On Error Resume Next
accessApp.LoadFromText 5, "mod_ClaudeExport", modulePath  ' acModule = 5
If Err.Number <> 0 Then
    WScript.Echo "WARNUNG: LoadFromText fehlgeschlagen, versuche VBE Import..."
    Err.Clear
    
    ' Alternative: Über VBE importieren
    accessApp.VBE.ActiveVBProject.VBComponents.Import modulePath
    If Err.Number <> 0 Then
        WScript.Echo "FEHLER beim Import: " & Err.Description
    Else
        WScript.Echo "Modul erfolgreich über VBE importiert!"
    End If
Else
    WScript.Echo "Modul erfolgreich importiert!"
End If
On Error GoTo 0

' Kurz warten
WScript.Sleep 1000

' Export-Funktion ausführen
WScript.Echo "Führe ExportForClaude aus..."
On Error Resume Next
accessApp.Run "ExportForClaude"
If Err.Number <> 0 Then
    WScript.Echo "FEHLER beim Export: " & Err.Description
    WScript.Echo "Err.Number: " & Err.Number
Else
    WScript.Echo "Export erfolgreich abgeschlossen!"
End If
On Error GoTo 0

' Datenbank speichern und schließen
WScript.Sleep 1000
accessApp.CloseCurrentDatabase
accessApp.Quit

Set accessApp = Nothing
Set fso = Nothing

WScript.Echo ""
WScript.Echo "==================================="
WScript.Echo "Export abgeschlossen!"
WScript.Echo "Pfad: " & exportPath
WScript.Echo "==================================="

' Hilfsfunktion: Ordnerstruktur erstellen
Sub CreateFolderStructure(basePath)
    On Error Resume Next
    If Not fso.FolderExists(basePath) Then fso.CreateFolder basePath
    If Not fso.FolderExists(basePath & "forms") Then fso.CreateFolder basePath & "forms"
    If Not fso.FolderExists(basePath & "queries") Then fso.CreateFolder basePath & "queries"
    If Not fso.FolderExists(basePath & "vba") Then fso.CreateFolder basePath & "vba"
    If Not fso.FolderExists(basePath & "macros") Then fso.CreateFolder basePath & "macros"
    If Not fso.FolderExists(basePath & "reports") Then fso.CreateFolder basePath & "reports"
    On Error GoTo 0
End Sub
