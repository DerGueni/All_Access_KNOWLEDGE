Attribute VB_Name = "mod_ClaudeExport_V2"
Option Compare Database
Option Explicit

' ============================================================================
' mod_ClaudeExport_V2 - Optimierter Export mit Index-System
' Erstellt strukturierte JSON-Dateien für schnellen Claude-Zugriff
' ============================================================================

Private Const EXPORT_BASE As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\"

' Hauptfunktion: Kompletter strukturierter Export
Public Sub ExportForClaudeV2()
    On Error GoTo ErrorHandler
    
    ' 1. Button-Index erstellen (alle Buttons aller Formulare)
    CreateButtonIndex
    
    ' 2. Event-Index erstellen (welche Events wo)
    CreateEventIndex
    
    ' 3. Control-Index erstellen (schnelle Suche nach Control-Namen)
    CreateControlIndex
    
    ' 4. Formular-Übersicht erstellen
    CreateFormOverview
    
    MsgBox "Export V2 abgeschlossen!" & vbCrLf & _
           "Neue Index-Dateien in: " & EXPORT_BASE, vbInformation
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler: " & Err.Description, vbCritical
End Sub

' Erstellt einen Index aller Buttons mit ihren Events
Private Sub CreateButtonIndex()
    Dim frm As Form
    Dim ctl As Control
    Dim frmObj As AccessObject
    Dim json As String
    Dim fileNum As Integer
    Dim isFirst As Boolean
    
    json = "{" & vbCrLf & "  ""buttons"": [" & vbCrLf
    isFirst = True
    
    For Each frmObj In CurrentProject.AllForms
        On Error Resume Next
        DoCmd.OpenForm frmObj.Name, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = Forms(frmObj.Name)
            
            For Each ctl In frm.Controls
                If ctl.ControlType = acCommandButton Then
                    If Not isFirst Then json = json & "," & vbCrLf
                    isFirst = False
                    
                    json = json & "    {" & vbCrLf
                    json = json & "      ""form"": """ & frmObj.Name & """," & vbCrLf
                    json = json & "      ""name"": """ & ctl.Name & """," & vbCrLf
                    json = json & "      ""caption"": """ & EscapeJson(Nz(ctl.Caption, "")) & """," & vbCrLf
                    json = json & "      ""left"": " & ctl.Left & "," & vbCrLf
                    json = json & "      ""top"": " & ctl.Top & "," & vbCrLf
                    json = json & "      ""width"": " & ctl.Width & "," & vbCrLf
                    json = json & "      ""height"": " & ctl.Height & "," & vbCrLf
                    json = json & "      ""visible"": " & LCase(ctl.Visible) & "," & vbCrLf
                    json = json & "      ""enabled"": " & LCase(ctl.Enabled) & "," & vbCrLf
                    json = json & "      ""onClick"": """ & GetEventStatus(ctl, "OnClick") & """," & vbCrLf
                    json = json & "      ""onDblClick"": """ & GetEventStatus(ctl, "OnDblClick") & """" & vbCrLf
                    json = json & "    }"
                End If
            Next ctl
            
            DoCmd.Close acForm, frmObj.Name, acSaveNo
        End If
        Err.Clear
        On Error GoTo 0
    Next frmObj
    
    json = json & vbCrLf & "  ]" & vbCrLf & "}"
    
    fileNum = FreeFile
    Open EXPORT_BASE & "BUTTON_INDEX.json" For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
End Sub

' Erstellt einen Index aller Events
Private Sub CreateEventIndex()
    Dim frm As Form
    Dim ctl As Control
    Dim frmObj As AccessObject
    Dim json As String
    Dim fileNum As Integer
    Dim isFirst As Boolean
    Dim eventTypes As Variant
    Dim i As Integer
    
    eventTypes = Array("OnClick", "OnDblClick", "AfterUpdate", "BeforeUpdate", "OnChange", "OnEnter", "OnExit", "OnCurrent", "OnOpen", "OnClose")
    
    json = "{" & vbCrLf & "  ""events"": [" & vbCrLf
    isFirst = True
    
    For Each frmObj In CurrentProject.AllForms
        On Error Resume Next
        DoCmd.OpenForm frmObj.Name, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = Forms(frmObj.Name)
            
            ' Form-Level Events
            For i = LBound(eventTypes) To UBound(eventTypes)
                If HasEvent(frm, CStr(eventTypes(i))) Then
                    If Not isFirst Then json = json & "," & vbCrLf
                    isFirst = False
                    json = json & "    {""form"": """ & frmObj.Name & """, ""control"": ""[Form]"", ""event"": """ & eventTypes(i) & """}"
                End If
            Next i
            
            ' Control-Level Events
            For Each ctl In frm.Controls
                For i = LBound(eventTypes) To UBound(eventTypes)
                    If HasControlEvent(ctl, CStr(eventTypes(i))) Then
                        If Not isFirst Then json = json & "," & vbCrLf
                        isFirst = False
                        json = json & "    {""form"": """ & frmObj.Name & """, ""control"": """ & ctl.Name & """, ""event"": """ & eventTypes(i) & """}"
                    End If
                Next i
            Next ctl
            
            DoCmd.Close acForm, frmObj.Name, acSaveNo
        End If
        Err.Clear
        On Error GoTo 0
    Next frmObj
    
    json = json & vbCrLf & "  ]" & vbCrLf & "}"
    
    fileNum = FreeFile
    Open EXPORT_BASE & "EVENT_INDEX.json" For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
End Sub

' Erstellt einen Index aller Controls für schnelle Suche
Private Sub CreateControlIndex()
    Dim frm As Form
    Dim ctl As Control
    Dim frmObj As AccessObject
    Dim json As String
    Dim fileNum As Integer
    Dim isFirst As Boolean
    Dim ctlTypeName As String
    
    json = "{" & vbCrLf & "  ""controls"": [" & vbCrLf
    isFirst = True
    
    For Each frmObj In CurrentProject.AllForms
        On Error Resume Next
        DoCmd.OpenForm frmObj.Name, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = Forms(frmObj.Name)
            
            For Each ctl In frm.Controls
                If Not isFirst Then json = json & "," & vbCrLf
                isFirst = False
                
                ctlTypeName = GetControlTypeName(ctl.ControlType)
                
                json = json & "    {""form"": """ & frmObj.Name & """, ""name"": """ & ctl.Name & """, ""type"": """ & ctlTypeName & """}"
            Next ctl
            
            DoCmd.Close acForm, frmObj.Name, acSaveNo
        End If
        Err.Clear
        On Error GoTo 0
    Next frmObj
    
    json = json & vbCrLf & "  ]" & vbCrLf & "}"
    
    fileNum = FreeFile
    Open EXPORT_BASE & "CONTROL_INDEX.json" For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
End Sub

' Erstellt eine Übersicht aller Formulare
Private Sub CreateFormOverview()
    Dim frmObj As AccessObject
    Dim frm As Form
    Dim json As String
    Dim fileNum As Integer
    Dim isFirst As Boolean
    Dim ctlCount As Integer
    Dim btnCount As Integer
    Dim ctl As Control
    
    json = "{" & vbCrLf & "  ""forms"": [" & vbCrLf
    isFirst = True
    
    For Each frmObj In CurrentProject.AllForms
        On Error Resume Next
        DoCmd.OpenForm frmObj.Name, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = Forms(frmObj.Name)
            
            ctlCount = frm.Controls.Count
            btnCount = 0
            For Each ctl In frm.Controls
                If ctl.ControlType = acCommandButton Then btnCount = btnCount + 1
            Next ctl
            
            If Not isFirst Then json = json & "," & vbCrLf
            isFirst = False
            
            json = json & "    {" & vbCrLf
            json = json & "      ""name"": """ & frmObj.Name & """," & vbCrLf
            json = json & "      ""controlCount"": " & ctlCount & "," & vbCrLf
            json = json & "      ""buttonCount"": " & btnCount & "," & vbCrLf
            json = json & "      ""recordSource"": """ & EscapeJson(Nz(frm.RecordSource, "")) & """," & vbCrLf
            json = json & "      ""hasVBA"": " & LCase(frm.HasModule) & vbCrLf
            json = json & "    }"
            
            DoCmd.Close acForm, frmObj.Name, acSaveNo
        End If
        Err.Clear
        On Error GoTo 0
    Next frmObj
    
    json = json & vbCrLf & "  ]" & vbCrLf & "}"
    
    fileNum = FreeFile
    Open EXPORT_BASE & "FORM_OVERVIEW.json" For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
End Sub

' Hilfsfunktionen
Private Function EscapeJson(s As String) As String
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCr, "\r")
    s = Replace(s, vbLf, "\n")
    s = Replace(s, vbTab, "\t")
    EscapeJson = s
End Function

Private Function GetEventStatus(ctl As Control, eventName As String) As String
    On Error Resume Next
    Dim val As String
    val = CallByName(ctl, eventName, VbGet)
    If Err.Number = 0 And Len(val) > 0 Then
        GetEventStatus = val
    Else
        GetEventStatus = ""
    End If
    Err.Clear
End Function

Private Function HasEvent(frm As Form, eventName As String) As Boolean
    On Error Resume Next
    Dim val As String
    val = CallByName(frm, eventName, VbGet)
    HasEvent = (Err.Number = 0 And InStr(val, "[Event Procedure]") > 0)
    Err.Clear
End Function

Private Function HasControlEvent(ctl As Control, eventName As String) As Boolean
    On Error Resume Next
    Dim val As String
    val = CallByName(ctl, eventName, VbGet)
    HasControlEvent = (Err.Number = 0 And InStr(val, "[Event Procedure]") > 0)
    Err.Clear
End Function

Private Function GetControlTypeName(ctlType As Integer) As String
    Select Case ctlType
        Case 100: GetControlTypeName = "Label"
        Case 101: GetControlTypeName = "Rectangle"
        Case 102: GetControlTypeName = "Line"
        Case 103: GetControlTypeName = "Image"
        Case 104: GetControlTypeName = "CommandButton"
        Case 105: GetControlTypeName = "OptionButton"
        Case 106: GetControlTypeName = "CheckBox"
        Case 107: GetControlTypeName = "OptionGroup"
        Case 108: GetControlTypeName = "BoundObjectFrame"
        Case 109: GetControlTypeName = "TextBox"
        Case 110: GetControlTypeName = "ListBox"
        Case 111: GetControlTypeName = "ComboBox"
        Case 112: GetControlTypeName = "Subform"
        Case 114: GetControlTypeName = "ObjectFrame"
        Case 118: GetControlTypeName = "PageBreak"
        Case 122: GetControlTypeName = "ToggleButton"
        Case 123: GetControlTypeName = "TabControl"
        Case 124: GetControlTypeName = "Page"
        Case Else: GetControlTypeName = "Unknown_" & ctlType
    End Select
End Function
