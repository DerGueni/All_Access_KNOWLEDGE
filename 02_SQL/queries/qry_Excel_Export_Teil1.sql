SELECT tbl_VA_Auftragstamm.ID AS VA_ID, Format([Dat_VA_Von],"dd/mm/yyyy",2.2) AS DatumVonStr, Format([Dat_VA_Bis],"dd/mm/yyyy",2.2) AS DatumBisStr, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Ort, tbl_VA_Auftragstamm.Objekt AS Location, Nz(Format([Treffp_Zeit],"Short Time")) AS TreffpZeitStr, tbl_VA_Auftragstamm.Treffpunkt AS TreffpOrtstr, tbl_VA_Auftragstamm.Dienstkleidung, tbl_KD_Kundenstamm.kun_Firma AS Auftraggeber, tbl_VA_Auftragstamm.Ansprechpartner, qry_KD_StdPreis_Kreuztabelle.*
FROM (tbl_VA_Auftragstamm LEFT JOIN tbl_KD_Kundenstamm ON tbl_VA_Auftragstamm.Veranstalter_ID = tbl_KD_Kundenstamm.kun_Id) LEFT JOIN qry_KD_StdPreis_Kreuztabelle ON tbl_VA_Auftragstamm.Veranstalter_ID = qry_KD_StdPreis_Kreuztabelle.kun_Id
ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von DESC;

