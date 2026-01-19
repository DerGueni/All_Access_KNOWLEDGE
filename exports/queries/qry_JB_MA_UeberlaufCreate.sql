-- Query: qry_JB_MA_UeberlaufCreate
-- Type: 64
INSERT INTO tbl_MA_UeberlaufStunden ( MA_ID, AktJahr )
SELECT tbl_MA_Mitarbeiterstamm.ID, tbltmp_Neuberech_Fuer.AktJ
FROM tbltmp_Neuberech_Fuer, tbl_MA_Mitarbeiterstamm;

