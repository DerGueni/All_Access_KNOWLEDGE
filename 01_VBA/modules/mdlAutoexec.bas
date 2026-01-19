Attribute VB_Name = "mdlAutoexec"
Option Compare Database
Option Explicit

Public Function fAutoexec()

Dim sysPfad As String
Dim DocPfad As String
Dim DocVorlage As String

Dim strSQL As String
Dim strp1 As String

Dim MA As String
Dim MA_Start As String

Dim strDefault_Bundesland As String

Dim strLogin As String
Dim bImmer As Boolean

Dim strFE_V As String
Dim strBE_V As String

Dim BE_Email_PfadDB As String

Dim i As Long

'########### Server fuer HTML-Formulare starten
StartAPIServer      ' Port 5000 - Datenzugriff
StartVBABridge      ' Port 5002 - VBA-Funktionen

Call checkconnectAcc

ftestdbnamen

Sleep 20
DoEvents

'########### Default Bundeseslandsabfrage erzeugenstrDefault_Bundesland = Get_Priv_Property("Default_Bundesland")

strSQL = ""
strSQL = strSQL & "SELECT JJJJMMTT, Werkname, dtDatum, IstFeiertag, Feiertagsname, JahrNr, Quartal, MonatNr, TagNr, Wochentag, KW_D, JJJJMM,"
strSQL = strSQL & " JJJJKW, JJJJQrt, KW_US, WN_KalMon, WN_KalTag, Arbeitszeit, LfdTagNrAcc,"
strSQL = strSQL & "B" & strDefault_Bundesland & " as Landesfeiertag, F" & strDefault_Bundesland & " AS Landesferien"
strSQL = strSQL & " FROM _tblAlleTage;"

Call CreateQuery(strSQL, "qryAlleTage_Default")

Sleep 20
DoEvents

Call Set_Priv_Property("prp_StartDatum_Uebersicht", Date)
Call Set_Priv_Property("prp_Dienstpl_StartDatum", Date)
'Call Set_Priv_Property("prp_Ue_Oeffen", 2)

Sleep 20
DoEvents

'Call Set_Priv_Property("prp_CONSYS_GrundPfad_Siegert", Get_Priv_Property("prp_CONSYS_GrundPfad"))
If (atCNames(1) = "Klaus" And atCNames(2) = "ASTERIX") Or (atCNames(1) = "bobd" And atCNames(2) = "TROUBADIX") Then
    If Get_Priv_Property("prp_CONSYS_GrundPfad") <> Get_Priv_Property("prp_CONSYS_GrundPfad_Obd") Then
        Call Set_Priv_Property("prp_CONSYS_GrundPfad", Get_Priv_Property("prp_CONSYS_GrundPfad_Obd"))
        BE_Email_PfadDB = Get_Priv_Property("prp_CONSYS_BE_eMail_Obd")
        Call CopyUsr_verb("tbl_eMail_Import", BE_Email_PfadDB)
    End If
    fSHowHiddenObjSet True
Else
    If Get_Priv_Property("prp_CONSYS_GrundPfad") <> Get_Priv_Property("prp_CONSYS_GrundPfad_CONSEC") Then
        Call Set_Priv_Property("prp_CONSYS_GrundPfad", Get_Priv_Property("prp_CONSYS_GrundPfad_CONSEC"))
        BE_Email_PfadDB = Get_Priv_Property("prp_CONSYS_BE_eMail_CONSEC")
        Call CopyUsr_verb("tbl_eMail_Import", BE_Email_PfadDB)
    End If
    fSHowHiddenObjSet False
End If

Sleep 20
DoEvents

DoEvents
strLogin = atCNames1(1)
bImmer = Nz(TLookup("int_Immer", "_tblEigeneFirma_Mitarbeiter", "int_Login = '" & strLogin & "'"), 0)
If bImmer Then
    DoCmd.OpenForm "frmTop_Login", , , , , acDialog
Else
    Call Set_Priv_Property("prp_Loginname", strLogin)
End If
DoEvents

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

Sleep 20
DoEvents

fExcel_Vorlagen_Schreiben

Sleep 200
DoEvents

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

'Aufgelaufene eMails zuordnen
'All_eMail_Update

'Hauptmen� �ffnen
DoCmd.OpenForm "frm_va_auftragstamm"
'DoCmd.OpenForm "frm_DP_Dienstplan_Objekt"

End Function

Function fVAUpd_AllSI()
If table_exist("tbltmp_VA_All_SollIst") Then DoCmd.DeleteObject acTable, "tbltmp_VA_All_SollIst"
DoEvents
CurrentDb.Execute ("SELECT tbl_VA_AnzTage.VA_ID, Sum(tbl_VA_AnzTage.TVA_Soll) AS SummevonTVA_Soll, Sum(tbl_VA_AnzTage.TVA_Ist) AS SummevonTVA_Ist, 0 As SI INTO tbltmp_VA_All_SollIst FROM tbl_VA_AnzTage GROUP BY tbl_VA_AnzTage.VA_ID;")
CurrentDb.Execute ("UPDATE tbltmp_VA_All_SollIst SET tbltmp_VA_All_SollIst.SI = [SummevonTVA_Soll]=[SummevonTVA_Ist];")
CurrentDb.Execute ("UPDATE tbltmp_VA_All_SollIst SET tbltmp_VA_All_SollIst.SI = 0 WHERE [SummevonTVA_Soll]= 0;")
CurrentDb.Execute ("UPDATE tbltmp_VA_All_SollIst INNER JOIN tbl_VA_Auftragstamm ON tbltmp_VA_All_SollIst.VA_ID = tbl_VA_Auftragstamm.ID SET tbl_VA_Auftragstamm.Veranst_Status_ID = 2 WHERE (((tbltmp_VA_All_SollIst.SI)=-1));")
If table_exist("tbltmp_VA_All_SollIst") Then DoCmd.DeleteObject acTable, "tbltmp_VA_All_SollIst"
DoEvents
End Function


Function ftestdbnamen()
Dim strFE_V As String
Dim strBE_V As String
Dim i As Long
Dim j As Long

strBE_V = Dir(Nz(TLookup("Database", "qrymdbTable2", "ObjName = '_tblEigeneFIrma'")))
strFE_V = Dir(CurrentDb.Name)

i = InStrRev(strBE_V, ".")
strBE_V = Left(strBE_V, i - 1)
i = InStrRev(strBE_V, "_")
strBE_V = Mid(strBE_V, i + 1)

i = InStrRev(strFE_V, ".")
strFE_V = Left(strFE_V, i - 1)
i = InStrRev(strFE_V, "_")
strFE_V = Mid(strFE_V, i + 1)

Call Set_Priv_Property("prp_V_FE", strFE_V)
Call Set_Priv_Property("prp_V_BE", strBE_V)

If Len(Trim(Nz(strBE_V))) = 0 Or Len(Trim(Nz(strFE_V))) = 0 Then
    MsgBox "Frontend oder Backendnamen entsprechen nicht den Vorgaben"
    DoCmd.Quit acQuitSaveAll
End If

End Function
