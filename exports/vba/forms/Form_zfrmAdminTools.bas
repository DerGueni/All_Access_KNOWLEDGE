VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrmAdminTools"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database


Private Sub btnArchivieren_Click()

    If MsgBox("Daten der vergangenen Jahre archivieren?", vbOKCancel) = vbOK Then Call archivieren

End Sub

Private Sub btnFEverteilen_Click()

    Call FE_verteilen
    
End Sub


Private Sub btnTestumgebung_Click()

    If MsgBox("FE auf Testumgebung schalten?", vbOKCancel) = vbOK Then Call Testumgebung_umschalten

End Sub
