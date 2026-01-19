-- Query: qry_JB_MA_InfBrutto_RV_Upd
-- Type: 48
UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.InfBrutto = fctRound([HabVerr]*MA_StdLohn([MA_ID])), tbl_MA_Jahresuebersicht.RV = MA_RV_Betrag([MA_ID]);

