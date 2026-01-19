VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_Neue_Vorlagen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btn_WordVorlagen_Neu_Einesen_Click()

Call WD_template_NonBookmark_Ausles_Test

End Sub


Private Sub btnInfoTextbau_Click()

DoCmd.Close acForm, Me.Name, acSaveNo
DoCmd.OpenForm "frmHlp_TextbausteinInfo"

End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!CONSYS_Grundpfad = Get_Priv_Property("prp_CONSYS_GrundPfad")
End Sub
