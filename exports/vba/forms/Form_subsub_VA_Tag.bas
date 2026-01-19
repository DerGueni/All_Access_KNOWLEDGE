VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_subsub_VA_Tag"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btn_frm_Auftrag_Oeffnen_Click()
Dim iVA_ID As Long
Dim mename As String
Dim i As Long
Dim iVADatum_ID As Long
Dim iAktDat_ID As Long

If Len(Trim(Nz(Me!VA_ID))) = 0 Then Exit Sub

iVA_ID = Me!VA_ID
'iVADatum_ID = Me!VADatum_ID
iVADatum_ID = TLookup("ID", "tbl_VA_AnzTage", "VADatum = " & SQLDatum(Me!VADatum) & " AND VA_ID = " & iVA_ID)

DoCmd.OpenForm "frm_VA_Auftragstamm"

iAktDat_ID = TLookup("ID", "tbl_VA_AnzTage", "VA_ID = " & iVA_ID & " AND VADatum = " & SQLDatum(Me.Parent!dtDatum))
Form_frm_VA_Auftragstamm.Recordset.FindFirst "ID = " & iVA_ID
Form_frm_VA_Auftragstamm.VADateSet (iAktDat_ID)


DoCmd.Close acForm, "frmTop_VA_Tag_sub", acSaveNo

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub
