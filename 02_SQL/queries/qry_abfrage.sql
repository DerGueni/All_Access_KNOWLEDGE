SELECT tbl_MA_VA_Zuordnung.RL_34a, tbl_MA_VA_Zuordnung.*, tbl_MA_Mitarbeiterstamm.*, tbl_VA_Auftragstamm.*
FROM (tbl_MA_VA_Zuordnung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) INNER JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID;

