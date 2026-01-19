Option Compare Database
Option Explicit


Function f_VAdat_Pl(iVADatum_ID As Long) As Date
f_VAdat_Pl = TLookup("VADatum", "tbl_VA_AnzTage", "ID = " & iVADatum_ID)
End Function


'Summe Stunden Consys für Abgleich in zfrm_MA_Stunden_Lexware
Public Function fSumme_Std_Consys(MA_ID As Integer, jahr As Integer, Monat As Integer) As Double
On Error Resume Next
  fSumme_Std_Consys = Forms("zfrm_MA_Stunden_Lexware").fSumme_stunden_consys(MA_ID, jahr, Monat)
End Function

'Summe Stunden ZK abgerechnet für Abgleich in zfrm_MA_Stunden_Lexware
Public Function fSumme_Std_abger(PersNr As Integer, jahr As Integer, Monat As Integer) As Double
On Error Resume Next
  fSumme_Std_abger = Forms("zfrm_MA_Stunden_Lexware").fSumme_Stunden_abger(PersNr, jahr, Monat)
End Function

'Summe Stunden ZK Zeitkonto für Abgleich in zfrm_MA_Stunden_Lexware
Public Function fSumme_Std_ges(PersNr As Integer, jahr As Integer, Monat As Integer) As Double
On Error Resume Next
  fSumme_Std_ges = Forms("zfrm_MA_Stunden_Lexware").fSumme_Stunden_ges(PersNr, jahr, Monat)
End Function

'Summe Stunden ZK Lexware für Abgleich in zfrm_MA_Stunden_Lexware
Public Function fZKausgezahlt(PersNr As Integer, jahr As Integer, Monat As Integer) As Double
On Error Resume Next
  fZKausgezahlt = Forms("zfrm_MA_Stunden_Lexware").fZKausgezahlt(PersNr, jahr, Monat)
End Function

Function fStundenberech(iVA_ID As Long)
On Error Resume Next

CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MVA_Start = Startzeit_G([VADatum],[MA_Start]) WHERE (((tbl_MA_VA_Zuordnung.VA_ID)=" & iVA_ID & "));")
DoEvents
CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MVA_Ende = Endezeit_G([VADatum],[MA_Start],[MA_Ende]) WHERE (((tbl_MA_VA_Zuordnung.VA_ID)=" & iVA_ID & "));")
DoEvents
CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_Brutto_Std = timeberech_G([VADatum],[MA_Start],[MA_Ende]) WHERE (((tbl_MA_VA_Zuordnung.VA_ID)=" & iVA_ID & "));")
DoEvents
CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_Netto_Std = Netto_Std_Berech([MA_Brutto_Std]) WHERE (((tbl_MA_VA_Zuordnung.VA_ID)=" & iVA_ID & "));")
DoEvents
CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.RL34a = RL34a_pro_Std([MA_ID]) WHERE (((tbl_MA_VA_Zuordnung.VA_ID)=" & iVA_ID & "));")

fStundenberech = -1

End Function


'Stundenberechnung Bruttostunden Nettostunden
Function zfStundenberech(iVA_ID As Long)

On Error GoTo err

    CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MVA_Start = Startzeit_G([VADatum],[MA_Start]) WHERE (((tbl_MA_VA_Zuordnung.VA_ID)=" & iVA_ID & "));")
    DoEvents
    CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MVA_Ende = Endezeit_G([VADatum],[MA_Start],[MA_Ende]) WHERE (((tbl_MA_VA_Zuordnung.VA_ID)=" & iVA_ID & "));")
    
    zfStundenberech = 1

Ende:
    Exit Function
err:
    Debug.Print err.Number & " " & err.description
    Resume Next
    
End Function



Function fExcel_qry_export(qry_XL As String)

Dim frm As Form

DoCmd.OpenForm "_frmHlp_Excel_Einbinden"
Set frm = Forms("_frmHlp_Excel_Einbinden")
frm.WahlLinkImport = 1  ' Export = 1  ' Link = 2, Import = 0
frm.WahlLI
DoEvents
frm.Tabellenname = qry_XL
DoEvents
frm.IstMitHeader = True

End Function

Function fNeu_Pos()

Dim iKID As Long
Dim strSQL As String

Dim PosNr As Long
Dim iAnz As Long
Dim iOB_Kopf As Long
Dim iOB_Pos As Long
Dim i As Long

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "qry_VA_Akt_Objekt_Pos_Ohne"

iKID = Get_Priv_Property("prp_VA_Akt_Objekt_ID")

CurrentDb.Execute ("qry_VA_Akt_MA_Pos_del")
DoEvents

PosNr = 1

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT Top 1 * FROM tbl_VA_Akt_Objekt_Pos_MA;")

With rst

ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        iAnz = DAOARRAY1(2, iZl)
        iOB_Kopf = DAOARRAY1(0, iZl)
        iOB_Pos = DAOARRAY1(1, iZl)
        For i = 1 To iAnz
            .AddNew
                .fields("VA_Akt_Objekt_Kopf_ID").Value = iOB_Kopf
                .fields("VA_Akt_Objekt_Pos_ID").Value = iOB_Pos
                .fields("PosNr").Value = PosNr
                .fields("MA_ID").Value = 0
                .fields("Bemerkung").Value = ""
            .update
            
            PosNr = PosNr + 1
        Next i

    Next iZl
    Set DAOARRAY1 = Nothing
End If

.Close
End With
Set rst = Nothing

End Function
Function fUE_DblClick(iVA_ID As Long, iVADatum_ID As Long)

Dim strSQL2 As String
Dim dtsich As Date
Dim stdat As Date

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

strSQL2 = ""
strSQL2 = strSQL2 & "SELECT tbl_MA_VA_Zuordnung.ID, tbl_MA_VA_Zuordnung.VA_ID, Nz(tbl_MA_VA_Zuordnung.MA_ID,0) AS Ausdr1, tbl_MA_VA_Zuordnung.PosNr,"
strSQL2 = strSQL2 & " [Nachname] & ', ' & [Vorname] AS Mitarbeiter, Left(Nz([VA_Start]),5) AS Start"
strSQL2 = strSQL2 & " FROM tbl_VA_Start RIGHT JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm"
strSQL2 = strSQL2 & " ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID) ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID"
strSQL2 = strSQL2 & " WHERE (tbl_MA_VA_Zuordnung.VA_ID= " & iVA_ID & ") AND ((tbl_MA_VA_Zuordnung.VADatum_ID) = " & iVADatum_ID & ") Order By PosNr;"

'DoCmd.OpenForm "frm_VA_Auftragstamm", , , "ID = " & iVA_ID
DoCmd.OpenForm "frmTop_VA_Tag_sub"
Forms!frmTop_VA_Tag_sub!dtDatum = stdat
Forms!frmTop_VA_Tag_sub!VA_ID = iVA_ID
Forms!frmTop_VA_Tag_sub!lst_Ist.RowSource = strSQL2
Forms!frmTop_VA_Tag_sub!lst_Ist.Requery
Forms!frmTop_VA_Tag_sub.Requery


End Function


Function fEzPreis(i As Long) As Single
Select Case i
    Case 4
        fEzPreis = Get_Priv_Property("EZ_Preisart_4")
    Case 3
        fEzPreis = Get_Priv_Property("EZ_Preisart_3")
    Case Else
        fEzPreis = Get_Priv_Property("EZ_Preisart_1")
End Select
End Function

Function fTag_Schicht_Update_Tag(iVADatum_ID As Long, iVA_ID As Long)
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "SELECT tbl_VA_Start.ID FROM tbl_VA_Start where tbl_VA_Start.VA_ID = " & iVA_ID & " AND tbl_VA_Start.VADatum_ID = " & iVADatum_ID & " ORDER BY VA_Start, VA_Ende;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        fTag_Schicht_Update iVADatum_ID, CLng(DAOARRAY1(0, iZl))
    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function


Function fTag_Schicht_Update(iVADatum_ID As Long, iVAStart_ID As Long)
Dim i As Long, j As Long, bt As Long, k As Long

Dim iVA_ID As Long
Dim cdat As Date


i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID > 0 AND VADatum_ID = " & iVADatum_ID), 0)
j = Nz(TSum("MA_Anzahl", "tbl_VA_Start", "VADatum_ID = " & iVADatum_ID), 0)
bt = Not (i >= j And j > 0)
CurrentDb.Execute ("UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Ist = " & i & ", tbl_VA_AnzTage.TVA_Soll = " & j & ", TVA_Offen = " & CLng(bt) & " WHERE (((tbl_VA_AnzTage.ID)= " & iVADatum_ID & "));")

i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID > 0 AND VAStart_ID = " & iVAStart_ID), 0)
CurrentDb.Execute ("UPDATE tbl_VA_Start SET tbl_VA_Start.MA_Anzahl_Ist = " & i & " WHERE (((tbl_VA_Start.ID)= " & iVAStart_ID & "));")

iVA_ID = Nz(TLookup("VA_ID", "tbl_VA_AnzTage", "ID = " & iVADatum_ID), 0)
k = Nz(TLookup("Veranst_Status_ID", "tbl_VA_Auftragstamm", "ID = " & iVA_ID), 0)
If k < 3 Then
    i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID > 0 AND VA_ID = " & iVA_ID), 0)
    j = Nz(TSum("TVA_Soll", "tbl_VA_AnzTage", "VA_ID = " & iVA_ID), 0)
    If i >= j And j > 0 Then
        CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Veranst_Status_ID = 2 WHERE (((tbl_VA_Auftragstamm.ID)= " & iVA_ID & "));")
        'CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Veranst_Status_ID = 2 WHERE (((tbl_VA_Auftragstamm.id)= " & iVA_ID & ") and (tbl_va_auftragstamm.dat_va_bis) > cdate);")
    Else
        CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Veranst_Status_ID = 1 WHERE (((tbl_VA_Auftragstamm.ID)= " & iVA_ID & "));")
    End If
End If

End Function


'läuft schneller als ursprüngliche Funktion...
Function zfCreateQuery_Verplant(ByVal vglstart As Date, ByVal vglende As Date)

Dim strSQL As String

'Start und Ende der Verfügbarkreitsprüfung startet / endet zwei Minuten nach / vor dem eigentlichen Start / Ende um Überschneidungen sicher zu vermeiden
'vglstart = DateAdd("n", 2, vglstart) 'Start
'vglende = DateAdd("n", -2, vglende)  'Ende
vglstart = DateAdd("n", -2, vglstart) 'Start
vglende = DateAdd("n", 2, vglende)  'Ende

strSQL = ""
'strsql = strsql & "Select [MA_ID], [VADatum], [MVA_Start], [MVA_Ende], [Art] FROM zqry_VV_Union WHERE ("
'strsql = strsql & " ([MVA_Start] between " & DateTimeForSQL(vglstart) & " and " & DateTimeForSQL(vglende) & ")  OR"
'strsql = strsql & " ([MVA_Ende] between " & DateTimeForSQL(vglstart) & " and " & DateTimeForSQL(vglende) & ")  OR"
'strsql = strsql & " (([MVA_Start]< " & DateTimeForSQL(vglstart) & ") AND ([MVA_Ende]> " & DateTimeForSQL(vglende) & ")))"
strSQL = strSQL & "Select [ID], [Beginn], [Ende], [Grund] FROM zqry_MA_Verfuegbarkeit WHERE istVerfuegbar = 0"

If Not CreateQuery(strSQL, "zqry_VV_tmp_belegt") Then
    MsgBox "zqry_VV_tmp_belegt nicht erzeugt"
End If

End Function


Function fCreateQuery_Verplant(ByVal VA_ID As Long, ByVal vglstart As Date, ByVal vglende As Date)

Dim strSQL As String

'Start und Ende der Verfügbarkreitsprüfung startet / endet zwei Minuten nach / vor dem eigentlichen Start / Ende um Überschneidungen sicher zu vermeiden
vglstart = DateAdd("n", 2, vglstart) 'Start
vglende = DateAdd("n", -2, vglende)  'Ende

Call upd_Vergleichszeiten(VA_ID, vglstart, vglende)

strSQL = ""
strSQL = strSQL & "Select [MA_ID], [MAName], [VADatum], [MVA_Start], [MVA_Ende], [Art], ObjektOrt FROM qry_VV_Union WHERE ("
strSQL = strSQL & " ([MVA_Start] between " & DateTimeForSQL(vglstart) & " and " & DateTimeForSQL(vglende) & ")  OR"
strSQL = strSQL & " ([MVA_Ende] between " & DateTimeForSQL(vglstart) & " and " & DateTimeForSQL(vglende) & ")  OR"
strSQL = strSQL & " (([MVA_Start]< " & DateTimeForSQL(vglstart) & ") AND ([MVA_Ende]> " & DateTimeForSQL(vglende) & ")))"

If Not CreateQuery(strSQL, "qry_VV_tmp_belegt") Then
    MsgBox "qry_VV_tmp_belegt nicht erzeugt"
End If

End Function


'Function fCreateQuery_Verplant_1(ByVal vglstart As Date, ByVal vglende As Date)
'
'Dim strSQL As String
'
''Start und Ende der Verfügbarkreitsprüfung startet / endet zwei Minuten nach / vor dem eigentlichen Start / Ende um Überschneidungen sicher zu vermeiden
'vglstart = DateAdd("n", 2, vglstart) 'Start
'vglende = DateAdd("n", -2, vglende)  'Ende
'
'strSQL = ""
'strSQL = strSQL & "Select [MA_ID], [MAName], [VADatum], [MVA_Start], [MVA_Ende], [Art], ObjektOrt FROM qry_VV_Union WHERE ("
'strSQL = strSQL & " ([MVA_Start] between " & DateTimeForSQL(vglstart) & " and " & DateTimeForSQL(vglende) & ")  OR"
'strSQL = strSQL & " ([MVA_Ende] between " & DateTimeForSQL(vglstart) & " and " & DateTimeForSQL(vglende) & ")  OR"
'strSQL = strSQL & " (([MVA_Start]< " & DateTimeForSQL(vglstart) & ") AND ([MVA_Ende]> " & DateTimeForSQL(vglende) & ")))"
'
'If Not CreateQuery(strSQL, "qry_VV_tmp_belegt") Then
'    MsgBox "qry_VV_tmp_belegt nicht erzeugt"
'End If
'
'End Function


Function fZeitAusg(st As String, en As String, Ist As Long, Soll As Long) As String

Dim s As String
Dim s1 As String

s = ""
If Len(Trim(Nz(st))) = 0 Then
    s1 = "von"
Else
    s1 = st
End If
s = s & s1 & " - "

If Len(Trim(Nz(en))) = 0 Then
    s1 = "xxx"
Else
    s1 = en
End If
s = s & s1

s = s & " Uhr | " & Ist & " / " & Soll

fZeitAusg = s

End Function

Function fVA_AnzTage_Update()

'############################################################
'Update alle Soll / Ist Zeiten

Call CurrentDb.Execute("Delete * FROM tbl_MA_VA_Zuordnung WHERE ID IN (SELECT Zuo_ID From qry_Falsche_Nr)")
Call CurrentDb.Execute("DELETE tbl_VA_AnzTage.ID, tbl_VA_Start.* FROM tbl_VA_Start LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Start.VADatum_ID = tbl_VA_AnzTage.ID WHERE (((tbl_VA_AnzTage.ID) Is Null));")

'Schritt 1 - Neue Soll-Zeiten hinzufügen
CurrentDb.Execute ("qry_VA_AnzTage_Soll_Add")

'temp table löschen
CurrentDb.Execute ("delete * FROM tbltmp_VA_Soll_Ist")

'temp table füllen
CurrentDb.Execute ("qry_VA_tmp_Soll_Ist_Add")

'Überschreiben alter VA_AnzTage Werte
CurrentDb.Execute ("qry_VA_Soll_Ist_Update_1")

'Ist: Alle VA_AnzTage 0 Setzen
CurrentDb.Execute ("qry_VA_Soll_Ist_Update_2")

'Alles TRUE setzen
CurrentDb.Execute ("qry_VA_Soll_Ist_Update_3")

'Alles False setzen, wenn TVA_Soll = 0 Oder TVA_Soll > TVA_Ist
CurrentDb.Execute ("qry_VA_Soll_Ist_Update_4")

'Aufräumen
'temp table löschen
CurrentDb.Execute ("delete * FROM tbltmp_VA_Soll_Ist")

'###########################

'temp table löschen
CurrentDb.Execute ("delete * FROM tbltmp_VAStart_Ist")

'temp table Füllen
CurrentDb.Execute ("qry_VA_Start_tmp_Add")

' Ist-Zeiten VA_Start auf 0 setzen
CurrentDb.Execute ("qry_VA_Start_Ist_Update_1")

'Update Ist-Zeiten VA_Start
CurrentDb.Execute ("qry_VA_Start_Ist_Update_2")

'Veranstaltungsstatus auf 1 setzen, wenn offen
CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID SET tbl_VA_Auftragstamm.Veranst_Status_ID = 1 WHERE (((tbl_VA_Auftragstamm.Veranst_Status_ID)<4) AND ((tbl_VA_AnzTage.TVA_Offen)=True));")

'Veranstaltungsstatus auf 1 setzen, wenn offen
CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID SET tbl_VA_Auftragstamm.Veranst_Status_ID = 1 WHERE (((tbl_VA_Auftragstamm.Veranst_Status_ID)<4) AND ((tbl_VA_AnzTage.TVA_Offen)=True));")

'Aufräumen
'temp table löschen
CurrentDb.Execute ("delete * FROM tbltmp_VAStart_Ist")

'############################################################

End Function

Function Zuord_Fill(iVADatum_ID As Long, iVA_ID As Long)

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim ArrFill_DAO_OK2 As Boolean, recsetSQL2 As String, iZLMax2 As Long, iColMax2 As Long, DAOARRAY2, iZl2 As Long, iCol2 As Long
Dim iAnz As Long
Dim i As Long, j As Long, k As Long
Dim iLfdNr As Long
Dim sAnz As Single
Dim iVgl As Long
Dim iGes As Long
Dim iGesVgl As Long

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim dtVgl As Date
Dim dtvgl_ID As Long
Dim dtdat As Date
Dim dtdat_ID As Long
Dim dtdatzeitvon As Date
Dim dtdatzeitbis As Date

Dim Dat_VA_Von As Date

Dim StdBrutto As Single
Dim Std_Pa As Single
Dim PauseAnz As Single

