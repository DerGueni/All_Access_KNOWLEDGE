SELECT qry_JB_MA_Zus1.MA_ID, qry_JB_MA_Zus1.AktJahr, qry_JB_MA_Zus1.AktMonat, Sum(qry_JB_MA_Zus1.[34a_RZ]) AS 34a_RZ, Sum(qry_JB_MA_Zus1.Abschlag) AS Abschlag, Sum(qry_JB_MA_Zus1.Nicht_Erscheinen) AS Nicht_Erscheinen, Sum(qry_JB_MA_Zus1.Kaution) AS Kaution, Sum(qry_JB_MA_Zus1.Sonst_Abzuege) AS Sonst_Abzuege, Max(qry_JB_MA_Zus1.Sonst_Abzuege_Grund) AS Sonst_Abzuege_Grund, Sum(qry_JB_MA_Zus1.Monatslohn) AS Monatslohn, Max(qry_JB_MA_Zus1.UeberwVon) AS UeberwVon
FROM qry_JB_MA_Zus1
GROUP BY qry_JB_MA_Zus1.MA_ID, qry_JB_MA_Zus1.AktJahr, qry_JB_MA_Zus1.AktMonat;

