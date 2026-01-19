VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_ZusatzDateien"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Dateiname_DblClick(Cancel As Integer)
If File_exist(Me!Dateiname) Then
    Application.FollowHyperlink Me!Dateiname
End If
'DoCmd.OpenForm "frmHlp_AnzeigeZusatz", , , "ZusatzNr = " & Me!ZusatzNr
End Sub
