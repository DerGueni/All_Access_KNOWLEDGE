VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_KD_Standardpreise"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub StdPreis_AfterUpdate()
    Me.Controls("Aenderer") = Environ("UserName")
    Me.Controls("GeaendertAm") = Now
End Sub

Private Sub StdPreis_BeforeUpdate(Cancel As Integer)
Dim sql As String

    sql = "INSERT INTO [ztbl_KD_Standardpreise_Historie] SELECT * FROM [tbl_KD_Standardpreise]" & _
            " WHERE [Kun_ID] = " & Me.kun_ID & " AND [Preisart_ID] = " & Me.PreisArt_ID
            
    CurrentDb.Execute sql
    
End Sub

Private Sub StdPreis_DblClick(Cancel As Integer)

    DoCmd.OpenForm "zfrm_KD_Standardpreise_Historie", acNormal, , "ID = " & Me.ID

End Sub
