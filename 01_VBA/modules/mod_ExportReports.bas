Attribute VB_Name = "mod_ExportReports"
Option Compare Database
Option Explicit

'------------------------------------------------------------------------------
'  HAUPT-EXPORT-FUNKTION
'------------------------------------------------------------------------------
Public Sub ExportReportsToJSON(ByVal exportPath As String)
    On Error GoTo ErrorHandler

    Dim f As Integer
    Dim filePath As String
    Dim i As Long
    Dim firstReport As Boolean
    Dim reportCount As Long
    Dim skippedCount As Long
    Dim ar As Access.AccessObject

    filePath = exportPath & "\reports.json"
    f = FreeFile
    Open filePath For Output As #f

    ' JSON-Array starten
    Print #f, "["
    firstReport = True
    reportCount = 0
    skippedCount = 0

    ' Alle Reports durchgehen
    For i = 0 To CurrentProject.AllReports.Count - 1
        Set ar = CurrentProject.AllReports(i)

        ' Report im Design-Modus öffnen (hidden)
        On Error Resume Next
        DoCmd.OpenReport ar.Name, Access.acViewDesign, , , Access.acHidden

        If Err.Number = 0 Then
            On Error GoTo ErrorHandler

            ' Komma vor weiteren Einträgen
            If Not firstReport Then Print #f, ","
            firstReport = False
            reportCount = reportCount + 1

            ' Report-Objekt exportieren
            If Not ExportSingleReportSafe(f, ar.Name) Then
                Debug.Print "      ? Report '" & ar.Name & "' teilweise exportiert (mit Fehlern)"
                skippedCount = skippedCount + 1
            End If

            ' Report schließen ohne Speichern
            DoCmd.Close Access.acReport, ar.Name, Access.acSaveNo
        Else
            ' Fehler beim Öffnen – Placeholder schreiben
            Debug.Print "      ? Report '" & ar.Name & "' konnte nicht geöffnet werden: " & Err.description

            If Not firstReport Then Print #f, ","
            firstReport = False

            Print #f, "  {"
            Print #f, "    ""name"": """ & mod_ExportConsys.EscapeJSON(ar.Name) & ""","
            Print #f, "    ""error"": ""Could not open report - " & mod_ExportConsys.EscapeJSON(Err.description) & ""","
            Print #f, "    ""recordSource"": ""ERROR"","
            Print #f, "    ""controls"": []"
            Print #f, "  }"

            skippedCount = skippedCount + 1
            Err.clear
            On Error GoTo ErrorHandler
        End If
    Next i

    ' JSON-Array schließen
    Print #f, "]"
    Close #f

    Debug.Print "      ? " & reportCount & " Reports exportiert"
    If skippedCount > 0 Then Debug.Print "      ? " & skippedCount & " Reports mit Fehlern/Warnungen"
    Exit Sub

ErrorHandler:
    On Error Resume Next
    Close #f
    DoCmd.Close Access.acReport, , Access.acSaveNo
    Debug.Print "      ? Fehler: " & Err.description
    Err.Raise Err.Number, "ExportReportsToJSON", Err.description
End Sub

