INSERT INTO tbl_MA_Tageszusatzwerte ( MA_ID, AktDat, 34a_RZ, Abschlag, Nicht_Erscheinen, Kaution, Dienstkleidung, Sonst_Abzuege, Sonst_Abzuege_Grund, Monatslohn, UeberwVon, Bemerkungen, Erst_von, Erst_am, Aend_von, Aend_am )
SELECT qry_MonZus7.MA_ID, qry_MonZus7.AktDat, qry_MonZus7.[X34a_RZ] AS Ausdr5, qry_MonZus7.Abschlag, qry_MonZus7.Nicht_Erscheinen, qry_MonZus7.Kaution, qry_MonZus7.Dienstkleidung, qry_MonZus7.Sonst_Abzuege, qry_MonZus7.Sonst_Abzuege_Grund, qry_MonZus7.Monatslohn, qry_MonZus7.UeberwVon, qry_MonZus7.Bemerkungen, atcnames(1) AS Ausdr1, Now() AS Ausdr2, atcnames(1) AS Ausdr3, Now() AS Ausdr4
FROM qry_MonZus7;