Dim iPosNr As Long

Dim strSQL As String
Dim iVAStart_ID As Long
Dim iMA_ID As Long

Dim iSollVgl As Long
Dim iSoll As Long

Dim dtSt1
Dim dtEn1

Dim dtSt2
Dim dtEn2

Set db = CurrentDb

'Table tbl_MA_VA_Zuordnung mit den fehlenden Positionsnummern füllen.
'Table tbl_MA_VA_Zuordnung - Überzählige IDs löschen
'Update aller Datensätze mit Sortierung der MAs und Neuer Vergabe der Positionsnummern

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents


'Löschen ganze Schichten ...
Call CurrentDb.Execute("Delete * FROM tbl_MA_VA_Zuordnung WHERE VA_ID IN (SELECT Zuo_ID From qry_Falsche_Nr)")
DoEvents

recsetSQL1 = "SELECT tbl_VA_Start.* FROM tbl_VA_Start where tbl_VA_Start.VA_ID = " & iVA_ID & " AND tbl_VA_Start.VADatum_ID = " & iVADatum_ID & " ORDER BY VA_Start, VA_Ende;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        iVAStart_ID = CLng(DAOARRAY1(0, iZl))
        'Anzahl lt Schichtplan
        iAnz = CLng(DAOARRAY1(3, iZl))
        'Vorhandene Anzahl lt. Einsatzplan
        iVgl = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VAStart_ID = " & iVAStart_ID), 0)
       
       'Wenn Überzählige im Einsatzplan ...
        If iVgl > iAnz Then  ' Überzählige löschen
            j = iVgl - iAnz
            Set rst = db.OpenRecordset("SELECT * FROM tbl_MA_VA_Zuordnung WHERE VAStart_ID = " & iVAStart_ID & " Order by PosNr Desc;")
            With rst
                For i = 1 To j
                    .Delete
                    .MoveNext
                Next i
                .Close
                DoEvents
            End With
            Set rst = Nothing
            DoEvents
            
        'Wenn Unterzählige im Einsatzplan ...
        ElseIf iVgl < iAnz Then  ' Fehlende hinzufügen
            j = iAnz - iVgl
            iLfdNr = Nz(TMax("PosNr", "tbl_MA_VA_Zuordnung", "VAdatum_ID = " & iVADatum_ID), 0) + 1
            
            dtdat = CDate(DAOARRAY1(7, iZl))
            j = iAnz - iVgl
            Debug.Print j
            For i = 1 To j
                
                strSQL = ""
                strSQL = strSQL & "INSERT INTO tbl_MA_VA_Zuordnung ( VA_ID, VADatum_ID, VAStart_ID, PosNr, MA_ID, MA_Start, MA_Ende, Erst_am, Erst_von, VADatum, MVA_Start, MVA_Ende, PreisArt_ID)"
                strSQL = strSQL & " SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, tbl_VA_Start.ID, "
                strSQL = strSQL & iLfdNr & " AS APosNr, 0 AS AMA_ID, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, "
                strSQL = strSQL & " Now() AS Ausdr5, atcnames(1) AS Ausdr6, "
                strSQL = strSQL & " tbl_VA_Start.VADatum, tbl_VA_Start.MVA_Start, tbl_VA_Start.MVA_Ende, 1 AS APrArt "
                strSQL = strSQL & " FROM tbl_VA_Start WHERE (((tbl_VA_Start.ID)= " & iVAStart_ID & "));"
                CurrentDb.Execute (strSQL)
                                  
                iLfdNr = iLfdNr + 1
            
            Next i
            DoEvents
        End If
    Next iZl

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

'Über und unterzählige Datensätze bereinigt
' Jetzt alle Datensätze Updaten
            
'Namen sortieren pro Schicht
    For iZl = 0 To iZLMax1
        iVAStart_ID = CLng(DAOARRAY1(0, iZl))
        iAnz = CLng(DAOARRAY1(3, iZl))
        dtSt2 = DAOARRAY1(4, iZl)
        dtEn2 = DAOARRAY1(5, iZl)
        
        recsetSQL1 = ""
        recsetSQL1 = recsetSQL1 & "SELECT tbl_MA_VA_Zuordnung.MA_ID, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_Ende FROM tbl_MA_VA_Zuordnung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Zuordnung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
        recsetSQL1 = recsetSQL1 & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID) = " & iVA_ID & ") And ((tbl_MA_VA_Zuordnung.VADatum_ID) = " & iVADatum_ID & " ) AND MA_ID > 0 And ((tbl_MA_VA_Zuordnung.VAStart_ID) = " & iVAStart_ID & "))"
        recsetSQL1 = recsetSQL1 & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname, tbl_MA_VA_Zuordnung.MA_Start, tbl_MA_VA_Zuordnung.MA_ENde;"
        
        ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
        'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
        If Not ArrFill_DAO_OK1 Then
    '        MsgBox "Sortierung nicht möglich, Abbruch"
            Exit For
        End If
    
        iSollVgl = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID), 0)
        If iSollVgl = 0 Or iAnz <> iSollVgl Then
           ' MsgBox "Sortierung nicht möglich, Abbruch"
            Debug.Print "Keine Sortierung"
            Exit For
        End If
        Set rst = db.OpenRecordset("SELECT * FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " ORDER BY [PosNr];")
        iZl = 0
        With rst
            Do Until .EOF
                If iZl <= iZLMax1 Then
                    iMA_ID = DAOARRAY1(0, iZl)
                    dtSt1 = DAOARRAY1(1, iZl)
                    dtEn1 = DAOARRAY1(2, iZl)
                Else
                    iMA_ID = 0
                    dtSt1 = dtSt2
                    dtEn1 = dtEn2
                End If
                .Edit
                    .fields("MA_ID") = iMA_ID
                    .fields("MA_Start") = dtSt1
                    .fields("MA_Ende") = dtEn1
                .update
                .MoveNext
                iZl = iZl + 1
            Loop
            .Close
        End With
        Set rst = Nothing
    Next iZl
End If



DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents


'Fortlaufende PosNr erzeugen über alle Schichten hinweg
k = rstDcount("*", "SELECT * FROM tbl_MA_VA_Zuordnung WHERE VADatum_ID = " & iVADatum_ID & " AND VA_ID = " & iVA_ID)
If k > 0 Then
    i = k
    Set rst = db.OpenRecordset("SELECT * FROM tbl_MA_VA_Zuordnung WHERE VADatum_ID = " & iVADatum_ID & " AND VA_ID = " & iVA_ID & " Order by MA_Start, PosNr;")
    With rst
    'Dummy Lfd Nr vergeben um die Key-Eindeutigkeit nicht zu verletzen
        Do Until .EOF
            .Edit
               .fields("PosNr").Value = i * 10000
            .update
            i = i - 1
            .MoveNext
        Loop
        .MoveFirst
        
    'Lfd Nr umsortieren
        i = 1
        Do Until .EOF
            .Edit
               .fields("PosNr").Value = i
            .update
            i = i + 1
            .MoveNext
        Loop
        .Close
        DoEvents
        Set rst = Nothing
    End With
End If


DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents


Set DAOARRAY1 = Nothing
Set DAOARRAY2 = Nothing
End Function


Function fCreate_PosNr_Lfd()
Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long
Dim iVgl As Long
Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM tbltmp_PosNr_create ORDER BY VADatum, VA_ID, VA_Start_ID, LfdNr_Start;")
With rst
    iVgl = .fields("MaxPos")
    i = 1
    Do While Not .EOF
        If iVgl <> .fields("MaxPos") Then
            i = 1
            iVgl = .fields("MaxPos")
        End If
        .Edit
            .fields("PosNr") = i
        .update
        i = i + 1
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing

End Function


Function fObjektOrt(ByVal Auftrag As String, ByVal Ort As String, ByVal Objekt As String) As String

Dim i1 As Long, i2 As Long, i3 As Long, s As String
i1 = Len(Trim(Nz(Auftrag)))
i2 = Len(Trim(Nz(Ort)))
i3 = Len(Trim(Nz(Objekt)))

If i1 > 0 And i2 > 0 And i3 > 0 Then
    s = Trim(Objekt & " " & Ort)
Else
    s = Trim(Nz(Auftrag)) & " " & Trim(Nz(Objekt))
    s = Trim(s) & " " & Trim(Nz(Ort))
    s = Trim(s)
End If
fObjektOrt = s

End Function


'Objekt + Ort für Dienstplanübersicht
Function fObjektOrt3(ByVal Auftrag As String, ByVal Ort As String, ByVal Objekt As String) As String

Dim i1 As Long, i2 As Long, i3 As Long, s As String

    i1 = Len(Trim(Nz(Auftrag)))
    i2 = Len(Trim(Nz(Ort)))
    i3 = Len(Trim(Nz(Objekt)))
    
    
    If i1 > 0 And i2 > 0 And i3 > 0 Then
        s = Trim(Auftrag & " " & Objekt & " " & Ort)
    Else
        s = Trim(Nz(Auftrag)) & " " & Trim(Nz(Objekt))
        s = Trim(s) & " " & Trim(Nz(Ort))
        s = Trim(s)
    End If
    
    'Nur Auftrag und Ort anzeigen
    s = Trim(Nz(Auftrag)) & ", " & Trim(Nz(Ort))
    
    
    fObjektOrt3 = s

End Function



Function ftel_erf(s1 As String, s2 As String) As String
Dim s As String
If Len(Trim(Nz(s1))) > 0 And Len(Trim(Nz(s2))) > 0 Then
    s = s1 & " | " & s2
Else
    s = Trim(Nz(s1) & Nz(s2))
End If
ftel_erf = s
End Function

Function fAnstellungsart(ID As Long) As String
fAnstellungsart = Nz(TLookup("Anstellungsart", "tbl_hlp_MA_Anstellungsart", "ID = " & ID))
End Function


Function VA_Start_Erw()
'Dim db As DAO.Database
'Dim rst As DAO.Recordset
'Dim i As Long
'Dim A As String
'Dim ivgl As Long
'
'Set db = CurrentDb()
'Set rst = db.OpenRecordset("SELECT * FROM tbl_VA_Start ORDER BY VA_ID, VADatum_ID, VA_Start, VA_Ende;")
'A = "A"
'With rst
'    ivgl = .Fields("VA_ID")
'    Do While Not .EOF
'        If ivgl <> .Fields("VA_ID") Then
'            A = "A"
'            ivgl = .Fields("VA_ID")
'        End If
'        .Edit
'            .Fields("VAStart_ID_Bchst") = A
'        .Update
'        A = Chr$(Asc(A) + 1)
'        .MoveNext
'    Loop
'    .Close
'End With
'Set rst = Nothing
'
'DoEvents
'CurrentDb.Execute ("UPDATE tbl_VA_Start INNER JOIN tbl_MA_VA_Zuordnung ON tbl_VA_Start.ID = tbl_MA_VA_Zuordnung.VAStart_ID SET tbl_MA_VA_Zuordnung.VAStart_ID_Bchst = [tbl_VA_Start].[VAStart_ID_Bchst];")
'DoEvents

End Function

Function fAnzAuftragTag(dt As Date) As Long

If dt <= CDate(TMax("VADatum", "tbl_VA_AnzTage")) And dt >= CDate(DMin("VADatum", "tbl_VA_AnzTage")) Then
    fAnzAuftragTag = Nz(TCount("*", "tbl_VA_AnzTage", "VADatum = " & SQLDatum(dt)), 0)
Else
    fAnzAuftragTag = -1
End If
End Function


Function date_Umsetz(dt As Date, relstd As Single) As Date

Dim dtx As Date
dtx = dt + (relstd / 24)

date_Umsetz = dtx

End Function


Function Loginname() As String
Loginname = Nz(TLookup("Int_Nachname", "_tblEigeneFirma_Mitarbeiter", "int_Login = '" & atCNames(1) & "'")) & ", " & Nz(TLookup("Int_Vorname", "_tblEigeneFirma_Mitarbeiter", "int_Login = '" & atCNames(1) & "'"))
End Function

Function fAuftr_RG(iTyp As Long, iRch_ID As Long)
Dim i As Long, iVA_ID As Long
Dim strSQL As String
strSQL = "SELECT tbl_Rch_Pos_Auftrag.VA_ID, tbl_Rch_Pos_Auftrag.Rch_ID FROM tbl_Rch_Pos_Auftrag GROUP BY tbl_Rch_Pos_Auftrag.VA_ID, tbl_Rch_Pos_Auftrag.Rch_ID"

i = rstDcount("*", strSQL, "Rch_ID = " & iRch_ID)
If i > 1 Or i < 1 Then
    If iTyp = 1 Then
        fAuftr_RG = "Diverse"
    Else
        fAuftr_RG = ""
    End If
Else
    iVA_ID = Nz(TLookup("VA_ID", "tbl_Rch_Pos_Auftrag", "Rch_ID = " & iRch_ID))
    Select Case iTyp
        Case 1
            fAuftr_RG = TLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & iVA_ID)
        Case 2
            fAuftr_RG = TLookup("Ort", "tbl_VA_Auftragstamm", "ID = " & iVA_ID)
        Case 3
            fAuftr_RG = TLookup("Objekt", "tbl_VA_Auftragstamm", "ID = " & iVA_ID)
        Case Else
            fAuftr_RG = ""
    End Select