'------------------------------------------------------------------------------
'  EINZELNEN REPORT EXPORTIEREN (MIT FEHLERBEHANDLUNG)
'------------------------------------------------------------------------------
Private Function ExportSingleReportSafe(fileNum As Integer, reportName As String) As Boolean
    On Error GoTo ReportError

    Dim rpt As Report
    Dim ctl As control
    Dim firstCtrl As Boolean
    Dim firstEvent As Boolean
    Dim hadError As Boolean

    hadError = False
    Set rpt = Reports(reportName)

    ' Report-Basis-Infos
    Print #fileNum, "  {"
    Print #fileNum, "    ""name"": """ & mod_ExportConsys.EscapeJSON(reportName) & ""","
    Print #fileNum, "    ""caption"": """ & mod_ExportConsys.EscapeJSON(Nz(SafeGetProperty(rpt, "Caption", ""), "")) & ""","

    ' RecordSource mit Fehlerbehandlung
    Dim recordSource As String
    On Error Resume Next
    recordSource = rpt.recordSource
    If Err.Number <> 0 Then
        recordSource = "ERROR: " & Err.description
        hadError = True
        Err.clear
    End If
    On Error GoTo ReportError

    Print #fileNum, "    ""recordSource"": """ & mod_ExportConsys.EscapeJSON(Nz(recordSource, "")) & ""","
    Print #fileNum, "    ""filter"": """ & mod_ExportConsys.EscapeJSON(Nz(SafeGetProperty(rpt, "Filter", ""), "")) & ""","
    Print #fileNum, "    ""orderBy"": """ & mod_ExportConsys.EscapeJSON(Nz(SafeGetProperty(rpt, "OrderBy", ""), "")) & ""","
    Print #fileNum, "    ""filterOnLoad"": " & LCase$(CStr(SafeGetProperty(rpt, "FilterOnLoad", False))) & ","
    Print #fileNum, "    ""orderByOnLoad"": " & LCase$(CStr(SafeGetProperty(rpt, "OrderByOnLoad", False))) & ","

    ' Sections-Info
    Print #fileNum, "    ""sections"": {"
    On Error Resume Next
    Print #fileNum, "      ""hasReportHeader"": " & LCase$(CStr(rpt.Section(Access.acHeader).Visible)) & ","
    Print #fileNum, "      ""hasReportFooter"": " & LCase$(CStr(rpt.Section(Access.acFooter).Visible)) & ","
    Print #fileNum, "      ""hasPageHeader"": " & LCase$(CStr(rpt.Section(Access.acPageHeader).Visible)) & ","
    Print #fileNum, "      ""hasPageFooter"": " & LCase$(CStr(rpt.Section(Access.acPageFooter).Visible)) & ","
    Print #fileNum, "      ""hasDetail"": " & LCase$(CStr(rpt.Section(Access.acDetail).Visible))
    If Err.Number <> 0 Then Err.clear
    On Error GoTo ReportError
    Print #fileNum, "    },"

    ' Grouping & Sorting
    Print #fileNum, "    ""grouping"": {"
    Print #fileNum, "      ""groupLevelCount"": " & GetGroupLevelCount(rpt)
    Print #fileNum, "    },"

    ' Events exportieren
    Print #fileNum, "    ""events"": {"
    firstEvent = True
    ExportReportEvent fileNum, rpt, "OnOpen", firstEvent
    ExportReportEvent fileNum, rpt, "OnClose", firstEvent
    ExportReportEvent fileNum, rpt, "OnActivate", firstEvent
    ExportReportEvent fileNum, rpt, "OnDeactivate", firstEvent
    ExportReportEvent fileNum, rpt, "OnNoData", firstEvent
    ExportReportEvent fileNum, rpt, "OnPage", firstEvent
    Print #fileNum, "    },"

    ' Controls exportieren
    Print #fileNum, "    ""controls"": ["
    firstCtrl = True

    On Error Resume Next
    For Each ctl In rpt.Controls
        If Err.Number = 0 Then
            If Not firstCtrl Then Print #fileNum, ","
            firstCtrl = False
            ExportReportControl fileNum, ctl
        Else
            Err.clear
        End If
    Next ctl
    On Error GoTo ReportError

    Print #fileNum, "    ]"
    Print #fileNum, "  }"

    ExportSingleReportSafe = Not hadError
    Exit Function

ReportError:
    Print #fileNum, "  {"
    Print #fileNum, "    ""name"": """ & mod_ExportConsys.EscapeJSON(reportName) & ""","
    Print #fileNum, "    ""error"": ""Export failed - " & mod_ExportConsys.EscapeJSON(Err.description) & ""","
    Print #fileNum, "    ""recordSource"": ""ERROR"","
    Print #fileNum, "    ""controls"": []"
    Print #fileNum, "  }"
    ExportSingleReportSafe = False
End Function

' Zählt GroupLevels robust (0-basierter Index)
Private Function GetGroupLevelCount(rpt As Report) As Long
    Dim i As Long
    Dim gl As GroupLevel
    On Error Resume Next
    i = 0
    Do
        Set gl = rpt.GroupLevel(i)     ' erfordert Index; löst Fehler aus wenn out of range
        If Err.Number <> 0 Then Exit Do
        i = i + 1
        Err.clear
    Loop
    On Error GoTo 0
    GetGroupLevelCount = i
End Function

