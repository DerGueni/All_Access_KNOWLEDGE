-- Query: qry_Zeitabfrage_Gemischt
-- Type: 128
SELECT * FROM  qry_Zeitabfrage_Planung
UNION SELECT * FROM  qry_Zeitabfrage_Zuordnung;

