SELECT [_tbl_Qry_Flags].QueryTyp, MSysObjects.Name
FROM MSysObjects LEFT JOIN _tbl_Qry_Flags ON MSysObjects.Flags = [_tbl_Qry_Flags].Flags
WHERE (((MSysObjects.Flags)<>3) AND ((MSysObjects.Type)=5))
ORDER BY [_tbl_Qry_Flags].QueryTyp, MSysObjects.Name;

