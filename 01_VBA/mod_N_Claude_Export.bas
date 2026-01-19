' ============================================================================
' Modul: mod_N_Claude_Export
' Beschreibung: Exportiert ALLE Access-Formular-Eigenschaften, Events, Relationen
'               für Claude/Claude Code zur HTML-Konvertierung
' Erstellt: 2026-01-16
' Version: 1.0.0
' ============================================================================
Option Compare Database
Option Explicit

' Konstanten für Export-Pfade
Private Const EXPORT_FOLDER As String = "exports\claude\"
Private Const EXPORT_PREFIX As String = "CLAUDE_EXPORT_"

' ============================================================================
' HAUPT-EXPORT-FUNKTION
' ============================================================================
Public Sub ExportAllesFuerClaude()
    '
    ' Exportiert ALLES was Claude für HTML-Konvertierung braucht
    '
    On Error GoTo ErrHandler
    
    Dim exportPath As String
    Dim startTime As Date
    Dim formCount As Long
    Dim moduleCount As Long
    
    startTime = Now
    
    ' Export-Ordner erstellen
    exportPath = CurrentProject.Path & "\" & EXPORT_FOLDER
    CreateExportFolder exportPath
    
    ' Status
    Debug.Print "=============================================="
    Debug.Print "CLAUDE EXPORT GESTARTET: " & Format(startTime, "yyyy-mm-dd hh:nn:ss")
    Debug.Print "Export-Pfad: " & exportPath
    Debug.Print "=============================================="
    
    ' 1. Alle Formulare exportieren
    Debug.Print vbCrLf & ">>> FORMULARE EXPORTIEREN..."
    formCount = ExportAlleFormulare(exportPath)
    Debug.Print "    " & formCount & " Formulare exportiert"
    
    ' 2. Alle VBA-Module exportieren
    Debug.Print vbCrLf & ">>> VBA-MODULE EXPORTIEREN..."
    moduleCount = ExportAlleModule(exportPath)
    Debug.Print "    " & moduleCount & " Module exportiert"
    
    ' 3. Tabellen-Schema exportieren
    Debug.Print vbCrLf & ">>> TABELLEN-SCHEMA EXPORTIEREN..."
    ExportTabellenSchema exportPath
    
    ' 4. Abfragen exportieren
    Debug.Print vbCrLf & ">>> ABFRAGEN EXPORTIEREN..."
    ExportAbfragen exportPath
    
    ' 5. Beziehungen exportieren
    Debug.Print vbCrLf & ">>> BEZIEHUNGEN EXPORTIEREN..."
    ExportBeziehungen exportPath
    
    ' 6. Gesamtübersicht erstellen
    Debug.Print vbCrLf & ">>> GESAMTÜBERSICHT ERSTELLEN..."
    ErstelleGesamtuebersicht exportPath, formCount, moduleCount
    
    ' Fertig
    Debug.Print vbCrLf & "=============================================="
    Debug.Print "CLAUDE EXPORT ABGESCHLOSSEN!"
    Debug.Print "Dauer: " & Format(Now - startTime, "nn:ss") & " Minuten"
    Debug.Print "Pfad: " & exportPath
    Debug.Print "=============================================="
    
    MsgBox "Export für Claude abgeschlossen!" & vbCrLf & vbCrLf & _
           "Formulare: " & formCount & vbCrLf & _
           "Module: " & moduleCount & vbCrLf & vbCrLf & _
           "Pfad: " & exportPath, vbInformation, "Claude Export"
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER in ExportAllesFuerClaude: " & Err.Description
    MsgBox "Fehler beim Export: " & Err.Description, vbCritical, "Fehler"
End Sub

' ============================================================================
' FORMULAR-EXPORT
' ============================================================================
Private Function ExportAlleFormulare(exportPath As String) As Long
    '
    ' Exportiert alle Formulare mit allen Details
    '
    On Error GoTo ErrHandler
    
    Dim frm As AccessObject
    Dim frmCount As Long
    Dim frmPath As String
    
    ' Unterordner für Formulare
    frmPath = exportPath & "formulare\"
    CreateExportFolder frmPath
    
    frmCount = 0
    
    For Each frm In CurrentProject.AllForms
        ' Nur echte Formulare (keine Systemformulare)
        If Left(frm.Name, 4) <> "MSys" Then
            ExportEinFormular frm.Name, frmPath
            frmCount = frmCount + 1
            Debug.Print "    [" & frmCount & "] " & frm.Name
        End If
    Next frm
    
    ExportAlleFormulare = frmCount
    Exit Function
    
ErrHandler:
    Debug.Print "FEHLER in ExportAlleFormulare: " & Err.Description
    ExportAlleFormulare = frmCount
End Function

