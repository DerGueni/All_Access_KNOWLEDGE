VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_Auf_Briefkopf"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Dim wdApp As Word.Application
'Dim wdDoc As Word.Document
'Dim wdRng As Word.Range
'Dim wdTab As Word.Table
'Dim wdRng2 As Word.Range
'Dim Ins As Word.InlineShape
'Dim wdTmp As Word.TEMPLATE

Dim wdApp As Object
Dim wdDoc As Object
Dim wdRng As Object
Dim wdTab As Object
Dim wdRng2 As Object
Dim Ins As Object
Dim wdTmp As Object

Const wdToggle = 9999998
Const wdSortByName = 0
Const wdCharacter = 1
Const wdLine = 5

Const wdStory As Long = 6
Const wdPrintView As Long = 3
Const wdGoToBookmark As Long = -1
Const wdOpenFormatAuto As Long = 0
Const wdUseDestinationStylesRecovery As Long = 19

Private Sub btnWord_Click()

Dim tTmp As String

Dim i As Long
Dim j As Long

Dim strName1 As String

Dim strBookm As String
Dim strInhalt As String
Dim strdoc As String
Dim strSavDoc As String

Dim strSQL As String

Dim strVorlagePfad As String

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
Dim ArrFill_DAO_OK2 As Boolean, recsetSQL2 As String, iZLMax2 As Long, iColMax2 As Long, DAOARRAY2, DAOARRAY_Name2, iZl2 As Long, iCol2 As Long
Dim ArrFill_DAO_OK3 As Boolean, recsetSQL3 As String, iZLMax3 As Long, iColMax3 As Long, DAOARRAY3, DAOARRAY_Name3, iZl3 As Long, iCol3 As Long

'If Not FileExists(CurrentPath & "Vorlagen\") Then MkDir CurrentPath & "Vorlagen\"
'If Not FileExists(CurrentPath & "Ausgabe\") Then MkDir CurrentPath & "Ausgabe\"
'If Not FileExists(tTmp) Then UnBLOB "BriefTab", tTmp

'savall_Secure

DoCmd.Hourglass True

'Neu 9.6.2014
If Len(Trim(Nz(Me.Parent!AuftragsStammID))) > 0 Then
    strSQL = ""
    strSQL = strSQL & "Update tblBew_AuftragsStamm SET"
    strSQL = strSQL & " Name1 = '" & fCnvQM(Me!Name1) & "'"
    strSQL = strSQL & " WHERE (((AuftragsStammID)= " & Me.Parent!AuftragsStammID & "));"
    CurrentDb.Execute (strSQL)
    For i = 2 To 16 Step 2
        If Me("ReBlock" & i) = "Baustelle" And Len(Trim(Nz(Me("ReBlock" & (i + 1))))) > 0 Then
            strSQL = ""
            strSQL = strSQL & "Update tblBew_AuftragsStamm SET"
            strSQL = strSQL & " MV_Baustelle = '" & fCnvQM(Nz(Me("ReBlock" & (i + 1)))) & "'"
            strSQL = strSQL & " WHERE (((AuftragsStammID)= " & Me.Parent!AuftragsStammID & "));"
            CurrentDb.Execute (strSQL)
        End If
        If Me("ReBlock" & i) = "Abholer" And Len(Trim(Nz(Me("ReBlock" & (i + 1))))) > 0 Then
            strSQL = ""
            strSQL = strSQL & "Update tblBew_AuftragsStamm SET"
            strSQL = strSQL & " Abholer = '" & fCnvQM(Nz(Me("ReBlock" & (i + 1)))) & "'"
            strSQL = strSQL & " WHERE (((AuftragsStammID)= " & Me.Parent!AuftragsStammID & "));"
            CurrentDb.Execute (strSQL)
        End If
    Next i
End If
DoEvents

On Error Resume Next
Set wdApp = GetObject(, "Word.Application")
If wdApp Is Nothing Then
    Err.clear
    Set wdApp = CreateObject("Word.Application")
End If
On Error GoTo 0

strVorlagePfad = TLookup("Pfad", "_tblEigeneFirma_Pfade", "FirmenID = 1 AND PfadArt = 'Vorlagen'")
If Me!IstVordruck = True Then ' Vorlage vorhanden
    i = 2
