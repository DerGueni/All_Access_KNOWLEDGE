# QuickImportExport.ps1 - Führt Import und Export in Access aus
# Kopiere den Code unten ins VBA Direktfenster (Strg+G) und drücke Enter

$vbaCode = @"
'=== KOPIERE ALLES AB HIER INS VBA DIREKTFENSTER ===

Sub ImportAndExport()
    Dim vbComp As Object
    Dim modulePath As String
    Dim exportPath As String
    
    modulePath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\mod_ClaudeExport.bas"
    exportPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\"
    
    ' Modul importieren
    On Error Resume Next
    Application.VBE.ActiveVBProject.VBComponents.Remove Application.VBE.ActiveVBProject.VBComponents("mod_ClaudeExport")
    On Error GoTo 0
    
    Application.VBE.ActiveVBProject.VBComponents.Import modulePath
    
    MsgBox "Modul importiert! Jetzt ExportForClaude ausfuehren.", vbInformation
End Sub

'=== BIS HIER KOPIEREN, DANN: Call ImportAndExport ===
"@

Write-Host $vbaCode
Write-Host ""
Write-Host "============================================"
Write-Host "ANLEITUNG:"
Write-Host "1. Kopiere den Code oben"
Write-Host "2. Füge ihn ins VBA-Direktfenster ein (Strg+G)"
Write-Host "3. Führe aus: Call ImportAndExport"
Write-Host "4. Dann: Call ExportForClaude"
Write-Host "============================================"
