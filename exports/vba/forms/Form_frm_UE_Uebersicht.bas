VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_UE_Uebersicht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Me!btnUms    1 = Tag    2 = Woche    3 = Monat

Dim strSourceObject As String
Dim iStart_VA_ID As Long
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, VA_ID_Array, iZl As Long, iCol As Long
Dim dtdat_Vgl As Date
Dim woart_vgl As Long
Dim bNotRepOpen As Boolean
Dim iAutoVor As Long 'Mit Tagesweiterschaltung = 0 ohne Tagesweiterschaltung = 1 bei btnVor
Dim iAutoRueck As Long 'Mit Tagesweiterschaltung = 0 ohne Tagesweiterschaltung = 1 bei btnRueck

Public Function SetStartdatum(dt As Date)

Me!dtStartdatum = dt
DoEvents
btnStartdatum_Click
DoEvents
End Function

Public Function Button_Next()
'iAuto = 1  ' Keine Tagesweiterschaltung
btnVor_Click
End Function

Public Function Button_Prev()
btnrueck_Click
End Function

Public Function ScreenPrint()
bNotRepOpen = True
btnDruck_Click
bNotRepOpen = False
End Function



Private Sub btn_Heute_Click()
Me!dtStartdatum = Date
btnStartdatum_Click
End Sub

Private Sub Form_Close()
Call Set_Priv_Property("prp_StartDatum_Uebersicht", Me!dtStartdatum)

End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)

Dim strFE As String
Dim strBE As String
Dim aendAm As Date

fVA_AnzTage_Update
DoEvents

woart_vgl = 2
strSourceObject = "sub_VA_Woche"

'Me!frm_Menuefuehrung.Form!Befehl38.Visible = False

strFE = TLookup("FrontEndVersion", "_tblInternalSystemFE", "ID = 1")
strBE = TLookup("BackEndVersion", "_tblInternalSystemFE", "ID = 1")
aendAm = TLookup("Aend_am", "_tblInternalSystemFE", "ID = 1")

Me!lbl_Datum.caption = Get_Priv_Property("prp_StartDatum_Uebersicht")
Me!dtStartdatum = CDate(Get_Priv_Property("prp_StartDatum_Uebersicht"))

btnStartdatum_Click
'DoEvents
'Me!ums_TagWoche = Get_Priv_Property("prp_Ue_Oeffen")
'DoEvents

'iAuto = 0

''IstAlleAnzeigen_AfterUpdate
'If Me!ums_TagWoche <> 2 Then
'
'    DoEvents
'    DBEngine.Idle dbRefreshCache
'    DBEngine.Idle dbFreeLocks
'    DoEvents
'    WoUmsch Me!ums_TagWoche
'    'btnStartdatum_Click
'End If
'DoEvents
'


    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
'    DoCmd.ShowToolbar "Ribbon", acToolbarNo

'Me!lbl_Login.Caption = Loginname()

Me.Requery
DoEvents

End Sub


Public Function Load_Loginname()
Me!lbl_Login.caption = Loginname()
End Function


