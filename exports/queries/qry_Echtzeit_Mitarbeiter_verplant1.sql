-- Query: qry_Echtzeit_Mitarbeiter_verplant1
-- Type: 0
SELECT qry_Echtzeit_MA_VA_UnionSp.MA_ID, Fix([MVA_Start]) AS VADatum, qry_Echtzeit_MA_VA_UnionSp.MVA_Start, qry_Echtzeit_MA_VA_UnionSp.MVA_Ende, qry_Echtzeit_MA_VA_UnionSp.Grund
FROM qry_Echtzeit_MA_VA_UnionSp;

