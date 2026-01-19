VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_Maintainance_Menue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btn_MA_Maintainance_Click()
DoCmd.OpenForm "frm_MA_Maintainance"
End Sub

Private Sub btnAdrKorrKunde_Click()
f_KD_Adr_Korrektur
End Sub

Private Sub btnAdrKorrMA_Click()
f_MA_Adr_Korrektur
End Sub

Private Sub btnDoppelteAuftr_Click()
DoCmd.OpenQuery "_Auswertung_qry_Doppelt_Pro_Auftrag", , acReadOnly 'acViewPreview  acViewReport  acEdit   acReadOnly
End Sub

Private Sub btnDoppelteUeber_Click()
DoCmd.OpenQuery "qry_Doppelt_MitZusInfo", , acReadOnly
End Sub

Private Sub btnExcelVorlagenSp_Click()
fExcel_Vorlagen_Schreiben
MsgBox "Excel Vorlagen im Dateisystem gespeichert"
End Sub

Private Sub btnImportUms_Click()

Dim strSQL As String

CurrentDb.Execute ("DELETE * FROM tbl_Rch_Kopf WHERE Year(RchDatum) < 2015")
DoEvents

strSQL = ""
strSQL = strSQL & "INSERT INTO tbl_Rch_Kopf ( RchDatum, RchNr_Ext, RchTyp, VorlageDokNr, kun_ID, VA_ID, Auftrag, Zwi_Sum1, FahrtkostenNetto, SonstigesNetto )"
strSQL = strSQL & " SELECT [_Umsatz_Gesamt].ReDat, [_Umsatz_Gesamt].RchNr, 4 AS Ausdr1, 14 AS Ausdr2, [_Umsatz_Gesamt].kun_ID, [_Umsatz_Gesamt].VA_ID, [_Umsatz_Gesamt].strVA,"
strSQL = strSQL & " [_Umsatz_Gesamt].Summe_Netto , [_Umsatz_Gesamt].Fk, [_Umsatz_Gesamt].Bänder"
strSQL = strSQL & " FROM _Umsatz_Gesamt WHERE year([ReDat]) < 2015;"
CurrentDb.Execute (strSQL)
DoEvents

MsgBox "2010 - 2014 importiert"

End Sub

Private Sub btnStatus4Ruecksetzen_Click()
CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Veranst_Status_ID = 3 WHERE (((tbl_VA_Auftragstamm.Veranst_Status_ID)=4));")
DoEvents
MsgBox "Aufträge zurückgesetzt"
End Sub

Private Sub btnStatusZeitenKorrOhne_Click()
DoCmd.Hourglass True
f_Schicht_Tag_Anz_Ist_Korr False
DoCmd.Hourglass False
End Sub

Private Sub btnStatusZeitenKorrMit_Click()
DoCmd.Hourglass True
f_Schicht_Tag_Anz_Ist_Korr True
DoCmd.Hourglass False
End Sub
