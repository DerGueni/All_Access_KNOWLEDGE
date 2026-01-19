VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_MA_ZuAbsage"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
cboZeitraum_AfterUpdate
btnZuAbs_Lesen_Click
End Sub

Private Sub btnZuAbs_Lesen_Click()

Dim strSQL As String

strSQL = ""
strSQL = strSQL & "SELECT tbl_MA_VA_Planung.* FROM tbl_MA_VA_Planung WHERE Status_ID < 3 AND VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis)

If Nz(Me!cboAuftrag_Vgl, 0) > 0 Then
    strSQL = strSQL & " AND VA_ID = " & Me!cboAuftrag_Vgl
End If

If Nz(Me!cbo_MA_Vgl, 0) > 0 Then
    strSQL = strSQL & " AND MA_ID = " & Me!cbo_MA_Vgl
End If

strSQL = strSQL & " ORDER BY tbl_MA_VA_Planung.MVA_Start, PosNr;"

Me!sub_tbl_MA_VA_Planung.Form.recordSource = strSQL

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
btnZuAbs_Lesen_Click
End Sub

Private Sub cboAuftrag_Vgl_AfterUpdate()
If Me!cboAuftrag_Vgl = 0 Then
    Me!cboAuftrag_Vgl = Null
End If
btnZuAbs_Lesen_Click
End Sub
