INSERT INTO tbltmp_MA_Tageszusatzwerte ( MA_ID, AktDat, X34a_RZ, Abschlag, Nicht_Erscheinen, Kaution, Dienstkleidung, Sonst_Abzuege, Sonst_Abzuege_Grund, Monatslohn, UeberwVon, Bemerkungen, Erst_von, Erst_am, Aend_von, Aend_am )
SELECT qry_MonZus2.MA_ID, qry_MonZus2.AktDat, qry_MonZus2.[34a_RZ], qry_MonZus2.Abschlag, qry_MonZus2.Nicht_Erscheinen, qry_MonZus2.Kaution, qry_MonZus2.Dienstkleidung, qry_MonZus2.Sonst_Abzuege, qry_MonZus2.Sonst_Abzuege_Grund, qry_MonZus2.Monatslohn, qry_MonZus2.UeberwVon, qry_MonZus2.Bemerkungen, qry_MonZus2.Erst_von, qry_MonZus2.Erst_am, qry_MonZus2.Aend_von, qry_MonZus2.Aend_am
FROM qry_MonZus2;

