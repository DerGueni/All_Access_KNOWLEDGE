-- Query: qryConnCrea2
-- Type: 48
UPDATE _tblConnections_Client SET [_tblConnections_Client].SQLConnectionstring = [SQLConnectionstring] & "UID=" & [SQLUser] & ";PWD=" & [SQLPasswd] & ";"
WHERE ((([_tblConnections_Client].[SQLTrustedConn])=False));

