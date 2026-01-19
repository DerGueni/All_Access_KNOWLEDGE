SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, tbl_MA_Mitarbeiterstamm.Email FROM tbl_MA_Mitarbeiterstamm WHERE Len(Trim(Nz([tbl_MA_Mitarbeiterstamm].[Email]))) > 0 
UNION SELECT tbl_MA_ErsatzEmailAdressen.MA_ID, tbl_MA_ErsatzEmailAdressen.email_2 FROM tbl_MA_ErsatzEmailAdressen;

