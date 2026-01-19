SELECT ma.Nachname & ', ' & ma.Vorname AS Mitarbeiter, nv.vonDat, Format(nv.vonDat,'mmm') AS Monat
FROM tbl_MA_Mitarbeiterstamm AS ma INNER JOIN tbl_MA_NVerfuegZeiten AS nv ON ma.ID = nv.MA_ID
WHERE ma.Anstellungsart_ID = 5 AND nv.Zeittyp_ID = 'Krank' AND Year(nv.vonDat) = 2023;

