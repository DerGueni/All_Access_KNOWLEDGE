-- Query: qry_allgemein_Kreuztabelle
-- Type: 16
TRANSFORM Count(qry_allgemein.[Datum]) AS AnzahlvonDatum
SELECT qry_allgemein.[AnzahlvonSoll], qry_allgemein.[SummevonMA_Brutto_Std], qry_allgemein.[Kosten_pro_MAStunde], Count(qry_allgemein.[Datum]) AS [Gesamtsumme von Datum]
FROM qry_allgemein
GROUP BY qry_allgemein.[AnzahlvonSoll], qry_allgemein.[SummevonMA_Brutto_Std], qry_allgemein.[Kosten_pro_MAStunde]
PIVOT qry_allgemein.[VADatum];

