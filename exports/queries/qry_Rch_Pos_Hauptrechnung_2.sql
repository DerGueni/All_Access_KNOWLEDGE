-- Query: qry_Rch_Pos_Hauptrechnung_2
-- Type: 48
UPDATE tbltmp_Position SET tbltmp_Position.PosNr = DCount("ID","tbltmp_Position","ID < " & [ID])+1;

