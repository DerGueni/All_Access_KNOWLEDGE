VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_Einsatzplan_Hirsch"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub MA_Ende_DblClick(Cancel As Integer)
Me!MA_Ende.SetFocus
feingabe
End Sub

Private Sub MA_Start_DblClick(Cancel As Integer)
Me!MA_Start.SetFocus
feingabe
End Sub

Function feingabe()
Dim mycontrol As control
 Dim myTarget As control
 Dim mySubTarget As control
 Dim ctlName
 Dim stprae As String
 Dim iVA_ID As Long
 Dim iMA_ID As Long
 Dim iZuo_ID As Long
 Dim iVADatum_ID As Long
 Dim dtVADatum As Date
 Dim stObjOrt As String
 Dim strSQL As String
 
DoCmd.OpenForm "frmTop_DP_Auftrageingabe"
'Forms!frmTop_DP_Auftrageingabe.lbl_ObjOrt.Caption = stObjOrt & " / " & Nz(Me(stprae & "von").Value, 0) & " - " & Nz(Me(stprae & "bis").Value, 0) & " Uhr"
Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.recordSource = "SELECT * FROM tbl_MA_VA_Zuordnung WHERE ID = " & iZuo_ID & ";"
Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.Requery
End Function
