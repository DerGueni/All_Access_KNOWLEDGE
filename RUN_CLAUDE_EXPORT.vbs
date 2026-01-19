' ============================================================================
' RUN_CLAUDE_EXPORT.vbs - VBScript für Claude Export ohne Python
' Doppelklick zum Ausführen
' ============================================================================

Option Explicit

Dim accessApp, dbPath, exportPath
Dim fso, shell

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

dbPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"
exportPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\"

' Prüfen ob Datenbank existiert
If Not fso.FileExists(dbPath) Then
    MsgBox "Datenbank nicht gefunden: " & dbPath, vbCritical, "Fehler"
    WScript.Quit
End If

' Export-Ordner erstellen
CreateFolderStructure exportPath

' Access starten
On Error Resume Next
Set accessApp = CreateObject("Access.Application")
If Err.Number <> 0 Then
    MsgBox "Fehler beim Starten von Access: " & Err.Description, vbCritical, "Fehler"
    WScript.Quit
End If
On Error GoTo 0

accessApp.Visible = True
accessApp.OpenCurrentDatabase dbPath

' Export-Funktion aufrufen
On Error Resume Next
accessApp.Run "ExportForClaude"
If Err.Number <> 0 Then
    MsgBox "Export-Funktion nicht gefunden. Bitte mod_ClaudeExport.bas importieren.", vbExclamation, "Hinweis"
End If
On Error GoTo 0

MsgBox "Export abgeschlossen!" & vbCrLf & "Pfad: " & exportPath, vbInformation, "Claude Export"

' Aufräumen
Set accessApp = Nothing
Set fso = Nothing
Set shell = Nothing

' Hilfsfunktion: Ordnerstruktur erstellen
Sub CreateFolderStructure(basePath)
    If Not fso.FolderExists(basePath) Then fso.CreateFolder basePath
    If Not fso.FolderExists(basePath & "forms") Then fso.CreateFolder basePath & "forms"
    If Not fso.FolderExists(basePath & "queries") Then fso.CreateFolder basePath & "queries"
    If Not fso.FolderExists(basePath & "vba") Then fso.CreateFolder basePath & "vba"
    If Not fso.FolderExists(basePath & "macros") Then fso.CreateFolder basePath & "macros"
    If Not fso.FolderExists(basePath & "reports") Then fso.CreateFolder basePath & "reports"
End Sub
