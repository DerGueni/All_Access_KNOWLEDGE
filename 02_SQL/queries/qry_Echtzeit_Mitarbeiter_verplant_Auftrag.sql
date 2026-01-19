SELECT tbl_MA_Mitarbeiterstamm.*, qry_Echtzeit_Mitarbeiter_verplant.MVA_Start, qry_Echtzeit_Mitarbeiter_verplant.MVA_Ende, qry_Echtzeit_Mitarbeiter_verplant.Grund, fctRound(MA_Monat_SumNetStd([ID],#6/29/2015#),0) AS MA_Std_Ges
FROM tbl_MA_Mitarbeiterstamm LEFT JOIN qry_Echtzeit_Mitarbeiter_verplant ON tbl_MA_Mitarbeiterstamm.ID = qry_Echtzeit_Mitarbeiter_verplant.MA_ID;

