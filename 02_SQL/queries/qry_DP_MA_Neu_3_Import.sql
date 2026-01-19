INSERT INTO tbltmp_DP_MA_Neu_1 ( MA_ID, MAName, IstAktiv, IstSubunternehmer, Anstellungsart_ID, IstFraglich, hlp, ZuordID )
SELECT qry_DP_MA_Neu_3_Resr.MA_ID, qry_DP_MA_Neu_3_Resr.MAName, qry_DP_MA_Neu_3_Resr.IstAktiv, qry_DP_MA_Neu_3_Resr.IstSubunternehmer, qry_DP_MA_Neu_3_Resr.Anstellungsart_ID, qry_DP_MA_Neu_3_Resr.IstFraglich, qry_DP_MA_Neu_3_Resr.hlp, 0 AS Ausdr1
FROM qry_DP_MA_Neu_3_Resr;

