Attribute VB_Name = "mod_ExportForms"
'═══════════════════════════════════════════════════════════════════════════════
' Modul:     mod_ExportForms
' Zweck:     Export aller Formular-Definitionen zu JSON
' Autor:     Access-Forensiker Agent
' Datum:     2025-10-31
' Version:   1.1 - Mit verbesserter Fehlerbehandlung
'═══════════════════════════════════════════════════════════════════════════════

Option Compare Database
Option Explicit

'═══════════════════════════════════════════════════════════════════════════════
' HAUPT-EXPORT-FUNKTION
'═══════════════════════════════════════════════════════════════════════════════

Public Sub ExportFormsToJSON(ByVal exportPath As String)
    On Error GoTo ErrorHandler
    
    Dim f As Integer
    Dim filePath As String
    Dim i As Integer
    Dim firstForm As Boolean
    Dim formCount As Integer
    Dim skippedCount As Integer
    Dim af As Access.AccessObject
    
    filePath = exportPath & "\forms.json"
    f = FreeFile
    
    Open filePath For Output As #f
    
    ' JSON-Array starten
    Print #f, "["
    
    firstForm = True
    formCount = 0
    skippedCount = 0
    
    ' Alle Formulare durchgehen
    For i = 0 To CurrentProject.AllForms.Count - 1
        Set af = CurrentProject.AllForms(i)
        
        ' Formular im Design-Modus öffnen
        On Error Resume Next
        DoCmd.OpenForm af.Name, acDesign, , , , acHidden
        
        If Err.Number = 0 Then
            On Error GoTo ErrorHandler
            
            ' Komma vor weiteren Einträgen
            If Not firstForm Then
                Print #f, ","
            End If
            firstForm = False
            formCount = formCount + 1
            
            ' Formular-Objekt exportieren (mit Fehlerbehandlung)
            If Not ExportSingleFormSafe(f, af.Name) Then
                ' Bei Fehler: Placeholder einfügen
                Debug.Print "      ⚠ Formular '" & af.Name & "' teilweise exportiert (mit Fehlern)"
                skippedCount = skippedCount + 1
            End If
            
            ' Formular schließen ohne Speichern
            DoCmd.Close acForm, af.Name, acSaveNo
        Else
            ' Fehler beim Öffnen - Placeholder einfügen
            Debug.Print "      ⚠ Formular '" & af.Name & "' konnte nicht ge�ffnet werden: " & Err.description
            
            If Not firstForm Then
                Print #f, ","
            End If
            firstForm = False
            
            Print #f, "  {"
            Print #f, "    ""name"": """ & mod_ExportConsys.EscapeJSON(af.Name) & ""","
            Print #f, "    ""error"": ""Could not open form - " & mod_ExportConsys.EscapeJSON(Err.description) & ""","
            Print #f, "    ""recordSource"": ""ERROR"","
            Print #f, "    ""controls"": []"
            Print #f, "  }"
            
            skippedCount = skippedCount + 1
            On Error GoTo ErrorHandler
        End If
    Next i
    
    ' JSON-Array schließen
    Print #f, "]"
    
    Close #f
    
    Debug.Print "      → " & formCount & " Formulare exportiert"
    If skippedCount > 0 Then
        Debug.Print "      ⚠ " & skippedCount & " Formulare mit Fehlern/Warnungen"
    End If
    
    Exit Sub

ErrorHandler:
    On Error Resume Next
    Close #f
    DoCmd.Close acForm, , acSaveNo
    On Error GoTo 0
    Debug.Print "      ✗ Fehler: " & Err.description
    Err.Raise Err.Number, "ExportFormsToJSON", Err.description
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' EINZELNES FORMULAR EXPORTIEREN (MIT FEHLERBEHANDLUNG)
'═══════════════════════════════════════════════════════════════════════════════

