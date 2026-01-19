VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_MA_Tagesuebersicht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
cboZeitraum_AfterUpdate
btnUebers_Click
End Sub

Private Sub btnUebers_Click()

Dim strSQL As String

strSQL = ""
strSQL = strSQL & "SELECT qry_MA_Tagesuebersicht.* FROM qry_MA_Tagesuebersicht WHERE VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis)

If Nz(Me!cbo_MA_Vgl.Column(0), 0) > 0 Then
    strSQL = strSQL & " AND ID = " & Me!cbo_MA_Vgl.Column(0)
End If

If Me!NichtNurAktive = False Then
    strSQL = strSQL & " AND IstAktiv = True "
End If

strSQL = strSQL & " ORDER BY qry_MA_Tagesuebersicht.VADatum, Start, Nachname, Vorname;"

Me!sub_MA_Tagesuebersicht.Form.recordSource = strSQL
Me!sub_MA_Tagesuebersicht.Form.Requery

End Sub

Private Sub cboZeitraum_AfterUpdate()
'' Function StdZeitraum_Von_Bis(ID, von, bis)  und Tabelle _tblZeitraumAngaben (für Combobox)
Dim dtvon As Date
Dim dtbis As Date
Call StdZeitraum_Von_Bis(Me!cboZeitraum, dtvon, dtbis)
Me!AU_von = dtvon
Me!AU_bis = dtbis
DoEvents
End Sub


Private Sub cbo_MA_Vgl_AfterUpdate()
If Me!cbo_MA_Vgl = 0 Then
    Me!cbo_MA_Vgl = Null
End If
btnUebers_Click
End Sub

Private Sub NichtNurAktive_AfterUpdate()
Dim strSQL As String
If Me!NichtNurAktive = True Then
    Me!NichtNurAktive.caption = "Alle"
    strSQL = "SELECT 0 as ID1, '  Alle' as GesName, 0 AS MA_ID FROM _tblInternalSystemFE UNION SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & ', ' & [Vorname] AS GesName, tbl_MA_Mitarbeiterstamm.ID AS MA_ID FROM tbl_MA_Mitarbeiterstamm ORDER BY GesName;"
Me!cbo_MA_Vgl.RowSource = strSQL
Else
    Me!NichtNurAktive.caption = "Nur Aktive"
    strSQL = "SELECT 0 as ID1, '  Alle' as GesName, 0 AS MA_ID FROM _tblInternalSystemFE UNION SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & ', ' & [Vorname] AS GesName, tbl_MA_Mitarbeiterstamm.ID AS MA_ID FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = True ORDER BY GesName;"
    Me!cbo_MA_Vgl.RowSource = strSQL
End If
Me!cbo_MA_Vgl.Requery
End Sub
