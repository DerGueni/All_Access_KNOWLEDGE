SELECT [_tblFarben].FarbID, [_tblFarben].Verwendung, [_tblFarben].FarbNrHint, [_tblFarben].FarbNrText
FROM _tblFarben
WHERE ((([_tblFarben].FarbID) In (18,4,11,7,8)))
ORDER BY [_tblFarben].FarbID;

