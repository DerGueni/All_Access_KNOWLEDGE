Attribute VB_Name = "mdl_DP_Create"
Option Compare Database
Option Explicit

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

Function fSuchZl(i As Long) As Long
fSuchZl = -1
For iZl = 0 To iZLMax1
    If DAOARRAY1(0, iZl) = i Then
        fSuchZl = iZl
        Exit For
    End If
Next iZl
End Function

Function fObtstxx()
    Call fCreate_DP_tmptable(DateSerial(2015, 11, 4), 0, 0)
    
End Function


Function fCreate_DP_tmptable(dtstartdat As Date, bNurIstNichtZugeordnet As Boolean, iPosAusblendAb As Long)

Dim dt(6) As Date
Dim strdtPkt(6) As String
Dim strdtUdl(6) As String
Dim i As Long
Dim strSQL As String
Dim chr34 As String
Dim OrtVgl As String

Dim iZuoID As Long
Dim iMA_ID As Long
Dim strMAName As String
Dim bfraglich As Boolean
Dim strvon As String
Dim strbis As String
Dim ztV As Variant
Dim zt As Date

Dim db As DAO.Database
Dim rst As DAO.Recordset

   On Error GoTo fCreate_DP_tmptable_Error

chr34 = Chr$(34)
'Datum füllen
For i = 0 To 6
    dt(i) = dtstartdat + i
    strdtPkt(i) = Format(dt(i), "Short Date")
    strdtUdl(i) = Replace(strdtPkt(i), ".", "_")
Next i

' Erzeugen Query "qry_DP_Alle_Zt"
strSQL = ""
strSQL = strSQL & "SELECT qry_DP_Alle_Obj.* FROM qry_DP_Alle_Obj WHERE (((VADatum)"
strSQL = strSQL & " Between " & SQLDatum(dt(0)) & " AND " & SQLDatum(dt(6)) & "))"
If bNurIstNichtZugeordnet = True Then
    strSQL = strSQL & " AND (MA_ID = 0) "
End If
If iPosAusblendAb > 0 Then
    strSQL = strSQL & " AND (Anz_MA < " & iPosAusblendAb & ") "
End If
strSQL = strSQL & " ORDER BY VADatum, ObjOrt, Pos_Nr;"
If Not CreateQuery(strSQL, "qry_DP_Alle_Zt") Then
    MsgBox strSQL, vbCritical, "Fehler beim Create der Tabelle 'qry_DP_Alle_Zt'"
    Exit Function
End If

' Erzeugen Query "qry_DP_Kreuztabelle"
strSQL = ""
strSQL = strSQL & "TRANSFORM First([qry_DP_Alle_Zt].ZuordID) AS ErsterWertvonZuordID SELECT [qry_DP_Alle_Zt].ObjOrt, [qry_DP_Alle_Zt].Pos_Nr"
strSQL = strSQL & " FROM qry_DP_Alle_Zt GROUP BY [qry_DP_Alle_Zt].ObjOrt, [qry_DP_Alle_Zt].Pos_Nr PIVOT Format([VADatum], 'Short Date')"
strSQL = strSQL & " IN ('" & strdtPkt(0) & "','" & strdtPkt(1) & "', '" & strdtPkt(2) & "', '" & strdtPkt(3) & "', '" & strdtPkt(4) & "', '" & strdtPkt(5) & "', '" & strdtPkt(6) & "');"

'strSQL = Replace(strSQL, "'", chr34)
If Not CreateQuery(strSQL, "qry_DP_Kreuztabelle") Then
    MsgBox strSQL, vbCritical, "Fehler beim Create der Tabelle 'qry_DP_Kreuztabelle'"
    Exit Function
End If

'tbltmp_DP_Grund fuellen
CurrentDb.Execute ("DELETE * FROM tbltmp_DP_Grund")
DoEvents

strSQL = ""
strSQL = strSQL & "INSERT INTO tbltmp_DP_Grund SELECT qry_DP_Kreuztabelle.ObjOrt, qry_DP_Kreuztabelle.ObjOrt AS ObjOrt_Anzeige, qry_DP_Kreuztabelle.Pos_Nr,"
strSQL = strSQL & " qry_DP_Kreuztabelle.[" & strdtUdl(0) & "] AS Tag1_Zuo_ID,"
strSQL = strSQL & " qry_DP_Kreuztabelle.[" & strdtUdl(1) & "] AS Tag2_Zuo_ID,"
strSQL = strSQL & " qry_DP_Kreuztabelle.[" & strdtUdl(2) & "] AS Tag3_Zuo_ID,"
strSQL = strSQL & " qry_DP_Kreuztabelle.[" & strdtUdl(3) & "] AS Tag4_Zuo_ID,"
strSQL = strSQL & " qry_DP_Kreuztabelle.[" & strdtUdl(4) & "] AS Tag5_Zuo_ID,"
strSQL = strSQL & " qry_DP_Kreuztabelle.[" & strdtUdl(5) & "] AS Tag6_Zuo_ID,"
strSQL = strSQL & " qry_DP_Kreuztabelle.[" & strdtUdl(6) & "] AS Tag7_Zuo_ID"
strSQL = strSQL & " FROM qry_DP_Kreuztabelle ORDER BY qry_DP_Kreuztabelle.ObjOrt, qry_DP_Kreuztabelle.Pos_Nr;"
CurrentDb.Execute (strSQL)
DoEvents

'tbltmp_DP_Grund_2 und tbltmp_DP_Grund_sort fuellen
CurrentDb.Execute ("DELETE * FROM tbltmp_DP_Grund_2")
CurrentDb.Execute ("DELETE * FROM tbltmp_DP_Grund_Sort")

CurrentDb.Execute ("qry_DP_Alle_Add_temp")

CurrentDb.Execute ("UPDATE tbltmp_DP_Grund INNER JOIN tbltmp_DP_Grund_Sort ON tbltmp_DP_Grund.ObjOrt = tbltmp_DP_Grund_Sort.ObjOrt SET tbltmp_DP_Grund.sortID = [tbltmp_DP_Grund_Sort].[ID];")

CurrentDb.Execute ("qry_DP_Allw_Ins_2")

CurrentDb.Execute ("UPDATE tbltmp_DP_Grund_2 SET tbltmp_DP_Grund_2.Startdat = " & SQLDatum(dtstartdat) & ";")
DoEvents

recsetSQL1 = "qry_DP_Alle_Zt_Fill"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

If Not ArrFill_DAO_OK1 Then
    MsgBox "Keine Projekte in diesem Zeitraum"
    Exit Function
End If

