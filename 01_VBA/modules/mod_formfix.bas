Attribute VB_Name = "mod_formfix"
'============================================================================
' KORREKTUR: Formulare reparieren - SIMPEL
'============================================================================

Option Compare Database
Option Explicit

Public Sub FixFormsAndData()

    MsgBox "Starte Reparatur der Formulare...", vbInformation

    ' Step 1: Fix Subforms mit Daten
    FixSubformStunden
    FixSubformKrank
    FixSubformUrlaub
    FixSubformPrivat

    MsgBox "? Unterformulare repariert", vbInformation

    ' Step 2: Hauptformular NEU erstellen
    CreateNewMainForm

    MsgBox "? FERTIG!" & vbCrLf & _
           "Alle 4 Subformen sind jetzt sichtbar!" & vbCrLf & _
           "Öffne: frm_MA_Monatsübersicht_NEU", vbInformation

End Sub

'============================================================================
' FIX SUBFORM 1: STUNDEN
'============================================================================
Private Sub FixSubformStunden()

    On Error Resume Next
    DoCmd.OpenForm "sub_MA_Monat_Stunden", acDesign
    On Error GoTo 0

    Dim frm As Form
    On Error Resume Next
    Set frm = Screen.ActiveForm
    On Error GoTo 0

    If frm Is Nothing Then Exit Sub

    frm.recordSource = "qry_MA_Monat_Stunden_Fest"
    frm.DefaultView = acFormDS
    frm.AllowEdits = False
    frm.NavigationButtons = False

    DoCmd.Close acForm, "sub_MA_Monat_Stunden", acSaveYes

End Sub

'============================================================================
' FIX SUBFORM 2: KRANK
'============================================================================
Private Sub FixSubformKrank()

    On Error Resume Next
    DoCmd.OpenForm "sub_MA_Monat_Krank", acDesign
    On Error GoTo 0

    Dim frm As Form
    On Error Resume Next
    Set frm = Screen.ActiveForm
    On Error GoTo 0

    If frm Is Nothing Then Exit Sub

    frm.recordSource = "qry_MA_Monat_Krank_Fest"
    frm.DefaultView = acFormDS
    frm.AllowEdits = False
    frm.NavigationButtons = False

    DoCmd.Close acForm, "sub_MA_Monat_Krank", acSaveYes

End Sub

'============================================================================
' FIX SUBFORM 3: URLAUB
'============================================================================
Private Sub FixSubformUrlaub()

    On Error Resume Next
    DoCmd.OpenForm "sub_MA_Monat_Urlaub", acDesign
    On Error GoTo 0

    Dim frm As Form
    On Error Resume Next
    Set frm = Screen.ActiveForm
    On Error GoTo 0

    If frm Is Nothing Then Exit Sub

    frm.recordSource = "qry_MA_Monat_Urlaub_Fest"
    frm.DefaultView = acFormDS
    frm.AllowEdits = False
    frm.NavigationButtons = False

    DoCmd.Close acForm, "sub_MA_Monat_Urlaub", acSaveYes

End Sub

'============================================================================
' FIX SUBFORM 4: PRIVAT
'============================================================================
Private Sub FixSubformPrivat()

    On Error Resume Next
    DoCmd.OpenForm "sub_MA_Monat_Privat", acDesign
    On Error GoTo 0

    Dim frm As Form
    On Error Resume Next
    Set frm = Screen.ActiveForm
    On Error GoTo 0

    If frm Is Nothing Then Exit Sub

    frm.recordSource = "qry_MA_Monat_Privat_Fest"
    frm.DefaultView = acFormDS
    frm.AllowEdits = False
    frm.NavigationButtons = False

    DoCmd.Close acForm, "sub_MA_Monat_Privat", acSaveYes

End Sub

'============================================================================
' NEUES HAUPTFORMULAR: KOMPLETT NEU MIT RICHTIGEN GRÖSSEN
'============================================================================
Private Sub CreateNewMainForm()

    ' Altes löschen
    On Error Resume Next
    DoCmd.DeleteObject acForm, "frm_MA_Monatsübersicht_NEU"
    On Error GoTo 0

    Dim frm As Form
    Set frm = CreateForm()

    Dim oldName As String
    oldName = frm.Name

    ' Speichern
    DoCmd.Close acForm, oldName, acSaveYes

    ' Im Design-Modus öffnen
    DoCmd.OpenForm oldName, acDesign
    Set frm = Screen.ActiveForm

    ' Größe (Breite Formular + Höhe Detailbereich)
    With frm
        .width = 21000
        .Section(acDetail).height = 8000      ' <- statt frm.Height
        .NavigationButtons = False
        .RecordSelectors = False
        .AllowEdits = False
        .AllowDeletions = False
        .AllowAdditions = False
    End With

    ' ===== MENÜ (LINKS) =====
    Dim lbl As control

    Set lbl = CreateControl(frm.Name, acLabel, acDetail)
    With lbl
        .caption = "MENÜ"
        .Left = 15
        .Top = 0
        .width = 2300
        .height = 7800
        .backColor = 10921638
        .FontSize = 12
        .FontBold = True
        .ForeColor = 16777215
    End With

    ' ===== JAHR-COMBO =====
    Set lbl = CreateControl(frm.Name, acLabel, acDetail)
    With lbl
        .caption = "Jahr:"
        .Left = 2600
        .Top = 50
        .width = 400
        .FontBold = True
    End With

    Dim cbo As control
    Set cbo = CreateControl(frm.Name, acComboBox, acDetail)
    With cbo
        .Name = "cboJahr"
        .Left = 3050
        .Top = 50
        .width = 900
        .height = 240
        .RowSourceType = "Value List"
        .RowSource = "2020;2021;2022;2023;2024;2025;2026;2027;2028;2029;2030"
    End With

    ' ===== 2x2 RASTER =====
    Dim subNames() As String
    subNames = Split("sub_MA_Monat_Stunden,sub_MA_Monat_Krank,sub_MA_Monat_Urlaub,sub_MA_Monat_Privat", ",")

    Dim subLabels() As String
    subLabels = Split("Gearbeitete Stunden,Krankheitstage,Urlaubstage,Privat verplant", ",")

    Dim posLeft As Long, posTop As Long
    Dim i As Integer
    Dim subCtrl As control

    For i = LBound(subNames) To UBound(subNames)

        posLeft = 2600 + (i Mod 2) * 9100
        posTop = 400 + (i \ 2) * 3600

        ' Label
        Set lbl = CreateControl(frm.Name, acLabel, acDetail)
        With lbl
            .caption = subLabels(i)
            .Left = posLeft
            .Top = posTop
            .width = 8900
            .height = 200
            .FontBold = True
            .backColor = 15921906
            .FontSize = 9
        End With

        ' Subform
        Set subCtrl = CreateControl(frm.Name, acSubform, acDetail)
        With subCtrl
            .SourceObject = "Form." & subNames(i)
            .Left = posLeft
            .Top = posTop + 220
            .width = 8900
            .height = 3200
            .BorderStyle = 1
            .BorderColor = 0
        End With

    Next i

    ' Speichern
    DoCmd.Close acForm, oldName, acSaveYes

    ' Umbenennen
    On Error Resume Next
    DoCmd.Rename "frm_MA_Monatsübersicht_NEU", acForm, oldName
    On Error GoTo 0

    ' Öffnen zur Anzeige
    DoCmd.OpenForm "frm_MA_Monatsübersicht_NEU"

End Sub


