SELECT 'Eskofier Sascha' AS Name, tbl_MA_UeberlaufStunden.AktJahr, tbl_MA_UeberlaufStunden.M1, tbl_MA_UeberlaufStunden.M2, tbl_MA_UeberlaufStunden.M3, tbl_MA_UeberlaufStunden.M4, tbl_MA_UeberlaufStunden.M5, tbl_MA_UeberlaufStunden.M6, tbl_MA_UeberlaufStunden.M7, tbl_MA_UeberlaufStunden.M8, tbl_MA_UeberlaufStunden.M9, tbl_MA_UeberlaufStunden.M10, tbl_MA_UeberlaufStunden.M11, tbl_MA_UeberlaufStunden.M12
FROM tbl_MA_UeberlaufStunden
WHERE (((tbl_MA_UeberlaufStunden.[ma_Id])=169))
ORDER BY tbl_MA_UeberlaufStunden.AktJahr;

