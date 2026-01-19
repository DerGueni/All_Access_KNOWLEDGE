-- Query: qry_Echtzeit_MA_VA_Union
-- Type: 128
SELECT qry_Echtzeit_MA_VA_Zuordnung.* FROM qry_Echtzeit_MA_VA_Zuordnung UNION
SELECT qry_Echtzeit_MA_VA_Planung.* FROM qry_Echtzeit_MA_VA_Planung  
UNION SELECT qry_Echtzeit_MA_VA_NVerfueg.* FROM qry_Echtzeit_MA_VA_NVerfueg;

