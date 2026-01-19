TRANSFORM Sum(zqry_MA_Stunden_Abgleich.Stunden_Consys) AS SummeVonStunden_Consys
SELECT zqry_MA_Stunden_Abgleich.Name, Sum(zqry_MA_Stunden_Abgleich.Stunden_Consys) AS Gesamt
FROM zqry_MA_Stunden_Abgleich
WHERE zqry_MA_Stunden_Abgleich.Jahr = [Formulare]![frm_N_MA_Monatsuebersicht]![cboJahr]
    AND zqry_MA_Stunden_Abgleich.Anstellungsart_ID = [Formulare]![frm_N_MA_Monatsuebersicht]![cboAnstellungsart]
GROUP BY zqry_MA_Stunden_Abgleich.Name
PIVOT Format([Monat],"00") & ". " & Choose([Monat],"Jan","Feb","Mrz","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez");

