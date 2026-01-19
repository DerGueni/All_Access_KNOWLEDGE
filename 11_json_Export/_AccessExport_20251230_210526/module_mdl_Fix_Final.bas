Option Compare Database
Option Explicit



Public Sub ExecuteFormFix()
    On Error Resume Next
    Dim frm As Form
    Dim ctl As control
    Dim leftMargin As Long
    Dim subformWidth As Long
    Dim subformHeight As Long
    Dim subformTop As Long
    Dim msg As String
    
    leftMargin = 567 * 5
    subformWidth = (567 * 29.7) - leftMargin - 567
    
    msg = "=== FIX START ===" & vbCrLf & vbCrLf
    
    ' Formular öffnen
    DoCmd.OpenForm "frm_MA_Monatsuebersicht", acDesign
    Set frm = forms("frm_MA_Monatsuebersicht")
    
    ' cboJahr
    Set ctl = frm.Controls("cboJahr")
    If Not ctl Is Nothing Then
        ctl.RowSourceType = "Value List"
        ctl.RowSource = "2023;2024;2025"
        ctl.defaultValue = "2025"
        ctl.ControlSource = ""
        ctl.AfterUpdate = "[Event Procedure]"
        msg = msg & "V cboJahr konfiguriert" & vbCrLf
    End If
    
    ' lblJahr
    Err.clear
    Set ctl = Nothing
    Set ctl = frm.Controls("lblJahr")
    If Err.Number <> 0 Then
        Set ctl = CreateControl(frm.Name, acLabel, , "cboJahr", , _
                                frm.Controls("cboJahr").Left + frm.Controls("cboJahr").width + 200, _
                                frm.Controls("cboJahr").Top)
        ctl.Name = "lblJahr"
        ctl.caption = "Jahr"
        msg = msg & "V lblJahr erstellt" & vbCrLf
    End If
    
    ' cboAnstellungsart
    Err.clear
    Set ctl = Nothing
    Set ctl = frm.Controls("cboAnstellungsart")
    If Err.Number <> 0 Then
        Set ctl = CreateControl(frm.Name, acComboBox, , , , _
                                frm.Controls("lblJahr").Left + frm.Controls("lblJahr").width + 1000, _
                                frm.Controls("cboJahr").Top)
        ctl.Name = "cboAnstellungsart"
        msg = msg & "V cboAnstellungsart erstellt" & vbCrLf
    End If
    
    If Not ctl Is Nothing Then
        ctl.RowSourceType = "Value List"
        ctl.RowSource = "3;Festangestellte;5;Minijobber"
        ctl.ColumnCount = 2
        ctl.ColumnWidths = "0cm;3cm"
        ctl.BoundColumn = 1
        ctl.defaultValue = "3"
        ctl.AfterUpdate = "[Event Procedure]"
        msg = msg & "V cboAnstellungsart konfiguriert" & vbCrLf
    End If
    
    ' lblAnstellungsart
    Err.clear
    Set ctl = Nothing
    Set ctl = frm.Controls("lblAnstellungsart")
    If Err.Number <> 0 Then
        Set ctl = CreateControl(frm.Name, acLabel, , "cboAnstellungsart", , _
                                frm.Controls("cboAnstellungsart").Left + frm.Controls("cboAnstellungsart").width + 200, _
                                frm.Controls("cboAnstellungsart").Top)
        ctl.Name = "lblAnstellungsart"
        ctl.caption = "Anstellungsart"
        msg = msg & "V lblAnstellungsart erstellt" & vbCrLf
    End If
    
    ' Unterformulare dimensionieren
    subformHeight = (frm.Section(acDetail).height - 1000) / 3
    subformTop = 500
    
    ' subUrlaubstage
    Err.clear
    Set ctl = Nothing
    Set ctl = frm.Controls("subUrlaubstage")
    If Err.Number = 0 And Not ctl Is Nothing Then
        ctl.SourceObject = "Form.sub_MA_Monat_Urlaub"
        ctl.Left = leftMargin
        ctl.Top = subformTop
        ctl.width = subformWidth
        ctl.height = subformHeight
        msg = msg & "V subUrlaubstage dimensioniert" & vbCrLf
    End If
    
    subformTop = subformTop + subformHeight + 300
    
    ' subKrankheitstage
    Err.clear
    Set ctl = Nothing
    Set ctl = frm.Controls("subKrankheitstage")
    If Err.Number = 0 And Not ctl Is Nothing Then
        ctl.SourceObject = "Form.sub_MA_Monat_Krank"
        ctl.Left = leftMargin
        ctl.Top = subformTop
        ctl.width = subformWidth
        ctl.height = subformHeight
        msg = msg & "V subKrankheitstage dimensioniert" & vbCrLf
    End If
    
    subformTop = subformTop + subformHeight + 300
    
    ' subPrivatverplant
    Err.clear
    Set ctl = Nothing
    Set ctl = frm.Controls("subPrivatverplant")
    If Err.Number = 0 And Not ctl Is Nothing Then
        ctl.SourceObject = "Form.sub_MA_Monat_Privat"
        ctl.Left = leftMargin
        ctl.Top = subformTop
        ctl.width = subformWidth
        ctl.height = subformHeight
        msg = msg & "V subPrivatverplant dimensioniert" & vbCrLf
    End If
    
    ' Form Load Event
    frm.OnLoad = "[Event Procedure]"
    
    ' Speichern
    DoCmd.Close acForm, "frm_MA_Monatsuebersicht", acSaveYes
    
    msg = msg & vbCrLf & "=== FIX ABGESCHLOSSEN ==="
    
    MsgBox msg, vbInformation, "Fix Complete"
    Debug.Print msg
End Sub