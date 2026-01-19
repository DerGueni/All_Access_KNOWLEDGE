VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_VA_Woche_KD"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub dtDatum_DblClick(Cancel As Integer)

Dim i As Long
i = fAnzAuftragTag(Me!dtDatum)
If i > 0 Then
    Me.Parent!dtStartdatum = Me!dtDatum
    Form_frm_UE_Uebersicht.WoUmsch 1
End If
End Sub
