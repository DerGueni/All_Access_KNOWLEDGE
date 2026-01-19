VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_MA_Abwesenheitsplanung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub AbwesenArt_AfterUpdate()

Select Case Me!AbwesenArt
    Case 1
        Me!TlZeitVon.Enabled = False
        Me!TlZeitBis.Enabled = False

    Case 2
        Me!TlZeitVon.Enabled = True
        Me!TlZeitBis.Enabled = True

    Case Else
        
End Select

End Sub


Private Sub btnAllLoesch_Click()
CurrentDb.Execute ("DELETE * FROM tbltmp_Fehlzeiten")
DoEvents
Me!lsttmp_Fehlzeiten.Requery
DoEvents
End Sub



Private Sub btnMarkLoesch_Click()
    Dim var As Variant
    Dim str
    Dim VertragNr As String
    Dim i As Long
    str = ""
    ' Listbox.column(Spalte, Zeile) <0,0>
    ' For Each var In Me!MeineListbox.ItemsSelected

    For Each var In Me!lsttmp_Fehlzeiten.ItemsSelected
         i = Me!lsttmp_Fehlzeiten.Column(0, var)
         CurrentDb.Execute ("DELETE * FROM tbltmp_Fehlzeiten WHERE ID = " & i)
         'str = str & ";" & Me!MeineListbox.Column(1, var)
    Next var
    DoEvents
'    MsgBox str
    Me!lsttmp_Fehlzeiten.RowSource = Me!lsttmp_Fehlzeiten.RowSource
    Me!lsttmp_Fehlzeiten.Requery
    DoEvents

End Sub

Private Sub bznUebernehmen_Click()

Dim rs      As Recordset
Dim NV_IDs  As String
Dim Anz_IDs As Integer
Dim Max_ID  As Integer
Dim i As Integer

    Anz_IDs = TCount("ID", "tbltmp_Fehlzeiten", "ID IS NOT NULL")
    
    CurrentDb.Execute ("qry_Ins_MA_NVerfuegZeiten")
    DoEvents
    Call CurrentDb.Execute("qry_MA_NVerfueg_ZeitUpdate")
    DoEvents
    Call CurrentDb.Execute("qry_MA_NVerfueg_ZeitUpdate_2")
    DoEvents
    CurrentDb.Execute ("DELETE * FROM tbltmp_Fehlzeiten")
    DoEvents
    Me!lsttmp_Fehlzeiten.Requery
    DoEvents

    
    'Stunden berechnen
    Max_ID = TMax("ID", NVERFUEG, "ID IS NOT NULL")
    For i = Max_ID - Anz_IDs + 1 To Max_ID
        NV_IDs = NV_IDs & i & ","
    Next i
    NV_IDs = Left(NV_IDs, Len(NV_IDs) - 1)
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & NVERFUEG & " WHERE ID IN (" & NV_IDs & ")", dbOpenSnapshot)
    Do While Not rs.EOF
        Call calc_NV_Stunden(rs.fields("ID"), rs.fields("MA_ID"))
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    MsgBox "Nicht-Verfügbar-Zeiten erfolgreich übernommen"
        
End Sub

Private Sub btnAbwBerechnen_Click()
Dim iMA_ID As Long
Dim strAbwesenArt As String
Dim bNurWerkTag As Boolean
Dim dtDatvon As Date
Dim dtDatBis As Date
Dim dtDatvon1 As Date
Dim dtDatBis1 As Date
Dim dtTlZeitVon As Date
Dim dtTlZeitBis As Date
Dim Bemerk As String
Dim strSQL As String
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim iTag As Long
Dim dt1 As Date
Dim i As Long
Dim j As Long
Dim k As Long
Dim iwk As Long

iMA_ID = Nz(Me!cbo_MA_ID, 0)
strAbwesenArt = Nz(Me!cboAbwGrund)
Bemerk = Nz(Me!Bemerkung)

If iMA_ID = 0 Then
    MsgBox "bitte zuerst Mitarbeiter eingeben"
    Exit Sub
End If

If Len(Trim(Nz(strAbwesenArt))) = 0 Then
    MsgBox "bitte zuerst einen Grund eingeben"
    Exit Sub
End If

'bis=von wenn bis leer
If Len(Trim(Nz(Me!DatVon))) = 0 Or Len(Trim(Nz(Me!DatBis))) = 0 Then Me.DatBis = Me.DatVon

'If Len(Trim(Nz(Me!DatVon))) = 0 Or Len(Trim(Nz(Me!DatBis))) = 0 Then
'    MsgBox "bitte zuerst Von- und BisDatum eingeben"
'    Exit Sub
'End If

If dtDatvon > dtDatBis Then
    MsgBox "Von- und BisDatum sind vertauscht"
    Exit Sub
End If

