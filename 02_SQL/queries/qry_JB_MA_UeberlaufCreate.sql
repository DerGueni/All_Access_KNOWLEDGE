INSERT INTO tbl_MA_UeberlaufStunden ( MA_ID, AktJahr )
SELECT tbl_MA_Mitarbeiterstamm.ID, tbltmp_Neuberech_Fuer.AktJ
FROM tbltmp_Neuberech_Fuer, tbl_MA_Mitarbeiterstamm;

