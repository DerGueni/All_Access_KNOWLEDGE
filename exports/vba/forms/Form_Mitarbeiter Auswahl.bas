VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_Mitarbeiter Auswahl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim strSQL_Org As String
Dim iObjekt_ID As Long


Public Function VAOpen(iVA_ID As Long, iVADatum_ID As Long)
Dim strSQL As String

Me!VA_ID = iVA_ID
strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & iVA_ID & ")) ORDER BY ID;"
Me!cboVADatum.RowSource = strSQL
Me!cboVADatum = iVADatum_ID
cboVADatum_AfterUpdate
'MA_Selektion_AfterUpdate
DoEvents
End Function

Private Function Soll_Plan_Ist_Ges(iVA_ID As Long, iVADatum_ID As Long) As String
Dim iSoll As Long
Dim iPlan As Long
Dim iIst As Long

iSoll = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID))
'iPlan = Nz(TCount("*", "tbl_MA_VA_Planung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND Status_ID > 0 and Status_ID < 3 "))
iIst = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND MA_ID > 0"))
Soll_Plan_Ist_Ges = iIst & " / " & iSoll

If iIst = iSoll Then
    Me!btnAddZusage.Enabled = False
Else
    Me!btnAddZusage.Enabled = True
End If

End Function

'
'Private Sub btnAddAll_Click()
'
'    Dim var As Variant
'    Dim strSQL As String
'
'    Dim iVAStart_ID As Long
'    Dim iVADatum_ID As Long
'    Dim VADatum As Date
'    Dim dtStart As Date
'    Dim dtEnde As Date
'    Dim iStatus_ID As Long  ' Ist derzeit immer 1 = Geplant
'    Dim iMA_ID As Long
'    Dim iVA_ID As Long
'    Dim MVA_Start As Date
'    Dim MVA_Ende As Date
'    Dim iPosNr As Long
'    Dim sPausenabzug As Single
'
'    Dim db As DAO.Database
'    Dim rst As DAO.Recordset
'
'    iVAStart_ID = Me!lstZeiten
'    iVADatum_ID = Me!cboVADatum
'    VADatum = Me!cboVADatum.Column(1)
'    dtStart = Me!lstZeiten.Column(2)
'    dtEnde = Me!lstZeiten.Column(3)
'    dtStart = dtStart - Fix(dtStart)
'    dtEnde = dtEnde - Fix(dtEnde)
'    iStatus_ID = 1
'    iVA_ID = Me!VA_ID
'    MVA_Start = Startzeit_G(VADatum, dtStart)
'    MVA_Ende = Endezeit_G(VADatum, dtStart, dtEnde)
'
'    sPausenabzug = Get_Priv_Property("prp_Pausenabzug")
'
'    Set db = CurrentDb
'    Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_MA_VA_Planung;")
'
'    ' Listbox.column(Spalte, Zeile) <0,0>
'    ' For Each var In Me!MeineListbox.ItemsSelected
'
'    For var = 1 To Me!List_MA.ListCount - 1
'        iMA_ID = Me!List_MA.Column(0, var)
'        If Test_selected(var) Then
'            iPosNr = Nz(TMax("PosNr", "tbl_MA_VA_Planung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0) + 1
'            With rst
'                .AddNew
'                    .Fields("VA_ID").Value = iVA_ID
'                    .Fields("VADatum_ID").Value = iVADatum_ID
'                    .Fields("VAStart_ID").Value = iVAStart_ID
'                    .Fields("PosNr").Value = iPosNr
'                    .Fields("VA_Start").Value = dtStart
' '                   .Fields("VA_Ende").Value = dtEnde
'                    .Fields("MA_ID").Value = iMA_ID
'                    .Fields("Status_ID").Value = iStatus_ID
'                    .Fields("Erst_von").Value = atCNames(1)
'                    .Fields("Erst_am").Value = Now()
'                    .Fields("Aend_von").Value = atCNames(1)
'                    .Fields("Aend_am").Value = Now()
'                    .Fields("VADatum").Value = VADatum
'                    .Fields("MVA_Start").Value = MVA_Start
'                    .Fields("MVA_Ende").Value = MVA_Ende
'                    .Fields("Bemerkungen").Value = ""
' '                   .Fields("MA_Brutto_Std2").Value = fctRound(timeberech_G(VADatum, dtStart, dtEnde), 2)
' '                   .Fields("MA_Netto_Std2").Value = fctRound((.Fields("MA_Brutto_Std2").Value * sPausenabzug), 2)
'                .Update
'            End With
'        End If
'        Me.List_MA.Selected(var) = False
'        DoEvents
'    Next var
'
'    rst.Close
'    Set rst = Nothing
'
'    strSQL = ""
'    strSQL = "SELECT * FROM qry_Mitarbeiter_Geplant WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum
'    Me!lstMA_Plan.RowSource = strSQL
'    Me!lstMA_Plan.Requery
'    DoEvents
'    Me!List_MA.RowSource = Me!List_MA.RowSource
'
'    DoEvents
'    DBEngine.Idle dbRefreshCache
'    DBEngine.Idle dbFreeLocks
'    DoEvents
'
'End Sub
'


