SELECT tbl_VA_AnzTage.VA_ID, Sum(tbl_VA_AnzTage.TVA_Ist) AS TVA_Ist, Sum(tbl_VA_AnzTage.TVA_Soll) AS TVA_Soll
FROM tbl_VA_AnzTage
GROUP BY tbl_VA_AnzTage.VA_ID;

