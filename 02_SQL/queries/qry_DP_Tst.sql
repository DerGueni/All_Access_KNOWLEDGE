SELECT qry_DP_Kreuztabelle.ObjOrt, qry_DP_Kreuztabelle.ObjOrt AS OnjOrt_Anzeige, qry_DP_Kreuztabelle.Pos_Nr, qry_DP_Kreuztabelle.[01_12_2015] AS Tag1_Zuo_ID, 0 AS Tag1_MA_ID, "" AS Tag1_Name, False AS Tag1_fraglich, "" AS Tag1_von, "" AS Tag1_bis, qry_DP_Kreuztabelle.[02_12_2015] AS Tag2_Zuo_ID, qry_DP_Kreuztabelle.[03_12_2015] AS Tag3_Zuo_ID, qry_DP_Kreuztabelle.[04_12_2015] AS Tag4_Zuo_ID, qry_DP_Kreuztabelle.[05_12_2015] AS Tag5_Zuo_ID, qry_DP_Kreuztabelle.[06_12_2015] AS Tag6_Zuo_ID, qry_DP_Kreuztabelle.[07_12_2015] AS Tag7_Zuo_ID
FROM qry_DP_Kreuztabelle
ORDER BY qry_DP_Kreuztabelle.ObjOrt, qry_DP_Kreuztabelle.Pos_Nr;

