-- Query: qry_DP_Kreuztabelle
-- Type: 16
TRANSFORM First([qry_DP_Alle_Zt].ZuordID) AS ErsterWertvonZuordID
SELECT [qry_DP_Alle_Zt].ObjOrt, [qry_DP_Alle_Zt].Pos_Nr
FROM qry_DP_Alle_Zt
GROUP BY [qry_DP_Alle_Zt].ObjOrt, [qry_DP_Alle_Zt].Pos_Nr
PIVOT Format([VADatum], 'Short Date') IN ('16.01.2026','17.01.2026', '18.01.2026', '19.01.2026', '20.01.2026', '21.01.2026', '22.01.2026');

