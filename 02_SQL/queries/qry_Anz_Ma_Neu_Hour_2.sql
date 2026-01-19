SELECT qry_Anz_Ma_Neu_Hour_1.VA_ID, qry_Anz_Ma_Neu_Hour_1.VADatum_ID, fZeitAusg([Start],[Ende],[MA_Anzahl_Ist],[MA_Anzahl]) AS Zeit
FROM qry_Anz_Ma_Neu_Hour_1
ORDER BY qry_Anz_Ma_Neu_Hour_1.VADatum_ID, fZeitAusg([Start],[Ende],[MA_Anzahl_Ist],[MA_Anzahl]);

