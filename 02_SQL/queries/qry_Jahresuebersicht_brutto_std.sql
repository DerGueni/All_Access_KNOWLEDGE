TRANSFORM Sum(qry_Jahresuebersicht.brutto_std) AS Summevonbrutto_std
SELECT qry_Jahresuebersicht.Name, Sum(qry_Jahresuebersicht.Brutto_Std) AS [Gesamtsumme von Brutto_Std]
FROM tbl_MA_Mitarbeiterstamm INNER JOIN qry_Jahresuebersicht ON tbl_MA_Mitarbeiterstamm.ID = qry_Jahresuebersicht.MA_ID
WHERE (((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3 Or (tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=5 Or (tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=11))
GROUP BY qry_Jahresuebersicht.Name, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID
PIVOT qry_Jahresuebersicht.AktMon;

