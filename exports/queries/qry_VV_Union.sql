-- Query: qry_VV_Union
-- Type: 128
SELECT qry_VV_Plan.* FROM qry_VV_Plan UNION
SELECT qry_VV_Zuo.* FROM qry_VV_Zuo UNION SELECT qry_VV_nVerfueg.* FROM qry_VV_nVerfueg
ORDER BY MVA_Start, SOrt;

