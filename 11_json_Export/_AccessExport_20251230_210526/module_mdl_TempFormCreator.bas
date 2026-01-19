Option Compare Database
Option Explicit

Public Sub Create_sub_MA_Dokumente()
    On Error GoTo ErrHandler
    
    Dim frm As Form
    Dim frmName As String
    
    On Error Resume Next
    DoCmd.DeleteObject acForm, "sub_MA_Dokumente"
    On Error GoTo ErrHandler
    

Set frm = Application.CreateForm

    
    frm.recordSource = "tbl_MA_Dokumente"
    frm.caption = "Dokumente"
    frm.DefaultView = 2
    frm.ScrollBars = 3
    frm.NavigationButtons = True
    frm.RecordSelectors = True
    frm.AllowAdditions = True
    frm.AllowEdits = True
    frm.AllowDeletions = True
    
    frmName = frm.Name
    DoCmd.Close acForm, frmName, acSaveYes
    DoCmd.Rename "sub_MA_Dokumente", acForm, frmName
    
    Debug.Print "Formular sub_MA_Dokumente erstellt"
    Exit Sub
    
ErrHandler:
    Debug.Print "Fehler: " & Err.description
End Sub