VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_KD_Kundenstamm_alt"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim sfirst As String

Private Sub AuftrBemerk_Exit(Cancel As Integer)
On Error Resume Next
Me!sub_Bew_AuftragsStamm.Form!Bemerkungen = Me!AuftrBemerk
End Sub

Private Sub Befehl38_Click()
On Error Resume Next
DoCmd.Close acForm, Me.Name, acSaveNo
DoEvents
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub Befehl46_Click()
Dim i As Long
On Error Resume Next
DoCmd.RunCommand acCmdRecordsGoToNew
i = rstDMax("kun_id", "SELECT tbl_KD_Kundenstamm.kun_ID FROM tbl_KD_Kundenstamm")
Me!kun_ID = i + 1
End Sub

Private Sub BrfBemerk_Exit(Cancel As Integer)
On Error Resume Next
Me!sub_Bew_AuftragsStamm_Brief.Form!Bemerkungen = Me!BrfBemerk
End Sub

Private Sub btnAuftrag_Click()
DoCmd.OpenForm "frmHlp_AuftragsErfassung", , , , , , "Kde" & Me!kun_ID
End Sub


Private Sub btnAufRchPDF_Click()
fReadDoc 1
End Sub

Private Sub btnAufRchPosPDF_Click()
fReadDoc 2
End Sub

Private Sub btnAufEinsPDF_Click()
fReadDoc 3
End Sub

Function fReadDoc(i As Long)
Dim s As String
s = Get_Priv_Property("prp_kun_rch_pdf_s" & i)
Application.FollowHyperlink s
End Function


Private Sub btnAuswertung_Click()

    DoCmd.OpenForm "frm_kundenpreise_gueni"
    
End Sub


Private Sub btnNeuAttach_Click()
Dim iID As Long
Dim iTable As Long

iID = Me!kun_ID
iTable = Me!TabellenNr

Call f_btnNeuAttach(iID, iTable)

Me!sub_ZusatzDateien.Form.Requery

End Sub


Private Sub btnUmsAuswert_Click()
DoCmd.OpenForm "frm_Auswertung_Kunde_Jahr"
End Sub

Private Sub cbo_Auswahl_AfterUpdate()

Dim listselect As String
'
Select Case Me!NurAktiveKD

    Case 1 '
      Me!lst_KD = listselect = "SELECT kun_ID, Kun_name, Kun_ort" & ",  [Telefon]"
    Case 2 '
    Me!lst_KD = listselect = "SELECT kun_ID, Kun_name, Kun_ort" & ", [email]"
    Case 3 '
        Me!lst_KD = listselect = "SELECT kun_ID, Kun_name, Kun_ort" & ", [umsatz]"
    Case 4 '
         Me!lst_KD = listselect = "SELECT kun_ID, Kun_name, Kun_ort" & ","
    Case 5
         Me!lst_KD = listselect = "SELECT kun_ID, Kun_name, Kun_ort"

End Select
'NurAktiveMA_AfterUpdate
End Sub

Private Sub cboKDNrSuche_AfterUpdate()
Me.Recordset.FindFirst "kun_ID = " & Nz(Me!cboKDNrSuche.Column(0), 0)
End Sub

Private Sub Form_AfterUpdate()
Me!lst_KD.Requery
End Sub


Private Sub Form_Load()
Me!lbl_Version.Visible = True
Me!lbl_Version.caption = Get_Priv_Property("prp_V_FE") & " | " & Get_Priv_Property("prp_V_BE")
DoCmd.Maximize
End Sub

'Private Sub btnNeuAttach_Click()
'
'Dim iID As Long
'Dim iTable As Long
'
'iID = Me!kun_ID
'iTable = Me!TabellenNr
'
'Call f_btnNeuAttach(iID, iTable)
'
'Me!sub_ZusatzDateien.Form.Requery
'
'End Sub

Private Sub btnAlle_Click()
Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
Me!cboSuchOrt = "_ALLE"
Me!cboSuchPLZ = "_ALLE"
Me!cboSuchSuchF = "_ALLE"
End Sub


Private Sub IstAlle_AfterUpdate()
If Me!istAlle Then
    Me!istAlle.caption = "Alle anzeigen"
    Me.recordSource = "SELECT tbl_KD_Kundenstamm.* FROM tbl_KD_Kundenstamm ORDER BY tbl_KD_Kundenstamm.kun_Firma;"
