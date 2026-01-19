Option Compare Database
Option Explicit

'This example enumerates the properties of each form
Function DBPropForm(frmName As String)
Dim frm As Form
Dim prpLoop As Property

DoCmd.OpenForm frmName, acDesign, , , , acHidden
Set frm = Forms(frmName)

For Each prpLoop In frm.Properties
    On Error Resume Next
    If Len(Trim(Nz(prpLoop))) > 0 Then
        Debug.Print "        " & prpLoop.Name & " = " & prpLoop
    End If
    On Error GoTo 0
Next prpLoop
DoCmd.Close acForm, frmName, acSaveNo
End Function

'This example enumerates the properties of each form
Function DBAllowDesignChangesForm_True(frmName As String)
Dim frm As Form
Dim prpLoop As Property

DoCmd.OpenForm frmName, acDesign, , , , acHidden
Set frm = Forms(frmName)
frm.Properties("AllowDesignChanges") = True
DoCmd.Close acForm, frmName, acSaveNo
End Function

Function allow_all()
DBAllowDesignChangesForm_True ("Kundendaten")
DBAllowDesignChangesForm_True ("Lizenzen")
DBAllowDesignChangesForm_True ("PC-Hardware")
End Function