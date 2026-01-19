SELECT 'Achtzehn Carola' AS Name, qry_MonZusD.VADatum, Day(VAdatum) AS Tag, qry_MonZusD.Auftrag_Ort, Format([MA_Start],'Short Time') AS Beginn, Format([MA_Ende],'Short Time') AS Ende, Brutto_Std2 AS Ausdr1, qry_MonZusD.Netto_Std2, qry_MonZusD.Fahrtko AS Fahrtkosten, RL34a AS Rücklagen_34a
FROM qry_MonZusD;

