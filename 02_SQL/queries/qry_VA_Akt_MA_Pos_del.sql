DELETE tbl_VA_Akt_Objekt_Pos_MA.*, tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID
FROM tbl_VA_Akt_Objekt_Pos_MA
WHERE (((tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID)=Get_Priv_Property("prp_VA_Akt_Objekt_ID")));

