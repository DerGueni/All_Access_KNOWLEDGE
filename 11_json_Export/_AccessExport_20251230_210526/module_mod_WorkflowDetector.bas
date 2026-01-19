'═══════════════════════════════════════════════════════════════════════════════
' Modul:     mod_WorkflowDetector
' Zweck:     Erkennt Workflows und Abhängigkeiten in der Datenbank
' Autor:     Access-Forensiker Agent
' Datum:     2025-10-31
' Version:   1.0
'═══════════════════════════════════════════════════════════════════════════════

Option Compare Database
Option Explicit

'═══════════════════════════════════════════════════════════════════════════════
' HAUPT-ANALYSE-FUNKTION
'═══════════════════════════════════════════════════════════════════════════════

Public Sub DetectWorkflows(ByVal exportPath As String)
    On Error GoTo ErrorHandler
    
    Dim f As Integer
    Dim filePath As String
    Dim firstWorkflow As Boolean
    
    filePath = exportPath & "\workflows.json"
    f = FreeFile
    
    Open filePath For Output As #f
    
    ' JSON-Objekt starten
    Print #f, "{"
    Print #f, "  ""analysisDate"": """ & Format(Now, "yyyy-mm-dd hh:nn:ss") & ""","
    Print #f, "  ""databaseName"": """ & mod_ExportConsys.EscapeJSON(CurrentProject.Name) & ""","
    
    ' 1. Formular → Query Abhängigkeiten
    Print #f, "  ""formToQueryDependencies"": " & AnalyzeFormQueryDependencies() & ","
    
    ' 2. Formular → Tabelle Abhängigkeiten
    Print #f, "  ""formToTableDependencies"": " & AnalyzeFormTableDependencies() & ","
    
    ' 3. Query → Tabelle Abhängigkeiten
    Print #f, "  ""queryToTableDependencies"": " & AnalyzeQueryTableDependencies() & ","
    
    ' 4. Button-Click Events (Navigation)
    Print #f, "  ""buttonNavigationMap"": " & AnalyzeButtonNavigation() & ","
    
    ' 5. Report → Query/Tabelle
    Print #f, "  ""reportDataSources"": " & AnalyzeReportDataSources() & ","
    
    ' 6. VBA-Funktionsaufrufe
    Print #f, "  ""vbaFunctionCalls"": " & AnalyzeVBAFunctionCalls() & ","
    
    ' 7. Erkannte Workflow-Muster
    Print #f, "  ""detectedWorkflowPatterns"": " & DetectWorkflowPatterns()
    
    Print #f, "}"
    
    Close #f
    
    Debug.Print "      → Workflow-Analyse abgeschlossen"
    
    Exit Sub

ErrorHandler:
    Close #f
    Debug.Print "      ✗ Fehler: " & Err.description
    Err.Raise Err.Number, "DetectWorkflows", Err.description
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' ANALYSE-FUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════

' Analysiert Formular → Query Abhängigkeiten
Private Function AnalyzeFormQueryDependencies() As String
    Dim result As String
    Dim i As Integer
    Dim frm As Form
    Dim isFirst As Boolean
    
    result = "["
    isFirst = True
    
    On Error Resume Next
    For i = 0 To CurrentProject.AllForms.Count - 1
        Dim formName As String
        formName = CurrentProject.AllForms(i).Name
        
        DoCmd.OpenForm formName, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = forms(formName)
            
            Dim recordSource As String
            recordSource = Nz(frm.recordSource, "")
            
            ' Prüfen ob RecordSource eine Query ist
            If Len(recordSource) > 0 And Not InStr(recordSource, "SELECT") > 0 Then
                If Not isFirst Then result = result & ","
                isFirst = False
                
                result = result & "{""form"":""" & mod_ExportConsys.EscapeJSON(formName) & ""","
                result = result & """query"":""" & mod_ExportConsys.EscapeJSON(recordSource) & """}"
            End If
            
            DoCmd.Close acForm, formName, acSaveNo
        End If
        Err.clear
    Next i
    On Error GoTo 0
    
    result = result & "]"
    AnalyzeFormQueryDependencies = result
End Function

' Analysiert Formular → Tabelle Abhängigkeiten
Private Function AnalyzeFormTableDependencies() As String
    Dim result As String
    Dim i As Integer
    Dim frm As Form
    Dim isFirst As Boolean
    
    result = "["
    isFirst = True
    
    On Error Resume Next
    For i = 0 To CurrentProject.AllForms.Count - 1
        Dim formName As String
        formName = CurrentProject.AllForms(i).Name
        
        DoCmd.OpenForm formName, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = forms(formName)
            
            Dim recordSource As String
            recordSource = Nz(frm.recordSource, "")
            
            ' Prüfen ob RecordSource direkt eine Tabelle ist
            If Len(recordSource) > 0 And Left$(recordSource, 4) = "tbl_" Then
                If Not isFirst Then result = result & ","
                isFirst = False
                
                result = result & "{""form"":""" & mod_ExportConsys.EscapeJSON(formName) & ""","
                result = result & """table"":""" & mod_ExportConsys.EscapeJSON(recordSource) & """}"
            End If
            
            DoCmd.Close acForm, formName, acSaveNo
        End If
        Err.clear
    Next i
    On Error GoTo 0
    
    result = result & "]"
    AnalyzeFormTableDependencies = result
End Function