Else
    i = 1
End If
tTmp = strVorlagePfad & TLookup("Docx_Name", "_tblEigeneFirma_Word_BriefVorlagen", "ID = " & i)
Set wdDoc = wdApp.Documents.Add(tTmp)

'wdApp.Visible = False
wdApp.Visible = True
'wdApp.ScreenUpdating = False   ' buggy - dont use
'wdApp.Visible = False

j = Nz(TCount("AuftragsPosID", "tblBew_AuftragPos", "AuftragsStammID = " & Me!AuftragsStammID & " AND ArtikelArtID = 2"), 0)

recsetSQL1 = "SELECT I1, I2, I3, I4, I5, I6, I7 FROM _tblEigeneFirma_Auftragsschritte WHERE AuftragsschrittID = " & Me!AuftragsschrittID
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
wdApp.Selection.GoTo What:=wdGoToBookmark, Name:="PosPgmStart"
If ArrFill_DAO_OK1 Then
    For iCol = 0 To iColMax1
        i = Nz(DAOARRAY1(iCol, 0), 0)
        If i > 0 Then
            If (i <> 6) Or (i = 6 And j > 0) Then
                strdoc = strVorlagePfad & TLookup("Docx_Name", "_tblEigeneFirma_Word_BriefVorlagen", "ID = " & i)
                wdApp.Documents.Open fileName:=strdoc, _
                    ConfirmConversions:=True, ReadOnly:=False, AddToRecentFiles:=False, PasswordDocument:="", _
                    PasswordTemplate:="", Revert:=False, WritePasswordDocument:="", _
                    WritePasswordTemplate:="", Format:=wdOpenFormatAuto, XMLTransform:=""
                wdApp.Selection.WholeStory
                wdApp.Selection.Copy
                wdApp.ActiveWindow.Close
                wdApp.Selection.EndKey Unit:=wdStory
                wdApp.Selection.PasteAndFormat (wdUseDestinationStylesRecovery)
            End If
        End If
    Next iCol
    Set DAOARRAY1 = Nothing
End If

'                    If .ActiveDocument.Bookmarks.Exists(STextmarke) = True Then
'                        If Not SFeldName = "Betrifft" Then
'                            If ControlExist(Forms(strOpenargs), SFeldName) Then


strSavDoc = Me!DocNamePfad

wdApp.ActiveDocument.SaveAs2 Chr(34) & strSavDoc & Chr(34)
Set wdDoc = wdApp.ActiveDocument

Call WordKopf_Setzen

If (Me!AuftragsschrittID < 20) Or (Me!AuftragsschrittID >= 23) Then

    strBookm = "PosFussErkl"
    strInhalt = Nz(TLookup("PosFussErkl", "_tblEigeneFIrma", "FirmenID = 1"))
    wdDoc.Bookmarks(strBookm).Select
    wdApp.Selection.InsertAfter strInhalt

End If

''' Nur zum Test
'''#############
''    wdApp.ActiveWindow.View.Type = wdPrintView
''    wdApp.ScreenUpdating = True   '  buggy - dont use
''    wdApp.Activate
''    wdApp.Visible = True
''    wdApp.Activate
''    DoCmd.Hourglass False
''
''    Stop
'''#############

Call WordPos

''' Nur zum Test
'''#############
''    wdApp.ActiveWindow.View.Type = wdPrintView
''    wdApp.ScreenUpdating = True   '  buggy - dont use
''    wdApp.Activate
''    wdApp.Visible = True
''    wdApp.Activate
''    DoCmd.Hourglass False
''
''    Stop
'''#############

wdDoc.SaveAs2 Chr(34) & strSavDoc & Chr(34)