Else
    Me!istAlle.caption = "Nur Aktive anzeigen"
    Me.recordSource = "SELECT tbl_KD_Kundenstamm.* FROM tbl_KD_Kundenstamm WHERE kun_IstAktiv = True ORDER BY tbl_KD_Kundenstamm.kun_Firma;"
End If
End Sub

Private Sub kun_AdressArt_DblClick(Cancel As Integer)
DoCmd.OpenForm "frmTop_KD_Adressart"
End Sub

Private Sub kun_IstAktiv_AfterUpdate()
On Error Resume Next
DoCmd.RunCommand acCmdSaveRecord
End Sub

Private Sub lst_KD_Click()

    Me.Recordset.FindFirst "kun_ID = " & Me!lst_KD
    Gl_Akt_KD_ID = Me!lst_KD
    DoEvents
    Call Set_Priv_Property("prp_Akt_KD_ID", Gl_Akt_KD_ID)
    DoEvents
 
    Call Standardleistungen_anlegen(Me!lst_KD)

End Sub

Private Sub NurAktiveKD_AfterUpdate()
If Me!NurAktiveKD = False Then
    Me.lbl_nur_aktive_anzeigen.caption = "Alle anzeigen"
    Me!lst_KD.RowSource = "SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Ansprechpartner.adr_Nachname, tbl_KD_Ansprechpartner.adr_Vorname, tbl_KD_Ansprechpartner.adr_Handy FROM tbl_KD_Kundenstamm LEFT JOIN tbl_KD_Ansprechpartner ON tbl_KD_Kundenstamm.kun_IDF_PersonID = tbl_KD_Ansprechpartner.adr_ID ORDER BY kun_firma;"
Else
    Me.lbl_nur_aktive_anzeigen.caption = "Nur Aktive anzeigen"
    Me!lst_KD.RowSource = "SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Ansprechpartner.adr_Nachname, tbl_KD_Ansprechpartner.adr_Vorname, tbl_KD_Ansprechpartner.adr_Handy FROM tbl_KD_Kundenstamm LEFT JOIN tbl_KD_Ansprechpartner ON tbl_KD_Kundenstamm.kun_IDF_PersonID = tbl_KD_Ansprechpartner.adr_ID WHERE kun_IstAktiv = TRUE ORDER BY kun_firma;"
End If

End Sub

Private Sub Textschnell_AfterUpdate()

Dim i As Integer

    Me.Recordset.FindFirst "kun_ID = " & Me!Textschnell.Column(0)
    'Listbox entmarkieren
    With Me.lst_KD
        For i = .ListCount - 1 To 1 Step -1
            .selected(i) = False
        Next i
'        'Eintrag markieren
        For i = 1 To .ListCount - 1
          If CLng(.Column(0, i)) = Me!Textschnell.Column(0) Then
             .selected(i) = True
             Exit For
          End If
        Next i
    End With
    Me!Textschnell = Null
    

End Sub


'Private Sub Textschnell_Exit(Cancel As Integer)
'Call btnGo_Click
'End Sub

'Private Sub btnGo_Click()
'
'If Len(Trim(Nz(Me!Textschnell))) = 0 Then Exit Sub
'
'If IsNumeric(Trim(Nz(Me!Textschnell))) Then
''    Me!kun_ID.SetFocus
''    If Len(Trim(Nz(Me!Textschnell))) = 0 Then Me!Textschnell = sfirst
''    DoCmd.FindRecord Me!Textschnell, acStart
'    Me.RecordSource = "SELECT * FROM tbl_KD_Kundenstamm WHERE [kun_ID] Like '*" & Me!Textschnell & "*';"
'Else
'    If TCount("kun_ID", "tbl_KD_Kundenstamm", "[kun_firma] Like '*" & Me!Textschnell & "*' OR [kun_bezeichnung] Like '*" & Me!Textschnell & "*'") > 0 Then
'        Me.RecordSource = "SELECT * FROM tbl_KD_Kundenstamm WHERE [kun_firma] Like '*" & Me!Textschnell & "*' OR [kun_bezeichnung] Like '*" & Me!Textschnell & "*';"
'    Else
'        Me.RecordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
'        MsgBox "Keine Datensätze vorhanden"
'    End If
'End If
'
'Me!Textschnell = ""
'
'Me!Textschnell.SetFocus
'
'End Sub

