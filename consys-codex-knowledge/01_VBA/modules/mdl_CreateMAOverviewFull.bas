Attribute VB_Name = "mdl_CreateMAOverviewFull"
'============================================================================
' MA Monatsübersicht - KORRIGIERT (OHNE VALUE SETZEN IM DESIGN MODE)
'============================================================================

Option Compare Database
Option Explicit

Public Sub CreateMAMonthsOverviewFull()

MsgBox "Starte Formular-Erstellung...", vbInformation

' Create 4 Subforms
CreateSubform1
CreateSubform2
CreateSubform3
CreateSubform4

MsgBox "✓ 4 Unterformulare erstellt", vbInformation

' Create Main Form
CreateMainForm

MsgBox "✓ Hauptformular erstellt!" & vbCrLf & _
       "Öffne: frm_MA_Monatsübersicht", vbInformation

End Sub

'============================================================================
' SUBFORM 1: STUNDEN
'============================================================================
Private Sub CreateSubform1()

On Error Resume Next
DoCmd.DeleteObject acForm, "sub_MA_Monat_Stunden"
On Error GoTo 0

Dim frm As Form
Dim oldName As String

Set frm = CreateForm()
oldName = frm.Name

frm.recordSource = "qry_MA_Monat_Stunden_Fest"
frm.DefaultView = 2
frm.AllowEdits = False

DoCmd.Close acForm, oldName, acSaveYes

On Error Resume Next
DoCmd.Rename "sub_MA_Monat_Stunden", acForm, oldName
On Error GoTo 0

End Sub

'============================================================================
' SUBFORM 2: KRANK
'============================================================================
Private Sub CreateSubform2()

On Error Resume Next
DoCmd.DeleteObject acForm, "sub_MA_Monat_Krank"
On Error GoTo 0

Dim frm As Form
Dim oldName As String

Set frm = CreateForm()
oldName = frm.Name

frm.recordSource = "qry_MA_Monat_Krank_Fest"
frm.DefaultView = 2
frm.AllowEdits = False

DoCmd.Close acForm, oldName, acSaveYes

On Error Resume Next
DoCmd.Rename "sub_MA_Monat_Krank", acForm, oldName
On Error GoTo 0

End Sub

'============================================================================
' SUBFORM 3: URLAUB
'============================================================================
Private Sub CreateSubform3()

On Error Resume Next
DoCmd.DeleteObject acForm, "sub_MA_Monat_Urlaub"
On Error GoTo 0

Dim frm As Form
Dim oldName As String

Set frm = CreateForm()
oldName = frm.Name

frm.recordSource = "qry_MA_Monat_Urlaub_Fest"
frm.DefaultView = 2
frm.AllowEdits = False

DoCmd.Close acForm, oldName, acSaveYes

On Error Resume Next
DoCmd.Rename "sub_MA_Monat_Urlaub", acForm, oldName
On Error GoTo 0

End Sub

'============================================================================
' SUBFORM 4: PRIVAT
'============================================================================
Private Sub CreateSubform4()

On Error Resume Next
DoCmd.DeleteObject acForm, "sub_MA_Monat_Privat"
On Error GoTo 0

Dim frm As Form
Dim oldName As String

Set frm = CreateForm()
oldName = frm.Name

frm.recordSource = "qry_MA_Monat_Privat_Fest"
frm.DefaultView = 2
frm.AllowEdits = False

DoCmd.Close acForm, oldName, acSaveYes

On Error Resume Next
DoCmd.Rename "sub_MA_Monat_Privat", acForm, oldName
On Error GoTo 0

End Sub

'============================================================================
' HAUPTFORMULAR
'============================================================================
Private Sub CreateMainForm()

On Error Resume Next
DoCmd.DeleteObject acForm, "frm_MA_Monatsübersicht"
On Error GoTo 0

Dim frm As Form
Dim oldName As String

Set frm = CreateForm()
oldName = frm.Name

DoCmd.Close acForm, oldName, acSaveYes

' Jetzt im Design-Modus öffnen
DoCmd.OpenForm oldName, acDesign
Set frm = Screen.ActiveForm

' Properties setzen
frm.NavigationButtons = False
frm.RecordSelectors = False
frm.AllowEdits = False
frm.AllowDeletions = False
frm.AllowAdditions = False

' MENÜ-Label
Dim lbl As control
Set lbl = CreateControl(frm.Name, acLabel, , "MENÜ")
lbl.Left = 15
lbl.Top = 0
lbl.width = 2600
lbl.height = 9000
lbl.backColor = 10921638
lbl.FontSize = 14
lbl.FontBold = True
lbl.ForeColor = 16777215

' Jahr-Label
Set lbl = CreateControl(frm.Name, acLabel, , "Jahr:")
lbl.Left = 2800
lbl.Top = 50
lbl.width = 600

' Jahr-Combo (OHNE VALUE)
Dim cbo As control
Set cbo = CreateControl(frm.Name, acComboBox)
cbo.Name = "cboJahr"
cbo.Left = 3500
cbo.Top = 50
cbo.width = 1200
cbo.RowSourceType = 1
cbo.RowSource = "2020;2021;2022;2023;2024;2025;2026;2027;2028;2029;2030;"

' Subformen im 2x2 Raster
Dim subNames() As String
subNames = Split("sub_MA_Monat_Stunden,sub_MA_Monat_Krank,sub_MA_Monat_Urlaub,sub_MA_Monat_Privat", ",")

Dim posLeft As Long, posTop As Long
Dim i As Integer

For i = LBound(subNames) To UBound(subNames)
    
    posLeft = 2700 + (i Mod 2) * 13500
    posTop = 500 + (i \ 2) * 6000
    
    ' Titel-Label
    Set lbl = CreateControl(frm.Name, acLabel, , subNames(i))
    lbl.Left = posLeft
    lbl.Top = posTop
    lbl.width = 13000
    lbl.height = 250
    lbl.FontBold = True
    lbl.backColor = 15921906
    
    ' Subform
    On Error Resume Next
    Dim subCtrl As control
    Set subCtrl = CreateControl(frm.Name, acSubform, , subNames(i), , posLeft, posTop + 300, 13000, 5500)
    If Not subCtrl Is Nothing Then
        subCtrl.SourceObject = subNames(i)
        subCtrl.BorderStyle = 1
    End If
    On Error GoTo 0
    
Next i

' Speichern
DoCmd.Close acForm, oldName, acSaveYes

' Umbenennen
On Error Resume Next
DoCmd.Rename "frm_MA_Monatsübersicht", acForm, oldName
On Error GoTo 0

End Sub


