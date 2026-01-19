VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_MA_Offene_Anfragen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Click()

    'Auswahl an Hauptformular übergeben
    Me.Parent.Form.Controls("txSelHeightSub") = Me.SelHeight
    
End Sub

Private Sub Form_Current()

    'Auswahl an Hauptformular übergeben
    Me.Parent.Form.Controls("txSelHeightSub") = Me.SelHeight

End Sub



