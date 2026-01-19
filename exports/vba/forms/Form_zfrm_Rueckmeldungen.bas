VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_Rueckmeldungen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub Form_Close()

Dim tbl_rueck As String

    tbl_rueck = "ztbl_Rueckmeldezeiten"
    CurrentDb.Execute "DELETE * FROM " & tbl_rueck
    
End Sub


Private Sub Form_Load()

Call Rückmeldeauswertung

End Sub
