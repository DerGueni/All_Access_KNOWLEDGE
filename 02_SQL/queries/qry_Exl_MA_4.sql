INSERT INTO tbltmp_MA_Monat_Einzel ( VA_ID, MA_ID, AktDat, VAStart_ID )
SELECT qry_Exl_MA_3.VA_ID, qry_Exl_MA_3.MA_ID, qry_Exl_MA_3.VADatum, qry_Exl_MA_3.VAStart_ID
FROM qry_Exl_MA_3;

