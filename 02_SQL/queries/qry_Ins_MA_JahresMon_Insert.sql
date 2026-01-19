INSERT INTO tbl_MA_Jahresuebersicht ( MA_ID, AktJahr, Mon, Ist, Fahrtko, RL_34a, RZ_34a, Abschlag, NichtDa, Sonstig, Lohn, LohnVon )
SELECT qry_Ins_MA_JahrMonGrp_Sum.MA_ID, qry_Ins_MA_JahrMonGrp_Sum.AktJahr, qry_Ins_MA_JahrMonGrp_Sum.AktMon, qry_Ins_MA_JahrMonGrp_Sum.Netto_Std, qry_Ins_MA_JahrMonGrp_Sum.Fahrtko, qry_Ins_MA_JahrMonGrp_Sum.RL_34a, qry_Ins_MA_JahrMonGrp_Sum.[34a_RZ], qry_Ins_MA_JahrMonGrp_Sum.Abschlag, qry_Ins_MA_JahrMonGrp_Sum.Nicht_Erscheinen, qry_Ins_MA_JahrMonGrp_Sum.Sonst_Abzuege, qry_Ins_MA_JahrMonGrp_Sum.Monatslohn, qry_Ins_MA_JahrMonGrp_Sum.UeberwVon
FROM qry_Ins_MA_JahrMonGrp_Sum;

