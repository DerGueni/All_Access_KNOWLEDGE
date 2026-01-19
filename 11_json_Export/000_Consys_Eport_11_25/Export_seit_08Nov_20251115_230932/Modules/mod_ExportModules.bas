'═══════════════════════════════════════════════════════════════════════════════
' Modul:     mod_ExportModules
' Zweck:     Export aller VBA-Module zu JSON
' Autor:     Access-Forensiker Agent
' Datum:     2025-10-31
' Version:   1.0
'═══════════════════════════════════════════════════════════════════════════════

Option Compare Database
Option Explicit
Private Const pk_Proc As Long = 0
Private Const pk_Get  As Long = 1
Private Const pk_Let  As Long = 2
Private Const pk_Set  As Long = 3
'═══════════════════════════════════════════════════════════════════════════════
' HAUPT-EXPORT-FUNKTION
'═══════════════════════════════════════════════════════════════════════════════

Public Sub ExportModulesToJSON(ByVal exportPath As String)
    On Error GoTo ErrorHandler
    
    Dim f As Integer
    Dim filePath As String
    Dim i As Integer
    Dim firstModule As Boolean
    Dim moduleCount As Integer
    Dim am As Access.AccessObject
    
    filePath = exportPath & "\modules.json"
    f = FreeFile
    
    Open filePath For Output As #f
    
    ' JSON-Array starten
    Print #f, "["
    
    firstModule = True
    moduleCount = 0
    
    ' Alle Standard-Module durchgehen
    For i = 0 To CurrentProject.AllModules.Count - 1
        Set am = CurrentProject.AllModules(i)
        
        ' Modul öffnen
        On Error Resume Next
        DoCmd.OpenModule am.Name
        
        If err.Number = 0 Then
            On Error GoTo ErrorHandler
            
            ' Komma vor weiteren Einträgen
            If Not firstModule Then
                Print #f, ","
            End If
            firstModule = False
            moduleCount = moduleCount + 1
            
            ' Modul-Objekt exportieren
            ExportSingleModule f, am.Name
            
            ' Modul schließen
            DoCmd.Close acModule, am.Name, acSaveNo
        Else
            ' Fehler beim Öffnen - überspringen
            Debug.Print "      ⚠ Modul '" & am.Name & "' konnte nicht ge�ffnet werden"
            On Error GoTo ErrorHandler
        End If
    Next i
    
    ' Auch Formular- und Report-Module exportieren
    ExportFormModules f, firstModule, moduleCount
    ExportReportModules f, firstModule, moduleCount
    
    ' JSON-Array schließen
    Print #f, "]"
    
    Close #f
    
    Debug.Print "      → " & moduleCount & " Module exportiert (inkl. Formular-/Report-Module)"
    
    Exit Sub

ErrorHandler:
    On Error Resume Next
    Close #f
    DoCmd.Close acModule, , acSaveNo
    On Error GoTo 0
    Debug.Print "      ✗ Fehler: " & err.description
    err.Raise err.Number, "ExportModulesToJSON", err.description
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' EINZELNES MODUL EXPORTIEREN
'═══════════════════════════════════════════════════════════════════════════════

Private Sub ExportSingleModule(fileNum As Integer, moduleName As String)
    Dim mdl As Module
    Dim codeText As String
    Dim lineCount As Long
    Dim procCount As Integer
    
    Set mdl = Modules(moduleName)
    lineCount = mdl.CountOfLines
    
    ' Gesamten Code auslesen
    If lineCount > 0 Then
        codeText = mdl.lines(1, lineCount)
    Else
        codeText = ""
    End If
    
    ' Prozeduren zählen
    procCount = CountProcedures(mdl)
    
    ' JSON-Objekt schreiben
    Print #fileNum, "  {"
    Print #fileNum, "    ""name"": """ & mod_ExportConsys.EscapeJSON(moduleName) & ""","
    Print #fileNum, "    ""type"": ""StandardModule"","
    Print #fileNum, "    ""lineCount"": " & lineCount & ","
    Print #fileNum, "    ""procedureCount"": " & procCount & ","
    Print #fileNum, "    ""procedures"": " & GetProcedureList(mdl) & ","
    Print #fileNum, "    ""code"": """ & mod_ExportConsys.EscapeJSON(codeText) & """"
    Print #fileNum, "  }"
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' FORMULAR-MODULE EXPORTIEREN
'═══════════════════════════════════════════════════════════════════════════════

Private Sub ExportFormModules(fileNum As Integer, ByRef isFirst As Boolean, ByRef moduleCount As Integer)
    On Error Resume Next
    Dim i As Integer
    Dim frm As Form
    Dim mdl As Module
    
    For i = 0 To CurrentProject.AllForms.Count - 1
        Dim formName As String
        formName = CurrentProject.AllForms(i).Name
        
        ' Formular im Design-Modus öffnen
        DoCmd.OpenForm formName, acDesign, , , , acHidden
        
        If err.Number = 0 Then
            Set frm = Forms(formName)
            
            ' Prüfen ob Modul vorhanden
            If frm.HasModule Then
                Set mdl = frm.Module
                
                If mdl.CountOfLines > 0 Then
                    If Not isFirst Then
                        Print #fileNum, ","
                    End If
                    isFirst = False
                    moduleCount = moduleCount + 1
                    
                    ' Modul exportieren
                    Print #fileNum, "  {"
                    Print #fileNum, "    ""name"": ""Form_" & mod_ExportConsys.EscapeJSON(formName) & ""","
                    Print #fileNum, "    ""type"": ""FormModule"","
                    Print #fileNum, "    ""parentForm"": """ & mod_ExportConsys.EscapeJSON(formName) & ""","
                    Print #fileNum, "    ""lineCount"": " & mdl.CountOfLines & ","
                    Print #fileNum, "    ""procedureCount"": " & CountProcedures(mdl) & ","
                    Print #fileNum, "    ""procedures"": " & GetProcedureList(mdl) & ","
                    Print #fileNum, "    ""code"": """ & mod_ExportConsys.EscapeJSON(mdl.lines(1, mdl.CountOfLines)) & """"
                    Print #fileNum, "  }"
                End If
            End If
            
            DoCmd.Close acForm, formName, acSaveNo
        End If
        
        err.clear
    Next i
    On Error GoTo 0
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' REPORT-MODULE EXPORTIEREN
'═══════════════════════════════════════════════════════════════════════════════

