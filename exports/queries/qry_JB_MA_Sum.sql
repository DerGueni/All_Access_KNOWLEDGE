-- Query: qry_JB_MA_Sum
-- Type: 0
SELECT qry_JB_MA_Stunden2.MA_ID, qry_JB_MA_Stunden2.AktJahr, qry_JB_MA_Stunden2.AktMonat, fctround([MA_Brutto_Std1]) AS MA_Brutto_Std, fctRound([MA_Netto_Std1]) AS MA_Netto_Std, qry_JB_MA_Stunden2.Fahrtkost, qry_JB_MA_Stunden2.RL_34a, qry_JB_MA_Zus2.[34a_RZ] AS RZ_34a, qry_JB_MA_Zus2.SummevonAbschlag AS Abschlag, qry_JB_MA_Zus2.SummevonNicht_Erscheinen AS NichtDa, qry_JB_MA_Zus2.SummevonKaution AS Kaution, qry_JB_MA_Zus2.SummevonSonst_Abzuege AS Sonst_Abzuege, qry_JB_MA_Zus2.Sonst_Abzuege_Grund, qry_JB_MA_Zus2.SummevonMonatslohn AS Monatslohn, qry_JB_MA_Zus2.MaxvonUeberwVon AS Ueberw_von
FROM qry_JB_MA_Stunden2 INNER JOIN qry_JB_MA_Zus2 ON (qry_JB_MA_Stunden2.AktMonat = qry_JB_MA_Zus2.AktMonat) AND (qry_JB_MA_Stunden2.AktJahr = qry_JB_MA_Zus2.AktJahr) AND (qry_JB_MA_Stunden2.MA_ID = qry_JB_MA_Zus2.MA_ID);

