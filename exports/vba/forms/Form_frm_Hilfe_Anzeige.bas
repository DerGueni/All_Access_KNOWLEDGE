VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Hilfe_Anzeige"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnEdit_Click()
DoCmd.OpenForm "_frmHlp_Hilfe_Erstellen", , , "Formularname = '" & Me!Formularname & "'", , acDialog
End Sub
Private Sub btnEnde_Click()
On Error GoTo Err_btnEnde_Click


    DoCmd.Close

Exit_btnEnde_Click:
    Exit Sub

Err_btnEnde_Click:
    MsgBox Err.description
    Resume Exit_btnEnde_Click
    
End Sub

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'", , acDialog
End Sub
