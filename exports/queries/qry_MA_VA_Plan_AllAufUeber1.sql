-- Query: qry_MA_VA_Plan_AllAufUeber1
-- Type: 128
SELECT qry_MA_VA_Plan_All_AufUeber1a.VA_ID, qry_MA_VA_Plan_All_AufUeber1a.MA_ID, qry_MA_VA_Plan_All_AufUeber1a.VADatum_ID, qry_MA_VA_Plan_All_AufUeber1a.VADatum, qry_MA_VA_Plan_All_AufUeber1a.Auftrag, qry_MA_VA_Plan_All_AufUeber1a.Ort, qry_MA_VA_Plan_All_AufUeber1a.Objekt, qry_MA_VA_Plan_All_AufUeber1a.Beginn, qry_MA_VA_Plan_All_AufUeber1a.Ende, qry_MA_VA_Plan_All_AufUeber1a.IstPL, qry_MA_VA_Plan_All_AufUeber1a.Plan_ID, 0 as PKW, 0 as [MA_Brutto_Std], 0 as [MA_Netto_Std]
FROM qry_MA_VA_Plan_All_AufUeber1a;
UNION SELECT qry_MA_VA_Plan_All_AufUeber2_neu.[VA_ID], qry_MA_VA_Plan_All_AufUeber2_neu.[MA_ID], qry_MA_VA_Plan_All_AufUeber2_neu.[VADatum_ID], qry_MA_VA_Plan_All_AufUeber2_neu.[VADatum], qry_MA_VA_Plan_All_AufUeber2_neu.[Auftrag], qry_MA_VA_Plan_All_AufUeber2_neu.[Ort], qry_MA_VA_Plan_All_AufUeber2_neu.[Objekt], qry_MA_VA_Plan_All_AufUeber2_neu.[Beginn], qry_MA_VA_Plan_All_AufUeber2_neu.[Ende], qry_MA_VA_Plan_All_AufUeber2_neu.[IstPL], qry_MA_VA_Plan_All_AufUeber2_neu.[Plan_ID], qry_MA_VA_Plan_All_AufUeber2_neu.[PKW], qry_MA_VA_Plan_All_AufUeber2_neu.[MA_Brutto_Std], qry_MA_VA_Plan_All_AufUeber2_neu.[MA_Netto_Std]
FROM qry_MA_VA_Plan_All_AufUeber2_neu;

