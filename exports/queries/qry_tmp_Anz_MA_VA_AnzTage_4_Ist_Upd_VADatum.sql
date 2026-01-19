-- Query: qry_tmp_Anz_MA_VA_AnzTage_4_Ist_Upd_VADatum
-- Type: 48
UPDATE tbltmp_MA_VaStart_AnzTag INNER JOIN tbl_VA_AnzTage ON (tbltmp_MA_VaStart_AnzTag.VADatum_ID = tbl_VA_AnzTage.ID) AND (tbltmp_MA_VaStart_AnzTag.VA_ID = tbl_VA_AnzTage.VA_ID) SET tbl_VA_AnzTage.TVA_Ist = [AnzahlvonMA_ID];

