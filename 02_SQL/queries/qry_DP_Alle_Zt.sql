SELECT qry_DP_Alle_Obj.*
FROM qry_DP_Alle_Obj
WHERE (((VADatum) Between #2025-11-25# AND #2025-12-01#))
ORDER BY VADatum, ObjOrt, Pos_Nr;

