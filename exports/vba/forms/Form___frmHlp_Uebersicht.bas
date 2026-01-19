VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form___frmHlp_Uebersicht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

Private Sub btnClose_Click()
If vbOK = MsgBox("Access benden", vbQuestion + vbOKCancel, "Access beenden") Then
    DoCmd.Quit acQuitSaveAll
End If
End Sub


Private Sub Form_Load()
    
Dim iMenueNr_Vgl As Long
Dim iMenueNr As Long
Dim i As Long
Dim strFkt As String
Dim strMakro As String

'SELECT * FROM tbl_Menuefuehrung_Neu order by MenueNr, SortNr

recsetSQL1 = "SELECT * FROM tbl_Menuefuehrung_Neu order by MenueNr, SortNr"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If Not ArrFill_DAO_OK1 Then
    DoCmd.Close acForm, Me.Name, acSaveNo
    Exit Sub
End If
    
End Sub

Public Function call_Menu(iMenu As Long)
Dim i As Long
On Error Resume Next
Form_Load

SendKeys "{ESC}{ESC}"
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

'i = Forms!frm_Menuefuehrung("cboF" & iMenu).Column(0)
i = Me("cboF" & iMenu).Column(0)

Call getMenu(i)
End Function

Function getMenu(i As Long)
Dim bLoesch As Boolean
On Error Resume Next

For iZl = 0 To iZLMax1
    If DAOARRAY1(0, iZl) = i Then Exit For
Next iZl
bLoesch = CLng(DAOARRAY1(7, iZl))
If bLoesch = True Then
    CloseAllForms_Neu
    DoCmd.OpenForm "__frmHlp_Uebersicht"
    DoEvents
End If
If Len(Trim(Nz(DAOARRAY1(3, iZl)))) > 0 Then
    Eval (DAOARRAY1(3, iZl))
ElseIf Len(Trim(Nz(DAOARRAY1(4, iZl)))) > 0 Then
    Eval (DAOARRAY1(4, iZl))
End If
End Function

Function CloseAllForms_Neu()
' Schließen aller Forms
' aus der Newsgroup

Dim frm As Form
Dim FormNummer, i As Integer
Dim Ausnahme As String

On Error Resume Next
FormNummer = 0
i = 0
'Ausnahme = "frm_Menuefuehrung"
Ausnahme = ""

'While Forms.count > 1
While Forms.Count > 0
    i = i + 1
    Set frm = Forms(FormNummer)
'    If frm.formname = Ausnahme Then
'        FormNummer = 1
'    Else
        If frm.Modal Then frm.Modal = False  '<<<added
        If frm.PopUp Then frm.PopUp = False  '<<<added
        DoCmd.Close acForm, frm.Name, acSaveNo
'    End If
Wend

End Function
