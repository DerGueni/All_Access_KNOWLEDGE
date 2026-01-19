-- Query: qry_XL_Start_Add
-- Type: 0
SELECT tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID, tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum, tblZZZ_XL_Auftrag_MA_Einsatz.Beginn, Min(tblZZZ_XL_Auftrag_MA_Einsatz.Ende) AS MinvonEnde, Max(tblZZZ_XL_Auftrag_MA_Einsatz.Ende) AS MaxvonEnde, Count(tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID) AS Anz_MA
FROM tblZZZ_XL_Auftrag_MA_Einsatz
GROUP BY tblZZZ_XL_Auftrag_MA_Einsatz.VA_ID, tblZZZ_XL_Auftrag_MA_Einsatz.VA_Datum, tblZZZ_XL_Auftrag_MA_Einsatz.Beginn;

