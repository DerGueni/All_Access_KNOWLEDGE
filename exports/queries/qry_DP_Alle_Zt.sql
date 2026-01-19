-- Query: qry_DP_Alle_Zt
-- Type: 0
SELECT qry_DP_Alle_Obj.*
FROM qry_DP_Alle_Obj
WHERE (((VADatum) Between #2026-01-16# AND #2026-01-22#))
ORDER BY VADatum, ObjOrt, Pos_Nr;