Private Sub IstAuftragsrt_AfterUpdate()

Me!GesUmsatz = Nz(TSum("ZwSum", "qrysub_Bew_Auftragsstamm_Auftrag", "AuftragsartID < 6 AND kun_ID = " & Me!kun_ID), 0)

Select Case Me!IstAuftragsArt
    Case 1 ' Alle
        Me!sub_Bew_AuftragsStamm.Form.recordSource = _
            "qrysub_Bew_Auftragsstamm_Auftrag"
            Me!SelektUmsatz = Nz(TSum("ZwSum", "qrysub_Bew_Auftragsstamm_Auftrag", "AuftragsartID < 6 AND kun_ID = " & Me!kun_ID), 0)

    Case 2 ' Miete
        Me!sub_Bew_AuftragsStamm.Form.recordSource = _
            "SELECT * FROM qrysub_Bew_Auftragsstamm_Auftrag WHERE AuftragsartID = 1 AND kun_ID = " & Me!kun_ID & _
            " ORDER BY AuftrDat DESC;"
            Me!SelektUmsatz = Nz(TSum("ZwSum", "qrysub_Bew_Auftragsstamm_Auftrag", "AuftragsartID = 1 AND kun_ID = " & Me!kun_ID), 0)

    Case 3 ' Verkauf
        Me!sub_Bew_AuftragsStamm.Form.recordSource = _
            "SELECT * FROM qrysub_Bew_Auftragsstamm_Auftrag WHERE (AuftragsartID = 2 OR AuftragsartID = 3) AND kun_ID = " & Me!kun_ID & _
            " ORDER BY AuftragsartID, AuftrDat DESC;"
            Me!SelektUmsatz = Nz(TSum("ZwSum", "qrysub_Bew_Auftragsstamm_Auftrag", "(AuftragsartID = 2 OR AuftragsartID = 3) AND kun_ID = " & Me!kun_ID), 0)

    Case 4 ' Reparatur
        Me!sub_Bew_AuftragsStamm.Form.recordSource = _
            "SELECT * FROM qrysub_Bew_Auftragsstamm_Auftrag WHERE AuftragsartID = 4 AND kun_ID = " & Me!kun_ID & _
            " ORDER BY AuftrDat DESC;"
            Me!SelektUmsatz = Nz(TSum("ZwSum", "qrysub_Bew_Auftragsstamm_Auftrag", "AuftragsartID = 4 AND kun_ID = " & Me!kun_ID), 0)

    Case 5  ' Datum
        Me!sub_Bew_AuftragsStamm.Form.recordSource = _
            "SELECT * FROM qrysub_Bew_Auftragsstamm_Auftrag WHERE kun_ID = " & Me!kun_ID & " AND AuftrDat >= " & _
               SQLDatum(Me!dtvon) & " AND AuftrDat <= " & SQLDatum(Me!dtbis) & " ORDER BY AuftragsartID, AuftrDat DESC;"
            Me!SelektUmsatz = Nz(TSum("ZwSum", "qrysub_Bew_Auftragsstamm_Auftrag", "kun_ID = " & Me!kun_ID & " AND AuftrDat >= " & _
               SQLDatum(Me!dtvon) & " AND AuftrDat <= " & SQLDatum(Me!dtbis)), 0)

    Case Else
End Select
Me!sub_Bew_AuftragsStamm.Form.Requery

End Sub

Private Sub btnDate_Click()
    Me!IstAuftragsArt = 5
    Call IstAuftragsrt_AfterUpdate
End Sub


Private Sub btnOutlook_Click()
DoCmd.OpenForm "frmOff_Outlook aufrufen", , , , , , Me.Name
End Sub

Private Sub btnPersonUebernehmen_Click()

Dim strSQL As String

If Len(Trim(Nz(Me!cboPerson))) > 0 Then
    strSQL = ""
    strSQL = strSQL & "INSERT INTO _tbl_AdrZuord ( Adrzuo_TabellenNr, Adrzuo_Stamm_ID, Adrzuo_Adr_ID )"
    strSQL = strSQL & " SELECT " & Me!TabellenNr & " AS Ausdr1, " & Me!kun_ID & " AS Ausdr2, " & Me!cboPerson & " AS Ausdr3"
    strSQL = strSQL & " FROM _tblHilfLfdNr WHERE ((([_tblHilfLfdNr].Feld1)=1));"
    CurrentDb.Execute strSQL
    Me!cboPerson = Nothing
    Me!sub_Ansprechpartner.Form.Requery
