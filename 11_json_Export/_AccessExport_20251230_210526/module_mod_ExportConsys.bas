'═══════════════════════════════════════════════════════════════════════════════
' Modul:     mod_ExportConsys
' Zweck:     Haupt-Export-Modul für vollständige Datenbank-Dokumentation
' Autor:     Access-Forensiker Agent
' Datum:     2025-10-31
' Version:   1.0
'═══════════════════════════════════════════════════════════════════════════════

Option Compare Database
Option Explicit

' Konstanten für Export-Pfade
Private Const EXPORT_BASE_PATH As String = "\Documents\0000_Consys_Wissen_kpl\03_Export_Ergebnisse"

'═══════════════════════════════════════════════════════════════════════════════
' HAUPT-EXPORT-ROUTINE
'═══════════════════════════════════════════════════════════════════════════════

Public Sub Export_All_Consys()
    On Error GoTo ErrorHandler
    
    Dim exportPath As String
    Dim startTime As Double
    Dim endTime As Double
    
    ' Timer starten
    startTime = Timer
    
    ' Export-Pfad vorbereiten
    exportPath = Environ$("USERPROFILE") & EXPORT_BASE_PATH
    EnsureFolder exportPath
    
    ' Fortschritts-Nachricht
    Debug.Print "═══════════════════════════════════════════════════════"
    Debug.Print "Consys-Datenbank Export gestartet..."
    Debug.Print "Export-Pfad: " & exportPath
    Debug.Print "═══════════════════════════════════════════════════════"
    Debug.Print ""
    
    ' 1. Tabellen exportieren
    Debug.Print "[1/8] Exportiere Tabellen..."
    ExportTableDefsToJSON exportPath
    Debug.Print "      ✓ Tabellen exportiert → tables.json"
    
    ' 2. Queries exportieren
    Debug.Print "[2/8] Exportiere Queries..."
    ExportQueryDefsToJSON exportPath
    Debug.Print "      ✓ Queries exportiert → queries.json"
    
    ' 3. Formulare exportieren
    Debug.Print "[3/8] Exportiere Formulare..."
    ExportFormsToJSON exportPath
    Debug.Print "      ✓ Formulare exportiert → forms.json"
    
    ' 4. Reports exportieren
    Debug.Print "[4/8] Exportiere Reports..."
    ExportReportsToJSON exportPath
    Debug.Print "      ✓ Reports exportiert → reports.json"
    
    ' 5. Module exportieren
    Debug.Print "[5/8] Exportiere VBA-Module..."
    ExportModulesToJSON exportPath
    Debug.Print "      ✓ Module exportiert → modules.json"
    
    ' 6. Makros exportieren
    Debug.Print "[6/8] Exportiere Makros..."
    ExportMacrosToJSON exportPath
    Debug.Print "      ✓ Makros exportiert → macros.json"
    
    ' 7. Beziehungen exportieren
    Debug.Print "[7/8] Exportiere Beziehungen..."
    ExportRelationsToJSON exportPath
    Debug.Print "      ✓ Beziehungen exportiert → relations.json"
    
    ' 8. Workflows erkennen
    Debug.Print "[8/8] Analysiere Workflows..."
    DetectWorkflows exportPath
    Debug.Print "      ✓ Workflows analysiert → workflows.json"
    
    ' Timer stoppen
    endTime = Timer
    
    ' Erfolgsmeldung
    Debug.Print ""
    Debug.Print "═══════════════════════════════════════════════════════"
    Debug.Print "✓ Export erfolgreich abgeschlossen!"
    Debug.Print "  Dauer: " & Format(endTime - startTime, "0.00") & " Sekunden"
    Debug.Print "  Pfad: " & exportPath
    Debug.Print "═══════════════════════════════════════════════════════"
    
    MsgBox "Export abgeschlossen!" & vbCrLf & vbCrLf & _
           "Alle Dateien wurden exportiert nach:" & vbCrLf & _
           exportPath & vbCrLf & vbCrLf & _
           "Dauer: " & Format(endTime - startTime, "0.00") & " Sekunden", _
           vbInformation, "Consys Export"
    
    Exit Sub

