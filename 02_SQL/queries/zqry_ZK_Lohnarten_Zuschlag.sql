SELECT ztbl_ZK_Lohnarten.ID, ztbl_ZK_Lohnarten.Nummer, ztbl_ZK_Lohnarten.Bezeichnung, ztbl_ZK_Lohnarten.Bezeichnung_kurz, ztbl_ZK_Lohnarten.Ist_Zeit, ztbl_ZK_Stundensatz.Grundlohn, ztbl_ZK_Stundensatz.Faktor, ztbl_ZK_Lohnarten.Vorzeichen, ztbl_ZK_Stundensatz.Satz, ztbl_ZK_Stundensatz.DatumVon, ztbl_ZK_Stundensatz.DatumBis, ztbl_ZK_Lohnarten.Anzeige_MAStamm, ztbl_ZK_Lohnarten.ID_Folgelohnart, ztbl_ZK_Lohnarten.Anzeige_Korrekturen
FROM ztbl_ZK_Lohnarten LEFT JOIN ztbl_ZK_Stundensatz ON ztbl_ZK_Lohnarten.ID = ztbl_ZK_Stundensatz.Lohnart_ID
ORDER BY ztbl_ZK_Lohnarten.Bezeichnung;

