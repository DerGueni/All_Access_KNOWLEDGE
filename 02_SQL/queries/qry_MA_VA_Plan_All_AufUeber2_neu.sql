SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt, ([MA_Start]) AS Beginn, ([MA_Ende]) AS Ende, "Zuo" AS IstPL, tbl_MA_VA_Zuordnung.ID AS Plan_ID, tbl_MA_VA_Zuordnung.PKW, ([ma_brutto_std2]) AS MA_Brutto_Std, ([MA_NETTO_STD2]) AS MA_Netto_Std
FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID
WHERE (((tbl_MA_VA_Zuordnung.VA_ID)>0) AND ((tbl_MA_VA_Zuordnung.MA_ID)>0) AND ((tbl_MA_VA_Zuordnung.VADatum_ID)>0));

