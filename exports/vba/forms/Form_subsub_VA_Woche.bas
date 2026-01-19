VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_subsub_VA_Woche"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btn_frm_Auftrag_Oeffnen_Click()
Dim iVA_ID As Long
Dim strSQL2 As String
Dim stdat As Date

If Len(Trim(Nz(Me!VA_ID))) = 0 Then Exit Sub

iVA_ID = Me!VA_ID
stdat = Me.Parent!dtDatum

strSQL2 = ""
strSQL2 = strSQL2 & "SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, Nz(tbl_MA_VA_Zuordnung.MA_ID,0) AS Ausdr1, tbl_MA_VA_Zuordnung.PosNr,"
strSQL2 = strSQL2 & " [Nachname] & ', ' & [Vorname] AS Mitarbeiter, Left(Nz([VA_Start]),5) AS Start"
strSQL2 = strSQL2 & " FROM tbl_VA_Start RIGHT JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm"
strSQL2 = strSQL2 & " ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID"
strSQL2 = strSQL2 & " WHERE (tbl_MA_VA_Zuordnung.VA_ID= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum) = " & SQLDatum(stdat) & ") Order By PosNr;"

'DoCmd.OpenForm "frm_VA_Auftragstamm", , , "ID = " & iVA_ID
DoCmd.OpenForm "frmTop_VA_Tag_sub"
'Forms!frmTop_VA_Tag_sub!VADatum_ID = TLookup("ID", "tbl_VA_AnzTage", "VADatum = " & SQLDatum(stdat) & " AND VA_ID = " & iVA_ID)
Forms!frmTop_VA_Tag_sub!dtDatum = stdat
Forms!frmTop_VA_Tag_sub!VA_ID = iVA_ID
Forms!frmTop_VA_Tag_sub!lst_Ist.RowSource = strSQL2
Forms!frmTop_VA_Tag_sub!lst_Ist.Requery
Forms!frmTop_VA_Tag_sub.Requery

End Sub
