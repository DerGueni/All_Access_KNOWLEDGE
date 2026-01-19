SELECT tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Pos_ID, Count(tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Pos_ID) AS AnzahlvonVA_Akt_Objekt_Pos_ID
FROM tbl_VA_Akt_Objekt_Pos_MA
WHERE (((tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID)=Get_Priv_Property("prp_VA_Akt_Objekt_ID")) AND ((tbl_VA_Akt_Objekt_Pos_MA.MA_ID)>0))
GROUP BY tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Pos_ID;

