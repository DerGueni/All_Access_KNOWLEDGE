SELECT o.*, m.Vorname, m.Tel_Festnetzt AS WhatsAppNr
FROM qry_MA_Offene_Anfragen AS o INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON o.MA_ID = m.MA_ID;

