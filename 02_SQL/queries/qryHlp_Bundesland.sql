SELECT [_tblBundesLand].BundeslandID, [_tblBundesLand].BundeslandName
FROM _tblBundesLand
WHERE ((([_tblBundesLand].Staat)="D"))
ORDER BY [_tblBundesLand].BundeslandName;

