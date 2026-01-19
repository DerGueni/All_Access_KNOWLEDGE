VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_MA_Dienstplan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit



Private Sub Report_Current()
    DoCmd.Maximize
End Sub

Private Sub Report_Open(Cancel As Integer)

 Dim sql      As String
 Dim von      As Date
 Dim bis      As Date
 Dim MA_ID    As Integer

    'Me.RecordSource = Forms("frm_ma_mitarbeiterstamm").lstPl_Zuo.RowSource
    Me.recordSource = Get_Priv_Property("prp_rpt_Dienstplan_MA_Recordsource")
    Me.txvon.caption = "von " & Get_Priv_Property("prp_rpt_Dienstplan_MA_von")
    Me.txbis.caption = "bis " & Get_Priv_Property("prp_rpt_Dienstplan_MA_bis")
    DoCmd.SetOrderBy "VADatum ASC, Beginn ASC" 'Notwendig, da Sortierung über RecordSource nicht funktioniert
    
    DoCmd.OpenForm "_frmHlp_rptClose", , , , , , Me.Name

End Sub


Private Sub Report_Close()
    DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo
End Sub

