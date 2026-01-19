SELECT [_tblAlleTage].dtDatum, [_tblAlleTage].JahrNr, [_tblAlleTage].MonatNr, [_tblAlleTage].TagNr, [_tblAlleTage].Wochentag, (Right([JJJJKW],2))+0 AS KW, "w1w" & [WN_KalMon] AS BtnWk, "btn1Tg" & [Wn_KalMon] & [Wochentag] AS BtnTg, [_tblAlleTage].BBW, [_tblAlleTage].BBY, [_tblAlleTage].BBE, [_tblAlleTage].BBB, [_tblAlleTage].BHB, [_tblAlleTage].BHH, [_tblAlleTage].BHE, [_tblAlleTage].BMV, [_tblAlleTage].BNI, [_tblAlleTage].BNW, [_tblAlleTage].BRP, [_tblAlleTage].BSL, [_tblAlleTage].BSN, [_tblAlleTage].BST, [_tblAlleTage].BSH, [_tblAlleTage].BTH, [_tblAlleTage].FBW, [_tblAlleTage].FBY, [_tblAlleTage].FBE, [_tblAlleTage].FBB, [_tblAlleTage].FHB, [_tblAlleTage].FHH, [_tblAlleTage].FHE, [_tblAlleTage].FMV, [_tblAlleTage].FNI, [_tblAlleTage].FNW, [_tblAlleTage].FRP, [_tblAlleTage].FSL, [_tblAlleTage].FSN, [_tblAlleTage].FST, [_tblAlleTage].FSH, [_tblAlleTage].FTH
FROM _tblAlleTage
WHERE ((([_tblAlleTage].Werkname)="Std"))
ORDER BY [_tblAlleTage].JJJJMMTT;

