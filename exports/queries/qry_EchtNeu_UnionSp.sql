-- Query: qry_EchtNeu_UnionSp
-- Type: 128
SELECT qry_EchtNeu_Zuo.* FROM qry_EchtNeu_Zuo UNION 
SELECT qry_EchtNeu_Plan.* FROM qry_EchtNeu_Plan UNION 
SELECT qry_EchtNeu_Plan_Absage.* FROM qry_EchtNeu_Plan_Absage UNION SELECT qry_EchtNeu_Privat.* FROM qry_EchtNeu_Privat;

