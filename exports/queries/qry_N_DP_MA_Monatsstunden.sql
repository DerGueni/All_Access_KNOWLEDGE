-- Query: qry_N_DP_MA_Monatsstunden
-- Type: 0
SELECT p.MA_ID, Sum(Nz(p.MA_Netto_Std,0)) AS MonatStd
FROM tbl_MA_VA_Planung AS p
WHERE Month(p.VADatum) = Month(Date())
  AND Year(p.VADatum) = Year(Date())
GROUP BY p.MA_ID;

