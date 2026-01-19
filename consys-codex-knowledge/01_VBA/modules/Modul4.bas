Attribute VB_Name = "Modul4"
Public Sub CreateDokumenteUnterformular()
    On Error GoTo ErrorHandler
    
    Dim frm As Form
    Dim ctl As control
    
    ' Lösche existierendes Formular
    On Error Resume Next
    DoCmd.DeleteObject acForm, "sub_MA_Dokumente"
    On Error GoTo ErrorHandler
    
    ' Erstelle neues Formular basierend auf Query
    Set frm = CreateForm()
    frm.recordSource = "qry_MA_Dokumente"
    frm.DefaultView = 2 ' Datenblatt
    frm.AllowAdditions = False
    frm.AllowDeletions = True
    frm.AllowEdits = False
    frm.NavigationButtons = True
    frm.RecordSelectors = True
    frm.DividingLines = True
    frm.AutoCenter = True
    frm.ScrollBars = 2 ' Vertikal
    frm.BorderStyle = 0 ' Kein Rahmen
    
    ' Speichere Formular
    DoCmd.Close acForm, frm.Name, acSaveYes
    DoCmd.Rename "sub_MA_Dokumente", acForm, frm.Name
    
    MsgBox "Unterformular sub_MA_Dokumente erstellt!", vbInformation
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub
