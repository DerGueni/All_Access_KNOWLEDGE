-- Query: qry_eMail_KunMain_Std
-- Type: 0
SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Anschreiben, tbl_KD_Kundenstamm.kun_Firma AS Firma, tbl_KD_Kundenstamm.kun_email AS [E-Maill]
FROM tbl_KD_Kundenstamm
WHERE (((Len(Trim(Nz([kun_email]))))>0) AND ((tbl_KD_Kundenstamm.kun_AdressArt)=1))
ORDER BY tbl_KD_Kundenstamm.kun_Firma;

