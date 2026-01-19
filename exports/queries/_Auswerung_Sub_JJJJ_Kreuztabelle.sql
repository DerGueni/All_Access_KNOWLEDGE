-- Query: _Auswerung_Sub_JJJJ_Kreuztabelle
-- Type: 16
TRANSFORM Sum([_Auswerung_Sub_JJJJ].NettoWert) AS SummevonNettoWert
SELECT [_Auswerung_Sub_JJJJ].kun_ID, [_Auswerung_Sub_JJJJ].kun_Firma, [_Auswerung_Sub_JJJJ].RchJahr, Sum([_Auswerung_Sub_JJJJ].NettoWert) AS Jahressumme_Kunde
FROM _Auswerung_Sub_JJJJ
GROUP BY [_Auswerung_Sub_JJJJ].kun_ID, [_Auswerung_Sub_JJJJ].kun_Firma, [_Auswerung_Sub_JJJJ].RchJahr
ORDER BY [_Auswerung_Sub_JJJJ].RchJahr, [_Auswerung_Sub_JJJJ].RchMonat
PIVOT [_Auswerung_Sub_JJJJ].RchMonat In (1,2,3,4,5,6,7,8,9,10,11,12);

