-- Query: qry_VA_Soll_Ist
-- Type: 0
SELECT qry_VA_MA_Soll.VA_ID, qry_VA_MA_Soll.VADatum_ID, qry_VA_MA_Soll.VADatum, qry_VA_MA_Soll.Soll, qry_VA_MA_Ist.[Ist]
FROM qry_VA_MA_Soll LEFT JOIN qry_VA_MA_Ist ON (qry_VA_MA_Soll.VADatum_ID = qry_VA_MA_Ist.VADatum_ID) AND (qry_VA_MA_Soll.VA_ID = qry_VA_MA_Ist.VA_ID);

