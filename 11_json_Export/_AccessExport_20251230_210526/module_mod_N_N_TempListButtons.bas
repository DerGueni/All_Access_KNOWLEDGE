Option Compare Database
Option Explicit


Public Function ListFormButtons() As String
    On Error Resume Next
    Dim frm As Form
    Dim ctl As control
    Dim result As String
    
    result = ""
    DoCmd.OpenForm "frm_Menuefuehrung", acDesign
    Set frm = forms("frm_Menuefuehrung")
    
    For Each ctl In frm.Controls
        If ctl.ControlType = 104 Then
            result = result & ctl.Name & " | " & ctl.caption & vbCrLf
        End If
    Next ctl
    
    DoCmd.Close acForm, "frm_Menuefuehrung", acSaveNo
    ListFormButtons = result
End Function