'ZuoID = 0
'MA_ID = 1
'Name = 2
'MA_Start = 3
'MA_Ende = 4
'Istfraglich = 5

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM tbltmp_DP_Grund_2 ORDER BY ID")
With rst
    OrtVgl = ""
    Do While Not .EOF
        .Edit
            If OrtVgl = .fields("ObjOrt_Anzeige") Then
                .fields("ObjOrt_Anzeige") = ""
            Else
                OrtVgl = .fields("ObjOrt_Anzeige")
            End If
            For i = 1 To 7
               iZuoID = Nz(.fields("Tag" & i & "_Zuo_ID"), 0)
               If iZuoID > 0 Then
                    iZl = fSuchZl(iZuoID)
                    If iZl < 0 Then
                        MsgBox "Probleme bei der Tabellenzuordnung - " & iZuoID
                        Exit Function
                    End If
                    ztV = Nz(DAOARRAY1(3, iZl))
                    If Len(Trim(ztV)) > 0 Then
                        strvon = Format(ztV, "hh:nn")
                    End If
                    If IsNull(DAOARRAY1(3, iZl)) Then
                        strvon = ""
                    End If
                    ztV = Nz(DAOARRAY1(4, iZl))
                    If Len(Trim(ztV)) > 0 Then
                        strbis = Format(ztV, "hh:nn")
                    End If
                    If IsNull(DAOARRAY1(4, iZl)) Then
                        strbis = ""
                    End If
                    iMA_ID = Nz(DAOARRAY1(1, iZl), 0)
                    strMAName = Nz(DAOARRAY1(2, iZl))
                    bfraglich = Nz(DAOARRAY1(5, iZl), 0)
                    
                    .fields("Tag" & i & "_MA_ID") = iMA_ID
                    .fields("Tag" & i & "_Name") = strMAName
                    .fields("Tag" & i & "_fraglich") = bfraglich
                    .fields("Tag" & i & "_von") = strvon
                    .fields("Tag" & i & "_bis") = strbis
                    
                End If
            Next i
    
        .update
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing
Set DAOARRAY1 = Nothing
Call Set_Priv_Property("prp_Dienstpl_StartDatum_Vgl", dtstartdat)

   On Error GoTo 0
   Exit Function

fCreate_DP_tmptable_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure fCreate_DP_tmptable of Modul mdl_DP_Create"
End Function


Function fcolw()

  Dim frm As Form
  Dim ctl As control
  Dim frmName As String

  Dim i As Long
  Dim j As Long
  Dim st As String
  
  Dim iLeft As Long
  
  Dim Twips2cm As Long

Twips2cm = 567
frmName = "sub_DP_Grund"

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
  frm.Controls("ID").ColumnWidth = 0
  frm.Controls("Startdat").ColumnWidth = 0
  frm.Controls("ObjOrt").ColumnWidth = 0
  frm.Controls("PosNr").ColumnWidth = 0
  frm.Controls("ObjOrt_Anzeige").ColumnWidth = 3.8 * Twips2cm
  For i = 1 To 7
    st = "Tag" & i & "_"
    frm.Controls(st & "Zuo_ID").ColumnWidth = 0
    frm.Controls(st & "MA_ID").ColumnWidth = 0
    frm.Controls(st & "Name").ColumnWidth = 3.5 * Twips2cm
    frm.Controls(st & "fraglich").ColumnWidth = 0 ' 0.7 * Twips2cm
    frm.Controls(st & "von").ColumnWidth = 1 * Twips2cm
    frm.Controls(st & "bis").ColumnWidth = 1 * Twips2cm
  Next i
  
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

frmName = "frm_DP_Dienstplan_Objekt"
  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
  
  iLeft = 5.2 * Twips2cm
  frm.Controls("lbl_Auftrag").width = 4.2 * Twips2cm
  frm.Controls("lbl_Auftrag").Left = iLeft
  iLeft = iLeft + 4.3 * Twips2cm
  For i = 1 To 7
    frm.Controls("lbl_Tag_" & i).width = 5.5 * Twips2cm
    frm.Controls("lbl_Tag_" & i).Left = iLeft
    iLeft = iLeft + 5.5 * Twips2cm
  Next i
  
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function

Function fcolw_MA()

  Dim frm As Form
  Dim ctl As control
  Dim frmName As String

  Dim i As Long
  Dim j As Long
  Dim st As String
  
  Dim Twips2cm As Long
  Dim iLeft As Long

Twips2cm = 567
frmName = "sub_DP_Grund_MA"

  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
  frm.Controls("ID").ColumnWidth = 0
  frm.Controls("Startdat").ColumnWidth = 0
  frm.Controls("MA_ID").ColumnWidth = 0
  frm.Controls("Hlp").ColumnWidth = 0
  frm.Controls("MAName").ColumnWidth = 3.8 * Twips2cm
  For i = 1 To 7
    st = "Tag" & i & "_"
    frm.Controls(st & "Zuo_ID").ColumnWidth = 0
    frm.Controls(st & "MA_ID").ColumnWidth = 0
    frm.Controls(st & "Name").ColumnWidth = 3.5 * Twips2cm
    frm.Controls(st & "fraglich").ColumnWidth = 0 ' 0.7 * Twips2cm
    frm.Controls(st & "von").ColumnWidth = 1 * Twips2cm
    frm.Controls(st & "bis").ColumnWidth = 1 * Twips2cm
  Next i
  
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

frmName = "frm_DP_Dienstplan_MA"
  DoCmd.OpenForm frmName, acDesign
  Set frm = Forms(frmName)
  
  iLeft = 5.2 * Twips2cm
  frm.Controls("lbl_Auftrag").width = 4.2 * Twips2cm
  frm.Controls("lbl_Auftrag").Left = iLeft
  iLeft = iLeft + 4.3 * Twips2cm
  For i = 1 To 7
    frm.Controls("lbl_Tag_" & i).width = 5.5 * Twips2cm
    frm.Controls("lbl_Tag_" & i).Left = iLeft
    iLeft = iLeft + 5.5 * Twips2cm
  Next i
  
  DoCmd.Close acForm, frmName, acSaveYes
  Set frm = Nothing

End Function


Function fSuchZl2(i As Long, iMA_ID As Long, dt As Date) As Long
fSuchZl2 = -1000
'ZuoID = 0
'MA_ID = 1
'Name = 2 ' objOrt
'MA_Start = 3
'MA_Ende = 4
'Istfraglich = 5
'VADatum = 6

For iZl = 0 To iZLMax1
    If DAOARRAY1(0, iZl) = i And DAOARRAY1(1, iZl) = iMA_ID And CDate(DAOARRAY1(6, iZl)) = dt Then
        fSuchZl2 = iZl
        Exit For
    End If
Next iZl
End Function