End If

End Function


Function MA_ID_Test(MA_ID As Long) As Long

Dim i As Long
i = Nz(TLookup("ID", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)

If i = 0 Then
    MA_ID_Test = 1001  ' TBA
Else
    MA_ID_Test = i
End If

End Function

'Function fMA_IstOK(ID As Long, MA_ID As Long, VADatum As Date, VAStart_ID As Long, Zeit_Herkunft_ID As Long, Optional VA_ID As Long, Optional bFehlerAnz As Boolean = True) As Long
''fMA_IstOK(Me!ID, Me!MA_ID, Me!VADatum, Me!MA_Start, Me!MA_Ende, 3, Me.Parent!ID, bFehlerAnz)
'' Zeit_Herkunft_ID = Woher kam der Aufruf: : 1 = Planung, 3 = Zuordnung
'
''Fehlercode = 1 - Im gleichen Auftrag bereits verplant
'
'Dim strSQL As String
'
'strSQL = "VA_ID = " & VA_ID & " AND MA_ID = " & MA_ID & " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID
''MA gleicher Auftrag schon verplant oder zugeordnet ?
'If Len(Trim(Nz(VA_ID))) > 0 Then
'    If TCount("*", "tbl_MA_VA_Zuordnung", strSQL) > 0 Or TCount("*", "tbl_MA_VA_Planung", strSQL) > 0 Then
'        fMA_IstOK = 1
'        Exit Function
'    End If
'End If
'
'strSQL = "VA_ID = " & VA_ID & " AND MA_ID = " & MA_ID & " AND VADatum_ID = " & VADatum_ID
'If Len(Trim(Nz(VA_ID))) > 0 Then
'    If TCount("*", "tbl_MA_VA_Zuordnung", strSQL) > 0 Or TCount("*", "tbl_MA_VA_Planung", strSQL) > 0 Then
'        fMA_IstOK = 2
'        Exit Function
'    End If
'End If
'strSQL = "VA_ID = " & VA_ID & " AND MA_ID = " & MA_ID & " AND VADatum_ID = " & VADatum_ID
'If Len(Trim(Nz(VA_ID))) > 0 Then
'    If TCount("*", "tbl_MA_VA_Zuordnung", strSQL) > 0 Or TCount("*", "tbl_MA_VA_Planung", strSQL) > 0 Then
'        fMA_IstOK = 2
'        Exit Function
'    End If
'End If
'
'End Function

Function VA_AnzTage_Maintainance()

CurrentDb.Execute ("qry_MA_Maintainance_Zuo_1")
CurrentDb.Execute ("qry_MA_Maintainance_Zuo_PKW_2")
CurrentDb.Execute ("qry_MA_Maintainance_Zuo_3")

CurrentDb.Execute ("qry_MA_Maintainance_Upd_Tl0_Null")
CurrentDb.Execute ("qry_MA_Maintainance_UPd_Tl1_Ist")
CurrentDb.Execute ("qry_MA_Maintainance_UPd_Tl2_Soll")
CurrentDb.Execute ("qry_MA_Maintainance_UPd_Tl3_PKWl")
CurrentDb.Execute ("qry_MA_Maintainance_UPd_Tl4_Offen")

DoCmd.DeleteObject acTable, "temp_tbl_MA_Maintainance_Zuo_Tl1"
DoCmd.DeleteObject acTable, "temp_tbl_MA_Maintainance_PKW_Zuo_T2"
DoCmd.DeleteObject acTable, "temp_tbl_MA_Maintainance_Zuo_Tl3"

End Function

'Aktuelle Veranstaltungsdaten updaten
Function VA_AnzTage_Upd(iVA_ID As Long, iVADatum_ID As Long)

Dim iIst As Long
Dim iSoll As Long
Dim iAnzPKW As Long
Dim bIstNotOffen As Long

Dim strSQL As String

iIst = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID > 0 AND VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0)
iAnzPKW = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "PKW IS NOT NULL AND VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0)
iSoll = Nz(TSum("MA_Anzahl", "tbl_VA_Start", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0)
bIstNotOffen = Not ((iIst <> 0) And (iSoll <> 0) And (iSoll - iIst <= 0))

strSQL = ""
strSQL = strSQL & "UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Soll = " & iSoll & ", "
strSQL = strSQL & " tbl_VA_AnzTage.TVA_Ist = " & iIst & ", "
strSQL = strSQL & " tbl_VA_AnzTage.TVA_Offen = " & bIstNotOffen & ", "
strSQL = strSQL & " tbl_VA_AnzTage.PKW_Anzahl = " & iAnzPKW
strSQL = strSQL & " WHERE (((tbl_VA_AnzTage.ID)= " & iVADatum_ID & "));"

CurrentDb.Execute (strSQL)

End Function


Function sumo_Test() As Single
Dim dt As Date
dt = DateSerial(2019, 9, 1)
sumo_Test = zMA_Monat_SumNetStd(152, dt)
End Function

Function MA_Monat_SumNetStd(iMA_ID As Long, mondat As Date) As Single
Dim SQLWHERE As String
Dim mosum As Single
SQLWHERE = "(tbl_MA_VA_Zuordnung.VADatum Between " & SQLDatum(DateSerial(year(mondat), Month(mondat), 1)) & " AND " & SQLDatum(DateSerial(year(mondat), Month(mondat) + 1, 0)) & ") AND ((tbl_MA_VA_Zuordnung.MA_ID = " & iMA_ID & ") AND (tbl_MA_VA_Zuordnung.Rch_Erstellt = TRUE))"
mosum = Nz(TSum("MA_Netto_Std", "tbl_MA_VA_Zuordnunng", SQLWHERE), 0)
MA_Monat_SumNetStd = fctround(mosum)
End Function


'Berechnung Nettostunden -> Gesamter Monat eingeteilt!
Function zMA_Monat_SumNetStd(iMA_ID As Long, mondat As Date) As Single
Dim SQLWHERE As String
Dim mosum As Single

    SQLWHERE = "(" & ZUORDNUNG_FE & ".VADatum Between " & SQLDatum(DateSerial(year(mondat), Month(mondat), 1)) & " AND " & _
        SQLDatum(DateSerial(year(mondat), Month(mondat) + 1, 0)) & ") AND (" & ZUORDNUNG_FE & ".MA_ID = " & iMA_ID & ")"

    mosum = Nz(TSum("MA_Netto_Std2", ZUORDNUNG_FE, SQLWHERE), 0)
    zMA_Monat_SumNetStd = fctround(mosum)
    
End Function


Function Startzeit_G(dtDat1, h_start1) As Date

Dim dtdatzeitvon As Date
Dim dtdatzeitbis As Date
Dim sg As Single

On Error Resume Next
Dim h_start As Date
Dim h_ende As Date

Dim dtdat As Date

If IsNull(h_start1) Or IsNull(dtDat1) Then Exit Function

If Not IsDate(h_start1) Or Not IsDate(dtDat1) Then Exit Function

h_start = h_start1
dtdat = dtDat1

dtdatzeitvon = Fix(dtdat) + TimeSerial(Hour(h_start), minute(h_start), 0)
Startzeit_G = dtdatzeitvon

End Function


Function Endezeit_G(dtDat1, h_start1, Optional h_ende1) As Date

Dim dtdatzeitvon As Date
Dim dtdatzeitbis As Date
Dim sg As Single

Dim stzwi As Single


On Error Resume Next
Dim h_start As Date
Dim h_ende As Date

Dim dtdat As Date

stzwi = CSng(Get_Priv_Property("prp_VA_Start_AutoLaenge")) / 24#

If IsNull(h_start1) Or IsNull(dtDat1) Then Exit Function
If Not IsDate(h_start1) Or Not IsDate(dtDat1) Then Exit Function

h_start = h_start1
dtdat = dtDat1

If IsDate(h_ende1) Then
    h_ende = h_ende1
Else
    h_ende = TimeSerial(Hour(h_start), minute(h_start), 0) + stzwi
End If

dtdatzeitvon = Fix(dtdat) + TimeSerial(Hour(h_start), minute(h_start), 0)
dtdatzeitbis = Fix(dtdat) + TimeSerial(Hour(h_ende), minute(h_ende), 0)
If dtdatzeitbis < dtdatzeitvon Then dtdatzeitbis = dtdatzeitbis + 1
Endezeit_G = dtdatzeitbis

End Function


Function timeberech_G(dtDat1, h_start1, h_ende1, Optional PreisArt_ID As Long = 1) As Variant

Dim dtdatzeitvon As Date
Dim dtdatzeitbis As Date
Dim sg As Single

On Error Resume Next
Dim h_start As Date
Dim h_ende As Date

Dim dtdat As Date


'timeberech_G = 0
sg = 0
timeberech_G = sg

If IsNull(h_start1) Or IsNull(h_ende1) Or IsNull(dtDat1) Then Exit Function

If Not IsDate(h_start1) Or Not IsDate(h_ende1) Or Not IsDate(dtDat1) Or PreisArt_ID > 3 Then Exit Function

h_start = h_start1
h_ende = h_ende1
dtdat = dtDat1

dtdatzeitvon = Fix(dtdat) + TimeSerial(Hour(h_start), minute(h_start), 0)
dtdatzeitbis = Fix(dtdat) + TimeSerial(Hour(h_ende), minute(h_ende), 0)
If dtdatzeitbis < dtdatzeitvon Then dtdatzeitbis = dtdatzeitbis + 1
sg = Nz(fctround(DateDiff("n", dtdatzeitvon, dtdatzeitbis, 2, 2) / 60), 0)
timeberech_G = sg
End Function

Function StdSumAll_Neuberech(Optional iVA_ID As Long = 0)

Dim strSQL As String
Dim strSQL2 As String

If table_exist("tbltmp_AnzStd") Then
    DoCmd.DeleteObject acTable, "tbltmp_AnzStd"
    DoEvents
End If

strSQL2 = ""
If iVA_ID > 0 Then
    strSQL2 = " AND VA_ID = " & iVA_ID
End If

strSQL = "UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Soll = 0, tbl_VA_AnzTage.TVA_Ist = 0 WHERE 1 = 1" & strSQL2 & ";"
CurrentDb.Execute (strSQL)
DoEvents

strSQL = ""
strSQL = strSQL & "SELECT tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID, Sum(tbl_VA_Start.MA_Anzahl) AS SummevonMA_Anzahl INTO tbltmp_AnzStd"
strSQL = strSQL & " FROM tbl_VA_Start "
strSQL = strSQL & " WHERE 1 = 1 " & strSQL2
strSQL = strSQL & " GROUP BY tbl_VA_Start.VA_ID, tbl_VA_Start.VADatum_ID;"
CurrentDb.Execute (strSQL)
DoEvents

strSQL = ""
strSQL = strSQL & "UPDATE tbltmp_AnzStd INNER JOIN tbl_VA_AnzTage ON (tbltmp_AnzStd.VADatum_ID = tbl_VA_AnzTage.ID) "
strSQL = strSQL & " AND (tbltmp_AnzStd.VA_ID = tbl_VA_AnzTage.VA_ID) SET tbl_VA_AnzTage.TVA_Soll = [SummevonMA_Anzahl];"
CurrentDb.Execute (strSQL)
DoEvents

DoCmd.DeleteObject acTable, "tbltmp_AnzStd"

strSQL = ""
strSQL = strSQL & "SELECT tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID, Count(tbl_MA_VA_Zuordnung.MA_ID) AS AnzahlvonMA_ID INTO tbltmp_AnzStd"
strSQL = strSQL & " FROM tbl_MA_VA_Zuordnung "
strSQL = strSQL & " WHERE 1 = 1 " & strSQL2
strSQL = strSQL & " GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_MA_VA_Zuordnung.VADatum_ID"
CurrentDb.Execute (strSQL)
DoEvents

strSQL = ""
strSQL = strSQL & "UPDATE tbltmp_AnzStd INNER JOIN tbl_VA_AnzTage ON (tbltmp_AnzStd.VADatum_ID = tbl_VA_AnzTage.ID) "
strSQL = strSQL & " AND (tbltmp_AnzStd.VA_ID = tbl_VA_AnzTage.VA_ID) SET tbl_VA_AnzTage.TVA_Ist = [AnzahlvonMA_ID];"
CurrentDb.Execute (strSQL)
DoEvents

strSQL = ""
strSQL = strSQL & "UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Offen = True WHERE ((([TVA_Soll]-[TVA_Ist])>0) OR TVA_Soll = 0);"
CurrentDb.Execute (strSQL)
DoEvents

'strSQL = ""
'strSQL = strSQL & "UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Offen = True WHERE (((tbl_VA_AnzTage.TVA_Soll)=0) AND ((tbl_VA_AnzTage.TVA_Ist)=0));"
'CurrentDb.Execute (strSQL)
'DoEvents

'DoCmd.DeleteObject acTable, "tbltmp_AnzStd"

End Function



Function fFontchange_frm(frmName As String)

Dim ctl
DoCmd.OpenForm "MyReport", acViewDesign
For Each ctl In Forms.item("AmbulanceServices")
  If ctl.FontName = "*" Then
    ctl.FontName = "Arial"
    ctl.FontSize = 10
  End If
Next
DoCmd.Save acForm, "MyReport"

End Function

'VA_StartDat: fGetStDat([VaDatum];[VA_Start])
Function fGetStDat(dtDatum As Date, dtStart As Date) As Date
fGetStDat = Fix(dtDatum) + TimeSerial(Hour(dtStart), minute(dtStart), 0)
End Function

'VA_EndeDat: fGetEndDat([VaDatum];[VA_Start];[VA_Ende])
Function fGetEndDat(dtDatum As Date, dtStart As Date, dtEnde As Date) As Date
Dim stdat As Date
Dim Enddat As Date
stdat = Fix(dtDatum) + TimeSerial(Hour(dtStart), minute(dtStart), 0)
Enddat = Fix(dtDatum) + TimeSerial(Hour(dtEnde), minute(dtEnde), 0)
If Enddat < stdat Then Enddat = Enddat + 1
fGetEndDat = Enddat
End Function

Function aend_Dat_Auftr()
Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim dtVgl As Date

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM tbl_XL_Auftrag_Einsatz;")

    With rst
        dtVgl = .fields("dtdatum")
        Do While Not .EOF
            .Edit
            If IsNull(.fields("dtdatum")) Then
            .Edit
                .fields("dtdatum") = dtVgl
            .update
            Else
                dtVgl = .fields("dtdatum")
            End If
            .MoveNext
        Loop
        
        .Close
    End With
Set rst = Nothing

End Function

Function ZtDatLoesch(xin As Variant) As Date
Dim dtdbl As Double
Dim dtlng As Long
If Not IsNull(xin) Then
    If Not IsDate(xin) Then
        Exit Function
    End If
Else
    Exit Function
End If

dtdbl = xin
dtlng = Fix(xin)
ZtDatLoesch = dtdbl - dtlng
End Function

Function VorMon_Ueberlaufstd_Les(MA_ID As Long, aktJahr As Long, Aktmon As Long) As Single
'Lesen Überlaufstunden Vormonat
Dim iJahr As Long
Dim iMon As Long

Dim sWert As Single

iMon = Aktmon - 1
iJahr = aktJahr

If iMon <= 0 Then
    iMon = 12
    iJahr = iJahr - 1
End If

sWert = Nz(TLookup("M" & iMon, "tbl_MA_UeberlaufStunden", "AktJahr = " & iJahr & " AND MA_ID = " & MA_ID), 0)
VorMon_Ueberlaufstd_Les = sWert

End Function

Function AktMon_Ueberlaufstd_Upd(MA_ID As Long, aktJahr As Long, Aktmon As Long, StdAnz As Single) As Single
'Update Überlaufstunden Aktueller Monat

If Aktmon < 1 Or Aktmon > 12 Or aktJahr < 2010 Or aktJahr > year(Date) + 1 Or StdAnz = 0 Then Exit Function

Dim strSQL As String

If Nz(TLookup("ID", "tbl_MA_UeberlaufStunden", "MA_ID = " & MA_ID & " AND AktJahr = " & aktJahr), 0) = 0 Then

    strSQL = ""
    strSQL = strSQL & "INSERT INTO tbl_MA_UeberlaufStunden ( MA_ID, AktJahr )"
    strSQL = strSQL & " SELECT " & MA_ID & "  AS Ausdr1, " & aktJahr & " AS Ausdr2"
    strSQL = strSQL & " FROM _tblInternalSystemFE;"
    CurrentDb.Execute strSQL
    DoEvents

End If

strSQL = ""
strSQL = strSQL & "UPDATE tbl_MA_UeberlaufStunden SET tbl_MA_UeberlaufStunden.M" & Aktmon & " = " & str(StdAnz)
strSQL = strSQL & " WHERE (((tbl_MA_UeberlaufStunden.MA_ID)= " & MA_ID & ") AND ((tbl_MA_UeberlaufStunden.AktJahr)= " & aktJahr & " ));"
CurrentDb.Execute strSQL
DoEvents

End Function


Function DivInfo_MA(MA_ID As Long, sMaxStd As Single, stdlohn As Currency, RV_Betrag As Currency, RL34a_pro_Std As Currency, Proz_Lohnsteuer As Single, MA_Netto_std2 As Single)
'---------------------------------------------------------------------------------------
' Procedure : DivInfo_MA
' Author    : Klaus
' Date      : 09.04.2015
' Purpose   : Liefert alle Werte, die man für die Jahreswerte MA benötigt
'               MA_ID As Long, sMaxStd As Single, RV_Betrag As Currency, stdlohn As Currency, Proz_Lohnsteuer As Single, RL34a_pro_Std As Currency)
'               MA_ID ist Input, der Rest ist Output:
'
'Wenn sMaxStd > 0 Dann die Summe (Nettostunden + Überlauf Vormat) auf max. Erlaubt und Folgemonat verteilen.
' Bei RV_Betrag, RL34a_pro_Std, Proz_Lohnsteuer - Rückgabe 0 wenn Bedingung nicht erfüllt, sonst Wert
'---------------------------------------------------------------------------------------
'
'#################################
'Dim iiMA_ID As Long, osMaxStd As Single, oRV_Betrag As Currency, oRL34a_pro_Std As Currency, ostdlohn As Currency, oProz_Lohnsteuer As Single
'
'iiMA_ID = 1234
'Call DivInfo_MA(iiMA_ID, sMaxStd, stdlohn, RV_Betrag, RL34a_pro_Std, Proz_Lohnsteuer)
'
'osMaxStd = sMaxStd
'ostdlohn = stdlohn
'oRV_Betrag = RV_Betrag             ' Wenn Ist_RV_Befrantrag = True, Betrag 0
'oRL34a_pro_Std = RL34a_pro_Std         ' 34a RL Betrag pro Stunde
'oProz_Lohnsteuer = Proz_Lohnsteuer ' nur wenn Minijobber, sonst 0

'Doevents
'###################################

Dim MJ As String
Dim IstRV As Boolean
Dim Hat_keine_34a As Boolean
Dim Proz_RL_34a As Single
Dim ima_netto_std2 As Single
MJ = UCase(Left(Nz(TLookup("Anstellungsart", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID)), 1))
IstRV = Nz(TLookup("Ist_RV_Befrantrag", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
Hat_keine_34a = Nz(TLookup("Hat_keine_34a", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)

sMaxStd = Nz(TLookup("StundenZahlMax", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
stdlohn = Nz(TLookup("Stundenlohn_brutto", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
ima_netto_std2 = Nz(TLookup("Ma_Netto_std2", "tbl_ma_va_zuordnung", "Me.MA_ID = " & MA_ID), 0)

If MJ = "M" Then
    'Proz_Lohnsteuer = Get_Priv_Property("prp_Lohnst")
    Proz_Lohnsteuer = "0,02"

    
    
    
Else
    Proz_Lohnsteuer = 0
End If

If IstRV = True Then
    RV_Betrag = Get_Priv_Property("prp_RV_Betrag")
Else
    RV_Betrag = 0
End If

If Hat_keine_34a = False Then
    Proz_RL_34a = Get_Priv_Property("prp_RL_34a")
    RL34a_pro_Std = Proz_RL_34a * stdlohn * MA_Netto_std2
Else
    RL34a_pro_Std = 0
End If

End Function

'    fctRound(RL34a_pro_Std([MA_ID_Neu]) * [MA_Netto_Std2])

Function RL34a_pro_Std(MA_ID As Long) As Currency

'Berechnung RL 34a:
'Wenn: Kein_34a angekreuzt ist, wird RL 34a erhoben.
'Wenn Kein_34a NICHT angekreuzt ist, so wird keine 34a Rücklage erhoben.
'Das Datum_34a überschreibt den Status von Kein_34a.
'Wenn Datum_34a enthält, wird VOR diesem Datum die RL 34a erhoben, danach nicht.

Dim Hat_keine_34a As Boolean
Dim MA_stdlohn As Currency
Dim Proz_RL_34a As Single
Dim RL_dat
Dim MA_Netto_Std As Single
MA_stdlohn = Nz(TLookup("Stundenlohn_brutto", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
If MA_stdlohn = 0 Then
    MA_stdlohn = Get_Priv_Property("prp_Lohn_Notfall")
End If

Hat_keine_34a = Nz(TLookup("Hat_keine_34a", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
Proz_RL_34a = Get_Priv_Property("prp_RL_34a")
RL_dat = TLookup("Datum_34a", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID)

If Hat_keine_34a = False Then
    RL34a_pro_Std = Proz_RL_34a * MA_stdlohn * MA_Netto_Std
Else
    RL34a_pro_Std = 0
End If
If Len(Trim(Nz(RL_dat))) = 0 Then
    If Date > RL_dat Then
        RL34a_pro_Std = Proz_RL_34a * MA_stdlohn * MA_Netto_Std
    Else
        RL34a_pro_Std = 0
    End If
End If

End Function

Function MA_Proz_Lohnsteuer(MA_ID As Long) As Single
Dim MJ As Long

MJ = Nz(TLookup("Anstellungsart_ID", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
If MJ = 5 Then
    MA_Proz_Lohnsteuer = Get_Priv_Property("prp_Lohnst")
Else
    MA_Proz_Lohnsteuer = 0
End If

End Function

Function MA_RV_Betrag(MA_ID As Long) As Currency

Dim IstRV As Boolean
IstRV = Nz(TLookup("Ist_RV_Befrantrag", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
If IstRV = False Then
    MA_RV_Betrag = Get_Priv_Property("prp_RV_Betrag")
Else
    MA_RV_Betrag = 0
End If

End Function

Function MA_stdlohn(MA_ID As Long) As Currency

MA_stdlohn = Nz(TLookup("Stundenlohn_brutto", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
If MA_stdlohn = 0 Then
    MA_stdlohn = Get_Priv_Property("prp_Lohn_Notfall")
End If

End Function


Function MA_AktMax_Mon_std(MA_ID As Long, IstGes As Single) As Single
Dim Max_Mon_std As Single
Max_Mon_std = Nz(TLookup("StundenZahlMax", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
If Max_Mon_std > 0 Then
    If IstGes > Max_Mon_std Then
        MA_AktMax_Mon_std = fctround(Max_Mon_std)
    Else
        MA_AktMax_Mon_std = fctround(IstGes)
    End If
Else
    MA_AktMax_Mon_std = fctround(IstGes)
End If
End Function

Function MA_Ueberl_Mon_std(MA_ID As Long, IstGes As Single) As Single
Dim Max_Mon_std As Single
Max_Mon_std = Nz(TLookup("StundenZahlMax", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID), 0)
If Max_Mon_std > 0 Then
    If IstGes > Max_Mon_std Then
        MA_Ueberl_Mon_std = fctround(IstGes - Max_Mon_std)
    Else
        MA_Ueberl_Mon_std = 0
    End If
Else
    MA_Ueberl_Mon_std = 0
End If
End Function



Function Netto_Std_Berech(Brutto_Std As Single) As Single
Dim Pause_Abzug As Single
    Pause_Abzug = Get_Priv_Property("prp_Pausenabzug")
    Netto_Std_Berech = fctround(Brutto_Std * Pause_Abzug)
    
End Function



Function Ueberlaufstd_Berech_Neu(aktJahr As Long, AktMonat As Long, Optional MA_ID As Long = 0)

Dim strSQL As String
Dim strSQL2 As String

Dim iAktMon As Long
Dim iAktJahr As Long
Dim iVorMon As Long
Dim iVorJahr As Long

Dim ARRSTR
Dim i As Long


'Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

'Vormonats-Überlaufwerte Selektieren
        iAktJahr = aktJahr
        iAktMon = AktMonat
        iVorJahr = iAktJahr
        iVorMon = iAktMon - 1
        If iVorMon = 0 Then
            iVorMon = 12
            iVorJahr = iVorJahr - 1
        End If
        
        strSQL = ""
        strSQL = strSQL & "SELECT " & iAktJahr & " AS AktJahr, " & iAktMon & " AS AktMon FROM _tblInternalSystemFE;"
        CreateQuery strSQL, "qry_JB_MA_AktMon"

        strSQL2 = ";"
        If MA_ID > 0 Then strSQL2 = " WHERE tbl_MA_Mitarbeiterstamm.ID= " & MA_ID & ";"
        strSQL = ""
        strSQL = strSQL & "SELECT tbl_MA_Mitarbeiterstamm.ID AS MA_ID, qry_JB_MA_AktMon.AktJahr, qry_JB_MA_AktMon.AktMon"
        strSQL = strSQL & " FROM tbl_MA_Mitarbeiterstamm, qry_JB_MA_AktMon"
        strSQL = strSQL & strSQL2
        CreateQuery strSQL, "qry_JB_MA_AktMon_Alle"

        strSQL2 = ";"
        If MA_ID > 0 Then strSQL2 = " WHERE tbl_MA_Mitarbeiterstamm.ID= " & MA_ID & ";"
        strSQL = ""
        strSQL = strSQL & "INSERT INTO tbl_MA_UeberlaufStunden ( MA_ID, AktJahr )"
        strSQL = strSQL & " SELECT tbl_MA_Mitarbeiterstamm.ID, " & iAktJahr & " AS Ausdr1 FROM tbl_MA_Mitarbeiterstamm"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents
        
        If iVorJahr <> iAktJahr Then
        
            strSQL2 = ";"
            If MA_ID > 0 Then strSQL2 = " WHERE tbl_MA_Mitarbeiterstamm.ID= " & MA_ID & ";"
            strSQL = ""
            strSQL = strSQL & "INSERT INTO tbl_MA_UeberlaufStunden ( MA_ID, AktJahr )"
            strSQL = strSQL & " SELECT tbl_MA_Mitarbeiterstamm.ID, " & iVorJahr & " AS Ausdr1 FROM tbl_MA_Mitarbeiterstamm"
            strSQL = strSQL & strSQL2
            CurrentDb.Execute (strSQL)
            DoEvents

        End If
        
'Jahresübersicht löschen
        strSQL2 = ";"
        If MA_ID > 0 Then strSQL2 = " AND MA_ID = " & MA_ID & ";"
        strSQL = ""
        strSQL = strSQL & "DELETE * FROM tbl_MA_Jahresuebersicht"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents
        
 'Jahreswerte Grund neu Einfügen
        strSQL2 = ";"
        If MA_ID > 0 Then strSQL2 = " AND MA_ID = " & MA_ID & ";"
        strSQL = ""
        strSQL = strSQL & "INSERT INTO tbl_MA_Jahresuebersicht ( MA_ID, AktJahr, AktMon, Brutto_Std2, Ist, Fahrtko, RL_34a, RZ_34a, Abschlag, NichtDa, Kaution, Sonstig,"
        strSQL = strSQL & " SonstFuer, Lohn, LohnVon, IstGes )"
        strSQL = strSQL & " SELECT qry_JB_MA_Sum.MA_ID, qry_JB_MA_Sum.AktJahr, qry_JB_MA_Sum.AktMonat, qry_JB_MA_Sum.MA_Brutto_Std2,"
        strSQL = strSQL & " qry_JB_MA_Sum.MA_Netto_Std2, qry_JB_MA_Sum.Fahrtkost, qry_JB_MA_Sum.RL_34a, qry_JB_MA_Sum.RZ_34a,"
        strSQL = strSQL & " qry_JB_MA_Sum.Abschlag, qry_JB_MA_Sum.NichtDa, qry_JB_MA_Sum.Kaution, qry_JB_MA_Sum.Sonst_Abzuege,"
        strSQL = strSQL & " qry_JB_MA_Sum.Sonst_Abzuege_Grund , qry_JB_MA_Sum.Monatslohn, qry_JB_MA_Sum.Ueberw_von, qry_JB_MA_Sum.MA_Netto_Std2 FROM qry_JB_MA_Sum"
        strSQL = strSQL & " WHERE (((qry_JB_MA_Sum.AktJahr)= " & iAktJahr & " ) AND ((qry_JB_MA_Sum.AktMonat)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents
        
'Überlauf Vormonat updaten
        strSQL2 = ";"
        If MA_ID > 0 Then strSQL2 = " AND tbl_MA_Jahresuebersicht.MA_ID= " & MA_ID & ";"
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.RestAusVormonat = VorMon_Ueberlaufstd_Les([MA_ID]," & iAktJahr & ", " & iAktMon & ")"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.aktJahr) = " & iAktJahr & " ) And ((tbl_MA_Jahresuebersicht.Aktmon) = " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents

strSQL2 = ";"
If MA_ID > 0 Then strSQL2 = " AND MA_ID = " & MA_ID & ";"

'Aktuellen Monat Updaten - IstGes = Ist + Überlauf Vormonat
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.IstGes = fctRound(Nz([RestAusVormonat],0) + Nz([Ist],0))"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents
    

'Aktuellen Monat Überlauf ermitteln - IstGes trennen in HabVerr (MaxStd) und UeberlaufAktMonat (ÜberlaufStunden)
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.UeberlaufAktMonat = Nz(MA_Ueberl_Mon_std([MA_ID],[IstGes]),0),"
        strSQL = strSQL & " tbl_MA_Jahresuebersicht.HabVerr = Nz(fctRound(MA_AktMax_Mon_std([MA_ID], [IstGes])),0)"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents

'Aktuellen Monat Überlaufstunden in tbl_MA_UeberlaufStunden übertragen
        strSQL2 = ";"
        If MA_ID > 0 Then strSQL2 = " AND tbl_MA_Jahresuebersicht.MA_ID = " & MA_ID & ";"
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_UeberlaufStunden INNER JOIN tbl_MA_Jahresuebersicht ON (tbl_MA_UeberlaufStunden.AktJahr = tbl_MA_Jahresuebersicht.AktJahr)"
        strSQL = strSQL & " AND (tbl_MA_UeberlaufStunden.MA_ID = tbl_MA_Jahresuebersicht.MA_ID)"
        strSQL = strSQL & " SET tbl_MA_UeberlaufStunden.M" & iAktMon & " = 1 * Nz([UeberlaufAktMonat],0)"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents

'Aktuellen Monat InfBrutto
strSQL2 = ";"
If MA_ID > 0 Then strSQL2 = " AND MA_ID = " & MA_ID & ";"
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.InfBrutto = fctRound(Nz([HabVerr],0) * Nz(MA_StdLohn([MA_ID]),0))"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents

'Aktuellen Monat RV Update
'        If Date >= DateSerial(iAktJahr, iAktMon - 1, 1) Then
            strSQL = ""
            strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET"
            strSQL = strSQL & " tbl_MA_Jahresuebersicht.RV = Nz(MA_RV_Betrag([MA_ID]),0)"
            strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
            strSQL = strSQL & strSQL2
            CurrentDb.Execute (strSQL)
            DoEvents
'        End If

'Aktuellen Monat Lohnsteuer Update
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.Lst = fctRound(MA_Proz_Lohnsteuer([MA_ID])*Nz([InfBrutto],0) *-1)"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents

'Aktuellen Monat InfNetto Update
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.InfNetto = fctRound(Nz([InfBrutto],0) + Nz([Lst],0))"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents
        
'Aktuellen Monat InfGesamt Update
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET"
        strSQL = strSQL & " tbl_MA_Jahresuebersicht.InfGesamt = fctRound(Nz([InfNetto],0) + Nz([RL34a],0) + Nz([Abschlag],0) + Nz([NichtDa],0) + Nz([Kaution],0) + Nz([Sonstig],0) + Nz([RV],0) + Nz([FahrtKo],0))"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents
                
'Aktuellen Monat InfGesamt Update
        strSQL = ""
        strSQL = strSQL & "UPDATE tbl_MA_Jahresuebersicht SET"
        strSQL = strSQL & " tbl_MA_Jahresuebersicht.RestGut = fctRound(Nz([InfGesamt],0) + Nz([Lohn],0))"
        strSQL = strSQL & " WHERE (((tbl_MA_Jahresuebersicht.AktJahr)= " & iAktJahr & ") AND ((tbl_MA_Jahresuebersicht.AktMon)= " & iAktMon & "))"
        strSQL = strSQL & strSQL2
        CurrentDb.Execute (strSQL)
        DoEvents
                

'HabVerr enthält manchmal zuviele Nachkommastellen, (warum auch immer keine Ahnung) Deshalb werden diese "weg"-gerundet.
CurrentDb.Execute ("UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht.HabVerr = fctround(tbl_MA_Jahresuebersicht.HabVerr);")

'Wenn 0 dann NULL  - 0-Werte in den folgenden Feldern löschen ...
ARRSTR = Array("Brutto_Std2", "Ist", "RestAusVormonat", "InfBrutto", "lst", "IstGes", "UeberlaufAktMonat", "HabVerr", "InfNetto", "InfGesamt", "RestGut", "RV")
For i = 0 To UBound(ARRSTR)
    CurrentDb.Execute ("UPDATE tbl_MA_Jahresuebersicht SET tbl_MA_Jahresuebersicht." & ARRSTR(i) & " = Null WHERE (((tbl_MA_Jahresuebersicht." & ARRSTR(i) & ")=0));")
Next i

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Function

Function Tabellen_Loeschen()

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim StrName As String

recsetSQL1 = "SELECT tblName FROM Acc_Acc_tblVerknuepfungstabellen WHERE jn = True;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
On Error Resume Next
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1

        StrName = DAOARRAY1(0, iZl)
        DoCmd.DeleteObject acTable, StrName

    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function

Function fKD_Adr_create(kun_ID As Long) As String

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim StrName As String

'tbl_KD_Kundenstamm
'Field Name
'==========
'0 - kun_Id
'1 - kun_AdressArt
'2 - kun_Firma
'3 - kun_Bezeichnung
'4 - kun_Matchcode
'5 - kun_Strasse
'6 - kun_PLZ
'7 - kun_Ort
'8 - kun_LKZ
'9 - kun_BriefKopf
'10 - kun_ans_manuell
'11 - kun_Anschreiben
'12 - kun_land_vorwahl
'13 - kun_telefon
'14 - kun_telefax
'15 - kun_mobil
'16 - kun_email
'17 - kun_URL
'18 - kun_kreditinstitut
'19 - kun_blz
'20 - kun_kontonummer
'21 - kun_iban
'22 - kun_bic
'23 - kun_ustidnr
'24 - kun_memo
'25 - kun_geloescht
'26 - Erst_von
'27 - Erst_am
'28 - Aend_von
'29 - Aend_am
'30 - kun_IDF_PersonID
'==========

recsetSQL1 = "SELECT * From tbl_KD_Kundenstamm WHERE kun_ID = " & kun_ID
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
On Error Resume Next
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        
        StrName = ""
        StrName = StrName & DAOARRAY1(2, iZl)
        StrName = StrName & vbCrLf & DAOARRAY1(3, iZl)
        StrName = StrName & vbCrLf & DAOARRAY1(5, iZl)
        StrName = StrName & vbCrLf
        StrName = StrName & vbCrLf & DAOARRAY1(6, iZl) & " " & DAOARRAY1(7, iZl)
        fKD_Adr_create = StrName
        
    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function

'Bild für Ausweis
Function fKopf_Bildname(MA_ID As Long) As String

Dim Bildname As String
Dim MA_Bildpfad As String
Dim Me_tblBilddatei As String
'Pfad ID 7 = Consec MA

Me_tblBilddatei = Nz(TLookup("tblBilddatei", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID))
MA_Bildpfad = Nz(Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 7")))

On Error Resume Next
If Not File_exist(MA_Bildpfad & Me_tblBilddatei) Then
    Bildname = "KeinBild.jpg"
Else
    Bildname = Me_tblBilddatei
End If

fKopf_Bildname = MA_Bildpfad & Bildname

End Function

'Signatur für Ausweis
Function fSignatur(MA_ID As Long) As String

Dim Signaturname As String
Dim MA_Signaturpfad As String
Dim Me_tblSignaturdatei As String

Me_tblSignaturdatei = Nz(TLookup("tblSignaturdatei", "tbl_MA_Mitarbeiterstamm", "ID = " & MA_ID))
MA_Signaturpfad = Nz(Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 14")))

On Error Resume Next
If Not File_exist(MA_Signaturpfad & Me_tblSignaturdatei) Then
    Signaturname = "KeinSignatur.jpg"
Else
    Signaturname = Me_tblSignaturdatei
End If

fSignatur = MA_Signaturpfad & Signaturname

End Function

Function fUnterschrift_Bild()
Dim MA_Bildpfad As String

'Pfad ID 6 = Consec intern
MA_Bildpfad = Nz(Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 6")))

fUnterschrift_Bild = MA_Bildpfad

End Function

Public Sub DatenbankEinlesen(strDatenbank As String)
Dim db As DAO.Database
Dim dbQuelle As DAO.Database
Dim lngDatenbankID As Long
Set db = CurrentDb
DoCmd.Hourglass True
Set dbQuelle = OpenDatabase(strDatenbank, , True)
db.Execute "DELETE FROM tblDatenbanken WHERE Datenbank = '" & dbQuelle.Name & "'", dbFailOnError
db.Execute "INSERT INTO tblDatenbanken(Datenbank) VALUES('" & dbQuelle.Name & "')", dbFailOnError
lngDatenbankID = db.OpenRecordset("SELECT @@IDENTITY").fields(0)
TabellenEinlesen db, dbQuelle, lngDatenbankID
DoCmd.Hourglass False
End Sub

Public Sub TabellenEinlesen(db As DAO.Database, dbQuelle As DAO.Database, lngDatenbankID As Long)

Dim tdf As DAO.TableDef
Dim intSystemtabelle As Integer
Dim intVersteckteTabelle As Integer
Dim lngTabelleID As Long
Dim bolEinlesen As Boolean
For Each tdf In dbQuelle.TableDefs
bolEinlesen = True
SysCmd acSysCmdSetStatus, "Tabelle '" & tdf.Name & "'"
intSystemtabelle = Not ((tdf.attributes And dbSystemObject) = 0)
intVersteckteTabelle = Not ((tdf.attributes And dbHiddenObject) = 0)
'If Me!chkSystemtabellen = False Then
If intSystemtabelle = True Then
bolEinlesen = False
End If
'End If
'If Me!chkVersteckteTabellen = False Then
If intVersteckteTabelle = True Then
bolEinlesen = False
End If
'End If
If bolEinlesen = True Then
db.Execute "INSERT INTO tblTabellen(Tabelle, DatenbankID, Systemtabelle, VersteckteTabelle) VALUES('" _
& tdf.Name & "', " & lngDatenbankID & ", " & intSystemtabelle & ", " & intVersteckteTabelle & ")"
lngTabelleID = db.OpenRecordset("SELECT @@IDENTITY").fields(0)
FelderEinlesen db, tdf, lngTabelleID
'TabelleneigenschaftenEinlesen db, tdf, lngTabelleID
End If
Next tdf
'SysCmd acSysCmdClearStat
End Sub

Public Sub FelderEinlesen(db As DAO.Database, tdf As DAO.TableDef, lngTabelleID As Long)
Dim fld As DAO.field
Dim lngFeldID As Long
For Each fld In tdf.fields
SysCmd acSysCmdSetStatus, "Tabelle '" & tdf.Name & "', Feld '" & fld.Name & "'"
db.Execute "INSERT INTO tblFelder(Feld, TabelleID) VALUES('" & fld.Name & "', " & lngTabelleID & ")", dbFailOnError
lngFeldID = db.OpenRecordset("SELECT @@IDENTITY").fields(0)
FeldeigenschaftenEinlesen db, tdf, fld, lngFeldID
Next fld
End Sub

Public Sub FeldeigenschaftenEinlesen(db As DAO.Database, tdf As DAO.TableDef, fld As DAO.field, lngFeldID As Long)
Dim prp As DAO.Property
Dim strEigenschaft As String
Dim strWert As String
For Each prp In fld.Properties
SysCmd acSysCmdSetStatus, "Tabelle '" & tdf.Name & "', Feld '" & fld.Name & "', Eigenschaft '" & prp.Name & "'"
Select Case prp.Name
Case "FieldSize", "ForeignName", "OriginalValue", "ValidateOnSet", "Value", "VisibleValue"
Case Else
strEigenschaft = prp.Name
strWert = prp.Value
db.Execute "INSERT INTO tblFeldeigenschaften(Feldeigenschaft, Eigenschaftswert, FeldID) VALUES('" _
& strEigenschaft & "', '" & Replace(strWert, "'", "''") & "', " & lngFeldID & ")", dbFailOnError
End Select
Next prp
End Sub


'Dateiname aus Pfad extrahieren
Function fDateiNameAusPfad(pfad As String) As String
Dim temp

    temp = Split(pfad, "\")
    fDateiNameAusPfad = temp(UBound(temp))
End Function


'Datum für Bericht Einsatzliste aufbereiten
Function fVADatum(VADatum As Date, PosNr As Integer) As String
    
    If PosNr = 1 Then fVADatum = Format(VADatum, "DDD. DD.MM.YY")
    
End Function