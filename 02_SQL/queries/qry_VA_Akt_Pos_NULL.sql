SELECT tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID, IsNull([Abs_Beginn]) AS Anf, IsNull([Abs_Ende]) AS Ende
FROM tbl_VA_Akt_Objekt_Pos
WHERE (((tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID)=Get_Priv_Property("prp_VA_Akt_Objekt_ID")) AND ((IsNull([Abs_Beginn]))=True) AND ((IsNull([Abs_Ende]))=True));