'Function fCreate_DP_MA_tmptable(dtstartdat As Date, iNurAktiveMA As Long)
' Falsche V68 Version
'
'' iNurAktiveMA  -- 0 = Alle, 1 = Nur Aktive, 2 = Nur Festangestellte, 3 = Nur Minijobber, 4 = Nur Subs
'
'Dim dt(6) As Date
'Dim strdtPkt(6) As String
'Dim strdtUdl(6) As String
'Dim i As Long, j As Long, k As Long
'Dim strSQL As String
'Dim chr34 As String
'Dim OrtVgl As String
'
'Dim iZuoID As Long
'Dim iMA_ID As Long
'Dim strMAName As String
'Dim bfraglich As Boolean
'Dim strvon As String
'Dim strbis As String
'Dim ztV As Variant
'Dim zt As Date
'
'Dim db As DAO.Database
'Dim rst As DAO.Recordset
'Dim Dttmp As Date
'
'Dim strSQLWhere As String
'Dim strSQLOrderBy As String
'
'' tbltmp_DP_MA_Neu_1 = Tabelle einzelne Werte untereinander - Alle MA die im Zeitraum zugeordnet oder nicht verfügbar sind, darunter der Rest
''d.h. i  Summe alle MA
'
'' tbltmp_DP_MA_Neu_2 = Tabelle einzelne Werte untereinander - Nur die MA die der übergebenen Selektion entsprechen
'
'' tbltmp_DP_MA_Grund - Pivotierte Tabelle basierend auf tbltmp_DP_MA_Neu_2
'
'' tbltmp_DP_MA_Grund_FI - Tabelle sortiert nach Datum
'
'
'Set db = CurrentDb
'
'chr34 = Chr$(34)
''Datum füllen
'For i = 0 To 6
'    dt(i) = dtstartdat + i
'    strdtPkt(i) = Format(dt(i), "Short Date")
'    strdtUdl(i) = Replace(strdtPkt(i), ".", "_")
'Next i
'
'strSQL = "SELECT * FROM qry_DP_MA_Neu_1 WHERE (((VADatum) Between " & SQLDatum(dt(0)) & " AND " & SQLDatum(dt(6)) & ") AND ((MA_ID)>0))"
'If Not CreateQuery(strSQL, "qry_DP_MA_Neu_2") Then
'    MsgBox strSQL, vbCritical, "Fehler beim Create der Abfrage 'qry_DP_MA_Neu_2'"
'    Exit Function
'End If
'
'Select Case iNurAktiveMA
'' 0 Alle
'' 1 Nur aktive - IstAktiv = True
'' 2 Nur Feste  - Anstellungsart_ID = 3
'' 3 Minijobber - Anstellungsart_ID = 5
'' 4 Nur Subs   - IstSubunternehmer = True
'
'Case 1
'    strSQLWhere = " WHERE IstAktiv = True"
'Case 2
'    strSQLWhere = " WHERE Anstellungsart_ID = 3"
'Case 3
'    strSQLWhere = " WHERE Anstellungsart_ID = 5"
'Case 4
'    strSQLWhere = " WHERE IstSubunternehmer = True"
'Case Else
'    strSQLWhere = " WHERE 1 = 1"
'
'End Select
'
'' Tabelle tbltmp_DP_MA_Neu_1 leeren und füllen
'CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_Neu_1;")
'CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_Neu_2;")
'
'DoEvents
'
''Neu 1 - Alle MA Füllen
'' Tabelle tbltmp_DP_MA_Neu_1 leeren und füllen
'CurrentDb.Execute ("qry_DP_MA_Neu_2_Import") ' Nur die Selektierten
'DoEvents
'CurrentDb.Execute ("qry_DP_MA_Neu_3_Import") ' Nur die ohne Job
'
''Neu 2 - Selektierte MA Selektion aus Übergabe füllen
'' Tabelle tbltmp_DP_MA_Neu_2 füllen
'strSQL = ""
'strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Neu_2 ( VADatum, MAName, Pos_Nr, ObjOrt, MA_ID, IstAktiv, IstSubunternehmer, Anstellungsart_ID, IstFraglich, ZuordID, VA_ID, VADatum_ID, VAStart_ID, MA_Start, MA_Ende, MVA_Start, Hlp )"
'strSQL = strSQL & " SELECT tbltmp_DP_MA_Neu_1.VADatum, tbltmp_DP_MA_Neu_1.MAName, tbltmp_DP_MA_Neu_1.Pos_Nr, tbltmp_DP_MA_Neu_1.ObjOrt, tbltmp_DP_MA_Neu_1.MA_ID, tbltmp_DP_MA_Neu_1.IstAktiv, tbltmp_DP_MA_Neu_1.IstSubunternehmer,"
'strSQL = strSQL & " tbltmp_DP_MA_Neu_1.Anstellungsart_ID, tbltmp_DP_MA_Neu_1.IstFraglich, tbltmp_DP_MA_Neu_1.ZuordID, tbltmp_DP_MA_Neu_1.VA_ID, tbltmp_DP_MA_Neu_1.VADatum_ID, tbltmp_DP_MA_Neu_1.VAStart_ID, tbltmp_DP_MA_Neu_1.MA_Start,"
'strSQL = strSQL & " tbltmp_DP_MA_Neu_1.MA_Ende , tbltmp_DP_MA_Neu_1.MVA_Start, 1"
'strSQL = strSQL & " FROM tbltmp_DP_MA_Neu_1" & strSQLWhere
'
'CurrentDb.Execute (strSQL)
'
'DoEvents
'
'
'' tbltmp_DP_ZWI11 - Anzahl der MA finden, die pro Tag mehr als einen Einsatz haben.
'' Update des Feldes hlp in der Tabelle tbltmp_DP_MA_Neu_2
'
'If table_exist("tbltmp_DP_ZWI11") Then DoCmd.DeleteObject acTable, "tbltmp_DP_ZWI11"
'
'strSQL = ""
'
'strSQL = strSQL & "SELECT tbltmp_DP_MA_Neu_2.MA_ID, tbltmp_DP_MA_Neu_2.VADatum, Count(tbltmp_DP_MA_Neu_2.MA_ID) AS Anzahl INTO tbltmp_DP_ZWI11"
'strSQL = strSQL & " FROM tbltmp_DP_MA_Neu_2 GROUP BY tbltmp_DP_MA_Neu_2.MA_ID, tbltmp_DP_MA_Neu_2.VADatum HAVING (((Count(tbltmp_DP_MA_Neu_2.MA_ID))>1));"
'CurrentDb.Execute (strSQL)
'
'CurrentDb.Execute ("UPDATE tbltmp_DP_MA_Neu_2 INNER JOIN tbltmp_DP_ZWI11 ON (tbltmp_DP_ZWI11.VADatum = tbltmp_DP_MA_Neu_2.VADatum) AND (tbltmp_DP_MA_Neu_2.MA_ID = tbltmp_DP_ZWI11.MA_ID) SET tbltmp_DP_MA_Neu_2.Hlp = [Anzahl];")
'
'If table_exist("tbltmp_DP_ZWI11") Then DoCmd.DeleteObject acTable, "tbltmp_DP_ZWI11"
'
''In Tabelle tbltmp_DP_MA_Neu_2 die hlp-Werte für Pivottabelle in aufsteigende Reihenfolge bringen (statt 3 3 3  - 1 2 3)
'strSQL = "SELECT tbltmp_DP_MA_Neu_2.MAName, tbltmp_DP_MA_Neu_2.Hlp FROM tbltmp_DP_MA_Neu_2 WHERE (((tbltmp_DP_MA_Neu_2.Hlp) > 1)) ORDER BY tbltmp_DP_MA_Neu_2.MAName, MA_Start, MA_Ende;"
'
'i = rstDcount("*", strSQL)
'If i > 0 Then
'    Set rst = db.OpenRecordset(strSQL)
'    With rst
'        j = .Fields("Hlp")
'        i = 1
'        Do While Not .EOF
'            If i > .Fields("Hlp") Then
'                i = 1
'                j = .Fields("Hlp")
'            End If
'            .Edit
'                .Fields("Hlp") = i
'            .Update
'            i = i + 1
'            .MoveNext
'        Loop
'        .Close
'    End With
'    Set rst = Nothing
'End If
''Kreuztabellen-Pivot-Abfrage erstellen
'
'strSQL = ""
'strSQL = strSQL & "TRANSFORM First(tbltmp_DP_MA_Neu_2.ZuordID) AS ErsterWertvonZuordID"
'strSQL = strSQL & " SELECT tbltmp_DP_MA_Neu_2.MA_ID, tbltmp_DP_MA_Neu_2.MAName, tbltmp_DP_MA_Neu_2.Hlp"
'strSQL = strSQL & " FROM tbltmp_DP_MA_Neu_2 GROUP BY tbltmp_DP_MA_Neu_2.MA_ID, tbltmp_DP_MA_Neu_2.MAName, tbltmp_DP_MA_Neu_2.Hlp"
'strSQL = strSQL & " ORDER BY tbltmp_DP_MA_Neu_2.MAName, tbltmp_DP_MA_Neu_2.Hlp"
'strSQL = strSQL & " PIVOT Format([VADatum],'Short Date')"
'strSQL = strSQL & " IN ('" & strdtPkt(0) & "','" & strdtPkt(1) & "', '" & strdtPkt(2) & "', '" & strdtPkt(3) & "', '" & strdtPkt(4) & "', '" & strdtPkt(5) & "', '" & strdtPkt(6) & "');"
'
''strSQL = Replace(strSQL, "'", chr34)
'If Not CreateQuery(strSQL, "qry_DP_MA_Kreuztabelle") Then
'    MsgBox strSQL, vbCritical, "Fehler beim Create der Abfrage 'qry_DP_MA_Kreuztabelle'"
'    Exit Function
'End If
'
'CurrentDb.Execute ("Delete * FROM tbltmp_DP_MA_Grund;")
'DoEvents
'
'strSQL = ""
'strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Grund SELECT MA_ID, MAName, Hlp,"
'strSQL = strSQL & " [" & strdtUdl(0) & "] AS Tag1_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(1) & "] AS Tag2_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(2) & "] AS Tag3_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(3) & "] AS Tag4_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(4) & "] AS Tag5_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(5) & "] AS Tag6_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(6) & "] AS Tag7_Zuo_ID"
'strSQL = strSQL & " FROM qry_DP_MA_Kreuztabelle ORDER BY MAName, Hlp;"
'CurrentDb.Execute (strSQL)
'DoEvents
'
'CurrentDb.Execute ("UPDATE tbltmp_DP_MA_Grund SET tbltmp_DP_MA_Grund.Startdat = " & SQLDatum(dtstartdat) & ";")
'DoEvents
'
'CurrentDb.Execute ("delete * FROM tbltmp_DP_Grund_Sort_MA")
'DoEvents
'
'CurrentDb.Execute ("qry_DP_Alle_Add_Temp_MA")
'DoEvents
'
'CurrentDb.Execute ("UPDATE tbltmp_DP_Grund_Sort_MA INNER JOIN tbltmp_DP_MA_Grund ON tbltmp_DP_Grund_Sort_MA.MA_ID = tbltmp_DP_MA_Grund.MA_ID SET tbltmp_DP_MA_Grund.IDSort = [tbltmp_DP_Grund_Sort_MA].[ID];")
'DoEvents
'
'CurrentDb.Execute ("delete * FROM tbltmp_DP_MA_Grund_FI")
'DoEvents
'
'CurrentDb.Execute ("qry_DP_MA_Grund_FI_Fill")
'DoEvents
'
'Set DAOARRAY1 = Nothing
'DoEvents
'
'recsetSQL1 = "SELECT * FROM qry_DP_Alle_MA_Zt"
'ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'
'If Not ArrFill_DAO_OK1 Then
'    MsgBox "Probleme beim füllen von qry_DP_Alle_MA_Zt_Fill"
'    Exit Function
'End If
'
''ZuoID = 0
''MA_ID = 1
''Name = 2 ' objOrt
''MA_Start = 3
''MA_Ende = 4
''Istfraglich = 5
''VADatum = 6
'
'Set rst = db.OpenRecordset("SELECT * FROM tbltmp_DP_MA_Grund_FI ORDER BY ID")
'With rst
'    OrtVgl = ""
'    Do While Not .EOF
'        .Edit
'            iMA_ID = .Fields("MA_ID")
'            If OrtVgl = .Fields("MAName") Then
'                .Fields("MAName") = ""
'            Else
'                OrtVgl = .Fields("MAName")
'            End If
'            For i = 1 To 7
'               iZuoID = Nz(.Fields("Tag" & i & "_Zuo_ID"), 0)
'               strvon = ""
'               strbis = ""
'               strMAName = ""
'               bfraglich = 0
'               If iZuoID <> 0 Then
'                    iZl = fSuchZl2(iZuoID, iMA_ID, dt(i - 1))
'                    If ArrFill_DAO_OK1 And iZl <> -1000 Then
'                        ztV = Nz(DAOARRAY1(3, iZl))
'                        If Len(Trim(ztV)) > 0 Then
'                            strvon = Format(ztV, "hh:nn")
'                        End If
'                        ztV = Nz(DAOARRAY1(4, iZl))
'                        If Len(Trim(ztV)) > 0 Then
'                            strbis = Format(ztV, "hh:nn")
'                            End If
'                        iMA_ID = Nz(DAOARRAY1(1, iZl), 0)
'                        strMAName = Nz(DAOARRAY1(2, iZl))
'                        bfraglich = Nz(DAOARRAY1(5, iZl), 0)
'                    End If
'
'                    .Fields("Tag" & i & "_MA_ID") = iMA_ID
'                    .Fields("Tag" & i & "_Name") = strMAName
'                    .Fields("Tag" & i & "_fraglich") = bfraglich
'                    .Fields("Tag" & i & "_von") = strvon
'                    .Fields("Tag" & i & "_bis") = strbis
'
'                 Else
'                    strvon = ""
'                    strbis = ""
'                    iMA_ID = .Fields("MA_ID")
'                    strMAName = ""
'                    bfraglich = 0
'                    .Fields("Tag" & i & "_MA_ID") = iMA_ID
'                    .Fields("Tag" & i & "_Name") = strMAName
'                    .Fields("Tag" & i & "_fraglich") = bfraglich
'                    .Fields("Tag" & i & "_von") = strvon
'                    .Fields("Tag" & i & "_bis") = strbis
'                End If
'            Next i
'
'        .Update
'        .MoveNext
'    Loop
'    .Close
'End With
'Set rst = Nothing
'
'Call Set_Priv_Property("prp_Dienstpl_StartDatum_Vgl", dtstartdat)
'Set DAOARRAY1 = Nothing
'
'End Function


