VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_N_MA_VA_Positionszuordnung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim iAnzMA As Long

Public Function VAOpen(iVA_Akt_Objekt_Kopf_ID As Long)
Dim strSQL As String

Me!cbo_Akt_Objekt_Kopf = iVA_Akt_Objekt_Kopf_ID
cbo_Akt_Objekt_Kopf_AfterUpdate
DoEvents
Me!Lst_MA_Zugeordnet.Requery

End Function

Private Sub btnPosNeu_Click()
fNeu_Pos
End Sub

Private Sub btnBack_PosKopfTl1_Click()
Dim iKID As Long
iKID = Get_Priv_Property("prp_VA_Akt_Objekt_ID")
DoCmd.OpenForm "frmTop_VA_Akt_Objekt_Kopf"
Form_frmTop_VA_Akt_Objekt_Kopf.VAOpen_ID iKID
DoCmd.Close acForm, "frm_N_MA_VA_Positionszuordnung", acSaveNo
End Sub

Private Sub btnPosList_PDF_Click()

Dim fn As String
Dim Dlen As Long
Dim dtfdate As Date
Dim Drive As String, DirName As String, fName As String, Ext As String
Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim iTable As Long
Dim i As Long
Dim stKurz As String

Dim iVA_ID As Long
Dim iVADatum_ID As Long

Dim strWD_Dateiname As String

iTable = 42

iVA_ID = Me!cbo_Akt_Objekt_Kopf.Column(2)
iVADatum_ID = Me!cboVADatum

stKurz = iVA_ID & "_" & iVADatum_ID
On Error Resume Next
i = Nz(TLookup("ZusatzNr", "tbl_Zusatzdateien", "TabellenID = 42 AND Kurzbeschreibung = '" & stKurz & "'"), 0)
On Error GoTo 0
If i > 0 Then
    CurrentDb.Execute ("DELETE * FROM tbl_Zusatzdateien WHERE ZusatzNr = " & i)
    DoEvents
End If

Call Set_Priv_Property("prp_Report1_Auftrag_ID", iVA_ID)
Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", iVADatum_ID)

strWD_Dateiname = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 9")) & "Pos Liste " & Me!cbo_Akt_Objekt_Kopf.Column(3) & ".pdf"

DoCmd.OutputTo acOutputReport, "rpt_VA_Akt_Posliste", "PDF", strWD_Dateiname

Sleep 1000
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    

Call FParsePath(strWD_Dateiname, Drive, DirName, fName, Ext)

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_Zusatzdateien")

    Dlen = fileLen(strWD_Dateiname)
    dtfdate = FileDateTime(strWD_Dateiname)

    rst.AddNew
        rst.fields(1) = iTable
        rst.fields(2) = iVA_ID
        rst.fields(3) = strWD_Dateiname
        rst.fields(4) = dtfdate
        rst.fields(5) = Dlen
        rst.fields(6) = Ext
        rst.fields(7) = stKurz
        rst.fields(8) = Dir(strWD_Dateiname)
        rst.fields(9) = 0
        rst.fields(10) = atCNames(1)
        rst.fields(11) = Date
        rst.fields(12) = atCNames(1)
        rst.fields(13) = Date
    rst.update

rst.Close
Set rst = Nothing

Application.FollowHyperlink strWD_Dateiname

End Sub

Private Sub btnRepeat_Click()
Me!AnzAusw = Null
Me!lstMA_Zusage.RowSource = Me!lstMA_Zusage.RowSource
Me!lstMA_Zusage.Requery
End Sub

Private Sub btnRepeatAus_Click()
Me!Lst_MA_Zugeordnet.RowSource = Me!Lst_MA_Zugeordnet.RowSource
Me!Lst_MA_Zugeordnet.Requery
End Sub

Private Sub Form_Current()
If Len(Trim(Nz(Me!cbo_Akt_Objekt_Kopf))) > 0 Then
    cbo_Akt_Objekt_Kopf_AfterUpdate
End If
End Sub

Public Sub cbo_Akt_Objekt_Kopf_AfterUpdate()

