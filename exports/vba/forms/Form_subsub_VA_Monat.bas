VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_subsub_VA_Monat"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub dtDatum_DblClick(Cancel As Integer)
Dim i As Long
i = fAnzAuftragTag(Me!dtDatum)
If i > 0 Then
    Me.Parent.Parent!dtStartdatum = Me!dtDatum
    Form_frm_UE_Uebersicht.WoUmsch 1
End If
End Sub

'Private Sub List_Tag_AfterUpdate()
'List_Tag_Exit False
'End Sub

Private Sub List_Tag_DblClick(Cancel As Integer)

Dim iVA_ID As Long
Dim strSQL2 As String
Dim dtsich As Date
Dim stdat As Date

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

iVA_ID = Nz(Me!List_Tag.Column(0), 0)

If iVA_ID = 0 Then Exit Sub

stdat = Me!dtDatum

dtsich = Form_frm_UE_Uebersicht!dtStartdatum

'If Not IsDateBetween2Dates(stdat, dtsich, dtsich + 6) Then

    Form_frm_UE_Uebersicht!dtStartdatum = Me!dtDatum
    DoEvents
    Form_frm_UE_Uebersicht.Wochanz_Fill
    Form_frm_UE_Uebersicht!dtStartdatum = dtsich
    DoEvents

'End If

strSQL2 = ""
strSQL2 = strSQL2 & "SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, Nz(tbl_MA_VA_Zuordnung.MA_ID,0) AS Ausdr1, tbl_MA_VA_Zuordnung.PosNr,"
strSQL2 = strSQL2 & " [Nachname] & ', ' & [Vorname] AS Mitarbeiter, Left(Nz([VA_Start]),5) AS Start"
strSQL2 = strSQL2 & " FROM tbl_VA_Start RIGHT JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm"
strSQL2 = strSQL2 & " ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID"
strSQL2 = strSQL2 & " WHERE (tbl_MA_VA_Zuordnung.VA_ID= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum) = " & SQLDatum(stdat) & ") Order By PosNr;"

'DoCmd.OpenForm "frm_VA_Auftragstamm", , , "ID = " & iVA_ID
DoCmd.OpenForm "frmTop_VA_Tag_sub"
Forms!frmTop_VA_Tag_sub!dtDatum = stdat
Forms!frmTop_VA_Tag_sub!VA_ID = iVA_ID
Forms!frmTop_VA_Tag_sub!lst_Ist.RowSource = strSQL2
Forms!frmTop_VA_Tag_sub!lst_Ist.Requery
Forms!frmTop_VA_Tag_sub.Requery

End Sub

'Private Sub List_Tag_Exit(Cancel As Integer)
'Dim i As Long
'i = Me!List_Tag.ListIndex
'On Error Resume Next
'If Me!List_Tag.Column(3, i) = True Then
'    Me!List_Tag.Selected(i) = True
'Else
'    Me!List_Tag.Selected(i) = False
'End If
'
'End Sub
