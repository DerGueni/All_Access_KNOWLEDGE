SELECT tbl_MA_UeberlaufStunden.MA_ID, 2015 AS AktJahr, 3 AS AktMonat, tbl_MA_UeberlaufStunden.M2 AS VorMonWert
FROM tbl_MA_UeberlaufStunden
WHERE (((tbl_MA_UeberlaufStunden.AktJahr)=2015));

