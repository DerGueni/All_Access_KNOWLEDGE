Option Compare Database
Option Explicit

' ============================================================================
' ANLEITUNG:
' 1. Oeffnen Sie Access: Consys_FE_N_Test_Claude.accdb
' 2. Druecken Sie ALT+F11 (VBA-Editor)
' 3. Menue: Datei > Datei importieren
' 4. Waehlen Sie diese .bas-Datei
' 5. Druecken Sie F5 und fuehren Sie CreateEventAuswahlFormNow aus
' ============================================================================

Public Sub CreateEventAuswahlFormNow()
    On Error GoTo ErrorHandler
 Dim frmName As String
 
    Dim frm As Form
    Dim lst As control
    Dim btn1 As control, btn2 As control, btn3 As control, btn4 As control
    Dim lbl As control
    
    ' Loesche Formular falls es existiert
    On Error Resume Next
    DoCmd.DeleteObject acForm, "frm_EventAuswahl"
    On Error GoTo ErrorHandler
    
    ' Erstelle neues Formular
    Set frm = CreateForm
    
    ' Formular-Eigenschaften
    With frm
        .caption = "Event-Auswahl"
        .RecordSelectors = False
        .NavigationButtons = False
        .ScrollBars = 0
        .AutoCenter = True
        .BorderStyle = 3
        .width = 12000
        .Section(acDetail).height = 6500
    End With
    
    ' Label
    
' NACHHER (RICHTIG - Properties einzeln setzen):
Set lbl = CreateControl(frmName, acLabel, acDetail)
lbl.Left = 200
lbl.Top = 200
lbl.width = 11500
    With lbl
        .caption = "Bitte waehlen Sie die Events aus, die importiert werden sollen:"
        .FontSize = 10
        .FontBold = True
    End With
    
    ' ListBox
    Set lst = CreateControl(frm.Name, acListBox, acDetail, , , 200, 700, 11500, 4500)
    With lst
        .Name = "lstEvents"
        .ColumnCount = 5
        .ColumnWidths = "400;800;5500;2000;0"
        .MultiSelect = 1
        .FontSize = 9
    End With
    
    ' Button: Alle auswaehlen
    Set btn1 = CreateControl(frm.Name, acCommandButton, acDetail, , , 200, 5400, 2500, 600)
    With btn1
        .Name = "btnAlleAuswaehlen"
        .caption = "Alle auswaehlen"
    End With
    
    ' Button: Alle abwaehlen
    Set btn2 = CreateControl(frm.Name, acCommandButton, acDetail, , , 2900, 5400, 2500, 600)
    With btn2
        .Name = "btnAlleAbwaehlen"
        .caption = "Alle abwaehlen"
    End With
    
    ' Button: OK
    Set btn3 = CreateControl(frm.Name, acCommandButton, acDetail, , , 7200, 5400, 2000, 600)
    With btn3
        .Name = "btnOK"
        .caption = "OK"
        .Default = True
    End With
    
    ' Button: Abbrechen
    Set btn4 = CreateControl(frm.Name, acCommandButton, acDetail, , , 9400, 5400, 2000, 600)
    With btn4
        .Name = "btnAbbrechen"
        .caption = "Abbrechen"
        .Cancel = True
    End With
    
    ' Formular speichern
    DoCmd.Close acForm, frm.Name, acSaveYes
    DoCmd.Rename "frm_EventAuswahl", acForm, frm.Name
    
    MsgBox "Formular 'frm_EventAuswahl' erfolgreich erstellt!" & vbCrLf & vbCrLf & _
           "Jetzt muss noch der Formular-Code hinzugefuegt werden.", vbInformation
    
    ' Oeffne Formular im Entwurfsmodus
    DoCmd.OpenForm "frm_EventAuswahl", acDesign
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler beim Erstellen des Formulars:" & vbCrLf & vbCrLf & _
           "Fehler-Nr: " & err.Number & vbCrLf & _
           "Beschreibung: " & err.description, vbCritical
End Sub