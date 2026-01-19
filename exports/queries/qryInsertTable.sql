-- Query: qryInsertTable
-- Type: 64
INSERT INTO tbl_Info_Tabellen ( ObjName )
SELECT qrymdbTable2.ObjName
FROM qrymdbTable2;

