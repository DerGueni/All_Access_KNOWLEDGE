-- Query: _Auswertung_Umsatz_Kunde
-- Type: 0
SELECT [_Auswerung_Sub_JJJJ_Kreuztabelle].kun_ID, [_Auswerung_Sub_JJJJ_Kreuztabelle].kun_Firma, [_Auswerung_Sub_JJJJ_Kreuztabelle].RchJahr, [_Auswerung_Sub_JJJJ_Kreuztabelle].Jahressumme_Kunde, [_Auswertung_Sub_Kundenpreise].StdPreis, [_Auswerung_Sub_JJJJ_Kreuztabelle].[1], [_Auswerung_Sub_JJJJ_Kreuztabelle].[2], [_Auswerung_Sub_JJJJ_Kreuztabelle].[3], [_Auswerung_Sub_JJJJ_Kreuztabelle].[4], [_Auswerung_Sub_JJJJ_Kreuztabelle].[5], [_Auswerung_Sub_JJJJ_Kreuztabelle].[6], [_Auswerung_Sub_JJJJ_Kreuztabelle].[7], [_Auswerung_Sub_JJJJ_Kreuztabelle].[8], [_Auswerung_Sub_JJJJ_Kreuztabelle].[9], [_Auswerung_Sub_JJJJ_Kreuztabelle].[10], [_Auswerung_Sub_JJJJ_Kreuztabelle].[11], [_Auswerung_Sub_JJJJ_Kreuztabelle].[12]
FROM _Auswerung_Sub_JJJJ_Kreuztabelle LEFT JOIN _Auswertung_Sub_Kundenpreise ON [_Auswerung_Sub_JJJJ_Kreuztabelle].kun_ID = [_Auswertung_Sub_Kundenpreise].kun_Id
ORDER BY [_Auswerung_Sub_JJJJ_Kreuztabelle].RchJahr DESC , [_Auswerung_Sub_JJJJ_Kreuztabelle].Jahressumme_Kunde DESC;

