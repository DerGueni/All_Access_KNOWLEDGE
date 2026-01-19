SELECT vak.ID AS VA_Akt_Kopf_ID, vak.VA_ID, va.Auftrag, va.Objekt, va.Ort, vak.VADatum, vap.ID AS Position_ID, vap.Sort, vap.Gruppe AS [Position], vap.Zusatztext AS Info, vap.Geschlecht, vap.Anzahl AS Soll_Anzahl, vap.Abs_Beginn, vap.Abs_Ende, zuo.MA_ID, ma.Nachname, ma.Vorname, ma.Nachname & ', ' & ma.Vorname AS MA_Name, zuo.MVA_Start AS MA_Beginn, zuo.MVA_Ende AS MA_Ende
FROM (((tbl_VA_Akt_Objekt_Kopf AS vak INNER JOIN tbl_VA_Auftragstamm AS va ON vak.VA_ID = va.ID) INNER JOIN tbl_VA_Akt_Objekt_Pos AS vap ON vak.ID = vap.VA_Akt_Objekt_Kopf_ID) LEFT JOIN tbl_MA_VA_Zuordnung AS zuo ON (zuo.VADatum_ID = vak.VADatum_ID) AND (zuo.VA_ID = vak.VA_ID)) LEFT JOIN tbl_MA_Mitarbeiterstamm AS ma ON zuo.MA_ID = ma.ID
ORDER BY vap.Sort, ma.Nachname;

