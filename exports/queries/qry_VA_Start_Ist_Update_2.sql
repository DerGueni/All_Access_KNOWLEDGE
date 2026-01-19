-- Query: qry_VA_Start_Ist_Update_2
-- Type: 48
UPDATE tbltmp_VAStart_Ist INNER JOIN tbl_VA_Start ON tbltmp_VAStart_Ist.VAStart_ID = tbl_VA_Start.ID SET tbl_VA_Start.MA_Anzahl_Ist = [SummevonIst];

