-- Query: qry_MA_Nachname_Proper
-- Type: 48
UPDATE tbl_MA_Mitarbeiterstamm SET tbl_MA_Mitarbeiterstamm.Nachname = Proper([Nachname]);

