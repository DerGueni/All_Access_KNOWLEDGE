VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_MA_FehlZeiten"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub bidDat_Exit(Cancel As Integer)
If Me!vonDat > Me!bisDat Then
    MsgBox "Datumseingabe verkehrt (von > bis)"
    Cancel = True
End If
End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)
   On Error GoTo Form_BeforeUpdate_Error

        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo

   On Error GoTo 0
   Exit Sub

Form_BeforeUpdate_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Form_BeforeUpdate of VBA Dokument Form_sub_MA_FehlZeiten"

End Sub
