-- Query: qrymdb_Anzahl_Objekte
-- Type: 0
SELECT [_int_tblObjektNamen].Art, Count([_int_tblObjektNamen].ID) AS AnzahlvonID
FROM _int_tblObjektNamen
GROUP BY [_int_tblObjektNamen].Art;

