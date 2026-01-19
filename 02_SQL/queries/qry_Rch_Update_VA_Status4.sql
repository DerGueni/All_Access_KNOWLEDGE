UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Veranst_Status_ID = 4
WHERE (((tbl_VA_Auftragstamm.ID)=Get_Priv_Property("prp_Akt_Rch_VA_ID")));

