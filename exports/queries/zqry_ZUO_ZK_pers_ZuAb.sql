-- Query: zqry_ZUO_ZK_pers_ZuAb
-- Type: 0
SELECT Null AS VADatum_ID, Null AS VAStart_ID, Null AS ZUO_ID, Null AS NV_ID, Null AS Korr_ID, tbl_MA_Mitarbeiterstamm.ID AS MA_ID, zqry_ZK_Lohnarten_Zuschlag.Bezeichnung AS Veranstaltung, Get_Priv_Property("prp_ZK_Datum") AS VADatum, Year([VADatum]) AS Jahr, Month([vadatum]) AS Monat, ztbl_MA_Mitarbeiterstamm_ZUAB.Lohnart_ID, Null AS Anz_Std, Null AS Satz, ztbl_MA_Mitarbeiterstamm_ZUAB.Wert, Null AS Beginn, Null AS Ende, False AS gesperrt, False AS exportiert, Now() AS erstellt, ermittle_Benutzer() AS Ersteller, Null AS geaendert, Null AS Aenderer, True AS exportieren, False AS Korrektur, Null AS Bemerkung, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID
FROM (tbl_MA_Mitarbeiterstamm RIGHT JOIN ztbl_MA_Mitarbeiterstamm_ZUAB ON tbl_MA_Mitarbeiterstamm.ID = ztbl_MA_Mitarbeiterstamm_ZUAB.MA_ID) LEFT JOIN zqry_ZK_Lohnarten_Zuschlag ON ztbl_MA_Mitarbeiterstamm_ZUAB.Lohnart_ID = zqry_ZK_Lohnarten_Zuschlag.ID;

