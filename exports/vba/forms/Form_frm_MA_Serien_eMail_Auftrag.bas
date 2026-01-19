VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_MA_Serien_eMail_Auftrag"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim b_Alles_Checken As Boolean

'für Autoreply notwendig sonst strIntern immer ""
Dim strIntern As String

Private Sub btnAttachSuch_Click()
Dim s As String
s = AlleSuch()
If Len(Trim(Nz(s))) = 0 Then Exit Sub
If Len(Trim(Nz(s))) > 0 Then
    CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
    Me!sub_tbltmp_Attachfile.Form.Requery
End If
End Sub

Private Sub btnAttLoesch_Click()
CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
Me!sub_tbltmp_Attachfile.Form.Requery
End Sub

Private Sub btnPDFCrea_Click()
Dim Ueber_Pfad As String
Dim PDF_Datei As String
Dim s As String

    Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 9"))
    Ueber_Pfad = Ueber_Pfad & "Allgemein\"
    
    Call Path_erzeugen(Ueber_Pfad, False, True)
    
    
    PDF_Datei = Ueber_Pfad & TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & " " & TLookup("Objekt", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & _
        " am " & TLookup("Dat_VA_Von", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & ".pdf"
    
    Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!VA_ID)
    Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", Me!cboVADatum)
    
    DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei
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
       
    s = PDF_Datei
    If Len(Trim(Nz(s))) > 0 Then
        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
        Me!sub_tbltmp_Attachfile.Form.Requery
    End If


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


Private Sub btnPosListeAtt_Click()
Dim s As String
Dim iVA_ID As Long
Dim iVADatum_ID As Long
Dim i As Long
Dim stKurz As String

iVA_ID = Me!VA_ID
iVADatum_ID = Me!cboVADatum
stKurz = iVA_ID & "_" & iVADatum_ID

s = Nz(TLookup("Dateiname", "tbl_Zusatzdateien", "TabellenID = 42 AND Kurzbeschreibung = '" & stKurz & "'"))
If Not File_exist(s) Then s = ""
If Len(Trim(Nz(s))) > 0 Then
    CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
    Me!sub_tbltmp_Attachfile.Form.Requery
End If

End Sub

Private Sub btnSchnellPlan_Click()
Dim iVA_ID As Long
Dim iVADatum_ID As Long


    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    
If Len(Trim(Nz(Me!VA_ID))) = 0 Then
    DoCmd.OpenForm "frm_MA_VA_Schnellauswahl"
Else

    iVA_ID = Me!VA_ID
    iVADatum_ID = Me!cboVADatum
    DoCmd.Close acForm, Me.Name
    DoCmd.OpenForm "frm_MA_VA_Schnellauswahl"
    Call Form_frm_MA_VA_Schnellauswahl.VAOpen(iVA_ID, iVADatum_ID)

End If
End Sub

Private Sub btnSendEmail_Click()

Dim var As Variant
Dim var1 As Variant
Dim str
Dim VertragNr As String
Dim k As Long
Dim strErr As String
Dim i As Long
Dim ii As Long
Dim m As Long
Dim strsendTo As String
    
Dim VAStart_ID() As Long
Dim strSendAll() As String
Dim strSendSelected As String

'On Error Resume Next
'DoCmd.RunCommand acCmdSaveRecord

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
       
'Nichts zu senden
    If Len(Trim(Nz(Me!VA_ID))) = 0 Or Len(Trim(Nz(Me!Betreffzeile))) = 0 Or Len(Trim(Nz(Me!Textinhalt))) = 0 Then
        MsgBox "Veranstaltung, Betreffzeile bzw. eMailText nicht eingegeben", vbCritical + vbOKOnly, "Abbruch"
        Exit Sub
    End If
    
'Absender und Voting leer
    If b_Alles_Checken Then
        If Len(Trim(Nz(Me!AbsendenAls))) = 0 Or Len(Trim(Nz(Me!Voting_Text))) = 0 Then
            If vbCancel = MsgBox("Abbruch ? Absender oder Voting Text nicht angegebent:" & vbNewLine & strErr, vbQuestion + vbOKCancel, "SendenAls oder VotingText ist leer") Then
                Exit Sub
            End If
        End If
    End If
       
    'SUB-Einsatzliste?
    If Me.cboeMail_Vorlage = 11 Then
        Dim sql     As String
        Dim rs      As Recordset
        Dim MA_ID   As Long
        Dim Email   As String
        Dim Body    As String
        Dim Subject As String
        Dim PDF     As String
        Dim sqlLog
        sql = Replace(Me.lstMA_Plan.RowSource, "SELECT *", "SELECT DISTINCT MA_ID, Email")
        Set rs = CurrentDb.OpenRecordset(sql)
        Do While Not rs.EOF
            MA_ID = rs.fields("MA_ID")
            'Anhang
            PDF = pdf_erstellen_einsatzliste_sub(Me.VA_ID, MA_ID)
            Email = rs.fields("Email")
            If Email = "" Then Email = Nz(TLookup("Tel_Festnetz", MASTAMM, "ID = " & MA_ID), "")
            If Email <> "" Then
                Subject = Textbau_Ersetz(Me.Betreffzeile, Me.VA_ID, Me.cboVADatum, Me.lstZeiten.Column(0))
                Body = Textbau_Ersetz(Me.Textinhalt, Me.VA_ID, Me.cboVADatum, Me.lstZeiten.Column(0))
                Body = Replace(Body, "[A_Sender]", "")
                send_Mail Email, Subject, Body, PDF
            End If
'           If TLookup("Veranst_Status_ID", AUFTRAGSTAMM, "ID = " & rsA.Fields("ID")) < 3 Then _
'              TUpdate "Veranst_Status_ID = 3", AUFTRAGSTAMM, "ID = " & rsA.Fields("ID"), BackendDB ' -> Status gesendet
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
        
        MsgBox "Versendet", vbInformation
        Call btnAuftrag_Click
        
    Else
        strErr = ""
        k = 0
        m = 0
        If Me!lstZeiten.ColumnHeads = True Then k = 1
        If Me!lstMA_Plan.ColumnHeads = True Then m = 1
        i = 0
    'Selected füllen
        ii = 0
        strSendSelected = ""
        If Me!IstAlleZeiten = True Then
            For Each var In Me!lstMA_Plan.ItemsSelected
                 ii = ii + 1
                 If Len(Trim(Nz(Me!lstMA_Plan.Column(5, var)))) > 0 Then
                     strSendSelected = strSendSelected & Me!lstMA_Plan.Column(5, var) & "; "
                 End If
            Next var
            If Len(strSendSelected) > 2 Then strSendSelected = Left(strSendSelected, Len(strSendSelected) - 2)
        End If
    
    'eMail Check und eMail-EmpfängerListe füllen
    'Alle füllen
        For var = k To Me!lstZeiten.ListCount - 1
            ReDim Preserve strSendAll(i)
            ReDim Preserve VAStart_ID(i)
            Me.lstZeiten.selected(var) = True
            Sleep 10
            DoEvents
            IstPlanAlle_AfterUpdate
            DoEvents
            VAStart_ID(i) = Me!lstZeiten.Column(0)
            strSendAll(i) = ""
            For var1 = m To Me!lstMA_Plan.ListCount - 1
                If Len(Trim(Nz(Me!lstMA_Plan.Column(5, var1)))) = 0 Then
                    strErr = strErr & Me!lstMA_Plan.Column(7, var1) & ", " & Me!lstMA_Plan.Column(8, var1) & vbNewLine
                Else
                    strSendAll(i) = strSendAll(i) & Me!lstMA_Plan.Column(5, var1) & "; "
                End If
            Next var1
            If Len(strSendAll(i)) > 2 Then strSendAll(i) = Left(strSendAll(i), Len(strSendAll(i)) - 2)
            i = i + 1
        Next var
        i = i - 1
        
        If b_Alles_Checken Then
            If Len(Trim(Nz(strErr))) > 0 Then
                If vbCancel = MsgBox("Abbruch ? Bei folgenden Mitarbeitern ist keine eMail-Adresse hinterlegt:" & vbNewLine & strErr, vbCritical + vbOKCancel, "Mitarbeiter werden ignoriert") Then
                    Exit Sub
                End If
            End If
        End If
    
    'Nur bestimmte Empfänger?
        If Me.txEmpfaenger <> "" Then strSendAll(0) = Me.txEmpfaenger
    
    'Zusätzlich an Info@Consec?
        If Me.cbInfoAtConsec = True Then strSendAll(0) = strSendAll(0) & "; info@consec-nuernberg.de"
        
    'Subunternehmer entfernen
        Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & MASTAMM & " WHERE IstSubunternehmer = TRUE", dbOpenSnapshot)
        Do While Not rs.EOF
            If rs.fields("Email") <> "" Then
                strSendAll(0) = Replace(strSendAll(0), rs.fields("Email") & "; ", "")
            End If
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
        
    'Wenn Selected und an selected senden, dann wird nur die erste Zeit genommen
        If Me!IstAlleZeiten = True Then
            If ii > 0 Then
                If vbYes = MsgBox("Einzelne Mitarbeiter ausgewählt. Nur an diese senden ?", vbQuestion + vbYesNo, "Mitarbeiter selektiert") Then
                    Call eMail_senden(strSendSelected, VAStart_ID(0))
                'Else
                    'Call eMail_senden(strSendAll(0), VAStart_ID(0))
                End If
            Else
                Call eMail_senden(strSendAll(0), VAStart_ID(0))
            End If
        Else
            For k = 0 To i
                Call eMail_senden(strSendAll(k), VAStart_ID(k))
            Next k
        End If
    End If