'i = Nz(TMax("AuftragsschrittID", "_tblEigeneFirma_Auftragsschritte", "AuftragsArtID = " & Me!AuftragsartID), 0)
j = Me!AuftragsschrittID
'If i > j Then
'    j = j + 1
'End If
If Me!AuftragsschrittID <> 26 Then
    i = Nz(TLookup("Auftragsstatus", "_tblEigeneFirma_Auftragsschritte", "AuftragsschrittID = " & j), 0)

    strSQL = ""
    strSQL = strSQL & "UPDATE tblBew_AuftragsStamm SET"
    strSQL = strSQL & " AktStatusID = " & i & ","
    strSQL = strSQL & " AuftragsschrittID = " & j & ","
    strSQL = strSQL & " Aend_von = atcnames(1), Aend_am = Now()"
    strSQL = strSQL & " WHERE (((AuftragsStammID)= " & Me!AuftragsStammID & ")"
    strSQL = strSQL & " AND ((AktStatusID) <= " & Me.Parent!AuftragsstatusID & "));"
    CurrentDb.Execute (strSQL)
    DoEvents
    
    strSQL = ""
    strSQL = strSQL & "UPDATE tblBew_AuftragPos SET"
    strSQL = strSQL & " AktStatusID = " & i & ","
    strSQL = strSQL & " Aend_von = atcnames(1), Aend_am = Now()"
    strSQL = strSQL & " WHERE (((AuftragsStammID)= " & Me!AuftragsStammID & ")"
    strSQL = strSQL & " AND ((AktStatusID) <= " & Me.Parent!AuftragsstatusID & "));"
    CurrentDb.Execute (strSQL)
    DoEvents
End If

If i = 8 Then
    strSQL = ""
    strSQL = strSQL & "UPDATE tblBew_AuftragsStamm SET"
    strSQL = strSQL & " EndRechnungsDatum = Now()"
    strSQL = strSQL & " WHERE (((AuftragsStammID)= " & Me!AuftragsStammID & ")"
    strSQL = strSQL & " AND ((AktStatusID) <= " & Me.Parent!AuftragsstatusID & "));"
    CurrentDb.Execute (strSQL)
    DoEvents
End If
DoCmd.Hourglass False

