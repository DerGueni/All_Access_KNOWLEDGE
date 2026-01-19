UPDATE Acc_SQL_tblVerknuepfungstabellen, _tblConnections_Client SET Acc_SQL_tblVerknuepfungstabellen.SQLConnectionstring = [_tblConnections_Client].[SQLConnectionstring]
WHERE ((([_tblConnections_Client].[ID])=1));

