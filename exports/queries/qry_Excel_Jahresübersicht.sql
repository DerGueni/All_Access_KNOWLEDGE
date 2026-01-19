-- Query: qry_Excel_Jahresübersicht
-- Type: 0
SELECT 'Göschelbauer Thomas' AS Name, *
FROM qry_XL_Jahr
WHERE (((qry_XL_Jahr.AktJahr)=2015) And ((qry_XL_Jahr.MA_ID)=15))
ORDER BY qry_XL_Jahr.AktMon;

