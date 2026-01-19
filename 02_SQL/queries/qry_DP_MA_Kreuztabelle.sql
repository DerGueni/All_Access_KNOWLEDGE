TRANSFORM First(tbltmp_DP_MA_1.ZuordID) AS ErsterWertvonZuordID
SELECT tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp
FROM tbltmp_DP_MA_1
GROUP BY tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp
ORDER BY tbltmp_DP_MA_1.Hlp
PIVOT Format([VADatum],'Short Date') IN ('25.11.2025','26.11.2025', '27.11.2025', '28.11.2025', '29.11.2025', '30.11.2025', '01.12.2025');

