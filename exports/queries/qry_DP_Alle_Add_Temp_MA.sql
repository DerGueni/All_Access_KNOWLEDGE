-- Query: qry_DP_Alle_Add_Temp_MA
-- Type: 64
INSERT INTO tbltmp_DP_Grund_Sort_MA ( MA_ID, MAName, MaxvonTag1_Zuo_ID, MaxvonTag2_Zuo_ID, MaxvonTag3_Zuo_ID, MaxvonTag4_Zuo_ID, MaxvonTag5_Zuo_ID, MaxvonTag6_Zuo_ID, MaxvonTag7_Zuo_ID )
SELECT tbltmp_DP_MA_Grund.MA_ID, tbltmp_DP_MA_Grund.MAName, Max(tbltmp_DP_MA_Grund.Tag1_Zuo_ID) AS MaxvonTag1_Zuo_ID, Max(tbltmp_DP_MA_Grund.Tag2_Zuo_ID) AS MaxvonTag2_Zuo_ID, Max(tbltmp_DP_MA_Grund.Tag3_Zuo_ID) AS MaxvonTag3_Zuo_ID, Max(tbltmp_DP_MA_Grund.Tag4_Zuo_ID) AS MaxvonTag4_Zuo_ID, Max(tbltmp_DP_MA_Grund.Tag5_Zuo_ID) AS MaxvonTag5_Zuo_ID, Max(tbltmp_DP_MA_Grund.Tag6_Zuo_ID) AS MaxvonTag6_Zuo_ID, Max(tbltmp_DP_MA_Grund.Tag7_Zuo_ID) AS MaxvonTag7_Zuo_ID
FROM tbltmp_DP_MA_Grund
GROUP BY tbltmp_DP_MA_Grund.MA_ID, tbltmp_DP_MA_Grund.MAName
HAVING (((tbltmp_DP_MA_Grund.MA_ID)>0))
ORDER BY Max(tbltmp_DP_MA_Grund.Tag1_Zuo_ID) DESC , Max(tbltmp_DP_MA_Grund.Tag2_Zuo_ID) DESC , Max(tbltmp_DP_MA_Grund.Tag3_Zuo_ID) DESC , Max(tbltmp_DP_MA_Grund.Tag4_Zuo_ID) DESC , Max(tbltmp_DP_MA_Grund.Tag5_Zuo_ID) DESC , Max(tbltmp_DP_MA_Grund.Tag6_Zuo_ID) DESC , Max(tbltmp_DP_MA_Grund.Tag7_Zuo_ID) DESC;