Private Sub btnAddSelected_Click()
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
    
    Dim db As DAO.Database
    Dim rst As DAO.Recordset
    
    iVAStart_ID = Me!lstZeiten
    iVADatum_ID = Me!cboVADatum
    VADatum = Me!cboVADatum.Column(1)
    dtStart = Me!lstZeiten.Column(2)
'    dtEnde = Me!lstZeiten.Column(3)
    dtStart = dtStart - Fix(dtStart)
'    dtEnde = dtEnde - Fix(dtEnde)
    iStatus_ID = 1
    iVA_ID = Me!VA_ID
    MVA_Start = Startzeit_G(VADatum, dtStart)
    MVA_Ende = Endezeit_G(VADatum, dtStart, Me!DienstEnde)
'    sPausenabzug = Get_Priv_Property("prp_Pausenabzug")
    
    Set db = CurrentDb
    Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_MA_VA_Planung;")
    
    ' Listbox.column(Spalte, Zeile) <0,0>
    ' For Each var In Me!MeineListbox.ItemsSelected

    For Each var In Me!List_MA.ItemsSelected
        
        iMA_ID = Me!List_MA.Column(0, var)
                        
        If Test_selected(var) Then
            iPosNr = Nz(TMax("PosNr", "tbl_MA_VA_Planung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0) + 1
            With rst
                .AddNew
                    .fields("VA_ID").Value = iVA_ID
                    .fields("VADatum_ID").Value = iVADatum_ID
                    .fields("VAStart_ID").Value = iVAStart_ID
                    .fields("PosNr").Value = iPosNr
                    .fields("VA_Start").Value = dtStart
 '                   .Fields("VA_Ende").Value = dtEnde
                    .fields("MA_ID").Value = iMA_ID
                    .fields("Status_ID").Value = iStatus_ID
                    .fields("Erst_von").Value = atCNames(1)
                    .fields("Erst_am").Value = Now()
                    .fields("Aend_von").Value = atCNames(1)
                    .fields("Aend_am").Value = Now()
                    .fields("VADatum").Value = VADatum
                    .fields("MVA_Start").Value = MVA_Start
                    .fields("MVA_Ende").Value = MVA_Ende
                    .fields("Bemerkungen").Value = ""
'                    .Fields("MA_Brutto_Std2").Value = fctRound(timeberech_G(VADatum, dtStart, dtEnde), 2)
'                    .Fields("MA_Netto_Std2").Value = fctRound((.Fields("MA_Brutto_Std2").Value * sPausenabzug), 2)
                .update
            End With
            DoEvents
        End If
        Me.List_MA.selected(var) = False
    Next var

    rst.Close
    Set rst = Nothing
    
    DoEvents
    
    'Schweinskram
    'fSort_MA 2
    zfSort_MA 2
    
    DoEvents
    
    strSQL = ""
    strSQL = "SELECT * FROM qry_Mitarbeiter_Geplant WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum
    Me!lstMA_Plan.RowSource = strSQL
    Me!lstMA_Plan.Requery
    DoEvents
    
    
    Me!List_MA.RowSource = Me!List_MA.RowSource
   
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

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

Private Sub btnPosListe_Click()
Dim i As Long
Dim strSQL As String

If iObjekt_ID > 0 Then
    i = Nz(TLookup("ID", "tbl_VA_Akt_Objekt_Kopf", "VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum & " AND OB_Objekt_Kopf_ID = " & iObjekt_ID), 0)
    If i = 0 Then
    
        strSQL = ""
        strSQL = strSQL & "INSERT INTO tbl_VA_Akt_Objekt_Kopf ( VA_ID, OB_Objekt_Kopf_ID, VADatum_ID, VADatum )"
        strSQL = strSQL & " SELECT " & Me!VA_ID & " AS Ausdr1, " & iObjekt_ID & " AS Ausdr2, " & Me!cboVADatum & " AS Ausdr3, " & SQLDatum(Me!cboVADatum.Column(1)) & " AS Ausdr4"
        strSQL = strSQL & " FROM _tblInternalSystemFE;"
        CurrentDb.Execute (strSQL)
        i = TMax("ID", "tbl_VA_Akt_Objekt_Kopf")
    End If
    
    DoCmd.OpenForm "frmTop_VA_Akt_Objekt_Kopf"
    Form_frmTop_VA_Akt_Objekt_Kopf.VAOpen_ID i
    
End If
End Sub

Private Sub btnSortPLan_Click()
'Schweinskram
'fSort_MA 2
zfSort_MA 2
End Sub

Private Sub btnSortZugeord_Click()
'Schweinskram
'fSort_MA 1
zfSort_MA 1
End Sub

Function fSort_MA(itbl As Long)
'1 = Zuordnung   2 = Planung

Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim iVAStart_ID As Long
Dim iPosStart As Long
Dim iPosEnde As Long
Dim iMA_ID As Long

Dim iSoll As Long
Dim iSollVgl As Long

Dim tbl As String

Dim db As DAO.Database
Dim rst As DAO.Recordset
    
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

If Len(Trim(Nz(Me!VA_ID))) = 0 Then Exit Function

If itbl = 1 Then
    tbl = "tbl_MA_VA_Zuordnung"
ElseIf itbl = 2 Then
    tbl = "tbl_MA_VA_Planung"
Else
Exit Function
End If

iVAStart_ID = Me!lstZeiten
iVA_ID = Me!VA_ID
iVADatum_ID = Me!cboVADatum
iSoll = Me!lstZeiten.Column(5)
Set db = CurrentDb

If itbl = 1 Then
    
    recsetSQL1 = ""
    recsetSQL1 = recsetSQL1 & "SELECT tbl_MA_VA_Zuordnung.MA_ID FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
    recsetSQL1 = recsetSQL1 & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID) = " & iVA_ID & ") And ((tbl_MA_VA_Zuordnung.VADatum_ID) = " & iVADatum_ID & " ) AND MA_ID > 0 And ((tbl_MA_VA_Zuordnung.VAStart_ID) = " & iVAStart_ID & "))"
    recsetSQL1 = recsetSQL1 & " ORDER BY tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
    
    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
    If Not ArrFill_DAO_OK1 Then
'        MsgBox "Sortierung nicht möglich, Abbruch"
        Exit Function
    End If

    iSollVgl = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID), 0)
    If iSollVgl = 0 Or iSoll <> iSollVgl Then
        MsgBox "Sortierung nicht möglich, Abbruch"
        Exit Function
    End If
    Set rst = db.OpenRecordset("SELECT * FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " ORDER BY [PosNr];")
    iZl = 0
    With rst
        Do Until .EOF
            If iZl <= iZLMax1 Then
                iMA_ID = DAOARRAY1(0, iZl)
            Else
                iMA_ID = 0
            End If
            .Edit
                .fields("MA_ID") = iMA_ID
            .update
            .MoveNext
            iZl = iZl + 1
        Loop
        .Close
    End With
    Set rst = Nothing
    Me!lstMA_Zusage.RowSource = Me!lstMA_Zusage.RowSource

ElseIf itbl = 2 Then
    
    recsetSQL1 = ""
    recsetSQL1 = recsetSQL1 & "SELECT tbl_MA_VA_Planung.MA_ID FROM tbl_MA_VA_Planung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
    recsetSQL1 = recsetSQL1 & " WHERE (((tbl_MA_VA_Planung.VA_ID) = " & iVA_ID & ") And ((tbl_MA_VA_Planung.VADatum_ID) = " & iVADatum_ID & " ) AND MA_ID > 0 And ((tbl_MA_VA_Planung.VAStart_ID) = " & iVAStart_ID & "))"
    recsetSQL1 = recsetSQL1 & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
    
    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
    If Not ArrFill_DAO_OK1 Then
'        MsgBox "Sortierung nicht möglich, Abbruch"
        Exit Function
    End If

    Set rst = db.OpenRecordset("SELECT * FROM tbl_MA_VA_Planung WHERE VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " ORDER BY [PosNr];")
    iZl = 0
    With rst
        Do Until .EOF
            If iZl <= iZLMax1 Then
                iMA_ID = DAOARRAY1(0, iZl)
            Else
                iMA_ID = 0
            End If
            .Edit
                .fields("MA_ID") = iMA_ID
            .update
            .MoveNext
            iZl = iZl + 1
        Loop
        .Close
    End With
    Set rst = Nothing
    Me!lstMA_Plan.RowSource = Me!lstMA_Plan.RowSource
End If
           


End Function


Function zfSort_MA(itbl As Long)
'1 = Zuordnung   2 = Planung

Debug.Print "Sort " & itbl

End Function


Private Sub btnAddZusage_Click()
Dim strSQL As String

Dim iSoll As Long
Dim iIst As Long

Dim iMA_ID As Long
Dim iZuo_ID As Long
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim iVAStart_ID As Long

Dim i As Long
Dim var

iVAStart_ID = Me!lstZeiten
iVA_ID = Me!VA_ID
iVADatum_ID = Me!cboVADatum

    For Each var In Me!lstMA_Plan.ItemsSelected
        i = Me!lstMA_Plan.Column(0, var)
        iMA_ID = Me!lstMA_Plan.Column(4, var)
        iSoll = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID))
        iIst = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND MA_ID > 0"))
        iZuo_ID = Nz(TLookup("ID", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " AND MA_ID = 0"), 0)
        If iIst < iSoll And iZuo_ID > 0 Then
            CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET MA_ID = " & iMA_ID & ", IstFraglich = 0 WHERE (((tbl_MA_VA_Zuordnung.ID)=" & iZuo_ID & "));")
            CurrentDb.Execute ("DELETE * FROM tbl_MA_VA_Planung Where ID = " & i)
        Else
            MsgBox "Es können keinen weiteren MA hinzugefügt werden"
            Exit For
        End If
    Next var
    
    DoEvents
    
    'fSort_MA 1
    zfSort_MA 1
    DoEvents
    'fSort_MA 2
    zfSort_MA 2
    DoEvents
           
    Me!lstMA_Plan.RowSource = Me!lstMA_Plan.RowSource
    Me!lstMA_Zusage.RowSource = Me!lstMA_Zusage.RowSource
    
    Me!iGes_MA = Soll_Plan_Ist_Ges(Me!VA_ID, Me!cboVADatum)

