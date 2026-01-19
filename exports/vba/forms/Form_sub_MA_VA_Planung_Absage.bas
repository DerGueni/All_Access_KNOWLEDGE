VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_MA_VA_Planung_Absage"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub Form_BeforeInsert(Cancel As Integer)
Me!PosNr = Nz(TMax("PosNr", "tbl_MA_VA_Planung", "VA_ID = " & Me.Parent!ID), 0) + 1
End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)
On Error Resume Next
        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo

End Sub

Private Sub MA_ID_DblClick(Cancel As Integer)

Dim iMA_ID As Long
Dim i As Long

iMA_ID = Nz(Me!MA_ID, 0)
If iMA_ID = 0 Then Exit Sub

DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"

Form_frm_MA_Mitarbeiterstamm.Recordset.FindFirst "ID = " & iMA_ID

'Form_frm_VA_Auftragstamm.Painting = False
'
'    For i = 1 To Form_frm_MA_Mitarbeiterstamm!lst_MA.ListCount
'        If Trim(Nz(Form_frm_MA_Mitarbeiterstamm!lst_MA.Column(0, i))) = iMA_ID Then
'            Form_frm_MA_Mitarbeiterstamm!lst_MA.Selected(i) = True
'            Exit For
'        End If
'    Next i
'
'Form_frm_VA_Auftragstamm.Painting = True

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub

Private Sub VA_Ende_AfterUpdate()
Start_End_Aend
End Sub

Private Sub VA_Start_AfterUpdate()
Start_End_Aend
End Sub

Function Start_End_Aend()
Me!VADatum = Me.Parent!cboDatum.Column(1)
Me!MVA_Start = Startzeit_G(Me!VADatum, Me!VA_Start)

If Len(Trim(Nz(Me!VA_Ende))) > 0 Then
    Me!MVA_Ende = Endezeit_G(Me!VADatum, Me!VA_Start, Me!VA_Ende)
End If

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Function
