VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_MA_Einsatzart"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_AfterUpdate()
Me!lstEinsatzart.Requery
End Sub

Private Sub Form_Delete(Cancel As Integer)
If Me!ID = 1 Then Cancel = True
End Sub

Private Sub lstEinsatzart_Click()
Me.Recordset.FindFirst "ID = " & Me!lstEinsatzart
End Sub
