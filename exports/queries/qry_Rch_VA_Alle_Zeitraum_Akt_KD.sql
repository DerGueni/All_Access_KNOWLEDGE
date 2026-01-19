-- Query: qry_Rch_VA_Alle_Zeitraum_Akt_KD
-- Type: 0
SELECT qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.kun_ID, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.VA_ID, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.VADatum, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.VAStart_ID, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.MA_Start, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.MA_Ende, Sum(qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.MA_Brutto_Std) AS Menge, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.PreisArt_ID, tbl_VA_Preise.EurPreis, tbl_VA_Preise.MwStSatz, Count(qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.MA_ID) AS ANz_MA
FROM qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std LEFT JOIN tbl_VA_Preise ON (qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.PreisArt_ID = tbl_VA_Preise.Kostenzuo_KD) AND (qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.VA_ID = tbl_VA_Preise.VA_ID)
WHERE (((qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.Veranst_Status_ID)=3) AND ((tbl_VA_Preise.kun_ID)=Get_Priv_Property("prp_Rechnung_AktKunde")))
GROUP BY qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.kun_ID, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.VA_ID, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.VADatum, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.VAStart_ID, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.MA_Start, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.MA_Ende, qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.PreisArt_ID, tbl_VA_Preise.EurPreis, tbl_VA_Preise.MwStSatz
HAVING (((qry_Rch_VA_MA_Alle_Pos_MA_Einzel_Std.kun_ID)=Get_Priv_Property("prp_Rechnung_AktKunde")));