End Sub

Function eMail_senden(strEmpfaenger As String, iVAStart_ID As Long)

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

Dim myattach()
Dim arrZeiten()
Dim k As Long
Dim iZeit As Long
Dim var
Dim i As Long
Dim strAbsender As String
Dim rc As String

Dim strBetreff_In As String
Dim strBetreff_Out As String

Dim strText_In As String
Dim strText_Out As String
Dim strVoting_Out As String
Dim strBCC As String
Dim iSendelogging As Long
Dim bDirektsenden As Boolean

'Empfänger prüfen ob gefüllt
If Len(Trim(Nz(strEmpfaenger))) = 0 Then
    If b_Alles_Checken = True Then
        MsgBox "Empfängerliste leer", vbCritical + vbOKOnly, "Abbruch"
    End If
    Exit Function
End If

'Absender prüfen, Abbruch wenn nicht ermittelbar
strAbsender = Nz(Me!AbsendenAls)
If Len(Trim(Nz(strAbsender))) = 0 Then
    strAbsender = Nz(TLookup("int_eMail", "_tblEigeneFirma_Mitarbeiter", "int_Login = '" & atCNames(1) & "'"))
    If Len(Trim(Nz(strAbsender))) = 0 Then
        strAbsender = Get_Priv_Property("prp_eMail_Notfall_Absender")
        If Len(Trim(Nz(strAbsender))) = 0 Then
            If b_Alles_Checken = True Then
                MsgBox "Absender nicht ermittelbar", vbCritical + vbOKOnly, "Abbruch"
            End If
            Exit Function
        End If
    End If