End If

End Sub

Private Sub btnWord_Click()
DoCmd.OpenForm "frmOff_WinWord_aufrufen", , , , , , Me.Name
End Sub

Private Sub cboSuchOrt_AfterUpdate()
Select Case Me!cboSuchOrt
    Case "_ALLE" ' Alle
        Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
    Case Else
        If TCount("kun_ID", "tbl_KD_Kundenstamm", "kun_LKZ = 'D' AND kun_ort = '" & Me!cboSuchOrt & "'") > 0 Then
            Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_LKZ = 'D' AND kun_ort = '" & Me!cboSuchOrt & "' ;"
        Else
            Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
            Me!cboSuchOrt = "_ALLE"
            MsgBox "Keine Datensätze vorhanden"
        End If

End Select
Me!cboSuchPLZ = "_ALLE"
Me!cboSuchSuchF = "_ALLE"
End Sub

Private Sub cboSuchPLZ_AfterUpdate()
Select Case Me!cboSuchPLZ
    Case "_ALLE" ' Alle
        Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
    Case Else
        If TCount("kun_ID", "tbl_KD_Kundenstamm", "kun_LKZ = 'D' AND kun_plz = '" & Me!cboSuchPLZ & "'") > 0 Then
            Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_LKZ = 'D' AND kun_plz = '" & Me!cboSuchPLZ & "' ;"
        Else
            Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
            Me!cboSuchPLZ = "_ALLE"
            MsgBox "Keine Datensätze vorhanden"
        End If

End Select
Me!cboSuchOrt = "_ALLE"
Me!cboSuchSuchF = "_ALLE"

End Sub

Private Sub cboSuchSuchF_AfterUpdate()
Select Case Me!cboSuchSuchF
    Case "_ALLE" ' Alle
        Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
    Case Else
        If TCount("kun_ID", "tbl_KD_Kundenstamm", "kun_Sortfeld = '" & Me!cboSuchSuchF & "'") > 0 Then
            Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_Sortfeld = '" & Me!cboSuchSuchF & "' ;"
        Else
            Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
            Me!cboSuchSuchF = "_ALLE"
            MsgBox "Keine Datensätze vorhanden"
        End If

End Select
Me!cboSuchOrt = "_ALLE"
Me!cboSuchPLZ = "_ALLE"

End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)

On Error Resume Next

        AdrUpd

        ' Erstellt am / von = Standardwert

        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo

End Sub

Function AdrUpd()

Dim strAdr As String
Dim strAnspr As String

If Me!kun_ans_manuell = False And Me.Dirty Then
    strAnspr = Nz(Me!kun_bezeichnung)
    If Len(Trim(Nz(strAnspr))) > 0 Then
        strAnspr = strAnspr & vbNewLine
    End If
    If Len(Trim(Nz(Me!kun_IDF_PersonID.Column(5)))) > 0 Then
        strAnspr = strAnspr & Me!kun_IDF_PersonID.Column(5) & vbNewLine
    End If
    strAdr = Me!kun_firma & vbNewLine & strAnspr & Me!kun_strasse & vbNewLine & vbNewLine
    If Len(Trim(Nz(Me!kun_LKZ))) = 0 Or Me!kun_LKZ = "DE" Then
        strAdr = strAdr & Me!kun_plz & " " & Me!kun_ort
    Else
        strAdr = strAdr & Me!kun_plz & " " & Me!kun_ort & vbNewLine & Me!kun_LKZ
    End If
    Me!kun_BriefKopf = strAdr
End If

End Function

Private Sub Form_Close()
Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
End Sub

Private Sub Form_Current()
On Error Resume Next
Dim i As Long

If Len(Trim(Nz([Me!kun_ID]))) > 0 Then
    Call Set_Priv_Property("prp_Stamm_ID", Me!kun_ID)
    Me!kun_IDF_PersonID.Requery
    DoEvents
    Me!adr_telefon = Me!kun_IDF_PersonID.Column(1)
    Me!adr_mobil = Me!kun_IDF_PersonID.Column(2)
    Me!adr_eMail = Me!kun_IDF_PersonID.Column(4)
    If Me.Dirty Then
        Me!Anschreiben = Me!kun_IDF_PersonID.Column(3)
    End If