Dim strSQL As String
Dim strSuch1 As String

Dim iKID As Long

If Len(Trim(Nz(Me!cbo_Akt_Objekt_Kopf))) > 0 Then

    Call Set_Priv_Property("prp_VA_Akt_Objekt_ID", Me!cbo_Akt_Objekt_Kopf.Column(0))
    iKID = Me!cbo_Akt_Objekt_Kopf.Column(0)
    DoEvents
    
    iVA_ID = Me!cbo_Akt_Objekt_Kopf.Column(2)
    iVADatum_ID = Me!cbo_Akt_Objekt_Kopf.Column(1)
    Me!cboVADatum = iVADatum_ID
    
    strSQL = ""
    strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.MA_ID, [Nachname] & ' ' & [Vorname] AS MA_Name"
    strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
    strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum_ID)= " & iVADatum_ID & ")"
    strSQL = strSQL & " AND ((tbl_MA_VA_Zuordnung.MA_ID) Not In (SELECT MA_ID FROM qry_VA_Akt_MA_Pos_Zuo_OhneSub) And (tbl_MA_VA_Zuordnung.MA_ID)>0));"
    
    Me!lstMA_Zusage.RowSource = strSQL
    Me!lstMA_Zusage.Requery
    
    Me!List_Pos.RowSource = "qry_VA_Akt_Objekt_Pos"
    Me!List_Pos = Me!List_Pos.ItemData(1)
    Me!List_Pos.Requery
    
    'ID = 0  MA_ID = 1
    Me!Lst_MA_Zugeordnet.RowSource = "qry_VA_Akt_MA_Pos_Zuo_Alle"
    Me!Lst_MA_Zugeordnet.Requery
    
    strSuch1 = "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID
    iAnzMA = Nz(TSum("MA_Anzahl", "tbl_VA_Start", strSuch1), 0)
    
    If Nz(TCount("*", "tbl_VA_Akt_Objekt_Pos_MA", "VA_Akt_Objekt_Kopf_ID = " & iKID), 0) = 0 Then
        btnPosNeu_Click
    End If
    
End If
End Sub



Private Sub btnAddAll_Click()

    Dim var As Variant
    Dim strSQL As String
    
    Dim iVAStart_ID As Long
    Dim iVADatum_ID As Long
    Dim VADatum As Date
    Dim dtStart As Date
    Dim dtEnde As Date
    Dim iStatus_ID As Long  ' Ist derzeit immer 1 = Geplant
    Dim iMA_ID As Long
    Dim iVA_ID As Long
    Dim MVA_Start As Date
    Dim MVA_Ende As Date
    Dim iPosNr As Long
    Dim sPausenabzug As Single
    
    Dim strWhere As String
    
    Dim iOB_Pos_ID As Long
    Dim iOB_Kopf_ID As Long
    
    Dim i As Long
    Dim j As Long
    
    Dim db As DAO.Database
    Dim rst As DAO.Recordset
    
    Me!AnzAusw = Null
    Set db = CurrentDb

    'Es KANN nur immer einer selekted sein !!
    For Each var In Me!List_Pos.ItemsSelected
'    var = Me!List_Pos.ItemsSelected
        iOB_Pos_ID = Me!List_Pos.Column(0, var)
        iOB_Kopf_ID = Me!List_Pos.Column(1, var)
    Next var
    
    strWhere = "((tbl_VA_Akt_Objekt_Pos_MA.MA_ID=0) AND (tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID= " & iOB_Kopf_ID & ") AND (tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Pos_ID= " & iOB_Pos_ID & "))"
    strSQL = "SELECT * FROM tbl_VA_Akt_Objekt_Pos_MA WHERE " & strWhere
    Set rst = db.OpenRecordset(strSQL)
    
    With rst
        i = TCount("*", "tbl_VA_Akt_Objekt_Pos_MA", strWhere)
        If i > 0 Then
            For var = 1 To Me!lstMA_Zusage.ListCount - 1
                iMA_ID = Me!lstMA_Zusage.Column(0, var)
                    .Edit
                    .fields("MA_ID").Value = iMA_ID
                .update
                .MoveNext
                If .EOF Then
                    Exit For
                End If
            Next var
        End If
        .Close
    End With
    Set rst = Nothing
    