'Private Sub IstAlleAnzeigen_AfterUpdate()
'
'Dim strSQL As String
'
'If Me!IstAlleAnzeigen = True Then
'    Me!IstAlleAnzeigen.Caption = "Alle Anzeigen"
'Else
'    Me!IstAlleAnzeigen.Caption = "Nur Aufträge mit fehlenden MA"
'End If
'
''Neuaufbau erzwingen, da ungültiges Vergleichsdatum
'dtdat_Vgl = #1/1/1988#
'
'If Me!IstAlleAnzeigen = True Then
'
'    '''' ALLE
'    'qry_Anz_MA_Tag
'    strSQL = ""
'    strSQL = strSQL & "SELECT DISTINCT qry_Anz_MA_Hour.VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, Sum(qry_Anz_MA_Hour.MA_Plan) AS MA_Plan_Ges, Sum(qry_Anz_MA_Hour.MA_Soll) AS MA_Soll_Ges, Sum(qry_Anz_MA_Hour.MA_Ist) AS MA_Ist_Ges, TVA_Offen"
'    strSQL = strSQL & " FROM tbl_VA_AnzTage RIGHT JOIN (qry_Anz_MA_Hour RIGHT JOIN tbl_VA_Auftragstamm ON qry_Anz_MA_Hour.VA_ID = tbl_VA_Auftragstamm.ID) ON tbl_VA_AnzTage.VA_ID = tbl_VA_Auftragstamm.ID"
'    strSQL = strSQL & " GROUP BY qry_Anz_MA_Hour.VA_ID, tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, TVA_Offen;"
'    Call CreateQuery(strSQL, "qry_Anz_MA_Tag")
'
'    'qry_Anz_Auftrag_AllTag
'    strSQL = ""
'    strSQL = strSQL & "SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_AnzTage.TVA_Offen"
'    strSQL = strSQL & " FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID;"
'    Call CreateQuery(strSQL, "qry_Anz_Auftrag_AllTag")
'
'
'    'qry_Anz_sub_Monat
'    strSQL = ""
'
'    strSQL = strSQL & "SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum,"
'    strSQL = strSQL & " [Auftrag] & ' - ' & [Objekt] AS Auftrag_, Nz([TVA_Ist],0) & ' / ' & Nz([TVA_Soll],0) AS I_S, TVA_Offen"
'    strSQL = strSQL & " FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID;"
'    Call CreateQuery(strSQL, "qry_Anz_sub_Monat")
'
'Else
'
'    '''' OFFEN
'    'qry_Anz_MA_Tag
'    strSQL = ""
'    strSQL = strSQL & "SELECT DISTINCT qry_Anz_MA_Hour.VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, Sum(qry_Anz_MA_Hour.MA_Plan) AS MA_Plan_Ges, Sum(qry_Anz_MA_Hour.MA_Soll) AS MA_Soll_Ges, Sum(qry_Anz_MA_Hour.MA_Ist) AS MA_Ist_Ges, TVA_Offen"
'    strSQL = strSQL & " FROM tbl_VA_AnzTage RIGHT JOIN (qry_Anz_MA_Hour RIGHT JOIN tbl_VA_Auftragstamm ON qry_Anz_MA_Hour.VA_ID = tbl_VA_Auftragstamm.ID) ON tbl_VA_AnzTage.VA_ID = tbl_VA_Auftragstamm.ID"
'    strSQL = strSQL & " WHERE (((tbl_VA_AnzTage.TVA_Offen) = True))"
'    strSQL = strSQL & " GROUP BY qry_Anz_MA_Hour.VA_ID, tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, TVA_Offen;"
'    Call CreateQuery(strSQL, "qry_Anz_MA_Tag")
'    '
'
'    'qry_Anz_Auftrag_AllTag
'    strSQL = ""
'    strSQL = strSQL & "SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_AnzTage.TVA_Offen"
'    strSQL = strSQL & " FROM tbl_VA_Auftragstamm LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
'    strSQL = strSQL & " WHERE (((tbl_VA_AnzTage.TVA_Offen)=True));"
'    Call CreateQuery(strSQL, "qry_Anz_Auftrag_AllTag")
'
'    'qry_Anz_sub_Monat
'    strSQL = ""
'    strSQL = strSQL & "SELECT tbl_VA_Auftragstamm.ID AS VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum,"
'    strSQL = strSQL & " [Auftrag] & ' - ' & [Objekt] AS Auftrag_, Nz([TVA_Ist],0) & ' / ' & Nz([TVA_Soll],0) AS I_S, TVA_Offen"
'    strSQL = strSQL & " FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
'    strSQL = strSQL & " WHERE (((tbl_VA_AnzTage.TVA_Offen)=True));"
'    Call CreateQuery(strSQL, "qry_Anz_sub_Monat")
'
'End If
'
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents
'
'btnStartdatum_Click
'
'End Sub

Private Sub ums_TagWoche_AfterUpdate()
WoUmsch Me!ums_TagWoche
End Sub


Public Function WoUmsch(iums As Long)

Dim i As Long
Dim bt As Boolean

Me!ums_TagWoche.SetFocus

'Bildschirmflackern reduzieren
   On Error GoTo WoUmsch_Error

'Me.Painting = False

Me!ums_TagWoche = iums
DoEvents

