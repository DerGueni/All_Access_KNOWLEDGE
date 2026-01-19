UPDATE tbltmp_MA_VaStart_AnzTag_Soll INNER JOIN tbl_VA_AnzTage ON (tbltmp_MA_VaStart_AnzTag_Soll.VA_ID = tbl_VA_AnzTage.VA_ID) AND (tbltmp_MA_VaStart_AnzTag_Soll.VADatum_ID = tbl_VA_AnzTage.ID) SET tbl_VA_AnzTage.TVA_Soll = [SummevonMA_Anzahl];