End If

'ggf. Attachfile anhängen
recsetSQL1 = "tbltmp_Attachfile"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
        
    For iZl = 0 To iZLMax1
        ReDim Preserve myattach(iZl)
        myattach(iZl) = DAOARRAY1(1, iZl)
    Next iZl
    Set DAOARRAY1 = Nothing
End If

strBetreff_In = Me!Betreffzeile
strText_In = Me!Textinhalt

'Wenn was in strIntern drinsteht um " - iVAStart_ID" ergänzen - nur bei Typ 1 Einladung für Autoreply notwendig
If Len(Trim(Nz(strIntern))) > 0 Then
    strIntern = strIntern & " - " & iVAStart_ID
End If

strBetreff_Out = Textbau_Ersetz(strBetreff_In, Me!VA_ID, Me!cboVADatum, iVAStart_ID) & strIntern
strText_Out = Textbau_Ersetz(strText_In, Me!VA_ID, Me!cboVADatum, iVAStart_ID)
strVoting_Out = Textbau_Ersetz(Nz(Me!Voting_Text), Me!VA_ID, Me!cboVADatum, iVAStart_ID)

iSendelogging = Get_Priv_Property("prp_Sendelogging")
bDirektsenden = Get_Priv_Property("prp_eMail_direkt_senden")

If iSendelogging Then
    Call Logfile_Fill(CLng(Me!IstHTML), strAbsender, Nz(strVoting_Out), strBetreff_Out, strText_Out, ArrFill_DAO_OK1, strEmpfaenger, Me!cboSendPrio, Me!VA_ID, Me!cboVADatum, iVAStart_ID)
End If


