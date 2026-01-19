-- Query: qry_Excel_Zeitkonto_Zusatzkosten
-- Type: 0
SELECT 'Achtzehn Carola' AS Name, qry_MonZus6.Aktdat AS VADatum, Day(Aktdat) AS Tag, qry_MonZus6.X34a_RZ AS Rückzahlung_34a, qry_MonZus6.Abschlag, qry_MonZus6.Nicht_Erscheinen AS Abwesend, qry_MonZus6.Kaution, qry_MonZus6.Dienstkleidung, qry_MonZus6.Sonst_Abzuege, qry_MonZus6.Sonst_Abzuege_Grund, qry_MonZus6.Monatslohn AS MA_Auszahlung, qry_MonZus6.UeberwVon AS von
FROM qry_MonZus6
ORDER BY qry_MonZus6.Aktdat;

