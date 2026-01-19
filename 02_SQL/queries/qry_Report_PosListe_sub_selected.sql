SELECT qry_VA_Akt_MA_Pos_Zuo_Alle.PosNr, qry_VA_Akt_MA_Pos_Zuo_Alle.MA_Name, Left([Beginn],5) & " Uhr" AS Start, Left([Ende],5) & " Uhr" AS [End], qry_VA_Akt_MA_Pos_Zuo_Alle.Gruppe, qry_VA_Akt_MA_Pos_Zuo_Alle.Zusatztext
FROM qry_VA_Akt_MA_Pos_Zuo_Alle;

