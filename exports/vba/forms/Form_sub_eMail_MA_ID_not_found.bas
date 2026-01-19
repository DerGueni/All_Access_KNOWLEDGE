VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_eMail_MA_ID_not_found"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub MA_ID_AfterUpdate()

Dim strSQL As String

If Len(Trim(Nz(Me!Sender))) > 0 And Me!MA_ID > 0 Then

    strSQL = "INSERT INTO tbl_MA_ErsatzEmailAdressen ( MA_ID, email_2 ) SELECT " & Me!MA_ID & " AS Ausdr1, '" & Me!Sender & "' AS Ausdr2 FROM _tblInternalSystemFE;"
    CurrentDb.Execute (strSQL)

End If
End Sub
