SELECT ztbl_MA_ZK_Korrekturen.*, DateSerial(Year("01." & [Monat] & "." & [Jahr]),Month("01." & [Monat] & "." & [Jahr])+1,1-1) AS vonDat
FROM ztbl_MA_ZK_Korrekturen;

