VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_MA_VA_Schnellauswahl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim iObjekt_ID As Long
Private bEntfernungsModus As Boolean  'Merkt sich ob Entfernungsmodus aktiv


Public Function VAOpen(ByVal iVA_ID As Long, ByVal iVADatum_ID As Long)

Dim strSQL As String

    Me.Painting = False
    
    Me!VA_ID = iVA_ID
    strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & iVA_ID & ")) ORDER BY ID;"
    Me!cboVADatum.RowSource = strSQL
    Me!cboVADatum = iVADatum_ID
    cboVADatum_AfterUpdate


    lbAuftrag.caption = cboVADatum.Column(1) & " " & TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & _
         " " & TLookup("Objekt", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & " " & TLookup("Ort", AUFTRAGSTAMM, "ID = " & Me.VA_ID)
         
    DoEvents

    Me.Painting = True
    
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
' '                   .Fields("MA_Netto_Std").Value = fctRound((.Fields("MA_Brutto_Std2").Value * sPausenabzug), 2)
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
Dim selected As Long
Dim i As Integer

    iVAStart_ID = Me!lstZeiten
    iVADatum_ID = Me!cboVADatum
    VADatum = Me!cboVADatum.Column(1)
    dtStart = Me!lstZeiten.Column(2)
    dtEnde = Me!lstZeiten.Column(3)
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
        selected = var
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
                    .fields("VA_Ende").Value = dtEnde
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
                .update
            End With
            DoEvents
        End If
        Me.List_MA.selected(var) = False
    Next var

    rst.Close
    Set rst = Nothing
    
    DoEvents
    
    
    'Daten im FE aktualisieren -> HIER AKTUELLER MONAT WEGEN DEN MONATSSTUNDEN!!!
    strSQL = "BETWEEN " & datumSQL(DateSerial(Year(Date), Month(Date), 0) + 1) & " AND " & datumSQL(DateSerial(Year(Date), Month(Date) + 1, 0))
    Call refresh_zuoplanfe(, strSQL)

    
    DoEvents
    
    strSQL = ""
    strSQL = "SELECT * FROM qry_Mitarbeiter_Geplant WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum
    Me!lstMA_Plan.RowSource = strSQL
    Me!lstMA_Plan.Requery
    DoEvents

    DoCmd.RunCommand acCmdSaveRecord
    Call zf_MA_Selektion

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents


On Error Resume Next

    For i = 0 To selected
        Me.List_MA.ListIndex = i - 1
        Me.List_MA.selected(i) = False
    Next i

    
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
    bIstbereitsPl = (Len(Trim(Nz(Me!List_MA.Column(5, var)))) > 0)
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

'ACHTUNG!!!-> Schweinskram -> Setzt nur die MA_IDs neu und versaut die Planung
'fSort_MA 2
zfSort_MA 2

End Sub


'Zuorndung sortieren
Private Sub btnSortZugeord_Click()

'ACHTUNG!!!-> Schweinskram -> Setzt nur die MA_IDs neu und versaut die Zusagen
'fSort_MA 1
    
'ZUORDNUNG sortieren
sort_zuo_plan Me.VA_ID, Me.cboVADatum, 1
    
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

Debug.Print "Sortierung" & itbl

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
    
    'Schweinskram
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
'                    .Fields("MA_Netto_Std").Value = fctRound((.Fields("MA_Brutto_Std2").Value * sPausenabzug), 2)
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

On Error Resume Next

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
If Len(Trim(Nz(Me!VA_ID))) = 0 Then
    DoCmd.OpenForm "frm_VA_Auftragstamm"
Else

    iVA_ID = Me!VA_ID
    iVADatum_ID = Me!cboVADatum
    
    If Not fctIsFormOpen("frm_VA_Auftragstamm") Then
        DoCmd.OpenForm "frm_VA_Auftragstamm"
    Else
        Forms("frm_VA_Auftragstamm").SetFocus
    End If
    
    Call Form_frm_VA_Auftragstamm.VAOpen(iVA_ID, iVADatum_ID)

End If

DoCmd.Close acForm, Me.Name, acSaveNo

End Sub

'Achtung!-> Löscht alles zur Veranstaltung aus Planungstabelle (inkl. Absagen)
'Private Sub btnDelAll_Click()
'
'Dim strSQL As String
'
'    If Not vbOK = MsgBox("Alle verplanten Mitarbeiter von der PLanung entfernen ?", vbQuestion + vbOKCancel, "Achtung Alles Löschen, Sind Sie sicher ?") Then
'        Exit Sub
'    End If
'
'    CurrentDb.Execute ("DELETE * FROM tbl_MA_VA_Planung WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum)
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

Private Sub btnDelSelected_Click()

Dim strSQL As String

Dim i As Long
Dim var

    For Each var In Me!lstMA_Plan.ItemsSelected
        i = Me!lstMA_Plan.Column(0, var)
        CurrentDb.Execute ("DELETE * FROM tbl_MA_VA_Planung WHERE ID = " & i)
    Next var

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
    
    'Daten im FE aktualisieren -> HIER AKTUELLER MONAT WEGEN DEN MONATSSTUNDEN!!!
    strSQL = "BETWEEN " & datumSQL(DateSerial(Year(Date), Month(Date), 0) + 1) & " AND " & datumSQL(DateSerial(Year(Date), Month(Date) + 1, 0))
    Call refresh_zuoplanfe(, strSQL)


    DoEvents
    Call zf_MA_Selektion
    
End Sub

'Geplante Mitarbeiter anfragen
Private Sub btnMail_Click()

Dim iVA_ID       As Long
Dim iVADatum_ID  As Long
Dim sql          As String



    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    If Len(Trim(Nz(Me!VA_ID))) > 0 Then
    


        'Status 1 bis 4:  1 = Geplant 2 = Benachrichtigt 3 = Zusage 4  = Absage
        '(Zusage 3 wird gelöscht kommt zu Zugeordnet)
        sql = Me.lstMA_Plan.RowSource
        'SQL = SQL & " AND Status_ID = 1" -> anderer Status wird nicht angezeigt!!!
        
        'Anfragelog anzeigen
        show_requestlog sql, False
         
        
        iVA_ID = Me.VA_ID
        iVADatum_ID = Me.cboVADatum

        'Formular muss nach erfolgter Anfrage geschlossen werden!!!
        DoCmd.Close acForm, Me.Name, acSaveNo
        
        
        'Auftragstamm öffnen
        If Not fctIsFormOpen("frm_va_auftragstamm") Then DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & iVA_ID
         

'    DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
'    Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(1, iVA_ID, iVADatum_ID)
End If
    
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
'Set rst = Nothing
End Sub


'Ausgewählte Mitarbeiter anfragen
Private Sub btnMailSelected_Click()


Dim iVA_ID       As Long
Dim iVADatum_ID  As Long
Dim sql          As String


    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    If Len(Trim(Nz(Me!VA_ID))) > 0 Then
    

        'Status 1 bis 4:  1 = Geplant 2 = Benachrichtigt 3 = Zusage 4  = Absage
        '(Zusage 3 wird gelöscht kommt zu Zugeordnet)
        sql = Me.lstMA_Plan.RowSource
        'SQL = SQL & " AND Status_ID = 1" -> anderer Status wird nicht angezeigt!!!
    
    
         'Anfragelog anzeigen
         show_requestlog sql, True
         

        iVA_ID = Me.VA_ID
        iVADatum_ID = Me.cboVADatum
        
        'Formular muss nach erfolgter Anfrage geschlossen werden!!!
        DoCmd.Close acForm, Me.Name, acSaveNo
        
        
        'Auftragstamm öffnen
        If Not fctIsFormOpen("frm_va_auftragstamm") Then DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & iVA_ID
         
        'Log schließen
        'DoCmd.Close acForm, "zfrm_Log"
        
        
End If
    
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
'Set rst = Nothing

End Sub


'Anzeige Log
Function show_requestlog(sql As String, Optional selected As Boolean)

Dim rst As Recordset
Dim Log As String
Dim rc  As String

    
    'Recordset aus eingeplanten MA
    Set rst = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    
    'Logdatei Löschen
    CurrentDb.Execute "DELETE * FROM ztbl_Log"
    
    'kurz warten
    Wait (1)
    
    FnSetzeAutowertZurueck "ID", "ztbl_Log"
    DoCmd.OpenForm "zfrm_Log"

    'Ladebalken
    SysCmd acSysCmdInitMeter, "Bitte warten...", rst.RecordCount
    DoCmd.Hourglass True
        
    'alle Einträge im Recordset durchlaufen -> prüfen ob alle oder Selektion
    Do
        If (selected = True And Me.lstMA_Plan.selected(rst.AbsolutePosition + 1) = True) Or selected = False Then '(Listbox beginnt bei 1, rst bei 0!)
        
            'Mitarbeiter einzeln anfragen
            rc = Anfragen(rst.fields("MA_ID"), rst.fields("VA_ID"), _
                           rst.fields("VADatum_ID"), rst.fields("VAStart_ID"))
                           
            sql = "INSERT INTO ztbl_Log ( Mitarbeiter, Status ) VALUES ( '" & VName & " " & NName & "', '" & rc & "' )"
            CurrentDb.Execute sql
            
            'Dokument für Zusage-Bestätigung erstellen
             create_confirm_doc (rst.fields("MA_ID"))
        End If
        
        rst.MoveNext
        
        'Ladebalken
        If rst.AbsolutePosition > 0 Then
            SysCmd acSysCmdUpdateMeter, rst.AbsolutePosition
        End If
        
        If fctIsFormOpen("zfrm_Log") Then
            Forms("zfrm_Log").zfrm_ufrm_Log.Requery
            Forms("zfrm_Log").zfrm_ufrm_Log.SetFocus
            DoCmd.GoToRecord , , acLast
        End If
        
    Loop Until rst.EOF
    
    rst.Close
    Set rst = Nothing
    
    'Ladebalken
    SysCmd acSysCmdRemoveMeter
    DoCmd.Hourglass False
        
    MsgBox TCount("ID", "ztbl_Log") & " Mitarbeiter wurden angefragt - siehe Log"
    DoCmd.Close acForm, "zfrm_Log"


End Function


'Erstellung PDF für Zusage-Bestätigung
Function create_confirm_doc(MA_ID As Integer)

Dim Report As String
Dim file As String

    'Bericht
    Report = "rpt_MA_Dienstplan_auto"

    'Anhang
    file = PfadZusage & "DP_" & MA_ID & ".pdf"

    'Prüfen, ob Bericht geöffnet
    If fctIsReportOpen(Report) Then DoCmd.Close acReport, Report, acSaveNo

On Error GoTo Err

    'Alte Datei löschen falls noch vorhanden
    If FileExists(file) Then Kill file
    
    'MA_ID für Dienstplan setzen
    Call Set_Priv_Property("prp_MA_ID_DP", MA_ID)
    
    DoEvents
    
    'Bericht im Temp-Verzeichnis als PDF sichern
    DoCmd.OutputTo acOutputReport, Report, "PDF", file

Err:

End Function


Private Sub btnSchnellGo_Click()

Dim strSQL As String
Dim srctbl As String
    
    srctbl = "ztbl_MA_Schnellauswahl"
    
    If Len(Trim(Nz(Me!strSchnellSuche))) > 0 Then
        strSQL = "SELECT * FROM " & srctbl & " WHERE [Name] Like '" & Me!strSchnellSuche & "*';"
    Else
        strSQL = srctbl
    End If
    
    Me!List_MA.RowSource = strSQL
    
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


Me!iGes_MA = Soll_Plan_Ist_Ges(Me!VA_ID, Me!cboVADatum)

'Me!List_MA.RowSource = Me!List_MA.RowSource

'For i = 0 To Me.List_MA.ListCount
'    If Me.List_MA.Column(3, i) > 45 Then
'        'Me.List_MA.Column(3, i).ForeColor = 200
'    End If
'Next i

End Sub


Private Sub DienstEnde_AfterUpdate()
    Call f_lstZeiten_upd
End Sub


Private Sub Form_Close()

'Zuordnung und Planung sortieren, wenn Datensatz
If Me.VA_ID.Value <> 0 And Me.VA_ID <> "" And Me.cboVADatum <> 0 Then
    sort_zuo_plan Me.VA_ID, Me.cboVADatum, 1
    sort_zuo_plan Me.VA_ID, Me.cboVADatum, 2
End If
End Sub

Private Sub Form_Load()

Dim strSQL As String
    DoCmd.Maximize
    
    'Daten im FE aktualisieren -> HIER AKTUELLER MONAT WEGEN DEN MONATSSTUNDEN!!!
    strSQL = "BETWEEN " & datumSQL(DateSerial(Year(Date), Month(Date), 0) + 1) & " AND " & datumSQL(DateSerial(Year(Date), Month(Date) + 1, 0))
    Call refresh_zuoplanfe(, strSQL)

    Me.cboAnstArt = 5
    Call cboAnstArt_AfterUpdate
    
End Sub

Private Sub Form_Open(Cancel As Integer)

Dim VA_ID As Long
Dim VADatum As Long

    Me.Painting = False
    
    Me.List_MA.RowSource = ""
    Me.lstZeiten.RowSource = ""
    Me.lstMA_Plan.RowSource = ""
    Me.lstMA_Zusage.RowSource = ""
    Me.lbl_Datum.caption = Date
    
    If Me.OpenArgs <> "" Then
        VA_ID = Left(Me.OpenArgs, InStr(Me.OpenArgs, " ") - 1)
        VADatum = Right(Me.OpenArgs, Len(Me.OpenArgs) - InStr(Me.OpenArgs, " "))
        Call VAOpen(VA_ID, VADatum)
        Me.VA_ID = VA_ID
    End If
    
    'Zuordnung und Planung sortieren, wenn Datensatz
    If Me.VA_ID.Value <> 0 And Me.VA_ID <> "" And Me.cboVADatum <> 0 Then
        sort_zuo_plan Me.VA_ID, Me.cboVADatum, 1
        sort_zuo_plan Me.VA_ID, Me.cboVADatum, 2
    End If
    
    Me.Painting = True
    
End Sub



Private Sub IstAktiv_AfterUpdate()
    If Me!istaktiv = True Then
        Me!lbl_IstAktiv.caption = "Nur aktive MA"
    Else
        Me!lbl_IstAktiv.caption = "Alle anzeigen"
    End If
    
    Call zf_MA_Selektion

End Sub

Private Sub List_MA_DblClick(Cancel As Integer)
    
Dim strSQL As String

    Me!List_MA.SetFocus
    Call btnAddSelected_Click

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

Private Sub lstMA_Plan_DblClick(Cancel As Integer)
    Me!lstMA_Plan.SetFocus
    Call btnDelSelected_Click
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
    
    Call f_lstZeiten_upd

End Sub

'Hier werden die Vergleichszeiten aufgebaut
Function f_lstZeiten_upd()

    Call upd_Vergleichszeiten(Me.VA_ID, Me.lstZeiten.Column(2), Me.DienstEnde)
    DoEvents
    Call zf_MA_Selektion

End Function

' Umschalten: Verplant = Verfuegbar
Private Sub cbVerplantVerfuegbar_AfterUpdate()

    If Me.cbVerplantVerfuegbar = True Then
        Me!lbl_VerplantVerfuegbar.caption = "geplant = verfügbar"
    Else
        Me!lbl_VerplantVerfuegbar.caption = "geplant = nicht verfügbar"
    End If
    
    DoCmd.RunCommand acCmdSaveRecord
    Call zf_MA_Selektion
 
End Sub


'Nur 34a
Private Sub cbNur34a_AfterUpdate()

    DoCmd.RunCommand acCmdSaveRecord
    Call zf_MA_Selektion
    
End Sub


Private Sub IstVerfuegbar_AfterUpdate()
    If Me!IstVerfuegbar = True Then
        Me!lbl_NurFreie.caption = "Nur freie anzeigen"
    Else
        Me!lbl_NurFreie.caption = "Alle anzeigen"
    End If
    
    DoCmd.RunCommand acCmdSaveRecord
    Call zf_MA_Selektion

End Sub

Private Sub cboAnstArt_AfterUpdate()

    Call zf_MA_Selektion
    
End Sub

Private Sub cboQuali_AfterUpdate()

    Call zf_MA_Selektion
    
End Sub


'Schnellere Selektion der relevanten Mitarbeiter
Function zf_MA_Selektion()

Dim strSQL As String
Dim srctbl As String
Dim lngObjektID As Long

    Me.Painting = False
    srctbl = "ztbl_MA_Schnellauswahl"
    strSQL = upd_qry_Verfuegbarkeit(Me.IstVerfuegbar, Me.cboAnstArt, Me.cboQuali, Me.istaktiv, Me.cbVerplantVerfuegbar, Me.cbNur34a)
    CurrentDb.Execute "DELETE FROM " & srctbl
    CurrentDb.Execute "INSERT INTO " & srctbl & " " & strSQL
    DoEvents
    
    If bEntfernungsModus Then
        lngObjektID = Nz(DLookup("Objekt_ID", "tbl_VA_Auftragstamm", "ID=" & Nz(Me.VA_ID, 0)), 0)
        If lngObjektID > 0 Then
            strSQL = "SELECT MA.ID AS MA_ID, MA.Nachname & ', ' & MA.Vorname & ' (' & Format(Nz(D.Entf_KM,0),'0.0') & ' km)' AS Anzeige " & _
                     "FROM (ztbl_MA_Schnellauswahl AS S INNER JOIN tbl_MA_Mitarbeiterstamm AS MA ON MA.ID = S.MA_ID) " & _
                     "LEFT JOIN tbl_MA_Objekt_Entfernung AS D ON D.MA_ID = MA.ID AND D.Objekt_ID = " & lngObjektID & " " & _
                     "ORDER BY Nz(D.Entf_KM,9999), MA.Nachname, MA.Vorname"
            Me!List_MA.RowSource = strSQL
        Else
            Me!List_MA.RowSource = srctbl
        End If
    Else
        Me!List_MA.RowSource = srctbl
    End If
    
    Me.Painting = True
    Me.SetFocus
    
End Function


Private Sub VA_ID_AfterUpdate()
    
    DoCmd.Hourglass True
    Call VAOpen(Me.VA_ID.Column(0), Me.VA_ID.Column(1))
    DoCmd.Hourglass False
    
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



Private Sub cmdListMA_Standard_Click()
    Me!List_MA.RowSource = "ztbl_MA_Schnellauswahl"
    Me!List_MA.Requery
    bEntfernungsModus = False
End Sub

Private Sub cmdListMA_Entfernung_Click()
    Dim lngObjektID As Long
    Dim strSQL As String
    lngObjektID = Nz(DLookup("Objekt_ID", "tbl_VA_Auftragstamm", "ID=" & Nz(Me.VA_ID, 0)), 0)
    If lngObjektID = 0 Then
        MsgBox "Kein Objekt fuer diesen Auftrag hinterlegt!", vbExclamation
        Exit Sub
    End If
    strSQL = "SELECT MA.ID AS MA_ID, MA.Nachname & ', ' & MA.Vorname & ' (' & Format(Nz(D.Entf_KM,0),'0.0') & ' km)' AS Anzeige " & _
             "FROM (ztbl_MA_Schnellauswahl AS S INNER JOIN tbl_MA_Mitarbeiterstamm AS MA ON MA.ID = S.MA_ID) " & _
             "LEFT JOIN tbl_MA_Objekt_Entfernung AS D ON D.MA_ID = MA.ID AND D.Objekt_ID = " & lngObjektID & " " & _
             "ORDER BY Nz(D.Entf_KM,9999), MA.Nachname, MA.Vorname"
    Me!List_MA.RowSource = strSQL
    Me!List_MA.Requery
    bEntfernungsModus = True
End Sub

