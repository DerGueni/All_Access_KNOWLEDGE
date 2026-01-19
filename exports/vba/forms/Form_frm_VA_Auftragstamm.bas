VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_VA_Auftragstamm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
 
 Option Compare Database
Option Explicit

Dim datbis_vgl            As Date


'
'Private Sub Befehl545_Click()
'DoCmd.Hourglass True
'f_Schicht_Tag_Anz_Ist_Korr True
'DoCmd.Hourglass False
'End Sub

'Public Sub btn_xl_Einsatzliste_Click()
'DoCmd.OpenFunction "fXL_Export_Auftrag(VA_ID As Long, XLPfad As String, XLName As String)"
'End Sub

'Public Sub btnEmails_aulesen_Click()
'DoCmd.OpenFunction f_eMail_Test()
'End Sub

Private Sub btnXLEinsLst_Click()
Dim i As Long
Dim strQry As String
i = Get_Priv_Property("prp_Report1_Auftrag_IstTage")
If i = 0 Then
    strQry = "qry_Report_Auftrag_Sort_Select"
ElseIf i = -1 Then
    strQry = "qry_Report_Auftrag_Sort_Select_All"
ElseIf i = 1 Then
    strQry = "qry_Report_Auftrag_Sort_Select_AbHeute"
ElseIf i = 2 Then
    Me.recordSource = "qry_Report_Auftrag_Sort_Select_MA"
End If

fExcel_qry_export strQry

End Sub

Private Sub Befehl658_Click()
Dim Ueber_Pfad As String
Dim PDF_Datei As String
Dim s As String

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 9"))
Ueber_Pfad = Ueber_Pfad & "Allgemein\"

Call Path_erzeugen(Ueber_Pfad, False, True)

'PDF_Datei = Ueber_Pfad & "P_" & Date & "_" & Me!VA_ID & ".pdf"
PDF_Datei = "P_" & Date & "_" & Me!VA_ID & ".xls"

Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!VA_ID)
Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", Me!cboVADatum)

'DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei

Call fXL_Export_Auftrag(Me!VA_ID, Ueber_Pfad, PDF_Datei)

DoEvents
Sleep 2000
DoEvents
'End Sub
' Private Sub btnDaBaAus_Click()
'    DoCmd.SelectObject acTable, , True
'    RunCommand acCmdWindowHide
'End Sub
'
'Private Sub btnDaBaEin_Click()
'    DoCmd.SelectObject acTable, , True
'End Sub
'
'Private Sub btnRibbonAus_Click()
'    DoCmd.ShowToolbar "Ribbon", acToolbarNo
'End Sub
'
'Private Sub btnRibbonEin_Click()
'    DoCmd.ShowToolbar "Ribbon", acToolbarYes
'End Sub

'PDF anhängen
s = PDF_Datei

If Len(Trim(Nz(s))) > 0 Then
    CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
    Me!sub_tbltmp_Attachfile.Form.Requery
End If
End Sub


Private Sub Befehl640_Click()

Dim rc As String  'Returncode

rc = AuftragKopieren(Me.ID)

If IsNumeric(rc) Then
    Me.Requery
    Me.RecordsetClone.FindFirst "ID=" & rc
    Me.Bookmark = Me.RecordsetClone.Bookmark
    Me.zsub_lstAuftrag.Form.Requery
    MsgBox "Auftrag erfolgreich kopiert", vbInformation
    
Else
    MsgBox rc, vbCritical
End If

End Sub



'
'Private Sub Befehl640_Click()
''Me.ID.Clone
''Me.Dat_VA_Von.SetFocus
''Set Me.Dat_VA_Von.Value = 0
''
''Me!sub_VA_Start.Clone
'
''Me!sub_MA_VA_Zuordnung.SetFocus
''DoCmd.RunCommand acCmdSelectRecord
'
''    Me.Recordset.Clone
''     Me!sub_VA_Start.SetFocus
''     DoCmd.RunCommand acCmdSelectRecord
''     DoCmd.RunCommand acCmdCopy
''     Me.SetFocus
''     DoCmd.RunCommand acCmdSelectRecord
''     DoCmd.RunCommand acCmdCopy
'''     VAOpen_New
''
'''     DoCmd.RunCommand acCmdRecordsGoToNew
'''
'''     DoCmd.RunCommand acCmdSelectRecord
''
''     DoCmd.RunCommand acCmdPaste
''Dim rst As DAO.Recordset, intI As Integer
''    Dim fld As Field
''    Set rst = Me.Recordset
''    For Each fld In rst.Fields
''        ' Print field names.
''        Debug.Print fld.Name
''    Next
''Dim rst As Recordset
''
''
'' DoCmd.OpenForm "frm_va_auftragstamm"
'' Set rst = Forms!frm_va_auftragstamm.RecordsetClone
''' rst.ID = Me!VA_ID
''
''Me!sub_MA_VA_Zuordnung.SetFocus
'''Me!sub_MA_VA_Zuordnung.Copy
'
'
'
' Forms!frm_va_auftragstamm.Bookmark = rst.Bookmark


'End Sub

Private Sub btn_Neuer_Auftrag2_Click()
DoCmd.OpenForm "frmtop_va_auftrag_neu"
End Sub


Private Sub Befehl709_Click()
    DoCmd.OpenTable "tbl_Log_eMail_Sent"
End Sub



Private Sub btn_Autosend_BOS_Click()

Dim iVA_ID          As Long
Dim iVADatum_ID     As Long
Dim i1              As Long
Dim strEmpfaenger   As String
Dim frmSerienmail   As String

    frmSerienmail = "frm_MA_Serien_eMail_Auftrag"
    If Me.Veranstalter_ID = 10720 Or Me.Veranstalter_ID = 20770 Or Me.Veranstalter_ID = 20771 Then
 
        DoEvents
        DBEngine.Idle dbRefreshCache
        DBEngine.Idle dbFreeLocks
        DoEvents
        
        'Kein Filter auf Zeitraum
        Set_Priv_Property "prp_Report1_Auftrag_IstTage", "-1"
        
        i1 = TCount("*", "tbl_MA_VA_Zuordnung", "VADatum_ID = " & Me!cboVADatum & " AND VA_ID = " & Me!ID & " AND MA_ID > 0")
        strEmpfaenger = "marcus.wuest@bos-franken.de; sb-dispo@bos-franken.de; frank.fischer@bos-franken.de"
        
        If Len(Trim(Nz(Me!ID))) > 0 And i1 > 0 Then
            iVA_ID = Me!ID
            iVADatum_ID = Me!cboVADatum
            'DoCmd.Close acForm, Me.Name, acSaveNo
            DoCmd.OpenForm frmSerienmail
            DoEvents
            Wait 2 'Sekunden
            Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(4, iVA_ID, iVADatum_ID, strEmpfaenger)
        Else
            MsgBox "Keine Mitarbeiter vorhanden"
        End If
            
        DoEvents
        DBEngine.Idle dbRefreshCache
        DBEngine.Idle dbFreeLocks
        DoEvents
    
    Else
        MsgBox "Nix B.O.S Auftrag!", vbCritical
        
    End If

End Sub
'
'Private Sub btn_BWN_Druck_Click()
'    On Error GoTo Err_Handler
'
'    ' Drucken der Bewachungsnachweise für den aktuellen Auftrag
'    Call DruckeBewachungsnachweise(Me)
'
'Exit_Sub:
'    Exit Sub
'
'Err_Handler:
'    MsgBox "Fehler im Druck-Button: " & Err.description, vbCritical, "Fehler"
'    Resume Exit_Sub
'End Sub


'Liste Stundennachweis erstellen
Private Sub btn_ListeStd_Click()
    Stundenliste_erstellen Me.ID, , Me.Veranstalter_ID
End Sub


Private Sub btn_Posliste_oeffnen_Click()
    ' Oeffnet frm_OB_Objekt mit Positionen fuer das aktuelle Objekt
    OpenObjektPositionenFromAuftrag
End Sub

Private Sub btn_rueck_Click()
'Me!sub_MA_VA_Zuordnung.Undo

End Sub

Private Sub btn_rueckgaengig_Click()
On Error Resume Next
DoCmd.SetWarnings False
DoCmd.RunCommand acCmdUndo
DoCmd.SetWarnings True
DoCmd.Close acForm, Me.Name, acSavePrompt

End Sub


'Rückmeldeauswertung
Private Sub btn_Rueckmeld_Click()

Dim Form As String

    Form = "zfrm_Rueckmeldungen"
    DoCmd.OpenForm (Form), acNormal
    Forms(Form).Requery
    
End Sub


Private Sub btn_std_check_Click()
Me.Veranst_Status_ID = 3
Me!Aend_am = Now()
    Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
'DoCmd.FindNext Forms!frm_va_auftragstamm.Veranst_Status_ID = 2
'Forms!frm_sub_ma_va_zuordnung.SetFocus
'Forms!frm_sub_ma_va_zuordnung.MA_Ende.SetFocus
btnDruckZusage_Click
'Me.btn_std_check.Visible = False
'Me.btnDruckZusage.Visible = False
'DoCmd.GoToRecord acNext

End Sub

Private Sub btn_std_check_LostFocus()
'Me.btn_std_check.Visible = False
Me.btnDruckZusage.Visible = False
End Sub


'Sortieren
Private Sub btn_sortieren_Click()

    'ZUORDNUNG sortieren
    sort_zuo_plan Me.ID, Me.cboVADatum, 1
    
End Sub

'Private Sub Befehl614_Click()
'
'End Sub

'Private Sub btn_aenderungsprotokoll_Click()
'Call aenderungsprotokoll

'End Sub

'Private Sub BTN_TAG_Loeschen_Click()
'markierte_tage_loeschen
'End Sub


Private Sub btn_VA_Abwesenheiten_Click()
DoCmd.OpenForm "frm_abwesenheitsuebersicht", acFormDS


End Sub
Private Function f_abwesenheiten()
DoCmd.OpenForm "frm_ma_nverfuegzeiten_si", acFormDS
End Function

Private Sub btnDatumRight_Click()
On Error Resume Next

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!ID & ")) ORDER By VADatum; "
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

If Me!ID > 0 And iZLMax1 > 0 And CDate(Me!cboVADatum.Column(1)) < Me!Dat_VA_Bis Then
    For iZl = 0 To iZLMax1
        If CDate(DAOARRAY1(1, iZl)) = CDate(Me!cboVADatum.Column(1)) Then Exit For
    Next iZl
    Me!cboVADatum = DAOARRAY1(0, iZl + 1)
    cboVADatum_AfterUpdate
End If
Set DAOARRAY1 = Nothing
End Sub


'Private Sub Form_AfterUpdate()
''Call ProtokollEnde
'
'End Sub
'Function ProtokollEnde()
'Dim db As DAO.Database
'Dim rs As DAO.Recordset
'Dim i As Long
'On Error Resume Next
'Set db = CurrentDb()
'Set rs = db.OpenRecordset("Protokoll", dbOpenDynaset)
'If Err <> 0 Then
'Beep
'MsgBox "Fehler beim Zugriff auf Tabelle 'Protokoll'...", _
'vbOKOnly + vbExclamation, "Protokollieren:"
'cntProtokoll = 0 ' Neue Protokollierung starten
'Exit Function
'End If
'
'End Function


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

'iVAStart_ID = Me!lstZeiten
'iVA_ID = Me!VA_ID
'iVADatum_ID = Me!cboVADatum
'iSoll = Me!lstZeiten.column(5)
Set db = CurrentDb

'If itbl = 1 Then
    
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
    Me!sub_MA_VA_Zuordnung.RowSource = Me!sub_MA_VA_Zuordnung.RowSource
'
'ElseIf itbl = 2 Then
'
'    recsetSQL1 = ""
'    recsetSQL1 = recsetSQL1 & "SELECT tbl_MA_VA_Planung.MA_ID FROM tbl_MA_VA_Planung LEFT JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID"
'    recsetSQL1 = recsetSQL1 & " WHERE (((tbl_MA_VA_Planung.VA_ID) = " & iVA_ID & ") And ((tbl_MA_VA_Planung.VADatum_ID) = " & iVADatum_ID & " ) AND MA_ID > 0 And ((tbl_MA_VA_Planung.VAStart_ID) = " & iVAStart_ID & "))"
'    recsetSQL1 = recsetSQL1 & " ORDER BY tbl_MA_Mitarbeiterstamm.Nachname, tbl_MA_Mitarbeiterstamm.Vorname;"
'
'    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'    If Not ArrFill_DAO_OK1 Then
''        MsgBox "Sortierung nicht möglich, Abbruch"
'        Exit Function
'    End If
'
'    Set rst = DB.OpenRecordset("SELECT * FROM tbl_MA_VA_Planung WHERE VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND VAStart_ID = " & iVAStart_ID & " ORDER BY [PosNr];")
'    iZl = 0
'    With rst
'        Do Until .EOF
'            If iZl <= iZLMax1 Then
'                iMA_ID = DAOARRAY1(0, iZl)
'            Else
'                iMA_ID = 0
'            End If
'            .Edit
'                .Fields("MA_ID") = iMA_ID
'            .Update
'            .MoveNext
'            iZl = iZl + 1
'        Loop
'        .Close
'    End With
'    Set rst = Nothing
'    Me!lstMA_Plan.RowSource = Me!lstMA_Plan.RowSource
'End If
           


