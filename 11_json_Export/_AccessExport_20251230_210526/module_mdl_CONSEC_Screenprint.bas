Option Compare Database
Option Explicit

'Public Function WoUmsch(iums As Long)  '' 1 = Tag    2 = Woche    3 = Monat
'Public Function SetStartdatum(dt As Date)
'Public Function Button_Next()
'Public Function Button_Prev()
'Public Function ScreenPrint()
'
'Function Monatsdruck_Steuer()
'Dim dt As Date
'Dim strSQL As String
'Dim Ueber_Pfad As String
'
'Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 8"))
'
'SendKeys "{F11}"
'DoCmd.OpenForm "frm_UE_Uebersicht"
'DoEvents
'Sleep 1000
'DoEvents
''Form_frm_UE_Uebersicht.ScreenPrint
''DoEvents
'Sleep 1000
'DoEvents
'Call Form_frm_UE_Uebersicht.WoUmsch(1)  '' 1 = Tag    2 = Woche    3 = Monat
'DoEvents
'Sleep 1000
'DoEvents
'Form_frm_UE_Uebersicht.ScreenPrint
'DoEvents
'Sleep 1000
'DoEvents
'Form_frm_UE_Uebersicht.ScreenPrint
'DoEvents
'Sleep 1000
'DoEvents
'Call Form_frm_UE_Uebersicht.WoUmsch(3)  '' 1 = Tag    2 = Woche    3 = Monat
'DoEvents
'Sleep 1000
'DoEvents
'Form_frm_UE_Uebersicht.ScreenPrint
'DoEvents
'Sleep 1000
'DoEvents
'DoCmd.Close acForm, "frm_UE_Uebersicht", acSaveNo
'DoEvents
'Sleep 1000
'SendKeys "{F11}"
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents
''DoCmd.Quit acQuitSaveNone
'
'strSQL = ""
'strSQL = strSQL & "SELECT tbl_VA_AnzTage.VADatum, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_Auftragstamm.*"
'strSQL = strSQL & " FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
'strSQL = strSQL & " WHERE  (((tbl_VA_AnzTage.VADatum) Between Date() And Date()+6))"
'strSQL = strSQL & " ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Auftrag;"
'CreateQuery strSQL, "qry_Report_Auftrag_Sort"
'
'DoCmd.OutputTo acOutputReport, "rpt_Auftrag", "PDF", Ueber_Pfad & "W_" & Date & ".pdf"
'DoEvents
'Sleep 1000
'DoEvents
'strSQL = ""
'strSQL = strSQL & " SELECT tbl_VA_AnzTage.VADatum, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_Auftragstamm.*"
'strSQL = strSQL & " FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
'strSQL = strSQL & " ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von, tbl_VA_Auftragstamm.Auftrag;"
'CreateQuery strSQL, "qry_Report_Auftrag_Sort"
'
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents
'
'End Function