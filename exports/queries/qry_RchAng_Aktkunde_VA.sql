-- Query: qry_RchAng_Aktkunde_VA
-- Type: 0
SELECT qry_RchAng_VA_Alle_Zeitraum_Akt_KD.VA_ID, [Auftrag] & " " & [Ort] & " " & [Objekt] AS Auftragsname, tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis
FROM qry_RchAng_VA_Alle_Zeitraum_Akt_KD INNER JOIN tbl_VA_Auftragstamm ON qry_RchAng_VA_Alle_Zeitraum_Akt_KD.VA_ID = tbl_VA_Auftragstamm.ID
WHERE (((tbl_VA_Auftragstamm.Veranst_Status_ID)<3))
GROUP BY qry_RchAng_VA_Alle_Zeitraum_Akt_KD.VA_ID, [Auftrag] & " " & [Ort] & " " & [Objekt], tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis, qry_RchAng_VA_Alle_Zeitraum_Akt_KD.kun_ID
HAVING (((qry_RchAng_VA_Alle_Zeitraum_Akt_KD.kun_ID)=Get_Priv_Property("prp_Rechnung_AktKunde")));

