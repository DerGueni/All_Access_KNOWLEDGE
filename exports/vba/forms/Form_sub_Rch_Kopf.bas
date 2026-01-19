VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_Rch_Kopf"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_AfterUpdate()
Form_frm_KD_Kundenstamm.Kopf_Berech
End Sub

Private Sub PDF_Datei_DblClick(Cancel As Integer)
Application.FollowHyperlink Me!PDF_Datei
End Sub

Private Sub PDF_Pos_Datei_DblClick(Cancel As Integer)
Application.FollowHyperlink Me!PDF_Pos_Datei

End Sub
