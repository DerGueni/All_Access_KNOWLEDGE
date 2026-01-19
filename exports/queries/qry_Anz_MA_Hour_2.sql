-- Query: qry_Anz_MA_Hour_2
-- Type: 0
SELECT qry_Anz_Plan_1_2_MA.VA_ID, qry_Anz_Plan_1_2_MA.VADatum_ID, qry_Anz_Plan_1_2_MA.VAStart_ID, tbl_VA_AnzTage.VADatum, Left([Va_start],5) & " - " & Left([va_Ende],5) & " Uhr  |   " & Nz([Ma_Ist],0) & " / " & Nz([MA_Soll],0) AS VA_ID_TXT, Nz([MA_Soll],0)-Nz([MA_Ist],0) AS MA_Diff
FROM tbl_VA_AnzTage RIGHT JOIN ([qry:Anz_Ist_MA] RIGHT JOIN qry_Anz_Plan_1_2_MA ON ([qry:Anz_Ist_MA].VAStart_ID = qry_Anz_Plan_1_2_MA.VAStart_ID) AND ([qry:Anz_Ist_MA].VADatum_ID = qry_Anz_Plan_1_2_MA.VADatum_ID) AND ([qry:Anz_Ist_MA].VA_ID = qry_Anz_Plan_1_2_MA.VA_ID)) ON (tbl_VA_AnzTage.VA_ID = qry_Anz_Plan_1_2_MA.VA_ID) AND (tbl_VA_AnzTage.ID = qry_Anz_Plan_1_2_MA.VADatum_ID);