Else
    i = Nz(TMax("kun_id", "tbl_KD_Kundenstamm"))
    Me!kun_ID = i + 1
End If
If Len(Trim(Nz(Me!Anschreiben))) = 0 Then
    Me!Anschreiben = Get_Priv_Property("prp_LeerAnrede")
End If

Me!KD_Ges = 0 + Nz(TSum("Zwi_Sum1", "qry_KD_Auftragskopf", "kun_ID = " & Me!kun_ID), 0)
i = (Year(Date) - 1)
Me!KD_VJ = 0 + Nz(TSum("Zwi_Sum1", "qry_KD_Auftragskopf", "RchJahr = " & i & " AND kun_ID = " & Me!kun_ID), 0)
i = (Year(Date))
Me!KD_LJ = 0 + Nz(TSum("Zwi_Sum1", "qry_KD_Auftragskopf", "RchJahr = " & i & " AND kun_ID = " & Me!kun_ID), 0)
i = (Month(Date))
Me!KD_LM = 0 + Nz(TSum("Zwi_Sum1", "qry_KD_Auftragskopf", "RchMon = " & i & " AND kun_ID = " & Me!kun_ID), 0)

'Me!btnAufRchPDF.Visible = False
'Me!btnAufRchPosPDF.Visible = False
'Me!btnAufEinsPDF.Visible = False

If Me!RegStammKunde.Pages(Me!RegStammKunde).Name = "pg_Rch_Kopf" Then
    Call Kopf_Berech
End If

'IstAuftragsArt_AfterUpdate
DoEvents
End Sub


Private Sub kun_bezeichnung_Exit(Cancel As Integer)
AdrUpd
End Sub

Private Sub kun_firma_Exit(Cancel As Integer)
AdrUpd
End Sub

Private Sub kun_IDF_PersonID_AfterUpdate()
Dim strAdr As String
Dim strAnspr As String

Me.Dirty = True
Me!adr_telefon = Me!kun_IDF_PersonID.Column(1)
Me!adr_mobil = Me!kun_IDF_PersonID.Column(2)
Me!Anschreiben = Me!kun_IDF_PersonID.Column(3)
Me!adr_eMail = Me!kun_IDF_PersonID.Column(4)

AdrUpd

End Sub

Private Sub kun_LKZ_AfterUpdate()
Me!kun_land_vorwahl = Me!kun_LKZ.Column(3)
End Sub

Private Sub kun_LKZ_Exit(Cancel As Integer)
AdrUpd
End Sub

Private Sub kun_ort_Exit(Cancel As Integer)
AdrUpd
End Sub

Private Sub kun_plz_Exit(Cancel As Integer)
AdrUpd
End Sub

Private Sub kun_strasse_Exit(Cancel As Integer)
AdrUpd
End Sub

Private Sub RegStammKunde_Change()

Dim strSQL As String
Dim i As Long
Dim rst As DAO.Recordset
Dim strCriteria As String
Dim j As Long

i = Me!RegStammKunde
Select Case Me!RegStammKunde.Pages(i).Name

  Case "pgMain"
    If Len(Trim(Nz(Me!kun_ID))) > 0 Then
        Application.Echo False
        j = Me!kun_ID
        Me.Requery
        Me!kun_ID.SetFocus
        DoCmd.FindRecord j, acStart
        Application.Echo True
        Me.Repaint
        Set rst = Nothing
    End If

  Case "pgBemerk"

      Me!kun_memo.SetFocus
      Me!kun_memo.SelStart = Len("" & Me!kun_memo)
      
  Case "pg_Rch_Kopf"
      Call Kopf_Berech

  Case Else

End Select

End Sub

Public Function Kopf_Berech()
Dim i As Long

Dim strWhere(1 To 3) As String
Dim strWHEREAuf(1 To 3) As String
Dim strWherekd As String
Dim strUmsWhere(1 To 3) As String

Dim strWhere1 As String
Dim strWhere2 As String
Dim strWhere3 As String

Dim strUmsWhere1 As String
Dim strUmsWhere2 As String
Dim strUmsWhere3 As String