End Function

'
''Daten Berechnungsliste laden
'Private Sub btnLoad_Click()
'
'If TCount("*", RCHLIST, "VA_ID=" & Me.ID) > 0 Then
'    If MsgBox("Daten wurden bereits geladen!  Überschreiben?", vbYesNoCancel) <> vbYes Then Exit Sub
'End If
'
'    Call fill_Berechnungsliste(Me.ID)
'    Me.sub_Berechnungsliste.Form.Requery
'    Me.PosGesamtsumme.Requery
'
'
'End Sub

'
''Rechnung in Lexware erstellen
'Private Sub btnRchLex_Click()
'
'Dim Liste       As String
'Dim Datum       As Date
'Dim SDatum      As String
'Dim Auftrag     As String
'Dim xlApp       As Object
'Dim sFile       As String
'Dim c           As Integer
'Dim Rch_Nr      As String
'Dim kunnr_Lex   As Long
'
'
'
'    'Datumsprüfung
'    If Me.Dat_VA_Bis >= Now Then
'        MsgBox "Rechnung kann erst nach der Veranstaltung erstellt werden!", vbCritical
'        Exit Sub
'    End If
'
'    'prüfen, ob Rechnungsdaten geladen
'    If TCount("*", RCHLIST, "VA_ID=" & Me.ID) = 0 Then
'        MsgBox "Bitte zuerst Berechnungsliste laden und ggf. ergänzen!", vbCritical
'        Exit Sub
'    End If
'
'    'Sicherheitsabfrage
'    If MsgBox("Rechnungserstellung in Lexware starten?" & vbCrLf & "ACHTUNG!" & vbCrLf & "ALLE EXCEL INSTANZEN MÜSSEN VORHER GESCHLOSSEN WERDEN!", vbYesNoCancel) <> vbYes Then Exit Sub
'
'    DoCmd.RunCommand acCmdSaveRecord
'
''    'VA Status prüfen
''    If Me.Veranst_Status_ID < 2 Then
''        MsgBox "Veranstaltung muss beendet sein!", vbCritical
''        Exit Sub
''    End If
'
'    'Kunde prüfen
'    kunnr_Lex = TLookup("kunnr_Lex", KDStamm, "kun_Id = " & Me.Veranstalter_ID)
'    If get_lex_customer_id(kunnr_Lex) = "" Then
'        MsgBox "Kunde " & kunnr_Lex & " nicht gefunden in Lexware" & vbCrLf & "Bitte im Kundenstamm korrigieren!", vbCritical
'        Exit Sub
'    End If
'
''    'Excel prüfen -> Fehler, da häufig unsichtbarer Excel-Task vorhanden!
''On Error Resume Next
''    Set xlApp = GetObject(, "Excel.Application")
''On Error GoTo 0
''    If Not xlApp Is Nothing Then
''        MsgBox "Bitte alle Excel-Instanzen schließen!", vbCritical
''        Exit Sub
''    End If
'
'    Rch_Nr = create_lex_invoice(Me.ID)
'
'    'Lex Rechnung prüfen
'    If Rch_Nr = "" Then
'        'MsgBox "Rechnung in Lexware bereits angelegt!", vbCritical 'Meldung kommt schon von der Funktion
'        Exit Sub
'    End If
'
'    'Start
'
'    Datum = Me.Controls("Dat_VA_Von")
'    SDatum = Mid(Datum, 4, 2) & "-" & Left(Datum, 2) & "-" & Right(Datum, 2)
'    Auftrag = Me.Controls("Auftrag")
'    Liste = SDatum & " " & Auftrag & " " & Objekt & ".xlsm"
'    sFile = PfadZuBerechnen & Liste
'
'    'Liste erstellen
'    Call fXL_Export_Auftrag(ID, PfadZuBerechnen, Liste)
'
'    'Warten
'    Sleep 500
'    For c = 1 To 1000
'        DoEvents
'    Next c
'    'Sleep 500
'
'    'Excel holen
'    Set xlApp = GetObject(, "Excel.Application")
'
'    'Berechnen
'    xlApp.Run "berechnen", True 'berechnen ohne Popup-Meldung!
'
'    'Warten
'    Sleep 500
'    For c = 1 To 1000
'        DoEvents
'    Next c
'    'Sleep 500
'
'    'PDF erstellen
'    xlApp.Run "PDF_erstellen"
'
'    xlApp.ActiveWorkbook.Save
'    'xlApp.activeworkbook.Close
'    'xlApp.Quit
'    Set xlApp = Nothing
'
'    TUpdate "Veranst_Status_ID = 4", AUFTRAGSTAMM, "ID=" & Me.ID 'Status direkt schreiben, sonst Fehler durch Sperrverwaltung!
'
'    MsgBox "habe fertig", vbInformation
'
'
'End Sub


'Synchronisationsfehler bearbeiten
Private Sub btnSyncErr_Click()
    DoCmd.OpenForm "zfrm_SyncError"
End Sub

'GGF Property für Zusage-Bestätigung setzen???
Private Sub cboEinsatzliste_BeforeUpdate(Cancel As Integer)
Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", Me!cboEinsatzliste)
End Sub


'Vorbelegung bei Auftragseingabe
Private Sub Ansprechpartner_GotFocus()

Dim lastVAID As Long
Dim Vorschlag As String

On Error Resume Next

    lastVAID = 0
    Vorschlag = ""
    If Me.Auftrag <> "" Then
        lastVAID = TMax("ID", AUFTRAGSTAMM, "Auftrag = '" & Me.Auftrag & "'")
        Vorschlag = TLookup("Ansprechpartner", AUFTRAGSTAMM, "ID = " & lastVAID)
        If Left(Vorschlag, 1) <> "#" And IsInitial(Me.Ansprechpartner) Then Me.Ansprechpartner = Vorschlag
    End If
    
End Sub


Private Sub cmd_BWN_send_Click()
    Call SendeBewachungsnachweise(Me)
End Sub


Private Sub cmd_Messezettel_NameEintragen_Click()
    If IsNull(Me.ID) Then
        MsgBox "Bitte Auftrag auswählen!", vbExclamation
        Exit Sub
    End If
    Call FuelleMessezettel(Me.ID)
End Sub


'Vorbelegung bei Auftragseingabe
Private Sub Dienstkleidung_GotFocus()

Dim lastVAID As Long
Dim Vorschlag As String

On Error Resume Next

    lastVAID = 0
    Vorschlag = ""
    If Me.Auftrag <> "" Then
        lastVAID = TMax("ID", AUFTRAGSTAMM, "Auftrag = '" & Me.Auftrag & "'")
        Vorschlag = TLookup("Dienstkleidung", AUFTRAGSTAMM, "ID = " & lastVAID)
        If Left(Vorschlag, 1) <> "#" And IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = Vorschlag
    End If
    
End Sub


'Auftrag Löschen
Private Sub mcobtnDelete_Click()

Dim Auftrag As String
Dim pos As Long
    
    If Me.ID <> 0 Then
            Auftrag = Me.Auftrag
            If MsgBox("Auftrag >" & Auftrag & "< wirklich löschen?", vbYesNo) = vbYes Then
            pos = Me.zsub_lstAuftrag.Form.Recordset.AbsolutePosition
            DoCmd.SetWarnings False
            DoCmd.RunCommand acCmdSaveRecord
            CurrentDb.Execute "DELETE FROM " & AUFTRAGSTAMM & " WHERE ID = " & Me.ID
            Me.zsub_lstAuftrag.Requery
            Me.zsub_lstAuftrag.Form.Recordset.AbsolutePosition = pos
            Me.zsub_lstAuftrag.Form.aktualisieren
            DoCmd.SetWarnings True
            MsgBox "Auftrag >" & Auftrag & "< wurde gelöscht"
        End If
    End If

End Sub

'Vorbelegung bei Auftragseingabe
Private Sub Objekt_GotFocus()

Dim lastVAID As Long
Dim Vorschlag As String

On Error Resume Next

    lastVAID = 0
    Vorschlag = ""
    If Me.Auftrag <> "" Then
        lastVAID = TMax("ID", AUFTRAGSTAMM, "Auftrag = '" & Me.Auftrag & "'")
        Vorschlag = TLookup("Objekt", AUFTRAGSTAMM, "ID = " & lastVAID)
        If Left(Vorschlag, 1) <> "#" And IsInitial(Me.Objekt) Then Me.Objekt = Vorschlag
    End If
    
End Sub

'Vorbelegung bei Auftragseingabe
Private Sub Ort_GotFocus()

Dim lastVAID As Long
Dim Vorschlag As String
On Error Resume Next

    lastVAID = 0
    Vorschlag = ""
    If Me.Auftrag <> "" Then
        lastVAID = TMax("ID", AUFTRAGSTAMM, "Auftrag = '" & Me.Auftrag & "'")
        Vorschlag = TLookup("Ort", AUFTRAGSTAMM, "ID = " & lastVAID)
        If Left(Vorschlag, 1) <> "#" And IsInitial(Me.Ort) Then Me.Ort = Vorschlag
    End If
    
  Select Case Me.Auftrag
   
    Case "Kaufland" & "*"
        If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor Ort"
        If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Schwarz neutral"
        If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20770
    
    Case "Greuther" & " " & "*"
        If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB Tor F"
        If IsInitial(Me.Ort) Then Me.Ort = "Fürth"
        If IsInitial(Me.Objekt) Then Me.Objekt = "Sportpark am Ronhof"
        If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Schwarz neutral"
        If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20737
    
    Case "1.FCN" & " " & "*"
        If IsInitial(Me.Ort) Or IsNull(Me.Ort) Then Me.Ort = "Nürnberg"
        If IsInitial(Me.Objekt) Or IsNull(Me.Objekt) Then Me.Objekt = "Max-Morlock-Stadion"
        If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB Eingang Nord West"
        If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Schwarz neutral"
        If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20771
        
    Case "Konzert"
        If IsInitial(Me.Ort) Then Me.Ort = "Nürnberg"
        If IsInitial(Me.Objekt) Then Me.Objekt = "Hirsch"
        If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
        If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Consec"
        If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 10233
        'If IsNull(Me.sub_VA_Start.Controls("VA_Ende")) Then Me.sub_VA_Start.Controls("VA_Ende") = "23:30"
        
    Case "clubbing"
        If IsInitial(Me.Ort) Then Me.Ort = "Nürnberg"
        If IsInitial(Me.Objekt) Then Me.Objekt = "Hirsch"
        If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
        If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Consec"
        If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 10337
        'If IsNull(Me.sub_VA_Start.Controls("VA_Ende")) Then Me.sub_VA_Start.Controls("VA_Ende") = "05:15"
        
    Case "HC Erlangen" & " "
        If IsInitial(Me.Ort) Then Me.Ort = "Nürnberg"
        If IsInitial(Me.Objekt) Then Me.Objekt = "Arena"
        If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB Arena Ecke Kurt-Leucht"
        If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Schwarz neutral"
        If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20761

   Case Else
     
 End Select
    
End Sub

'Vorbelegung bei Auftragseingabe
Private Sub Treffp_Zeit_GotFocus()

Dim lastVAID As Long
Dim Vorschlag As String

On Error Resume Next

    lastVAID = 0
    Vorschlag = ""
    If Me.Auftrag <> "" Then
        lastVAID = TMax("ID", AUFTRAGSTAMM, "Auftrag = '" & Me.Auftrag & "'")
        Vorschlag = TLookup("Treffp_Zeit", AUFTRAGSTAMM, "ID = " & lastVAID)
        If Left(Vorschlag, 1) <> "#" And IsInitial(Me.Treffp_Zeit) Then Me.Treffp_Zeit = Vorschlag
    End If
    
End Sub

'Vorbelegung bei Auftragseingabe
Private Sub Treffpunkt_GotFocus()

Dim lastVAID As Long
Dim Vorschlag As String

