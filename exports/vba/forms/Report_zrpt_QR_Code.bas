VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_zrpt_QR_Code"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub Detailbereich_Format(Cancel As Integer, FormatCount As Integer)

    Call drawQuickResponse(Me.tx_qr)
    
    
End Sub


