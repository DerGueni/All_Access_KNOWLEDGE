VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_Ordnerkonzept"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Report_Close()
DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo
End Sub

Private Sub Report_Open(Cancel As Integer)
DoCmd.OpenForm "_frmHlp_rptClose", , , , , , Me.Name
'DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo
End Sub
