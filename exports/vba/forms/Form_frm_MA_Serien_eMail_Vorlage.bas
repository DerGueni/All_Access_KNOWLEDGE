VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_MA_Serien_eMail_Vorlage"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub Form_Current()
IstHTML_AfterUpdate
End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub IstHTML_AfterUpdate()
If Me!IstHTML = False Then
    Me!IstHTML.caption = "Unformatierter Text (ASCII)"
        Me!Textinhalt.TextFormat = 0
Else
    Me!Textinhalt.TextFormat = 1
    Me!IstHTML.caption = "Formatierter Text (HTML)"
End If
End Sub