dtDatvon = Fix(Me!DatVon)
dtDatBis = Fix(Me!DatBis)
bNurWerkTag = Me!NurWerktags

Select Case Me!AbwesenArt
    Case 1  ' Ganztag
        dtTlZeitVon = TimeSerial(0, 0, 0)
        dtTlZeitBis = TimeSerial(23, 59, 0)
        iTag = 0
    Case 2  ' Partiell von bis
        dtTlZeitVon = TimeSerial(Hour(Me!TlZeitVon), minute(Me!TlZeitVon), 0)
        dtTlZeitBis = TimeSerial(Hour(Me!TlZeitBis), minute(Me!TlZeitBis), 0)
        iTag = 0
        If dtTlZeitVon > dtTlZeitBis Then
            iTag = 1
        End If
    Case Else
End Select

'If bNurWerkTag = False And Me!AbwesenArt = 1 Then
'
'    dtDatBis = CDate(CDbl(dtDatBis) + CDbl(TimeSerial(23, 59, 0)))
'    strSQL = ""
'    strSQL = strSQL & "INSERT INTO tbltmp_Fehlzeiten ( MA_ID, AbwesenArt, Bemerk, DatVon, DatBis )"
'    strSQL = strSQL & " SELECT " & iMA_ID & " AS A3, '" & strAbwesenArt & "' AS A4, '" & Bemerk & "' As A5, " & DateTimeForSQL(Me!DatVon) & " AS a1, " & DateTimeForSQL(dtDatBis) & " AS a2"
'    strSQL = strSQL & " FROM _tblInternalSystemFE;"
'    CurrentDb.Execute (strSQL)
'
'Else

    strSQL = ""
    strSQL = strSQL & "SELECT dtDatum FROM qryAlleTage_Default WHERE dtDatum"
    strSQL = strSQL & " BETWEEN " & SQLDatum(dtDatvon) & " AND " & SQLDatum(dtDatBis)
    If bNurWerkTag Then
        strSQL = strSQL & " AND Landesfeiertag = False"
        strSQL = strSQL & " AND Wochentag < 6"
    End If
    strSQL = strSQL & " Order By dtDatum"
    
    recsetSQL1 = strSQL
    
    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
    If ArrFill_DAO_OK1 Then
        For iZl = 0 To iZLMax1
            dt1 = DAOARRAY1(0, iZl)
            dtDatvon1 = dt1 + dtTlZeitVon
            dtDatBis1 = dt1 + dtTlZeitBis + iTag
        
            strSQL = ""
            strSQL = strSQL & "INSERT INTO tbltmp_Fehlzeiten ( MA_ID, AbwesenArt, Bemerk, DatVon, DatBis )"
            strSQL = strSQL & " SELECT " & iMA_ID & " AS A3, '" & strAbwesenArt & "' AS A4, '" & Bemerk & "' As A5, " & DateTimeForSQL(dtDatvon1) & " AS a1, " & DateTimeForSQL(dtDatBis1) & " AS a2"
            strSQL = strSQL & " FROM _tblInternalSystemFE;"
            CurrentDb.Execute (strSQL)
    
        Next iZl
        Set DAOARRAY1 = Nothing
    End If
'End If

Me!lsttmp_Fehlzeiten.Requery
DoEvents

End Sub


Private Sub cbo_MA_ID_AfterUpdate()
Dim anstArt As Integer
Dim sql As String
    
    anstArt = TLookup("Anstellungsart_ID", MASTAMM, "ID = " & Me.cbo_MA_ID)
    sql = "SELECT Kuerzel_Datev, Zeittyp FROM tbl_MA_Zeittyp"
    If anstArt = 5 Then
        sql = sql & " WHERE ID > 5 AND ID <> 7" 'ohne krank und Urlaub
    Else
        sql = sql & " WHERE ID > 4 AND ID <> 11" 'ohne Hauptjob
       
    End If
    sql = sql & " ORDER BY SortNr"
    cboAbwGrund.RowSource = sql

End Sub


Private Sub DatBis_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub DatVon_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)
CurrentDb.Execute ("Delete * FROM tbltmp_Fehlzeiten")
Me!lsttmp_Fehlzeiten.Requery
Call create_Default_AlleTage(Get_Priv_Property("Default_Bundesland"))
DoEvents
Me.NurWerktags = False

Me.AbwesenArt = 1
Call AbwesenArt_AfterUpdate
Me.TlZeitVon = "00:00"
Me.TlZeitBis = "00:00"

End Sub

Private Sub Veranst_Status_ID_DblClick(Cancel As Integer)
DoCmd.OpenForm "frmtop_VA_Veranstaltungsstatus"
End Sub


Private Sub Veranstalter_ID_DblClick(Cancel As Integer)
    DoCmd.OpenForm "frm_KD_Kundenstamm"
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

