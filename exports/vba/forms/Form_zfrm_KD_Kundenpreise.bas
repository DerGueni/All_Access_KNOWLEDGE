VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_KD_Kundenpreise"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub btn_kalk_Click()

    DoCmd.OpenQuery "qry_KD_Kalkulation_Gueni"
    
End Sub

'Private Sub btn_kalk_Click()
'DoCmd.Open
'End Sub

Private Sub btnAuswertung_Click()

    DoCmd.OpenForm "frm_kundenpreise_gueni"
    
End Sub


Private Sub btnClearFilter_Click()
    
    Me.cboKunde = ""
    Me.filter = ""
    Me.FilterOn = True
       
End Sub


Private Sub cboKunde_Click()

    Me.filter = "kun_ID = " & Me.cboKunde.Column(0)
    Me.FilterOn = True

End Sub