Wo_Loesch

If Me!ums_TagWoche = 2 Then ' Wochenübersicht
    Me!btnrueck.Visible = True
    Me!btnVor.Visible = True
    strSourceObject = "sub_VA_Woche"
    For i = 0 To 6
        Me("sub_Tag" & i).Visible = True
        Me("sub_Tag" & i).SourceObject = strSourceObject
        DoEvents
        Me("sub_Tag" & i).Form!dtDatum = Me!dtStartdatum + i
    Next i
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    Wochanz_Fill
    Me!lbl_Ueberschr.caption = "Wochenübersicht    -    " & Format(Me!dtStartdatum, "Short Date", 2, 2) & "    bis    " & Format(Me!dtStartdatum + 6, "Short Date", 2, 2)

ElseIf Me!ums_TagWoche = 1 Then ' Tag
    Wochanz_Fill
    strSourceObject = "sub_VA_Tag"
'    If fAnzAuftragTag(Me!dtStartdatum) = 0 Then
'        bt = False
'    Else
'        bt = True
'    End If
    For i = 0 To 6
        Me("sub_Tag" & i).Visible = False
        Me("sub_Tag" & i).SourceObject = strSourceObject
        DoEvents
    Next i
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    TagesAnz_Fill

ElseIf Me!ums_TagWoche = 3 Then  ' Monatsübersicht
    Me!btnrueck.Visible = True
    Me!btnVor.Visible = True

    strSourceObject = "sub_VA_Monat"
    For i = 0 To 6
        Me("sub_Tag" & i).Visible = True
        Me("sub_Tag" & i).SourceObject = strSourceObject
        DoEvents
    Next i
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    MonatsAnz_Fill

End If
'Bildschirm einschalten
 Me.Painting = True

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
 
   On Error GoTo 0
   Exit Function

WoUmsch_Error:

'Bildschirm einschalten
 Me.Painting = True
    
 MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure WoUmsch of VBA Dokument Form_frm_UE_Uebersicht"

End Function

Function Wochanz_Fill()

'Erzeugen der Temp-Tabelle tbltmp_VA_Tag_All
' tbltmp_VA_Tag_txt = Nur die von-bis Stundenwerte als Textfile
'Alle von-bis-Werte eines auftrages werden als ein langer Text mit Zeilenumbrüchem dargestellt
'

Dim strSQL As String
Dim strSQL2 As String
Dim i As Long
Dim j As Long
Dim k As Long
Dim kk As Long
Dim vastr As String
Dim va_ID_Vgl As Long
Dim dtDatum As Date
Dim s As String

Dim iVA_ID As Long
Dim iVADatum_ID As Long

Dim db As DAO.Database
Dim rst As DAO.Recordset

If dtdat_Vgl = Me!dtStartdatum Then Exit Function

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

CurrentDb.Execute ("Delete * FROM tbltmp_VA_Tag_txt")

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

CurrentDb.Execute ("Delete * FROM tbltmp_VA_Tag_All")

strSQL = ""
strSQL = strSQL & "INSERT INTO tbltmp_VA_Tag_All ( VA_ID, VADatum_ID, VADatum, Auftrag, Objekt, MA_SPI, TVA_Offen)"
strSQL = strSQL & " SELECT qry_Anz_MA_Tag_SPI.VA_ID, qry_Anz_MA_Tag_SPI.VADatum_ID, qry_Anz_MA_Tag_SPI.VADatum,"
strSQL = strSQL & " qry_Anz_MA_Tag_SPI.Auftrag , qry_Anz_MA_Tag_SPI.ObjOrt, qry_Anz_MA_Tag_SPI.MA_SPI, qry_Anz_MA_Tag_SPI.TVA_Offen"
strSQL = strSQL & " FROM qry_Anz_MA_Tag_SPI"
strSQL = strSQL & " WHERE (((VADatum) Between " & SQLDatum(Me!dtStartdatum) & " AND " & SQLDatum(Me!dtStartdatum + 6) & "))" & strSQL2 & ";"

CurrentDb.Execute (strSQL)

