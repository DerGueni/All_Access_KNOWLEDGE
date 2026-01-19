Option Explicit

Dim vaId, vadatumId, mode, recipient

If WScript.Arguments.Count < 4 Then
    WScript.Echo "Usage: send_request_email.vbs <va_id> <vadatum_id> <mode> <recipient>"
    WScript.Quit 1
End If

vaId = WScript.Arguments(0)
vadatumId = WScript.Arguments(1)
mode = LCase(WScript.Arguments(2))
recipient = WScript.Arguments(3)

Dim iTyp
If mode = "all" Then
    iTyp = 2
Else
    iTyp = 1
End If

Dim acc
Set acc = CreateObject("Access.Application")
acc.Visible = False
acc.OpenCurrentDatabase "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb", False

On Error Resume Next
acc.DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag", 0
acc.Forms("frm_MA_Serien_eMail_Auftrag").Visible = False

On Error GoTo 0

On Error Resume Next
acc.Run "Form_frm_MA_Serien_eMail_Auftrag.Autosend", CInt(iTyp), CLng(vaId), CLng(vadatumId), CStr(recipient)

If Err.Number <> 0 Then
    WScript.Echo "Autosend error: " & Err.Description
    acc.CloseCurrentDatabase
    acc.Quit
    WScript.Quit 2
End If
On Error GoTo 0

On Error Resume Next
acc.Forms("frm_MA_Serien_eMail_Auftrag").cbInfoAtConsec = False
acc.Forms("frm_MA_Serien_eMail_Auftrag").txEmpfaenger = recipient

' Try to send
acc.Run "Form_frm_MA_Serien_eMail_Auftrag.btnSendEmail_Click"

If Err.Number <> 0 Then
    WScript.Echo "Send error: " & Err.Description
    acc.CloseCurrentDatabase
    acc.Quit
    WScript.Quit 3
End If
On Error GoTo 0

acc.CloseCurrentDatabase
acc.Quit
WScript.Echo "OK"
