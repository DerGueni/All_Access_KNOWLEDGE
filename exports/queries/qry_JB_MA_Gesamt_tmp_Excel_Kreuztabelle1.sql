-- Query: qry_JB_MA_Gesamt_tmp_Excel_Kreuztabelle1
-- Type: 16
TRANSFORM Sum(qry_JB_MA_Gesamt_tmp_Excel.IstGes) AS SummevonIstGes
SELECT qry_JB_MA_Gesamt_tmp_Excel.Nachname, qry_JB_MA_Gesamt_tmp_Excel.Vorname, Sum(qry_JB_MA_Gesamt_tmp_Excel.IstGes) AS [Gesamtsumme von IstGes]
FROM qry_JB_MA_Gesamt_tmp_Excel
GROUP BY qry_JB_MA_Gesamt_tmp_Excel.Nachname, qry_JB_MA_Gesamt_tmp_Excel.Vorname
PIVOT qry_JB_MA_Gesamt_tmp_Excel.AktMon;

