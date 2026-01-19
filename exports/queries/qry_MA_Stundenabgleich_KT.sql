TRANSFORM Sum(S.[SummenvonWert]) AS Summe_Stunden
SELECT S.[Name] AS Mitarbeiter
FROM zqry_MA_Stunden_Abgleich AS S
WHERE S.[Jahr] = [Bitte Jahr eingeben:]
GROUP BY S.[Name]
PIVOT S.[Monat] IN
    (1,2,3,4,5,6,7,8,9,10,11,12);

