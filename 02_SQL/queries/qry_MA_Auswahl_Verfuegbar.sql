SELECT qry_MA_Auswahl_Alle.ID, qry_MA_Auswahl_Alle.IstSubunternehmer, qry_MA_Auswahl_Alle.Name, qry_MA_Auswahl_Alle.Stunden, qry_MA_Auswahl_Alle.Beginn, qry_MA_Auswahl_Alle.Ende, qry_MA_Auswahl_Alle.Grund, qry_MA_Auswahl_Alle.Anstellungsart_ID
FROM qry_MA_Auswahl_Alle
WHERE (((qry_MA_Auswahl_Alle.ID) Not In (Select MA_ID FROM [qry_EchtNeu_UnionSP_ohneSub])) AND ((qry_MA_Auswahl_Alle.Anstellungsart_ID)=3 Or (qry_MA_Auswahl_Alle.Anstellungsart_ID)=5));

