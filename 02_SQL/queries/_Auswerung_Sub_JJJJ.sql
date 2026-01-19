SELECT tbl_Rch_Kopf.kun_ID, tbl_KD_Kundenstamm.kun_Firma, tbl_Rch_Kopf.RchDatum, tbl_Rch_Kopf.Zwi_Sum1 AS NettoWert, CLng(Year([RchDatum]) & Right("00" & Month([RchDatum]),2)) AS RchJaMon, Year([RchDatum]) AS RchJahr, Month([RchDatum]) AS RchMonat
FROM tbl_Rch_Kopf INNER JOIN tbl_KD_Kundenstamm ON tbl_Rch_Kopf.kun_ID = tbl_KD_Kundenstamm.kun_Id
ORDER BY tbl_Rch_Kopf.RchDatum;

