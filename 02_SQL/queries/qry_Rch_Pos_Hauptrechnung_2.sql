UPDATE tbltmp_Position SET tbltmp_Position.PosNr = DCount("ID","tbltmp_Position","ID < " & [ID])+1;

