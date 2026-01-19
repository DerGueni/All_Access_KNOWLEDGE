-- Query: qryHlp_tbl_Hilfe_Ja_Setzen_Wenn_aktuell
-- Type: 48
UPDATE _tbl_Hilfe INNER JOIN qrymdbForm ON [_tbl_Hilfe].Formularname = qrymdbForm.ObjName SET _tbl_Hilfe.jn = True;

