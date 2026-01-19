-- Query: qry_MA_Leere_Tageszusatzwerte_loeschen
-- Type: 32
DELETE tbl_MA_Tageszusatzwerte.*, Len(Trim(Nz([34a_RZ]))) AS Ausdr1, Len(Trim(Nz([Abschlag]))) AS Ausdr2, Len(Trim(Nz([Nicht_Erscheinen]))) AS Ausdr3, Len(Trim(Nz([Kaution]))) AS Ausdr4, Len(Trim(Nz([Dienstkleidung]))) AS Ausdr5, Len(Trim(Nz([Sonst_Abzuege]))) AS Ausdr6, Len(Trim(Nz([Sonst_Abzuege_Grund]))) AS Ausdr7, Len(Trim(Nz([Monatslohn]))) AS Ausdr8, Len(Trim(Nz([UeberwVon]))) AS Ausdr9, Len(Trim(Nz([Bemerkungen]))) AS Ausdr10
FROM tbl_MA_Tageszusatzwerte
WHERE (((Len(Trim(Nz([34a_RZ]))))=0) AND ((Len(Trim(Nz([Abschlag]))))=0) AND ((Len(Trim(Nz([Nicht_Erscheinen]))))=0) AND ((Len(Trim(Nz([Kaution]))))=0) AND ((Len(Trim(Nz([Dienstkleidung]))))=0) AND ((Len(Trim(Nz([Sonst_Abzuege]))))=0) AND ((Len(Trim(Nz([Sonst_Abzuege_Grund]))))=0) AND ((Len(Trim(Nz([Monatslohn]))))=0) AND ((Len(Trim(Nz([UeberwVon]))))=0) AND ((Len(Trim(Nz([Bemerkungen]))))=0));

