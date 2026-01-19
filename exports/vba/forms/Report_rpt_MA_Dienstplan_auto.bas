VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_MA_Dienstplan_auto"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit



Private Sub Report_Open(Cancel As Integer)

Dim MA_ID As String
Dim sql As String
Dim WHERE As String

    MA_ID = Get_Priv_Property("prp_MA_ID_DP") 'MA_ID für Zusagemail
    sql = "SELECT * FROM qry_Dienstplan "
    WHERE = "VADatum >= " & datumSQL(Left(Now, 10)) & " AND MA_ID = " & MA_ID & " ORDER BY VADatum, Beginn"
    
    If IsNumeric(TLookup("MA_ID", "qry_Dienstplan", WHERE)) Then
        Me.recordSource = sql & " WHERE " & WHERE
    Else
        Cancel = True
    End If

End Sub