DoEvents

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM tbltmp_VA_Tag_All;")
With rst
    Do Until .EOF
        .Edit
            iVA_ID = .fields("VA_ID")
            iVADatum_ID = .fields("VADatum_ID")
            recsetSQL1 = "SELECT * FROM qry_Anz_Ma_Neu_Hour_3 WHERE VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " ORDER BY VA_ID,VADatum_ID, Zeit;"
            ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
            'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
            s = ""
            If ArrFill_DAO_OK1 Then
                For iZl = 0 To iZLMax1
                    s = s & CStr(Nz(DAOARRAY1(2, iZl)))
                    If iZl < iZLMax1 Then
                        s = s & vbCrLf
                    End If
                Next iZl
                Set DAOARRAY1 = Nothing
            End If
            .fields("MA_Hour") = s
        .update
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

dtdat_Vgl = Me!dtStartdatum

End Function



Private Sub btnStartdatum_Click()

Dim i As Long

   On Error GoTo btnStartdatum_Click_Error

'Bildschirm ausschalten
' Me.Painting = False

Wochanz_Fill

If Me!ums_TagWoche = 1 Then  ' Tag
    TagesAnz_Fill
    'Me!lbl_Ueberschr.Caption = "Tagesübersicht für " & Format(Me!dtStartdatum, "Long Date", 2, 2)

ElseIf Me!ums_TagWoche = 2 Then ' Woche
    For i = 0 To 6
        Me("sub_Tag" & i).Form!dtDatum = Me!dtStartdatum + i
    Next i
    Me!lbl_Ueberschr.caption = "Wochenübersicht  -  " & Format(Me!dtStartdatum, "Short Date", 2, 2) & "  bis  " & Format(Me!dtStartdatum + 6, "Short Date", 2, 2)

    
ElseIf Me!ums_TagWoche = 3 Then ' Monat
    MonatsAnz_Fill
    'Me!lbl_Ueberschr.Caption = "Monatsübersicht für " & TLookup("MonLang", "_tblAlleMonate", "MonNr = " & iMonat) & " " & iJahr

End If

Me.Requery

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

'Bildschirm einschalten
 Me.Painting = True

   On Error GoTo 0
   Exit Sub

btnStartdatum_Click_Error:

'Bildschirm einschalten
 Me.Painting = True
    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure btnStartdatum_Click of VBA Dokument Form_frm_UE_Uebersicht"

End Sub

Function TagesAnz_Fill()
'Tagesübersicht vorbereiten
'Wenn mehr als 7 Aufträge pro Tag vorhanden sind, werden die vor und zurpckbuttons eingeblendet


Dim i As Long
    
   On Error GoTo TagesAnz_Fill_Error

'If Me!IstAlleAnzeigen = True Then
    recsetSQL1 = "SELECT VA_ID, TVA_Offen FROM tbl_VA_AnzTage WHERE (((VADatum) = " & SQLDatum(Me!dtStartdatum) & ")) Order BY VA_ID;"
'Else
'    recsetSQL1 = "SELECT VA_ID, TVA_Offen FROM tbl_VA_AnzTage WHERE (((VADatum) = " & SQLDatum(Me!dtStartdatum + i) & ")) AND (TVA_Offen = TRUE) Order BY VA_ID;"
'End If

    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, VA_ID_Array)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
    
' btn vor und zurück immer sichtbar
' 13.8.2015  Kobd
'################
    iStart_VA_ID = 0
    If ArrFill_DAO_OK1 And iZLMax1 > 6 Then
        Me!btnrueck.Visible = True
        Me!btnVor.Visible = True
'        iAuto = 1
    Else
'        iAuto = 0
'        Me!btnrueck.Visible = False
'        Me!btnVor.Visible = False
    End If
  
'####################
  
   i = fAnzAuftragTag(Me!dtStartdatum)
   If i = 0 Then
       iAutoVor = 0
    Else  ' Entweder Auftrag oder Anfang oder Ende
       iAutoVor = 1
   End If
        
   btnVor_Click
    Me!lbl_Ueberschr.caption = "Tagesübersicht  -  " & Format(Me!dtStartdatum, "Long Date", 2, 2)

   On Error GoTo 0
   Exit Function

TagesAnz_Fill_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure TagesAnz_Fill of VBA Dokument Form_frm_UE_Uebersicht"

