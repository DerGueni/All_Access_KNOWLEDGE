-- Query: qry_Report_Ausweisdruck
-- Type: 0
SELECT tbl_MA_Mitarbeiterstamm.*, fKopf_Bildname([ID]) AS Kopf_Bild, fSignatur([ID]) AS Signatur, fUnterschrift_Bild() AS Unterschr, #12/31/2022# AS Ausw_Gueltig_Bis, [Strasse] & ' ' & [Nr] AS Strasse_nr
FROM tbltmp_AusweisMA_ID INNER JOIN tbl_MA_Mitarbeiterstamm ON tbltmp_AusweisMA_ID.MA_ID = tbl_MA_Mitarbeiterstamm.ID
ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;

