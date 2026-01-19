-- Query: qry_JB_MA_AktMon_Alle
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, qry_JB_MA_AktMon.AktJahr, qry_JB_MA_AktMon.AktMon
FROM tbl_MA_Mitarbeiterstamm, qry_JB_MA_AktMon
WHERE (((tbl_MA_Mitarbeiterstamm.ID)=279));

