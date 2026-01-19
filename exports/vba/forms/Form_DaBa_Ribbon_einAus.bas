VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_DaBa_Ribbon_einAus"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub btnDaBaAus_Click()
DaBa_Fenster_aus
End Sub

Private Sub btnDaBaEin_Click()
DaBa_Fenster_ein
End Sub

Private Sub btnRibbonAus_Click()
Ribbon_aus
End Sub

Private Sub btnRibbonEin_Click()
Ribbon_ein
End Sub
