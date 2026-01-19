-- Query: qryHlp_AlleFeiertage_Update
-- Type: 48
UPDATE (_tblAlleFeiertage_Meta INNER JOIN _tblAlleFeiertage ON [_tblAlleFeiertage_Meta].Feiertagsname = [_tblAlleFeiertage].Feiertagsname) INNER JOIN _tblAlleTage ON [_tblAlleFeiertage].JJJJMMTT = [_tblAlleTage].JJJJMMTT SET _tblAlleTage.Feiertagsname = [_tblAlleFeiertage].Feiertagsname, _tblAlleTage.IstFeiertag = True, _tblAlleTage.BBW = [BW], _tblAlleTage.BBY = [BY], _tblAlleTage.BBE = [BE], _tblAlleTage.BBB = [BB], _tblAlleTage.BHB = [HB], _tblAlleTage.BHH = [HH], _tblAlleTage.BHE = [HE], _tblAlleTage.BMV = [MV], _tblAlleTage.BNI = [NI], _tblAlleTage.BNW = [NW], _tblAlleTage.BRP = [RP], _tblAlleTage.BSL = [SL], _tblAlleTage.BSN = [SN], _tblAlleTage.BST = [ST], _tblAlleTage.BSH = [SH], _tblAlleTage.BTH = [TH];

