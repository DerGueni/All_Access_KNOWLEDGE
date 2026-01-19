Attribute VB_Name = "mod_ClaudeExport"
Option Compare Database
Option Explicit

' ============================================================================
' mod_ClaudeExport - VBA Modul für Access Bridge Ultimate Export
' Exportiert Formulare, Tabellen, Abfragen und VBA-Code für Claude AI
' ============================================================================

Private Const EXPORT_BASE_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\"

' Hauptfunktion: Kompletter Export für Claude
Public Sub ExportForClaude()
    On Error GoTo ErrorHandler
    
    Dim exportPath As String
    exportPath = EXPORT_BASE_PATH
    
    ' Ordner erstellen falls nicht vorhanden
    CreateExportFolders exportPath
    
    ' Export durchführen
    ExportAllForms exportPath & "forms\"
    ExportAllQueries exportPath & "queries\"
    ExportAllTables exportPath
    ExportAllVBAModules exportPath & "vba\"
    ExportFormMetadata exportPath
    
    MsgBox "Export für Claude erfolgreich abgeschlossen!" & vbCrLf & _
           "Pfad: " & exportPath, vbInformation, "Claude Export"
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler beim Export: " & Err.description, vbCritical, "Export Fehler"
End Sub

' Ordnerstruktur erstellen
Private Sub CreateExportFolders(basePath As String)
    On Error Resume Next
    MkDir basePath
    MkDir basePath & "forms"
    MkDir basePath & "queries"
    MkDir basePath & "vba"
    MkDir basePath & "macros"
    MkDir basePath & "reports"
    On Error GoTo 0
End Sub

' Alle Formulare exportieren
Private Sub ExportAllForms(exportPath As String)
    Dim frm As AccessObject
    Dim db As DAO.Database
    Set db = CurrentDb
    
    For Each frm In CurrentProject.AllForms
        On Error Resume Next
        Application.SaveAsText acForm, frm.Name, exportPath & frm.Name & ".txt"
        On Error GoTo 0
    Next frm
End Sub

' Alle Abfragen exportieren
Private Sub ExportAllQueries(exportPath As String)
    Dim qdf As DAO.QueryDef
    Dim db As DAO.Database
    Dim fileNum As Integer
    
    Set db = CurrentDb
    
    For Each qdf In db.QueryDefs
        If Left(qdf.Name, 1) <> "~" Then  ' Temporäre Abfragen überspringen
            On Error Resume Next
            fileNum = FreeFile
            Open exportPath & qdf.Name & ".sql" For Output As #fileNum
            Print #fileNum, "-- Query: " & qdf.Name
            Print #fileNum, "-- Type: " & qdf.Type
            Print #fileNum, qdf.sql
            Close #fileNum
            On Error GoTo 0
        End If
    Next qdf
End Sub

' Tabellenstruktur exportieren
Private Sub ExportAllTables(exportPath As String)
    Dim tdf As DAO.TableDef
    Dim fld As DAO.field
    Dim db As DAO.Database
    Dim fileNum As Integer
    Dim jsonOutput As String
    
    Set db = CurrentDb
    
    jsonOutput = "{"
    jsonOutput = jsonOutput & """tables"": ["
    
    Dim isFirst As Boolean
    isFirst = True
    
    For Each tdf In db.TableDefs
        If Left(tdf.Name, 4) <> "MSys" And Left(tdf.Name, 1) <> "~" Then
            If Not isFirst Then jsonOutput = jsonOutput & ","
            isFirst = False
            
            jsonOutput = jsonOutput & vbCrLf & "  {"
            jsonOutput = jsonOutput & """name"": """ & tdf.Name & ""","
            jsonOutput = jsonOutput & """fields"": ["
            
            Dim isFirstField As Boolean
            isFirstField = True
            
            For Each fld In tdf.fields
                If Not isFirstField Then jsonOutput = jsonOutput & ","
                isFirstField = False
                jsonOutput = jsonOutput & "{""name"":""" & fld.Name & """,""type"":" & fld.Type & "}"
            Next fld
            
            jsonOutput = jsonOutput & "]}"
        End If
    Next tdf
    
    jsonOutput = jsonOutput & vbCrLf & "]}"
    
    fileNum = FreeFile
    Open exportPath & "tables_schema.json" For Output As #fileNum
    Print #fileNum, jsonOutput
    Close #fileNum
End Sub

' Alle VBA Module exportieren
Private Sub ExportAllVBAModules(exportPath As String)
    Dim vbComp As Object
    Dim vbProj As Object
    
    On Error Resume Next
    Set vbProj = Application.VBE.ActiveVBProject
    
    If vbProj Is Nothing Then
        Exit Sub
    End If
    
    For Each vbComp In vbProj.VBComponents
        Select Case vbComp.Type
            Case 1  ' Standard Module
                vbComp.Export exportPath & vbComp.Name & ".bas"
            Case 2  ' Class Module
                vbComp.Export exportPath & vbComp.Name & ".cls"
            Case 3  ' Form
                ' Forms werden separat exportiert
        End Select
    Next vbComp
    On Error GoTo 0
End Sub

' Formular-Metadaten exportieren (Controls, Events, Properties)
Private Sub ExportFormMetadata(exportPath As String)
    Dim frm As AccessObject
    Dim fileNum As Integer
    Dim jsonOutput As String
    
    jsonOutput = "{""forms"": ["
    
    Dim isFirst As Boolean
    isFirst = True
    
    For Each frm In CurrentProject.AllForms
        If Not isFirst Then jsonOutput = jsonOutput & ","
        isFirst = False
        
        jsonOutput = jsonOutput & vbCrLf & "  {""name"": """ & frm.Name & """}"
    Next frm
    
    jsonOutput = jsonOutput & vbCrLf & "]}"
    
    fileNum = FreeFile
    Open exportPath & "form_metadata.json" For Output As #fileNum
    Print #fileNum, jsonOutput
    Close #fileNum
End Sub

' Einzelnes Formular mit Details exportieren
Public Sub ExportSingleForm(formName As String)
    On Error GoTo ErrorHandler
    
    Dim exportPath As String
    exportPath = EXPORT_BASE_PATH & "forms\"
    
    Application.SaveAsText acForm, formName, exportPath & formName & ".txt"
    
    MsgBox "Formular '" & formName & "' exportiert!", vbInformation
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub
