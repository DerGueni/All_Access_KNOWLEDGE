-- Query: zqry_ZK_Stunden_export
-- Type: 0
SELECT zqry_ZK_Stunden_Zusatz.MA_ID, zqry_ZK_Stunden_Zusatz.Jahr, zqry_ZK_Stunden_Zusatz.Monat, pruefeLohnart([ma_id],Nz([Lohnart_ID],0),Nz([Nummer],"")) AS Lohnartnummer, Sum(zqry_ZK_Stunden_Zusatz.Anz_Std) AS SummevonAnz_Std, Sum(zqry_ZK_Stunden_Zusatz.Anz_Std_netto) AS SummevonAnz_Std_netto, Sum(zqry_ZK_Stunden_Zusatz.Wert) AS Wert, First(zqry_ZK_Stunden_Zusatz.Satz) AS Stundensatz, zqry_ZK_Stunden_Zusatz.Anstellungsart_ID, zqry_ZK_Stunden_Zusatz.Bezeichnung_kurz, zqry_ZK_Stunden_Zusatz.LEXWare_ID, zqry_ZK_Stunden_Zusatz.Lohnart_ID, "Euro" AS Währung, zqry_ZK_Stunden_Zusatz.Name
FROM zqry_ZK_Stunden_Zusatz
GROUP BY zqry_ZK_Stunden_Zusatz.MA_ID, zqry_ZK_Stunden_Zusatz.Jahr, zqry_ZK_Stunden_Zusatz.Monat, pruefeLohnart([ma_id],Nz([Lohnart_ID],0),Nz([Nummer],"")), zqry_ZK_Stunden_Zusatz.Anstellungsart_ID, zqry_ZK_Stunden_Zusatz.Bezeichnung_kurz, zqry_ZK_Stunden_Zusatz.LEXWare_ID, zqry_ZK_Stunden_Zusatz.Lohnart_ID, "Euro", zqry_ZK_Stunden_Zusatz.Name, zqry_ZK_Stunden_Zusatz.exportiert, zqry_ZK_Stunden_Zusatz.exportieren
HAVING (((zqry_ZK_Stunden_Zusatz.exportiert)=False) AND ((zqry_ZK_Stunden_Zusatz.exportieren)=True));

