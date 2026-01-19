-- Query: qry_VV_tmp_belegt
-- Type: 0
SELECT [MA_ID], [MAName], [VADatum], [MVA_Start], [MVA_Ende], [Art], ObjektOrt
FROM qry_VV_Union
WHERE ( ([MVA_Start] between #2024-07-12 20:32:00# and #2024-07-13 02:28:00#)  OR ([MVA_Ende] between #2024-07-12 20:32:00# and #2024-07-13 02:28:00#)  OR (([MVA_Start]< #2024-07-12 20:32:00#) AND ([MVA_Ende]> #2024-07-13 02:28:00#)));

