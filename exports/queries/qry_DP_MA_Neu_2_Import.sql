-- Query: qry_DP_MA_Neu_2_Import
-- Type: 64
INSERT INTO tbltmp_DP_MA_Neu_1
SELECT qry_DP_MA_Neu_2.*
FROM qry_DP_MA_Neu_2;