If ArrFill_DAO_OK1 Then
    'Call CreatePlainMail(CLng(Me!IstHTML), strText_Out, strBetreff_Out, strAbsender, Me!cboSendPrio, , strEmpfaenger, myattach, bDirektsenden, Nz(strVoting_Out), strAbsender, True)
    rc = zCreatePlainMail(CLng(Me!IstHTML), strText_Out, strBetreff_Out, strAbsender, Me!cboSendPrio, , strEmpfaenger, myattach, bDirektsenden, Nz(strVoting_Out), strAbsender)
Else
    'Call CreatePlainMail(CLng(Me!IstHTML), strText_Out, strBetreff_Out, strAbsender, Me!cboSendPrio, , strEmpfaenger, , bDirektsenden, Nz(strVoting_Out), strAbsender, True)
    rc = zCreatePlainMail(CLng(Me!IstHTML), strText_Out, strBetreff_Out, strAbsender, Me!cboSendPrio, , strEmpfaenger, , bDirektsenden, Nz(strVoting_Out), strAbsender)
End If


'Veranstaltungsstatus aktualisieren
MsgBox rc
If rc = "Email wurde versendet" Then
    If TLookup("Veranst_Status_ID", AUFTRAGSTAMM, "ID = " & Me.VA_ID) < 2 Then _
        TUpdate "Veranst_Status_ID = 3", AUFTRAGSTAMM, "ID = " & Me.VA_ID
End If

'Auftragstamm öffnen
If Not fctIsFormOpen("frm_va_auftragstamm") Then DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & Me.VA_ID

'Auftragstamm aktualisieren
Form_frm_VA_Auftragstamm.zsub_lstAuftrag.Form.Recalc
Form_sub_VA_Anzeige.f_UpdStatus
    
'Mailformular schließen
DoCmd.Close acForm, Me.Name, acSaveNo

' Parameter myattach
'-------------------
' Ein Array mit Dateinamen
' Beispiel für 2 Attachs:
' Dim att
' att = Array("D:\GEZSpruch.jpg", "D:\Kulturverlust.pdf")

' Parameter IsSend
'-----------------
' IsSend = True  -- eMail wird direkt gesendet
' IsSend = False  -- eMail wird angezeigt, um sie vor dem Senden noch editieren zu können

'Function CreatePlainMail(Bodytext As String, Betreff As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False, Optional Voting As String = "", Optional sendAs As String = "")

'Creates a new e-mail item and modifies its properties

'myItem.Importance 2 = High
'myItem.Importance 1 = Normal
'myItem.Importance 0 = Low

End Function

Function Logfile_Fill(IstHTML As Long, strAbsender As String, strVoting As String, strBetreff As String, strText As String, ReportJN As Boolean, strEmpfaenger As String, SendPrio As Long, VA_ID As Long, VADatum_ID As Long, VAStart_ID As Long)
Dim db As DAO.Database
Dim rst As DAO.Recordset
Set db = CurrentDb
Set rst = db.OpenRecordset("Select Top 1 * FROM tbl_Log_eMail_Sent;")
With rst
    .AddNew
        .fields("SendDate").Value = Now()
        .fields("Absender").Value = Nz(strAbsender)
        .fields("Voting").Value = Nz(strVoting)
        .fields("Betreff").Value = Nz(strBetreff)
        .fields("MailText").Value = Nz(strText)
        .fields("ReportJN").Value = ReportJN
        .fields("BCC").Value = Nz(strEmpfaenger)
        .fields("SendPrio").Value = SendPrio
        .fields("VA_ID").Value = VA_ID
        .fields("VADatum_ID").Value = VADatum_ID
        .fields("VAStart_ID").Value = VAStart_ID
        .fields("IstHTML").Value = IstHTML
    .update
    .Close
End With
Set rst = Nothing

End Function


Private Sub btnZuAbsage_Click()
DoCmd.OpenForm "frmTop_MA_ZuAbsage"
End Sub

Private Sub cboeMail_Vorlage_AfterUpdate()

