SELECT DISTINCTROW [Kunden/Ohne Index].*, DCount("*","[Bestellungen]","[Empfänger]='" & [Firma] & "'") AS AnzBest
FROM [Kunden/Ohne Index]
ORDER BY [Kunden/Ohne Index].Firma;

