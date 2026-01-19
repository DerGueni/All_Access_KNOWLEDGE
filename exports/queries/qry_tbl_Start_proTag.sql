-- Query: qry_tbl_Start_proTag
-- Type: 0
SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID
FROM tbl_VA_Start
GROUP BY tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID;