On Error Resume Next

    lastVAID = 0
    Vorschlag = ""
    If Me.Auftrag <> "" Then
        lastVAID = TMax("ID", AUFTRAGSTAMM, "Auftrag = '" & Me.Auftrag & "'")
        Vorschlag = TLookup("Treffpunkt", AUFTRAGSTAMM, "ID = " & lastVAID)
        If Left(Vorschlag, 1) <> "#" And IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = Vorschlag
    End If
    
    Select Case Me.Objekt
        Case "Löwensaal"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Consec"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 10233
                        
         Case "KIA Arena"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Consec"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 10233
              
        Case "Messezentrum"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB am SCU"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Schwarz neutral"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20730
        
    '    Case "Arena"
    '       If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB Eingang Treppe"
    '       If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Schwarz neutral"
    '       If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20720
            
        Case "Max-Morlock-Stadion"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB Eingang Nord West"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Schwarz neutral"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20771
            
        Case "Hirsch"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Consec"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 10337
            
        Case "Meistersingerhalle"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Anzug + Consec Hemd + Consec Krawatte"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 10337
            
        Case "Mississippi Queen"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Anzug + Consec Hemd + Consec Krawatte"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 10220
            
        Case "Neues Museum"
            If IsInitial(Me.Treffpunkt) Then Me.Treffpunkt = "15 min vor DB vor Ort"
            If IsInitial(Me.Dienstkleidung) Then Me.Dienstkleidung = "Anzug + Consec Hemd + Consec Krawatte"
            If IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = 20707
                 
        Case Else
    End Select
End Sub

'Vorbelegung bei Auftragseingabe
Private Sub veranstalter_id_GotFocus()

Dim lastVAID As Long
Dim Vorschlag As String

On Error Resume Next

    lastVAID = 0
    Vorschlag = ""
    If Me.Auftrag <> "" Then
        lastVAID = TMax("ID", AUFTRAGSTAMM, "Auftrag = '" & Me.Auftrag & "'")
        Vorschlag = TLookup("Veranstalter_ID", AUFTRAGSTAMM, "ID = " & lastVAID)
        If Left(Vorschlag, 1) <> "#" And IsInitial(Me.Veranstalter_ID) Then Me.Veranstalter_ID = Vorschlag
    End If

End Sub


Private Sub Treffp_Zeit_BeforeUpdate(Cancel As Integer)

On Error Resume Next

    Select Case Len(Me.Treffp_Zeit)
        Case 2
            Me.Treffp_Zeit = Me.Treffp_Zeit & ":00"
        Case 3
            Me.Treffp_Zeit = Me.Treffp_Zeit & "00"
    End Select
End Sub

Private Sub veranstalter_id_AfterUpdate()
Dim KeyCode As Controls
'Weiterspringen in nächstes Formular
'If keycode = 9 Or keycode.Enter Then
Forms!frm_VA_Auftragstamm!sub_VA_Start.SetFocus
Forms!frm_VA_Auftragstamm!sub_VA_Start!MA_Anzahl.SetFocus
'End If

'Me.sub_VA_Start.SetFocus
'Me.sub_VA_Start.Controls("MA_Anzahl").SetFocus
'Me.sub_VA_Start.Form.Controls("MA_Anzahl").SetFocus

'Debug.Print Me.ActiveControl.Name
'DoCmd.GoToControl Me.sub_VA_Start.Form.


'Me.sub_VA_Start.Controls("MA_Anzahl").Selected = True

    
End Sub

Private Sub cboAnstArt_DblClick(Cancel As Integer)
DoCmd.OpenForm "frmTop_MA_Anstellungsart"
End Sub

Private Sub cboEinsatzliste_AfterUpdate()
Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", Me!cboEinsatzliste)
End Sub

Private Sub cboID_AfterUpdate()
On Error Resume Next
    Me.Recordset.FindFirst "ID = " & Me.cboID.Column(0)
    Me!cboID = Null
End Sub

Private Sub Form_BeforeDelConfirm(Cancel As Integer, response As Integer)
If ID <= 10 Then
    MsgBox "Diese Anstellungsart kann nicht gelöscht werden"
    Cancel = True
End If
End Sub

Private Sub Form_Load()

 Dim sql As String
 
    DoCmd.Maximize
    Me!lbl_Version.Visible = True
    Me!lbl_Version.caption = Get_Priv_Property("prp_V_FE") & " | " & Get_Priv_Property("prp_V_BE")
    
    
''PKW Anzahl + Fahrtkosten ermitteln
'On Error Resume Next
'
'    Me.Fahrtkosten = TSum("PKW", ZUORDNUNG, "VA_ID = " & Me.ID) & " €"
'    Me.PKW_Anzahl = TSum("PKW_Anzahl", ZUORDNUNG, "VA_ID = " & Me.ID)


End Sub

Private Sub Auftraege_ab_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub


Private Sub btnreq_Click()

'Email-Antworten Synchronisieren -Läuft über Scheduler!
'synchronisieren

req_rq

End Sub

'Private Sub Form_AfterDelConfirm(Status As Integer)
'Call datensatzloeschung

'End Sub

Private Sub Form_Open(Cancel As Integer)
On Error Resume Next

Dim i As Long
Dim iVADatum_ID As Long
Dim iVA_ID As Long
Dim dt As Date
    
    Me.Recordset.FindFirst "ID = " & TLookup("ID", AUFTRAGSTAMM, "Dat_VA_Von > " & datumSQL(Now() - 1) & " AND Dat_VA_Von < " & datumSQL(Now() + 5) & " ORDER BY Dat_VA_Von ASC")
    
    CurrentDb.Execute ("DELETE * FROM tbltmp_MA_Verfueg_tmp")
    CurrentDb.Execute ("INSERT INTO tbltmp_MA_Verfueg_tmp ( ID, MAName, IstVerfuegbar, Anstellungsart_ID, IstAktiv) SELECT 0 AS Ausdr1, '(gelöscht)' AS Ausdr2, -1 AS Ausdr3, 3 as Ausdr4, -1 as Ausdr5 FROM _tblInternalSystemFE;")
    CurrentDb.Execute ("qry_MA_Add_Verfueg_tmp_1")
        
    'PosNr_Einfaerben_FormatCondition_Loesch
    
    'DoCmd.RunCommand acCmdRecordsGoToLast
    'DoCmd.RunCommand acCmdRecordsGoToNew
    
    btn_AbWann_Click
    
    'DoEvents
    'DBEngine.Idle dbRefreshCache
    'DBEngine.Idle dbFreeLocks
    'DoEvents
    
    'Me!btn_VA_Objekt_NA_Teil1.Visible = False

    Me.lbl_Datum.caption = Date

    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
'    DoCmd.ShowToolbar "Ribbon", acToolbarNo


End Sub

Public Function VAOpen_LastDS()
On Error Resume Next

Me!Auftrag.SetFocus
DoEvents
DoCmd.RunCommand acCmdRecordsGoToLast

End Function


Public Function req_rq(Optional iID As Long, Optional iVADatum_ID As Long)
On Error Resume Next

iID = Nz(iID, 0)
If iID = 0 Then
    iID = Me!ID
End If

Me.zsub_lstAuftrag.Form.Recalc
Me.Requery

Me.Recordset.FindFirst "Id = " & iID
iVADatum_ID = Nz(iVADatum_ID, 0)
If iVADatum_ID > 0 Then
    VADateSet iVADatum_ID
End If
Form_sub_VA_Anzeige.f_UpdStatus

End Function

Public Function VAOpen_New()
On Error Resume Next

Me!Dat_VA_Von.SetFocus
DoEvents
DoCmd.RunCommand acCmdRecordsGoToNew
DoEvents

'Me!lbl_Auftrag.Caption = ""
'Me!lbl_Objekt.Caption = ""

End Function

Public Function VADateSet(iVADatum_ID)
Me!cboVADatum = iVADatum_ID
Me!cboVADatum.Requery
End Function

Public Function VAOpen(iVA_ID As Long, iVADatum_ID As Long)
Dim strSQL As String
Dim i As Long

Me.Recordset.FindFirst "ID = " & iVA_ID
DoEvents
strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & iVA_ID & ")) ORDER BY ID;"
Me!cboVADatum.RowSource = strSQL
Me!cboVADatum = iVADatum_ID
DoEvents

Me.zsub_lstAuftrag.Form.RecordsetClone.FindFirst "tbl_VA_Auftragstamm.ID = " & Me.ID
Me.zsub_lstAuftrag.Form.Bookmark = Me.zsub_lstAuftrag.Form.RecordsetClone.Bookmark

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
End Function

Private Sub btn_VA_Neu_Aus_Vorlage_Click()
DoCmd.OpenForm "frm_Crea_VA_Aus_Vorlage"
End Sub

Private Sub btnMAErz_Click()
'Dim iMAAnz_Zeit As Long
'Dim iMAAnz_Zuo As Long
'Dim i As Long
'
'iMAAnz_Zeit = TSum("MA_Anzahl", "tbl_VA_Start", "VA_ID = " & Me!ID)
'iMAAnz_Zuo = TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & Me!ID)
'
'
'If iMAAnz_Zuo > iMAAnz_Zeit Then
'    MsgBox "Anzahl zugeordneter MA > Anzahl lt. Zeitplan!", vbCritical, "Achtung Gefahr"
'ElseIf iMAAnz_Zuo < iMAAnz_Zeit Then
'    If iMAAnz_Zuo > 0 Then
'        MsgBox "loop Insert part"
'    Else
'        MsgBox "loop Insert All"
'    End if
'End if

End Sub


Private Sub btnAuftrBerech_Click()
On Error Resume Next
Dim iTaetart As Long
Dim iKd_Nr As Long
Dim iRchArt As Long
Dim iAuftrag_Nr As Long
Dim btnStdBerech As CommandButton
Dim btnBerList As CommandButton
Dim btnRchWd_Open As CommandButton
Dim btnPrint1 As CommandButton
Dim btnPrint2 As CommandButton

DoCmd.RunCommand acCmdSaveRecord

' 1. date > Endedatum
' 2. veranstalter
' 3. Alle MA
' 4. Alle Zeiten
    
    If Len(Trim(Nz(Me!Veranstalter_ID))) = 0 Or Me!Veranstalter_ID = 0 Then
        MsgBox "Bitte Veranstalter eingeben"
    Else
        DoCmd.OpenForm "frmTop_Rch_Berechnungsliste"
        Form_frmTop_Rch_Berechnungsliste.VAOpen Me!ID
'        DoCmd.OpenForm "frmTop_Textbaustein_Rechnung"
'        Call Form_frmTop_Textbaustein_Rechnung.Rchnung_aus_Auftrag(Me!Veranstalter_ID, Me!ID)
'        DoEvents
'        Me!pgRechnung.Visible = True
'        Me!pgRechnung.SetFocus
'        DoEvents
    End If

Form_sub_VA_Anzeige.f_UpdStatus
'Call btnStdBerech_Click
'Call btnBerList_Click
'Call btnRchWd_Open_Click
'Call btnPrint1_Click
'Call btnPrint2_Click

End Sub

'Private Sub btnPrint1_Click()
'Dim strDok As String
'strDok = Me!strPDF_Rechnung
'If File_exist(strDok) Then PrintDoc strDok
'End Sub
'
'Private Sub btnPrint2_Click()
'Dim strDok As String
'strDok = Me!str_Stundenliste
'If File_exist(strDok) Then PrintDoc strDok
'End Sub
'
'Private Sub btnPrint3_Click()
'Dim strDok As String
'strDok = Me!strPDF_Einsatzliste
'If File_exist(strDok) Then PrintDoc strDok
'End Sub
'
'Private Sub btnRchWd_Open_Click()
'Dim s As String
'Dim i As Long
's = Me!strPDF_Rechnung
'i = InStrRev(s, ".")
's = Left(s, i) & "docx"
'If File_exist(s) Then
'    Application.FollowHyperlink s
'End If
'End Sub
'
'Private Sub btnSendenAn_Click()
'Dim s As String
'CurrentDb.Execute ("Delete * FROM tbltmp_Attachfile")
'DoEvents
'If Me!ist_Rechnung Then
'    s = Nz(Me!strPDF_Rechnung)
'    If File_exist(s) Then
'        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
'    End If
'End If
'If Me!ist_Std_Liste Then
'    s = Nz(Me!str_Stundenliste)
'    If File_exist(s) Then
'        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
'    End If
'End If
'If Me!ist_Einsatzliste Then
'    s = Nz(Me!strPDF_Einsatzliste)
'    If File_exist(s) Then
'        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
'    End If
'End If
'
'DoCmd.OpenForm "frmOff_Outlook_aufrufen", , , , , , Me!cboKunde.column(0)
'Form_frmOff_Outlook_aufrufen.VAOpen_rch
'End Sub

