VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_tbl_MA_Zeitkonto_Aktmon2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit



'---------------------------------------------------------------------------------------
' Procedure : Form_BeforeUpdate
' Author    : Klaus
' Date      : 07.04.2015
' Purpose   :
'---------------------------------------------------------------------------------------
'
Private Sub Form_BeforeUpdate(Cancel As Integer)
   On Error GoTo Form_BeforeUpdate_Error

Me!Aend_am = Now()
Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo

   On Error GoTo 0
   Exit Sub

Form_BeforeUpdate_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Form_BeforeUpdate of VBA Dokument Form_sub_tbl_MA_Zeitkonto_Aktmon2"

End Sub
