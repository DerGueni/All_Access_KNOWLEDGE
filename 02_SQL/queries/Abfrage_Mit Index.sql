SELECT DISTINCTROW [Kunden/Mit Index].*, DCount("*","[Bestellungen]","[Empfänger]='" & [Firma] & "'") AS AnzBest
FROM [Kunden/Mit Index]
ORDER BY [Kunden/Mit Index].Firma;

