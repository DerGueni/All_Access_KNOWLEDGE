VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_DP_Auftrageingabe_Siegert"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub cboQuali_DblClick(Cancel As Integer)
DoCmd.OpenForm "frm_Top_Einsatzart"
End Sub

Private Sub Form_Open(Cancel As Integer)
CurrentDb.Execute ("DELETE * FROM tbltmp_MA_Verfueg_tmp")
CurrentDb.Execute ("INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, MAName, IstVerfuegbar, Anstellungsart_ID, IstAktiv) SELECT 0 AS Ausdr1, '(gelöscht)' AS Ausdr2, -1 AS Ausdr3, 3 as Ausdr4, -1 as Ausdr5 FROM _tblInternalSystemFE;")
CurrentDb.Execute ("qry_MA_Add_Verfueg_tmp_1")

Me!MA_Selektion = Get_Priv_Property("prp_MA_Selektion")
Me!cboAnstArt = Get_Priv_Property("prp_cboAnstArt")
Me!IstVerfuegbar = Get_Priv_Property("prp_IstVerfuegbar")
Me!cboQuali = Get_Priv_Property("prp_cboQuali")

End Sub


Public Function fMA_Selektion_AfterUpdate()
MA_Selektion_AfterUpdate
End Function

Private Sub cboAnstArt_AfterUpdate()
If Len(Trim(Nz(Me!cboAnstArt))) > 0 Then
    Call Set_Priv_Property("prp_cboAnstArt", Me!cboAnstArt)
End If
MA_Selektion_AfterUpdate
End Sub

Private Sub cboQuali_AfterUpdate()
If Len(Trim(Nz(Me!cboQuali))) > 0 Then
    Call Set_Priv_Property("prp_cboQuali", Me!cboQuali)
End If
MA_Selektion_AfterUpdate
End Sub

Private Sub IstVerfuegbar_AfterUpdate()
If Len(Trim(Nz(Me!IstVerfuegbar))) > 0 Then
    Call Set_Priv_Property("prp_IstVerfuegbar", Me!IstVerfuegbar)
End If
MA_Selektion_AfterUpdate
End Sub

Private Sub MA_Selektion_AfterUpdate()

Dim strSQL As String
Dim sto As String

If Len(Trim(Nz(Me!MA_Selektion))) > 0 Then
    Call Set_Priv_Property("prp_MA_Selektion", Me!MA_Selektion)
End If

sto = " Order by MAName"

strSQL = ""
If Me!MA_Selektion = 1 Then
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
