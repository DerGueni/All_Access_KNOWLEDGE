-- Query: qry_VA_AnzTage_Soll_Add
-- Type: 64
INSERT INTO tbl_VA_AnzTage ( VA_ID, TVA_Soll, VADatum )
SELECT qry_VA_MA_Soll.VA_ID, qry_VA_MA_Soll.Soll, qry_VA_MA_Soll.VADatum
FROM qry_VA_MA_Soll;

