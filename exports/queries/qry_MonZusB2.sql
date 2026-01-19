-- Query: qry_MonZusB2
-- Type: 0
SELECT 0 AS ID, qry_MonZusB1.VADatum, 0 AS VA_ID, qry_MonZusB1.MA_ID, CStr([Zeittyp]) AS Auftrag_Ort
FROM tbl_MA_Zeittyp INNER JOIN qry_MonZusB1 ON tbl_MA_Zeittyp.Kuerzel_Datev = qry_MonZusB1.Zeittyp_ID
WHERE (((qry_MonZusB1.MA_ID)=CLng(Get_Priv_Property("prp_Akt_MA_ID"))) AND ((qry_MonZusB1.iMonat)=CLng(Get_Priv_Property("prp_AktMonUeb_Monat"))) AND ((qry_MonZusB1.iJahr)=CLng(Get_Priv_Property("prp_AktMonUeb_Jahr"))));

