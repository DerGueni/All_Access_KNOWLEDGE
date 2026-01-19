-- Query: qryConnCrea1
-- Type: 48
UPDATE _tblConnections_Client INNER JOIN _YesNo ON [_tblConnections_Client].SQLTrustedConn = [_YesNo].JnValue SET _tblConnections_Client.SQLConnectionstring = "ODBC;Driver={" & [ODBC_Driver] & "};SERVER=" & [SQLServername] & [SQLInstancename] & ";DATABASE=" & [SQLDatabasename] & ";Trusted_Connection=" & [JNText] & ";";

