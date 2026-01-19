-- Query: qry_JB_MA_Gesamt_tmp_Excel_Kreuztabelle
-- Type: 16
TRANSFORM Count(qry_JB_MA_Gesamt_tmp_Excel.MA_ID) AS AnzahlvonMA_ID
SELECT qry_JB_MA_Gesamt_tmp_Excel.Nachname, qry_JB_MA_Gesamt_tmp_Excel.Vorname, Count(qry_JB_MA_Gesamt_tmp_Excel.MA_ID) AS [Gesamtsumme von MA_ID]
FROM qry_JB_MA_Gesamt_tmp_Excel
GROUP BY qry_JB_MA_Gesamt_tmp_Excel.Nachname, qry_JB_MA_Gesamt_tmp_Excel.Vorname
PIVOT qry_JB_MA_Gesamt_tmp_Excel.AktMon;

