SELECT ma.Nachname & ', ' & ma.Vorname AS Mitarbeiter, zuo.MVA_Start, zuo.MVA_Ende, Round(DateDiff('n',[zuo].[MVA_Start],[zuo].[MVA_Ende])/60*0.91,2) AS Stunden, Format(zuo.MVA_Start,'mmm') AS Monat
FROM tbl_MA_Mitarbeiterstamm AS ma INNER JOIN tbl_MA_VA_Zuordnung AS zuo ON ma.ID = zuo.MA_ID
WHERE (((ma.Anstellungsart_ID)=3) AND ((Year([zuo].[MVA_Start]))=2025));

