VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_eMail_NichtStandardAntwort"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Zu_Absage_AfterUpdate()

Dim iZuo As Long
Dim snetto As Single
Dim iPosNr As Long

Dim iZuo1 As Long
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim iVAStart_ID As Long
Dim iMA_ID As Long
Dim iID As Long

Dim strSQL As String

iID = Me!ID

If Me!Zu_Absage = -1 Then

    strSQL = "UPDATE tbl_MA_VA_Planung SET tbl_MA_VA_Planung.Status_ID = 3 WHERE (((tbl_MA_VA_Planung.VAStart_ID)= " & Me!VAStart_ID & ") AND ((tbl_MA_VA_Planung.MA_ID)= " & Me!MA_ID & "));"
    CurrentDb.Execute (strSQL)
    
    iZuo = TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!VADatum_ID & " AND VAStart_ID = " & Me!VAStart_ID & " AND MA_ID = 0")
    If iZuo > 0 Then
        iZuo = TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!VADatum_ID & " AND VAStart_ID = " & Me!VAStart_ID & " AND MA_ID = 0")
        snetto = Nz(TLookup("MA_Netto_Std2", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
        iPosNr = Nz(TLookup("PosNr", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
    
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_VA_Zuordnung, tbl_MA_VA_Planung SET"
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_ID = " & Me!MA_ID & ", "
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_von = '" & atCNames(1) & "', "
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_am = Now()"
        strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));"
        
        CurrentDb.Execute (strSQL)
        
        'tbl_VA_AnzTage Updaten
        DoEvents
        Call VA_AnzTage_Upd(Me!VA_ID, Me!VADatum_ID)
        DoEvents
        
    Else
    
        iMA_ID = Me!MA_ID
        iVA_ID = Me!VA_ID
        iVADatum_ID = Me!VADatum_ID
        iVAStart_ID = Me!VAStart_ID
    
        iZuo = Nz(TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID), 0)
        iPosNr = Nz(TMax("PosNr", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0) + 1
        
        strSQL = ""
        strSQL = strSQL & "INSERT INTO tbl_MA_VA_Zuordnung ( VA_ID, VADatum_ID, VAStart_ID, PosNr, MA_ID, MA_Start, MA_Ende,"
        strSQL = strSQL & " Erst_von, Erst_am, Aend_von, Aend_am, VADatum, MVA_Start, MVA_Ende )"
        strSQL = strSQL & " SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, tbl_MA_VA_Zuordnung.VAStart_ID, " & iPosNr & " AS Ausdr1,"
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende,"
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Erst_von, tbl_MA_VA_Zuordnung.Erst_am, tbl_MA_VA_Zuordnung.Aend_von,"
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_am , tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.MVA_Start, tbl_MA_VA_Zuordnung.MVA_Ende"
        strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));"

        CurrentDb.Execute (strSQL)
        
        DoEvents
        iZuo = TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " AND PosNr = " & iPosNr)
        
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_VA_Zuordnung, tbl_MA_VA_Planung SET"
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_ID = " & iMA_ID & ", "
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_von = '" & atCNames(1) & "', "
        strSQL = strSQL & " tbl_MA_VA_Zuordnung.Aend_am = Now()"
        strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));"
        
        CurrentDb.Execute (strSQL)
        
        'tbl_VA_AnzTage Updaten
        DoEvents
        Call VA_AnzTage_Upd(iVA_ID, iVADatum_ID)
        DoEvents
        
    End If
        
    Me.Parent.Befehl38.SetFocus
    DoEvents
    CurrentDb.Execute ("UPDATE tbl_eMail_Import SET tbl_eMail_Import.IstErledigt = -1 WHERE ((tbl_eMail_Import.ID)= " & iID & ");")
'    CurrentDb.Execute ("DELETE * FROM tbl_eMail_Import WHERE ID = " & iID)
    
    DoEvents
    
    'Access Bug 3fdach gemoppelt !!!
    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource = Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource
    DoEvents
    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.Requery

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource = Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource
    DoEvents
    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.Requery
    
    MsgBox "Mitarbeiterzusage erledigt, MA hat PosNr " & iPosNr
    
ElseIf Me!Zu_Absage = 0 Then

    strSQL = "UPDATE tbl_MA_VA_Planung SET tbl_MA_VA_Planung.Status_ID = 4 WHERE (((tbl_MA_VA_Planung.VAStart_ID)= " & Me!VAStart_ID & ") AND ((tbl_MA_VA_Planung.MA_ID)= " & Me!MA_ID & "));"
    CurrentDb.Execute (strSQL)
    
    Me.Parent.Befehl38.SetFocus
    DoEvents
    
    CurrentDb.Execute ("UPDATE tbl_eMail_Import SET tbl_eMail_Import.IstErledigt = -1 WHERE ((tbl_eMail_Import.ID)= " & iID & ");")
'    CurrentDb.Execute ("DELETE * FROM tbl_eMail_Import WHERE ID = " & iID)
    
    DoEvents
    
    'Access Bug 3fdach gemoppelt !!!
    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource = Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource
    DoEvents
    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.Requery

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource = Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.recordSource
    DoEvents
    Forms!frmTop_eMail_MA_ID_NGef!sub_eMail_NichtStandardAntwort.Form.Requery
    
End If

End Sub
