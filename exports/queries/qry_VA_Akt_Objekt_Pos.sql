-- Query: qry_VA_Akt_Objekt_Pos
-- Type: 0
SELECT tbl_VA_Akt_Objekt_Pos.ID, tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID, tbl_VA_Akt_Objekt_Pos.Anzahl AS Soll, Nz([AnzahlvonVA_Akt_Objekt_Pos_ID],0) AS Ist, tbl_VA_Akt_Objekt_Pos.Gruppe, tbl_VA_Akt_Objekt_Pos.Zusatztext, tbl_VA_Akt_Objekt_Pos.Geschlecht, tbl_VA_Akt_Objekt_Pos.Sort
FROM tbl_VA_Akt_Objekt_Pos LEFT JOIN qry_VA_Akt_Pos_AnzZugeordnet ON tbl_VA_Akt_Objekt_Pos.ID = qry_VA_Akt_Pos_AnzZugeordnet.VA_Akt_Objekt_Pos_ID
WHERE (((tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID)=Get_Priv_Property("prp_VA_Akt_Objekt_ID")) AND ((tbl_VA_Akt_Objekt_Pos.Anzahl)>0) AND (([Anzahl]-Nz([AnzahlvonVA_Akt_Objekt_Pos_ID],0))>0))
ORDER BY tbl_VA_Akt_Objekt_Pos.Sort;

