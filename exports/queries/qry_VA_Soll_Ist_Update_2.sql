-- Query: qry_VA_Soll_Ist_Update_2
-- Type: 48
UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Ist = 0
WHERE (((tbl_VA_AnzTage.TVA_Ist) Is Null));

