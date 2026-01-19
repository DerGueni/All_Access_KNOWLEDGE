-- Query: qry_tmp_Anz_MA_VA_AnzTage_7_Zu_wennGleich
-- Type: 48
UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Offen = False
WHERE ((([TVA_Soll]-[TVA_Ist])<=0) AND ((tbl_VA_AnzTage.TVA_Soll)>0));

