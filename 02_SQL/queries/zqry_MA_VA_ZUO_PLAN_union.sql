SELECT ID, VA_ID, MA_ID, MA_Start, MA_Ende, MA_Brutto_Std2, VADatum, Bemerkungen
FROM tbl_MA_VA_Zuordnung
UNION SELECT ID, VA_ID, MA_ID, VA_Start AS MA_Start, VA_Ende as MA_Ende, MA_Brutto_Std2, VADatum, Bemerkungen
FROM tbl_MA_VA_Planung
ORDER BY VA_ID, MA_ID;

