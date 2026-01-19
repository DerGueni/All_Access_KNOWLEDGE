-- Query: qry_MA_Tagesuebersicht
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.ID, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_Mitarbeiterstamm.IstAktiv, tbl_MA_Mitarbeiterstamm.IstSubunternehmer, Fix([MVA_Start]) AS VADatum, Right("00" & Hour([MVA_Start]),2) & ":" & Right("00" & Minute([MVA_Start]),2) & " Uhr" AS Start, Right("00" & Hour([MVA_Ende]),2) & ":" & Right("00" & Minute([MVA_Ende]),2) & " Uhr" AS Ende, qry_Echtzeit_MA_VA_UnionSp.Grund
FROM tbl_MA_Mitarbeiterstamm INNER JOIN qry_Echtzeit_MA_VA_UnionSp ON tbl_MA_Mitarbeiterstamm.ID = qry_Echtzeit_MA_VA_UnionSp.MA_ID
ORDER BY Fix([MVA_Start]), Right("00" & Hour([MVA_Start]),2) & ":" & Right("00" & Minute([MVA_Start]),2) & " Uhr", tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;

