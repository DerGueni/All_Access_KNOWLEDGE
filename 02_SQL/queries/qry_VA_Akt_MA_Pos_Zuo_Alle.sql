SELECT m.ID, m.PosNr, p.Gruppe AS [Position], p.Zusatztext AS Info, h.von, h.bis, s.[Nachname] & ' ' & s.[Vorname] AS MA_Name
FROM ((tbl_VA_Akt_Objekt_Pos_MA AS m LEFT JOIN tbl_MA_Mitarbeiterstamm AS s ON m.MA_ID = s.ID) LEFT JOIN tbl_VA_Akt_Objekt_Pos AS p ON m.VA_Akt_Objekt_Pos_ID = p.ID) LEFT JOIN qry_MA_Zeiten_Helper AS h ON (m.VA_Akt_Objekt_Kopf_ID = h.Kopf_ID) AND (m.MA_ID = h.MA_ID)
WHERE m.VA_Akt_Objekt_Kopf_ID = Get_Priv_Property('prp_VA_Akt_Objekt_ID')
ORDER BY m.PosNr;

