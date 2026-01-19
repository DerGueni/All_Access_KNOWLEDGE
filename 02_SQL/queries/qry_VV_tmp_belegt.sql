SELECT [MA_ID], [MAName], [VADatum], [MVA_Start], [MVA_Ende], [Art], ObjektOrt
FROM qry_VV_Union
WHERE ( ([MVA_Start] between #2023-03-07 17:32:00# and #2023-03-07 22:28:00#)  OR ([MVA_Ende] between #2023-03-07 17:32:00# and #2023-03-07 22:28:00#)  OR (([MVA_Start]< #2023-03-07 17:32:00#) AND ([MVA_Ende]> #2023-03-07 22:28:00#)));

