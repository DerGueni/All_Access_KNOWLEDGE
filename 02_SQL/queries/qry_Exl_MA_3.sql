SELECT qry_Exl_MA_2.*
FROM qry_Exl_MA_2 LEFT JOIN qry_Exl_MA_1 ON (qry_Exl_MA_2.VAStart_ID = qry_Exl_MA_1.VAStart_ID) AND (qry_Exl_MA_2.MA_ID = qry_Exl_MA_1.MA_ID)
WHERE (((qry_Exl_MA_1.VAStart_ID) Is Null));