'Function fCreate_DP_MA_tmptable(dtstartdat As Date, iNurAktiveMA As Long)
'Original V60 Version
'
'Dim dt(6) As Date
'Dim strdtPkt(6) As String
'Dim strdtUdl(6) As String
'Dim i As Long, j As Long, k As Long
'Dim strSQL As String
'Dim chr34 As String
'Dim OrtVgl As String
'
'Dim iZuoID As Long
'Dim iMA_ID As Long
'Dim strMAName As String
'Dim bfraglich As Boolean
'Dim strvon As String
'Dim strbis As String
'Dim ztV As Variant
'Dim zt As Date
'
'
'Dim db As DAO.Database
'Dim rst As DAO.Recordset
'Dim Dttmp As Date
'
'Dim strSQLWhere As String
'Dim strSQLOrderBy As String
'
'Set db = CurrentDb
'
'chr34 = Chr$(34)
''Datum füllen
'For i = 0 To 6
'    dt(i) = dtstartdat + i
'    strdtPkt(i) = Format(dt(i), "Short Date")
'    strdtUdl(i) = Replace(strdtPkt(i), ".", "_")
'Next i
'
'' Erzeugen Query "qry_DP_Alle_MA_Zt"
'
'
'strSQL = ""
'strSQL = strSQL & "SELECT qry_DP_Alle.*, 1 AS Hlp FROM qry_DP_Alle WHERE (((qry_DP_Alle.VADatum)"
'strSQL = strSQL & " Between " & SQLDatum(dt(0)) & " AND " & SQLDatum(dt(6)) & ") AND ((qry_DP_Alle.MA_ID)>0))"
'strSQL = strSQL & " ORDER BY qry_DP_Alle.MAName, qry_DP_Alle.VADatum, qry_DP_Alle.MA_Start"
'strSQL = strSQL & " UNION "
'strSQL = strSQL & " SELECT -1 AS VA_ID, -1 AS ZuordID, 1 AS Anz_MA, tbl_MA_Zeittyp.ZeitTyp AS ObjOrt, CDate(Fix(CDbl([vonDat]))) AS VADatum,"
'strSQL = strSQL & " 1 AS Pos_Nr, tbl_MA_NVerfuegZeiten.vonDat AS MA_Start, tbl_MA_NVerfuegZeiten.bisDat AS MA_Ende, tbl_MA_NVerfuegZeiten.MA_ID,"
'strSQL = strSQL & " [Nachname] & ' ' & [Vorname] AS MAName, 0 AS IstFraglich, 1 AS Hlp"
'strSQL = strSQL & " FROM tbl_MA_Zeittyp INNER JOIN (tbl_MA_Mitarbeiterstamm RIGHT JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_NVerfuegZeiten.MA_ID) ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID"
'strSQL = strSQL & " WHERE (((CDate(Fix(CDbl([vonDat])))) Between " & SQLDatum(dt(0)) & " AND " & SQLDatum(dt(6)) & "));"
'If Not CreateQuery(strSQL, "qry_DP_Alle_MA_Zt") Then
'    MsgBox strSQL, vbCritical, "Fehler beim Create der Tabelle 'qry_DP_Alle_MA_Zt'"
'    Exit Function
'End If
'
''In tmp Taberlle speichern um Anzahl Einsätze pro Tag > 1 zu setzen
'CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_1;")
'DoEvents
'CurrentDb.Execute ("qry_DP_MA_1")
'DoEvents
'
'' Wenn MA Name leer, Anzeige der MA_ID
'CurrentDb.Execute ("UPDATE tbltmp_DP_MA_1 SET tbltmp_DP_MA_1.MAName = [MA_ID] WHERE (((Len(Trim(Nz([MAName]))))=0));")
'
'
'recsetSQL1 = "qry_DP_MA_2"
'ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'
''Hlp = Anzahl Jobs pro Tag korrigieren (für Kreuztabelle)
'If ArrFill_DAO_OK1 Then
'    For iZl = 0 To iZLMax1
'        i = 1
'        strSQL = ""
'        strSQL = strSQL & "SELECT tbltmp_DP_MA_1.* FROM tbltmp_DP_MA_1"
'        strSQL = strSQL & " WHERE (((tbltmp_DP_MA_1.MA_ID)=" & CLng(DAOARRAY1(0, iZl)) & " ) AND ((tbltmp_DP_MA_1.VADatum)= " & SQLDatum(DAOARRAY1(1, iZl)) & ")) ORDER BY MA_Start ASC ;"
'        Set rst = db.OpenRecordset(strSQL)
'        With rst
'            Do While Not .EOF
'                .Edit
'                    .Fields("Hlp") = i
'                .Update
'                i = i + 1
'                .MoveNext
'            Loop
'            .Close
'        End With
'        Set rst = Nothing
'    Next iZl
'End If
'DoEvents
'
'' Erzeugen Query "qry_DP_MA_Kreuztabelle"
'strSQL = ""
'
'strSQL = strSQL & "TRANSFORM First(tbltmp_DP_MA_1.ZuordID) AS ErsterWertvonZuordID SELECT tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp"
'strSQL = strSQL & " FROM tbltmp_DP_MA_1 GROUP BY tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp PIVOT Format([VADatum],'Short Date')"
'strSQL = strSQL & " IN ('" & strdtPkt(0) & "','" & strdtPkt(1) & "', '" & strdtPkt(2) & "', '" & strdtPkt(3) & "', '" & strdtPkt(4) & "', '" & strdtPkt(5) & "', '" & strdtPkt(6) & "');"
'
''strSQL = Replace(strSQL, "'", chr34)
'If Not CreateQuery(strSQL, "qry_DP_MA_Kreuztabelle") Then
'    MsgBox strSQL, vbCritical, "Fehler beim Create der Tabelle 'qry_DP_MA_Kreuztabelle'"
'    Exit Function
'End If
'
'CurrentDb.Execute ("Delete * FROM tbltmp_DP_MA_Grund;")
'DoEvents
'
'strSQL = ""
'strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Grund SELECT MA_ID, MAName, Hlp,"
'strSQL = strSQL & " [" & strdtUdl(0) & "] AS Tag1_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(1) & "] AS Tag2_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(2) & "] AS Tag3_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(3) & "] AS Tag4_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(4) & "] AS Tag5_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(5) & "] AS Tag6_Zuo_ID,"
'strSQL = strSQL & " [" & strdtUdl(6) & "] AS Tag7_Zuo_ID"
'strSQL = strSQL & " FROM qry_DP_MA_Kreuztabelle ORDER BY MAName, Hlp;"
'CurrentDb.Execute (strSQL)
'DoEvents
'
'CurrentDb.Execute ("UPDATE tbltmp_DP_MA_Grund SET tbltmp_DP_MA_Grund.Startdat = " & SQLDatum(dtstartdat) & ";")
'DoEvents
'
'recsetSQL1 = "qry_DP_Alle_MA_Zt_Fill"
'ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'
'If Not ArrFill_DAO_OK1 Then
''    MsgBox "Probleme beim füllen von qry_DP_Alle_MA_Zt_Fill"
''    Exit Function
'End If
'
''ZuoID = 0
''MA_ID = 1
''Name = 2
''MA_Start = 3
''MA_Ende = 4
''Istfraglich = 5
'
'Set rst = db.OpenRecordset("SELECT * FROM tbltmp_DP_MA_Grund ORDER BY ID")
'With rst
'    OrtVgl = ""
'    Do While Not .EOF
'        .Edit
''            If OrtVgl = .Fields("MAName") Then
''                .Fields("MAName") = ""
''            Else
''                OrtVgl = .Fields("MAName")
''            End If
'            For i = 1 To 7
'               iZuoID = Nz(.Fields("Tag" & i & "_Zuo_ID"), 0)
'               strvon = ""
'               strbis = ""
'               iMA_ID = 0
'               strMAName = ""
'               bfraglich = 0
'               If iZuoID > 0 Then
'                    iZl = fSuchZl(iZuoID)
'                    If ArrFill_DAO_OK1 Then
'                        ztV = Nz(DAOARRAY1(3, iZl))
'                        If Len(Trim(ztV)) > 0 Then
'                            strvon = Format(ztV, "hh:nn")
'                        End If
'                        ztV = Nz(DAOARRAY1(4, iZl))
'                        If Len(Trim(ztV)) > 0 Then
'                            strbis = Format(ztV, "hh:nn")
'                            End If
'                        iMA_ID = Nz(DAOARRAY1(2, iZl), 0)
'                        strMAName = Nz(DAOARRAY1(1, iZl))
'                        bfraglich = Nz(DAOARRAY1(5, iZl), 0)
'                    End If
'
'                    .Fields("Tag" & i & "_MA_ID") = iMA_ID
'                    .Fields("Tag" & i & "_Name") = strMAName
'                    .Fields("Tag" & i & "_fraglich") = bfraglich
'                    .Fields("Tag" & i & "_von") = strvon
'                    .Fields("Tag" & i & "_bis") = strbis
'
'                ElseIf iZuoID < 0 Then
'                    strvon = ""
'                    strbis = ""
'                    iMA_ID = .Fields("MA_ID")
'                    Dttmp = dt(i - 1)
'                    strMAName = ""
'                    bfraglich = 0
'                    If ArrFill_DAO_OK1 Then
'                        ztV = Nz(DAOARRAY1(3, iZl))
'                        If Len(Trim(ztV)) > 0 Then
'                            strvon = Format(ztV, "hh:nn")
'                        End If
'                        If IsNull(DAOARRAY1(3, iZl)) Then
'                            strvon = ""
'                        End If
'                        ztV = Nz(DAOARRAY1(4, iZl))
'                        If Len(Trim(ztV)) > 0 Then
'                            strbis = Format(ztV, "hh:nn")
'                        End If
'                        If IsNull(DAOARRAY1(4, iZl)) Then
'                            strbis = ""
'                        End If
'                    End If
'                    strMAName = Nz(TLookup("ObjOrt", "tbltmp_DP_MA_1", "ZuordID = -1 AND Vadatum = " & SQLDatum(Dttmp) & " AND MA_ID = " & iMA_ID))
'                    .Fields("Tag" & i & "_MA_ID") = iMA_ID
'                    .Fields("Tag" & i & "_Name") = strMAName
'                    .Fields("Tag" & i & "_fraglich") = bfraglich
'                    .Fields("Tag" & i & "_von") = strvon
'                    .Fields("Tag" & i & "_bis") = strbis
'                End If
'            Next i
'
'        .Update
'        .MoveNext
'    Loop
'    .Close
'End With
'Set rst = Nothing
'Set DAOARRAY1 = Nothing
'
'Select Case iNurAktiveMA
'    Case 1 ' Nur Aktive
'        strSQLWhere = " AND IstAktiv = True "
'    Case 2 ' Nur Festangestellte  'Anstellungsart 3
'        strSQLWhere = " AND Anstellungsart_ID = 3 "
'    Case 3 ' Nur Minijobber  ' Anstellungsart 5
'        strSQLWhere = " AND Anstellungsart_ID = 5 "
'    Case 4 ' Nur Unternehmer  ' IstSubunternehmer = True
'        strSQLWhere = " AND IstSubunternehmer = True "
'    Case Else ' Alle
'        strSQLWhere = ""
'
'End Select
'strSQLOrderBy = " ORDER BY Nachname, Vorname"
'
'strSQL = ""
'strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Grund ( MA_ID, MAName, Startdat, Hlp )"
'strSQL = strSQL & " SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & ' ' & [Vorname] AS NName, " & SQLDatum(dtstartdat) & " AS Ausdr1, 1 AS Ausdr2"
'strSQL = strSQL & " FROM tbl_MA_Mitarbeiterstamm WHERE (((tbl_MA_Mitarbeiterstamm.ID) Not In (Select Distinct MA_ID FROM tbltmp_DP_MA_1))"
'strSQL = strSQL & strSQLWhere & ")" & strSQLOrderBy
'CurrentDb.Execute (strSQL)
'
'DoEvents
'CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_Grund_FI;")
'DoEvents
'
'strSQLOrderBy = " ORDER BY MAName"
'
'strSQL = ""
'strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Grund_FI ( Startdat, MA_ID, MAName, Hlp, Tag1_Zuo_ID, Tag1_MA_ID, Tag1_Name, Tag1_fraglich, Tag1_von, Tag1_bis,"
'strSQL = strSQL & " Tag2_Zuo_ID, Tag2_MA_ID, Tag2_Name, Tag2_fraglich, Tag2_von, Tag2_bis, Tag3_Zuo_ID, Tag3_MA_ID, Tag3_Name, Tag3_fraglich, Tag3_von, Tag3_bis,"
'strSQL = strSQL & " Tag4_Zuo_ID, Tag4_MA_ID, Tag4_Name, Tag4_fraglich, Tag4_von, Tag4_bis, Tag5_Zuo_ID, Tag5_MA_ID, Tag5_Name, Tag5_fraglich, Tag5_von,"
'strSQL = strSQL & " Tag5_bis, Tag6_Zuo_ID, Tag6_MA_ID, Tag6_Name, Tag6_fraglich, Tag6_von, Tag6_bis, Tag7_Zuo_ID, Tag7_MA_ID, Tag7_Name, Tag7_fraglich, Tag7_von, Tag7_bis )"
'strSQL = strSQL & " SELECT Startdat, MA_ID, MAName, Hlp, Tag1_Zuo_ID, Tag1_MA_ID, Tag1_Name, Tag1_fraglich, Tag1_von, Tag1_bis, Tag2_Zuo_ID, Tag2_MA_ID,"
'strSQL = strSQL & " Tag2_Name, Tag2_fraglich, Tag2_von, Tag2_bis, Tag3_Zuo_ID, Tag3_MA_ID, Tag3_Name, Tag3_fraglich, Tag3_von, Tag3_bis, Tag4_Zuo_ID,"
'strSQL = strSQL & " Tag4_MA_ID, Tag4_Name, Tag4_fraglich, Tag4_von, Tag4_bis, Tag5_Zuo_ID, Tag5_MA_ID, Tag5_Name, Tag5_fraglich, Tag5_von, Tag5_bis,"
'strSQL = strSQL & " Tag6_Zuo_ID , Tag6_MA_ID, Tag6_Name, Tag6_fraglich, Tag6_von, Tag6_bis, Tag7_Zuo_ID, Tag7_MA_ID, Tag7_Name, Tag7_fraglich, Tag7_von, Tag7_bis"
'strSQL = strSQL & " FROM qry_DP_Temp_Imp_MA WHERE (1 = 1"
'strSQL = strSQL & strSQLWhere & ")" & strSQLOrderBy
'CurrentDb.Execute (strSQL)
'
'DoEvents
'
'Set rst = db.OpenRecordset("SELECT * FROM tbltmp_DP_MA_Grund_FI ORDER BY ID")
'With rst
'    OrtVgl = ""
'    Do While Not .EOF
'        .Edit
'            If OrtVgl = .Fields("MAName") Then
'                .Fields("MAName") = ""
'            Else
'                OrtVgl = .Fields("MAName")
'            End If
'        .Update
'        .MoveNext
'    Loop
'    .Close
'End With
'Set rst = Nothing
'
'DoEvents
'
''CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_Grund;")
'
'DoEvents
'
'
'Call Set_Priv_Property("prp_Dienstpl_StartDatum_Vgl", dtstartdat)
'End Function

