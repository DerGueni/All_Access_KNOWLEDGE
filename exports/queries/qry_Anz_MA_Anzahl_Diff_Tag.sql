-- Query: qry_Anz_MA_Anzahl_Diff_Tag
-- Type: 0
SELECT qry_Anz_MA_VA_Zuordnung_Tag.VA_ID, qry_Anz_MA_VA_Zuordnung_Tag.VADatum, qry_Anz_MA_VA_Zuordnung_Tag.VADatum_ID, qry_Anz_MA_VA_Zuordnung_Tag.AnzMA_Z, qry_Anz_MA_VA_Zuordnung_Tag.PosNrMax, [AnzMA_Z]-[SummevonMA_Anzahl] AS MA_Diff
FROM qry_Anz_VA_Start_Tag INNER JOIN qry_Anz_MA_VA_Zuordnung_Tag ON (qry_Anz_MA_VA_Zuordnung_Tag.VADatum_ID = qry_Anz_VA_Start_Tag.VADatum_ID) AND (qry_Anz_VA_Start_Tag.VA_ID = qry_Anz_MA_VA_Zuordnung_Tag.VA_ID)
WHERE ((([AnzMA_Z]-[SummevonMA_Anzahl])>0));