End Function

Private Sub btnVor_Click()
'Me!btnUms    1 = Tag    2 = Woche    3 = Monat
Dim i As Long
Dim i1 As Long, i2 As Long

Wo_Loesch
If Me!ums_TagWoche = 2 Then
    Me!dtStartdatum = Me!dtStartdatum + 7
    btnStartdatum_Click
ElseIf Me!ums_TagWoche = 1 Then
    'Nächster Tag 13.08.2015 - Kobd
    '###############################
    'Dim ix As Long
    'ix = Nz(TLookup("AnzTag", "qry_Anz_Auftrag_ProTag", "VADatum = " & SQLDatum(Me!dtStartdatum)), 0)
    'If ((ix = iStart_VA_ID Or ix < 8) And (iAutoVor = 0)) Then
     If iAutoVor = 0 Then
        i1 = 0
        i2 = 0
        Do
            i2 = i2 + 1
            i1 = fAnzAuftragTag(Me!dtStartdatum + i2)
        Loop While i1 = 0
        Me!dtStartdatum = Me!dtStartdatum + i2
        WoUmsch 1
        iStart_VA_ID = 0
    Else
        Tages_VA_Fill
    End If
    '################################
ElseIf Me!ums_TagWoche = 3 Then
    Me!dtStartdatum = DateSerial(Year(Me!dtStartdatum), Month(Me!dtStartdatum) + 1, 1)
    MonatsAnz_Fill
End If
'iAuto = 0
End Sub

Private Sub btnrueck_Click()
'Me!btnUms    1 = Tag    2 = Woche    3 = Monat
Dim i As Long
Dim i1 As Long, i2 As Long

Wo_Loesch
If Me!ums_TagWoche = 2 Then
    Me!dtStartdatum = Me!dtStartdatum - 7
    btnStartdatum_Click
ElseIf Me!ums_TagWoche = 1 Then

    'Vorheriger Tag 13.08.2015 - Kobd
    '###############################
'    Dim ix As Long
'    ix = Nz(TLookup("AnzTag", "qry_Anz_Auftrag_ProTag", "VADatum = " & SQLDatum(Me!dtStartdatum)), 0)
'    If iStart_VA_ID < ix Or ix < 8 Then
    If iAutoRueck = 0 Then
        i1 = 0
        i2 = 0
        
        Do
            i2 = i2 + 1
            i1 = fAnzAuftragTag(Me!dtStartdatum - i2)
        Loop While i1 = 0
       
        Me!dtStartdatum = Me!dtStartdatum - i2
        WoUmsch 1
    Else
        iStart_VA_ID = iStart_VA_ID - 13
        If iStart_VA_ID < 0 Then
            iStart_VA_ID = 0
        End If
        Tages_VA_Fill
    End If
    '################################
        
ElseIf Me!ums_TagWoche = 3 Then
    Me!dtStartdatum = DateSerial(Year(Me!dtStartdatum), Month(Me!dtStartdatum) - 1, 1)
    MonatsAnz_Fill
End If
End Sub

Function Wo_Loesch()
Dim i As Long
For i = 1 To 6
    Me("W" & i) = ""
Next i
End Function

Function Tages_VA_Fill()

Dim i As Long
Dim i1 As Long
'Dim strSQL1 As String
Dim strSQL2 As String
Dim stdat As Date

'Revers
'Const Const_BackColor_Std As Long = 16777215
'Const Const_BackColor_Gelb As Long = 0
'Const Const_ForeColor_Std As Long = 0
'Const Const_ForeColor_Gelb As Long = 16777215

'Gelb hinterlegt
Const Const_BackColor_Std As Long = 16777215
Const Const_BackColor_Gelb As Long = 62207
Const Const_ForeColor_Std As Long = 0
Const Const_ForeColor_Gelb As Long = 0

   On Error GoTo Tages_VA_Fill_Error

If Not ArrFill_DAO_OK1 Then Exit Function
'Me.Painting = False

