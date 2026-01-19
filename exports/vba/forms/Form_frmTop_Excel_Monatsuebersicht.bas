VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_Excel_Monatsuebersicht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub aktJahr_AfterUpdate()
fExcelname
End Sub

Private Sub AktMonat_AfterUpdate()
fExcelname
End Sub

Function fExcelname()

'Dim strvname As String
'Dim strnname As String
'Dim MA_ID As Long
Dim MA_Name As String

If Me!UebersichtsArt = 1 Then
    Me!ExcelName = "MUE_Ges_" & Me!aktJahr & "_" & Right("00" & Me!AktMonat, 2) & ".xls"
Else
    MA_Name = Me!cboMitarbeiter.Column(1)
    'MA_ID = Me!cboMitarbeiter.Column(0)
    'strnname = Nz(TLookup("Nachname", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID))
    'strvname = Nz(TLookup("Vorname", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID))
    ' Me!ExcelName = "MUE_MA_" & iAktJahr & "_" & Right("00" & iAktMon, 2) & "_" & strnname & "_" & strvname & ".xls"
     Me!ExcelName = "MUE_MA_" & Me!aktJahr & "_" & Right("00" & Me!AktMonat, 2) & "_" & MA_Name & ".xls"
End If

End Function

Private Sub btnMonUebExcel_Click()
If Me!UebersichtsArt = 1 Then
    fMUE_Ges
Else
    fMUE_Einzel
End If

End Sub

Function fMUE_Ges()
Dim strSQL As String
Dim datname As String
Dim mename As String

DoCmd.Hourglass True
Me!btnMonUebExcel.Enabled = False

Call Ueberlaufstd_Berech_Neu(Me!aktJahr, Me!AktMonat)
DoEvents

If Me!Istaktiv_MA = True Then
    strSQL = "SELECT * FROM qry_JB_MA_Jahr_Gesamt WHERE AktMon = " & Me!AktMonat & " AND AktJahr = " & Me!aktJahr & " AND IstAktiv = TRUE;"
Else
    strSQL = "SELECT * FROM qry_JB_MA_Jahr_Gesamt WHERE AktMon = " & Me!AktMonat & " AND AktJahr = " & Me!aktJahr & ";"
End If
Call CreateQuery(strSQL, "qry_JB_MA_Gesamt_tmp_Excel")
datname = Me!ExcelPfad & Me!ExcelName
DoEvents
DoCmd.TransferSpreadsheet acExport, acSpreadsheetTypeExcel9, "qry_JB_MA_Gesamt_tmp_Excel", datname, True
DoEvents
DoCmd.Hourglass False
mename = Me.Name
Application.FollowHyperlink datname
Me!btnMonUebExcel.Enabled = True
DoCmd.Close acForm, mename, acSaveNo

End Function

Function fMUE_Einzel()
Dim strSQL As String
Dim datname As String
Dim mename As String

DoCmd.Hourglass True
Me!btnMonUebExcel.Enabled = False

Call Monat_Erz(Me!AktMonat, Me!aktJahr, Me!cboMitarbeiter.Column(0))
DoEvents

datname = Me!ExcelPfad & Me!ExcelName
DoEvents
DoCmd.TransferSpreadsheet acExport, acSpreadsheetTypeExcel9, "qry_Exl_MA_5", datname, True
DoEvents
DoCmd.Hourglass False
mename = Me.Name
Application.FollowHyperlink datname
Me!btnMonUebExcel.Enabled = True
DoCmd.Close acForm, mename, acSaveNo

End Function

Private Sub cboMitarbeiter_AfterUpdate()
fExcelname
End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!ExcelPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 11"))
Call Path_erzeugen(Me!ExcelPfad, False, True)
Me!ExcelPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 10"))
Call Path_erzeugen(Me!ExcelPfad, False, True)
Me!ExcelName = "Monatsübersicht_" & Me!aktJahr & "_" & Me!AktMonat & ".xls"
End Sub

Private Sub Istaktiv_MA_AfterUpdate()

If Me!Istaktiv_MA = True Then
    Me!cboMitarbeiter.RowSource = "SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & ""_"" & [Vorname] AS Name FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True ORDER BY [Nachname] & ""_"" & [Vorname];"
Else
    Me!cboMitarbeiter.RowSource = "SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & ""_"" & [Vorname] AS Name FROM tbl_MA_Mitarbeiterstamm ORDER BY [Nachname] & ""_"" & [Vorname];"
End If
Me!cboMitarbeiter.defaultValue = "[cboMitarbeiter].[ItemData](0)"
Me!cboMitarbeiter.Requery
End Sub

Private Sub UebersichtsArt_AfterUpdate()
If Me!UebersichtsArt = 1 Then  ' Alle
    Me!cboMitarbeiter.Visible = False
Else
    Me!cboMitarbeiter.Visible = True
End If
End Sub