Private Sub btnDatumLeft_Click()
On Error Resume Next

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!ID & ")) ORDER By VADatum; "
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

If Me!ID > 0 And iZLMax1 > 0 And CDate(Me!cboVADatum.Column(1)) > Me!Dat_VA_Von Then
    For iZl = 0 To iZLMax1
        If CDate(DAOARRAY1(1, iZl)) = CDate(Me!cboVADatum.Column(1)) Then Exit For
    Next iZl
    Me!cboVADatum = DAOARRAY1(0, iZl - 1)
    cboVADatum_AfterUpdate
End If
Set DAOARRAY1 = Nothing
End Sub

Private Sub btnDruck_Click()
Dim Ueber_Pfad As String
Dim PDF_Datei As String
Dim s As String

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 9"))
'Ueber_Pfad = Ueber_Pfad & "Allgemein\"

PDF_Datei = Ueber_Pfad & "Auf_Alle_" & Date & "_" & Me!ID & ".pdf"

Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!ID)
Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", Me!cboVADatum.Column(0))

DoCmd.OutputTo acOutputReport, "rpt_Auftrag", "PDF", PDF_Datei
DoEvents
Sleep 2000
DoEvents

Application.FollowHyperlink PDF_Datei

End Sub
Private Sub btnStdBerech_Click()
Dim i As Long
Dim j As Long
Dim iVA_ID As Long

'If Len(Trim(Nz(Me!cboAuftrag))) = 0 Then
'    Exit Sub
'End If
'If Nz(Me!cboKunde, 0) = 0 Then
'    MsgBox "Bitte erst Auftraggeber zuordnen"
'    Exit Sub
'End If
'
'Me!strPDF_Rechnung = ""
'Me!str_Stundenliste = ""
'Me!strPDF_Einsatzliste = ""
'
'Me!pgStd.SetFocus
'
'CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.PKW_Anzahl = 1 WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & Me!VA_ID & ") AND ((Nz([PKW],0))>0) AND ((Nz([PKW_Anzahl],0))=0));")
'DoEvents
'Me!Anz_PKW = Nz(TSum("PKW_Anzahl", "tbl_MA_VA_Zuordnung", "VA_ID= " & Me!VA_ID), 0)
'Me!SumPKW_MA = Nz(TSum("PKW", "tbl_MA_VA_Zuordnung", "VA_ID= " & Me!VA_ID), 0)
'DoEvents
'Me!sub_MA_VA_Zuordnung.Form.Requery
'DoEvents
'
'If Me!StdF1 = 0 Then
'    MsgBox "Standard Preis fehlt. Bitte Preis (netto) eingeben"
'    Exit Sub
'End If
'I = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID = 0 AND VA_ID = " & Me!VA_ID), 0)
''If I > 0 Then
'    MsgBox "Bitte erst alle MA zuordnen"
'    Exit Sub
'End If
'I = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "len(trim(Nz(MA_Ende))) = 0 AND VA_ID = " & Me!VA_ID), 0)
'If I > 0 Then
'    MsgBox "Bitte erst alle Endzeiten setzen"
'    Exit Sub
'End If
'I = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "len(trim(Nz(MA_Start))) = 0 AND VA_ID = " & Me!VA_ID), 0)
'If I > 0 Then
'    MsgBox "Bitte erst alle Startzeiten setzen"
'    Exit Sub
'End If
'I = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "PreisArt_ID = 3 AND VA_ID = " & Me!VA_ID), 0)
'If Me!StdF3 = 0 And I > 0 Then
'    MsgBox "Einsatzleiter vorhanden, aber Preis fehlt. Bitte Preis (EL) eingeben"
'    Exit Sub
'End If
'If Me!Anz_PKW > 0 And Me!StdPKW = 0 Then
'    If vbCancel = MsgBox("PKW vorhanden aber die Kunden Fahrtkosten Pauschale pro PKW = 0, ist das OK", vbOKCancel + vbQuestion, "Keine Kunden Fahrtkostenpauschale") Then
'        Exit Sub
'    End If
'End If
'
'call fStundenberech(iVA_ID = me_id)"




'Me!sub_MA_VA_Zuordnung.Form.Requery
'DoEvents

End Sub



'Private Sub btnBerList_Click()
'
'Dim iRch_ID As Long
'Dim strSQL As String
'
'Dim Ges_Alles As Currency
'
'strSQL = ""
'
'CurrentDb.Execute ("Delete * FROM tbltmp_Position;")
'DoEvents
'
'Me!Rch_ID = fRch_ID_fuell(Me!VA_ID, 1)
'
'CurrentDb.Execute ("Delete * FROM tbl_Rch_Pos_Auftrag WHERE VA_ID = " & Me!VA_ID & ";")
'DoEvents
'
'Call Set_Priv_Property("EZ_Preisart_1", Me!StdF1)
'Call Set_Priv_Property("EZ_Preisart_3", Me!StdF3)
'Call Set_Priv_Property("EZ_Preisart_4", Me!StdPKW)
'
'strSQL = ""
'strSQL = strSQL & "INSERT INTO tbl_Rch_Pos_Auftrag ( VA_ID, VorlageNr, kun_ID, VADatum, VAStart_ID, MA_Start, MA_Ende, Menge, EzPreis,"
'strSQL = strSQL & " Mengenheit, MwSt, Beschreibung, Preisart_ID, GesPreis, Rch_ID, Anz_MA )"
'strSQL = strSQL & " SELECT tbl_MA_VA_Zuordnung.VA_ID, 404 AS VorlageNr, tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID,"
'strSQL = strSQL & " tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_VA_Start.VA_Start,"
'strSQL = strSQL & " Max(tbl_MA_VA_Zuordnung.MA_Ende) AS VA_Ende, Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std2) AS Menge,"
'strSQL = strSQL & " fEzPreis([tbl_MA_VA_Zuordnung].[Preisart_ID]) AS EzPreis, tbl_KD_Artikelbeschreibung.Mengenheit,"
'strSQL = strSQL & " tbl_KD_Artikelbeschreibung.MwSt_Satz, tbl_KD_Artikelbeschreibung.Beschreibung,"
'strSQL = strSQL & " tbl_MA_VA_Zuordnung.Preisart_ID, Sum([MA_Brutto_Std2]*fEzPreis([tbl_MA_VA_Zuordnung].[Preisart_ID])) AS GesPreis, " & Me!Rch_ID & " AS Rch_ID,"
'strSQL = strSQL & " Count(tbl_MA_VA_Zuordnung.ID) As Anz_MA"
'strSQL = strSQL & " FROM (tbl_VA_Auftragstamm INNER JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_VA_Start"
'strSQL = strSQL & " ON tbl_MA_VA_Zuordnung.VAStart_ID = tbl_VA_Start.ID) ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID)"
'strSQL = strSQL & " LEFT JOIN tbl_KD_Artikelbeschreibung ON tbl_MA_VA_Zuordnung.PreisArt_ID = tbl_KD_Artikelbeschreibung.ID"
'strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID) = " & Me!VA_ID & ") And ((tbl_MA_VA_Zuordnung.Preisart_ID) < 4))"
'strSQL = strSQL & " GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_VA_Auftragstamm.Veranstalter_ID, tbl_MA_VA_Zuordnung.VADatum,"
'strSQL = strSQL & " tbl_MA_VA_Zuordnung.VAStart_ID, tbl_VA_Start.VA_Start, fEzPreis([tbl_MA_VA_Zuordnung].[Preisart_ID]),"
'strSQL = strSQL & " tbl_KD_Artikelbeschreibung.Mengenheit, tbl_KD_Artikelbeschreibung.MwSt_Satz,"
'strSQL = strSQL & " tbl_KD_Artikelbeschreibung.Beschreibung, tbl_MA_VA_Zuordnung.Preisart_ID;"
'CurrentDb.Execute (strSQL)
'
'If fEzPreis(4) > 0 Then
'    strSQL = ""
'    strSQL = strSQL & "INSERT INTO tbl_Rch_Pos_Auftrag ( VA_ID, VorlageNr, kun_ID, VADatum, VAStart_ID, MA_Start, MA_Ende, Menge, EzPreis,"
'    strSQL = strSQL & " Preisart_ID, Mengenheit, MwSt, Beschreibung, GesPreis, Rch_ID, Anz_MA )"
'    strSQL = strSQL & " SELECT tbl_MA_VA_Zuordnung.VA_ID, 405 AS VorlageNr, tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID, tbl_MA_VA_Zuordnung.VADatum, "
'    strSQL = strSQL & " tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_Start, Max(tbl_MA_VA_Zuordnung.MA_Ende) AS MaxvonMA_Ende,"
'    strSQL = strSQL & " Sum(tbl_MA_VA_Zuordnung.PKW_Anzahl) AS SummevonPKW_Anzahl, fEzPreis(4) AS EzPreis,"
'    strSQL = strSQL & " tbl_KD_Artikelbeschreibung.ID AS Preisart_ID, tbl_KD_Artikelbeschreibung.Mengenheit,"
'    strSQL = strSQL & " tbl_KD_Artikelbeschreibung.MwSt_Satz AS MwSt, tbl_KD_Artikelbeschreibung.Beschreibung,"
'    strSQL = strSQL & " Sum(fEzPreis(4)*[PKW_Anzahl]) AS GesPreis, " & Me!Rch_ID & " AS Rch_ID, 0 AS Anz_MA"
'    strSQL = strSQL & " FROM tbl_KD_Artikelbeschreibung, tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Zuordnung"
'    strSQL = strSQL & " ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID"
'    strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID) = " & Me!VA_ID & "))"
'    strSQL = strSQL & " GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_VA_Auftragstamm.Veranstalter_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VAStart_ID, "
'    strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_Start, fEzPreis(4), tbl_KD_Artikelbeschreibung.ID, tbl_KD_Artikelbeschreibung.Mengenheit,"
'    strSQL = strSQL & " tbl_KD_Artikelbeschreibung.MwSt_Satz, tbl_KD_Artikelbeschreibung.Beschreibung, 0, 4, 0"
'    strSQL = strSQL & " HAVING (((Sum(tbl_MA_VA_Zuordnung.PKW_Anzahl))>0) AND ((tbl_KD_Artikelbeschreibung.ID)=4));"
'    CurrentDb.Execute (strSQL)
'End If
'
'f_tmp_position_fill
'
'Textbau_Replace_Felder_Fuellen (Me!VorlageDokNr)
'
'fCreateRech_Neu
'
'fbtnStunden
'
'Me!sub_MA_VA_Zuordnung.Form.Requery
'Me!sub_Rch_Pos_Auftrag.Form.Requery
'Me!sub_tbltmp_Position.Form.Requery
'Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery
'
'Me!pgBerech.SetFocus
'
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents
'
'Me!btnWord.Visible = True
'btnWord_Click
'
'End Sub

Private Sub btnDruckZusage_Click()

Dim Datum As Date
Dim SDatum As String
Dim Auftrag As String
Dim c As Integer


Datum = Me.Controls("Dat_VA_Von")
SDatum = Mid(Datum, 4, 2) & "-" & Left(Datum, 2) & "-" & Right(Datum, 2)
Auftrag = Me.Controls("Auftrag")



Call fXL_Export_Auftrag(ID, CONSYS & "\CONSEC\CONSEC PLANUNG AKTUELL\", SDatum & " " & Auftrag & " " & Objekt & ".xlsm")

'Warten
Sleep 1000
For c = 1 To 10000
    DoEvents
Next c
Sleep 1000

'Status Beendet setzen
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
On Error Resume Next
Me.Veranst_Status_ID = 2
Wait 2
DoCmd.RunCommand acCmdSaveRecord
On Error GoTo 0


'Dim Ueber_Pfad As String
'Dim PDF_Datei As String
'Dim s As String
'
'Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 9"))
''Ueber_Pfad = Ueber_Pfad & "Allgemein\"
'
'PDF_Datei = Ueber_Pfad & "Auf_Zusage_" & Date & "_" & Me!ID & ".pdf"
'
'Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!ID)
'Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", Me!cboVADatum.Column(0))
'
'DoCmd.OpenReport "rpt_Auftrag_Zusage", acViewPreview
'RunCommand acCmdFitToWindow
'
''DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei
''DoEvents
''Sleep 2000
''DoEvents
''
''Application.FollowHyperlink PDF_Datei

'btnAuftrBerech_Click
''Me.Parent.Veranst_Status_ID = 3
'DoCmd.Close acForm, "frmtop_rch_berechnungsliste"


End Sub
Private Sub btnDruckZusage1_Click()
Dim Ueber_Pfad As String
Dim PDF_Datei As String
Dim s As String

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 9"))
'Ueber_Pfad = Ueber_Pfad & "Allgemein\"

PDF_Datei = Ueber_Pfad & "Auf_Zusage_" & Date & "_" & Me!ID & ".pdf"

Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!ID)
Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", Me!cboVADatum.Column(0))

