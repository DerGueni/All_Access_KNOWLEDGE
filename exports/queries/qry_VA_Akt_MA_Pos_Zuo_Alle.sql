-- Query: qry_VA_Akt_MA_Pos_Zuo_Alle
-- Type: 0
SELECT tbl_VA_Akt_Objekt_Pos_MA.ID, tbl_VA_Akt_Objekt_Pos_MA.MA_ID, tbl_VA_Akt_Objekt_Pos_MA.PosNr, tbl_VA_Akt_Objekt_Pos.Abs_Beginn AS Beginn, tbl_VA_Akt_Objekt_Pos.Abs_Ende AS Ende, [Nachname] & " " & [Vorname] AS MA_Name, tbl_VA_Akt_Objekt_Pos.Gruppe, tbl_VA_Akt_Objekt_Pos.Zusatztext, tbl_VA_Akt_Objekt_Pos.Geschlecht, tbl_VA_Akt_Objekt_Pos_MA.Bemerkung
FROM (tbl_VA_Akt_Objekt_Pos_MA LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_VA_Akt_Objekt_Pos_MA.MA_ID = tbl_MA_Mitarbeiterstamm.ID) LEFT JOIN tbl_VA_Akt_Objekt_Pos ON tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Pos_ID = tbl_VA_Akt_Objekt_Pos.ID
WHERE (((tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID)=Get_Priv_Property("prp_VA_Akt_Objekt_ID")));

