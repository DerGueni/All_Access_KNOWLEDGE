-- Query: zqry_Rueckmeldungen
-- Type: 0
SELECT ztbl_Rueckmeldezeiten.MA_ID, Count(ztbl_Rueckmeldezeiten.Anfragezeitpunkt) AS AnzahlvonAnfragezeitpunkt, Count(ztbl_Rueckmeldezeiten.Rueckmeldezeitpunkt) AS AnzahlvonRueckmeldezeitpunkt, Avg(ztbl_Rueckmeldezeiten.Reaktionszeit) AS MittelwertvonReaktionszeit, Round(IIf([AnzahlvonAnfragezeitpunkt]<>0,[AnzahlvonRueckmeldezeitpunkt]/[AnzahlvonAnfragezeitpunkt]*100,0),0) AS Antwortrate, Sum(IIf([Status_ID]=3,1,0)) AS Zusagen, Sum(IIf([Status_ID]=4,1,0)) AS Absagen
FROM ztbl_Rueckmeldezeiten
GROUP BY ztbl_Rueckmeldezeiten.MA_ID;