Private Sub ExportReportModules(fileNum As Integer, ByRef isFirst As Boolean, ByRef moduleCount As Integer)
    On Error Resume Next
    Dim i As Integer
    Dim rpt As Report
    Dim mdl As Module
    
    For i = 0 To CurrentProject.AllReports.Count - 1
        Dim reportName As String
        reportName = CurrentProject.AllReports(i).Name
        
        ' Report im Design-Modus öffnen
        DoCmd.OpenReport reportName, acViewDesign, , , acHidden
        
        If err.Number = 0 Then
            Set rpt = Reports(reportName)
            
            ' Prüfen ob Modul vorhanden
            If rpt.HasModule Then
                Set mdl = rpt.Module
                
                If mdl.CountOfLines > 0 Then
                    If Not isFirst Then
                        Print #fileNum, ","
                    End If
                    isFirst = False
                    moduleCount = moduleCount + 1
                    
                    ' Modul exportieren
                    Print #fileNum, "  {"
                    Print #fileNum, "    ""name"": ""Report_" & mod_ExportConsys.EscapeJSON(reportName) & ""","
                    Print #fileNum, "    ""type"": ""ReportModule"","
                    Print #fileNum, "    ""parentReport"": """ & mod_ExportConsys.EscapeJSON(reportName) & ""","
                    Print #fileNum, "    ""lineCount"": " & mdl.CountOfLines & ","
                    Print #fileNum, "    ""procedureCount"": " & CountProcedures(mdl) & ","
                    Print #fileNum, "    ""procedures"": " & GetProcedureList(mdl) & ","
                    Print #fileNum, "    ""code"": """ & mod_ExportConsys.EscapeJSON(mdl.lines(1, mdl.CountOfLines)) & """"
                    Print #fileNum, "  }"
                End If
            End If
            
            DoCmd.Close acReport, reportName, acSaveNo
        End If
        
        err.clear
    Next i
    On Error GoTo 0
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' HILFSFUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════

' Zählt Prozeduren in einem Modul
Private Function CountProcedures(mdl As Module) As Integer
    Dim lineNum As Long
    Dim procName As String
    Dim procKind As Long
    Dim Count As Integer
    
    Count = 0
    lineNum = 1
    
    On Error Resume Next
    Do While lineNum < mdl.CountOfLines
        procName = mdl.ProcOfLine(lineNum, procKind)
        If Len(procName) > 0 And err.Number = 0 Then
            Count = Count + 1
            ' Zur nächsten Prozedur springen
            lineNum = mdl.ProcStartLine(procName, procKind) + mdl.ProcCountLines(procName, procKind)
        Else
            lineNum = lineNum + 1
        End If
    Loop
    On Error GoTo 0
    
    CountProcedures = Count
End Function

' Erstellt Liste aller Prozeduren als JSON-Array
Private Function GetProcedureList(mdl As Module) As String
    Dim lineNum As Long
    Dim procName As String
    Dim procKind As Long
    Dim procList As String
    Dim visitedProcs As Object
    Dim isFirst As Boolean
    
    Set visitedProcs = CreateObject("Scripting.Dictionary")
    procList = "["
    isFirst = True
    lineNum = 1
    
    On Error Resume Next
    Do While lineNum < mdl.CountOfLines
        procName = mdl.ProcOfLine(lineNum, procKind)
        
        If Len(procName) > 0 And err.Number = 0 Then
            ' Prüfen ob bereits verarbeitet
            If Not visitedProcs.Exists(procName) Then
                visitedProcs.Add procName, True
                
                If Not isFirst Then
                    procList = procList & ","
                End If
                isFirst = False
                
                procList = procList & "{""name"":""" & mod_ExportConsys.EscapeJSON(procName) & ""","
                procList = procList & """type"":""" & GetProcKindName(procKind) & ""","
                procList = procList & """startLine"":" & mdl.ProcStartLine(procName, procKind) & ","
                procList = procList & """lineCount"":" & mdl.ProcCountLines(procName, procKind) & "}"
                
                ' Zur nächsten Prozedur springen
                lineNum = mdl.ProcStartLine(procName, procKind) + mdl.ProcCountLines(procName, procKind)
            Else
                lineNum = lineNum + 1
            End If
        Else
            lineNum = lineNum + 1
        End If
    Loop
    On Error GoTo 0
    
    procList = procList & "]"
    GetProcedureList = procList
End Function

' Keine VBIDE-Referenz n�tig


Private Function GetProcKindName(procKind As Long) As String
    Select Case procKind
        Case pk_Proc: GetProcKindName = "Sub/Function"
        Case pk_Get:  GetProcKindName = "Property Get"
        Case pk_Let:  GetProcKindName = "Property Let"
        Case pk_Set:  GetProcKindName = "Property Set"
        Case Else:    GetProcKindName = "Unknown"
    End Select
End Function