Dim i As Long
i = Get_Priv_Property("prp_Report1_Auftrag_IstTage")
If i = -1 Then
    If Nz(TCount("*", "qry_Report_Auftrag_Sort_Select_All"), 0) = 0 Then
        MsgBox "Keine Daten >= Heute, kein Druck möglich (Da nur Vergangenheitswerte)"
        Exit Sub
    End If
End If

DoCmd.OpenReport "rpt_Auftrag_Zusage", acViewPreview
RunCommand acCmdFitToWindow

'DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei
'DoEvents
'Sleep 2000
'DoEvents
'
'Application.FollowHyperlink PDF_Datei


End Sub
Private Sub btnMailEins_Click()
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim i1 As Long

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

'Kein Filter auf Zeitraum
Set_Priv_Property "prp_Report1_Auftrag_IstTage", "-1"

i1 = TCount("*", "tbl_MA_VA_Zuordnung", "VADatum_ID = " & Me!cboVADatum & " AND VA_ID = " & Me!ID & " AND MA_ID > 0")

If Len(Trim(Nz(Me!ID))) > 0 And i1 > 0 Then
    iVA_ID = Me!ID
    iVADatum_ID = Me!cboVADatum
    'DoCmd.Close acForm, Me.Name, acSaveNo
    DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
    DoEvents
    Wait 2 'Sekunden
    Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(2, iVA_ID, iVADatum_ID)
Else
    MsgBox "Keine Mitarbeiter vorhanden"
End If
    
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub

Private Sub btnMailPos_Click()

Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim i1 As Long

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

If Len(Trim(Nz(Me!ID))) > 0 Then
    iVA_ID = Me!ID
    iVADatum_ID = Me!cboVADatum
'    DoCmd.Close acForm, Me.Name, acSaveNo
    DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
    Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(3, iVA_ID, iVADatum_ID)
Else
    MsgBox "Keine Mitarbeiter vorhanden"
End If
    
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub


Private Sub btnMailSub_Click()

Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim i1 As Long

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

If Len(Trim(Nz(Me!ID))) > 0 Then
    iVA_ID = Me!ID
    iVADatum_ID = Me!cboVADatum
'    DoCmd.Close acForm, Me.Name, acSaveNo
    DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
    Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(5, iVA_ID, iVADatum_ID)
Else
    MsgBox "Keine Mitarbeiter vorhanden"
End If
    
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub


Private Sub btnNeuAttach_Click()
Dim iID As Long
Dim iTable As Long

iID = Me!Objekt_ID
iTable = Me!TabellenNr

Call f_btnNeuAttach(iID, iTable)

Me!sub_ZusatzDateien.Form.Requery

End Sub

Private Sub btnNeuVeranst_Click()
VAOpen_New
Me.Autosend_EL = True
End Sub

'Private Sub btnOutlookRch_Click()
'
'Dim strText As String
'Dim strAn As String
'Dim strrchnr As String
'Dim dtrchdat As Date
'Dim ikun_ID As Long
'Dim strkun_email As String
'
'ikun_ID = Me!sub_tbl_Rch_Kopf.Form!kun_ID
'strkun_email = Nz(TLookup("kun_email", "tbl_KD_Kundenstamm", "kun_ID = " & ikun_ID))
'strrchnr = Me!sub_tbl_Rch_Kopf.Form!RchNr_Ext
'dtrchdat = Me!sub_tbl_Rch_Kopf.Form!RchDatum
'
'strText = "<div><font face=Tahoma size=2 color=black>Sehr geehrte Damen und Herren, </font></div>"
'strText = strText & "<div>&nbsp;</div>"
'strText = strText & "<div><font face=Tahoma size=2 color=black>Beiliegend Rechnung " & strrchnr & " </font></div>"
'strText = strText & "<div><font face=Tahoma size=2 color=black>Rechungs-Datum " & dtrchdat & " </font></div>"
'strText = strText & "<div>&nbsp;</div>"
'strText = strText & "<div><font face=Tahoma size=2 color=black>mit der Bitte um schnelle Erledigung </font></div>"
'strText = strText & "<div>&nbsp;</div>"
'strText = strText & "<div><font face=""Bradley Hand ITC"" size=4 color=blue><strong>Günther Siegert</strong></font></div>"
'strText = strText & "<div><font face=Arial color=""#1F497D""><strong>Head of Security DTH &nbsp;</strong></font></div>"
'strText = strText & "<div><font face=Arial size=2 color=""#1F497D""><strong>i.A. von MM-Security Kelkheim und KKT Berlin</strong></font></div>"
'strText = strText & "<div><font face=""Bookman Old Style"" size=3 color=navy><strong>CONSEC </strong></font>"
'strText = strText & "<fontface=Tahoma size=2 color=navy><strong>Veranstaltungsservice &amp; Sicherheitsdienst oHG</strong></font></div>"
'strText = strText & "<div><font face=Tahoma size=2 color=navy><strong>Vogelweiherstr. 70</strong></font></div>"
'strText = strText & "<div><font face=Tahoma size=2 color=navy><strong>90441 Nürnberg</strong></font></div>"
'strText = strText & "<div>&nbsp;</div>"
'strText = strText & "<div><font face=Tahoma size=2 color=navy><strong>0911 - 40 99 77 99 (Tel.)</strong></font></div>"
'strText = strText & "<div><font face=Tahoma size=2 color=navy><strong>0911 - 40 99 77 92 (Fax)</strong></font></div>"
'strText = strText & "<div><font face=Tahoma size=2 color=navy><strong>0171 - 20 57 404 (Mobil)</strong></font></div>"
'strText = strText & "<div><font face=Tahoma size=2 color=navy><strong>E-Mail: </strong></font>"
'strText = strText & "<fontface=Tahoma size=2 color=""#0563C1""><strong><u>siegert@consec-nuernberg.de</u></strong></font></div>"
'strText = strText & "<div><font face=Tahoma size=2 color=black>"
'strText = strText & "<a href=""http://www.consec-nuernberg.de""><strong>http://www.consec-nuernberg.de</strong></a></font></div>"
'strText = strText & "<div>&nbsp;</div>"
'strText = strText & "<div>&nbsp;</div>"
'
''Function OutlookRch(IstHTML As Variant, Bodytext As String, Betreff As String, SendTo As String, sendAs As String)
'OutlookRch True, strText, "Beiliegend Rechnung " & strrchnr & " Rechungs-Datum " & dtrchdat, strkun_email, ""
'
'End Sub

Function OutlookRch(IstHTML As Variant, Bodytext As String, Betreff As String, SendTo As String, sendAs As String)
'Function CreatePlainMail(IstHTML As Variant, Bodytext As String, Betreff As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False, Optional Voting As String = "", Optional sendAs As String = "", Optional bReadReceipt As Boolean = False, Optional strHeaderbild As String)

'  Call CreatePlainMail(IstHTML, Bodytext, Betreff, SendTo, _
'      iImportance, SendToCC, SendToBCC, myattach, IsSend, Voting, sendAs, bReadReceipt, strHeaderbild)
''  Ab 2. Reihe optional


' Parameter myattach
'-------------------
' Ein Array mit Dateinamen incl. Pfad
' Beispiel für 2 Attachs:
' Dim myattach
' myattach = Array("D:\GEZSpruch.jpg", "D:\Kulturverlust.pdf")

' Parameter IsSend
'-----------------
' IsSend = True  -- eMail wird direkt gesendet
' IsSend = False  -- eMail wird angezeigt, um sie vor dem Senden noch editieren zu können

' Parameter bReadReceipt
'-----------------
' bReadReceipt = True -- Empfangsbestätigung anfordern
' bReadReceipt = False -- Keine Empfangsbestätigung anfordern

' Parameter IstHTML
'-----------------
'IstHTML = -1 - BodyText ist im HTML Format                 |   .Bodyformat = 2  und   .HTMLBody = Bodytext
'IstHTML =  0 - BodyText ist im Plain Text / ASCII Format   |   .Bodyformat = 1  und   .Body = Bodytext

' SendTo, CC, BCC - eine Mailadresse oder mehrere duch Semikolon getrennt

'myItem.Importance 2 = High
'myItem.Importance 1 = Normal
'myItem.Importance 0 = Low

'Dim myattach
'Dim Dateiname1 As String
'    Dateiname1 = Left(Nz(Me!sub_tbl_Rch_Kopf.Form!Dateiname), Len(Nz(Me!sub_tbl_Rch_Kopf.Form!Dateiname)) - 5) & ".pdf"
'Dim Dateiname2 As String
'    Dateiname2 = Left(Nz(Me!sub_tbl_Rch_Kopf.Form!Dateiname), Len(Nz(Me!sub_tbl_Rch_Kopf.Form!Dateiname)) - 5) & "_pos.pdf"
'
'myattach = Array(Dateiname1, Dateiname2)
'
''Call CreatePlainMail(IstHTML, Bodytext, Betreff, SendTo, _
''      iImportance, SendToCC, SendToBCC, myattach, IsSend, Voting, sendAs, bReadReceipt, strHeaderbild)
'
'Call CreatePlainMail(IstHTML, Bodytext, Betreff, SendTo, _
'      , , , myattach, False, , sendAs, True)

End Function

Private Sub btnPDFKopf_Click()
Dim Dateiname1 As String
    Dateiname1 = Me!sub_tbl_Rch_Kopf.Form!Dateiname
    Application.FollowHyperlink Dateiname1
End Sub

Private Sub btnPDFPos_Click()
Dim rpt     As String
Dim Datei As String

    rpt = "zrpt_Rch_Berechnungsliste"
    Datei = PfadZuBerechnen & "test.pdf"
    
    DoCmd.OutputTo acOutputReport, rpt, "PDF", Datei
    
    Application.FollowHyperlink Datei
    
'Dim Dateiname2 As String
'Dim Dateiname1 As String
'Dim DaPfad As String
'Dim i As Long
'    Dateiname1 = Me!sub_tbl_Rch_Kopf.Form!Dateiname
'    i = InStrRev(Dateiname1, "\")
'    DaPfad = Left(Dateiname1, i)
'    i = Me!ID
'    Dateiname2 = DaPfad & "Stundenliste_Rch_" & i & ".pdf"
'    Application.FollowHyperlink Dateiname2
End Sub

