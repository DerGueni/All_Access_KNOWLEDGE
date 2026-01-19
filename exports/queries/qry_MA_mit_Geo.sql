-- Query: qry_MA_mit_Geo
-- Type: 0
SELECT M.ID, M.Nachname, M.Vorname, G.Strasse, G.PLZ, G.Ort, G.Land, G.Lat, G.Lon
FROM tbl_MA_Mitarbeiterstamm AS M LEFT JOIN tbl_MA_Geo AS G ON G.MA_ID = M.ID;

