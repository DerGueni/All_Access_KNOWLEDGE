-- Query: qry_Dienstplan
-- Type: 0
SELECT qry_MA_VA_Plan_AllAufUeber1.VA_ID, qry_MA_VA_Plan_AllAufUeber1.MA_ID, qry_MA_VA_Plan_AllAufUeber1.VADatum_ID, qry_MA_VA_Plan_AllAufUeber1.VADatum, qry_MA_VA_Plan_AllAufUeber1.Auftrag, qry_MA_VA_Plan_AllAufUeber1.Ort, qry_MA_VA_Plan_AllAufUeber1.Objekt, zqry_Treffpunkt.Treffpunkt, qry_MA_VA_Plan_AllAufUeber1.Beginn, qry_MA_VA_Plan_AllAufUeber1.Ende, qry_MA_VA_Plan_AllAufUeber1.IstPL, qry_MA_VA_Plan_AllAufUeber1.Plan_ID, qry_MA_VA_Plan_AllAufUeber1.PKW, qry_MA_VA_Plan_AllAufUeber1.MA_Brutto_Std, qry_MA_VA_Plan_AllAufUeber1.MA_Netto_Std, zqry_Treffpunkt.Treffp_Zeit, Format([VADatum],"ddd") & ", " & Format([VADatum],"dd/mm/yy") AS VADatum1, *
FROM qry_MA_VA_Plan_AllAufUeber1 LEFT JOIN zqry_Treffpunkt ON qry_MA_VA_Plan_AllAufUeber1.VA_ID = zqry_Treffpunkt.ID
WHERE (((qry_MA_VA_Plan_AllAufUeber1.IstPL)="Zuo"))
ORDER BY qry_MA_VA_Plan_AllAufUeber1.VADatum, qry_MA_VA_Plan_AllAufUeber1.Beginn;

