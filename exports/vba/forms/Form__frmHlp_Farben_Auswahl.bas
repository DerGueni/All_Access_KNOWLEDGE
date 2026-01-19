VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_Farben_Auswahl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnColorBack_Click()
Me!FarbNrHint = ShowColorDialog(Me!FarbNrHint)
FarbeAnpassen
End Sub

Private Sub btnColorText_Click()
Me!FarbNrText = ShowColorDialog(Me!FarbNrText)
FarbeAnpassen
End Sub

Private Sub btnHilfe_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", , , "Formularname='" & [Screen].[ActiveForm].[Name] & "'", , acDialog
End Sub

Private Sub btnEnde_Click()
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"
End Sub

Private Sub FarbNrHint_AfterUpdate()
FarbeAnpassen
End Sub

Function FarbeAnpassen()
On Error Resume Next
Me!lbl_Sample.backColor = CLng(Me!FarbNrHint)
Me!lbl_Sample.ForeColor = CLng(Me!FarbNrText)
Me!Hallo.backColor = CLng(Me!FarbNrHint)
Me!Hallo.ForeColor = CLng(Me!FarbNrText)
End Function

Private Sub Form_Current()
FarbeAnpassen
End Sub

Function XRGB(x As Long) As Variant
XRGB = "#" & Right("000000" & Hex(x), 6)
End Function
