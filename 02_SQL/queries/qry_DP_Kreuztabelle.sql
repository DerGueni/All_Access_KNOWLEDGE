TRANSFORM First([qry_DP_Alle_Zt].ZuordID) AS ErsterWertvonZuordID
SELECT [qry_DP_Alle_Zt].ObjOrt, [qry_DP_Alle_Zt].Pos_Nr
FROM qry_DP_Alle_Zt
GROUP BY [qry_DP_Alle_Zt].ObjOrt, [qry_DP_Alle_Zt].Pos_Nr
PIVOT Format([VADatum], 'Short Date') IN ('25.11.2025','26.11.2025', '27.11.2025', '28.11.2025', '29.11.2025', '30.11.2025', '01.12.2025');