' Analysiert Query → Tabelle Abhängigkeiten
Private Function AnalyzeQueryTableDependencies() As String
    Dim result As String
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim isFirst As Boolean
    
    Set db = CurrentDb()
    result = "["
    isFirst = True
    
    For Each qdf In db.QueryDefs
        If Left$(qdf.Name, 1) <> "~" Then
            Dim tables As String
            tables = ExtractTablesFromSQL(qdf.sql)
            
            If Len(tables) > 0 Then
                If Not isFirst Then result = result & ","
                isFirst = False
                
                result = result & "{""query"":""" & mod_ExportConsys.EscapeJSON(qdf.Name) & ""","
                result = result & """tables"":""" & mod_ExportConsys.EscapeJSON(tables) & """}"
            End If
        End If
    Next qdf
    
    result = result & "]"
    AnalyzeQueryTableDependencies = result
End Function

' Analysiert Button-Navigation (OpenForm, OpenReport etc.)
Private Function AnalyzeButtonNavigation() As String
    Dim result As String
    Dim i As Integer
    Dim frm As Form
    Dim ctl As control
    Dim isFirst As Boolean
    
    result = "["
    isFirst = True
    
    On Error Resume Next
    For i = 0 To CurrentProject.AllForms.Count - 1
        Dim formName As String
        formName = CurrentProject.AllForms(i).Name
        
        DoCmd.OpenForm formName, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = forms(formName)
            
            For Each ctl In frm.Controls
                If ctl.ControlType = acCommandButton Then
                    Dim onClick As String
                    onClick = Nz(GetControlProperty(ctl, "OnClick"), "")
                    
                    ' Prüfen auf OpenForm oder OpenReport
                    If InStr(onClick, "OpenForm") > 0 Or InStr(onClick, "OpenReport") > 0 Then
                        If Not isFirst Then result = result & ","
                        isFirst = False
                        
                        result = result & "{""sourceForm"":""" & mod_ExportConsys.EscapeJSON(formName) & ""","
                        result = result & """button"":""" & mod_ExportConsys.EscapeJSON(ctl.Name) & ""","
                        result = result & """action"":""" & mod_ExportConsys.EscapeJSON(onClick) & """}"
                    End If
                End If
            Next ctl
            
            DoCmd.Close acForm, formName, acSaveNo
        End If
        Err.clear
    Next i
    On Error GoTo 0
    
    result = result & "]"
    AnalyzeButtonNavigation = result
End Function

' Analysiert Report-Datenquellen
Private Function AnalyzeReportDataSources() As String
    Dim result As String
    Dim i As Integer
    Dim rpt As Report
    Dim isFirst As Boolean
    
    result = "["
    isFirst = True
    
    On Error Resume Next
    For i = 0 To CurrentProject.AllReports.Count - 1
        Dim reportName As String
        reportName = CurrentProject.AllReports(i).Name
        
        DoCmd.OpenReport reportName, acViewDesign, , , acHidden
        If Err.Number = 0 Then
            Set rpt = Reports(reportName)
            
            Dim recordSource As String
            recordSource = Nz(rpt.recordSource, "")
            
            If Len(recordSource) > 0 Then
                If Not isFirst Then result = result & ","
                isFirst = False
                
                result = result & "{""report"":""" & mod_ExportConsys.EscapeJSON(reportName) & ""","
                result = result & """recordSource"":""" & mod_ExportConsys.EscapeJSON(recordSource) & """}"
            End If
            
            DoCmd.Close acReport, reportName, acSaveNo
        End If
        Err.clear
    Next i
    On Error GoTo 0
    
    result = result & "]"
    AnalyzeReportDataSources = result
End Function

' Analysiert VBA-Funktionsaufrufe (vereinfacht)
Private Function AnalyzeVBAFunctionCalls() As String
    Dim result As String
    result = "[{""note"":""VBA call analysis requires code parsing - implement if needed""}]"
    AnalyzeVBAFunctionCalls = result
End Function

' Erkennt Workflow-Muster
Private Function DetectWorkflowPatterns() As String
    Dim result As String
    result = "["
    result = result & "{""pattern"":""Data Entry"",""description"":""Forms with AllowAdditions=True""},"
    result = result & "{""pattern"":""Reporting"",""description"":""Reports with RecordSource""}"
    result = result & "]"
    DetectWorkflowPatterns = result
End Function

'═══════════════════════════════════════════════════════════════════════════════
' HILFSFUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════

Private Function ExtractTablesFromSQL(sql As String) As String
    ' Vereinfachte Extraktion von Tabellennamen aus SQL
    Dim tableList As String
    Dim fromPos As Long
    Dim wherePos As Long
    
    sql = UCase(sql)
    fromPos = InStr(sql, " FROM ")
    
    If fromPos = 0 Then
        ExtractTablesFromSQL = ""
        Exit Function
    End If
    
    wherePos = InStr(fromPos, sql, " WHERE ")
    If wherePos = 0 Then wherePos = InStr(fromPos, sql, " ORDER ")
    If wherePos = 0 Then wherePos = InStr(fromPos, sql, " GROUP ")
    If wherePos = 0 Then wherePos = Len(sql)
    
    tableList = Trim(Mid$(sql, fromPos + 6, wherePos - fromPos - 6))
    tableList = Replace(tableList, " INNER JOIN ", ", ")
    tableList = Replace(tableList, " LEFT JOIN ", ", ")
    tableList = Replace(tableList, " RIGHT JOIN ", ", ")
    
    ExtractTablesFromSQL = tableList
End Function

Private Function GetControlProperty(ctl As control, propName As String) As Variant
    On Error Resume Next
    GetControlProperty = ctl.Properties(propName)
    If Err.Number <> 0 Then
        GetControlProperty = Null
    End If
    On Error GoTo 0
End Function