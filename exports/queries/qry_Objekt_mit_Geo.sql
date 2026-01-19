-- Query: qry_Objekt_mit_Geo
-- Type: 0
SELECT O.ID, O.Objekt AS ObjektName, G.Strasse, G.PLZ, G.Ort, G.Land, G.Lat, G.Lon
FROM tbl_OB_Objekt AS O LEFT JOIN tbl_OB_Geo AS G ON G.Objekt_ID = O.ID;

