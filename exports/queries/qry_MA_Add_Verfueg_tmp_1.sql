-- Query: qry_MA_Add_Verfueg_tmp_1
-- Type: 64
INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, IstAktiv, IstSubunternehmer, Anstellungsart_ID, IstVerfuegbar, MAName )
SELECT zqry_MA_Verfuegbarkeit.ID, zqry_MA_Verfuegbarkeit.IstAktiv, zqry_MA_Verfuegbarkeit.IstSubunternehmer, zqry_MA_Verfuegbarkeit.Anstellungsart_ID, zqry_MA_Verfuegbarkeit.istVerfuegbar, zqry_MA_Verfuegbarkeit.Name
FROM zqry_MA_Verfuegbarkeit
WHERE (((zqry_MA_Verfuegbarkeit.Name)<>""));