cbo_Akt_Objekt_Kopf_AfterUpdate
End Sub



Private Sub btnAddSelected_Click()
    Dim var As Variant
    Dim strSQL As String
    Dim strWhere As String
    
    Dim iOB_Pos_ID As Long
    Dim iOB_Kopf_ID As Long
    
    
    
    Dim iVAStart_ID As Long
    Dim iVADatum_ID As Long
    Dim VADatum As Date
    Dim dtStart As Date
    Dim dtEnde As Date
    Dim iStatus_ID As Long  ' Ist derzeit immer 1 = Geplant
    Dim iMA_ID As Long
    Dim iVA_ID As Long
    Dim MVA_Start As Date
    Dim MVA_Ende As Date
    Dim iPosNr As Long
    Dim sPausenabzug As Single
    Dim i As Long
    Dim j As Long
    
    
    Dim db As DAO.Database
    Dim rst As DAO.Recordset
    
    Me!AnzAusw = Null
    
    Set db = CurrentDb
        
    'Es KANN nur immer eine Poition selekted sein !!
    For Each var In Me!List_Pos.ItemsSelected
'    var = Me!List_Pos.ItemsSelected
        iOB_Pos_ID = Me!List_Pos.Column(0, var)
        iOB_Kopf_ID = Me!List_Pos.Column(1, var)
    Next var
    
    strWhere = "((tbl_VA_Akt_Objekt_Pos_MA.MA_ID=0) AND (tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Kopf_ID= " & iOB_Kopf_ID & ") AND (tbl_VA_Akt_Objekt_Pos_MA.VA_Akt_Objekt_Pos_ID= " & iOB_Pos_ID & "))"
    strSQL = "SELECT * FROM tbl_VA_Akt_Objekt_Pos_MA WHERE " & strWhere
    Set rst = db.OpenRecordset(strSQL)
    With rst
        i = TCount("*", "tbl_VA_Akt_Objekt_Pos_MA", strWhere)
        If i > 0 Then
            For Each var In Me!lstMA_Zusage.ItemsSelected
                iMA_ID = Me!lstMA_Zusage.Column(0, var)
                .Edit
                    .fields("MA_ID").Value = iMA_ID
                .update
                .MoveNext
                If .EOF Then
                    Exit For
                End If
            Next var
        End If
        .Close
    End With
    Set rst = Nothing
    
    cbo_Akt_Objekt_Kopf_AfterUpdate

End Sub

Private Function Test_selected(var) As Boolean

Dim bIstbereitsPl As Boolean
Dim iOK As Long
Dim bIsSub As Boolean
Dim MA_Name As String
Dim iMA_ID As Long
'Dim var
    
Test_selected = True
'var = Me!List_MA.ListIndex
If Me!List_MA.selected(var) = True Then
    bIstbereitsPl = (Len(Trim(Nz(Me!List_MA.Column(6, var)))) > 0)
    iMA_ID = Me!List_MA.Column(0, var)
    bIsSub = Me!List_MA.Column(1, var)
    MA_Name = Me!List_MA.Column(2, var)
    If bIstbereitsPl And Not bIsSub Then
        If Not vbOK = MsgBox("Mitarbeiter " & MA_Name & " ist nicht verfügbar, dennoch verplanen ?", vbCritical + vbOKCancel, "Achtung Doppelbelegung") Then
            Test_selected = False
        End If
    End If
End If

End Function

Private Sub btnAuftrag_Click()
Dim iVA_ID As Long
Dim iVADatum_ID As Long

iVA_ID = Me!cbo_Akt_Objekt_Kopf.Column(2)

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

If Len(Trim(Nz(iVA_ID))) = 0 Then
    DoCmd.OpenForm "frm_VA_Auftragstamm"
