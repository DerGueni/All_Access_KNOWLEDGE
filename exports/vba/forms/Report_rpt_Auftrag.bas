VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_Auftrag"
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
Me!lstZeiten.Requery
'DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo

End Sub

Private Sub Seitenkopfbereich_Format(Cancel As Integer, FormatCount As Integer)
Me!lstZeiten.Requery
End Sub

'Private Sub Seitenkopfbereich_Format(Cancel As Integer, FormatCount As Integer)
'
'Dim strSQL As String
'
'strSQL = ""
'strSQL = strSQL & "SELECT VAStart_ID, VADatum, MVA_Start, MVA_Ende, MA_Ist as Ist, MA_Soll as Soll, left(VA_Start,5) As Beginn, "
'strSQL = strSQL & " left(VA_Ende,5) as Ende FROM qry_Anz_MA_Start "
'strSQL = strSQL & " WHERE VADatum_ID = " & Get_Priv_Property("prp_Report1_Auftrag_ID")
'strSQL = strSQL & " ORDER BY VA_Start, VA_Ende"
'Me!lstZeiten.RowSource = strSQL
'Me!lstZeiten.Requery
'DoEvents
'
'End Sub

Private Sub Seitenkopfbereich_Paint()
Me!lstZeiten.Requery
End Sub
