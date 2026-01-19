SELECT tbl_Textbaustein_Herkunft.ID, "[" & [TB_Name] & "]" AS Feldname, tbl_Textbaustein_Namen.Bemerkung, tbl_Textbaustein_Herkunft.Beschreibung
FROM tbl_Textbaustein_Namen INNER JOIN tbl_Textbaustein_Herkunft ON tbl_Textbaustein_Namen.Herkunft_ID = tbl_Textbaustein_Herkunft.ID
ORDER BY tbl_Textbaustein_Namen.Herkunft_ID, tbl_Textbaustein_Namen.ID;