strWherekd = "kun_ID = " & kun_ID
strWhere(1) = strWherekd
strWhere(2) = strWherekd & " AND VADatum BETWEEN " & SQLDatum(Date - 90) & " AND " & SQLDatum(Date)
strWhere(3) = strWherekd & " AND VADatum BETWEEN " & SQLDatum(Date - 30) & " AND " & SQLDatum(Date)

strWherekd = "Veranstalter_ID = " & kun_ID
strWHEREAuf(1) = strWherekd
strWHEREAuf(2) = strWherekd & " AND Dat_VA_Von BETWEEN " & SQLDatum(Date - 90) & " AND " & SQLDatum(Date)
strWHEREAuf(3) = strWherekd & " AND Dat_VA_Von BETWEEN " & SQLDatum(Date - 30) & " AND " & SQLDatum(Date)

strWherekd = "kun_ID = " & kun_ID
strUmsWhere(1) = strWherekd
strUmsWhere(2) = strWherekd & " AND IstBezahlt = False"
strUmsWhere(3) = strWherekd & " AND IstBezahlt = False AND ((M1IstGemahnt1 = True) OR (M2IstGemahnt1 = True) OR (M3IstGemahnt1 = True))"

'qry_Rch_Hlp_Stunden_Ges_Pro_Tag
'qry_Rch_Hlp_Stunden_Pro_VA
'qry_Rch_Hlp_Umsatz

For i = 1 To 3
    Me("AufAnz" & i) = Nz(TCount("*", "tbl_VA_Auftragstamm", strWHEREAuf(i)), 0)
    Me("PersGes" & i) = Nz(TCount("*", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", strWhere(i)), 0)
    Me("StdGes" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", strWhere(i)), 0)
    Me("UmsGes" & i) = Nz(TSum("NettoBetrag", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Netto", strWhere(i)), 0)
    Me("Std5" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 5 AND " & strWhere(i)), 0)
    Me("Std6" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 6 AND " & strWhere(i)), 0)
    Me("Std7" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 7 AND " & strWhere(i)), 0)
    Me("Pers5" & i) = Nz(TCount("*", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 5 AND " & strWhere(i)), 0)
    Me("Pers6" & i) = Nz(TCount("*", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 6 AND " & strWhere(i)), 0)
    Me("Pers7" & i) = Nz(TCount("*", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 7 AND " & strWhere(i)), 0)
    Me("UmsNGes" & i) = Nz(TSum("NettoBetrag", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Netto", strUmsWhere(i)), 0)
Next i

End Function
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

'Standardleistungen / Standardpreise anlegen
Function Standardleistungen_anlegen(kun_ID As Integer)

Dim sql   As String
Dim WHERE As String

On Error GoTo Err

    If Me.RegStammKunde = 1 Then
        WHERE = "kun_ID = " & kun_ID & " AND Preisart_ID = "
        sql = "INSERT INTO " & SPREISE & " (kun_ID, Preisart_ID) VALUES (" & kun_ID & ", "
    
        'Sicherheitspersonal
        If Nz(TLookup("ID", SPREISE, WHERE & "1"), 0) = 0 Then CurrentDb.Execute sql & "1)"
        
        'Leitungspersonal
        If Nz(TLookup("ID", SPREISE, WHERE & "3"), 0) = 0 Then CurrentDb.Execute sql & "3)"
        
        'Fahrtkosten
        If Nz(TLookup("ID", SPREISE, WHERE & "4"), 0) = 0 Then CurrentDb.Execute sql & "4)"
        
        'Sonstiges
        If Nz(TLookup("ID", SPREISE, WHERE & "5"), 0) = 0 Then CurrentDb.Execute sql & "5)"
        
        'Nachtzuschlag
        If Nz(TLookup("ID", SPREISE, WHERE & "11"), 0) = 0 Then CurrentDb.Execute sql & "11)"
        
        'Sonntagszuschlag
        If Nz(TLookup("ID", SPREISE, WHERE & "12"), 0) = 0 Then CurrentDb.Execute sql & "12)"
        
        'Feiertagszuschlag
        If Nz(TLookup("ID", SPREISE, WHERE & "13"), 0) = 0 Then CurrentDb.Execute sql & "13)"
        
        Me.sub_KD_Standardpreise.Requery
        
    End If
    
    Exit Function

Err:
    MsgBox "Funktion nicht möglich!", vbCritical
    
End Function
