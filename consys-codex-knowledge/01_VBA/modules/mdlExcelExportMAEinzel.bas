Attribute VB_Name = "mdlExcelExportMAEinzel"
Option Compare Database
Option Explicit

Function Monat_Erz(iAktMon As Long, iAktJahr As Long, MA_ID As Long)

Dim strSQL As String

Call CreateQuery("SELECT " & iAktJahr & " AS AktJahr, " & iAktMon & " AS AktMon FROM _tblInternalSystemFE;", "qry_JB_MA_AktMon")

DoEvents

CurrentDb.Execute ("Delete * FROM tbltmp_MA_Monat_Einzel;")

DoEvents

strSQL = ""
strSQL = "INSERT INTO tbltmp_MA_Monat_Einzel ( AktDat, MA_ID ) SELECT dtDatum, " & MA_ID & " AS Aus1 FROM qry_Exl_Tag ORDER BY dtDatum;"
Call CreateQuery(strSQL, "qry_Exl_MA_0")
DoEvents
CurrentDb.Execute ("qry_Exl_MA_0")

DoEvents

CurrentDb.Execute ("qry_Exl_Upd_Mo1")

DoEvents
CurrentDb.Execute ("qry_Exl_Upd_Mo2")

DoEvents

strSQL = ""
strSQL = strSQL & "SELECT tbltmp_MA_Monat_Einzel.MA_ID, tbltmp_MA_Monat_Einzel.VAStart_ID, tbltmp_MA_Monat_Einzel.VA_ID, tbltmp_MA_Monat_Einzel.AktDat"
strSQL = strSQL & " FROM tbltmp_MA_Monat_Einzel"
strSQL = strSQL & " WHERE (((tbltmp_MA_Monat_Einzel.MA_ID)= " & MA_ID & ") AND ((tbltmp_MA_Monat_Einzel.VA_ID)>0));"

Call CreateQuery(strSQL, "qry_Exl_MA_1")

strSQL = ""
strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.VADatum"
strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung"
strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.MA_ID)= " & MA_ID & ") AND ((Year([VADatum]))= " & iAktJahr & ") AND ((Month([VADatum]))= " & iAktMon & "));"

Call CreateQuery(strSQL, "qry_Exl_MA_2")

strSQL = ""
strSQL = strSQL & "SELECT qry_Exl_MA_2.*"
strSQL = strSQL & " FROM qry_Exl_MA_2 LEFT JOIN qry_Exl_MA_1 ON (qry_Exl_MA_2.MA_ID = qry_Exl_MA_1.MA_ID) AND (qry_Exl_MA_2.VAStart_ID = qry_Exl_MA_1.VAStart_ID)"
strSQL = strSQL & " WHERE (((qry_Exl_MA_1.VAStart_ID) Is Null));"

Call CreateQuery(strSQL, "qry_Exl_MA_3")

DoEvents
CurrentDb.Execute ("qry_Exl_MA_4")

DoEvents
CurrentDb.Execute ("qry_Exl_Upd_Mo2")

DoEvents

End Function
