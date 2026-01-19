SELECT DISTINCTROW Month([Bestelldatum]) AS Monat, Bestellungen.Empf‰nger, Bestellungen.Straﬂe, Bestellungen.PLZ, Bestellungen.Ort, DCount("*","[Bestellungen]","[Empf‰nger]='" & [Empf‰nger] & "'") AS AnzBest
FROM Bestellungen
GROUP BY Month([Bestelldatum]), Bestellungen.Empf‰nger, Bestellungen.Straﬂe, Bestellungen.PLZ, Bestellungen.Ort;