'

Function ftstxx()
    Call fCreate_DP_MA_tmptable(DateSerial(2015, 11, 23), 2)
    
End Function


'Function fSuchZl2(i As Long, iMA_ID As Long, dt As Date) As Long
'fSuchZl2 = -1000
''ZuoID = 0
''MA_ID = 1
''Name = 2 ' objOrt
''MA_Start = 3
''MA_Ende = 4
''Istfraglich = 5
''VADatum = 6
'
'For iZl = 0 To iZLMax1
'    If DAOARRAY1(0, iZl) = i And DAOARRAY1(1, iZl) = iMA_ID And CDate(DAOARRAY1(6, iZl)) = dt Then
'        fSuchZl2 = iZl
'        Exit For
'    End If
'Next iZl
'End Function


Function fCreate_DP_MA_tmptable(dtstartdat As Date, iNurAktiveMA As Long)

Dim dt(6) As Date
Dim strdtPkt(6) As String
Dim strdtUdl(6) As String
Dim i As Long, j As Long, k As Long
Dim c As Integer
Dim strSQL As String
Dim chr34 As String
Dim OrtVgl As String

Dim iZuoID As Long
Dim iMA_ID As Long
Dim strMAName As String
Dim bfraglich As Boolean
Dim strvon As String
Dim strbis As String
Dim ztV As Variant
Dim zt As Date


Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim Dttmp As Date

