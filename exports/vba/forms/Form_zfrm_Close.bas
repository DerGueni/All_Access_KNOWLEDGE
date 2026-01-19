VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_Close"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database


Private Sub Detailbereich_Click()
    Me.Visible = False
End Sub


Private Sub Form_Current()
    Me.Visible = False
End Sub

Private Sub Form_Load()

    If Environ("UserName") <> "johannes.kuypers" Then Me.TimerInterval = 5000
    Me.Visible = False

End Sub


Private Sub Form_Open(Cancel As Integer)
    Me.Visible = False
End Sub


Private Sub Form_Timer()

On Error Resume Next

    If TLookup("close", "ztbl_CloseAll", "close = TRUE AND check = TRUE") = True Then

        Call Quit_Access
        
    End If
    
End Sub
