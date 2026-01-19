-- Query: qry_DP_MA_Kreuztabelle
-- Type: 16
TRANSFORM First(tbltmp_DP_MA_1.ZuordID) AS ErsterWertvonZuordID
SELECT tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp
FROM tbltmp_DP_MA_1
GROUP BY tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp
ORDER BY tbltmp_DP_MA_1.Hlp
PIVOT Format([VADatum],'Short Date') IN ('14.01.2026','15.01.2026', '16.01.2026', '17.01.2026', '18.01.2026', '19.01.2026', '20.01.2026');