''''''''''wdApp.ScreenUpdating = True  '  buggy - dont use
wdApp.ActiveWindow.SplitVertical = 0
wdApp.ActiveWindow.view.Type = wdPrintView
wdApp.Visible = True

wdApp.ActiveWindow.view.Type = wdPrintView
wdApp.ScreenUpdating = True   '  buggy - dont use
wdApp.Activate
wdApp.Visible = True
wdApp.Activate
'
'DoEvents

Set wdApp = Nothing

On Error Resume Next

DoEvents
DBEngine.Idle dbFreeLocks
DBEngine.Idle dbRefreshCache

'Form_frmHlp_AuftragsErfassung.GetHomeToMummy


End Sub

Function WordPos()

' ##################################################################################
' ###### 21.07.2014 - Punkt 57 - Alle Rabattprozent-Ausgaben ohne Nachkommastellen #
' ###### FormatPercent(Nz([RabPrz],0),0)) as rab                                   #
' ##################################################################################

Dim strSQL As String
Dim strSQLMi As String
Dim i As Long
Dim j As Long
Dim Betr As String
Dim bIstManuell As Boolean

Dim i1 As Long
Dim i2 As Long

Dim db_Z_von As Double
Dim db_Z_bis As Double

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long
Dim ArrFill_DAO_OK2 As Boolean, recsetSQL2 As String, iZLMax2 As Long, iColMax2 As Long, DAOARRAY2, DAOARRAY_Name2, iZl2 As Long, iCol2 As Long

Dim IstMonatsPreiskalk As Boolean
Dim str_prp_Word_MonRechText As String

strSQL = ""

CurrentDb.Execute ("DELETE * FROM tmptbl_qryBew_Auftragspos;")
   
' ###########################################################################################################
' #### Neu 31.08.2014
' #### qryBew_AuftragsPos_TR - enthält die um die bereits gezahlten TR verminderte Rech_Menge und Beträge ###
' ###########################################################################################################

If Get_Priv_Property("prp_gl_Teilrech_ID") > 0 And Get_Priv_Property("prp_gl_Teilrech") = True Then
    ' wenn Teilrechnung
    strSQL = "INSERT INTO tmptbl_qryBew_Auftragspos SELECT * FROM qryBew_AuftragsPos_TR_Teilrechnung"
Else
    'strSQL = "INSERT INTO tmptbl_qryBew_Auftragspos SELECT * FROM qryBew_AuftragsPos"
    strSQL = "INSERT INTO tmptbl_qryBew_Auftragspos SELECT * FROM qryBew_AuftragsPos_TR"
    strSQL = strSQL & " WHERE (((AuftragsStammID)= " & Me!AuftragsStammID & "));"
End If

CurrentDb.Execute (strSQL)

bIstManuell = False
Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM tmptbl_qryBew_Auftragspos;")
With rst
    Do Until .EOF
        If .fields("RabManuell") = True Then
           bIstManuell = True
           .MoveNext
        End If
        If Not .EOF Then
            If .fields("IstFolgeArtikel") = "*" And bIstManuell = True Then
                .Edit
                    .fields("RabManuell") = True
                .update
            Else
               bIstManuell = False
            End If
            .MoveNext
        End If
    Loop
    .Close
End With
Set rst = Nothing
DoEvents

' Mietpreis pro Tag = Einzelpreis bei Artikel 45900 setzen
CurrentDb.Execute ("qry_Update_Mietpreis_Tag_45900")

' Mietpreis pro Tag = Einzelpreis bei Verkaufsartikeln (ArtikelArtID = 1) setzen
CurrentDb.Execute ("UPDATE tmptbl_qryBew_Auftragspos SET tmptbl_qryBew_Auftragspos.Mietpreis_Tag = [EzPreis] WHERE (((tmptbl_qryBew_Auftragspos.ArtikelArtID)=1));")

' Kundenspezifische Artikelnr und Bezeichnung verwenden
strSQL = ""
strSQL = strSQL & "UPDATE tmptbl_qryBew_Auftragspos INNER JOIN tblStamm_KundeSpezArtikelNr"
strSQL = strSQL & " ON (tmptbl_qryBew_Auftragspos.kun_ID = tblStamm_KundeSpezArtikelNr.kun_ID)"
strSQL = strSQL & " AND (tmptbl_qryBew_Auftragspos.a_strArtikelID = tblStamm_KundeSpezArtikelNr.a_strArtikelID)"
strSQL = strSQL & " SET tmptbl_qryBew_Auftragspos.a_strArtikelID = [ak_strArtikelID],"
strSQL = strSQL & " tmptbl_qryBew_Auftragspos.a_bez1 = [ak_Bezeichnung1],"
strSQL = strSQL & " tmptbl_qryBew_Auftragspos.a_Bez2 = [ak_Bezeichnung2];"

CurrentDb.Execute (strSQL)

strSQL = ""
strSQLMi = ""
    
Select Case Me!AuftragsschrittID

    Case 2  ' Mietvertrag ** Artikel-Nr. Bezeichnung / Leistung  ME  Miet-Menge   Mietpreis € Stück / Tag Rechn.-Menge Mietzeit Mon./ Tag   Mietpreis  pro Einh € Rab.%   Pos.Preis €
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, Menge, Mietpreis_Tag, x,x,EzPreis, RabPrz
        
        'Zaehlerstand in Beschreibung
        CurrentDb.Execute ("qry_Update_ZaehlerArtikeltmp_nurStart")
        DoEvents
        
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] = 0, '', Format([a_strArtikelID],'@@-@@')), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', [a_Mengeneinheit]) as MengEH, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz([Menge] ,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID]  Not IN (1, 2), '',  FormatNumber(Nz([Mietpreis_Tag], 0),2)) as MietprTag, "
        strSQL = strSQL & " '' as x1, '' as x2, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0 OR [RabManuell] = 0, '', FormatNumber(Nz([EzPreis], 2))) as ezpr, "
        strSQL = strSQL & " iif([RabPrz] = 0  OR [RabManuell] = 0, '', FormatPercent(Nz([RabPrz],0),0)) as rab"
'        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID <> 1 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"

    Case 4     ' Mietrücknameschein (Menge, Einzelpreis, Zeit) **
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, Menge, Mietpreis_Tag, M_Rechn_Menge, (kalk Zeitraum), EzPreis, RabPrz
        
        'Zaehlerstand in Beschreibung
        CurrentDb.Execute ("qry_Update_ZaehlerArtikeltmp")
        DoEvents
        
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] = 0, '', Format([a_strArtikelID],'@@-@@')), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] <> 2 , '', FormatNumber(Nz([Menge], 0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID]  Not IN (1, 2), '',  FormatNumber(Nz([Mietpreis_Tag], 0),2)) as MietprTag, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz([M_Rechn_Menge], 0), 1)) as RchMenge ,"
        strSQL = strSQL & " iif([ArtikelArtID] Not IN (1, 2), '', cstr(Nz([Anz_Monat], 0)) & ' / ' & cstr(Nz([Anz_RestTage], 0))) as Ztraum, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0 OR [RabManuell] = 0, '', FormatNumber(Nz([EzPreis], 0),2)) as ezpr, "
        strSQL = strSQL & " iif([RabPrz] = 0 OR [RabManuell] = 0, '', FormatPercent(Nz([RabPrz],0),0)) as rab"
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID > 0 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
    
    Case 5, 26  ' Mietrechnungsschreibung, Teilrechnung
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, M_Rechn_Menge, EzPreis, Brutto, RabPrz, Netto
             
        'Zaehlerstand in Beschreibung
        CurrentDb.Execute ("qry_Update_ZaehlerArtikeltmp")
        CurrentDb.Execute ("qry_Update_Zaehlerstand_Artikel")
               
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] = 0, '', Format([a_strArtikelID],'@@-@@')), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(M_Rechn_Menge,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Mietpreis_Tag, 0),2)) as ezpr, "
'        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Ezpreis, 0),2)) as ezpr, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Brutto, 0),2)) as brut, "
        strSQL = strSQL & " iif([RabPrz] = 0, '', FormatPercent(Nz(RabPrz,0),0)) as rab, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Netto, 0),2)) as nett "
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID > 0 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
'        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        
        i1 = TCount("*", "qryBew_MietPosTab2", "AuftragsStammID = " & Me!AuftragsStammID)
        i2 = TCount("*", "qryBew_MietPosTab3", "AuftragsStammID = " & Me!AuftragsStammID)
        
        If i2 < i1 Then
            strSQLMi = ""
            strSQLMi = strSQLMi & "SELECT Format([a_strArtikelID],'@@-@@') , MV_Baustelle, NrKreisLfdNr, FormatDateTime([MV_von], 2), FormatDateTime([MV_Bis],2), FormatNumber(Nz(Anz_Monat,0), 0) as iAnz_Monat, FormatNumber(Nz(Anz_RestTage,0), 0) as iAnz_Resttage, FormatNumber(Nz(Anz_Korr_Tage,0), 0) as iAnz_Korr_Tage,  FormatNumber(Nz(Menge,0), 1) as Mg1 "
            strSQLMi = strSQLMi & " FROM qryBew_MietPosTab2 WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        Else
            strSQLMi = ""
            strSQLMi = strSQLMi & "SELECT Format([a_strArtikelID],'@@-@@') , MV_Baustelle, NrKreisLfdNr, FormatDateTime([MV_von], 2), FormatDateTime([MV_Bis],2), FormatNumber(Nz(Anz_Monat,0), 0) as iAnz_Monat, FormatNumber(Nz(Anz_RestTage,0), 0) as iAnz_Resttage, FormatNumber(Nz(Anz_Korr_Tage,0), 0) as iAnz_Korr_Tage,  FormatNumber(Nz(Menge,0), 1) as Mg1 "
            strSQLMi = strSQLMi & " FROM qryBew_MietPosTab3 WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        End If
    
    Case 7  ' Verkaufsartikel Ausgabe - Lieferschein
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, Menge, EzPreis, x, RabPrz
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] = 0, '', Format([a_strArtikelID],'@@-@@')), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Menge,0), 1)) as Mg1 , "
        strSQL = strSQL & " iif([ArtikelArtID] IN (0, 5) OR [RabManuell] = 0, '', FormatNumber(Nz(EzPreis, 0),2)) as ezpr, '' as x1,"
        strSQL = strSQL & " iif([ArtikelArtID] IN (0, 5) OR [RabManuell] = 0, '', FormatPercent (Nz(RabPrz , 0),0)) as rab "
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"

    Case 8, 10, 23  ' Rechnungsschreibung (Normal / Bar / Reparatur) sowie Bestellung
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, M_Rechn_Menge, EzPreis, Brutto, RabPrz, Netto
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] = 0, '', Format([a_strArtikelID],'@@-@@')), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(M_Rechn_Menge,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(EzPreis, 0),2)) as ezpr, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Brutto, 0),2)) as brut, "
        strSQL = strSQL & " iif([RabPrz] = 0, '', FormatPercent(Nz(RabPrz,0),0)) as rab, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Netto, 0),2)) as nett "
'        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID > 0 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"

    Case 12 ' Reparaturschein Annahme
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, Menge, EzPreis, x1, Rab
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] not in (0, 5), Format([a_strArtikelID],'@@-@@') , ''), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Menge,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID] IN (0, 5) OR [RabManuell] = 0, '', FormatNumber(Nz(EzPreis, 0),2)) as ezpr, '' as x1,"
        strSQL = strSQL & " iif([ArtikelArtID] IN (0, 5) OR [RabManuell] = 0, '', FormatPercent (Nz(RabPrz , 0),0)) as rab "
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID > 0 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"

    Case 14 ' Reparaturschein Rückgabe
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, Menge, EzPreis, x1, Rab
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] not in (0, 5), Format([a_strArtikelID],'@@-@@') , ''), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(M_Rechn_Menge,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID] IN (0, 5) OR [RabManuell] = 0, '', FormatNumber(Nz(EzPreis, 0),2)) as ezpr, '' as x1, "
        strSQL = strSQL & " iif([ArtikelArtID] IN (0, 5) OR [RabManuell] = 0, '', FormatPercent (Nz(RabPrz , 0),0)) as rab "
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
    
    Case 15  ' Reparaturrechnungsschreibung
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, M_Rechn_Menge, EzPreis, Brutto, RabPrz, Netto
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] not in (0, 5), Format([a_strArtikelID],'@@-@@') , ''), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(M_Rechn_Menge,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(EzPreis, 0),2)) as ezpr, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz (Brutto, 0),2)) as brut, "
        strSQL = strSQL & " iif([RabPrz] = 0, '', FormatPercent(Nz(RabPrz,0),0)) as rab, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Netto, 0),2)) as nett "
'        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID > 0 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
    
    Case 17 ' Angebot
            '  a_strArtikelID, a_bez1, a_Mengeneinheit, M_Rechn_Menge, EzPreis, Brutto, RabPrz, Netto
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] = 0, '', Format([a_strArtikelID],'@@-@@')), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(M_Rechn_Menge,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(EzPreis, 0),2)) as ezpr, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Brutto, 0),2)) as brut, "
        strSQL = strSQL & " iif([RabPrz] = 0, '', FormatPercent(Nz(RabPrz,0),0)) as rab, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Netto, 0),2)) as nett "
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID > 0 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        
        strSQLMi = ""
        strSQLMi = strSQLMi & "SELECT Format([a_strArtikelID],'@@-@@') , MV_Baustelle, NrKreisLfdNr, FormatDateTime([MV_von], 2), FormatDateTime([MV_Bis],2), FormatNumber(Nz(Anz_Monat,0), 0) as iAnz_Monat, FormatNumber(Nz(Anz_RestTage,0), 0) as iAnz_Resttage, FormatNumber(Nz(Anz_Korr_Tage,0), 0) as iAnz_Korr_Tage,  FormatNumber(Nz(Menge,0), 1) as Mg1 "
        strSQLMi = strSQLMi & " FROM qryBew_MietPosTab2 WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
    
    Case 19 ' Gutschrift
            '  a_strArtikelID, a_bez1 a_Mengeneinheit, M_Rechn_Menge, EzPreis, Brutto, RabPrz, Netto
        strSQL = ""
        strSQL = strSQL & "SELECT iif([ArtikelArtID] = 0, '', Format([a_strArtikelID],'@@-@@')), "
        strSQL = strSQL & " IIf(Len(Trim(Nz([a_bez2])))>0,Trim(Nz([a_Bez1])) & Chr$(013) & Chr$(010) & Trim(Nz([a_Bez2])),Trim(Nz([a_Bez1]))) AS Bez, "
        strSQL = strSQL & " iif([a_Mengeneinheit] = 0, '', a_Mengeneinheit), "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(M_Rechn_Menge,0), 1)) as Mg1, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(EzPreis, 0),2)) as ezpr, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Brutto, 0),2)) as brut, "
        strSQL = strSQL & " iif([RabPrz] = 0, '', FormatPercent(Nz(RabPrz,0),0)) as rab, "
        strSQL = strSQL & " iif([ArtikelArtID] = 0, '', FormatNumber(Nz(Netto, 0),2)) as nett "
        strSQL = strSQL & " FROM qryBew_AuftragsPos_tmp WHERE ArtikelArtID > 0 AND AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
        
        strSQLMi = ""
        strSQLMi = strSQLMi & "SELECT Format([a_strArtikelID],'@@-@@') , MV_Baustelle, NrKreisLfdNr, FormatDateTime([MV_von], 2), FormatDateTime([MV_Bis],2), FormatNumber(Nz(Anz_Monat,0), 0) as iAnz_Monat, FormatNumber(Nz(Anz_RestTage,0), 0) as iAnz_Resttage, FormatNumber(Nz(Anz_Korr_Tage,0), 0) as iAnz_Korr_Tage,  FormatNumber(Nz(Menge,0), 1) as Mg1 "
        strSQLMi = strSQLMi & " FROM qryBew_MietPosTab2 WHERE AuftragsStammID = " & Me!AuftragsStammID & " ORDER BY PosNr;"
    
    Case 20, 21  ' Brief Kunde
    '  schon alles erledigt, keine Positionen
    
    'Case 21 ' Brief Lieferant
    'Case 23 ' Lieferantenbestellung
    
    Case Else

End Select

If Len(Trim(Nz(strSQL))) > 0 Then
    recsetSQL1 = strSQL
    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
    'Tabelle TabPos
    If ArrFill_DAO_OK1 Then
        i = 2
        Set wdTab = wdDoc.Bookmarks("TabPos").Range.tables(1)
        For iZl = 0 To iZLMax1
            i = i + 1
            For j = 0 To iColMax1
                wdTab.Cell(i, j + 1).Range.Text = Nz(DAOARRAY1(j, iZl))
            Next j
            If iZl < iZLMax1 Then
                wdTab.rows.Add
            End If
        Next iZl
        Set DAOARRAY1 = Nothing
    End If
    
    'Nur bei Miete und wenn Mietpositionen vorhanden sind
    'Tabelle TabPos_M
    If Len(Trim(Nz(strSQLMi))) > 0 Then
    
        ' IstMonatsPreiskalk wird in Function Preiscalc_Vermiet auf true gesetzt, wenn Monatsberechnung --- Punkt 91  14.11.2014
        IstMonatsPreiskalk = TLookup("IstMonatsPreiskalk", "tblBew_AuftragsStamm", "AuftragsStammID = " & Me!AuftragsStammID)
        str_prp_Word_MonRechText = Get_Priv_Property("prp_Word_MonRechText")

        If IstMonatsPreiskalk = True Then
            wdApp.Selection.GoTo What:=wdGoToBookmark, Name:="TabPos_M"
            With wdApp.ActiveDocument.Bookmarks
                .DefaultSorting = wdSortByName
                .ShowHidden = False
            End With
            wdApp.Selection.MoveLeft Unit:=wdCharacter, Count:=2
            wdApp.Selection.TypeParagraph
            wdApp.Selection.TypeParagraph
            wdApp.Selection.MoveUp Unit:=wdLine, Count:=1
            wdApp.Selection.Font.Italic = wdToggle
            wdApp.Selection.TypeText Text:=str_prp_Word_MonRechText
            wdApp.Selection.Font.Italic = wdToggle
        End If
   
        recsetSQL2 = strSQLMi
        ArrFill_DAO_OK2 = ArrFill_DAO_Acc(recsetSQL2, iZLMax2, iColMax2, DAOARRAY2)
        'Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
        If ArrFill_DAO_OK2 Then
            i = 2
            Set wdTab = wdDoc.Bookmarks("TabPos_M").Range.tables(1)
            For iZl2 = 0 To iZLMax2
                i = i + 1
                For iCol2 = 0 To iColMax2
                    wdTab.Cell(i, iCol2 + 1).Range.Text = Nz(DAOARRAY2(iCol2, iZl2))
                Next iCol2
                If iZl2 < iZLMax2 Then
                    wdTab.rows.Add
                End If
            Next iZl2
            Set DAOARRAY2 = Nothing
        End If
    End If
End If

If Get_Priv_Property("prp_gl_Teilrech_ID") > 0 And Get_Priv_Property("prp_gl_Teilrech") = True Then
    strSQL = ""
    strSQL = strSQL & "UPDATE tblBew_AuftragsStamm SET IstTeilberechnet = -1, LetzteTeilberechnungAm = Now()"
    strSQL = strSQL & " WHERE AuftragsStammID = " & Me!AuftragsStammID & ";"
    
    CurrentDb.Execute (strSQL)
End If

Call Set_Priv_Property("prp_gl_Teilrech_ID", 0)
Call Set_Priv_Property("prp_gl_Teilrech", 0)


End Function

Function WordKopf_Setzen()

Dim i As Long
Dim bisdate As Boolean

Dim strName1 As String

Dim strBookm As String
Dim strInhalt As String
Dim strdoc As String
Dim strSavDoc As String
Dim strFussReBlock18 As String

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, DAOARRAY_Name1, iZl As Long, iCol As Long

recsetSQL1 = "SELECT Textmarke FROM _tblEigeneFirma_Word_TextmarkeZuord WHERE FirmenID = 1;"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)

If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        strBookm = DAOARRAY1(0, iZl)
        Select Case strBookm
            Case "MwStPrz"
                strInhalt = FormatPercent(Nz(Me(strBookm), 0), 1)
                bisdate = False
            
            Case "ZwSum", "MwStBetrag", "EndSum"
                strInhalt = FormatCurrency(Nz(Me(strBookm), 0))
                bisdate = False
                
            Case "ReBlock18"
                strInhalt = Nz(Me(strBookm))
                strFussReBlock18 = strInhalt
                
            Case Else
                strInhalt = Nz(Me(strBookm))
                If strInhalt = "Miete von" Or strInhalt = "Miete bis" Then
                    bisdate = True
                Else
                    If bisdate = True Then
                        strInhalt = Left(strInhalt, 10)
                        bisdate = False
                    End If
                End If
                        
        End Select
            
        If wdDoc.Bookmarks.Exists(strBookm) = True Then
            wdDoc.Bookmarks(strBookm).Select
            wdApp.Selection.InsertAfter strInhalt
        End If
    Next iZl
    Set DAOARRAY1 = Nothing
End If
    
strBookm = "FussReBlock18"
strInhalt = strFussReBlock18

If wdDoc.Bookmarks.Exists(strBookm) = True Then
    wdDoc.Bookmarks(strBookm).Select
    wdApp.Selection.InsertAfter strInhalt
End If
    
End Function


Private Sub Form_BeforeUpdate(Cancel As Integer)

On Error GoTo Form_BeforeUpdate_Err

' Erstellt am / von = Standardwert
        
Me!Aend_am = Now()
Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
        
Form_BeforeUpdate_Exit:
    Exit Sub

Form_BeforeUpdate_Err:
    MsgBox Error$
    Resume Form_BeforeUpdate_Exit

End Sub

Private Sub Form_Open(Cancel As Integer)
Call IstVordruck_AfterUpdate
End Sub

Private Sub FussZl_AfterUpdate()
Me!Fusstext = Me!FussZl.Column(1)
End Sub

Private Sub IstVordruck_AfterUpdate()
If Me!IstVordruck = True Then
    Me!IstVordruck.caption = "Auf Vordruck"
Else
    Me!IstVordruck.caption = "Kopf drucken"
End If
End Sub

Private Sub Zahlbed_AfterUpdate()
Dim zwtext As String
Dim i As Long
Dim zwcur As Currency
zwtext = Me!Zahlbed.Column(3)
i = Me!Zahlbed.Column(2)
If i > 0 Then
    zwtext = zwtext & " " & Format(Date + i, "short date", 2, 2) & " " & Me!Zahlbed.Column(4)
End If
If Len(Trim(Nz(Me!EndSum))) > 0 Then
    If Me!EndSum > 0 And Me!Zahlbed.Column(5) > 0 Then
        zwcur = fctround(Me!EndSum - (Me!EndSum * Me!Zahlbed.Column(5)))
        zwtext = zwtext & " " & Format(zwcur, "Currency")
        zwtext = zwtext & " " & Me!Zahlbed.Column(6)
    End If
End If
Me!Zahlungsbed = zwtext

End Sub

