SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum
FROM tbl_MA_VA_Zuordnung
WHERE (((tbl_MA_VA_Zuordnung.MA_ID)=152) AND ((Year([VADatum]))=2015) AND ((Month([VADatum]))=11));

