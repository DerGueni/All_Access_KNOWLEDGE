-- Query: qry_VA_Start_tmp_Add
-- Type: 64
INSERT INTO tbltmp_VAStart_Ist ( VAStart_ID, SummevonIst )
SELECT qry_VA_MA_Ist_VAStart.VAStart_ID, Sum(qry_VA_MA_Ist_VAStart.[Ist]) AS SummevonIst
FROM qry_VA_MA_Ist_VAStart
GROUP BY qry_VA_MA_Ist_VAStart.VAStart_ID;

