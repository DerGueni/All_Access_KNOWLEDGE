VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_VA_Tag_sub"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub lst_Ist_DblClick(Cancel As Integer)


Dim iVA_ID As Long
Dim mename As String
Dim i As Long


Dim iID As Long, iMA_ID As Long

iID = lst_Ist.Column(0)     ' ID der Tabelle tbl_MA_VA_Zuordnung
iVA_ID = lst_Ist.Column(1)  ' Tabelle tbl_VA_Auftragstamm
iMA_ID = lst_Ist.Column(2)  ' Tabelle Mitarbeiter - oder 0 wenn noch nicht selektiert

If iMA_ID = 0 Then Exit Sub

DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Form_frm_MA_Mitarbeiterstamm.Recordset.FindFirst "ID = " & iMA_ID

Form_frm_VA_Auftragstamm.Painting = False

    For i = 1 To Form_frm_MA_Mitarbeiterstamm!Lst_MA.ListCount
        If Trim(Nz(Form_frm_MA_Mitarbeiterstamm!Lst_MA.Column(0, i))) = iMA_ID Then
            Form_frm_MA_Mitarbeiterstamm!Lst_MA.selected(i) = True
            Exit For
        End If
    Next i

Form_frm_VA_Auftragstamm.Painting = True

If isFormLoad("frm_UE_Uebersicht") Then
    DoCmd.Close acForm, "frm_UE_Uebersicht", acSaveNo
    DoEvents
End If

DoCmd.Close acForm, "frmTop_VA_Tag_sub", acSaveNo

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub
