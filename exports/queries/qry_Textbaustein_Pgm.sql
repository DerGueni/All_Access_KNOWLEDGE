-- Query: qry_Textbaustein_Pgm
-- Type: 0
SELECT tbl_Textbaustein_Herkunft.Herkunftsname, "[" & [TB_Name] & "]" AS TextBausteinName, tbl_Textbaustein_Namen.Feldname, tbl_Textbaustein_Namen.Feldtyp, tbl_Textbaustein_Typen.Todo, tbl_Textbaustein_Typen.Bemerkung AS ToDo_Info, tbl_Textbaustein_Herkunft.P1, tbl_Textbaustein_Herkunft.P2, tbl_Textbaustein_Herkunft.P3, tbl_Textbaustein_Namen.Herkunft_ID, tbl_Textbaustein_Herkunft.P1Typ, tbl_Textbaustein_Herkunft.P2Typ, tbl_Textbaustein_Herkunft.P3Typ
FROM tbl_Textbaustein_Herkunft INNER JOIN (tbl_Textbaustein_Namen INNER JOIN tbl_Textbaustein_Typen ON tbl_Textbaustein_Namen.Feldtyp = tbl_Textbaustein_Typen.Feldtyp) ON tbl_Textbaustein_Herkunft.ID = tbl_Textbaustein_Namen.Herkunft_ID
ORDER BY tbl_Textbaustein_Namen.Herkunft_ID, tbl_Textbaustein_Namen.ID;

