Attribute VB_Name = "mod_ClaudeExport_Ultimate"
Option Compare Database
Option Explicit

' ============================================================================
' mod_ClaudeExport_Ultimate - Optimierter Export für Claude AI
' Erstellt Index-Dateien für SOFORTIGEN Zugriff ohne Durchsuchen
' ============================================================================

Private Const EXPORT_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\"

' ===== HAUPTFUNKTION =====
Public Sub ExportUltimate()
    On Error GoTo ErrorHandler
    
    Dim startTime As Double
    startTime = Timer
    
    Debug.Print "=== CLAUDE EXPORT ULTIMATE START ==="
    
    ' 1. Master-Index: Alles in einer Datei
    Debug.Print "1/4 Erstelle MASTER_INDEX.json..."
    CreateMasterIndex
    
    ' 2. Button-Lookup: Button-Name -> Form + VBA-Funktion
    Debug.Print "2/4 Erstelle BUTTON_LOOKUP.json..."
    CreateButtonLookup
    
    ' 3. VBA-Event-Map: Welche Events rufen welche Funktionen
    Debug.Print "3/4 Erstelle VBA_EVENT_MAP.json..."
    CreateVBAEventMap
    
    ' 4. Form-Detail-Index: Schnellzugriff auf Formular-Details
    Debug.Print "4/4 Erstelle FORM_DETAIL_INDEX.json..."
    CreateFormDetailIndex
    
    Debug.Print "=== FERTIG in " & Round(Timer - startTime, 1) & " Sekunden ==="
    MsgBox "Export Ultimate abgeschlossen!" & vbCrLf & _
           "Dauer: " & Round(Timer - startTime, 1) & " Sek.", vbInformation
    Exit Sub
    
ErrorHandler:
    Debug.Print "FEHLER: " & Err.Description
    MsgBox "Fehler: " & Err.Description, vbCritical
End Sub

' ===== 1. MASTER INDEX =====
' Eine Datei mit ALLEM für schnellen Überblick
Private Sub CreateMasterIndex()
    Dim frm As Form, ctl As Control, frmObj As AccessObject
    Dim json As String, btnJson As String, ctlJson As String
    Dim isFirstForm As Boolean, isFirstBtn As Boolean, isFirstCtl As Boolean
    Dim btnCount As Long, ctlCount As Long, formCount As Long
    
    json = "{" & vbCrLf
    json = json & "  ""exportDate"": """ & Format(Now, "yyyy-mm-dd hh:nn:ss") & """," & vbCrLf
    json = json & "  ""forms"": [" & vbCrLf
    
    isFirstForm = True
    formCount = 0
    
    For Each frmObj In CurrentProject.AllForms
        On Error Resume Next
        DoCmd.OpenForm frmObj.Name, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = Forms(frmObj.Name)
            formCount = formCount + 1
            
            If Not isFirstForm Then json = json & "," & vbCrLf
            isFirstForm = False
            
            ' Buttons sammeln
            btnJson = ""
            isFirstBtn = True
            btnCount = 0
            For Each ctl In frm.Controls
                If ctl.ControlType = acCommandButton Then
                    btnCount = btnCount + 1
                    If Not isFirstBtn Then btnJson = btnJson & ","
                    isFirstBtn = False
                    btnJson = btnJson & """" & ctl.Name & """"
                End If
            Next ctl
            
            json = json & "    {""name"":""" & frmObj.Name & ""","
            json = json & """buttons"":[" & btnJson & "],"
            json = json & """buttonCount"":" & btnCount & ","
            json = json & """controlCount"":" & frm.Controls.Count & ","
            json = json & """recordSource"":""" & EscapeStr(Nz(frm.RecordSource, "")) & ""","
            json = json & """hasModule"":" & IIf(frm.HasModule, "true", "false") & "}"
            
            DoCmd.Close acForm, frmObj.Name, acSaveNo
        End If
        Err.Clear
    Next frmObj
    
    json = json & vbCrLf & "  ]," & vbCrLf
    json = json & "  ""totalForms"": " & formCount & vbCrLf
    json = json & "}"
    
    WriteUTF8File EXPORT_PATH & "MASTER_INDEX.json", json
End Sub

