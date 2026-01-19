Attribute VB_Name = "mdl_N_CreateHTMLButtons"
' =====================================================
' mdl_N_CreateHTMLButtons
' Erstellt HTML-Ansicht Buttons in Access-Formularen
' =====================================================
Option Compare Database
Option Explicit

Public Sub CreateAllHTMLButtons()
    ' Erstellt HTML-Buttons in allen Hauptformularen
    
    Call CreateHTMLButton_Mitarbeiterstamm
    Call CreateHTMLButton_Kundenstamm
    Call CreateHTMLButton_Auftragstamm
    
    MsgBox "HTML-Buttons wurden erstellt!", vbInformation
End Sub

Public Sub CreateHTMLButton_Mitarbeiterstamm()
    On Error Resume Next
    
    Dim frm As Form
    Dim btn As Control
    
    ' Formular im Entwurfsmodus öffnen
    DoCmd.OpenForm "frm_MA_Mitarbeiterstamm", acDesign
    Set frm = Forms("frm_MA_Mitarbeiterstamm")
    
    ' Prüfe ob Button existiert
    Dim ctl As Control
    For Each ctl In frm.Controls
        If ctl.Name = "btnHTMLAnsicht" Then
            Debug.Print "Button existiert bereits in frm_MA_Mitarbeiterstamm"
            DoCmd.Close acForm, "frm_MA_Mitarbeiterstamm", acSaveNo
            Exit Sub
        End If
    Next
    
    ' Button erstellen
    Set btn = CreateControl("frm_MA_Mitarbeiterstamm", acCommandButton, acDetail, "", "", 11000, 400, 2000, 400)
    btn.Name = "btnHTMLAnsicht"
    btn.Caption = "HTML Ansicht"
    btn.OnClick = "=OpenMitarbeiterstammHTML([ID])"
    btn.BackColor = RGB(0, 100, 180)
    btn.ForeColor = RGB(255, 255, 255)
    
    DoCmd.Close acForm, "frm_MA_Mitarbeiterstamm", acSaveYes
    Debug.Print "Button erstellt in frm_MA_Mitarbeiterstamm"
End Sub

Public Sub CreateHTMLButton_Kundenstamm()
    On Error Resume Next
    
    Dim frm As Form
    Dim btn As Control
    
    DoCmd.OpenForm "frm_KD_Kundenstamm", acDesign
    Set frm = Forms("frm_KD_Kundenstamm")
    
    Dim ctl As Control
    For Each ctl In frm.Controls
        If ctl.Name = "btnHTMLAnsicht" Then
            DoCmd.Close acForm, "frm_KD_Kundenstamm", acSaveNo
            Exit Sub
        End If
    Next
    
    Set btn = CreateControl("frm_KD_Kundenstamm", acCommandButton, acDetail, "", "", 11000, 400, 2000, 400)
    btn.Name = "btnHTMLAnsicht"
    btn.Caption = "HTML Ansicht"
    btn.OnClick = "=OpenKundenstammHTML([kun_Id])"
    btn.BackColor = RGB(0, 100, 180)
    btn.ForeColor = RGB(255, 255, 255)
    
    DoCmd.Close acForm, "frm_KD_Kundenstamm", acSaveYes
End Sub

Public Sub CreateHTMLButton_Auftragstamm()
    On Error Resume Next
    
    Dim frm As Form
    Dim btn As Control
    
    DoCmd.OpenForm "frm_VA_Auftragstamm", acDesign
    Set frm = Forms("frm_VA_Auftragstamm")
    
    Dim ctl As Control
    For Each ctl In frm.Controls
        If ctl.Name = "btnHTMLAnsicht" Then
            DoCmd.Close acForm, "frm_VA_Auftragstamm", acSaveNo
            Exit Sub
        End If
    Next
    
    Set btn = CreateControl("frm_VA_Auftragstamm", acCommandButton, acDetail, "", "", 8000, 400, 2000, 400)
    btn.Name = "btnHTMLAnsicht"
    btn.Caption = "HTML Ansicht"
    btn.OnClick = "=OpenAuftragsverwaltungHTML([ID])"
    btn.BackColor = RGB(0, 100, 180)
    btn.ForeColor = RGB(255, 255, 255)
    
    DoCmd.Close acForm, "frm_VA_Auftragstamm", acSaveYes
End Sub
