UPDATE tbl_VA_AnzTage INNER JOIN tbltmp_VA_Soll_Ist ON (tbl_VA_AnzTage.VADatum = tbltmp_VA_Soll_Ist.VADatum) AND (tbl_VA_AnzTage.VA_ID = tbltmp_VA_Soll_Ist.VA_ID) SET tbl_VA_AnzTage.TVA_Soll = [Soll], tbl_VA_AnzTage.TVA_Ist = [Ist];

