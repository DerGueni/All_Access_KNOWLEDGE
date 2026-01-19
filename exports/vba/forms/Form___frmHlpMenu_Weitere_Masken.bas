VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form___frmHlpMenu_Weitere_Masken"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btn3MonKal_Click()
DoCmd.OpenForm "_frmHlp_Kalender_3Mon"
End Sub

Private Sub btnBlob_Click()
DoCmd.OpenForm "__Vorlagen_einlesen"
End Sub

Private Sub btnCL_Setup_Click()
DoCmd.OpenForm "_frmHlp_CodeLurker_Setup"
End Sub

Private Sub btnCL_Click()
DoCmd.OpenForm "_frmHlp_CodeLurker"
End Sub

Private Sub btnColor_Click()
DoCmd.OpenForm "_frmHlp_Farben_Auswahl"
End Sub

Private Sub btnCreaTSQL_Click()
Dim sPath As String
sPath = Left(CurrentDb.Name, Len(CurrentDb.Name) - Len(Dir(CurrentDb.Name))) & "TSQL_CreateTableDesc.sql"
TSQL_TableDescription sPath, True, True
MsgBox "TSQL_CreateTableDesc.sql erzeugt"
End Sub

Private Sub btnExcel_Click()
DoCmd.OpenForm "_frmHlp_Excel_Einbinden"
End Sub

Private Sub btnFerienMeta_Click()
DoCmd.OpenForm "_frmHlp_Ferien_Meta"
End Sub

Private Sub btnGewUmr_Click()
DoCmd.OpenForm "_frmHlp_MasseGewichteUmrechnen"
End Sub

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"
End Sub

Private Sub btnJahrKal_Click()
DoCmd.OpenForm "_frmHlp_Kalender_Jahr"
End Sub

Private Sub btnLKZ_definition_Click()
DoCmd.OpenForm "_frmHlp_LKZ"
End Sub

Private Sub btnMaintainance_CONSYS_Click()
DoCmd.OpenForm "_frmHlp_Maintainance_Menue"
End Sub

Private Sub btnNoDSN_Click()
DoCmd.OpenForm "_frmHlp_Connectionstring_erzeugen"
End Sub

Private Sub btnSysInfo_Click()
DoCmd.OpenForm "_frmHlp_SysInfo"
End Sub

Private Sub btnTetris_Click()
DoCmd.OpenForm "_frmHlp_Spiel_Tetris"
End Sub

Private Sub btnWaehrUmr_Click()
DoCmd.OpenForm "_frmHlp_Waehrungsumrechnung"
End Sub

Private Sub cmdOK_Click()
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
End Sub