Dim strSQLWhere As String
Dim strSQLOrderBy As String

Set db = CurrentDb

chr34 = Chr$(34)
'Datum füllen
For i = 0 To 6
    dt(i) = dtstartdat + i
    strdtPkt(i) = Format(dt(i), "Short Date")
    strdtUdl(i) = Replace(strdtPkt(i), ".", "_")
Next i

' Erzeugen Query "qry_DP_Alle_MA_Zt"


strSQL = ""
strSQL = strSQL & "SELECT qry_DP_Alle.*, 1 AS Hlp FROM qry_DP_Alle WHERE (((qry_DP_Alle.VADatum)"
strSQL = strSQL & " Between " & SQLDatum(dt(0)) & " AND " & SQLDatum(dt(6)) & ") AND ((qry_DP_Alle.MA_ID)>0))"
strSQL = strSQL & " ORDER BY qry_DP_Alle.MAName, qry_DP_Alle.VADatum, qry_DP_Alle.MA_Start, qry_DP_Alle.MA_Ende"
strSQL = strSQL & " UNION "
strSQL = strSQL & " SELECT -1 AS VA_ID,  (([tbl_MA_Zeittyp].ID) * -1) AS ZuordID, 1 AS Anz_MA, tbl_MA_Zeittyp.ZeitTyp AS ObjOrt, CDate(Fix(CDbl([vonDat]))) AS VADatum,"
strSQL = strSQL & " 1 AS Pos_Nr, Format(tbl_MA_NVerfuegZeiten.vonDat, 'hh:nn',2) AS MA_Start, Format(tbl_MA_NVerfuegZeiten.bisDat, 'hh:nn', 2) AS MA_Ende, tbl_MA_NVerfuegZeiten.MA_ID,"
strSQL = strSQL & " [Nachname] & ' ' & [Vorname] AS MAName, 0 AS IstFraglich, 1 AS Hlp"
strSQL = strSQL & " FROM tbl_MA_Zeittyp INNER JOIN (tbl_MA_Mitarbeiterstamm RIGHT JOIN tbl_MA_NVerfuegZeiten ON tbl_MA_Mitarbeiterstamm.ID = tbl_MA_NVerfuegZeiten.MA_ID) ON tbl_MA_Zeittyp.Kuerzel_Datev = tbl_MA_NVerfuegZeiten.Zeittyp_ID"
strSQL = strSQL & " WHERE (((CDate(Fix(CDbl([vonDat])))) Between " & SQLDatum(dt(0)) & " AND " & SQLDatum(dt(6)) & "));"
If Not CreateQuery(strSQL, "qry_DP_Alle_MA_Zt") Then
    MsgBox strSQL, vbCritical, "Fehler beim Create der Tabelle 'qry_DP_Alle_MA_Zt'"
    Exit Function
