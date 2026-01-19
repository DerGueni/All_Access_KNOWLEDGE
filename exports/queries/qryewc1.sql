-- Query: qryewc1
-- Type: 64
INSERT INTO tbl_MA_Jahresuebersicht ( MA_ID, AktJahr, AktMon, Brutto_Std, Ist, Fahrtko, RL_34a, RZ_34a, Abschlag, NichtDa, Kaution, Sonstig, SonstFuer, Lohn, LohnVon, IstGes )
SELECT qry_JB_MA_Sum.MA_ID AS Ausdr1, qry_JB_MA_Sum.AktJahr AS Ausdr2, qry_JB_MA_Sum.AktMonat AS Ausdr3, qry_JB_MA_Sum.MA_Brutto_Std AS Ausdr4, qry_JB_MA_Sum.MA_Netto_Std AS Ausdr5, qry_JB_MA_Sum.Fahrtkost AS Ausdr6, qry_JB_MA_Sum.RL_34a AS Ausdr7, qry_JB_MA_Sum.RZ_34a AS Ausdr8, qry_JB_MA_Sum.Abschlag AS Ausdr9, qry_JB_MA_Sum.NichtDa AS Ausdr10, qry_JB_MA_Sum.Kaution AS Ausdr11, qry_JB_MA_Sum.Sonst_Abzuege AS Ausdr12, qry_JB_MA_Sum.Sonst_Abzuege_Grund AS Ausdr13, qry_JB_MA_Sum.Monatslohn AS Ausdr14, qry_JB_MA_Sum.Ueberw_von AS Ausdr15, qry_JB_MA_Sum.MA_Netto_Std AS Ausdr16
FROM qry_JB_MA_Sum;

