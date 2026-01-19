SELECT [Nachname] & " " & [Vorname] AS Name, Last(tbl_MA_VA_Zuordnung.VADatum) AS Datum, Last(tbl_VA_Auftragstamm.Auftrag) AS [Letzter Einsatz]
FROM (tbl_MA_VA_Zuordnung LEFT JOIN tbl_VA_Auftragstamm ON tbl_MA_VA_Zuordnung.VA_ID = tbl_VA_Auftragstamm.ID) INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
GROUP BY [Nachname] & " " & [Vorname], tbl_MA_Mitarbeiterstamm.Anstellungsart_ID
HAVING (((Last(tbl_MA_VA_Zuordnung.VADatum))<Date()-14) AND ((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3 Or (tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=5))
ORDER BY Last(tbl_MA_VA_Zuordnung.VADatum);

