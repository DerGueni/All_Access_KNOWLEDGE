SELECT S.ID, S.IstSubunternehmer, S.Name, Format(IIf(E.Entf_KM Is Null,999,E.Entf_KM),'0.0') & ' km' AS Std, S.Beginn, S.Ende, S.Grund
FROM ztbl_MA_Schnellauswahl AS S LEFT JOIN ztmp_Entf_Filter AS E ON E.MA_ID = S.ID
ORDER BY IIf(E.Entf_KM Is Null,999,E.Entf_KM), S.Name;

