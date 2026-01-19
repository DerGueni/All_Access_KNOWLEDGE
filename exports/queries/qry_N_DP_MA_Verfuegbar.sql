-- Query: qry_N_DP_MA_Verfuegbar
-- Type: 0
SELECT m.ID AS MA_ID, m.Nachname & " " & m.Vorname AS MA_Name, m.Anstellungsart_ID, Nz((SELECT Sum(Nz(p.MA_Netto_Std,0))
           FROM tbl_MA_VA_Planung AS p
           WHERE p.MA_ID = m.ID
             AND Month(p.VADatum) = Month(Date())
             AND Year(p.VADatum) = Year(Date())), 0) AS MonatStd
FROM tbl_MA_Mitarbeiterstamm AS m
WHERE m.IstAktiv = True
  AND m.Anstellungsart_ID IN (3, 5)
ORDER BY IIf(m.Anstellungsart_ID=3, 1, 2), m.Nachname, m.Vorname;

