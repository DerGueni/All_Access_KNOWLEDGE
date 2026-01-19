SELECT zqry_KD_Gesamtstunden_Datum.kun_Firma, Sum(zqry_KD_Gesamtstunden_Datum.SummevonMA_Brutto_Std2) AS MA_Brutto_Std, zqry_KD_Gesamtstunden_Datum.Jahr, calc_percentage_KD_hours([Kun_ID],[zqry_KD_Gesamtstunden_Datum].[Jahr]) AS [%]
FROM zqry_KD_Gesamtstunden_Datum
GROUP BY zqry_KD_Gesamtstunden_Datum.kun_Firma, zqry_KD_Gesamtstunden_Datum.Jahr, calc_percentage_KD_hours([Kun_ID],[zqry_KD_Gesamtstunden_Datum].[Jahr])
ORDER BY zqry_KD_Gesamtstunden_Datum.Jahr;

