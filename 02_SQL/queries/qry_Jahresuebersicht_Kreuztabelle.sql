TRANSFORM Sum(qry_Jahresuebersicht.IstGes) AS SummevonIstGes
SELECT qry_Jahresuebersicht.Name, Sum(qry_Jahresuebersicht.IstGes) AS [Gesamtsumme von IstGes]
FROM qry_Jahresuebersicht
GROUP BY qry_Jahresuebersicht.Name
PIVOT qry_Jahresuebersicht.AktMon;

