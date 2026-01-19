-- Query: qry_XL_XLDiePl
-- Type: 0
SELECT 'Glatz Michael' AS Name, qry_MA_VA_Plan_AllAufUeber1.VADatum, qry_MA_VA_Plan_AllAufUeber1.Auftrag, qry_MA_VA_Plan_AllAufUeber1.Ort, qry_MA_VA_Plan_AllAufUeber1.Objekt, Format([Beginn],'Short Time') AS beginnt, Format([Ende],'Short Time') AS endet, qry_MA_VA_Plan_AllAufUeber1.IstPl
FROM qry_MA_VA_Plan_AllAufUeber1
WHERE (((qry_MA_VA_Plan_AllAufUeber1.VADatum) Between #11/30/2015# And #8/26/2018#) And ((qry_MA_VA_Plan_AllAufUeber1.MA_ID)=152))
ORDER BY qry_MA_VA_Plan_AllAufUeber1.VADatum, qry_MA_VA_Plan_AllAufUeber1.Beginn;

