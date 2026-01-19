-- Query: qry_MA_Maintainance_UPd_Tl4_Offen
-- Type: 48
UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Offen = False
WHERE (((Nz([TVA_Soll],0)-Nz([TVA_Ist],0))<=0) AND ((Nz([TVA_Soll],0))>0) AND ((Nz([TVA_Ist],0))>0));

