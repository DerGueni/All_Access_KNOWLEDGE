VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_UE_Uebersicht_leer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnWeitere_Click()
DoCmd.OpenForm "__frmHlp_Weitere_Masken"
End Sub

Private Sub cmdOK_Click()
If vbYes = MsgBox("Access verlassen, sind Sie sicher ?", vbYesNo + vbQuestion, "Access beenden") Then
    DoCmd.Close acForm, Me.Name, acSaveNo
    DoCmd.Quit acQuitSaveNone
End If
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
End Sub

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"
End Sub
