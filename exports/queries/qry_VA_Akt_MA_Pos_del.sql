-- Query: qry_VA_Akt_MA_Pos_del
-- Type: 32
DELETE tbl_VA_Akt_Objekt_Pos_MA.*, tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID
FROM tbl_VA_Akt_Objekt_Pos_MA
WHERE (((tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID)=Get_Priv_Property("prp_VA_Akt_Objekt_ID")));

