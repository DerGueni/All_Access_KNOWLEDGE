VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmFensterposition"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_Load()
    Me!lblUhrzeit.caption = Format$(Now, "Long Time")
    PosWiederherstellen Me
End Sub

Private Sub Form_Timer()
    Me!lblUhrzeit.caption = Format$(Now, "Long Time")
End Sub

Private Sub Form_Unload(Cancel As Integer)
    PosSpeichern Me
End Sub
