-- Query: qry_MA_VA_Zuo_All_AufUeber
-- Type: 0
SELECT qry_MA_VA_Zuo_All_AufUeber1.VA_ID, qry_MA_VA_Zuo_All_AufUeber1.MA_ID, qry_MA_VA_Zuo_All_AufUeber1.VADatum_ID, qry_MA_VA_Zuo_All_AufUeber1.VADatum, qry_MA_VA_Zuo_All_AufUeber1.Auftrag, qry_MA_VA_Zuo_All_AufUeber1.Ort, qry_MA_VA_Zuo_All_AufUeber1.Objekt, qry_MA_VA_Zuo_All_AufUeber1.beginn1, qry_MA_VA_Zuo_All_AufUeber1.Ende1, qry_MA_VA_Zuo_All_AufUeber1.Fahrtkosten, qry_MA_VA_Zuo_All_AufUeber1.RL_34a, ([MA_Brutto_Std2]) AS [Brutto Std], ([MA_Netto_Std2]) AS [Netto Std]
FROM qry_MA_VA_Zuo_All_AufUeber1 INNER JOIN tbl_MA_VA_Zuordnung ON (qry_MA_VA_Zuo_All_AufUeber1.VADatum_ID = tbl_MA_VA_Zuordnung.VADatum_ID) AND (qry_MA_VA_Zuo_All_AufUeber1.Ende1 = tbl_MA_VA_Zuordnung.MA_Ende) AND (qry_MA_VA_Zuo_All_AufUeber1.Beginn1 = tbl_MA_VA_Zuordnung.MA_Start) AND (qry_MA_VA_Zuo_All_AufUeber1.MA_ID = tbl_MA_VA_Zuordnung.MA_ID) AND (qry_MA_VA_Zuo_All_AufUeber1.VA_ID = tbl_MA_VA_Zuordnung.VA_ID);