' ===== 2. BUTTON LOOKUP =====
' Button-Name -> Formular, Caption, Events, VBA-Funktion
Private Sub CreateButtonLookup()
    Dim frm As Form, ctl As Control, frmObj As AccessObject
    Dim json As String, isFirst As Boolean
    Dim onClick As String, onDblClick As String
    
    json = "{" & vbCrLf
    json = json & "  ""description"": ""Button-Name -> Formular + Events + VBA-Funktion""," & vbCrLf
    json = json & "  ""usage"": ""Suche nach Button-Name, finde sofort das Formular und die VBA-Datei""," & vbCrLf
    json = json & "  ""buttons"": {" & vbCrLf
    
    isFirst = True
    
    For Each frmObj In CurrentProject.AllForms
        On Error Resume Next
        DoCmd.OpenForm frmObj.Name, acDesign, , , , acHidden
        If Err.Number = 0 Then
            Set frm = Forms(frmObj.Name)
            
            For Each ctl In frm.Controls
                If ctl.ControlType = acCommandButton Then
                    onClick = GetEventProp(ctl, "OnClick")
                    onDblClick = GetEventProp(ctl, "OnDblClick")
                    
                    If Not isFirst Then json = json & "," & vbCrLf
                    isFirst = False
                    
                    json = json & "    """ & ctl.Name & """: {"
                    json = json & """form"":""" & frmObj.Name & ""","
                    json = json & """caption"":""" & EscapeStr(Nz(ctl.Caption, "")) & ""","
                    json = json & """visible"":" & IIf(ctl.Visible, "true", "false") & ","
                    json = json & """enabled"":" & IIf(ctl.Enabled, "true", "false") & ","
                    json = json & """hasOnClick"":" & IIf(Len(onClick) > 0, "true", "false") & ","
                    json = json & """hasOnDblClick"":" & IIf(Len(onDblClick) > 0, "true", "false") & ","
                    json = json & """vbaFile"":""exports/vba/forms/Form_" & frmObj.Name & ".bas"""
                    json = json & "}"
                End If
            Next ctl
            
            DoCmd.Close acForm, frmObj.Name, acSaveNo
        End If
        Err.Clear
    Next frmObj
    
    json = json & vbCrLf & "  }" & vbCrLf & "}"
    
    WriteUTF8File EXPORT_PATH & "BUTTON_LOOKUP.json", json
End Sub

' ===== 3. VBA EVENT MAP =====
' Welche Events existieren wo
Private Sub CreateVBAEventMap()
    Dim frm As Form, ctl As Control, frmObj As AccessObject
    Dim json As String, isFirst As Boolean
    Dim eventTypes As Variant, i As Integer
    Dim eventVal As String
    eventTypes = Array("OnClick", "OnDblClick", "AfterUpdate", "BeforeUpdate", "OnChange", "OnCurrent", "OnOpen", "OnClose", "OnEnter", "OnExit")
    
    json = "{" & vbCrLf
    json = json & "  ""description"": ""Alle VBA-Events nach Typ gruppiert""," & vbCrLf
    json = json & "  ""usage"": ""Finde alle Controls mit bestimmtem Event-Typ""," & vbCrLf
    
    ' Pro Event-Typ eine Liste
    For i = LBound(eventTypes) To UBound(eventTypes)
        json = json & "  """ & eventTypes(i) & """: [" & vbCrLf
        isFirst = True
        
        For Each frmObj In CurrentProject.AllForms
            On Error Resume Next
            DoCmd.OpenForm frmObj.Name, acDesign, , , , acHidden
            If Err.Number = 0 Then
                Set frm = Forms(frmObj.Name)
                
                ' Form-Level Event
                eventVal = GetEventProp(frm, CStr(eventTypes(i)))
                If InStr(eventVal, "[Event Procedure]") > 0 Then
                    If Not isFirst Then json = json & "," & vbCrLf
                    isFirst = False
                    json = json & "    {""form"":""" & frmObj.Name & """,""control"":""[Form]"",""vbaFunc"":""" & frmObj.Name & "_" & eventTypes(i) & """}"
                End If
                
                ' Control-Level Events
                For Each ctl In frm.Controls
                    eventVal = GetEventProp(ctl, CStr(eventTypes(i)))
                    If InStr(eventVal, "[Event Procedure]") > 0 Then
                        If Not isFirst Then json = json & "," & vbCrLf
                        isFirst = False
                        json = json & "    {""form"":""" & frmObj.Name & """,""control"":""" & ctl.Name & """,""vbaFunc"":""" & ctl.Name & "_" & Mid(eventTypes(i), 3) & """}"
                    End If
                Next ctl
                
                DoCmd.Close acForm, frmObj.Name, acSaveNo
            End If
            Err.Clear
        Next frmObj
        
        json = json & vbCrLf & "  ]"
        If i < UBound(eventTypes) Then json = json & ","
        json = json & vbCrLf
    Next i
    
    json = json & "}"
    
    WriteUTF8File EXPORT_PATH & "VBA_EVENT_MAP.json", json
End Sub

' ===== 4. FORM DETAIL INDEX =====
' Schnellzugriff: Formular -> alle relevanten Dateien
Private Sub CreateFormDetailIndex()
    Dim fso As Object
    Dim frmObj As AccessObject
    Dim json As String, isFirst As Boolean
    Dim formFolder As String
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    json = "{" & vbCrLf
    json = json & "  ""description"": ""Formular -> alle zugehörigen Export-Dateien""," & vbCrLf
    json = json & "  ""forms"": {" & vbCrLf
    
    isFirst = True
    
    For Each frmObj In CurrentProject.AllForms
        formFolder = EXPORT_PATH & "forms\" & frmObj.Name
        
        If Not isFirst Then json = json & "," & vbCrLf
        isFirst = False
        
        json = json & "    """ & frmObj.Name & """: {"
        json = json & """definition"":""exports/forms/" & frmObj.Name & ".txt"","
        
        ' Prüfe ob Unterordner existiert
        If fso.FolderExists(formFolder) Then
            json = json & """controls"":""exports/forms/" & frmObj.Name & "/controls.json"","
            json = json & """subforms"":""exports/forms/" & frmObj.Name & "/subforms.json"","
            json = json & """tabs"":""exports/forms/" & frmObj.Name & "/tabs.json"","
        Else
            json = json & """controls"":null,"
            json = json & """subforms"":null,"
            json = json & """tabs"":null,"
        End If
        
        ' VBA-Datei
        If fso.FileExists(EXPORT_PATH & "vba\forms\Form_" & frmObj.Name & ".bas") Then
            json = json & """vba"":""exports/vba/forms/Form_" & frmObj.Name & ".bas"""
        Else
            json = json & """vba"":null"
        End If
        
        json = json & "}"
    Next frmObj
    
    json = json & vbCrLf & "  }" & vbCrLf & "}"
    
    WriteUTF8File EXPORT_PATH & "FORM_DETAIL_INDEX.json", json
End Sub

' ===== HILFSFUNKTIONEN =====
Private Function EscapeStr(s As String) As String
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCr, "")
    s = Replace(s, vbLf, "")
    s = Replace(s, vbTab, " ")
    EscapeStr = s
End Function

Private Function GetEventProp(obj As Object, propName As String) As String
    On Error Resume Next
    GetEventProp = ""
    GetEventProp = CallByName(obj, propName, VbGet)
    Err.Clear
End Function

' UTF-8 Datei schreiben (ohne BOM)
Private Sub WriteUTF8File(filePath As String, content As String)
    Dim txtStream As Object, binStream As Object
    
    ' Text zu UTF-8 konvertieren
    Set txtStream = CreateObject("ADODB.Stream")
    txtStream.Type = 2 ' adTypeText
    txtStream.Charset = "UTF-8"
    txtStream.Open
    txtStream.WriteText content
    
    ' Position nach BOM setzen (3 Bytes)
    txtStream.Position = 0
    txtStream.Type = 1 ' adTypeBinary
    txtStream.Position = 3 ' Skip UTF-8 BOM
    
    ' Ohne BOM speichern
    Set binStream = CreateObject("ADODB.Stream")
    binStream.Type = 1 ' adTypeBinary
    binStream.Open
    txtStream.CopyTo binStream
    binStream.SaveToFile filePath, 2 ' adSaveCreateOverWrite
    
    binStream.Close
    txtStream.Close
End Sub
