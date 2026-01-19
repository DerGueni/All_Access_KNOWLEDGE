-- Query: qry_Rch_AktKunde_StandardPreis
-- Type: 0
SELECT tbl_KD_Standardpreise.Preisart_ID, tbl_KD_Standardpreise.StdPreis, tbl_KD_Standardpreise.kun_ID
FROM tbl_KD_Standardpreise
WHERE (((tbl_KD_Standardpreise.kun_ID)=Get_Priv_Property("prp_Rechnung_AktKunde")));

