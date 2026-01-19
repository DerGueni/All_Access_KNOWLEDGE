-- Query: qry_DP_Obj_ab_Heute_ZW
-- Type: 0
SELECT clng(ZuordID) AS Zuo_ID
FROM qry_DP_Alle
WHERE (((qry_DP_Alle.ObjOrt) = 'Palazzo, Nürnberg') And ((qry_DP_Alle.VADatum) >= #2024-10-27#));