Else

    iVADatum_ID = Me!cboVADatum
    DoCmd.Close acForm, Me.Name
    DoCmd.OpenForm "frm_VA_Auftragstamm"
    Call Form_frm_VA_Auftragstamm.VAOpen(iVA_ID, iVADatum_ID)

End If
End Sub

Private Sub btnDelAll_Click()

Dim strSQL As String
Dim iKID As Long

    Me!AnzAusw = Null

    If Not vbOK = MsgBox("Alle verplanten Mitarbeiter von der PLanung entfernen ?", vbQuestion + vbOKCancel, "Achtung Alles Löschen, Sind Sie sicher ?") Then
        Exit Sub
    End If
    
    btnPosNeu_Click

    cbo_Akt_Objekt_Kopf_AfterUpdate

End Sub

Private Sub btnDelSelected_Click()

Dim strSQL As String

Dim i As Long
Dim var

    Me!AnzAusw = Null

    For Each var In Me!Lst_MA_Zugeordnet.ItemsSelected
        i = Me!Lst_MA_Zugeordnet.Column(0, var)
        CurrentDb.Execute ("UPDATE tbl_VA_Akt_Objekt_Pos_MA SET tbl_VA_Akt_Objekt_Pos_MA.MA_ID = 0 WHERE (((tbl_VA_Akt_Objekt_Pos_MA.ID)= " & i & "));")
    Next var

    cbo_Akt_Objekt_Kopf_AfterUpdate

End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub List_Pos_AfterUpdate()
Me!AnzAusw = Null
End Sub

Private Sub lstMA_Zusage_AfterUpdate()
Dim var
Dim i As Long
i = 0
For Each var In Me!lstMA_Zusage.ItemsSelected
    i = i + 1
Next var
Me!AnzAusw = i
End Sub

Private Sub MA_Typ_AfterUpdate()

Dim strSQL As String

Select Case Me!MA_Typ
  Case 1
    strSQL = ""
    strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.MA_ID, [Nachname] & ', ' & [Vorname] AS MA_Name"
    strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
    strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum_ID)= " & iVADatum_ID & ")"
    strSQL = strSQL & " AND ((tbl_MA_VA_Zuordnung.MA_ID) Not In (SELECT MA_ID FROM qry_VA_Akt_MA_Pos_Zuo) And (tbl_MA_VA_Zuordnung.MA_ID)>0));"
  Case 2
    strSQL = ""
    strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.MA_ID, [Nachname] & ', ' & [Vorname] AS MA_Name"
    strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
    strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum_ID)= " & iVADatum_ID & ")"
    strSQL = strSQL & " AND lcase(Left([Geschlecht],1)) = 'm'"
    strSQL = strSQL & " AND ((tbl_MA_VA_Zuordnung.MA_ID) Not In (SELECT MA_ID FROM qry_VA_Akt_MA_Pos_Zuo) And (tbl_MA_VA_Zuordnung.MA_ID)>0));"
  Case 3
    strSQL = ""
    strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.MA_ID, [Nachname] & ', ' & [Vorname] AS MA_Name"
    strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
    strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum_ID)= " & iVADatum_ID & ")"
    strSQL = strSQL & " AND lcase(Left([Geschlecht],1)) = 'w'"
    strSQL = strSQL & " AND ((tbl_MA_VA_Zuordnung.MA_ID) Not In (SELECT MA_ID FROM qry_VA_Akt_MA_Pos_Zuo) And (tbl_MA_VA_Zuordnung.MA_ID)>0));"
  Case Else
End Select

Me!lstMA_Zusage.RowSource = strSQL
Me!lstMA_Zusage.Requery
    

End Sub
Private Sub btnDaBaAus_Click()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End Sub

Private Sub btnDaBaEin_Click()
    DoCmd.SelectObject acTable, , True
End Sub

Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub

Private Sub btnRibbonEin_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub


Private Sub cboVADatum_AfterUpdate()
    If Len(Nz(Me!cboVADatum, "")) > 0 Then
        LoadPositionszuordnungByDatum Me!cboVADatum
    End If
End Sub