If Me!cboeMail_Vorlage > 0 Then
    Me!AbsendenAls = Me!cboeMail_Vorlage.Column(1)
    Me!Voting_Text = Me!cboeMail_Vorlage.Column(2)
    Me!Betreffzeile = Me!cboeMail_Vorlage.Column(3)
    Me!IstHTML = Me!cboeMail_Vorlage.Column(5)
    IstHTML_AfterUpdate
    
    
    Select Case Me.cboeMail_Vorlage
        Case 8
            'TEXTINHALT / Mail Body  aus Body importieren
            Me.Textinhalt = create_HTML(TXTEinsatzliste)
            
        Case 10
            'TEXTINHALT / Mail Body  aus Body importieren
            Me.Textinhalt = create_HTML(TXTEinsatzlisteKD)
            
        Case 11
            'TEXTINHALT / Mail Body  aus Body importieren
            Me.Textinhalt = create_HTML(TXTEinsatzliste)
            
        Case Else
            Me!Textinhalt = Nz(TLookup("Textinhalt", "tbl_MA_Serien_eMail_Vorlage", "ID = " & Me!cboeMail_Vorlage))
            
    End Select
    
End If
End Sub

Private Sub Form_Load()
    DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)

    'Drucker prüfen
    If InStr(Application.Printer.DeviceName, "Badgy") <> 0 Then Application.Printer = Application.Printers(2)
    
    Me!lbl_Datum.caption = Date
    CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
    Me!sub_tbltmp_Attachfile.Form.Requery
    Me!lstZeiten.RowSource = ""
    Me!lstMA_Plan.RowSource = ""
    b_Alles_Checken = True
    Call ogZeitraum_AfterUpdate
    
    'Me.Textinhalt.TextFormat = acTextFormatHTMLRichText
End Sub


Private Sub IstAlleZeiten_AfterUpdate()
If Me!IstAlleZeiten = True Then
    Me!lstZeiten.Visible = False
Else
    Me!lstZeiten.Visible = True
End If

IstPlanAlle_AfterUpdate
End Sub

Private Sub IstHTML_AfterUpdate()
If Me!IstHTML = False Then
    Me!IstHTML.caption = "Unformatierter Text (ASCII)"
        Me!Textinhalt.TextFormat = 0
Else
    Me!Textinhalt.TextFormat = 1
    Me!IstHTML.caption = "Formatierter Text (HTML)"
End If
End Sub

Private Sub IstPlanAlle_AfterUpdate()
Dim strSQL As String
Dim strSQL2 As String

strSQL = ""
strSQL2 = ""

If Me!IstAlleZeiten = False Then
    strSQL2 = " AND VAStart_ID = " & Me!lstZeiten.Column(0)
Else
    strSQL2 = ""
End If


Select Case IstPlanAlle

    Case 1
        strSQL = strSQL & "SELECT * FROM qry_Mitarbeiter_Zusage_email WHERE VA_ID = " & Me!VA_ID & " AND MA_ID > 0 AND VADatum_ID = " & Me!cboVADatum & strSQL2
        
    Case 2
        strSQL = strSQL & "SELECT * FROM qry_Mitarbeiter_Geplant_email WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum & strSQL2
        
    Case 4
        strSQL = strSQL & "SELECT * FROM qry_Mitarbeiter_Sub_email WHERE VA_ID = " & Me!VA_ID & " AND MA_ID > 0 AND VADatum_ID = " & Me!cboVADatum & strSQL2
    Case Else
        
        strSQL = ""
        strSQL = strSQL & "SELECT * FROM qry_Mitarbeiter_Zusage_email WHERE VA_ID = " & Me!VA_ID & " AND MA_ID > 0 AND VADatum_ID = " & Me!cboVADatum & strSQL2
        strSQL = strSQL & " UNION SELECT * FROM qry_Mitarbeiter_Geplant_email WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum & strSQL2
        Me!IstPlanAlle = 3
        
End Select
        
'Debug.Print strSQL

Me!lstMA_Plan.RowSource = strSQL
Me!lstMA_Plan.Requery
DoEvents

End Sub

Private Sub lstMA_Plan_Click()
Dim var
If Me!IstAlleZeiten = False Then
    MsgBox "Eine Mitarbeiterauswahl ist nur möglich, wenn 'Alle Zeiten' gesetzt ist, nicht bei Einzel-Schichten"
    For Each var In Me!lstMA_Plan.ItemsSelected
        Me!lstMA_Plan.selected(var) = False
    Next var
End If
End Sub

Private Sub lstZeiten_AfterUpdate()
IstPlanAlle_AfterUpdate
End Sub

Public Function Autosend(iTyp As Integer, iVA_ID As Long, iVADatum_ID As Long, Optional iEmpfaenger As String)
' Typ 1 = prp_Std_Einladung - Mitarbeiter geplant - Alle_Zeiten = False - Voting Text True - kein Attach
' Typ 2 = prp_Std_Versammlungsinfo - Alle MA - Alle Zeiten = True - Kein Voting Text - Attach Report

