-- Query: qry_VA_Akt_Objekt_Pos_Ohne
-- Type: 0
SELECT tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID, tbl_VA_Akt_Objekt_Pos.ID AS VA_Akt_Objekt_Pos_ID, tbl_VA_Akt_Objekt_Pos.Anzahl
FROM tbl_VA_Akt_Objekt_Pos
WHERE (((tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID)=Get_Priv_Property("prp_VA_Akt_Objekt_ID")) AND ((tbl_VA_Akt_Objekt_Pos.Anzahl)>0))
ORDER BY tbl_VA_Akt_Objekt_Pos.Sort;

