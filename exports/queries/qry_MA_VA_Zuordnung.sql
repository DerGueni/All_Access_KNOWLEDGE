-- Query: qry_MA_VA_Zuordnung
-- Type: 0
SELECT tbl_MA_VA_Zuordnung.*, IIf([tbl_Zeiterfassung].[CheckOut_Zeit] Is Not Null,2,IIf([tbl_Zeiterfassung].[CheckIn_Zeit] Is Not Null,1,0)) AS [Check-In]
FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_Zeiterfassung ON tbl_MA_VA_Zuordnung.ID = tbl_Zeiterfassung.ZUO_ID
ORDER BY tbl_MA_VA_Zuordnung.PosNr;

