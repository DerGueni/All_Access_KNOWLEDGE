Public Sub AutoLinkGeoTables()
    Dim tdf As DAO.TableDef
    Dim backendPath As String
    backendPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb"
    
    On Error Resume Next
    CurrentDb.TableDefs.Delete "tbl_OB_Geo"
    CurrentDb.TableDefs.Delete "tbl_MA_Geo"
    CurrentDb.TableDefs.Delete "tbl_MA_Objekt_Entfernung"
    Err.clear
    On Error GoTo 0
    
    Set tdf = CurrentDb.CreateTableDef("tbl_OB_Geo")
    tdf.Connect = ";DATABASE=" & backendPath
    tdf.SourceTableName = "tbl_OB_Geo"
    CurrentDb.TableDefs.append tdf
    
    Set tdf = CurrentDb.CreateTableDef("tbl_MA_Geo")
    tdf.Connect = ";DATABASE=" & backendPath
    tdf.SourceTableName = "tbl_MA_Geo"
    CurrentDb.TableDefs.append tdf
    
    Set tdf = CurrentDb.CreateTableDef("tbl_MA_Objekt_Entfernung")
    tdf.Connect = ";DATABASE=" & backendPath
    tdf.SourceTableName = "tbl_MA_Objekt_Entfernung"
    CurrentDb.TableDefs.append tdf
    
    CurrentDb.TableDefs.Refresh
End Sub