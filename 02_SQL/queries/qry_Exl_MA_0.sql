INSERT INTO tbltmp_MA_Monat_Einzel ( AktDat, MA_ID )
SELECT qry_Exl_Tag.dtDatum, 152 AS Aus1
FROM qry_Exl_Tag
ORDER BY qry_Exl_Tag.dtDatum;

