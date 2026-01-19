-- Query: zqry_Rch_Pos
-- Type: 0
SELECT DISTINCTROW Sum(ztbl_Rch_Berechnungsliste.menge) AS Summevonmenge, ztbl_Rch_Berechnungsliste.bezeichnung, Sum(ztbl_Rch_Berechnungsliste.summe_std) AS Summevonsumme_std, ztbl_Rch_Berechnungsliste.faktor, ztbl_Rch_Berechnungsliste.VA_ID, Sum(ztbl_Rch_Berechnungsliste.summe) AS [Summe von summe]
FROM ztbl_Rch_Berechnungsliste
GROUP BY ztbl_Rch_Berechnungsliste.bezeichnung, ztbl_Rch_Berechnungsliste.faktor, ztbl_Rch_Berechnungsliste.VA_ID
ORDER BY First(ztbl_Rch_Berechnungsliste.sort);