stdat = Me!dtStartdatum
    i1 = 0

    If iZLMax1 > 6 Then
        iAutoVor = 1
        iAutoRueck = 1
    Else
        iAutoVor = 0
        iAutoRueck = 0
    End If
    If iStart_VA_ID = 0 Then iAutoRueck = 0
    
    For i = iStart_VA_ID To iStart_VA_ID + 6
        Me!ums_TagWoche.SetFocus
        Me("sub_Tag" & i1).SourceObject = strSourceObject
        DoEvents
        If i <= iZLMax1 Then
            Me("sub_Tag" & i1).Visible = True
            Me("sub_Tag" & i1).Form!dtDatum = stdat
            Me("sub_Tag" & i1).Form!VA_ID = VA_ID_Array(0, i)
            DoEvents
            
'            If VA_ID_Array(1, i) = True Then  ' Gelb setzen
'                Me("sub_Tag" & i1).Form!subsub_VA_Woche.Form!VA_Auftrag.BackColor = Const_BackColor_Gelb
'                Me("sub_Tag" & i1).Form!subsub_VA_Woche.Form!VA_Auftrag.ForeColor = Const_ForeColor_Gelb
'            Else   ' Normal setzen
'                Me("sub_Tag" & i1).Form!subsub_VA_Woche.Form!VA_Auftrag.BackColor = Const_BackColor_Std
'                Me("sub_Tag" & i1).Form!subsub_VA_Woche.Form!VA_Auftrag.ForeColor = Const_ForeColor_Std
'            End If
            
'            strSQL1 = ""
'            strSQL1 = strSQL1 & "SELECT [Nachname] & ', ' & [Vorname] AS Gesname"
'            strSQL1 = strSQL1 & " FROM tbl_MA_VA_Planung INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
'            strSQL1 = strSQL1 & " WHERE (((tbl_MA_VA_Planung.VA_ID)= " & VA_ID_Array(0, i)
'            strSQL1 = strSQL1 & " ) AND ((tbl_MA_VA_Planung.Status_ID)=1 Or (tbl_MA_VA_Planung.Status_ID)=2));"
            
            strSQL2 = ""
            strSQL2 = strSQL2 & "SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, Nz(tbl_MA_VA_Zuordnung.MA_ID,0) AS Ausdr1, tbl_MA_VA_Zuordnung.PosNr,"
            strSQL2 = strSQL2 & " [Nachname] & ', ' & [Vorname] AS Mitarbeiter, Left(Nz([VA_Start]),5) AS Start"
            strSQL2 = strSQL2 & " FROM tbl_VA_Start RIGHT JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm"
            strSQL2 = strSQL2 & " ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID"
            strSQL2 = strSQL2 & " WHERE (tbl_MA_VA_Zuordnung.VA_ID= " & VA_ID_Array(0, i) & ") AND ((tbl_MA_VA_Zuordnung.VADatum) = " & SQLDatum(stdat) & ") Order By PosNr;"
            
'            Debug.Print strSQL2
'            Me("sub_Tag" & i1).Form!lst_Plan.RowSource = strSQL1
            Me("sub_Tag" & i1).Form!lst_Ist.RowSource = strSQL2
            
            Me("sub_Tag" & i1).Form.Requery
            Me("sub_Tag" & i1).Visible = True
        Else
            Me("sub_Tag" & i1).Visible = False
            iAutoVor = 0
        End If
        i1 = i1 + 1
    Next i
    iStart_VA_ID = i - 1
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
   
'Me.Painting = True

   On Error GoTo 0
   Exit Function

Tages_VA_Fill_Error:

    Me.Painting = True
    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Tages_VA_Fill of VBA Dokument Form_frm_UE_Uebersicht"

End Function


Private Sub btnWeiter_Click()
DoCmd.OpenForm "__frmHlpMenu_Weitere_Masken"
End Sub

Private Sub btnSysInfo_Click()
DoCmd.OpenForm "_frmHlp_SysInfo"
End Sub


Private Sub dtStartdatum_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub


Function MonatsAnz_Fill()

'sub_TagN (0 - 6)
'WocheN (0 - 5)

Dim dtDatum As Date
Dim i As Long

Dim iJahr As Long
Dim iMonat As Long
Dim iWoTag As Long

