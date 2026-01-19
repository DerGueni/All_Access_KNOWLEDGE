VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_DP_Dienstplan_Objekt1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnOutpExcelSend_Click()
DoCmd.Hourglass True
FCreate_Dienstplan_Excel_Send (1)
DoCmd.Hourglass False
End Sub

Private Sub Form_Load()
Me!lbl_Version.Visible = True
Me!lbl_Version.caption = Get_Priv_Property("prp_V_FE") & " | " & Get_Priv_Property("prp_V_BE")
End Sub

Public Function btnSta()
btnStartdatum_Click
End Function

Private Sub btn_Heute_Click()
Me!dtStartdatum = Date
btnStartdatum_Click
End Sub

Private Sub btnOutpExcel_Click()
FCreate_Dienstplan_Excel (1)
End Sub

Private Sub btnreq_Click()
btnStartdatum_Click
End Sub

Private Sub btnrueck_Click()
Dim dt As Date
dt = Me!dtStartdatum
Me!dtStartdatum = dt - 6
btnStartdatum_Click
End Sub

Private Sub btnVor_Click()
Dim dt As Date
dt = Me!dtStartdatum
Me!dtStartdatum = dt + 6
btnStartdatum_Click
End Sub

Private Sub btnStartdatum_Click()

On Error Resume Next
Dim iPosausblend As Long

Me!dtStartdatum = Me!dtStartdatum

Me!dtStartdatum.SetFocus

If Me!IstAuftrAusblend = True And Me!PosAusblendAb > 0 Then
    iPosausblend = Me!PosAusblendAb
Else
    iPosausblend = 0
End If

Call fCreate_DP_tmptable(Me!dtStartdatum, Me!NurIstNichtZugeordnet, iPosausblend)
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
Me!dtStartdatum.SetFocus
fset_Tage
DoEvents
Me!sub_DP_Grund.Form.Requery
DoEvents
Me!dtStartdatum.SetFocus
'Me!frm_DP_Dienstplan_Objekt.SetFocus
DoEvents

Call Set_Priv_Property("prp_Dienstpl_StartDatum", Me!dtStartdatum)

Me!sub_DP_Grund.SetFocus
Me!sub_DP_Grund.Form!Tag1_Name.SetFocus
DoCmd.RunCommand acCmdRecordsGoToLast
DoCmd.RunCommand acCmdRecordsGoToFirst

If GL_lngPos > 0 Then
    Me!sub_DP_Grund.Form.Recordset.AbsolutePosition = GL_lngPos
End If
If Len(Trim(Nz(GL_DP_Objekt_Fld))) > 0 Then
    Me!sub_DP_Grund.SetFocus
    Me!sub_DP_Grund.Form(GL_DP_Objekt_Fld).SetFocus
End If
End Sub

Private Sub dtStartdatum_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXfrm_DP_Dienstplan_ObjektXXX"
End Sub

Private Sub dtStartdatum_Exit(Cancel As Integer)
btnStartdatum_Click
End Sub


Function fset_Tage()
Dim i As Long
Dim st As String
For i = 0 To 6
    st = "lbl_Tag_" & (i + 1)
    Me(st).Value = Me!dtStartdatum + i
Next i
End Function


Private Sub Form_Close()
    DoCmd.SelectObject acTable, , True
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
GL_DP_Objekt_Fld = ""
End Sub

Private Sub Form_Open(Cancel As Integer)
Dim dtdat As Date

'Me!frm_Menuefuehrung.Form!Befehl38.Visible = False

dtdat = Get_Priv_Property("prp_Dienstpl_StartDatum")
Me!dtStartdatum = dtdat
btnStartdatum_Click
'btn_Heute_Click

'Top Ribbon ausblenden + links Objekte ausblenden
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
'    DoCmd.ShowToolbar "Ribbon", acToolbarNo

End Sub

Private Sub lbl_Tag_1_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_1
btnStartdatum_Click
End Sub

Private Sub lbl_Tag_2_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_2
btnStartdatum_Click
End Sub

Private Sub lbl_Tag_3_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_3
btnStartdatum_Click
End Sub

Private Sub lbl_Tag_4_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_4
btnStartdatum_Click
End Sub

Private Sub lbl_Tag_5_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_5
btnStartdatum_Click
End Sub

Private Sub lbl_Tag_6_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_6
btnStartdatum_Click
End Sub

Private Sub lbl_Tag_7_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_7
btnStartdatum_Click
End Sub

Private Sub btnDaBaAus_Click()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End Sub

Private Sub btnDaBaEin_Click()
    DoCmd.SelectObject acTable, , True
End Sub

Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub

Private Sub btnRibbonEin_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub
