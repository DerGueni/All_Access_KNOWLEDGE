-- Query: qry_tmp_Create_PosNr_Teil1
-- Type: 80
SELECT tbl_VA_Start.VADatum, tbl_VA_Start.VA_ID, tbl_VA_Start.ID AS VA_Start_ID, tbl_VA_Start.VADatum_ID, [_tblAlleTage].LfdNr AS LfdNr_Start, tbl_VA_AnzTage.TVA_Soll AS MaxPos, 0 AS PosNr INTO tbltmp_PosNr_create
FROM _tblAlleTage, tbl_VA_AnzTage INNER JOIN tbl_VA_Start ON tbl_VA_AnzTage.ID = tbl_VA_Start.VADatum_ID
WHERE ((([_tblAlleTage].LfdNr)<=[MA_Anzahl] And ([_tblAlleTage].LfdNr)>0))
ORDER BY tbl_VA_Start.VADatum, tbl_VA_Start.VA_ID, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, [_tblAlleTage].LfdNr;