Dim iVorlageNr As Long
Dim i As Long
Dim stKurz As String
Dim SubMode As Boolean

strIntern = ""

If iTyp = 1 Then
' Typ 1 = prp_Std_Einladung - Mitarbeiter geplant - Alle_Zeiten = False - Voting Text True - kein Attach
    iVorlageNr = Get_Priv_Property("prp_Std_Einladung")
    Me!IstAlleZeiten = False
    Me!IstPlanAlle = 2   '  2 = Geplant
    'für Autoreply notwendig sonst strIntern immer ""
    strIntern = "    - Intern: " & iVA_ID & " - " & iVADatum_ID
    SubMode = False
ElseIf iTyp = 2 Then
' Typ 2 = prp_Std_Versammlungsinfo - Alle MA - Alle Zeiten = True - Kein Voting Text - Attach Report
    iVorlageNr = Get_Priv_Property("prp_Std_Versammlungsinfo")
    Me!IstAlleZeiten = True
    Me!IstPlanAlle = 1   '  1 = Zugesagt  / 3 = Alle
    SubMode = False
ElseIf iTyp = 3 Then
' Typ 3 = prp_Std_Positionsliste - Alle MA - Alle Zeiten = True - Kein Voting Text - Attach Report Positionsliste
    iVorlageNr = Get_Priv_Property("prp_Std_Positionsliste")
    Me!IstAlleZeiten = True
    Me!IstPlanAlle = 1   '  1 = Zugesagt  / 3 = Alle
    SubMode = False
ElseIf iTyp = 4 Then
' Typ 4 = Einsatzliste_KD - Alle MA - Alle Zeiten = True - Kein Voting Text - Attach Report Positionsliste
    iVorlageNr = 10
    Me!IstAlleZeiten = True
    Me!IstPlanAlle = 1   '  1 = Zugesagt  / 3 = Alle
    SubMode = False
ElseIf iTyp = 5 Then
' Typ 5 = Einsatzliste_SUB - Nur Subunternehmer - Alle Zeiten = True - Kein Voting Text - KEIN Attach -> wird separat pro Sub bearbeitet!
    iVorlageNr = 11
    Me!IstAlleZeiten = True
    Me!IstPlanAlle = 4   '  4 = Subunternehmer
    SubMode = True
Else
    Exit Function
End If

If SubMode = True Then
    Me.ogZeitraum.Visible = False
    Me.sub_tbltmp_Attachfile.Visible = False
    Me.btnAttachSuch.Visible = False
    Me.btnAttLoesch.Visible = False
    Me.Bezeichnungsfeld199.Visible = False
    
Else
    Me.ogZeitraum.Visible = True
    Me.sub_tbltmp_Attachfile.Visible = True
    Me.btnAttachSuch.Visible = True
    Me.btnAttLoesch.Visible = False
    Me.Bezeichnungsfeld199.Visible = True

End If



Me.cbInfoAtConsec = True

'Nur an bestimmte Empfänger?
If iEmpfaenger = "" Then
    Me.txEmpfaenger = ""
Else
    Me.txEmpfaenger = iEmpfaenger
End If

VAOpen iVA_ID, iVADatum_ID

stKurz = iVA_ID & "_" & iVADatum_ID

On Error Resume Next
i = Nz(TLookup("ZusatzNr", "tbl_Zusatzdateien", "TabellenID = 42 AND Kurzbeschreibung = '" & stKurz & "'"), 0)
On Error GoTo 0
If i > 0 Then
    Me!btnPosListeAtt.Visible = True
Else
    Me!btnPosListeAtt.Visible = False
End If

b_Alles_Checken = False

If iTyp <> 1 And iTyp <> 5 Then
    btnPDFCrea_Click
End If

Me!cboeMail_Vorlage = iVorlageNr
DoEvents
cboeMail_Vorlage_AfterUpdate
DoEvents

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
    
'btnSendEmail_Click
'DoEvents
'DoCmd.Close acForm, "frm_MA_Serien_eMail_Auftrag", acSaveNo

End Function

Public Function VAOpen(iVA_ID As Long, iVADatum_ID As Long)
Dim strSQL As String

b_Alles_Checken = True

