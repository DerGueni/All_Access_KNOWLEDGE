VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmHlp_TextbausteinInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnNeuVorlage_Click()
DoCmd.OpenForm "frmTop_Neue_Vorlagen"
End Sub

Private Sub cboTextbau_Herkunft_AfterUpdate()

Dim strSQL As String

Dim strinstr As String

Select Case Me!cboTextbau_Herkunft
    Case 2 ' Auftrag
        strinstr = "1, 2, 4"
    Case 3 ' Mitarbeiter
        strinstr = "1, 3"
    Case 4 ' Kunden
        strinstr = "1, 4"
    Case 5  'Rechnung
        strinstr = "1, 4, 5"
End Select

strSQL = "SELECT * FROM qry_Textbaustein_Info WHERE ID IN(" & strinstr & ") Order By ID DESC, Feldname"

Me!sub_Textbaustein_Info.Form.recordSource = strSQL

End Sub

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
cboTextbau_Herkunft_AfterUpdate
End Sub
