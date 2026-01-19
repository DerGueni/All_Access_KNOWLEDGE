Attribute VB_Name = "mdl_N_CreateHTMLButtons"
Option Compare Database
Option Explicit

Public Sub CreateAllHTMLButtons()
    Call CreateHTMLButton_Mitarbeiterstamm
    Call CreateHTMLButton_Kundenstamm
    Call CreateHTMLButton_Auftragstamm
    MsgBox "HTML-Buttons wurden erstellt!", vbInformation
End Sub

Public Sub CreateHTMLButton_Mitarbeiterstamm()
    On Error Resume Next
    Dim frm As Form
    Dim btn As Control
    DoCmd.OpenForm "frm_MA_Mitarbeiterstamm", acDesign
    Set frm = Forms("frm_MA_Mitarbeiterstamm")
    Dim ctl As Control
    For Each ctl In frm.Controls
        If ctl.Name = "btnHTMLAnsicht" Then
            DoCmd.Close acForm, "frm_MA_Mitarbeiterstamm", acSaveNo
            Exit Sub
        End If
    Next
    Set btn = CreateControl("frm_MA_Mitarbeiterstamm", acCommandButton, acDetail, "", "", 11000, 400, 2000, 400)
    btn.Name = "btnHTMLAnsicht"
    btn.Caption = "HTML Ansicht"
    btn.OnClick = "=OpenMitarbeiterstammHTML([ID])"
    DoCmd.Close acForm, "frm_MA_Mitarbeiterstamm", acSaveYes
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
    DoCmd.Close acForm, "frm_VA_Auftragstamm", acSaveYes
End Sub