-- Query: qry_VV_Nverfueg_Upd_MA
-- Type: 48
UPDATE tbltmp_MA_Verfueg_tmp SET tbltmp_MA_Verfueg_tmp.IstVerfuegbar = 0
WHERE (((tbltmp_MA_Verfueg_tmp.ID) In (SELECT MA_ID FROM qry_VV_tmp_belegt)));