End If

'In tmp Taberlle speichern um Anzahl Einsätze pro Tag > 1 zu setzen
CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_1;")
DoEvents
CurrentDb.Execute ("qry_DP_MA_1")
DoEvents

' Wenn MA Name leer, Anzeige der MA_ID
CurrentDb.Execute ("UPDATE tbltmp_DP_MA_1 SET tbltmp_DP_MA_1.MAName = [MA_ID] WHERE (((Len(Trim(Nz([MAName]))))=0));")


recsetSQL1 = "qry_DP_MA_2"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

'Hlp = Anzahl Jobs pro Tag korrigieren (für Kreuztabelle)
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        i = 1
        strSQL = ""
        strSQL = strSQL & "SELECT tbltmp_DP_MA_1.* FROM tbltmp_DP_MA_1"
        strSQL = strSQL & " WHERE (((tbltmp_DP_MA_1.MA_ID)=" & CLng(DAOARRAY1(0, iZl)) & " ) AND ((tbltmp_DP_MA_1.VADatum)= " & SQLDatum(DAOARRAY1(1, iZl)) & ")) ORDER BY MA_Start ASC, MA_Ende ASC;"
        Set rst = db.OpenRecordset(strSQL)
        With rst
            Do While Not .EOF
                .Edit
                    .fields("Hlp") = i
                .update
                i = i + 1
                .MoveNext
            Loop
            .Close
        End With
        Set rst = Nothing
    Next iZl
End If
DoEvents

' Erzeugen Query "qry_DP_MA_Kreuztabelle"
strSQL = ""

strSQL = strSQL & "TRANSFORM First(tbltmp_DP_MA_1.ZuordID) AS ErsterWertvonZuordID SELECT tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp"
strSQL = strSQL & " FROM tbltmp_DP_MA_1 GROUP BY tbltmp_DP_MA_1.MAName, tbltmp_DP_MA_1.MA_ID, tbltmp_DP_MA_1.Hlp ORDER BY tbltmp_DP_MA_1.Hlp PIVOT Format([VADatum],'Short Date')"
strSQL = strSQL & " IN ('" & strdtPkt(0) & "','" & strdtPkt(1) & "', '" & strdtPkt(2) & "', '" & strdtPkt(3) & "', '" & strdtPkt(4) & "', '" & strdtPkt(5) & "', '" & strdtPkt(6) & "');"

'strSQL = Replace(strSQL, "'", chr34)
If Not CreateQuery(strSQL, "qry_DP_MA_Kreuztabelle") Then
    MsgBox strSQL, vbCritical, "Fehler beim Create der Tabelle 'qry_DP_MA_Kreuztabelle'"
    Exit Function
End If

CurrentDb.Execute ("Delete * FROM tbltmp_DP_MA_Grund;")
DoEvents

strSQL = ""
strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Grund SELECT MA_ID, MAName, Hlp,"
strSQL = strSQL & " [" & strdtUdl(0) & "] AS Tag1_Zuo_ID,"
strSQL = strSQL & " [" & strdtUdl(1) & "] AS Tag2_Zuo_ID,"
strSQL = strSQL & " [" & strdtUdl(2) & "] AS Tag3_Zuo_ID,"
strSQL = strSQL & " [" & strdtUdl(3) & "] AS Tag4_Zuo_ID,"
strSQL = strSQL & " [" & strdtUdl(4) & "] AS Tag5_Zuo_ID,"
strSQL = strSQL & " [" & strdtUdl(5) & "] AS Tag6_Zuo_ID,"
strSQL = strSQL & " [" & strdtUdl(6) & "] AS Tag7_Zuo_ID"
strSQL = strSQL & " FROM qry_DP_MA_Kreuztabelle ORDER BY MAName, Hlp;"
CurrentDb.Execute (strSQL)
DoEvents

CurrentDb.Execute ("UPDATE tbltmp_DP_MA_Grund SET tbltmp_DP_MA_Grund.Startdat = " & SQLDatum(dtstartdat) & ";")
DoEvents

'recsetSQL1 = "qry_DP_Alle_MA_Zt_Fill"
recsetSQL1 = "SELECT ZuordID, MA_ID, ObjOrt, MA_Start, MA_Ende, IstFraglich, VADatum FROM tbltmp_DP_MA_1 ORDER BY ZuordID"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

If Not ArrFill_DAO_OK1 Then
'    MsgBox "Probleme beim füllen von qry_DP_Alle_MA_Zt_Fill"
'    Exit Function
End If

'ZuoID = 0
'MA_ID = 1
'Name = 2
'MA_Start = 3
'MA_Ende = 4
'Istfraglich = 5
'VADAtum = 6