Private Function ExportSingleFormSafe(fileNum As Integer, formName As String) As Boolean
    On Error GoTo FormError
    
    Dim frm As Form
    Dim ctl As control
    Dim firstCtrl As Boolean
    Dim firstEvent As Boolean
    Dim hadError As Boolean
    
    hadError = False
    Set frm = Forms(formName)
    
    ' Formular-Basis-Infos
    Print #fileNum, "  {"
    Print #fileNum, "    ""name"": """ & mod_ExportConsys.EscapeJSON(formName) & ""","
    Print #fileNum, "    ""caption"": """ & mod_ExportConsys.EscapeJSON(Nz(SafeGetProperty(frm, "Caption", ""), "")) & ""","
    
    ' RecordSource mit Fehlerbehandlung
    Dim recordSource As String
    On Error Resume Next
    recordSource = frm.recordSource
    If Err.Number <> 0 Then
        recordSource = "ERROR: " & Err.description
        hadError = True
        Err.clear
    End If
    On Error GoTo FormError
    
    Print #fileNum, "    ""recordSource"": """ & mod_ExportConsys.EscapeJSON(Nz(recordSource, "")) & ""","
    Print #fileNum, "    ""defaultView"": " & SafeGetProperty(frm, "DefaultView", 0) & ","
    Print #fileNum, "    ""viewsAllowed"": " & SafeGetProperty(frm, "ViewsAllowed", 0) & ","
    Print #fileNum, "    ""allowAdditions"": " & LCase(SafeGetProperty(frm, "AllowAdditions", False)) & ","
    Print #fileNum, "    ""allowDeletions"": " & LCase(SafeGetProperty(frm, "AllowDeletions", False)) & ","
    Print #fileNum, "    ""allowEdits"": " & LCase(SafeGetProperty(frm, "AllowEdits", False)) & ","
    Print #fileNum, "    ""dataEntry"": " & LCase(SafeGetProperty(frm, "DataEntry", False)) & ","
    Print #fileNum, "    ""recordSelectors"": " & LCase(SafeGetProperty(frm, "RecordSelectors", True)) & ","
    Print #fileNum, "    ""navigationButtons"": " & LCase(SafeGetProperty(frm, "NavigationButtons", True)) & ","
    Print #fileNum, "    ""popUp"": " & LCase(SafeGetProperty(frm, "PopUp", False)) & ","
    Print #fileNum, "    ""modal"": " & LCase(SafeGetProperty(frm, "Modal", False)) & ","
    
    ' Filter und OrderBy
    Print #fileNum, "    ""filter"": """ & mod_ExportConsys.EscapeJSON(Nz(SafeGetProperty(frm, "Filter", ""), "")) & ""","
    Print #fileNum, "    ""orderBy"": """ & mod_ExportConsys.EscapeJSON(Nz(SafeGetProperty(frm, "OrderBy", ""), "")) & ""","
    Print #fileNum, "    ""filterOnLoad"": " & LCase(SafeGetProperty(frm, "FilterOnLoad", False)) & ","
    Print #fileNum, "    ""orderByOnLoad"": " & LCase(SafeGetProperty(frm, "OrderByOnLoad", False)) & ","
    
    ' Events exportieren
    Print #fileNum, "    ""events"": {"
    firstEvent = True
    ExportFormEvent fileNum, frm, "OnLoad", firstEvent
    ExportFormEvent fileNum, frm, "OnOpen", firstEvent
    ExportFormEvent fileNum, frm, "OnClose", firstEvent
    ExportFormEvent fileNum, frm, "OnCurrent", firstEvent
    ExportFormEvent fileNum, frm, "BeforeUpdate", firstEvent
    ExportFormEvent fileNum, frm, "AfterUpdate", firstEvent
    ExportFormEvent fileNum, frm, "OnActivate", firstEvent
    ExportFormEvent fileNum, frm, "OnDeactivate", firstEvent
    Print #fileNum, "    },"
    
    ' Controls exportieren
    Print #fileNum, "    ""controls"": ["
    firstCtrl = True
    
    On Error Resume Next
    For Each ctl In frm.Controls
        If Err.Number = 0 Then
            If Not firstCtrl Then
                Print #fileNum, ","
            End If
            firstCtrl = False
            
            ExportControl fileNum, ctl
        Else
            ' Fehler bei diesem Control - weitermachen
            Err.clear
        End If
    Next ctl
    On Error GoTo FormError
    
    Print #fileNum, "    ]"
    Print #fileNum, "  }"
    
    ExportSingleFormSafe = Not hadError
    Exit Function