Private Sub btnSchnellPlan_Click()
Dim iVA_ID As Long
Dim iVADatum_ID As Long
    
    Me.Painting = False
    
    iVA_ID = Me.ID
    iVADatum_ID = Me.cboVADatum
    
    If Nz(TCount("*", "tbl_VA_Start", "VA_ID = " & iVA_ID), 0) = 0 Then
        MsgBox "Keine Start-Ende-Zeiten definiert für diesen Auftrag"
        Exit Sub
    End If
    
    Call req_rq(iVA_ID, iVADatum_ID)
    
    'DoCmd.Close acForm, Me.Name, acSaveNo
    
    If TCount("MA_ID", ZUORDNUNG, "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID) > 0 Then
        DoCmd.OpenForm "frm_MA_VA_Schnellauswahl", , , , , , iVA_ID & " " & iVADatum_ID
    Else
        MsgBox "Keine Mitarbeiter geplant für diese Veranstaltung"
    End If

    Me.Painting = True

End Sub



Function PosNr_Einfaerben_FormatCondition_Loesch()

Dim ctl As control
Dim fcd As FormatCondition
Set ctl = Me!sub_MA_VA_Zuordnung.Form!PosNr
ctl.FormatConditions.Delete

End Function

Function PosNr_Einfaerben_FormatCondition(iVA_ID As Long, iVADatum_ID As Long)

Dim ctl As control
Dim fcd As FormatCondition
Dim i As Long, j As Long, k As Long, l As Long
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

l = 255

Set ctl = Me!sub_MA_VA_Zuordnung.Form!PosNr

recsetSQL1 = "SELECT * FROM qry_Anz_MA_Anzahl_Diff_Tag WHERE VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
With ctl.FormatConditions
    .Delete  'Alle Formatconditions löschen
    If ArrFill_DAO_OK1 Then
        For iZl = 0 To iZLMax1
            j = DAOARRAY1(4, iZl)
            i = DAOARRAY1(5, iZl)
            k = j - i + 1
                Set fcd = .Add(acFieldValue, acBetween, k, j)
                fcd.backColor = l
        Next iZl
        Set DAOARRAY1 = Nothing
    End If
End With

End Function


Private Sub btnVAPlanAendern_Click()

Me!sub_MA_VA_Zuordnung.Form.AllowDeletions = True
'Me!sub_MA_VA_Zuordnung.Form!PosNr.Enabled = True
'Me!sub_MA_VA_Zuordnung.Form!PosNr.Locked = False

MsgBox "Löschen von Mitarbeitern bis zum nächsten schliessen der Maske erlaubt"
End Sub

Private Sub btnVAPlanCrea_Click()
On Error Resume Next
Dim datimax As Long
If Len(Trim(Nz(Me!ID))) > 0 Then
    If Nz(TCount("*", "tbl_VA_Start", "VA_ID = " & Me!ID & " AND VADatum_ID = " & Me!cboVADatum.Column(0)), 0) > 0 Then
        datimax = TMax("ID", "tbl_VA_AnzTage", "VA_ID = " & Me!ID)
        Me!sub_MA_VA_Zuordnung.Form.recordSource = "tbltmp_MA_VA_Zuordnung"
        Zuord_Fill Me!cboVADatum.Column(0), Me!ID
        fTag_Schicht_Update_Tag Me!cboVADatum.Column(0), Me!ID
        Me!sub_MA_VA_Zuordnung.Form.recordSource = "tbl_MA_VA_Zuordnung"
        Me.zsub_lstAuftrag.Form.Recalc
        btnreq_Click
        Me!btnPlan_Kopie.Visible = True
        Me!sub_MA_VA_Zuordnung.Form.Requery
    End If
End If
Me!sub_VA_Start.Form.Requery
End Sub


Private Sub btnPlan_Kopie_Click()

Dim strSQL As String

Dim va_dat_id As Long
Dim va_Dat As Date
Dim va_Folgedat As Date
Dim va_Folgedat_ID As Long

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

If MsgBox("Daten in Folgetag kopieren?", vbYesNoCancel) = vbYes Then

    recsetSQL1 = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!ID & ")) ORDER By VADatum; "
    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
    
    If Me!ID > 0 And iZLMax1 > 0 And CDate(Me!cboVADatum.Column(1)) < Me!Dat_VA_Bis Then
        For iZl = 0 To iZLMax1
            If CDate(DAOARRAY1(1, iZl)) = CDate(Me!cboVADatum.Column(1)) Then Exit For
        Next iZl
        
        If iZl < iZLMax1 Then
            iZl = iZl + 1
        Else
            MsgBox "Kein Folgetag"
            Exit Sub
        End If
        va_Folgedat = DAOARRAY1(1, iZl)
        va_Folgedat_ID = DAOARRAY1(0, iZl)
        
    End If
    Set DAOARRAY1 = Nothing

    
'Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

    'Me!sub_MA_VA_Zuordnung.Form.RecordSource = "tbltmp_MA_VA_Zuordnung"
    
    'just in case
    'Löschen der tbl_VAStart-Sätze
    strSQL = "DELETE * FROM tbl_VA_Start WHERE VA_ID = " & Me!ID & " AND VADatum_ID = " & va_Folgedat_ID
    Call CurrentDb.Execute(strSQL)
    
    'Löschen der tbl_MA_VA_Zuordnung-Sätze
    strSQL = "DELETE * FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & Me!ID & " AND VADatum_ID = " & va_Folgedat_ID
    Call CurrentDb.Execute(strSQL)
    
    strSQL = ""

    strSQL = strSQL & "INSERT INTO tbl_VA_Start ( VA_ID, VADatum_ID, MA_Anzahl, VA_Start, VA_Ende, Bemerkungen, VADatum, MVA_Start, MVA_Ende )"
    strSQL = strSQL & " SELECT tbl_VA_Start.VA_ID, " & va_Folgedat_ID & " AS Ausdr1, tbl_VA_Start.MA_Anzahl, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende, tbl_VA_Start.Bemerkungen, "
    strSQL = strSQL & SQLDatum(va_Folgedat) & " AS Ausdr2, " & SQLDatum(va_Folgedat) & " AS Ausdr3, " & SQLDatum(va_Folgedat) & " AS Ausdr4"
    strSQL = strSQL & " FROM tbl_VA_Start WHERE (((tbl_VA_Start.VA_ID)= " & Me!ID & ") AND ((tbl_VA_Start.VADatum_ID)= " & Me!cboVADatum.Column(0) & "));"
    CurrentDb.Execute (strSQL)
    DoEvents

    strSQL = ""
    strSQL = strSQL & "UPDATE tbl_VA_Start SET tbl_VA_Start.MVA_Start = Startzeit_G([VADatum],[VA_Start]), tbl_VA_Start.MVA_Ende = Endezeit_G([VADatum],[VA_Start],[VA_Ende])"
    strSQL = strSQL & " WHERE tbl_VA_Start.VA_ID = " & Me!ID & ";"
    CurrentDb.Execute (strSQL)
    
    Call Zuord_Fill(va_Folgedat_ID, Me!ID)
    
    Me!sub_MA_VA_Zuordnung.Form.recordSource = "tbl_MA_VA_Zuordnung"

    DoCmd.Hourglass False
    Call btnDatumRight_Click
    
End If


End Sub

Private Sub cboAuftrSuche_AfterUpdate()
On Error Resume Next
Me.Recordset.FindFirst "ID = " & Me!cboAuftrSuche.Column(0)
End Sub

'Private Sub cboQuali_DblClick(Cancel As Integer)
'DoCmd.OpenForm "frmTop_MA_Einsatzart"
'End Sub

Private Sub cboVADatum_AfterUpdate()
'Call PosNr_Einfaerben_FormatCondition(Me!ID, Me!cboVADatum.Column(0)) ' -> In Prüfung integriert

Me!sub_VA_Start.Form!VADatum_ID.defaultValue = Chr$(34) & Me!cboVADatum.Column(0) & Chr$(34)
Me!sub_VA_Start.Form!VADatum.defaultValue = Chr$(34) & Me!cboVADatum.Column(1) & Chr$(34)


End Sub

Private Sub cboVADatum_DblClick(Cancel As Integer)
If Me!ID > 0 And Me!Dat_VA_Von < Me!Dat_VA_Bis Then
    DoCmd.OpenForm "frmTop_VA_AnzTage_sub"
    Forms!frmTop_VA_AnzTage_sub!VA_ID = Me!ID
    Forms!frmTop_VA_AnzTage_sub!VADatum_ID = Me!cboVADatum.Column(0)
    Forms!frmTop_VA_AnzTage_sub!frmTop_VA_AnzTage_subsub.Form.Requery
Else
    MsgBox " Liste nur bei Mehrfachdatum"
End If
End Sub

Private Sub Dat_VA_Bis_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub Dat_VA_Von_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub


Private Sub Dat_VA_Von_Exit(Cancel As Integer)
    If Len(Trim(Nz(Me!Dat_VA_Bis))) = 0 And Len(Trim(Nz(Me!Dat_VA_Von))) = 0 Then
        Exit Sub
    ElseIf Len(Trim(Nz(Me!Dat_VA_Bis))) = 0 And Len(Trim(Nz(Me!Dat_VA_Von))) > 0 Then
        Me!Dat_VA_Bis = Me!Dat_VA_Von
    End If
    Dat_VA_Bis_AfterUpdate
End Sub


Private Sub Dat_VA_Bis_AfterUpdate()
Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long, iAnz As Long
Dim dtdat As Date
Dim strSQL As String
DoCmd.RunCommand acCmdSaveRecord


If datbis_vgl = Me!Dat_VA_Bis And Not IsInitial(Me.cboVADatum) Then
    Exit Sub
Else
    datbis_vgl = Me!Dat_VA_Bis
End If

strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!ID & "));"

If Len(Trim(Nz(Me!Dat_VA_Bis))) = 0 Then
    Me!Dat_VA_Bis = Me!Dat_VA_Von
End If
If Not (IsDate(Me!Dat_VA_Von) Or IsDate(Me!Dat_VA_Bis)) Then
    MsgBox "Bitte berichtigen Sie das Datum"
    Exit Sub
End If
If Me!Dat_VA_Bis < Me!Dat_VA_Von Then
    MsgBox "Bitte berichtigen Sie die Datumsreihenfolge - Bis < Von"
    Me!Dat_VA_Bis = Null
    Me!Dat_VA_Bis.SetFocus
    Exit Sub
End If
'CurrentDb.Execute ("DELETE * FROM tbl_VA_AnzTage WHERE VA_ID = " & Me!ID & ";")
DoEvents

i = Nz(TCount("*", "tbl_VA_AnzTage", "VA_ID = " & Me!ID & " AND VADatum BETWEEN " & SQLDatum(Me!Dat_VA_Von) & " AND " & SQLDatum(Me!Dat_VA_Bis)), 0)
If i > 0 Then
    dtdat = TMax("VADatum", "tbl_VA_AnzTage", "VA_ID = " & Me!ID & " AND VADatum BETWEEN " & SQLDatum(Me!Dat_VA_Von) & " AND " & SQLDatum(Me!Dat_VA_Bis))
    iAnz = Fix(Me!Dat_VA_Bis) - Fix(dtdat)
Else
    iAnz = Fix(Me!Dat_VA_Bis) - Fix(Me!Dat_VA_Von)
    dtdat = Fix(Me!Dat_VA_Von)
End If

If iAnz >= 0 Then
    Set db = CurrentDb
    Set rst = db.OpenRecordset("SELECT top 1 * FROM tbl_VA_AnzTage;")
    With rst
        For i = 0 To iAnz
            .AddNew
                .fields(1).Value = Me!ID
                .fields(2).Value = dtdat
                dtdat = dtdat + 1
    On Error Resume Next
            .update
    Err.clear
    On Error GoTo 0
        Next i
        .Close
    End With
    Set rst = Nothing
End If

Me!cboVADatum.RowSource = strSQL
Me!cboVADatum = Me!cboVADatum.ItemData(0)
Me.zsub_lstAuftrag.Form.Requery

End Sub


Private Sub Form_BeforeUpdate(Cancel As Integer)
On Error Resume Next
'Call Protokollieren

    Me!Aend_am = Now()
    Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
        

End Sub
'Public Function Protokollieren()
'Dim F As Form, C As Control, ctl As Control
'Dim strID As String
'On Error Resume Next
'Set F = Screen.activateform
'Set C = Screen.ActiveControl
'If Err <> 0 Then
'Beep
'MsgBox "Kein Formular geöffnet oder kein Steuerelement aktiviert...", _
'vbOKOnly + vbExclamation, "Protokollieren:"
'Exit Function
'End If
'strID = ""
'For Each ctl In F.Controls
'If ctl.Tag = "DSID" Then
'strID = strID & CStr(ctl.Value)
'End If
'Next ctl
'If strID = "" Then
'Beep
'MsgBox "Kein Feld als 'DSID' gekennzeichnet!", _
'vbOKOnly + vbExclamation, "Protokollieren:"
'Exit Function
'End If
'
'cntProtokoll = cntProtokoll + 1
'arrProtokoll(cntProtokoll, 1) = CurrentDb.Name
'arrProtokoll(cntProtokoll, 2) = F.Name
'arrProtokoll(cntProtokoll, 3) = C.Name
'arrProtokoll(cntProtokoll, 4) = CStr(C.OldValue)
'arrProtokoll(cntProtokoll, 5) = CStr(C.Value)
'arrProtokoll(cntProtokoll, 6) = Now
'arrProtokoll(cntProtokoll, 7) = CurrentUser() & "/" & NetworkComputerName()
'arrProtokoll(cntProtokoll, 8) = strID
'End Function



Private Sub Form_Current()

'Debug.Print "VA_Auftragstamm: " & Me.Dirty

On Error Resume Next
'Call Protokollstart

Dim strSQL As String
Dim i As Long

Dim iPKWAnz As Long

Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim stKurz As String
Dim idat_va_bis As Date
Dim idate As SYSTEMTIME
Dim SDatum As Date
Dim exceleinsatzliste As Object
Dim jetzt As Date
Dim xl As Object
Me!sub_MA_VA_Zuordnung.Form.AllowDeletions = True

'iPKWAnz = Nz(TSum("PKW_Anzahl", "tbl_VA_Auftragstamm", "ID = " & Me!ID), 0)
'If iPKWAnz > 0 Then
'    Me!PKW_Anzahl = iPKWAnz
'End If

'If Len(Trim(Nz(Me!ID))) = 0 Then
'    Me!pgAttach.Visible = False
'    Exit Sub
'End If
'Me!btn_std_check.Visible = True

Me!PosGesamtsumme = Nz(TSum("GesPreis", "tbl_Rch_Pos_Auftrag", "VA_ID = " & Me!ID), 0)

Me!btnPlan_Kopie.Visible = True

strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!ID & "));"
'i = rstDcount("*", strsql)
i = TCount("*", anzTage, "VA_ID = " & Me.ID)
If i > 1 Then
    Me!btnPlan_Kopie.Visible = True
Else
    Me!btnPlan_Kopie.Visible = False
End If

Me!cboVADatum.RowSource = strSQL
Me!cboVADatum = Me!cboVADatum.ItemData(0)
If Nz(Me!Objekt_ID, 0) = 0 Then
    Me!pgAttach.Visible = False
    Me!Objekt_ID.backColor = 16777215
Else
    iVA_ID = Me!ID
    iVADatum_ID = Me!cboVADatum
    
    Me!pgAttach.Visible = True
    Me!Objekt_ID.backColor = 11063436
    
    stKurz = iVA_ID & "_" & iVADatum_ID
    i = Nz(TLookup("ZusatzNr", "tbl_Zusatzdateien", "TabellenID = 42 AND Kurzbeschreibung = '" & stKurz & "'"), 0)
    If i > 0 Then
        Me!btnmailpos.Visible = True
    Else
        Me!btnmailpos.Visible = False
    End If
    
End If
If Me!sub_MA_VA_Zuordnung.PKW = "" Then
'And (Me!sub_MA_VA_Zuordnung.MA_Ende Is Not Null) And (Me!sub_MA_VA_Zuordnung.MA_ID Is Not Null) Then
Me!btn_std_check.Visible = True
Else: Me!btn_std_check.Visible = True
End If

If Len(Trim(Nz(Me!Bemerkungen))) = 0 Then
    Me!pgBemerk.Visible = False
Else
    Me!pgBemerk.Visible = True
End If


If Me!Veranst_Status_ID >= 3 Then
    Me!btnAuftrBerech.Visible = True
'    Me!btnAuftrBerech.Visible = False
    Me!pgRechnung.Visible = True

End If

'If Me!Veranst_Status_ID >= 3 Then
'    Me!pgRechnung.Visible = True
'
'
'Else
'    Me!pgRechnung.Visible = False
'End If

If Me!ID > 0 Then
    DoEvents

'    Me!lbl_Auftrag.Caption = Me!Auftrag
'    Me!lbl_Objekt.Caption = Me!Objekt
    Veranst_Status_ID_AfterUpdate
    Me!sub_VA_Start.Form!VADatum_ID.defaultValue = Chr$(34) & Me!cboVADatum.Column(0) & Chr$(34)
    Me!sub_VA_Start.Form!VADatum.defaultValue = Chr$(34) & Me!cboVADatum.Column(1) & Chr$(34)
    Me!Auftrag.SetFocus
    datbis_vgl = Me!Dat_VA_Bis
Else
'    Me!lbl_Auftrag.Caption = ""
'    Me!lbl_Objekt.Caption = ""
End If

'Debug.Print Me!ID
'Debug.Print Me!cboVADatum

'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents

Me!sub_MA_VA_Zuordnung.Form.Requery
DoEvents
' If Dir("\\consecpc5\e\TERASTATION 13.06.14\CONSEC\CONSEC PLANUNG AKTUELL\e aufträge 2015 noch zu berechnen\", sdatum & " " & Auftrag & " " & Objekt & ".xlsm") <> "" Then
'Exit Sub
'Else
'   Call fXL_Export_Auftrag(ID, "\\consecpc5\e\TERASTATION 13.06.14\CONSEC\CONSEC PLANUNG AKTUELL\e aufträge 2015 noch zu berechnen\", sdatum & " " & Auftrag & " " & Objekt & ".xlsm")
'End If
'If Dir("\\consecpc5\e\TERASTATION 13.06.14\CONSEC\CONSEC PLANUNG AKTUELL\e aufträge 2015 noch zu berechnen\", sdatum & " " & Auftrag & " " & Objekt & ".xlsm") <> "" Then
'Exit Sub
'End If
'If Me!sub_MA_VA_Zuordnung.MA_ID > 0 And Me!sub_MA_VA_Zuordnung.MA_Ende > 0 Then
'btn_std_check.Visible = True
'Else
'btn_std_check.Visible = False
'End If


'ID für Rechnung
Set_Priv_Property "prp_rpt_rch_va_id", Me.ID


  If Me.Veranstalter_ID = 20760 Then
     ' AUSBLENDEN bei Veranstalter 20760
     Me.sub_MA_VA_Zuordnung.Form.Controls("PKW").Visible = False
     Me.sub_MA_VA_Zuordnung.Form.Controls("Einsatzleitung").Visible = False
     Me.cmd_Messezettel_NameEintragen.Visible = True
     Me.cmd_BWN_send.Visible = True
     ' Optional: Auch Spaltenüberschriften ausblenden
On Error Resume Next
     Me.sub_MA_VA_Zuordnung.Form.Controls("PKW_Label").Visible = False
     Me.sub_MA_VA_Zuordnung.Form.Controls("EL_Label").Visible = False
On Error GoTo 0
 Else
     ' EINBLENDEN bei anderen Veranstaltern
     Me.sub_MA_VA_Zuordnung.Form.Controls("PKW").Visible = True
     Me.sub_MA_VA_Zuordnung.Form.Controls("Einsatzleitung").Visible = True
      Me.cmd_Messezettel_NameEintragen.Visible = False
  Me.cmd_BWN_send.Visible = False
On Error Resume Next
     Me.sub_MA_VA_Zuordnung.Form.Controls("Bezeichnungsfeld51").Visible = True
     Me.sub_MA_VA_Zuordnung.Form.Controls("Einsatzleitung_Label").Visible = True
On Error GoTo 0

 End If

End Sub

Public Function f_AbWann()
btn_AbWann_Click
End Function

Private Sub Auftraege_ab_Exit(Cancel As Integer)
btn_AbWann_Click
End Sub

Private Sub btnTgVor_Click()
Me!Auftraege_ab = Me!Auftraege_ab + 3
DoEvents
btn_AbWann_Click
End Sub


Private Sub btnTgBack_Click()
Me!Auftraege_ab = Me!Auftraege_ab - 3
DoEvents
btn_AbWann_Click
End Sub


Private Sub btnHeute_Click()
Me!Auftraege_ab = Date
Me!IstStatus = -5
DoEvents
btn_AbWann_Click
End Sub

Private Sub btn_AbWann_Click()

Dim strSQL As String
Dim strSQL2 As String

    
    strSQL2 = " WHERE 1 = 1"
    If Len(Trim(Nz(Me!Auftraege_ab))) > 0 Then
        strSQL2 = strSQL2 & " AND (((tbl_VA_AnzTage.VADatum) >= " & SQLDatum(Me!Auftraege_ab) & "))"
    End If
    If Me!IstStatus <> -5 Then
        strSQL2 = strSQL2 & " AND ((tbl_VA_Auftragstamm.Veranst_Status_ID)= " & Me!IstStatus & ")"
    End If
    
    strSQL = ""
    
    strSQL = strSQL & "SELECT tbl_VA_Auftragstamm.ID, tbl_VA_AnzTage.VADatum AS Datum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort, "
    strSQL = strSQL & " tbl_VA_AnzTage.TVA_Soll AS Soll, tbl_VA_AnzTage.TVA_Ist AS Ist, tbl_Veranst_Status.Fortschritt AS Status, tbl_VA_AnzTage.ID, tbl_KD_Kundenstamm.kun_Firma"
    strSQL = strSQL & " FROM (tbl_KD_Kundenstamm RIGHT JOIN (tbl_VA_Auftragstamm LEFT JOIN tbl_Veranst_Status ON tbl_VA_Auftragstamm.Veranst_Status_ID = tbl_Veranst_Status.ID) "
    strSQL = strSQL & " ON tbl_KD_Kundenstamm.kun_Id = tbl_VA_Auftragstamm.Veranstalter_ID) LEFT JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
    strSQL = strSQL & strSQL2
    
    
    strSQL = strSQL & " ORDER BY tbl_VA_AnzTage.VADatum, tbl_VA_Auftragstamm.Auftrag, tbl_VA_Auftragstamm.Objekt" 'NEU FÜR FORMULAR AUFTRAGSLISTE
    
    If Not CreateQuery(strSQL, "qry_lst_Row_Auftrag") Then
        Stop
        MsgBox "Muuuhhh"
    End If
    
    
    Me.zsub_lstAuftrag.Form.recordSource = "qry_lst_Row_Auftrag"

End Sub



'Private Sub istAlleTage_AfterUpdate()
'If Me!istAlleTage = False Then
'    Me!istAlleTage.Caption = "Druck Einsatzliste: Tag"
'Else
'    Me!istAlleTage.Caption = "Druck Einsatzliste: kpl"
'End If
'Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", Me!istAlleTage)
'
'End Sub

Private Sub IstStatus_AfterUpdate()
btn_AbWann_Click
End Sub

Public Function f_lst_Auft_Cl()

Call lstRowAuftrag_Click(Me.ID, Me.cboVADatum)

End Function


'Hier werden die Vergleichszeiten aufgebaut
Function f_lstZeiten_upd()

Dim strSQL As String
Dim von As Date
Dim bis As Date

    'Veranstaltungszeiten
    von = Me.cboVADatum.Column(1) & " " & Me.sub_VA_Start.Controls("VA_Start")
    If Not IsNull(Me.sub_VA_Start.Controls("VA_Ende")) Then
        bis = Me.sub_VA_Start.Controls("VA_Ende")
    Else
        bis = DateAdd("n", 270, von) ' Wenn keine Endzeit dann Start + 4,5h
    End If
    
    'BERECHNUNG NEU
    Call upd_Vergleichszeiten(Me.ID, von, bis)
    
End Function

Public Function fMA_Selektion_AfterUpdate()
MA_Selektion_AfterUpdate
End Function

Private Sub cboAnstArt_AfterUpdate()
MA_Selektion_AfterUpdate
End Sub

'Private Sub cboQuali_AfterUpdate()
'MA_Selektion_AfterUpdate
'End Sub

Private Sub IstVerfuegbar_AfterUpdate()
If Me!IstVerfuegbar = True Then
    Me!lbl_NurFreie.caption = "Nur freie anzeigen"
Else
    Me!lbl_NurFreie.caption = "Alle anzeigen"
End If
MA_Selektion_AfterUpdate
End Sub



Private Sub MA_Selektion_AfterUpdate()

Dim strSQL As String
Dim sto As String
Dim st As String

sto = " Order by MAName"

strSQL = ""
If Me!MA_Selektion = 1 Then
    strSQL = "SELECT ID, MAName AS Name, ID as PersNr From tbltmp_MA_Verfueg_tmp WHERE 1 = 2"
ElseIf Me!MA_Selektion = 2 Then
    strSQL = "SELECT ID, MAName AS Name, ID AS PersNr From tbltmp_MA_Verfueg_tmp WHERE IstAktiv = True"
End If
'If Me!cboQuali > 1 Then
'    strSQL = strSQL & " AND ID In(SELECT MA_ID FROM tbl_MA_Einsatz_Zuo WHERE Quali_ID = " & Me!cboQuali & ")"
'End If
If Me!IstVerfuegbar = True Then
    strSQL = strSQL & " AND IstVerfuegbar = True"
End If
If Me!cboAnstArt <> 9 Then
    strSQL = strSQL & " AND Anstellungsart_ID = " & Me!cboAnstArt
End If
If Me!cboAnstArt = 9 Then
    strSQL = strSQL & " AND Anstellungsart_ID = 3 or anstellungsart_ID = 5"
strSQL = strSQL & " AND IstVerfuegbar = True"
    End If

Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.RowSource = strSQL & sto
st = strSQL & sto

'CurrentDb.Execute ("UPDATE tbltmp_MA_Verfueg_tmp SET tbltmp_MA_Verfueg_tmp.IstVerfuegbar = -1;")

'iVerfueg = 0
'If bVerfueg Then
'    Call fCreateQuery_Verplant(Me!MVA_Start, Me!MVA_Ende)
'    DoEvents
'    iVerfueg = Nz(TCount("*", "qry_VV_tmp_belegt"), 0)
'    DoEvents
'    CurrentDb.Execute ("DELETE * FROM tbltmp_VV_Belegt")
'    If iVerfueg > 0 Then
'        CurrentDb.Execute ("qry_VV_tmp_belegt_ADD")
'        CurrentDb.Execute ("qry_VV_Upd_Verfueg_All")
'    End If
'End If


End Sub

Private Sub Objekt_DblClick(Cancel As Integer)

Dim i As Long
Dim strSQL As String

Call Set_Priv_Property("prp_Akt_VA_ID", Me!ID)


If Me!Objekt_ID > 0 Then
    i = Nz(TLookup("ID", "tbl_VA_Akt_Objekt_Kopf", "VA_ID = " & Me!ID & " AND VADatum_ID = " & Me!cboVADatum & " AND OB_Objekt_Kopf_ID = " & Me!Objekt_ID), 0)
    If i = 0 Then
    
        strSQL = ""
        strSQL = strSQL & "INSERT INTO tbl_VA_Akt_Objekt_Kopf ( VA_ID, OB_Objekt_Kopf_ID, VADatum_ID, VADatum )"
        strSQL = strSQL & " SELECT " & Me!ID & " AS Ausdr1, " & Me!Objekt_ID & " AS Ausdr2, " & Me!cboVADatum & " AS Ausdr3, " & SQLDatum(Me!cboVADatum.Column(1)) & " AS Ausdr4"
        strSQL = strSQL & " FROM _tblInternalSystemFE;"
        CurrentDb.Execute (strSQL)
        i = TMax("ID", "tbl_VA_Akt_Objekt_Kopf")
    End If
    
    DoCmd.OpenForm "frmTop_VA_Akt_Objekt_Kopf"
    Form_frmTop_VA_Akt_Objekt_Kopf.VAOpen_ID i
    
Else
    MsgBox "Bitte erst Objekt zuordnen"
'    DoCmd.OpenForm "frm_OB_Objekt", , , , acFormAdd
End If

End Sub

Private Sub Objekt_Exit(Cancel As Integer)
Dim i As Long
If Len(Trim(Nz(Me!Objekt_ID))) = 0 Then
    i = Nz(TLookup("ID", "tbl_ON_Objekt", "Objekt = '" & Me!Objekt & "'"), 0)
    If i > 0 Then
        'If vbOK = MsgBox("Positionsliste verfügbar, zuordnen ?", vbQuestion + vbOKCancel, Me!Objekt) Then
            Me!Obkjekt_ID = i
            Objekt_ID_AfterUpdate
        End If
    End If
'End If
End Sub

Private Sub Objekt_ID_AfterUpdate()
Dim strSQL As String
btn_Posliste_oeffnen.Visible = True
btnmailpos.Visible = True
Me!Objekt_ID.backColor = 11063436
DoCmd.RunCommand acCmdSaveRecord
Me!pgAttach.Visible = True
DoEvents

End Sub


Private Sub Objekt_ID_DblClick(Cancel As Integer)
If Me!Objekt_ID > 0 Then
    DoCmd.OpenForm "frm_OB_Objekt", , , "ID = " & Me!Objekt_ID
Else
    DoCmd.OpenForm "frm_OB_Objekt", , , , acFormAdd
End If

End Sub
'
'Private Sub Reg_VA_Change()
'
''Dim strSQL As String
''Dim i As Long
''Dim rst As DAO.Recordset
''Dim strCriteria As String
''Dim j As Long
''
''i = Me!RegStammKunde
''Select Case Me!RegStammKunde.Pages(i).Name
''
''  Case "pgRechnung"
'
'
'    'Planung sortieren
'    If Me.Reg_VA = 1 Then Call sort_zuo_plan(Me.ID, Me.cboVADatum, 2)
'
'    'Rechnungsdaten laden
'    If Me.Reg_VA = 3 Then
'        If TCount("*", RCHLIST, "VA_ID=" & Me.ID) = 0 Then
'            Call fill_Berechnungsliste(Me.ID)
'            Me.sub_Berechnungsliste.Form.Requery
'            Me.PosGesamtsumme.Requery
'        End If
'    End If
'
'End Sub

'Private Sub sub_MA_VA_Zuordnung_Enter()
''Dim i As Long
''i = Me!sub_MA_VA_Zuordnung.Form!MA_ID.ColumnWidth
'Me!sub_MA_VA_Zuordnung.Form!MA_ID.Enabled = True
'If Get_Priv_Property("prp_Doppeltes_Lottchen") = 0 Then
'    Me!sub_MA_VA_Zuordnung.Form!MA_ID.ColumnHidden = False
'End If
'Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.ColumnHidden = False
''Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.ColumnWidth = i
'End Sub
'
'Private Sub sub_MA_VA_Zuordnung_Exit(Cancel As Integer)
'Dim i As Long
'On Error Resume Next
'Me!sub_MA_VA_Zuordnung.Form!MA_ID.ColumnHidden = False
'Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.ColumnHidden = False
'Me!sub_MA_VA_Zuordnung.Form!MA_ID.ColumnHidden = False
'Me!sub_MA_VA_Zuordnung.Form!MA_ID.Enabled = True
'DoCmd.RunCommand acCmdSaveRecord
'Me!sub_VA_Start.Form.Requery
'End Sub

Private Sub sub_VA_Start_Enter()
On Error Resume Next
DoCmd.RunCommand acCmdSaveRecord
Me!sub_VA_Start.Form!VADatum_ID.defaultValue = Chr$(34) & Me!cboVADatum.Column(0) & Chr$(34)
Me!sub_VA_Start.Form!VADatum.defaultValue = Chr$(34) & Me!cboVADatum.Column(1) & Chr$(34)
'Me!sub_VA_Start.Form!VA_Treffpunkt.DefaultValue = Chr$(34) & Format(Me!cboVADatum.Column(1), "dd.mm.yyyy") & Chr$(34)
End Sub

Private Sub sub_MA_VA_Zuordnung_Exit(Cancel As Integer)

On Error Resume Next
    Me.zsub_lstAuftrag.Form.Recalc
    
End Sub


Private Sub sub_MA_VA_Zuordnung_Enter()

On Error Resume Next
    Me.zsub_lstAuftrag.Form.Recalc
    
End Sub


Private Sub sub_VA_Start_Exit(Cancel As Integer)

Dim VADatum As String
   
On Error Resume Next
    
    'Tag merken
    VADatum = Me.cboVADatum.Value
    
    DoCmd.RunCommand acCmdSaveRecord
    
    SysCmd acSysCmdInitMeter, "Bitte warten...", 100
    DoCmd.Hourglass True
    
    'btnVAPlanCrea_Click ' SCHWEINSKRAM!
    'Prüfen, ob genügend Vorbelegungssätze vorhanden sind, falls nicht -> einfügen
    Call check_Anzahl_MA(Me.ID, Me.cboVADatum)
    Call sort_zuo_plan(Me.ID, Me.cboVADatum, 1)
    
    'Aufträge aktualisieren
    Me.zsub_lstAuftrag.Form.Recalc
    
    'Tag wieder setzen
    Me.cboVADatum.Value = VADatum
    Call cboVADatum_AfterUpdate
    
    'Stunden berechnen -> berechnete Felder -> nur Anpassung Start und Endzeiten!
    Call zfStundenberech(Me.ID)
    
    'Änderungsprotokoll prüfen (hat Fehler bei kopierten auf
    Call check_Ersteller(Me.ID)
    
    SysCmd acSysCmdRemoveMeter
    DoCmd.Hourglass False
    
End Sub

'Prüfung, ob Treffpunktzeit korrekt eingegeben wurde
Private Sub Treffp_Zeit_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!Treffp_Zeit.Text
        If Not st = "" Then
            If Not IsNumeric(st) And Not st Like "[0-9][0-9]:[0-9][0-9]" Then
               Me!Treffpunkt.Undo
               MsgBox "Bitte Treffpunktzeit im Format 'hh:mm' oder 'hhmm' eingeben!"
               Exit Sub
            End If
            If Len(Trim(Nz(st))) < 3 Then
                s = st
                m = 0
            Else
                s = Left(st, 2)
                m = Right(st, 2)
            End If
            uz = CDate(TimeSerial(s, m, 0))
            Me!Treffp_Zeit = uz
        End If
        
        Me!Treffpunkt.SetFocus
        
    End If

End Sub


Private Sub Veranst_Status_ID_AfterUpdate()

On Error Resume Next
'Dim exceleinsatzliste As Object
'Dim sdatum As Date

DoCmd.RunCommand acCmdSaveRecord
Me.zsub_lstAuftrag.Form.Recalc
Me!veranst_status_is = 1
If Me!Dat_VA_Bis > Date Then
Me!veranst_status.ID = 2
End If

Me!btnAuftrBerech.Visible = False
If Me!Veranst_Status_ID > 3 Then
    Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.ColumnHidden = True
    Me!sub_MA_VA_Zuordnung.Locked = True
    Me!sub_VA_Start.Locked = True
    Me!sub_MA_VA_Planung_Absage.Locked = True
    Me!lbl_KeineEingabe.Visible = True
'    Me!btnVAPlanCrea.Visible = False
    Me!btnVAPlanAendern.Visible = False
    Me!lbl_rechnungsnr.Visible = True
    Me!Rech_NR.Visible = True
Else
    Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.ColumnHidden = False
    Me!sub_MA_VA_Zuordnung.Locked = False
    Me!sub_VA_Start.Locked = False
    Me!sub_MA_VA_Planung_Absage.Locked = False
    Me!lbl_KeineEingabe.Visible = False
'    Me!btnVAPlanCrea.Visible = True
    Me!btnVAPlanAendern.Visible = True
    Me!lbl_rechnungsnr.Visible = False
    Me!Rech_NR.Visible = False
End If

If Me!Veranst_Status_ID = 3 Then
    Me!Abschlussdatum = Date
    Me!btnAuftrBerech.Visible = True
    
End If

End Sub

Private Sub Veranst_Status_ID_BeforeUpdate(Cancel As Integer)
If Me!Veranst_Status_ID.OldValue > 3 And Me!Veranst_Status_ID.Value < Me!Veranst_Status_ID.OldValue Then
    If vbOK = MsgBox("Status herabsetzen", vbQuestion + vbOKCancel, "Statusänderung, Sind Sie sicher ?") Then
        Exit Sub
    Else
        Me!Veranst_Status_ID.Undo
        Cancel = True
'        Me.btn_std_check.Visible = True
        Me.btnDruckZusage.Visible = True
        
        Exit Sub
    End If
End If
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

Private Sub Veranstalter_ID_KeyDown(KeyCode As Integer, Shift As Integer)

On Error Resume Next
    If KeyCode = 9 Or KeyCode = 13 Then
        Forms!frm_VA_Auftragstamm!sub_VA_Start.SetFocus
        Forms!frm_VA_Auftragstamm!sub_VA_Start!MA_Anzahl.SetFocus
    End If

End Sub


Function tbl_ma_mitarbeiterstamm()
DoCmd.OpenTable "tbl_ma_mitarbeiterstamm"

End Function


Function lstRowAuftrag_Click(Auftrag As Long, anzTage As Long)

On Error Resume Next

Dim iID_AnzTage As Long
    
    iID_AnzTage = anzTage
    Me.Recordset.FindFirst "ID = " & Auftrag
    Me.cboVADatum = iID_AnzTage
    
    'Verfügbarkeiten
    SysCmd acSysCmdInitMeter, "Bitte warten...", 100
    DoCmd.Hourglass True
    Call Me.sub_MA_VA_Zuordnung.Form.reload
    
    'Prüfen, ob genügend Vorbelegungssätze vorhanden sind, falls nicht -> einfügen
    Call check_Anzahl_MA(Me.ID, Me.cboVADatum)
    'Zuordnung sortieren
    Call sort_zuo_plan(Me.ID, Me.cboVADatum, 1)
    
    SysCmd acSysCmdRemoveMeter
    DoCmd.Hourglass False
    
End Function


' Änderungsprotokoll anpassen bei kopierten Aufträgen
Function check_Ersteller(VA_ID As Long)

Dim rs As Recordset
Dim sql As String
Dim erst As String
Dim edat As Date
    
    sql = "SELECT * FROM " & ZUORDNUNG & " WHERE VA_ID = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql)
    
    Do
        If IsInitial(rs.fields("Erst_von")) And Not IsInitial(rs.fields("Aend_von")) Then
            rs.Edit
            rs.fields("Erst_von") = rs.fields("Aend_von")
            rs.fields("Aend_von") = Null
            rs.fields("Erst_am") = rs.fields("Aend_am")
            rs.fields("Aend_am") = Null
            rs.update
        End If
        rs.MoveNext
    Loop While Not rs.EOF

End Function