Set rst = db.OpenRecordset("SELECT * FROM tbltmp_DP_MA_Grund ORDER BY ID")
With rst
    OrtVgl = ""
    Do While Not .EOF
        .Edit
'            If OrtVgl = .Fields("MAName") Then
'                .Fields("MAName") = ""
'            Else
'                OrtVgl = .Fields("MAName")
'            End If
            For i = 1 To 7
               iZuoID = Nz(.fields("Tag" & i & "_Zuo_ID"), 0)
               strvon = ""
               strbis = ""
               iMA_ID = Nz(.fields("MA_ID"), 0)
               strMAName = ""
               bfraglich = 0
               If iZuoID <> 0 Then
                    iZl = fSuchZl2(iZuoID, iMA_ID, dt(i - 1))
                    If ArrFill_DAO_OK1 Then
                        ztV = Nz(DAOARRAY1(3, iZl))
                        If Len(Trim(ztV)) > 0 Then
                            strvon = Format(ztV, "hh:nn")
                        End If
                        ztV = Nz(DAOARRAY1(4, iZl))
                        If Len(Trim(ztV)) > 0 Then
                            strbis = Format(ztV, "hh:nn")
                            End If
'                        iMA_ID = Nz(DAOARRAY1(1, iZl), 0)
                        strMAName = Nz(DAOARRAY1(2, iZl))
                        bfraglich = Nz(DAOARRAY1(5, iZl), 0)
                    End If
                    
                    .fields("Tag" & i & "_MA_ID") = iMA_ID
                    .fields("Tag" & i & "_Name") = strMAName
                    .fields("Tag" & i & "_fraglich") = bfraglich
                    .fields("Tag" & i & "_von") = strvon
                    .fields("Tag" & i & "_bis") = strbis
                    
                Else
                    strvon = ""
                    strbis = ""
                    strMAName = ""
                    bfraglich = 0
                    .fields("Tag" & i & "_MA_ID") = iMA_ID
                    .fields("Tag" & i & "_Name") = strMAName
                    .fields("Tag" & i & "_fraglich") = bfraglich
                    .fields("Tag" & i & "_von") = strvon
                    .fields("Tag" & i & "_bis") = strbis
                End If
            Next i
    
        .update
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing
Set DAOARRAY1 = Nothing

Select Case iNurAktiveMA
    Case 1 ' Nur Aktive
        strSQLWhere = " AND Anstellungsart_ID = 3 or Anstellungsart_ID = 5  "
    Case 2 ' Nur Festangestellte  'Anstellungsart 3
        strSQLWhere = " AND Anstellungsart_ID = 3 "
    Case 3 ' Nur Minijobber  ' Anstellungsart 5
        strSQLWhere = " AND Anstellungsart_ID = 5 "
    Case 4 ' Nur Unternehmer  ' IstSubunternehmer = True
        strSQLWhere = " AND IstSubunternehmer = True "
    Case Else ' Alle
        strSQLWhere = " AND Anstellungsart_ID = 3 or Anstellungsart_ID = 5 or Anstellungsart_ID = 11   "

End Select
strSQLOrderBy = " ORDER BY Nachname, Vorname"

strSQL = ""
strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Grund ( MA_ID, MAName, Startdat, Hlp )"
strSQL = strSQL & " SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & ' ' & [Vorname] AS NName, " & SQLDatum(dtstartdat) & " AS Ausdr1, 1 AS Ausdr2"
strSQL = strSQL & " FROM tbl_MA_Mitarbeiterstamm WHERE (((tbl_MA_Mitarbeiterstamm.ID) Not In (Select Distinct MA_ID FROM tbltmp_DP_MA_1))"
strSQL = strSQL & strSQLWhere & ")" & strSQLOrderBy
CurrentDb.Execute (strSQL)

DoEvents
CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_Grund_FI;")
DoEvents

strSQLOrderBy = " ORDER BY MAName, hlp"

strSQL = ""
strSQL = strSQL & "INSERT INTO tbltmp_DP_MA_Grund_FI ( Startdat, MA_ID, MAName, Hlp, Tag1_Zuo_ID, Tag1_MA_ID, Tag1_Name, Tag1_fraglich, Tag1_von, Tag1_bis,"
strSQL = strSQL & " Tag2_Zuo_ID, Tag2_MA_ID, Tag2_Name, Tag2_fraglich, Tag2_von, Tag2_bis, Tag3_Zuo_ID, Tag3_MA_ID, Tag3_Name, Tag3_fraglich, Tag3_von, Tag3_bis,"
strSQL = strSQL & " Tag4_Zuo_ID, Tag4_MA_ID, Tag4_Name, Tag4_fraglich, Tag4_von, Tag4_bis, Tag5_Zuo_ID, Tag5_MA_ID, Tag5_Name, Tag5_fraglich, Tag5_von,"
strSQL = strSQL & " Tag5_bis, Tag6_Zuo_ID, Tag6_MA_ID, Tag6_Name, Tag6_fraglich, Tag6_von, Tag6_bis, Tag7_Zuo_ID, Tag7_MA_ID, Tag7_Name, Tag7_fraglich, Tag7_von, Tag7_bis )"
strSQL = strSQL & " SELECT Startdat, MA_ID, MAName, Hlp, Tag1_Zuo_ID, Tag1_MA_ID, Tag1_Name, Tag1_fraglich, Tag1_von, Tag1_bis, Tag2_Zuo_ID, Tag2_MA_ID,"
strSQL = strSQL & " Tag2_Name, Tag2_fraglich, Tag2_von, Tag2_bis, Tag3_Zuo_ID, Tag3_MA_ID, Tag3_Name, Tag3_fraglich, Tag3_von, Tag3_bis, Tag4_Zuo_ID,"
strSQL = strSQL & " Tag4_MA_ID, Tag4_Name, Tag4_fraglich, Tag4_von, Tag4_bis, Tag5_Zuo_ID, Tag5_MA_ID, Tag5_Name, Tag5_fraglich, Tag5_von, Tag5_bis,"
strSQL = strSQL & " Tag6_Zuo_ID , Tag6_MA_ID, Tag6_Name, Tag6_fraglich, Tag6_von, Tag6_bis, Tag7_Zuo_ID, Tag7_MA_ID, Tag7_Name, Tag7_fraglich, Tag7_von, Tag7_bis"
strSQL = strSQL & " FROM qry_DP_Temp_Imp_MA WHERE (1 = 1"
strSQL = strSQL & strSQLWhere & ")" & strSQLOrderBy
CurrentDb.Execute (strSQL)

DoEvents

Set rst = db.OpenRecordset("SELECT * FROM tbltmp_DP_MA_Grund_FI ORDER BY ID")
With rst
    OrtVgl = ""
    Do While Not .EOF
        .Edit
            If OrtVgl = .fields("MAName") Then
                .fields("MAName") = ""
            Else
                OrtVgl = .fields("MAName")
            End If
            'Stunden berechnen
            For c = 1 To 7
                If .fields("Tag" & c & "_von") <> "" And .fields("Tag" & c & "_bis") <> "" And .fields("Tag" & c & "_Zuo_ID") > 0 Then _
                    .fields("Stunden_gesamt") = .fields("Stunden_gesamt") + stunden(.fields("Tag" & c & "_von"), .fields("Tag" & c & "_bis"))
            Next c
        .update
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing

DoEvents

'CurrentDb.Execute ("DELETE * FROM tbltmp_DP_MA_Grund;")

DoEvents


Call Set_Priv_Property("prp_Dienstpl_StartDatum_Vgl", dtstartdat)
End Function


