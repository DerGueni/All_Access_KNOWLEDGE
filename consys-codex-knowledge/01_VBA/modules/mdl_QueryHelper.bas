Attribute VB_Name = "mdl_QueryHelper"
Public Function GetQuerySQL(strQueryName As String) As String
    GetQuerySQL = CurrentDb.QueryDefs(strQueryName).sql
End Function

Public Sub SetQuerySQL(strQueryName As String, strSQL As String)
    CurrentDb.QueryDefs(strQueryName).sql = strSQL
End Sub

Public Sub CreateHelperQuery()
    On Error Resume Next
    CurrentDb.QueryDefs.Delete "qry_MA_Zeiten_Helper"
    On Error GoTo 0
    
    Dim qdf As DAO.QueryDef
    Set qdf = CurrentDb.CreateQueryDef("qry_MA_Zeiten_Helper", _
        "SELECT k.ID AS Kopf_ID, z.MA_ID, Format(z.MVA_Start,'hh:nn') AS von, Format(z.MVA_Ende,'hh:nn') AS bis " & _
        "FROM tbl_VA_Akt_Objekt_Kopf AS k INNER JOIN tbl_MA_VA_Zuordnung AS z ON k.VA_ID = z.VA_ID AND k.VADatum_ID = z.VADatum_ID WHERE z.MA_ID > 0")
End Sub