FormError:
    ' Bei kritischem Fehler: Minimal-Export
    Print #fileNum, "  {"
    Print #fileNum, "    ""name"": """ & mod_ExportConsys.EscapeJSON(formName) & ""","
    Print #fileNum, "    ""error"": ""Export failed - " & mod_ExportConsys.EscapeJSON(Err.description) & ""","
    Print #fileNum, "    ""recordSource"": ""ERROR"","
    Print #fileNum, "    ""controls"": []"
    Print #fileNum, "  }"
    ExportSingleFormSafe = False
End Function

'═══════════════════════════════════════════════════════════════════════════════
' SICHERE PROPERTY-ABFRAGE
'═══════════════════════════════════════════════════════════════════════════════

Private Function SafeGetProperty(obj As Object, propName As String, defaultValue As Variant) As Variant
    On Error Resume Next
    SafeGetProperty = obj.Properties(propName)
    If Err.Number <> 0 Then
        SafeGetProperty = defaultValue
    End If
    On Error GoTo 0
End Function

'═══════════════════════════════════════════════════════════════════════════════
' CONTROL EXPORTIEREN
'═══════════════════════════════════════════════════════════════════════════════

Private Sub ExportControl(fileNum As Integer, ctl As control)
    Dim firstEvent As Boolean
    
    On Error Resume Next
    
    Print #fileNum, "      {"
    Print #fileNum, "        ""name"": """ & mod_ExportConsys.EscapeJSON(ctl.Name) & ""","
    Print #fileNum, "        ""controlType"": " & ctl.ControlType & ","
    Print #fileNum, "        ""controlTypeName"": """ & GetControlTypeName(ctl.ControlType) & ""","
    Print #fileNum, "        ""controlSource"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "ControlSource"), "")) & ""","
    
    ' Spezielle Properties je nach Control-Typ
    Select Case ctl.ControlType
        Case acTextBox, acComboBox, acListBox
            Print #fileNum, "        ""rowSource"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "RowSource"), "")) & ""","
            Print #fileNum, "        ""rowSourceType"": """ & GetControlProperty(ctl, "RowSourceType") & ""","
        Case acCommandButton
            Print #fileNum, "        ""caption"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "Caption"), "")) & ""","
        Case acLabel
            Print #fileNum, "        ""caption"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "Caption"), "")) & ""","
        Case acSubform
            Print #fileNum, "        ""sourceObject"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "SourceObject"), "")) & ""","
            Print #fileNum, "        ""linkChildFields"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "LinkChildFields"), "")) & ""","
            Print #fileNum, "        ""linkMasterFields"": """ & mod_ExportConsys.EscapeJSON(Nz(GetControlProperty(ctl, "LinkMasterFields"), "")) & ""","
    End Select
    
    ' Visible und Enabled
    Print #fileNum, "        ""visible"": " & LCase(GetControlProperty(ctl, "Visible")) & ","
    Print #fileNum, "        ""enabled"": " & LCase(GetControlProperty(ctl, "Enabled")) & ","
    Print #fileNum, "        ""locked"": " & LCase(GetControlProperty(ctl, "Locked")) & ","
    
    ' Events exportieren
    Print #fileNum, "        ""events"": {"
    firstEvent = True
    ExportControlEvent fileNum, ctl, "OnClick", firstEvent
    ExportControlEvent fileNum, ctl, "OnDblClick", firstEvent
    ExportControlEvent fileNum, ctl, "BeforeUpdate", firstEvent
    ExportControlEvent fileNum, ctl, "AfterUpdate", firstEvent
    ExportControlEvent fileNum, ctl, "OnEnter", firstEvent
    ExportControlEvent fileNum, ctl, "OnExit", firstEvent
    ExportControlEvent fileNum, ctl, "OnGotFocus", firstEvent
    ExportControlEvent fileNum, ctl, "OnLostFocus", firstEvent
    ExportControlEvent fileNum, ctl, "OnChange", firstEvent
    Print #fileNum, "        }"
    
    Print #fileNum, "      }"
    
    On Error GoTo 0
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' EVENT EXPORTIEREN
'═══════════════════════════════════════════════════════════════════════════════

