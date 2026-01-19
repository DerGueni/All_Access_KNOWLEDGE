-- Query: qry_EchtNeu_UnionSP_ohneSub
-- Type: 0
SELECT qry_EchtNeu_UnionSp.*
FROM tbl_MA_Mitarbeiterstamm INNER JOIN qry_EchtNeu_UnionSp ON tbl_MA_Mitarbeiterstamm.ID = qry_EchtNeu_UnionSp.MA_ID
WHERE (((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)<>11)) OR (((tbl_MA_Mitarbeiterstamm.IstSubunternehmer)=False));