Private Sub ExportEinFormular(formName As String, exportPath As String)
    '
    ' Exportiert ein einzelnes Formular mit ALLEN Details
    '
    On Error GoTo ErrHandler
    
    Dim frm As Form
    Dim ctl As Control
    Dim json As String
    Dim filePath As String
    Dim fileNum As Integer
    Dim wasOpen As Boolean
    
    ' Formular öffnen (falls nicht offen)
    wasOpen = IsFormOpen(formName)
    If Not wasOpen Then
        DoCmd.OpenForm formName, acDesign, , , , acHidden
    End If
    
    Set frm = Forms(formName)
    
    ' JSON-Export erstellen
    json = "{"
    json = json & vbCrLf & "  ""formular"": {"
    json = json & vbCrLf & "    ""name"": """ & EscapeJSON(formName) & ""","
    json = json & vbCrLf & "    ""exportDatum"": """ & Format(Now, "yyyy-mm-dd hh:nn:ss") & ""","
    
    ' Formular-Eigenschaften
    json = json & vbCrLf & "    ""eigenschaften"": " & GetFormularEigenschaften(frm) & ","
    
    ' Formular-Events
    json = json & vbCrLf & "    ""events"": " & GetFormularEvents(frm) & ","
    
    ' Datenquelle
    json = json & vbCrLf & "    ""datenquelle"": {"
    json = json & vbCrLf & "      ""recordSource"": """ & EscapeJSON(Nz(frm.RecordSource, "")) & ""","
    json = json & vbCrLf & "      ""filter"": """ & EscapeJSON(Nz(frm.Filter, "")) & ""","
    json = json & vbCrLf & "      ""filterOn"": " & IIf(frm.FilterOn, "true", "false") & ","
    json = json & vbCrLf & "      ""orderBy"": """ & EscapeJSON(Nz(frm.OrderBy, "")) & ""","
    json = json & vbCrLf & "      ""orderByOn"": " & IIf(frm.OrderByOn, "true", "false")
    json = json & vbCrLf & "    },"
    
    ' Controls
    json = json & vbCrLf & "    ""controls"": ["
    
    Dim firstCtl As Boolean
    firstCtl = True
    
    For Each ctl In frm.Controls
        If Not firstCtl Then json = json & ","
        json = json & vbCrLf & "      " & GetControlDetails(ctl)
        firstCtl = False
    Next ctl
    
    json = json & vbCrLf & "    ]"
    json = json & vbCrLf & "  }"
    json = json & vbCrLf & "}"
    
    ' Datei schreiben
    filePath = exportPath & formName & ".json"
    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
    
    ' VBA-Code des Formulars separat exportieren
    ExportFormularCode formName, exportPath
    
    ' Formular schließen falls wir es geöffnet haben
    If Not wasOpen Then
        DoCmd.Close acForm, formName, acSaveNo
    End If
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER bei Formular " & formName & ": " & Err.Description
    If Not wasOpen Then
        On Error Resume Next
        DoCmd.Close acForm, formName, acSaveNo
    End If
End Sub

Private Function GetFormularEigenschaften(frm As Form) As String
    '
    ' Gibt alle Formular-Eigenschaften als JSON zurück
    '
    On Error Resume Next
    
    Dim json As String
    
    json = "{"
    
    ' Basis-Eigenschaften
    json = json & vbCrLf & "      ""caption"": """ & EscapeJSON(Nz(frm.Caption, "")) & ""","
    json = json & vbCrLf & "      ""defaultView"": " & frm.DefaultView & ","
    json = json & vbCrLf & "      ""allowEdits"": " & IIf(frm.AllowEdits, "true", "false") & ","
    json = json & vbCrLf & "      ""allowDeletions"": " & IIf(frm.AllowDeletions, "true", "false") & ","
    json = json & vbCrLf & "      ""allowAdditions"": " & IIf(frm.AllowAdditions, "true", "false") & ","
    json = json & vbCrLf & "      ""dataEntry"": " & IIf(frm.DataEntry, "true", "false") & ","
    
    ' Größe und Position
    json = json & vbCrLf & "      ""width"": " & frm.Width & ","
    json = json & vbCrLf & "      ""windowWidth"": " & frm.WindowWidth & ","
    json = json & vbCrLf & "      ""windowHeight"": " & frm.WindowHeight & ","
    
    ' Visuelle Eigenschaften
    json = json & vbCrLf & "      ""scrollBars"": " & frm.ScrollBars & ","
    json = json & vbCrLf & "      ""recordSelectors"": " & IIf(frm.RecordSelectors, "true", "false") & ","
    json = json & vbCrLf & "      ""navigationButtons"": " & IIf(frm.NavigationButtons, "true", "false") & ","
    json = json & vbCrLf & "      ""dividers"": " & IIf(frm.Dividers, "true", "false") & ","
    json = json & vbCrLf & "      ""autoCenter"": " & IIf(frm.AutoCenter, "true", "false") & ","
    json = json & vbCrLf & "      ""autoResize"": " & IIf(frm.AutoResize, "true", "false") & ","
    json = json & vbCrLf & "      ""borderStyle"": " & frm.BorderStyle & ","
    json = json & vbCrLf & "      ""controlBox"": " & IIf(frm.ControlBox, "true", "false") & ","
    json = json & vbCrLf & "      ""minMaxButtons"": " & frm.MinMaxButtons & ","
    json = json & vbCrLf & "      ""closeButton"": " & IIf(frm.CloseButton, "true", "false") & ","
    json = json & vbCrLf & "      ""modal"": " & IIf(frm.Modal, "true", "false") & ","
    json = json & vbCrLf & "      ""popUp"": " & IIf(frm.PopUp, "true", "false") & ","
    
    ' Farben (Long zu Hex)
    json = json & vbCrLf & "      ""backColor"": """ & LongToHex(frm.Section(acDetail).BackColor) & ""","
    
    ' Sections vorhanden?
    json = json & vbCrLf & "      ""hasHeader"": " & IIf(HasSection(frm, acHeader), "true", "false") & ","
    json = json & vbCrLf & "      ""hasFooter"": " & IIf(HasSection(frm, acFooter), "true", "false") & ","
    json = json & vbCrLf & "      ""hasDetail"": true"
    
    json = json & vbCrLf & "    }"
    
    GetFormularEigenschaften = json
End Function

Private Function GetFormularEvents(frm As Form) As String
    '
    ' Gibt alle Formular-Events als JSON zurück
    '
    On Error Resume Next
    
    Dim json As String
    
    json = "{"
    
    ' Load/Unload Events
    json = json & vbCrLf & "      ""onLoad"": """ & EscapeJSON(Nz(frm.OnLoad, "")) & ""","
    json = json & vbCrLf & "      ""onUnload"": """ & EscapeJSON(Nz(frm.OnUnload, "")) & ""","
    json = json & vbCrLf & "      ""onOpen"": """ & EscapeJSON(Nz(frm.OnOpen, "")) & ""","
    json = json & vbCrLf & "      ""onClose"": """ & EscapeJSON(Nz(frm.OnClose, "")) & ""","
    
    ' Current/Navigation Events
    json = json & vbCrLf & "      ""onCurrent"": """ & EscapeJSON(Nz(frm.OnCurrent, "")) & ""","
    
    ' Daten-Events
    json = json & vbCrLf & "      ""beforeInsert"": """ & EscapeJSON(Nz(frm.BeforeInsert, "")) & ""","
    json = json & vbCrLf & "      ""afterInsert"": """ & EscapeJSON(Nz(frm.AfterInsert, "")) & ""","
    json = json & vbCrLf & "      ""beforeUpdate"": """ & EscapeJSON(Nz(frm.BeforeUpdate, "")) & ""","
    json = json & vbCrLf & "      ""afterUpdate"": """ & EscapeJSON(Nz(frm.AfterUpdate, "")) & ""","
    json = json & vbCrLf & "      ""onDelete"": """ & EscapeJSON(Nz(frm.OnDelete, "")) & ""","
    json = json & vbCrLf & "      ""beforeDelConfirm"": """ & EscapeJSON(Nz(frm.BeforeDelConfirm, "")) & ""","
    json = json & vbCrLf & "      ""afterDelConfirm"": """ & EscapeJSON(Nz(frm.AfterDelConfirm, "")) & ""","
    
    ' Sonstige Events
    json = json & vbCrLf & "      ""onActivate"": """ & EscapeJSON(Nz(frm.OnActivate, "")) & ""","
    json = json & vbCrLf & "      ""onDeactivate"": """ & EscapeJSON(Nz(frm.OnDeactivate, "")) & ""","
    json = json & vbCrLf & "      ""onResize"": """ & EscapeJSON(Nz(frm.OnResize, "")) & ""","
    json = json & vbCrLf & "      ""onTimer"": """ & EscapeJSON(Nz(frm.OnTimer, "")) & ""","
    json = json & vbCrLf & "      ""timerInterval"": " & Nz(frm.TimerInterval, 0) & ","
    json = json & vbCrLf & "      ""onError"": """ & EscapeJSON(Nz(frm.OnError, "")) & ""","
    json = json & vbCrLf & "      ""onFilter"": """ & EscapeJSON(Nz(frm.OnFilter, "")) & ""","
    json = json & vbCrLf & "      ""onApplyFilter"": """ & EscapeJSON(Nz(frm.OnApplyFilter, "")) & """"
    
    json = json & vbCrLf & "    }"
    
    GetFormularEvents = json
End Function

Private Function GetControlDetails(ctl As Control) As String
    '
    ' Gibt alle Details eines Controls als JSON zurück
    '
    On Error Resume Next
    
    Dim json As String
    Dim ctlType As String
    
    ' Control-Typ ermitteln
    ctlType = GetControlTypeName(ctl.ControlType)
    
    json = "{"
    
    ' Basis-Informationen
    json = json & """name"": """ & EscapeJSON(ctl.Name) & ""","
    json = json & """typ"": """ & ctlType & ""","
    json = json & """controlType"": " & ctl.ControlType & ","
    
    ' Position und Größe
    json = json & """position"": {"
    json = json & """left"": " & Nz(ctl.Left, 0) & ","
    json = json & """top"": " & Nz(ctl.Top, 0) & ","
    json = json & """width"": " & Nz(ctl.Width, 0) & ","
    json = json & """height"": " & Nz(ctl.Height, 0)
    json = json & "},"
    
    ' Visuelle Eigenschaften
    json = json & """visual"": {"
    json = json & """visible"": " & IIf(GetCtlProperty(ctl, "Visible", True), "true", "false") & ","
    json = json & """enabled"": " & IIf(GetCtlProperty(ctl, "Enabled", True), "true", "false") & ","
    json = json & """locked"": " & IIf(GetCtlProperty(ctl, "Locked", False), "true", "false") & ","
    json = json & """backColor"": """ & LongToHex(GetCtlProperty(ctl, "BackColor", 16777215)) & ""","
    json = json & """foreColor"": """ & LongToHex(GetCtlProperty(ctl, "ForeColor", 0)) & ""","
    json = json & """borderColor"": """ & LongToHex(GetCtlProperty(ctl, "BorderColor", 0)) & ""","
    json = json & """borderStyle"": " & GetCtlProperty(ctl, "BorderStyle", 0) & ","
    json = json & """borderWidth"": " & GetCtlProperty(ctl, "BorderWidth", 0) & ","
    json = json & """specialEffect"": " & GetCtlProperty(ctl, "SpecialEffect", 0)
    json = json & "},"
    
    ' Schrift
    json = json & """font"": {"
    json = json & """name"": """ & EscapeJSON(GetCtlProperty(ctl, "FontName", "")) & ""","
    json = json & """size"": " & GetCtlProperty(ctl, "FontSize", 8) & ","
    json = json & """bold"": " & IIf(GetCtlProperty(ctl, "FontBold", False), "true", "false") & ","
    json = json & """italic"": " & IIf(GetCtlProperty(ctl, "FontItalic", False), "true", "false") & ","
    json = json & """underline"": " & IIf(GetCtlProperty(ctl, "FontUnderline", False), "true", "false")
    json = json & "},"
    
    ' Daten-Eigenschaften (je nach Typ)
    json = json & """daten"": " & GetControlDatenEigenschaften(ctl) & ","
    
    ' Events
    json = json & """events"": " & GetControlEvents(ctl) & ","
    
    ' Bedingte Formatierung
    json = json & """bedingteFormatierung"": " & GetBedingteFormatierung(ctl) & ","
    
    ' Typ-spezifische Eigenschaften
    json = json & """typSpezifisch"": " & GetTypSpezifischeEigenschaften(ctl)
    
    json = json & "}"
    
    GetControlDetails = json
End Function

Private Function GetControlDatenEigenschaften(ctl As Control) As String
    '
    ' Gibt Daten-Eigenschaften eines Controls zurück
    '
    On Error Resume Next
    
    Dim json As String
    
    json = "{"
    json = json & """controlSource"": """ & EscapeJSON(GetCtlProperty(ctl, "ControlSource", "")) & ""","
    json = json & """defaultValue"": """ & EscapeJSON(GetCtlProperty(ctl, "DefaultValue", "")) & ""","
    json = json & """validationRule"": """ & EscapeJSON(GetCtlProperty(ctl, "ValidationRule", "")) & ""","
    json = json & """validationText"": """ & EscapeJSON(GetCtlProperty(ctl, "ValidationText", "")) & ""","
    json = json & """inputMask"": """ & EscapeJSON(GetCtlProperty(ctl, "InputMask", "")) & ""","
    json = json & """format"": """ & EscapeJSON(GetCtlProperty(ctl, "Format", "")) & ""","
    json = json & """tabIndex"": " & GetCtlProperty(ctl, "TabIndex", 0) & ","
    json = json & """tabStop"": " & IIf(GetCtlProperty(ctl, "TabStop", True), "true", "false")
    json = json & "}"
    
    GetControlDatenEigenschaften = json
End Function

Private Function GetControlEvents(ctl As Control) As String
    '
    ' Gibt alle Events eines Controls zurück
    '
    On Error Resume Next
    
    Dim json As String
    
    json = "{"
    
    ' Klick-Events
    json = json & """onClick"": """ & EscapeJSON(GetCtlProperty(ctl, "OnClick", "")) & ""","
    json = json & """onDblClick"": """ & EscapeJSON(GetCtlProperty(ctl, "OnDblClick", "")) & ""","
    
    ' Fokus-Events
    json = json & """onGotFocus"": """ & EscapeJSON(GetCtlProperty(ctl, "OnGotFocus", "")) & ""","
    json = json & """onLostFocus"": """ & EscapeJSON(GetCtlProperty(ctl, "OnLostFocus", "")) & ""","
    json = json & """onEnter"": """ & EscapeJSON(GetCtlProperty(ctl, "OnEnter", "")) & ""","
    json = json & """onExit"": """ & EscapeJSON(GetCtlProperty(ctl, "OnExit", "")) & ""","
    
    ' Daten-Events
    json = json & """onChange"": """ & EscapeJSON(GetCtlProperty(ctl, "OnChange", "")) & ""","
    json = json & """beforeUpdate"": """ & EscapeJSON(GetCtlProperty(ctl, "BeforeUpdate", "")) & ""","
    json = json & """afterUpdate"": """ & EscapeJSON(GetCtlProperty(ctl, "AfterUpdate", "")) & ""","
    
    ' Maus-Events
    json = json & """onMouseDown"": """ & EscapeJSON(GetCtlProperty(ctl, "OnMouseDown", "")) & ""","
    json = json & """onMouseUp"": """ & EscapeJSON(GetCtlProperty(ctl, "OnMouseUp", "")) & ""","
    json = json & """onMouseMove"": """ & EscapeJSON(GetCtlProperty(ctl, "OnMouseMove", "")) & ""","
    
    ' Tastatur-Events
    json = json & """onKeyDown"": """ & EscapeJSON(GetCtlProperty(ctl, "OnKeyDown", "")) & ""","
    json = json & """onKeyUp"": """ & EscapeJSON(GetCtlProperty(ctl, "OnKeyUp", "")) & ""","
    json = json & """onKeyPress"": """ & EscapeJSON(GetCtlProperty(ctl, "OnKeyPress", "")) & """"
    
    json = json & "}"
    
    GetControlEvents = json
End Function

Private Function GetBedingteFormatierung(ctl As Control) As String
    '
    ' Gibt bedingte Formatierungen zurück
    '
    On Error Resume Next
    
    Dim json As String
    Dim fc As FormatCondition
    Dim i As Long
    
    json = "["
    
    ' Prüfen ob Control FormatConditions hat
    If ctl.ControlType = acTextBox Or ctl.ControlType = acComboBox Then
        On Error Resume Next
        Dim fcCount As Long
        fcCount = ctl.FormatConditions.Count
        
        If fcCount > 0 Then
            For i = 0 To fcCount - 1
                Set fc = ctl.FormatConditions(i)
                If i > 0 Then json = json & ","
                
                json = json & "{"
                json = json & """index"": " & i & ","
                json = json & """type"": " & fc.Type & ","
                json = json & """operator"": " & fc.Operator & ","
                json = json & """expression1"": """ & EscapeJSON(Nz(fc.Expression1, "")) & ""","
                json = json & """expression2"": """ & EscapeJSON(Nz(fc.Expression2, "")) & ""","
                json = json & """backColor"": """ & LongToHex(fc.BackColor) & ""","
                json = json & """foreColor"": """ & LongToHex(fc.ForeColor) & ""","
                json = json & """fontBold"": " & IIf(fc.FontBold, "true", "false") & ","
                json = json & """fontItalic"": " & IIf(fc.FontItalic, "true", "false") & ","
                json = json & """fontUnderline"": " & IIf(fc.FontUnderline, "true", "false") & ","
                json = json & """enabled"": " & IIf(fc.Enabled, "true", "false")
                json = json & "}"
            Next i
        End If
    End If
    
    json = json & "]"
    
    GetBedingteFormatierung = json
End Function

Private Function GetTypSpezifischeEigenschaften(ctl As Control) As String
    '
    ' Gibt typ-spezifische Eigenschaften zurück
    '
    On Error Resume Next
    
    Dim json As String
    
    json = "{"
    
    Select Case ctl.ControlType
        Case acTextBox
            json = json & """textAlign"": " & GetCtlProperty(ctl, "TextAlign", 0) & ","
            json = json & """scrollBars"": " & GetCtlProperty(ctl, "ScrollBars", 0) & ","
            json = json & """enterKeyBehavior"": " & IIf(GetCtlProperty(ctl, "EnterKeyBehavior", False), "true", "false") & ","
            json = json & """allowAutoCorrect"": " & IIf(GetCtlProperty(ctl, "AllowAutoCorrect", True), "true", "false")
            
        Case acComboBox
            json = json & """rowSource"": """ & EscapeJSON(GetCtlProperty(ctl, "RowSource", "")) & ""","
            json = json & """rowSourceType"": """ & EscapeJSON(GetCtlProperty(ctl, "RowSourceType", "")) & ""","
            json = json & """columnCount"": " & GetCtlProperty(ctl, "ColumnCount", 1) & ","
            json = json & """columnWidths"": """ & EscapeJSON(GetCtlProperty(ctl, "ColumnWidths", "")) & ""","
            json = json & """boundColumn"": " & GetCtlProperty(ctl, "BoundColumn", 1) & ","
            json = json & """listWidth"": " & GetCtlProperty(ctl, "ListWidth", 0) & ","
            json = json & """listRows"": " & GetCtlProperty(ctl, "ListRows", 8) & ","
            json = json & """limitToList"": " & IIf(GetCtlProperty(ctl, "LimitToList", True), "true", "false") & ","
            json = json & """autoExpand"": " & IIf(GetCtlProperty(ctl, "AutoExpand", True), "true", "false")
            
        Case acListBox
            json = json & """rowSource"": """ & EscapeJSON(GetCtlProperty(ctl, "RowSource", "")) & ""","
            json = json & """rowSourceType"": """ & EscapeJSON(GetCtlProperty(ctl, "RowSourceType", "")) & ""","
            json = json & """columnCount"": " & GetCtlProperty(ctl, "ColumnCount", 1) & ","
            json = json & """columnWidths"": """ & EscapeJSON(GetCtlProperty(ctl, "ColumnWidths", "")) & ""","
            json = json & """columnHeads"": " & IIf(GetCtlProperty(ctl, "ColumnHeads", False), "true", "false") & ","
            json = json & """boundColumn"": " & GetCtlProperty(ctl, "BoundColumn", 1) & ","
            json = json & """multiSelect"": " & GetCtlProperty(ctl, "MultiSelect", 0)
            
        Case acCommandButton
            json = json & """caption"": """ & EscapeJSON(GetCtlProperty(ctl, "Caption", "")) & ""","
            json = json & """picture"": """ & EscapeJSON(GetCtlProperty(ctl, "Picture", "")) & ""","
            json = json & """pictureType"": " & GetCtlProperty(ctl, "PictureType", 0) & ","
            json = json & """transparent"": " & IIf(GetCtlProperty(ctl, "Transparent", False), "true", "false") & ","
            json = json & """default"": " & IIf(GetCtlProperty(ctl, "Default", False), "true", "false") & ","
            json = json & """cancel"": " & IIf(GetCtlProperty(ctl, "Cancel", False), "true", "false")
            
        Case acCheckBox
            json = json & """tripleState"": " & IIf(GetCtlProperty(ctl, "TripleState", False), "true", "false") & ","
            json = json & """optionValue"": " & GetCtlProperty(ctl, "OptionValue", 1)
            
        Case acOptionButton
            json = json & """optionValue"": " & GetCtlProperty(ctl, "OptionValue", 1)
            
        Case acLabel
            json = json & """caption"": """ & EscapeJSON(GetCtlProperty(ctl, "Caption", "")) & ""","
            json = json & """textAlign"": " & GetCtlProperty(ctl, "TextAlign", 0)
            
        Case acSubform
            json = json & """sourceObject"": """ & EscapeJSON(GetCtlProperty(ctl, "SourceObject", "")) & ""","
            json = json & """linkChildFields"": """ & EscapeJSON(GetCtlProperty(ctl, "LinkChildFields", "")) & ""","
            json = json & """linkMasterFields"": """ & EscapeJSON(GetCtlProperty(ctl, "LinkMasterFields", "")) & """"
            
        Case acTabCtl
            json = json & """tabFixedWidth"": " & GetCtlProperty(ctl, "TabFixedWidth", 0) & ","
            json = json & """tabFixedHeight"": " & GetCtlProperty(ctl, "TabFixedHeight", 0) & ","
            json = json & """multiRow"": " & IIf(GetCtlProperty(ctl, "MultiRow", False), "true", "false") & ","
            json = json & """style"": " & GetCtlProperty(ctl, "Style", 0) & ","
            json = json & """pages"": " & GetTabPages(ctl)
            
        Case Else
            json = json & """hinweis"": ""Keine typ-spezifischen Eigenschaften"""
    End Select
    
    json = json & "}"
    
    GetTypSpezifischeEigenschaften = json
End Function

Private Function GetTabPages(tabCtl As Control) As String
    '
    ' Gibt Tab-Seiten zurück
    '
    On Error Resume Next
    
    Dim json As String
    Dim pg As Page
    Dim i As Long
    
    json = "["
    
    For i = 0 To tabCtl.Pages.Count - 1
        Set pg = tabCtl.Pages(i)
        If i > 0 Then json = json & ","
        
        json = json & "{"
        json = json & """index"": " & i & ","
        json = json & """name"": """ & EscapeJSON(pg.Name) & ""","
        json = json & """caption"": """ & EscapeJSON(pg.Caption) & ""","
        json = json & """visible"": " & IIf(pg.Visible, "true", "false") & ","
        json = json & """enabled"": " & IIf(pg.Enabled, "true", "false")
        json = json & "}"
    Next i
    
    json = json & "]"
    
    GetTabPages = json
End Function

' ============================================================================
' VBA-MODUL-EXPORT
' ============================================================================
Private Function ExportAlleModule(exportPath As String) As Long
    '
    ' Exportiert alle VBA-Module
    '
    On Error GoTo ErrHandler
    
    Dim vbComp As Object
    Dim modPath As String
    Dim modCount As Long
    
    ' Unterordner für Module
    modPath = exportPath & "vba\"
    CreateExportFolder modPath
    
    modCount = 0
    
    For Each vbComp In Application.VBE.ActiveVBProject.VBComponents
        Select Case vbComp.Type
            Case 1 ' Standard Module
                vbComp.Export modPath & vbComp.Name & ".bas"
                modCount = modCount + 1
                Debug.Print "    [MOD] " & vbComp.Name
                
            Case 2 ' Class Module
                vbComp.Export modPath & vbComp.Name & ".cls"
                modCount = modCount + 1
                Debug.Print "    [CLS] " & vbComp.Name
        End Select
    Next vbComp
    
    ExportAlleModule = modCount
    Exit Function
    
ErrHandler:
    Debug.Print "FEHLER in ExportAlleModule: " & Err.Description
    ExportAlleModule = modCount
End Function

Private Sub ExportFormularCode(formName As String, exportPath As String)
    '
    ' Exportiert den VBA-Code eines Formulars
    '
    On Error Resume Next
    
    Dim vbComp As Object
    Dim codePath As String
    
    codePath = exportPath & "vba\"
    CreateExportFolder codePath
    
    Set vbComp = Application.VBE.ActiveVBProject.VBComponents("Form_" & formName)
    
    If Not vbComp Is Nothing Then
        If vbComp.CodeModule.CountOfLines > 0 Then
            vbComp.Export codePath & "Form_" & formName & ".cls"
        End If
    End If
End Sub

' ============================================================================
' TABELLEN-EXPORT
' ============================================================================
Private Sub ExportTabellenSchema(exportPath As String)
    '
    ' Exportiert Schema aller Tabellen
    '
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim tdf As DAO.TableDef
    Dim fld As DAO.Field
    Dim idx As DAO.Index
    Dim json As String
    Dim filePath As String
    Dim fileNum As Integer
    Dim firstTbl As Boolean
    Dim firstFld As Boolean
    
    Set db = CurrentDb
    
    json = "{"
    json = json & vbCrLf & "  ""tabellen"": ["
    
    firstTbl = True
    
    For Each tdf In db.TableDefs
        ' Nur echte Tabellen (keine System- oder verknüpften)
        If Left(tdf.Name, 4) <> "MSys" And Left(tdf.Name, 1) <> "~" Then
            If Not firstTbl Then json = json & ","
            
            json = json & vbCrLf & "    {"
            json = json & vbCrLf & "      ""name"": """ & EscapeJSON(tdf.Name) & ""","
            json = json & vbCrLf & "      ""felder"": ["
            
            firstFld = True
            For Each fld In tdf.Fields
                If Not firstFld Then json = json & ","
                
                json = json & vbCrLf & "        {"
                json = json & """name"": """ & EscapeJSON(fld.Name) & ""","
                json = json & """typ"": """ & GetFieldTypeName(fld.Type) & ""","
                json = json & """typeCode"": " & fld.Type & ","
                json = json & """size"": " & fld.Size & ","
                json = json & """required"": " & IIf(fld.Required, "true", "false") & ","
                json = json & """allowZeroLength"": " & IIf(fld.AllowZeroLength, "true", "false")
                json = json & "}"
                
                firstFld = False
            Next fld
            
            json = json & vbCrLf & "      ]"
            json = json & vbCrLf & "    }"
            
            firstTbl = False
            Debug.Print "    [TBL] " & tdf.Name
        End If
    Next tdf
    
    json = json & vbCrLf & "  ]"
    json = json & vbCrLf & "}"
    
    ' Datei schreiben
    filePath = exportPath & "tabellen_schema.json"
    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER in ExportTabellenSchema: " & Err.Description
End Sub

' ============================================================================
' ABFRAGEN-EXPORT
' ============================================================================
Private Sub ExportAbfragen(exportPath As String)
    '
    ' Exportiert alle Abfragen
    '
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim json As String
    Dim filePath As String
    Dim fileNum As Integer
    Dim firstQry As Boolean
    
    Set db = CurrentDb
    
    json = "{"
    json = json & vbCrLf & "  ""abfragen"": ["
    
    firstQry = True
    
    For Each qdf In db.QueryDefs
        ' Keine System-Abfragen
        If Left(qdf.Name, 1) <> "~" Then
            If Not firstQry Then json = json & ","
            
            json = json & vbCrLf & "    {"
            json = json & vbCrLf & "      ""name"": """ & EscapeJSON(qdf.Name) & ""","
            json = json & vbCrLf & "      ""type"": " & qdf.Type & ","
            json = json & vbCrLf & "      ""sql"": """ & EscapeJSON(qdf.SQL) & """"
            json = json & vbCrLf & "    }"
            
            firstQry = False
            Debug.Print "    [QRY] " & qdf.Name
        End If
    Next qdf
    
    json = json & vbCrLf & "  ]"
    json = json & vbCrLf & "}"
    
    ' Datei schreiben
    filePath = exportPath & "abfragen.json"
    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER in ExportAbfragen: " & Err.Description
End Sub

' ============================================================================
' BEZIEHUNGEN-EXPORT
' ============================================================================
Private Sub ExportBeziehungen(exportPath As String)
    '
    ' Exportiert alle Tabellenbeziehungen
    '
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rel As DAO.Relation
    Dim fld As DAO.Field
    Dim json As String
    Dim filePath As String
    Dim fileNum As Integer
    Dim firstRel As Boolean
    Dim firstFld As Boolean
    
    Set db = CurrentDb
    
    json = "{"
    json = json & vbCrLf & "  ""beziehungen"": ["
    
    firstRel = True
    
    For Each rel In db.Relations
        If Not firstRel Then json = json & ","
        
        json = json & vbCrLf & "    {"
        json = json & vbCrLf & "      ""name"": """ & EscapeJSON(rel.Name) & ""","
        json = json & vbCrLf & "      ""primaryTable"": """ & EscapeJSON(rel.Table) & ""","
        json = json & vbCrLf & "      ""foreignTable"": """ & EscapeJSON(rel.ForeignTable) & ""","
        json = json & vbCrLf & "      ""attributes"": " & rel.Attributes & ","
        json = json & vbCrLf & "      ""felder"": ["
        
        firstFld = True
        For Each fld In rel.Fields
            If Not firstFld Then json = json & ","
            json = json & vbCrLf & "        {"
            json = json & """primary"": """ & EscapeJSON(fld.Name) & ""","
            json = json & """foreign"": """ & EscapeJSON(fld.ForeignName) & """"
            json = json & "}"
            firstFld = False
        Next fld
        
        json = json & vbCrLf & "      ]"
        json = json & vbCrLf & "    }"
        
        firstRel = False
        Debug.Print "    [REL] " & rel.Name
    Next rel
    
    json = json & vbCrLf & "  ]"
    json = json & vbCrLf & "}"
    
    ' Datei schreiben
    filePath = exportPath & "beziehungen.json"
    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, json
    Close #fileNum
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER in ExportBeziehungen: " & Err.Description
End Sub

' ============================================================================
' GESAMTÜBERSICHT
' ============================================================================
Private Sub ErstelleGesamtuebersicht(exportPath As String, formCount As Long, moduleCount As Long)
    '
    ' Erstellt eine Markdown-Übersicht für Claude
    '
    On Error GoTo ErrHandler
    
    Dim md As String
    Dim filePath As String
    Dim fileNum As Integer
    
    md = "# CONSYS Access Export für Claude" & vbCrLf & vbCrLf
    md = md & "**Exportiert:** " & Format(Now, "yyyy-mm-dd hh:nn:ss") & vbCrLf
    md = md & "**Datenbank:** " & CurrentProject.Name & vbCrLf & vbCrLf
    
    md = md & "## Statistik" & vbCrLf & vbCrLf
    md = md & "| Kategorie | Anzahl |" & vbCrLf
    md = md & "|-----------|--------|" & vbCrLf
    md = md & "| Formulare | " & formCount & " |" & vbCrLf
    md = md & "| VBA-Module | " & moduleCount & " |" & vbCrLf
    md = md & "| Tabellen | " & CurrentDb.TableDefs.Count & " |" & vbCrLf
    md = md & "| Abfragen | " & CurrentDb.QueryDefs.Count & " |" & vbCrLf
    md = md & "| Beziehungen | " & CurrentDb.Relations.Count & " |" & vbCrLf & vbCrLf
    
    md = md & "## Dateistruktur" & vbCrLf & vbCrLf
    md = md & "```" & vbCrLf
    md = md & "exports/claude/" & vbCrLf
    md = md & "├── formulare/          # JSON pro Formular" & vbCrLf
    md = md & "│   ├── frm_*.json      # Eigenschaften, Events, Controls" & vbCrLf
    md = md & "│   └── vba/            # VBA-Code der Formulare" & vbCrLf
    md = md & "├── vba/                # Alle VBA-Module" & vbCrLf
    md = md & "├── tabellen_schema.json" & vbCrLf
    md = md & "├── abfragen.json" & vbCrLf
    md = md & "├── beziehungen.json" & vbCrLf
    md = md & "└── README.md           # Diese Datei" & vbCrLf
    md = md & "```" & vbCrLf & vbCrLf
    
    md = md & "## Verwendung in Claude" & vbCrLf & vbCrLf
    md = md & "```" & vbCrLf
    md = md & "Lies: exports/claude/formulare/frm_va_Auftragstamm.json" & vbCrLf
    md = md & "```" & vbCrLf & vbCrLf
    
    md = md & "## JSON-Struktur (Formulare)" & vbCrLf & vbCrLf
    md = md & "```json" & vbCrLf
    md = md & "{" & vbCrLf
    md = md & "  ""formular"": {" & vbCrLf
    md = md & "    ""name"": ""Formularname""," & vbCrLf
    md = md & "    ""eigenschaften"": { ... }," & vbCrLf
    md = md & "    ""events"": { onLoad, onCurrent, ... }," & vbCrLf
    md = md & "    ""datenquelle"": { recordSource, filter, ... }," & vbCrLf
    md = md & "    ""controls"": [" & vbCrLf
    md = md & "      {" & vbCrLf
    md = md & "        ""name"": ""txtFeld1""," & vbCrLf
    md = md & "        ""typ"": ""TextBox""," & vbCrLf
    md = md & "        ""position"": { left, top, width, height }," & vbCrLf
    md = md & "        ""visual"": { visible, enabled, colors, ... }," & vbCrLf
    md = md & "        ""font"": { name, size, bold, ... }," & vbCrLf
    md = md & "        ""daten"": { controlSource, defaultValue, ... }," & vbCrLf
    md = md & "        ""events"": { onClick, onDblClick, onChange, ... }," & vbCrLf
    md = md & "        ""bedingteFormatierung"": [ ... ]," & vbCrLf
    md = md & "        ""typSpezifisch"": { ... }" & vbCrLf
    md = md & "      }" & vbCrLf
    md = md & "    ]" & vbCrLf
    md = md & "  }" & vbCrLf
    md = md & "}" & vbCrLf
    md = md & "```" & vbCrLf
    
    ' Datei schreiben
    filePath = exportPath & "README.md"
    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, md
    Close #fileNum
    
    Exit Sub
    
ErrHandler:
    Debug.Print "FEHLER in ErstelleGesamtuebersicht: " & Err.Description
End Sub

' ============================================================================
' HILFSFUNKTIONEN
' ============================================================================
Private Sub CreateExportFolder(folderPath As String)
    On Error Resume Next
    
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FolderExists(folderPath) Then
        fso.CreateFolder folderPath
    End If
End Sub

Private Function IsFormOpen(formName As String) As Boolean
    On Error Resume Next
    IsFormOpen = (SysCmd(acSysCmdGetObjectState, acForm, formName) <> 0)
End Function

Private Function HasSection(frm As Form, sectionType As AcSection) As Boolean
    On Error Resume Next
    HasSection = (frm.Section(sectionType).Height > 0)
    If Err.Number <> 0 Then HasSection = False
End Function

Private Function GetCtlProperty(ctl As Control, propName As String, defaultVal As Variant) As Variant
    On Error Resume Next
    GetCtlProperty = CallByName(ctl, propName, VbGet)
    If Err.Number <> 0 Then GetCtlProperty = defaultVal
End Function

Private Function EscapeJSON(str As String) As String
    Dim result As String
    result = str
    result = Replace(result, "\", "\\")
    result = Replace(result, """", "\""")
    result = Replace(result, vbCr, "\r")
    result = Replace(result, vbLf, "\n")
    result = Replace(result, vbTab, "\t")
    EscapeJSON = result
End Function

Private Function LongToHex(colorLong As Long) As String
    On Error Resume Next
    Dim r As Long, g As Long, b As Long
    r = colorLong And 255
    g = (colorLong \ 256) And 255
    b = (colorLong \ 65536) And 255
    LongToHex = "#" & Right("0" & Hex(r), 2) & Right("0" & Hex(g), 2) & Right("0" & Hex(b), 2)
End Function

Private Function GetControlTypeName(ctlType As Integer) As String
    Select Case ctlType
        Case acLabel: GetControlTypeName = "Label"
        Case acTextBox: GetControlTypeName = "TextBox"
        Case acComboBox: GetControlTypeName = "ComboBox"
        Case acListBox: GetControlTypeName = "ListBox"
        Case acCheckBox: GetControlTypeName = "CheckBox"
        Case acOptionButton: GetControlTypeName = "OptionButton"
        Case acToggleButton: GetControlTypeName = "ToggleButton"
        Case acCommandButton: GetControlTypeName = "CommandButton"
        Case acOptionGroup: GetControlTypeName = "OptionGroup"
        Case acBoundObjectFrame: GetControlTypeName = "BoundObjectFrame"
        Case acImage: GetControlTypeName = "Image"
        Case acUnboundObjectFrame: GetControlTypeName = "UnboundObjectFrame"
        Case acLine: GetControlTypeName = "Line"
        Case acRectangle: GetControlTypeName = "Rectangle"
        Case acPage: GetControlTypeName = "Page"
        Case acPageBreak: GetControlTypeName = "PageBreak"
        Case acSubform: GetControlTypeName = "SubForm"
        Case acTabCtl: GetControlTypeName = "TabControl"
        Case acCustomControl: GetControlTypeName = "CustomControl"
        Case Else: GetControlTypeName = "Unknown_" & ctlType
    End Select
End Function

Private Function GetFieldTypeName(fldType As Integer) As String
    Select Case fldType
        Case dbBoolean: GetFieldTypeName = "Boolean"
        Case dbByte: GetFieldTypeName = "Byte"
        Case dbInteger: GetFieldTypeName = "Integer"
        Case dbLong: GetFieldTypeName = "Long"
        Case dbCurrency: GetFieldTypeName = "Currency"
        Case dbSingle: GetFieldTypeName = "Single"
        Case dbDouble: GetFieldTypeName = "Double"
        Case dbDate: GetFieldTypeName = "Date"
        Case dbBinary: GetFieldTypeName = "Binary"
        Case dbText: GetFieldTypeName = "Text"
        Case dbLongBinary: GetFieldTypeName = "LongBinary"
        Case dbMemo: GetFieldTypeName = "Memo"
        Case dbGUID: GetFieldTypeName = "GUID"
        Case Else: GetFieldTypeName = "Unknown_" & fldType
    End Select
End Function

' ============================================================================
' EINZEL-FORMULAR-EXPORT (für schnellen Zugriff)
' ============================================================================
Public Sub ExportEinzelFormular(formName As String)
    '
    ' Exportiert ein einzelnes Formular
    '
    Dim exportPath As String
    exportPath = CurrentProject.Path & "\" & EXPORT_FOLDER & "formulare\"
    CreateExportFolder CurrentProject.Path & "\" & EXPORT_FOLDER
    CreateExportFolder exportPath
    
    ExportEinFormular formName, exportPath
    
    MsgBox "Formular '" & formName & "' exportiert!" & vbCrLf & vbCrLf & _
           "Pfad: " & exportPath & formName & ".json", vbInformation, "Export"
End Sub

' ============================================================================
' SCHNELL-AUFRUF
' ============================================================================
Public Sub Claude_Export()
    ' Alias für einfachen Aufruf
    ExportAllesFuerClaude
End Sub
