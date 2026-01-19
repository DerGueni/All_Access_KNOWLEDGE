-- Query: qry_Anz_MA_Hour
-- Type: 0
SELECT qry_Anz_Plan_1_2_MA.VA_ID, qry_Anz_Plan_1_2_MA.VADatum_ID, qry_Anz_Plan_1_2_MA.VAStart_ID, qry_Anz_Plan_1_2_MA.VA_Start, qry_Anz_Plan_1_2_MA.VA_Ende, qry_Anz_Plan_1_2_MA.MA_Plan, qry_Anz_Plan_1_2_MA.MA_Soll, [qry:Anz_Ist_MA].MA_Ist
FROM [qry:Anz_Ist_MA] RIGHT JOIN qry_Anz_Plan_1_2_MA ON ([qry:Anz_Ist_MA].VAStart_ID = qry_Anz_Plan_1_2_MA.VAStart_ID) AND ([qry:Anz_Ist_MA].VADatum_ID = qry_Anz_Plan_1_2_MA.VADatum_ID) AND ([qry:Anz_Ist_MA].VA_ID = qry_Anz_Plan_1_2_MA.VA_ID)
GROUP BY qry_Anz_Plan_1_2_MA.VA_ID, qry_Anz_Plan_1_2_MA.VADatum_ID, qry_Anz_Plan_1_2_MA.VAStart_ID, qry_Anz_Plan_1_2_MA.VA_Start, qry_Anz_Plan_1_2_MA.VA_Ende, qry_Anz_Plan_1_2_MA.MA_Plan, qry_Anz_Plan_1_2_MA.MA_Soll, [qry:Anz_Ist_MA].MA_Ist;

