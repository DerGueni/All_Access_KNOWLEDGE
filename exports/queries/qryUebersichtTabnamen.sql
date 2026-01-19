-- Query: qryUebersichtTabnamen
-- Type: 0
SELECT qrymdbTable.ObjName AS Tabellename
FROM qrymdbTable
WHERE (((qrymdbTable.ObjName)<>"Acc_tbl_Dest_CL_Leer") AND ((Left([ObjName],15))="Acc_tbl_Dest_CL"));

