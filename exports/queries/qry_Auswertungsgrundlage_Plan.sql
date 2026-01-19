-- Query: qry_Auswertungsgrundlage_Plan
-- Type: 0
SELECT tbl_VA_Auftragstamm.Veranstalter_ID AS kun_id, tbl_KD_Kundenstamm.kun_Firma, tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Dummy, tbl_VA_Start.MA_Anzahl, tbl_VA_AnzTage.VADatum, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, timeberech_G([tbl_VA_Start].[VADatum],[VA_Start],[VA_Ende]) AS Plan_Std_Brutto, Nz(timeberech_G(tbl_VA_Start.VADatum,[VA_Start],[VA_Ende]),0)*Nz([Dummy],0)*Nz([MA_Anzahl],0) AS Plan_Umsatz_pro_Zeitraum
FROM (tbl_KD_Kundenstamm RIGHT JOIN tbl_VA_Auftragstamm ON tbl_KD_Kundenstamm.kun_Id = tbl_VA_Auftragstamm.Veranstalter_ID) LEFT JOIN (tbl_VA_AnzTage LEFT JOIN tbl_VA_Start ON tbl_VA_AnzTage.ID = tbl_VA_Start.VADatum_ID) ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
ORDER BY tbl_VA_AnzTage.VADatum DESC , tbl_VA_Start.VA_Start, tbl_VA_Auftragstamm.Dat_VA_Von DESC , tbl_VA_Auftragstamm.Dat_VA_Bis DESC , tbl_VA_Auftragstamm.Auftrag;

