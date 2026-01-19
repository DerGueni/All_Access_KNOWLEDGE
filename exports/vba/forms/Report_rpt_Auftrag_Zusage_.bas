VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_Auftrag_Zusage_"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim iColor As Long

Private Sub Detailbereich_Print(Cancel As Integer, PrintCount As Integer)
If Me!IstFraglich = True Then
'    Me!Nachname.BackColor = &HFDEADA
    Me!Nachname.backColor = iColor ' Türkisblau
'    Me!Nachname.BackColor = 110043
Else
    Me!Nachname.backColor = &HFFFFFF
End If
End Sub

Private Sub Report_Close()
DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo
End Sub

Private Sub Report_Open(Cancel As Integer)
On Error Resume Next

iColor = Get_Priv_Property("prp_MA_Fraglich_Farbe")
'iColor = 110043 '' helleres Kakibraun  ' <--

Dim i As Long
i = Get_Priv_Property("prp_Report1_Auftrag_IstTage")
If i = 0 Then
    Me.recordSource = "qry_Report_Auftrag_Sort_Select"
ElseIf i = -1 Then
    Me.recordSource = "qry_Report_Auftrag_Sort_Select_All"
ElseIf i = 1 Then
    Me.recordSource = "qry_Report_Auftrag_Sort_Select_AbHeute"
End If
DoCmd.OpenForm "_frmHlp_rptClose", , , , , , Me.Name
'DoCmd.Close acForm, "_frmHlp_rptClose", acSaveNo

End Sub

Private Sub Report_Page()
    Me.Line (0, 0)-(Me.ScaleWidth - 60, Me.ScaleHeight - 20), , B
End Sub