Me!VA_ID = iVA_ID
strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & iVA_ID & ")) ORDER BY ID;"
Me!cboVADatum.RowSource = strSQL
Me!cboVADatum = iVADatum_ID
cboVADatum_AfterUpdate
DoEvents
End Function


Private Sub cboVADatum_AfterUpdate()
Dim dtdat As Date

Dim strSQL As String

CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
Me!sub_tbltmp_Attachfile.Form.Requery

'Me!cboAuftrStatus = Nz(TLookup("Veranst_Status_ID", "tbl_VA_Auftragstamm", "ID = " & Me!VA_ID), 0)

strSQL = ""
strSQL = strSQL & "SELECT VAStart_ID, MA_Ist as Ist, MA_Soll as Soll, VA_Start As Start, VA_Ende as Ende FROM qry_Anz_MA_Start WHERE VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!cboVADatum & " ORDER BY VA_Start, VA_Ende"
Me!lstZeiten.RowSource = strSQL
Me!lstZeiten.Requery
DoEvents
Me!lstZeiten = Me!lstZeiten.ItemData(1)

Call Set_Priv_Property("prp_tmp_AktdatAuswahl", Me!cboVADatum.Column(1))

Me!iGes_MA = Soll_Plan_Ist_Ges(Me!VA_ID, Me!cboVADatum)

IstPlanAlle_AfterUpdate

End Sub

Private Function Soll_Plan_Ist_Ges(iVA_ID As Long, iVADatum_ID As Long) As String
Dim iSoll As Long
Dim iPlan As Long
Dim iIst As Long

iSoll = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID))
'iPlan = Nz(TCount("*", "tbl_MA_VA_Planung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND Status_ID > 0 and Status_ID < 3 "))
iIst = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID & " AND MA_ID > 0"))
Soll_Plan_Ist_Ges = iIst & "  " & iSoll

End Function


'Zeitraum für Einsatzliste
Private Sub ogZeitraum_AfterUpdate()

Dim VADatum_ID As Variant
    
    If IsNull(Me.VA_ID) Then Exit Sub
    
    'Zeitraum für Einsatzliste
    Select Case Me.ogZeitraum
        Case 1 'Gesamt
            Set_Priv_Property "prp_Report1_Auftrag_IstTage", "-1"
            CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
            Call btnPDFCrea_Click
        Case 2 'Ab heute
            Set_Priv_Property "prp_Report1_Auftrag_IstTage", 1
            CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
            Call btnPDFCrea_Click
        Case 3 'Datum
            'VADatum_ID = TLookup("ID", ANZTAGE, "VA_ID = " & Me.VA_ID & " AND VADatum = " & DatumSQL(InputBox("Datum: ")))
            VADatum_ID = Me.cboVADatum
            If IsNumeric(VADatum_ID) Then
                Set_Priv_Property "prp_Report1_Auftrag_IstTage", 0
                Set_Priv_Property "prp_Report1_Auftrag_VADatum_ID", VADatum_ID
                CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
                Call btnPDFCrea_Click
            Else
                MsgBox "Keine Daten zum Datum gefunden!", vbCritical
                Me.ogZeitraum = 1
                Exit Sub
            End If
        Case 4 'MA
            If IsNull(Me.lstMA_Plan.Column(4)) Then
                MsgBox "Bitte MA selektieren"
                Exit Sub
            End If
            Set_Priv_Property "prp_Report1_Auftrag_IstTage", "2"
            Set_Priv_Property "prp_Report1_MA_ID", Me.lstMA_Plan.Column(4)
            CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
            Call btnPDFCrea_Click
    End Select
    'DoCmd.RunCommand acCmdSaveRecord
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
End Sub



Private Sub VA_ID_AfterUpdate()


Dim dtdat As Date
Dim i As Long
Dim strSQL As String

Me!lstZeiten.RowSource = ""
Me!lstMA_Plan.RowSource = ""

If Nz(TCount("*", "tbl_VA_Start", "VA_ID = " & Me!VA_ID), 0) = 0 Then
    MsgBox "Erst Zeitraum im Auftrag definieren, keine Auftrag eMail möglich"
    Exit Sub
End If

strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!VA_ID & ")) ORDER BY ID;"
Me!cboVADatum.RowSource = strSQL
'Me!cboVADatum = Me!cboVADatum.ItemData(0)
Me!cboVADatum = Me!VA_ID.Column(1)

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


