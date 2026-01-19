'Option Compare Database
'Option Explicit
'
''Below code will set the BackColor of second column.
''
'vb.net Code:
'Public Class Form1
'
'    Private Sub Form1_Load(_
'        ByVal sender As System.Object, _
'        ByVal e As System.EventArgs _
'    ) Handles MyBase.Load
'
'        For i As Integer = 0 To ListView1.Items.Count - 1
'            ListView1.Items(i).UseItemStyleForSubItems = False
'            If ListView1.Items(i).SubItems.Count > 1 Then
'                ListView1.Items(i).SubItems(1).BackColor = Color.red
'                ListView1.Items(i).SubItems(1).Font = New Font(ListView1.Items(i).SubItems(1).Font, FontStyle.Bold)
'            End If
'        Next
'    End Sub
'
'End Class
''