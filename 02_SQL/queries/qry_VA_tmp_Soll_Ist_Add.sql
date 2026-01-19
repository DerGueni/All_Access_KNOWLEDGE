INSERT INTO tbltmp_VA_Soll_Ist ( VA_ID, VADatum, Soll, Ist )
SELECT qry_VA_MA_Soll.VA_ID, qry_VA_MA_Soll.VADatum, qry_VA_MA_Soll.Soll, qry_VA_MA_Ist.[Ist]
FROM qry_VA_MA_Ist INNER JOIN qry_VA_MA_Soll ON (qry_VA_MA_Soll.VADatum = qry_VA_MA_Ist.VADatum) AND (qry_VA_MA_Ist.VA_ID = qry_VA_MA_Soll.VA_ID);

