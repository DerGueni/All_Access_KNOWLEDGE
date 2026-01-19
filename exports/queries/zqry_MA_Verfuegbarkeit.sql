-- Query: zqry_MA_Verfuegbarkeit
-- Type: 0
SELECT ztbl_MA_Verfuegbarkeit.MA_ID AS ID, tbl_MA_Mitarbeiterstamm.IstSubunternehmer, [Nachname] & " " & [Vorname] AS Name, IIf([stunden]<>0,IIf(Len([stunden])=3,[Stunden],IIf(Len([stunden])=2,Space(Len(Format([Stunden],'00'))) & [Stunden],Space(Len(Format([Stunden],'   0'))) & [Stunden])),'') AS Std, ztbl_MA_Verfuegbarkeit.Beginn, ztbl_MA_Verfuegbarkeit.Ende, ztbl_MA_Verfuegbarkeit.Grund, tbl_MA_Mitarbeiterstamm.Anstellungsart_ID, tbl_MA_Mitarbeiterstamm.IstAktiv, fctround(zMA_Monat_SumNetStd([ID],[VGL_Start]),0) AS Stunden, IIf(IsNull([Grund]),True,False) AS istVerfuegbar, IIf([ztbl_MA_Verfuegbarkeit].[Grund] Like "Plan*",-1,IIf([ztbl_MA_Verfuegbarkeit].[Grund] Like "Absage*",-1,0)) AS istVerplant, tbl_MA_Mitarbeiterstamm.Hat_keine_34a
FROM tbltmp_Vergleichszeiten, ztbl_MA_Verfuegbarkeit INNER JOIN tbl_MA_Mitarbeiterstamm ON ztbl_MA_Verfuegbarkeit.[MA_ID] = tbl_MA_Mitarbeiterstamm.ID;

