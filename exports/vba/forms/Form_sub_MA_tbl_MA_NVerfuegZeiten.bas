VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_MA_tbl_MA_NVerfuegZeiten"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub vonDat_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub bisDat_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub Form_AfterUpdate()
   On Error GoTo Form_AfterUpdate_Error

        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo

        DoEvents
        Call CurrentDb.Execute("qry_MA_NVerfueg_ZeitUpdate")
        Call CurrentDb.Execute("qry_MA_NVerfueg_ZeitUpdate_2")
        DoEvents

   On Error GoTo 0
   Exit Sub

Form_AfterUpdate_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Form_AfterUpdate of VBA Dokument Form_sub_MA_tbl_MA_NVerfuegZeiten"

End Sub
