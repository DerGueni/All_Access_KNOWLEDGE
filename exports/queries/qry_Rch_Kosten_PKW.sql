-- Query: qry_Rch_Kosten_PKW
-- Type: 0
SELECT tbl_VA_Preise.*
FROM tbl_VA_Preise
WHERE (((tbl_VA_Preise.kun_ID)=Get_Priv_Property("prp_Rechnung_AktKunde")) And ((tbl_VA_Preise.Kostenart_ID)=1) And ((tbl_VA_Preise.Kostenzuo_KD)=4));

