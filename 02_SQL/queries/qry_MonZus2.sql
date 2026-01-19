SELECT qry_MonZus1a.MA_ID, qry_MonZus1.dtDatum AS AktDat, qry_MonZus1a.[34a_RZ], qry_MonZus1a.Abschlag, qry_MonZus1a.Nicht_Erscheinen, qry_MonZus1a.Kaution, qry_MonZus1a.Dienstkleidung, qry_MonZus1a.Sonst_Abzuege, qry_MonZus1a.Sonst_Abzuege_Grund, qry_MonZus1a.Monatslohn, qry_MonZus1a.UeberwVon, qry_MonZus1a.Bemerkungen, qry_MonZus1a.Erst_von, qry_MonZus1a.Erst_am, qry_MonZus1a.Aend_von, qry_MonZus1a.Aend_am
FROM qry_MonZus1a RIGHT JOIN qry_MonZus1 ON qry_MonZus1a.AktDat = qry_MonZus1.dtDatum;

