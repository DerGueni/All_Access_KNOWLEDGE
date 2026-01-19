VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_MA_Offene_Anfragen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

'Selektierte Datensätze erneut anfragen
Private Sub btnAnfragen_Click()

Dim sfm As Form
Dim rst As DAO.Recordset
Dim i As Integer
Dim intSelHeight As Integer
Dim intSelTop As Integer
Dim rc As String

    rc = ""
    intSelHeight = Me.txSelHeightSub
    intSelTop = Me.sub_MA_Offene_Anfragen.Form.SelTop
        
    Set sfm = Me.sub_MA_Offene_Anfragen.Form
    Set rst = sfm.RecordsetClone
    For i = intSelTop - 1 To intSelTop + intSelHeight - 2
        rst.AbsolutePosition = i
        
       'Mitarbeiter einzeln anfragen
       rc = rc & rst.fields("Name") & ": " & _
        Anfragen(rst.fields("MA_ID"), rst.fields("VA_ID"), rst.fields("VADatum_ID"), rst.fields("VAStart_ID")) & vbCrLf
        
    Next i
    
    MsgBox rc
    
    rst.Close
    Set rst = Nothing
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

End Sub



