VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_tbltmp_Attachfile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Attachfile_DblClick(Cancel As Integer)
If Len(Trim(Nz(Me!Attachfile))) > 0 Then
    Application.FollowHyperlink Me!Attachfile
End If
End Sub

Private Sub Dateiname_DblClick(Cancel As Integer)

    If Len(Trim(Nz(Me!Attachfile))) > 0 Then
        Application.FollowHyperlink Me!Attachfile
    End If

End Sub