Private Sub ExportFormEvent(fileNum As Integer, frm As Form, eventName As String, ByRef isFirst As Boolean)
    Dim eventValue As String
    On Error Resume Next
    eventValue = frm.Properties(eventName)
    If Err.Number = 0 And Len(Nz(eventValue, "")) > 0 Then
        If Not isFirst Then Print #fileNum, ","
        isFirst = False
        Print #fileNum, "      """ & eventName & """: """ & mod_ExportConsys.EscapeJSON(eventValue) & """"
    End If
    On Error GoTo 0
End Sub

Private Sub ExportControlEvent(fileNum As Integer, ctl As control, eventName As String, ByRef isFirst As Boolean)
    Dim eventValue As String
    On Error Resume Next
    eventValue = ctl.Properties(eventName)
    If Err.Number = 0 And Len(Nz(eventValue, "")) > 0 Then
        If Not isFirst Then Print #fileNum, ","
        isFirst = False
        Print #fileNum, "          """ & eventName & """: """ & mod_ExportConsys.EscapeJSON(eventValue) & """"
    End If
    On Error GoTo 0
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' HILFSFUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════
Public Function GetControlTypeName(ctl As control) As String
    Select Case ctl.ControlType
        Case Access.acOptionGroup:      GetControlTypeName = "OptionGroup"
        Case Access.acBoundObjectFrame: GetControlTypeName = "BoundObjectFrame"
        Case Access.acCheckBox:         GetControlTypeName = "CheckBox"
        Case Access.acComboBox:         GetControlTypeName = "ComboBox"
        Case Access.acCommandButton:    GetControlTypeName = "CommandButton"
        Case Access.acTextBox:          GetControlTypeName = "TextBox"
        Case Access.acListBox:          GetControlTypeName = "ListBox"
        Case Access.acLabel:            GetControlTypeName = "Label"
        Case Access.acImage:            GetControlTypeName = "Image"
        Case Access.acLine:             GetControlTypeName = "Line"
        Case Access.acRectangle:        GetControlTypeName = "Rectangle"
        Case Access.acSubform:          GetControlTypeName = "Subform"
        Case Access.acObjectFrame:      GetControlTypeName = "ObjectFrame"
        Case Access.acPageBreak:        GetControlTypeName = "PageBreak"
        Case Access.acCustomControl:    GetControlTypeName = "CustomControl"
        Case Access.acToggleButton:     GetControlTypeName = "ToggleButton"
        Case Access.acTabCtl:           GetControlTypeName = "TabControl"   ' <� nicht acTab!
        Case Access.acPage:             GetControlTypeName = "Page"
        Case Else
            GetControlTypeName = "Unknown (" & ctl.ControlType & ")"
    End Select
End Function

Private Function GetControlProperty(ctl As control, propName As String) As Variant
    On Error Resume Next
    GetControlProperty = ctl.Properties(propName)
    If Err.Number <> 0 Then
        GetControlProperty = Null
    End If
    On Error GoTo 0
End Function