End Sub


Private Sub btnDelZusage_Click()
Dim strSQL As String

Dim i As Long
Dim iMA_ID As Long
Dim var

    If vbCancel = MsgBox("Zusagen entfernen", vbOKCancel + vbQuestion, "Zusage löschen, sind Sie sicher") Then
        Me!lstMA_Zusage.RowSource = Me!lstMA_Zusage.RowSource
        Exit Sub
    End If
    
    For Each var In Me!lstMA_Zusage.ItemsSelected
        i = Me!lstMA_Zusage.Column(0, var)
        CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_ID = 0, tbl_MA_VA_Zuordnung.IstFraglich = 0 WHERE (((tbl_MA_VA_Zuordnung.ID)=" & i & "));")
    Next var
    
    'Schweinskram
    'fSort_MA 1
    zfSort_MA 1
    Me!lstMA_Zusage.RowSource = Me!lstMA_Zusage.RowSource

    Me!iGes_MA = Soll_Plan_Ist_Ges(Me!VA_ID, Me!cboVADatum)
End Sub


Private Sub btnMoveZusage_Click()
Dim strSQL As String

Dim i As Long
Dim var
Dim iPosNr As Long

Dim iMA_ID As Long
Dim iZuo_ID As Long
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim iVAStart_ID As Long
Dim VADatum As Date
Dim dtStart As Date

