VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Startmenue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Befehl1_Click()
DoCmd.OpenForm "frm_ma_mitarbeiterstamm"

End Sub

Private Sub Befehl2_Click()
DoCmd.OpenForm "frm_va_auftragstamm"

End Sub

Private Sub Befehl3_Click()
DoCmd.OpenForm "frm_dp_dienstplan_objekt"

End Sub

Private Sub Befehl4_Click()
DoCmd.OpenForm "frm_va_auftragstamm"

End Sub
