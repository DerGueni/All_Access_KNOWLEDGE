VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_DP_Auftrageingabe_"
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

Call zf_MA_Selektion

'CurrentDb.Execute ("DELETE * FROM tbltmp_MA_Verfueg_tmp")
'CurrentDb.Execute ("INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, MAName, IstVerfuegbar, Anstellungsart_ID, IstAktiv) SELECT 0 AS Ausdr1, '(gelöscht)' AS Ausdr2, -1 AS Ausdr3, 3 as Ausdr4, -1 as Ausdr5 FROM _tblInternalSystemFE;")
'CurrentDb.Execute ("qry_MA_Add_Verfueg_tmp_1")

End Sub


Public Function fMA_Selektion_AfterUpdate()
'MA_Selektion_AfterUpdate
End Function

Private Sub cboAnstArt_AfterUpdate()
If Len(Trim(Nz(Me!cboAnstArt))) > 0 Then
    Call Set_Priv_Property("prp_cboAnstArt", Me!cboAnstArt)
End If
'MA_Selektion_AfterUpdate
Call zf_MA_Selektion
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
'MA_Selektion_AfterUpdate
Call zf_MA_Selektion
End Sub

'Private Sub MA_Selektion_AfterUpdate()
'
'Dim strsql As String
'Dim sto As String
''
'If Len(Trim(Nz(Me!MA_Selektion))) > 0 Then
'    Call Set_Priv_Property("prp_MA_Selektion", Me!MA_Selektion)
'End If
'
''sto = " Order by MAName"
'sto = " Order by Name"
'
'strsql = ""
'If Me!MA_Selektion = 1 Or Me!cboAnstArt = 9 Then
'    strsql = "SELECT ID, MAName AS Name, ID as PersNr From tbltmp_MA_Verfueg_tmp WHERE 1 = 1"
'ElseIf Me!MA_Selektion = 2 Then
'    strsql = "SELECT ID, MAName AS Name, ID AS PersNr From tbltmp_MA_Verfueg_tmp WHERE IstAktiv = True"
'End If
''If Me!cboQuali > 1 Then
''    strSQL = strSQL & " AND ID In(SELECT MA_ID FROM tbl_MA_Einsatz_Zuo WHERE Quali_ID = " & Me!cboQuali & ")"
''End If
'If Me!IstVerfuegbar = True Then
'    strsql = strsql & " AND IstVerfuegbar = True"
'End If
'If Me!cboAnstArt <> 9 Then
'    strsql = strsql & " AND Anstellungsart_ID = " & Me!cboAnstArt
'End If
'
'Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.RowSource = strsql & sto
'
'End Sub


'Schnellere Selektion der relevanten Mitarbeiter
Function zf_MA_Selektion()

Dim strSQL As String
Dim srctbl As String

    Me.Painting = False
    srctbl = "ztbl_MA_Schnellauswahl"
    strSQL = upd_qry_Verfuegbarkeit(Me.IstVerfuegbar, Me.cboAnstArt, 1, True)
    CurrentDb.Execute "DELETE FROM " & srctbl
    CurrentDb.Execute "INSERT INTO " & srctbl & " " & strSQL
    DoEvents
    
    'CurrentDb.Execute ("DELETE * FROM tbltmp_MA_Verfueg_tmp")
    'CurrentDb.Execute ("INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, MAName, IstVerfuegbar, Anstellungsart_ID, IstAktiv) SELECT 0 AS Ausdr1, '(gelöscht)' AS Ausdr2, -1 AS Ausdr3, 3 as Ausdr4, -1 as Ausdr5 FROM _tblInternalSystemFE;")
    'CurrentDb.Execute ("qry_MA_Add_Verfueg_tmp_1")

    Me.Painting = True
    'strsql = "SELECT ID, MAName AS Name, ID as PersNr From tbltmp_MA_Verfueg_tmp Order by MAName"
    Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.RowSource = srctbl
    
    
End Function