'------------------------------------------------------------------------------
'  SICHERE PROPERTY-ABFRAGE
'------------------------------------------------------------------------------
Private Function SafeGetProperty(obj As Object, propName As String, defaultValue As Variant) As Variant
    On Error Resume Next
    SafeGetProperty = obj.Properties(propName)
    If Err.Number <> 0 Then
        SafeGetProperty = defaultValue
        Err.clear
    End If
    On Error GoTo 0
End Function

'------------------------------------------------------------------------------
'  CONTROL EXPORTIEREN
'------------------------------------------------------------------------------
Private Sub ExportReportControl(fileNum As Integer, ctl As control)
    On Error Resume Next

    Print #fileNum, "      {"
    Print #fileNum, "        ""name"": """ & mod_ExportConsys.EscapeJSON(ctl.Name) & ""","
    Print #fileNum, "        ""controlType"": " & ctl.ControlType & ","
    Print #fileNum, "        ""controlTypeName"": """ & GetControlTypeName(ctl.ControlType) & ""","
    Print #fileNum, "        ""controlSource"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "ControlSource"), "")) & ""","
    Print #fileNum, "        ""section"": " & ctl.Section & ","
    Print #fileNum, "        ""visible"": " & LCase$(CStr(GetControlProperty(ctl, "Visible")))

    ' Spezielle Properties für bestimmte Control-Typen
    Select Case ctl.ControlType
        Case Access.acLabel, Access.acTextBox
            Dim caption As Variant
            caption = GetControlProperty(ctl, "Caption")
            If Not IsNull(caption) And Len(Nz(caption, "")) > 0 Then
                Print #fileNum, ","
                Print #fileNum, "        ""caption"": """ & mod_ExportConsys.EscapeJSON(caption) & """"
            End If

        Case Access.acSubform
            Print #fileNum, ","
            Print #fileNum, "        ""sourceObject"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "SourceObject"), "")) & """"
    End Select

    Print #fileNum, "      }"
    On Error GoTo 0
End Sub

'------------------------------------------------------------------------------
'  EVENT EXPORTIEREN
'------------------------------------------------------------------------------
Private Sub ExportReportEvent(fileNum As Integer, rpt As Report, eventName As String, ByRef isFirst As Boolean)
    Dim eventValue As String
    On Error Resume Next
    eventValue = rpt.Properties(eventName)
    If Err.Number = 0 And Len(Nz(eventValue, "")) > 0 Then
        If Not isFirst Then Print #fileNum, ","
        isFirst = False
        Print #fileNum, "      """ & eventName & """: """ & mod_ExportConsys.EscapeJSON(eventValue) & """"
    End If
    Err.clear
    On Error GoTo 0
End Sub

'------------------------------------------------------------------------------
'  HILFSFUNKTIONEN
'------------------------------------------------------------------------------
Private Function GetControlTypeName(ctrlType As Integer) As String
    Select Case ctrlType
        Case Access.acLabel:            GetControlTypeName = "Label"
        Case Access.acRectangle:        GetControlTypeName = "Rectangle"
        Case Access.acLine:             GetControlTypeName = "Line"
        Case Access.acImage:            GetControlTypeName = "Image"
        Case Access.acTextBox:          GetControlTypeName = "TextBox"
        Case Access.acComboBox:         GetControlTypeName = "ComboBox"
        Case Access.acListBox:          GetControlTypeName = "ListBox"
        Case Access.acCommandButton:    GetControlTypeName = "CommandButton"
        Case Access.acOptionGroup:      GetControlTypeName = "OptionGroup"
        Case Access.acCheckBox:         GetControlTypeName = "CheckBox"
        Case Access.acSubform:          GetControlTypeName = "Subreport"
        Case Access.acPageBreak:        GetControlTypeName = "PageBreak"
        Case Access.acToggleButton:     GetControlTypeName = "ToggleButton"
        Case Access.acTabCtl:           GetControlTypeName = "TabControl"
        Case Access.acPage:             GetControlTypeName = "Page"
        Case Else:                      GetControlTypeName = "Unknown (" & ctrlType & ")"
    End Select
End Function

Private Function GetControlProperty(ctl As control, propName As String) As Variant
    On Error Resume Next
    GetControlProperty = ctl.Properties(propName)
    If Err.Number <> 0 Then
        GetControlProperty = Null
        Err.clear
    End If
    On Error GoTo 0
End Function

