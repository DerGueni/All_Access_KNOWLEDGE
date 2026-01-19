-- Query: qry_Excel_Export_Teil2_Org
-- Type: 0
SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.MA_Anzahl AS Anz_MA, tbl_VA_Start.VA_Start AS vonStr, tbl_VA_Start.VA_Ende AS bisStr, CStr(Nz(timeberech_G([VADatum],[VA_Start],[VA_Ende]))) AS Anz_Stdstr, Trim(Nz([VA_Treffpunkt] & " " & Format([VA_Zeitpunkt],"Short Time"))) AS Info
FROM tbl_VA_Start;