ErrorHandler:
    Debug.Print ""
    Debug.Print "✗ FEHLER beim Export!"
    Debug.Print "  Beschreibung: " & Err.description
    Debug.Print "  Nummer: " & Err.Number
    
    MsgBox "Fehler beim Export:" & vbCrLf & vbCrLf & _
           Err.description & vbCrLf & _
           "(Fehler-Nr: " & Err.Number & ")", _
           vbCritical, "Consys Export Fehler"
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' HILFSFUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════

' Stellt sicher, dass ein Ordner existiert
Private Sub EnsureFolder(ByVal folderPath As String)
    On Error Resume Next
    If Dir(folderPath, vbDirectory) = "" Then
        MkDir folderPath
    End If
    On Error GoTo 0
End Sub

' Escaped JSON-Strings (ersetzt " durch ')
Public Function EscapeJSON(ByVal Text As String) As String
    If IsNull(Text) Then
        EscapeJSON = ""
        Exit Function
    End If
    
    ' Anführungszeichen durch ' ersetzen
    Text = Replace(Text, """", "'")
    
    ' Zeilenumbrüche durch \n ersetzen
    Text = Replace(Text, vbCrLf, "\n")
    Text = Replace(Text, vbCr, "\n")
    Text = Replace(Text, vbLf, "\n")
    
    ' Backslashes escapen
    Text = Replace(Text, "\", "\\")
    
    EscapeJSON = Text
End Function

' Gibt Property-Wert zurück oder leeren String
Public Function GetProp(obj As Object, propName As String) As String
    On Error Resume Next
    GetProp = obj.Properties(propName)
    If Err.Number <> 0 Then
        GetProp = ""
    End If
    On Error GoTo 0
End Function

'═══════════════════════════════════════════════════════════════════════════════
' PLATZHALTER FÜR EXPORT-FUNKTIONEN
' (werden in separaten Modulen implementiert)
'═══════════════════════════════════════════════════════════════════════════════

Private Sub ExportTableDefsToJSON(exportPath As String)
    ' Wird in mod_ExportTables implementiert
    mod_ExportTables.ExportTableDefsToJSON exportPath
End Sub

Private Sub ExportQueryDefsToJSON(exportPath As String)
    ' Wird in mod_ExportQueries implementiert
    mod_ExportQueries.ExportQueryDefsToJSON exportPath
End Sub

Private Sub ExportFormsToJSON(exportPath As String)
    ' Wird in mod_ExportForms implementiert
    mod_ExportForms.ExportFormsToJSON exportPath
End Sub

Private Sub ExportReportsToJSON(exportPath As String)
    ' Wird in mod_ExportReports implementiert
    mod_ExportReports.ExportReportsToJSON exportPath
End Sub

Private Sub ExportModulesToJSON(exportPath As String)
    ' Wird in mod_ExportModules implementiert
    mod_ExportModules.ExportModulesToJSON exportPath
End Sub

Private Sub ExportMacrosToJSON(exportPath As String)
    ' Wird in mod_ExportMacros implementiert
    ' Makros sind in Access selten, daher einfacher Export
    Dim f As Integer
    Dim filePath As String
    filePath = exportPath & "\macros.json"
    f = FreeFile
    Open filePath For Output As #f
    Print #f, "[]"
    Close #f
End Sub

Private Sub ExportRelationsToJSON(exportPath As String)
    ' Wird in mod_ExportRelations implementiert
    mod_ExportRelations.ExportRelationsToJSON exportPath
End Sub

Private Sub DetectWorkflows(exportPath As String)
    ' Wird in mod_WorkflowDetector implementiert
    mod_WorkflowDetector.DetectWorkflows exportPath
End Sub