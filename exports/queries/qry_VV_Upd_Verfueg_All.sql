-- Query: qry_VV_Upd_Verfueg_All
-- Type: 48
UPDATE tbltmp_MA_Verfueg_tmp INNER JOIN tbltmp_VV_Belegt ON tbltmp_MA_Verfueg_tmp.ID = tbltmp_VV_Belegt.MA_ID SET tbltmp_MA_Verfueg_tmp.IstVerfuegbar = 0;

