VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_DP_Auftrageingabe"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


'#########################################
'Hilfsroutinen

'Private Sub ShowInputErrors(OnOff As Boolean)
'  Me.lblVNrWarning.Visible = OnOff
'End Sub

Private Function CharConv(strChar As String) As String
Dim strTmp As String

  strTmp = UCase(Left(strChar, 1))
  Select Case strTmp
    Case "Ä": strTmp = "A"
    Case "Ö": strTmp = "O"
    Case "Ü": strTmp = "U"
    Case "ß": strTmp = "S"
  End Select
  CharConv = strTmp
End Function



Private Sub btnAuftrag_Click()

Dim iVA_ID As Long
Dim iVADatum_ID As Long

iVA_ID = Me!sub_MA_VA_Zuordnung.Form.VA_ID
iVADatum_ID = Me!sub_MA_VA_Zuordnung.Form.VADatum_ID
DoCmd.OpenForm "frm_VA_Auftragstamm"
Call Form_frm_VA_Auftragstamm.VAOpen(iVA_ID, iVADatum_ID)

End Sub


'Private Sub cboQuali_DblClick(Cancel As Integer)
'DoCmd.OpenForm "frm_Top_Einsatzart"
'End Sub


Private Sub Form_Open(Cancel As Integer)

Me!MA_Selektion = Get_Priv_Property("prp_MA_Selektion")
Me!cboAnstArt = Get_Priv_Property("prp_cboAnstArt")
Me!IstVerfuegbar = Get_Priv_Property("prp_IstVerfuegbar")
'Me!cboQuali = Get_Priv_Property("prp_cboQuali")

End Sub


Public Function fMA_Selektion_AfterUpdate()
MA_Selektion_AfterUpdate
End Function

Private Sub cboAnstArt_AfterUpdate()
If Len(Trim(Nz(Me!cboAnstArt))) > 0 Then
    Call Set_Priv_Property("prp_cboAnstArt", Me!cboAnstArt)
End If
MA_Selektion_AfterUpdate
Me.sub_MA_VA_Zuordnung.Form.cboMA_Ausw.Dropdown
End Sub
'
'Private Sub cboQuali_AfterUpdate()
'If Len(Trim(Nz(Me!cboQuali))) > 0 Then
'    Call Set_Priv_Property("prp_cboQuali", Me!cboQuali)
'End If
'MA_Selektion_AfterUpdate
'End Sub

Private Sub IstVerfuegbar_AfterUpdate()
If Len(Trim(Nz(Me!IstVerfuegbar))) > 0 Then
    Call Set_Priv_Property("prp_IstVerfuegbar", Me!IstVerfuegbar)
End If
MA_Selektion_AfterUpdate
Me.sub_MA_VA_Zuordnung.Form.cboMA_Ausw.Dropdown
End Sub

Private Sub MA_Selektion_AfterUpdate()

Dim strSQL As String
Dim sto As String

If Len(Trim(Nz(Me!MA_Selektion))) > 0 Then
    Call Set_Priv_Property("prp_MA_Selektion", Me!MA_Selektion)
End If

sto = " Order by MAName"

strSQL = ""
If Me!MA_Selektion = 1 Or Me!cboAnstArt = 9 Then
    strSQL = "SELECT ID, MAName AS Name, ID as PersNr From tbltmp_MA_Verfueg_tmp WHERE 1 = 1"
ElseIf Me!MA_Selektion = 2 Then
    strSQL = "SELECT ID, MAName AS Name, ID AS PersNr From tbltmp_MA_Verfueg_tmp WHERE IstAktiv = True"
End If
'If Me!cboQuali > 1 Then
'    strSQL = strSQL & " AND ID In(SELECT MA_ID FROM tbl_MA_Einsatz_Zuo WHERE Quali_ID = " & Me!cboQuali & ")"
'End If
If Me!IstVerfuegbar = True Then
    strSQL = strSQL & " AND IstVerfuegbar = True"
End If
If Me!cboAnstArt <> 9 Then
    strSQL = strSQL & " AND Anstellungsart_ID = " & Me!cboAnstArt
End If

Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.RowSource = strSQL & sto

End Sub

'Verfügbarkeiten Updaten
Function update()
Dim VA_ID   As Long
Dim VADatum As Date
Dim von     As Date
Dim bis     As Date
Dim strSQL As String
Dim srctbl As String

    VA_ID = Me.sub_MA_VA_Zuordnung.Form.Controls("VA_ID")
    VADatum = Me.sub_MA_VA_Zuordnung.Form.Controls("VADatum")
    von = Me.sub_MA_VA_Zuordnung.Form.Controls("MVA_Start")
    bis = Me.sub_MA_VA_Zuordnung.Form.Controls("MVA_Ende")
    
'    If bis < von Then
'        bis = VADatum + 1 & " " & bis
'    Else
'        bis = VADatum & " " & bis
'    End If
'
'    von = VADatum & " " & von

    Me.Painting = False
    
    Call upd_Vergleichszeiten(VA_ID, von, bis)
    
'    srctbl = "ztbl_MA_Schnellauswahl"
'    strsql = upd_qry_Verfuegbarkeit(False, 9, 1, False)
'    CurrentDb.Execute "DELETE FROM " & srctbl
'    CurrentDb.Execute "INSERT INTO " & srctbl & " " & strsql
'    DoEvents
    
    CurrentDb.Execute ("DELETE * FROM tbltmp_MA_Verfueg_tmp")
    CurrentDb.Execute ("INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, MAName, IstVerfuegbar, Anstellungsart_ID, IstAktiv) SELECT 0 AS Ausdr1, '(gelöscht)' AS Ausdr2, -1 AS Ausdr3, 3 as Ausdr4, -1 as Ausdr5 FROM _tblInternalSystemFE;")
    CurrentDb.Execute ("INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, MAName, IstVerfuegbar, Anstellungsart_ID, IstAktiv) SELECT 0 AS Ausdr1, '(gelöscht)' AS Ausdr2, -1 AS Ausdr3, 5 as Ausdr4, -1 as Ausdr5 FROM _tblInternalSystemFE;")
    CurrentDb.Execute ("INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, MAName, IstVerfuegbar, Anstellungsart_ID, IstAktiv) SELECT 0 AS Ausdr1, '(gelöscht)' AS Ausdr2, -1 AS Ausdr3,11 as Ausdr4, -1 as Ausdr5 FROM _tblInternalSystemFE;")
    CurrentDb.Execute ("qry_MA_Add_Verfueg_tmp_1")
    
    Me.Painting = True
    
End Function
