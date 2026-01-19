VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form___frmHlp_Uebersicht_Alt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnAuftrag_Click()
DoCmd.OpenForm "frm_VA_Auftragstamm"
End Sub

Private Sub btnCONSEC_Click()
DoCmd.OpenForm "frmStamm_EigeneFirma"
End Sub

Private Sub btnExcelMon_Click()
DoCmd.OpenForm "frmTop_Excel_Monatsuebersicht"
End Sub

Private Sub btnKundenstamm_Click()
DoCmd.OpenForm "frm_KD_Kundenstamm"
End Sub

Private Sub btnMA_Click()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
End Sub

Private Sub btnObjekt_Click()
DoCmd.OpenForm "frm_OB_Objekt"
End Sub

Private Sub btnRechnung_Click()

End Sub

Private Sub btnSchnellplanung_Click()
DoCmd.OpenForm "frm_MA_VA_Schnellauswahl"
End Sub

Private Sub btnWeitere_Click()
DoCmd.OpenForm "__frmHlpMenu_Weitere_Masken"
End Sub

Private Sub btnWoUebersicht_Click()
DoCmd.OpenForm "frm_UE_Uebersicht"
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
DoCmd.OpenForm "_frmHlp_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"
End Sub
