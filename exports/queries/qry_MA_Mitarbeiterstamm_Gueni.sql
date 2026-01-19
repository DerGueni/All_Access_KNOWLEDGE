-- Query: qry_MA_Mitarbeiterstamm_Gueni
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.LEXWare_ID, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_Mitarbeiterstamm.Strasse, tbl_MA_Mitarbeiterstamm.Nr, tbl_MA_Mitarbeiterstamm.PLZ, tbl_MA_Mitarbeiterstamm.Ort, tbl_MA_Mitarbeiterstamm.Geschlecht, tbl_MA_Mitarbeiterstamm.Tel_Mobil, tbl_MA_Mitarbeiterstamm.Email, tbl_MA_Mitarbeiterstamm.Staatsang, tbl_MA_Mitarbeiterstamm.Geb_Dat, tbl_MA_Mitarbeiterstamm.Geb_Ort, tbl_MA_Mitarbeiterstamm.Geb_Name, tbl_MA_Mitarbeiterstamm.Bewacher_ID
FROM tbl_MA_Mitarbeiterstamm
WHERE (((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3 Or (tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=5))
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname;

