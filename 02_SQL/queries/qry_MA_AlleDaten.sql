SELECT tbl_MA_Mitarbeiterstamm.*, tbl_MA_Sonstiges.Geo_Laenge, tbl_MA_Sonstiges.Geo_Breite, tbl_MA_Sonstiges.Bluemchen, tbl_MA_Sonstiges.Bienchen, tbl_MA_Sonstiges.Bells, tbl_MA_Sonstiges.Whistles, tbl_MA_Sonstiges.Bemerkungen, tbl_MA_Sonstiges.tblBilddatei
FROM tbl_MA_Mitarbeiterstamm LEFT JOIN tbl_MA_Sonstiges ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_Sonstiges.MA_ID;

