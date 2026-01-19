-- Query: qry_Anz_MA_Tag
-- Type: 0
SELECT qry_Anz_MA_Tag_1.VA_ID, qry_Anz_MA_Tag_1.VADatum_ID, qry_Anz_MA_Tag_1.VADatum, qry_Anz_MA_Tag_1.Auftrag, qry_Anz_MA_Tag_1.Objekt_Ort, Sum(qry_Anz_MA_Tag_1.MA_Plan_Ges) AS MA_Plan_Ges, Sum(qry_Anz_MA_Tag_1.MA_Soll_Ges) AS MA_Soll_Ges, Sum(qry_Anz_MA_Tag_1.MA_Ist_Ges) AS MA_Ist_Ges, qry_Anz_MA_Tag_1.TVA_Offen
FROM qry_Anz_MA_Tag_1
GROUP BY qry_Anz_MA_Tag_1.VA_ID, qry_Anz_MA_Tag_1.VADatum_ID, qry_Anz_MA_Tag_1.VADatum, qry_Anz_MA_Tag_1.Auftrag, qry_Anz_MA_Tag_1.Objekt_Ort, qry_Anz_MA_Tag_1.TVA_Offen;