Dim strWoNr As String
Dim strWoTagNr As String
Dim idt As Long
Dim dtlauf As Date
Dim dtEnde As Date
Dim iTag As Long
Dim iWoche As Long
Dim wochNr As Long
Dim wochNrMax As Long

Dim iMonstart_WoTag As Long
Dim iMonEnde_WoTag As Long
Dim iMonende_TagNr As Long  ' (28 / 30 / 31)
Dim Wn As Long

Dim var As Variant
Dim bOffen As Boolean

Dim strSQL As String

   On Error GoTo MonatsAnz_Fill_Error

Me.Painting = False

dtDatum = Me!dtStartdatum

iJahr = Year(dtDatum)
iMonat = Month(dtDatum)

idt = 1
dtlauf = DateSerial(iJahr, iMonat, 1)
dtEnde = DateSerial(iJahr, iMonat + 1, 0)
iMonende_TagNr = Day(dtEnde)
iMonstart_WoTag = TLookup("WN_KalTag", "_tblAlleTage", "dtDatum = " & SQLDatum(dtlauf))
iMonEnde_WoTag = TLookup("WN_KalTag", "_tblAlleTage", "dtDatum = " & SQLDatum(dtEnde))
wochNr = TLookup("KW_D", "_tblAlleTage", "dtDatum = " & SQLDatum(dtlauf))
wochNrMax = TLookup("KW_D", "_tblAlleTage", "dtDatum = " & SQLDatum(dtEnde))
Me!W1 = "Wo" & vbNewLine & wochNr

For iWoche = 0 To 5
    strWoNr = "Woche" & iWoche
    Me!ums_TagWoche.SetFocus
    For iTag = 0 To 6
        strWoTagNr = "sub_Tag" & iTag
        Me!ums_TagWoche.SetFocus
        If idt >= iMonstart_WoTag And idt <= iMonEnde_WoTag Then
            Me(strWoTagNr).Form!(strWoNr).Visible = True
            Me(strWoTagNr).Form!(strWoNr).Enabled = True
            Me(strWoTagNr).Form!(strWoNr).Locked = False
            Me(strWoTagNr).Form!(strWoNr).Form!dtDatum = dtlauf
'            Me(strWoTagNr).Form!(strWoNr).Form!List_Tag.RowSource = "SELECT qry_Anz_sub_Monat.* FROM qry_Anz_sub_Monat WHERE (((qry_Anz_sub_Monat.VADatum)= " & SQLDatum(dtlauf) & "));"
            strSQL = "SELECT VA_ID, VADatum_ID, VADatum, TVA_Offen, [Auftrag_], I_S FROM qry_Anz_sub_Monat WHERE (((qry_Anz_sub_Monat.VADatum)= " & SQLDatum(dtlauf) & "));"
            Me(strWoTagNr).Form!(strWoNr).Form!List_Tag.RowSource = strSQL
            DoEvents
            
'Schwarz markieren
'            If rstDcount("*", strSQL) > 0 Then
'                For var = 0 To Me(strWoTagNr).Form!(strWoNr).Form!List_Tag.ListCount - 1
'                    bOffen = Me(strWoTagNr).Form!(strWoNr).Form!List_Tag.Column(3, var)
'                    If bOffen <> 0 Then
'                        Me(strWoTagNr).Form!(strWoNr).Form!List_Tag.Selected(var) = True
'                    Else
'                        Me(strWoTagNr).Form!(strWoNr).Form!List_Tag.Selected(var) = False
'                    End If
'                Next var
'            End If
            
            dtlauf = dtlauf + 1
        Else
'            Me(strWoTagNr)!tmpFokus.SetFocus
            Me!ums_TagWoche.SetFocus
            Me(strWoTagNr).Form!(strWoNr).Visible = False
'            Me(strWoTagNr).Form!(strWoNr).Form!dtDatum = Null
'            Me(strWoTagNr).Form!(strWoNr).Form!List_Tag.RowSource = ""
'            Me(strWoTagNr).Form!(strWoNr).enabled = False
'            Me(strWoTagNr).Form!(strWoNr).Locked = True
        End If
        idt = idt + 1
    Next iTag
    wochNr = wochNr + 1
    If wochNr <= wochNrMax Then
        Me("W" & iWoche + 2) = wochNr
    End If
        