Dim MVA_Start As Date
Dim MVA_Ende As Date

Dim db As DAO.Database
Dim rst As DAO.Recordset

    iVAStart_ID = Me!lstZeiten
    iVA_ID = Me!VA_ID
    iVADatum_ID = Me!cboVADatum
    VADatum = Me!cboVADatum.Column(1)
   
    Set db = CurrentDb
    Set rst = db.OpenRecordset("SELECT TOP 1 * FROM tbl_MA_VA_Planung;")

    For Each var In Me!lstMA_Zusage.ItemsSelected
        i = Me!lstMA_Zusage.Column(0, var)
        dtStart = Me!lstMA_Zusage.Column(10, var)
        iMA_ID = Me!lstMA_Zusage.Column(4, var)
        MVA_Start = Startzeit_G(VADatum, dtStart)
        MVA_Ende = Endezeit_G(VADatum, dtStart, Me!DienstEnde)
   
        CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_ID = 0, tbl_MA_VA_Zuordnung.IstFraglich = 0 WHERE (((tbl_MA_VA_Zuordnung.ID)=" & i & "));")
            iPosNr = Nz(TMax("PosNr", "tbl_MA_VA_Planung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0) + 1
            With rst
                .AddNew
                    .fields("VA_ID").Value = iVA_ID
                    .fields("VADatum_ID").Value = iVADatum_ID
                    .fields("VAStart_ID").Value = iVAStart_ID
                    .fields("PosNr").Value = iPosNr
                    .fields("VA_Start").Value = dtStart
 '                   .Fields("VA_Ende").Value = dtEnde
                    .fields("MA_ID").Value = iMA_ID
                    .fields("Status_ID").Value = 1
                    .fields("Erst_von").Value = atCNames(1)
                    .fields("Erst_am").Value = Now()
                    .fields("Aend_von").Value = atCNames(1)
                    .fields("Aend_am").Value = Now()
                    .fields("VADatum").Value = VADatum
                    .fields("MVA_Start").Value = MVA_Start
                    .fields("MVA_Ende").Value = MVA_Ende
                    .fields("Bemerkungen").Value = ""
'                    .Fields("MA_Brutto_Std2").Value = fctRound(timeberech_G(VADatum, dtStart, dtEnde), 2)
'                    .Fields("MA_Netto_Std2").Value = fctRound((.Fields("MA_Brutto_Std2").Value * sPausenabzug), 2)
                .update
            End With
            DoEvents
    Next var
    
    'Schweinskram
    'fSort_MA 1
    'fSort_MA 2
    zfSort_MA 1
    zfSort_MA 2
    
    Me!lstMA_Plan.RowSource = Me!lstMA_Plan.RowSource
    Me!lstMA_Zusage.RowSource = Me!lstMA_Zusage.RowSource

    Me!iGes_MA = Soll_Plan_Ist_Ges(Me!VA_ID, Me!cboVADatum)

End Sub



Private Sub btnAuftrag_Click()
Dim iVA_ID As Long
Dim iVADatum_ID As Long

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
If Len(Trim(Nz(Me!VA_ID))) = 0 Then
    DoCmd.OpenForm "frm_VA_Auftragstamm"
Else

    iVA_ID = Me!VA_ID
    iVADatum_ID = Me!cboVADatum
    DoCmd.Close acForm, Me.Name
    DoCmd.OpenForm "frm_VA_Auftragstamm"
    Call Form_frm_VA_Auftragstamm.VAOpen(iVA_ID, iVADatum_ID)

End If
End Sub

Private Sub btnDelAll_Click()

Dim strSQL As String

    If Not vbOK = MsgBox("Alle verplanten Mitarbeiter von der PLanung entfernen ?", vbQuestion + vbOKCancel, "Achtung Alles Löschen, Sind Sie sicher ?") Then
        Exit Sub
    End If

    CurrentDb.Execute ("DELETE * FROM tbl_MA_VA_Planung WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum)

    strSQL = ""
    strSQL = "SELECT * FROM qry_Mitarbeiter_Geplant WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum
    Me!lstMA_Plan.RowSource = strSQL
    Me!lstMA_Plan.Requery
    DoEvents
    Me!List_MA.RowSource = Me!List_MA.RowSource
  
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

End Sub

Private Sub btnDelSelected_Click()

Dim strSQL As String

Dim i As Long
Dim var

    For Each var In Me!lstMA_Plan.ItemsSelected
        i = Me!lstMA_Plan.Column(0, var)
        CurrentDb.Execute ("DELETE * FROM tbl_MA_VA_Planung WHERE ID = " & i)
    Next var

    DoEvents
    'Schweinskram
    'fSort_MA 2
    zfSort_MA 2
    DoEvents
    
    strSQL = ""
    strSQL = "SELECT * FROM qry_Mitarbeiter_Geplant WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum
    Me!lstMA_Plan.RowSource = strSQL
    Me!lstMA_Plan.Requery
    DoEvents
    Me!List_MA.RowSource = Me!List_MA.RowSource
  
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

End Sub

Private Sub btnMail_Click()
Dim iVA_ID As Long
Dim iVADatum_ID As Long

'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents
If lstMA_Plan = 0 Then
MsgBox "Keine Mitarbeiter ausgewählt"
End If


If Len(Trim(Nz(Me!VA_ID))) > 0 Then
    iVA_ID = Me!VA_ID
    iVADatum_ID = Me!cboVADatum
'    DoCmd.Close acForm, Me.Name, acSaveNo
    
    DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
    Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(1, iVA_ID, iVADatum_ID)
End If
    
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents

End Sub

Private Sub btnSchnellGo_Click()
Dim strSQL As String

If Len(Trim(Nz(Me!strSchnellSuche))) > 0 Then
    strSQL = "SELECT * FROM (" & strSQL_Org
    strSQL = strSQL & ") WHERE [Name] Like '" & Me!strSchnellSuche & "*';"
    Me!List_MA.RowSource = strSQL
Else
    Me!List_MA.RowSource = strSQL_Org
End If
Me!strSchnellSuche = ""

End Sub


Private Sub btnZuAbsage_Click()
DoCmd.OpenForm "frmTop_MA_ZuAbsage"
End Sub

Private Sub cboVADatum_AfterUpdate()
Dim dtdat As Date

Dim strSQL As String

Dim i As Long

Me!cboAuftrStatus = Nz(TLookup("Veranst_Status_ID", "tbl_VA_Auftragstamm", "ID = " & Me!VA_ID), 0)

iObjekt_ID = Nz(TLookup("Objekt_ID", "tbl_VA_Auftragstamm", "ID = " & Me!VA_ID), 0)
If iObjekt_ID > 0 Then
    Me!btnPosListe.Visible = True
Else
    Me!btnPosListe.Visible = False
End If

strSQL = ""
strSQL = strSQL & "SELECT VAStart_ID, VADatum, MVA_Start, MVA_Ende, MA_Ist as Ist, MA_Soll as Soll, left(VA_Start,5) As Beginn, left(VA_Ende,5) as Ende FROM qry_Anz_MA_Start WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum & " ORDER BY VA_Start, VA_Ende"
Me!lstZeiten.RowSource = strSQL
Me!lstZeiten.Requery
DoEvents
Me!lstZeiten = Me!lstZeiten.ItemData(1)
lstZeiten_AfterUpdate

strSQL = ""
strSQL = "SELECT * FROM qry_Mitarbeiter_Zusage WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum
Me!lstMA_Zusage.RowSource = strSQL
Me!lstMA_Zusage.Requery
DoEvents

strSQL = ""
strSQL = "SELECT * FROM qry_Mitarbeiter_Geplant WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum
Me!lstMA_Plan.RowSource = strSQL
Me!lstMA_Plan.Requery
DoEvents

Call Set_Priv_Property("prp_tmp_AktdatAuswahl", Me!cboVADatum.Column(1))

strSQL = ""
strSQL = "SELECT * FROM qry_VA_Einsatz WHERE VADatum = " & SQLDatum(Me!cboVADatum.Column(1))
Me!Lst_Parallel_Einsatz.RowSource = strSQL
Me!Lst_Parallel_Einsatz.Requery
DoEvents

'    'Me.Painting = False
'
'        For i = 0 To Me!Lst_Parallel_Einsatz.ListCount
'            If Trim(Nz(Me!Lst_Parallel_Einsatz.Column(0, i))) = Me!VA_ID Then
'                Me!Lst_Parallel_Einsatz.Selected(i) = True
'                Exit For
'            End If
'        Next i
'
'    'Me.Painting = True


Me!iGes_MA = Soll_Plan_Ist_Ges(Me!VA_ID, Me!cboVADatum)

Me!List_MA.RowSource = Me!List_MA.RowSource

End Sub

Private Sub DienstEnde_AfterUpdate()
f_lstZeiten_upd
End Sub


Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!List_MA.RowSource = ""
Me!lstZeiten.RowSource = ""
Me!lstMA_Plan.RowSource = ""
Me!lstMA_Zusage.RowSource = ""
Me!lbl_Datum.caption = Date
End Sub



Private Sub IstAktiv_AfterUpdate()
If Me!istaktiv = True Then
    Me!lbl_IstAktiv.caption = "Nur aktive MA"
Else
    Me!lbl_IstAktiv.caption = "Alle anzeigen"
End If
'f_MA_Selektion
zf_MA_Selektion
End Sub

Private Sub Lst_Parallel_Einsatz_DblClick(Cancel As Integer)
Dim i As Long
Dim j As Long
i = Nz(TCount("*", "tbl_VA_Start", "VA_ID = " & CLng(Me!Lst_Parallel_Einsatz.Column(0)) & " AND VADatum_ID = " & CLng(Me!Lst_Parallel_Einsatz.Column(1))), 0)
If i > 0 Then
    Call VAOpen(Me!Lst_Parallel_Einsatz.Column(0), CLng(Me!Lst_Parallel_Einsatz.Column(1)))
Else
    MsgBox "Keine Schichten"
End If
End Sub

Private Sub lstZeiten_AfterUpdate()
Dim strSQL As String

Dim sg As Single

sg = (Get_Priv_Property("prp_VA_Start_AutoLaenge") * 60)

If Len(Trim(Nz(Me!lstZeiten.Column(3)))) = 0 Or Not IsDate(Me!lstZeiten.Column(3)) Then
    Me!DienstEnde = DateAdd("n", sg, Me!lstZeiten.Column(2))
Else
    Me!DienstEnde = CDate(Me!lstZeiten.Column(3))
End If

f_lstZeiten_upd

End Sub

Function f_lstZeiten_upd()
Dim strSQL As String

    'BERECHNUNG NEU
    Call upd_Vergleichszeiten(Me.VA_ID, Me.lstZeiten.Column(2), Me.DienstEnde)
    
'CurrentDb.Execute ("DELETE * FROM tbltmp_Vergleichszeiten;")
'strsql = ""
'strsql = strsql & "INSERT INTO tbltmp_Vergleichszeiten ( VGL_Start, VGL_Ende, VGL_VA_ID )"
''strSQL = strSQL & " SELECT " & DateTimeForSQL(DateAdd("n", 2, Me!lstZeiten.Column(2))) & ", " & DateTimeForSQL(DateAdd("n", -2, Me!DienstEnde)) & ", " & Me!VA_ID & " AS Ausdr1"
'strsql = strsql & " SELECT " & DateTimeForSQL(DateAdd("n", 0, Me!lstZeiten.Column(2))) & ", " & DateTimeForSQL(DateAdd("n", 0, Me!DienstEnde)) & ", " & Me!VA_ID & " AS Ausdr1"
'strsql = strsql & " FROM _tblInternalSystemFE;"
'CurrentDb.Execute (strsql)

DoEvents
'f_MA_Selektion
zf_MA_Selektion

End Function

Private Sub IstVerfuegbar_AfterUpdate()
If Me!IstVerfuegbar = True Then
    Me!lbl_NurFreie.caption = "Nur freie anzeigen"
Else
    Me!lbl_NurFreie.caption = "Alle anzeigen"
End If
'f_MA_Selektion
zf_MA_Selektion
End Sub

Private Sub cboAnstArt_AfterUpdate()
'f_MA_Selektion
zf_MA_Selektion
End Sub
'
'Private Sub cboQuali_AfterUpdate()
'f_MA_Selektion
'End Sub


Function zf_MA_Selektion()

Dim strSQL As String

    strSQL = upd_qry_Verfuegbarkeit(Me.IstVerfuegbar, Me.cboAnstArt, Me.cboQuali, Me.istaktiv)
    
    strSQL_Org = strSQL
    Me!List_MA.RowSource = strSQL
    Me!List_MA.Requery

End Function

Function f_MA_Selektion()

Dim iVerf As Long
Dim iAnstArt As Long
'Dim iQuali As Long
Dim iAktiv As Long
Dim strSQL As String

Dim strSQLqry As String

iAktiv = Me!istaktiv
iVerf = Me!IstVerfuegbar
iAnstArt = Me!cboAnstArt
'iQuali = Me!cboQuali

strSQL = ""
strSQL = strSQL & "SELECT qry_EchtNeu_SP_MA_Alle.ID, qry_EchtNeu_SP_MA_Alle.IstSubunternehmer, [Nachname] & ' ' & [Vorname] AS Name,"
strSQL = strSQL & " fctround(zMA_Monat_SumNetStd([ID],[VGL_Start]),0) AS Stunden, Left([VA_Start],5) AS Beginn, Left([VA_Ende],5) AS Ende,"
strSQL = strSQL & " qry_EchtNeu_SP_MA_Alle.Grund , qry_EchtNeu_SP_MA_Alle.Anstellungsart_ID"
strSQL = strSQL & " FROM qry_EchtNeu_SP_MA_Alle, tbltmp_Vergleichszeiten"
If iAktiv <> 0 Then
    strSQL = strSQL & " WHERE (((qry_EchtNeu_SP_MA_Alle.IstAktiv) = True))"
End If
strSQL = strSQL & " ORDER BY [Nachname], [Vorname];"

Call CreateQuery(strSQL, "qry_MA_Auswahl_Alle")

If iVerf = False Then
    strSQLqry = "qry_MA_Auswahl_Alle"
Else
    strSQLqry = "qry_MA_Auswahl_Verfuegbar"
End If
strSQL = strSQLqry

'If iQuali <> 1 And
If iAnstArt = 9 Then
   ' strSQL = "SELECT * FROM " & strSQLqry & "_Quali WHERE Quali_ID = " & iQuali
'ElseIf iQuali = 1  And
ElseIf iAnstArt <> 9 Then
    strSQL = "SELECT * FROM " & strSQLqry & " WHERE Anstellungsart_ID = " & iAnstArt
'ElseIf iQuali <> 1 And
ElseIf iAnstArt <> 9 Then
    strSQL = "SELECT * FROM " & strSQLqry & "Anstellungsart_ID = " & iAnstArt
End If

strSQL_Org = strSQL
Me!List_MA.RowSource = strSQL
Me!List_MA.Requery

End Function

'Private Sub MA_Selektion_AfterUpdate()
'
'Dim strSQLqry As String
'Dim strSQL As String
'
'Select Case Me!MA_Selektion
'    Case 1  ' Alle
'        strSQLqry = "qry_MA_Auswahl_Alle"
'    Case 2  ' Verfügbar
'        strSQLqry = "qry_MA_Auswahl_Verfuegbar"
'    Case Else
'End Select
'
'If Me!cboQuali > 1 Then
'    strSQL = "SELECT * FROM " & strSQLqry & "_Quali WHERE Quali_ID = " & Me!cboQuali
''    Me!btnAddAll.Visible = True
'Else
'    strSQL = strSQLqry
''    Me!btnAddAll.Visible = False
'End If
'
'End Sub


Private Sub strSchnellSuche_Exit(Cancel As Integer)
btnSchnellGo_Click
End Sub

Private Sub DienstEnde_KeyDown(KeyCode As Integer, Shift As Integer)

Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!DienstEnde.Text
        If Not IsNumeric(st) Then
            Me!DienstEnde.SetFocus
            Exit Sub
        End If
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!DienstEnde = uz
        Me!DienstEnde.SetFocus
    End If

End Sub

Private Sub VA_ID_AfterUpdate()

Dim dtdat As Date
Dim i As Long
Dim strSQL As String

Me!List_MA.RowSource = ""

If Nz(TCount("*", "tbl_VA_Start", "VA_ID = " & Me!VA_ID), 0) = 0 Then
    MsgBox "Erst Zeitraum im Auftrag definieren, keine Schnellplanung möglich"
    Exit Sub
End If

i = Me!VA_ID.Column(1)

strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!VA_ID & ")) ORDER BY ID;"
Me!cboVADatum.RowSource = strSQL
'Me!cboVADatum = Me!cboVADatum.ItemData(0)
Me!cboVADatum = i

DoEvents
dtdat = Me!cboVADatum.Column(1)
Me!iGes_MA = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum))

cboVADatum_AfterUpdate

'iGes_MA für den Tag

'MA_Selektion_AfterUpdate

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

