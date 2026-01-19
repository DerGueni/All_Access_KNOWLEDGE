SELECT tbl_VA_Akt_Objekt_Pos.ID, tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID, tbl_VA_Akt_Objekt_Pos.Gruppe AS [Position], Format(k.VA_Start_Abs,'hh:nn') AS von, Format(k.VA_Ende_Abs,'hh:nn') AS bis, tbl_VA_Akt_Objekt_Pos.Anzahl AS Soll, Nz([AnzahlvonVA_Akt_Objekt_Pos_ID],0) AS Ist
FROM (tbl_VA_Akt_Objekt_Pos LEFT JOIN qry_VA_Akt_Pos_AnzZugeordnet ON tbl_VA_Akt_Objekt_Pos.ID = qry_VA_Akt_Pos_AnzZugeordnet.VA_Akt_Objekt_Pos_ID) LEFT JOIN tbl_VA_Akt_Objekt_Kopf AS k ON tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID = k.ID
WHERE tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID = Get_Priv_Property('prp_VA_Akt_Objekt_ID') AND tbl_VA_Akt_Objekt_Pos.Anzahl > 0 AND ([Anzahl]-Nz([AnzahlvonVA_Akt_Objekt_Pos_ID],0)) > 0
ORDER BY tbl_VA_Akt_Objekt_Pos.Sort;

