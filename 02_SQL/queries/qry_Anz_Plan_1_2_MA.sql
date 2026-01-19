SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, tbl_VA_Start.ID AS VAStart_ID, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, Count(qry_MA_Plan.MA_ID) AS MA_Plan, tbl_VA_Start.MA_Anzahl AS MA_Soll
FROM qry_MA_Plan RIGHT JOIN tbl_VA_Start ON qry_MA_Plan.VAStart_ID = tbl_VA_Start.ID
GROUP BY tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, tbl_VA_Start.ID, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, tbl_VA_Start.MA_Anzahl;

