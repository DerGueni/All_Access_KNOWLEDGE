SELECT tbl_MA_Mitarbeiterstamm.[nachname] & " " & [Vorname] AS Name, tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_MA_VA_Planung.MVA_Start AS von, tbl_MA_VA_Planung.MVA_Ende AS bis, tbl_MA_VA_Planung.Anfragezeitpunkt, tbl_MA_VA_Planung.Rueckmeldezeitpunkt, tbl_MA_VA_Planung.VA_ID, tbl_MA_VA_Planung.VADatum_ID, tbl_MA_VA_Planung.MA_ID, tbl_MA_VA_Planung.VAStart_ID
FROM (tbl_MA_Mitarbeiterstamm INNER JOIN tbl_MA_VA_Planung ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_VA_Planung.MA_ID) INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Planung.VA_ID = tbl_VA_Auftragstamm.ID
WHERE (((tbl_VA_Auftragstamm.Dat_VA_Von)>Date()) AND ((tbl_MA_VA_Planung.Anfragezeitpunkt)>#1/1/2022#) AND ((tbl_MA_VA_Planung.Rueckmeldezeitpunkt) Is Null))
ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von, tbl_MA_VA_Planung.Anfragezeitpunkt DESC;

