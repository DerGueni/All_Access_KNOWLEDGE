Attribute VB_Name = "Modul2"
Option Compare Database
Option Explicit

Public Sub tblproperty()
DoCmd.OpenTable "_tblproperties"

End Sub

Public Sub tbl_kd_kundenstamm()
DoCmd.OpenTable "tbl_kd_kundenstamm"
End Sub

Public Sub tbl_ma_mitarbeiterstamm()
DoCmd.OpenTable "tbl_ma_mitarbeiterstamm"
End Sub

Public Sub kd_preisarten()
DoCmd.OpenTable "tbl_kd_preisarten"

End Sub

Public Sub frm_abwesenheiten()
DoCmd.OpenForm "frm_abwesenheiten()"

End Sub

Public Sub frm_Anstellungsart()
DoCmd.OpenForm "anstellungsart"

End Sub
 
 Public Sub tbl_email_import()
 DoCmd.OpenTable "email_import"
 
 End Sub
