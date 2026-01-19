SELECT tbl_MA_Mitarbeiterstamm.*, fctRound(MA_Monat_SumNetStd([ID],#6/29/2015#),0) AS MA_Std_Ges
FROM tbl_MA_Mitarbeiterstamm
WHERE (((tbl_MA_Mitarbeiterstamm.ID) Not In (SELECT MA_ID FROM qry_Echtzeit_Mitarbeiter_verplant)));

