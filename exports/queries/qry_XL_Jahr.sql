-- Query: qry_XL_Jahr
-- Type: 0
SELECT qry_XL_Jahr_Tl1.MA_ID, qry_XL_Jahr_Tl1.AktJahr, qry_XL_Jahr_Tl2.AktMon, qry_XL_Jahr_Tl1.Monat, qry_XL_Jahr_Tl1.Std, qry_XL_Jahr_Tl1.[Rest aus Vormonat], qry_XL_Jahr_Tl1.[Std gesamt], qry_XL_Jahr_Tl1.[Überlauf Std], qry_XL_Jahr_Tl1.verrechnet, qry_XL_Jahr_Tl1.[Info Brutto €], qry_XL_Jahr_Tl1.[Lohnsteuer €], qry_XL_Jahr_Tl1.[Info Netto €], qry_XL_Jahr_Tl1.[Info netto ges €], qry_XL_Jahr_Tl1.[MA Auszahlung €], qry_XL_Jahr_Tl1.[Auszahlung von], qry_XL_Jahr_Tl1.[Restguthaben €], qry_XL_Jahr_Tl2.Fahrtkosten, qry_XL_Jahr_Tl2.[Rücklage 34a], qry_XL_Jahr_Tl2.Rückzahlung, qry_XL_Jahr_Tl2.Abschlag, qry_XL_Jahr_Tl2.Fernbleiben, qry_XL_Jahr_Tl2.Kaution, qry_XL_Jahr_Tl2.Sonstiges, qry_XL_Jahr_Tl2.Grund, qry_XL_Jahr_Tl2.[RV freiw]
FROM qry_XL_Jahr_Tl1 INNER JOIN qry_XL_Jahr_Tl2 ON (qry_XL_Jahr_Tl1.Monat = qry_XL_Jahr_Tl2.Monat) AND (qry_XL_Jahr_Tl1.AktJahr = qry_XL_Jahr_Tl2.AktJahr) AND (qry_XL_Jahr_Tl1.MA_ID = qry_XL_Jahr_Tl2.MA_ID);

