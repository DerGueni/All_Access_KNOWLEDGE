VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zsub_copy_to_mail"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub Email_DblClick(Cancel As Integer)
    Call add_remove
End Sub

Private Sub Name_DblClick(Cancel As Integer)
    Call add_remove
End Sub


Function add_remove() As Variant

Dim arr(0, 1) As String

    arr(0, 0) = Me.MA
    arr(0, 1) = Me.Email
    
    'add_remove = arr

'On Error Resume Next
    If Me.Parent.Name <> "" Then Call Me.Parent.add_remove(arr)

End Function
