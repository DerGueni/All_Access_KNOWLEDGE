SELECT qry_Rch_Ges.VA_ID, [Auftrag] & " " & [Ort] & " " & [Objekt] AS Auftragsname, tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis
FROM qry_Rch_Ges INNER JOIN tbl_VA_Auftragstamm ON qry_Rch_Ges.VA_ID = tbl_VA_Auftragstamm.ID
GROUP BY qry_Rch_Ges.VA_ID, [Auftrag] & " " & [Ort] & " " & [Objekt], tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Dat_VA_Bis, qry_Rch_Ges.kun_ID, qry_Rch_Ges.Veranst_Status_ID
HAVING (((qry_Rch_Ges.kun_ID)=Get_Priv_Property("prp_Rechnung_AktKunde")) AND ((qry_Rch_Ges.Veranst_Status_ID)=3));

