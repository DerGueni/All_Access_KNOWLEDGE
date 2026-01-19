-- Query: Qry_MA_Ohne_PersNr
-- Type: 0
SELECT tbl_XL_Auftrag_Einsatz.GName AS Ausdr1, tbl_XL_Auftrag_Einsatz.PersNr AS Ausdr2
FROM tbl_XL_Auftrag_Einsatz
GROUP BY tbl_XL_Auftrag_Einsatz.GName, tbl_XL_Auftrag_Einsatz.PersNr
HAVING ((([tbl_XL_Auftrag_Einsatz].[PersNr]) Is Null));

