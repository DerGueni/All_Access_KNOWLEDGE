INSERT INTO tbltmp_VA_Tag_Hour_All
SELECT qry_Anz_Ma_Neu_Hour_2.*
FROM qry_Anz_Ma_Neu_Hour_2 INNER JOIN tbltmp_VA_Tag_All ON (qry_Anz_Ma_Neu_Hour_2.VADatum_ID = tbltmp_VA_Tag_All.VADatum_ID) AND (qry_Anz_Ma_Neu_Hour_2.VA_ID = tbltmp_VA_Tag_All.VA_ID);