Next iWoche

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

Me!lbl_Ueberschr.caption = "Monatsübersicht  -  " & TLookup("MonLang", "_tblAlleMonate", "MonNr = " & iMonat) & " " & iJahr

Me.Painting = True

   On Error GoTo 0
   Exit Function

MonatsAnz_Fill_Error:
    Me.Painting = True
    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure MonatsAnz_Fill of VBA Dokument Form_frm_UE_Uebersicht"
End Function


Private Sub btnDruck_Click()

Dim strPath As String
Dim strPathIn As String
Dim strPathOut As String
Dim strPathOut1 As String
Dim strPathOut2 As String
Dim strSubPath As String

Dim atrDat As String

Me!dtStartdatum.SetFocus
Me!sub_Menuefuehrung.Visible = False
Me!btnDruck.Visible = False
Me!btnStartdatum.Visible = False
Me!btn_MenueFuehrung.Visible = False
Me!btnrueck.Visible = False
Me!btnVor.Visible = False
Me!lbl_Datum.caption = Now
DoEvents

strPath = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 8"))

Select Case Me!ums_TagWoche

    Case 1 ' Tag -- 2 Bilder erlaubt

        strPathIn = strPath & Left(Me!ums_TagWoche.Column(1), 1) & "_" & Me!dtStartdatum & ".bmp"
        strPathOut1 = strPath & Left(Me!ums_TagWoche.Column(1), 1) & "_" & Me!dtStartdatum & "_1.jpg"
        strPathOut2 = strPath & Left(Me!ums_TagWoche.Column(1), 1) & "_" & Me!dtStartdatum & "_2.jpg"
        
        If File_exist(strPathOut2) And File_exist(strPathOut1) Then
            Kill strPathOut1
            Name strPathOut2 As strPathOut1
            DoEvents
            strPathOut = strPathOut2
        ElseIf File_exist(strPathOut1) Then
            strPathOut = strPathOut2
        Else
            strPathOut = strPathOut1
        End If
            
    Case 3 ' Monat
    
        strPathIn = strPath & Left(Me!ums_TagWoche.Column(1), 1) & "_" & Right(Me!dtStartdatum, 7) & ".bmp"
        strPathOut = strPath & Left(Me!ums_TagWoche.Column(1), 1) & "_" & Right(Me!dtStartdatum, 7) & ".jpg"
    
    Case Else ' Woche

        strPathIn = strPath & Left(Me!ums_TagWoche.Column(1), 1) & "_" & Me!dtStartdatum & ".bmp"
        strPathOut = strPath & Left(Me!ums_TagWoche.Column(1), 1) & "_" & Me!dtStartdatum & ".jpg"

End Select

Call Set_Priv_Property("prp_Uebersichten_JPG_File", strPathOut)

'strPath = Left(CurrentDb.Name, Len(CurrentDb.Name) - Len(Dir(CurrentDb.Name))) & "Temp.bmp"

'ihWnd = fhWnd(Me!ActiveXStr0)

'Call prcSave_Picture_Active_Window_part(strPath, ihWnd) 'aktive hwnd'
'Call prcSave_Picture_Active_Window_part(strPath, Me.Parent.hwnd) 'aktive hwnd'
Call prcSave_Picture_Active_Window_part(strPathIn, Me.hwnd) 'aktive hwnd'

'Call prcSave_Picture_Active_Window_part_cm(strPath, Me.hwnd, 0, 0, 31.7, 19)

DoEvents
Sleep 10
DoEvents

Call Save_as_Jpg(strPathIn, strPathOut)

DoEvents
Sleep 10

Kill strPathIn

DoEvents
Sleep 10

If bNotRepOpen = False Then

    DoCmd.OpenReport "rptObjektkosten_Bild", acViewPreview

End If

Me!lbl_Datum.caption = Date
Me!sub_Menuefuehrung.Visible = True
Me!btnDruck.Visible = True
Me!btn_MenueFuehrung.Visible = True
Me!btnStartdatum.Visible = True
Me!btnrueck.Visible = True
Me!btnVor.Visible = True
Me!btnDruck.SetFocus
DoEvents

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
