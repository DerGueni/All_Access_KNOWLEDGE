VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_MA_Anstellungsart"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_AfterUpdate()
Me!lstAusw.Requery
End Sub

Private Sub Form_BeforeDelConfirm(Cancel As Integer, response As Integer)
If Me!ID <= 10 Then
    MsgBox "Anstellungsart kann nicht gelöscht werden"
    Cancel = True
End If
End Sub

Private Sub Form_Load()
    PosWiederherstellen Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
    PosSpeichern Me
End Sub

Private Sub lstAusw_Click()
Me.Recordset.FindFirst "ID = " & Me!lstAusw
End Sub

Private Sub btnDaBaAus_Click()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End Sub

Private Sub btnDaBaEin_Click()
    DoCmd.SelectObject acTable, , True
End Sub

Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub

Private Sub btnRibbonEin_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub


