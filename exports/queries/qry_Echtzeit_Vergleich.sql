-- Query: qry_Echtzeit_Vergleich
-- Type: 0
SELECT tbl_VA_Start.*, tbl_VA_Start.MVA_Start AS VGL_Start, tbl_VA_Start.MVA_Ende AS VGL_Ende
FROM tbl_VA_Start;

