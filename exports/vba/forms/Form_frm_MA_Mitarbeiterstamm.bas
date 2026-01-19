VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_MA_Mitarbeiterstamm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Declare PtrSafe Function BlockInput Lib "user32" (ByVal fBlock As Long) As Long
    'Tastatur und Maus SPERREN
    'BlockInput True
    'Tastatur und Maus ENTSPERREN
    'BlockInput False
    
Dim MA_Bildpfad As String
Dim MA_Signaturpfad As String
Dim Listfeld As String
Dim listselect As String
Dim isDirty As Boolean
Dim GMA_ID As Integer


Private Sub Anstellungsart_AfterUpdate()
    Select Case Me.Anstellungsart_ID
        Case 11 ' Sub
            Me.IstNSB = True
            Me.IstSubunternehmer = True
            Me.StundenZahlMax = 0
            Me.Stundenlohn_brutto = Null
            
        Case 5 ' Mini
            Me.IstNSB = False
            Me.IstSubunternehmer = False
            Me.StundenZahlMax = 38.5
            Me.Stundenlohn_brutto = 2
            
        Case 3 ' Fest
            Me.IstNSB = False
            Me.IstSubunternehmer = False
            Me.StundenZahlMax = 0
            Me.Stundenlohn_brutto = 1
            
        Case Else
            Me.IstNSB = False
            Me.IstSubunternehmer = False
            Me.StundenZahlMax = 0
            Me.Stundenlohn_brutto = Null
            
    End Select

End Sub


Private Sub Bericht_drucken_click()
    DoCmd.OpenReport "rpt_einsatzuebersicht3", acViewPreview
    
End Sub


'Drucken
Private Sub btn_Diensplan_prnt_Click()
Dim rptDB As String

    rptDB = "rpt_MA_Dienstplan"
     

    'Prüfen, ob Bericht geöffnet
    If fctIsReportOpen(rptDB) Then
        MsgBox "Bitte zuerst den Bericht schließen!"
        Exit Sub
    End If

        Set_Priv_Property "prp_rpt_Dienstplan_MA_Recordsource", Me.lstPl_Zuo.RowSource
        Set_Priv_Property "prp_rpt_Dienstplan_MA_von", Me.AU_von
        Set_Priv_Property "prp_rpt_Dienstplan_MA_bis", Me.AU_bis
        DoCmd.OpenReport rptDP, acViewPreview

End Sub


'Senden
Private Sub btn_Dienstplan_send_Click()
On Error GoTo Err

    If MsgBox("Dienstplan an " & Me.Nachname & ", " & Me.Vorname & " senden?", vbYesNo) = vbYes Then
        Set_Priv_Property "prp_rpt_Dienstplan_MA_Recordsource", Me.lstPl_Zuo.RowSource
        Set_Priv_Property "prp_rpt_Dienstplan_MA_von", Me.AU_von
        Set_Priv_Property "prp_rpt_Dienstplan_MA_bis", Me.AU_bis
        DoCmd.OpenReport rptDP, acViewPreview
        DoCmd.Close acReport, rptDP, acSaveYes
        MsgBox Dienstplan_senden(Me.ID, Me.AU_von, Me.AU_bis)
    End If

    Me.Recalc
    Me.Refresh
    
Ende:
    Exit Sub
Err:
    MsgBox Err.Number & " " & Err.description
    Resume Ende
End Sub


Private Sub btn_MA_EinlesVorlageDatei_Click()
Dim str_MADok As String
Me!sub_tbltmp_MA_Ausgef_Vorlagen.Form.recordSource = ""
On Error Resume Next
CurrentDb.Execute ("DROP Table tbltmp_MA_Ausgef_Vorlagen")

str_MADok = Get_Priv_Property("prp_CONSYS_GrundPfad") & TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 1") & "M_" & Me!ID
'"M_"nnn
Call ReadFileInfos("tbltmp_MA_Ausgef_Vorlagen", str_MADok)
DoEvents
Me!sub_tbltmp_MA_Ausgef_Vorlagen.Form.recordSource = "tbltmp_MA_Ausgef_Vorlagen"
Me!sub_tbltmp_MA_Ausgef_Vorlagen.Visible = True
Me!sub_tbltmp_MA_Ausgef_Vorlagen.Form.Requery

End Sub


'Stundenberechnung öffnen
Private Sub btnCalc_Click()
Dim frm     As String
Dim WHERE   As String
Dim VA_ID   As Long

    frm = "zfrm_ZUO_Stunden"
    VA_ID = Nz(Me.cboFilterAuftrag.Column(0), 0)
    
    WHERE = "MA_ID = " & Me.ID
    If VA_ID <> 0 Then
        WHERE = WHERE & " AND VA_ID = " & VA_ID
    Else
        WHERE = WHERE & " AND ID in (SELECT ID from zqry_ZUO_Stunden WHERE MA_ID = " & Me.ID & " AND VADatum >= " & datumSQL(Me.AU_von) & " AND  VADatum <= " & datumSQL(Me.AU_bis) & ")"
    End If
    
    DoCmd.OpenForm frm, acNormal, , WHERE
    
End Sub


'Listen drucken
Private Sub btnLstDruck_Click()
Dim strSQL As String

    strSQL = Me!Lst_MA.RowSource
    Call CreateQuery(strSQL, "qry_MA_Akt_ListeDrucken")
    DoEvents
    
    fExcel_qry_export ("qry_MA_Akt_ListeDrucken")

End Sub


Public Sub btnMADienstpl_Click()
    Call FCreate_Dienstplan_MA_Einzel_Excel(Me!PersNr, Me!DiDatumAb)
    
End Sub


Private Sub btnXLDiePl_Click()
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, VADatum, Auftrag, Ort, Objekt, Format([Beginn],'hh:nn') as beginnt, Format([Ende],'hh:nn') AS endet, FROM qry_MA_VA_Plan_AllAufUeber1 WHERE VADatum Between " & SQLDatum(Me!AUPl_von) & " AND " & SQLDatum(Me!AUPl_bis) & " And MA_ID = " & Me!ID & " ORDER BY VADatum, Beginn"
    Call CreateQuery(strSQL, "qry_Excel_Dienstplan")
    DoEvents

    fExcel_qry_export ("qry_Excel_Dienstplan")

End Sub


Private Sub btnXLEinsUeber_Click()
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, VADatum, Auftrag, Ort, Objekt, Format([Beginn],'hh:nn') as beginnt, Format([Ende],'hh:nn') AS endet, "
    strSQL = strSQL & " MA_Brutto_Std, MA_Netto_Std FROM qry_MA_VA_Plan_All_AufUeber2_Zuo WHERE VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis) & " And MA_ID = " & Me!ID & " ORDER BY VADatum, Beginn"
    Call CreateQuery(strSQL, "qry_Excel_Einsatzuebersicht")
    DoEvents

    fExcel_qry_export ("qry_Excel_Einsatzuebersicht")

End Sub


Private Sub btnXLJahr_Click()
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, * from qry_XL_Jahr WHERE AktJahr = " & Me!cboJahrJa & " AND MA_ID = " & Me!ID & " ORDER BY AktMon "
    Call CreateQuery(strSQL, "qry_Excel_Jahresübersicht")
    DoEvents

    fExcel_qry_export ("qry_Excel_Jahresübersicht")
End Sub


Private Sub btnXLNverfueg_Click()
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, Zeittyp_ID, Format([vonDat], 'dd.mm.yyyy hh:nn') as von, Format([bisDat], 'dd.mm.yyyy hh:nn') as  bis, Bemerkung from qry_tbl_MA_NVerfuegZeiten Order by vondat"
    Call CreateQuery(strSQL, "qry_Excel_nVerfueg")
    DoEvents

    fExcel_qry_export ("qry_Excel_nVerfueg")
End Sub


Private Sub btnXLUeberhangStd_Click()
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, AktJahr, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12 from tbl_MA_UeberlaufStunden where ma_Id = " & Me!ID & " ORDER BY AktJahr"
    Call CreateQuery(strSQL, "qry_Excel_Ueberhang")
    DoEvents

    fExcel_qry_export ("qry_Excel_Ueberhang")

End Sub


Private Sub btnXLVordrucke_Click()
Dim strSQL As String

    Call btn_MA_EinlesVorlageDatei_Click

    strSQL = ""
    strSQL = strSQL & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, Ordner, Dateiname, Datum FROM  tbltmp_MA_Ausgef_Vorlagen"
    Call CreateQuery(strSQL, "qry_Excel_Vordrucke")
    DoEvents

    fExcel_qry_export ("qry_Excel_Vordrucke")

End Sub


Private Sub btnXLZeitkto_Click()
Dim strSQL As String
Dim strSQL2 As String
Dim strFileName As String
Dim qryXL As String
Dim frm As Form

    Call btnLesen_Click
    
    Call Set_Priv_Property("prp_GL_XL_MehrfachTabs", 1)
    
    strSQL = ""
    strSQL = strSQL & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, VADatum, day(VAdatum) as Tag, Auftrag_Ort, Format([MA_Start],'hh:nn') as Beginn, Format([MA_Ende],'hh:nn') AS Ende, Brutto_Std2, Netto_Std2, Fahrtko as Fahrtkosten, RL34a as Rücklagen_34a FROM qry_MonZusD"
    Call CreateQuery(strSQL, "qry_Excel_Zeitkonto_Auftrag")
    DoEvents
    
    strSQL2 = ""
    strSQL2 = strSQL2 & "SELECT '" & Me!Nachname & " " & Me!Vorname & "' AS Name, Aktdat as VADatum, day(Aktdat) as Tag, X34a_RZ as Rückzahlung_34a, Abschlag, Nicht_Erscheinen as Abwesend, Kaution,  Dienstkleidung, Sonst_Abzuege, Sonst_Abzuege_Grund, Monatslohn as MA_Auszahlung, UeberwVon as von FROM qry_MonZus6 Order By Aktdat"
    Call CreateQuery(strSQL2, "qry_Excel_Zeitkonto_Zusatzkosten")
    DoEvents
    
    GL_XL_MehrfachTabs = Array("qry_Excel_Zeitkonto_Auftrag", "qry_Excel_Zeitkonto_Zusatzkosten")
    
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    
    DoCmd.OpenForm "_frmHlp_Excel_Einbinden"
    Set frm = Forms("_frmHlp_Excel_Einbinden")
    frm.WahlLinkImport = 1  ' Export = 1  ' Link = 2, Import = 0
    frm.WahlLI
    frm.IstMitHeader = True
    frm.Tabellenname = GL_XL_MehrfachTabs(0)
    frm.Dateiname = strFileName

End Sub


'Zeitkonto öffnen
Private Sub btnZeitkonto_Click()

Dim xlApp As Object, xlWb As Object
Dim fso As New Scripting.FileSystemObject
Dim fol As folder
Dim Fil As file
Dim PfadZeitkonten As String
Dim Name As String
Dim Monat As Integer
Const xlMaximized As Long = -4137&

On Error GoTo Err

    PfadZeitkonten = PfadZK
    
    'Wenn Pfad nicht existiert -> letztes Jahr
    If Dir(PfadZeitkonten, vbDirectory) = "" Then PfadZeitkonten = PfadZuBerechnen & Year(Date) - 1 & " Zeitkonten"
    
    'Wenn Pfad nicht existiert -> Fehler
    If Dir(PfadZeitkonten, vbDirectory) = "" Then Err.Raise 76, , PfadZeitkonten & vbCrLf & " nicht gefunden!"
    
    Name = Me.Nachname & " " & Me.Vorname
    
    Set fol = fso.GetFolder(PfadZeitkonten)
    
    'Zeitkonto suchen
    For Each Fil In fol.files
        'If UCase(Left(fil.Name, Len(fil.Name) - (Len(fil.Name) - InStrRev(fil.Name, ".")) - 1)) = UCase(Name) Then
        If InStr(UCase(Fil.Name), UCase(Name)) <> 0 Then
            Set xlApp = CreateObject("Excel.Application")
            xlApp.Visible = True
            Set xlWb = xlApp.Workbooks.Open(Fil.path, , False)
            
       With xlApp
    .WindowState = xlMaximized
    
    End With
     
            Exit For
        End If
    Next Fil
    
    'Zeitkonto nicht gefunden
    If xlApp Is Nothing Then Err.Raise 76, , "Zeitkonto   " & Name & "   nicht gefunden!"

    'Monat im Zeitkonto selektieren
    If Not IsNull(Me.AU_von) Then
        Monat = Mid(Me.AU_von, 4, 2)
        xlWb.Sheets(Monat).Select
    End If
    
    
Ende:
    Set xlApp = Nothing
    Set xlWb = Nothing
    Exit Sub
Err:
    MsgBox Err.Number & " " & Err.description, vbCritical
    Resume Ende
End Sub


'Zeitkonto aus Einsatzübersicht fortschreiben
Private Sub btnZKeinzel_Click()

Dim Name    As String
Dim MA_ID   As Integer
Dim von     As Date
Dim bis     As Date
Dim rc      As String

    'Aktuellen Monat setzen -> deaktiviert!
    'If Me.cboZeitraum <> 8 And Me.cboZeitraum <> 9 Then Me.cboZeitraum = 8
    'Call cboZeitraum_AfterUpdate
    
    MA_ID = Me.ID
    Name = Me.Nachname & " " & Me.Vorname
    von = Me.AU_von
    bis = Me.AU_bis
    
    'If MsgBox("Zeitkonto  " & Name & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "fortschreiben?", vbYesNoCancel) <> vbYes Then Exit Sub
    
    Me.btnZKeinzel.Enabled = False
    rc = "Einzelsatz: " & ZK_Daten_uebertragen(MA_ID, von, bis, True)
    
On Error Resume Next
    CurrentDb.Execute "INSERT INTO [ztbl_ZK_Log] VALUES (" & DatumUhrzeitSQL(Now()) & ", '" & Environ("UserName") & "', '" & rc & "');"
On Error GoTo 0

    Me.btnZKeinzel.Enabled = True
    'MsgBox "Zeitkonto " & Name & " wurde fortgeschrieben"
End Sub


'Zeitkonten Festangestellte fortschreiben
Private Sub btnZKFest_Click()

Dim rs  As Recordset
Dim rc  As String
Dim von As Date
Dim bis As Date

On Error GoTo Err

    'Aktuellen Monat setzen
    If Me.cboZeitraum <> 8 And Me.cboZeitraum <> 9 Then Me.cboZeitraum = 8
    Call cboZeitraum_AfterUpdate
    von = Me.AU_von
    bis = Me.AU_bis
    
    If MsgBox("Zeitkonten Festangestelle  " & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "fortschreiben?", vbYesNoCancel) <> vbYes Then Exit Sub
    
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & MASTAMM & _
        " WHERE [IstAktiv] = TRUE AND [IstSubunternehmer] = FALSE AND Anstellungsart_ID = 3 ORDER BY Nachname ASC;")

    'Ladebalken starten
    Application.SysCmd acSysCmdInitMeter, "Einsätze Festangestellte werden übertragen ...", rs.RecordCount
    
    Do While Not rs.EOF
        rc = "Festangestellte: " & ZK_Daten_uebertragen(rs.fields("ID"), von, bis)
On Error Resume Next
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Log] VALUES (" & DatumUhrzeitSQL(Now()) & ", '" & Environ("UserName") & "', '" & rc & "');"
On Error GoTo 0
        rs.MoveNext
        'Ladebalken aktualisieren
        If rs.AbsolutePosition > 0 Then Application.SysCmd acSysCmdUpdateMeter, rs.AbsolutePosition
    Loop
    Set rs = Nothing
    
    'Ladebalken entfernen
    Application.SysCmd acSysCmdRemoveMeter
    
    MsgBox "Einsätze der Festangestellten wurden in die Zeitkonten übertragen!"
    
Ende:
    Exit Sub
Err:
    Select Case Err.Number
        Case 94
            MsgBox "Bitte Einsatzübersicht öffnen und Zeitraum angeben!", vbCritical
        Case Else
            MsgBox Err.Number & " " & Err.description
    End Select
    Resume Ende
End Sub


'Zeitkonten Minijobber fortschreiben
Private Sub btnZKMini_Click()

Dim rs  As Recordset
Dim rc  As String
Dim von As Date
Dim bis As Date


On Error GoTo Err

    'Aktuellen Monat setzen
    If Me.cboZeitraum <> 8 And Me.cboZeitraum <> 9 Then Me.cboZeitraum = 8
    Call cboZeitraum_AfterUpdate
    von = Me.AU_von
    bis = Me.AU_bis
    
    If MsgBox("Zeitkonten Minijobber  " & vbCrLf & " von  " & von & vbCrLf & " bis   " & bis & vbCrLf & "fortschreiben?", vbYesNoCancel) <> vbYes Then Exit Sub
    
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & MASTAMM & _
        " WHERE [IstAktiv] = TRUE AND [IstSubunternehmer] = FALSE AND Anstellungsart_ID = 5 ORDER BY Nachname ASC;")

    'Ladebalken starten
    Application.SysCmd acSysCmdInitMeter, "Einsätze Festangestellte werden übertragen ...", rs.RecordCount
    
    Do While Not rs.EOF
        rc = "Minijobber: " & ZK_Daten_uebertragen(rs.fields("ID"), von, bis)
On Error Resume Next
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Log] VALUES (" & DatumUhrzeitSQL(Now()) & ", '" & Environ("UserName") & "', '" & rc & "');"
On Error GoTo 0
        rs.MoveNext
        'Ladebalken aktualisieren
        If rs.AbsolutePosition > 0 Then Application.SysCmd acSysCmdUpdateMeter, rs.AbsolutePosition
    Loop
    Set rs = Nothing
    
    'Ladebalken entfernen
    Application.SysCmd acSysCmdRemoveMeter
    
    MsgBox "Einsätze der Minijobber wurden in die Zeitkonten übertragen!"
   
Ende:
    Exit Sub
Err:
    Select Case Err.Number
        Case 94
            MsgBox "Bitte Einsatzübersicht öffnen und Zeitraum angeben!", vbCritical
        Case Else
            MsgBox Err.Number & " " & Err.description
    End Select
    Resume Ende
End Sub


Private Sub btnZuAb_Click()
Dim tbl As String

    tbl = "ztbl_MA_Mitarbeiterstamm_ZUAB"

    If TCount("*", tbl, "MA_ID = " & Me.ID & " AND Lohnart_ID is Null") = 0 Then _
        CurrentDb.Execute "INSERT INTO " & tbl & " (MA_ID) VALUES (" & Me.ID & ")"
        
    DoCmd.OpenForm "zsub_MA_ZUAB", acFormDS, , "MA_ID = " & Me.ID
        
End Sub


Private Sub cboFilterAuftrag_AfterUpdate()
    Call btnAU_Lesen_Click
    
End Sub


Private Sub cboIDSuche_AfterUpdate()
    Me.Recordset.FindFirst "ID = " & Me!cboIDSuche
    
End Sub


Private Sub DiDatumAb_DblClick(Cancel As Integer)
    Set Global_AufrufCtrl = Me.ActiveControl
    DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
    
End Sub


Private Sub Form_Load()

    'Dieser Monat
    Me.cboZeitraum = 8
    Call cboZeitraum_AfterUpdate
    
    Me!lbl_Version.Visible = True
    Me!lbl_Version.caption = Get_Priv_Property("prp_V_FE") & " | " & Get_Priv_Property("prp_V_BE")
    DoCmd.Maximize

            
    'selektierten Mitarbeiter anzeigen
    lst_MA_Click

End Sub

Private Sub Anstellungsart_DblClick(Cancel As Integer)
DoCmd.OpenForm "frmTop_MA_Anstellungsart", , , , , acDialog
Me!Anstellungsart.Requery
End Sub

Private Sub btnAUPl_Lesen_Click()
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT * FROM qry_Dienstplan WHERE VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis) & " And MA_ID = " & Me!ID & " ORDER BY VADatum, Beginn"
    Me!lstPl_Zuo.RowSource = strSQL
    Me!lstPl_Zuo.Requery
    DoEvents

End Sub

'Bild Mitarbeiter
Private Sub btnDateisuch_Click()
Dim MA_Bild As String
Dim MA_Bildpfad As String
    MA_Bildpfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 7"))
    MA_Bild = JPGSuch(MA_Bildpfad)
    If Len(Trim(Nz(MA_Bild))) > 0 Then
        tblBilddatei = Dir(MA_Bild)
    End If

End Sub

'Signatur Mitarbeiter
Private Sub btnDateisuch2_Click()
Dim MA_Signatur As String
Dim MA_Signaturpfad As String
    MA_Signaturpfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 14"))
    MA_Signatur = JPGSuch(MA_Signaturpfad)
    If Len(Trim(Nz(MA_Signatur))) > 0 Then
        tblSignaturdatei = Dir(MA_Signatur)
    End If

End Sub

Private Sub Austrittsdatum_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub btnAU_Lesen_Click()
'in Abfrage qry_MA_VA_Zuo_All_AufUeber2 - VADatum - Dort ist das Datumsformat auf "ttt  tt.mm.jjjj" gesetzt
Dim strSQL As String

    strSQL = ""
   
    If Me.cboFilterAuftrag.Visible = True Then
         strSQL = "SELECT DISTINCT VA_ID,Auftrag FROM qry_MA_VA_Plan_All_AufUeber2_Zuo WHERE VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis) & " And MA_ID = " & Me!ID
        Me.cboFilterAuftrag.RowSource = strSQL
        strSQL = ""
    End If
  
    strSQL = "SELECT * FROM qry_MA_VA_Plan_All_AufUeber2_Zuo WHERE VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis) & " And MA_ID = " & Me!ID
    If Nz(Me.cboFilterAuftrag, "") <> "" Then strSQL = strSQL & " AND Auftrag = '" & Me.cboFilterAuftrag & "'"
    strSQL = strSQL & " ORDER BY VADatum, Beginn"
    Me!lst_Zuo.RowSource = strSQL
    Me!lst_Zuo.Requery
    DoEvents
    
    
    'Nettostunden Wertberechnung
    If Me.IstNSB = True Then
        lbSummeStunden.caption = "Gesamt brutto: " & Round(calc_brutto_std(Me.ID, Left(Me.AU_von, 10), Left(Me.AU_bis, 10), Nz(Me.cboFilterAuftrag, "")), 2) & " h"
        If Not IsNull(Me.cboFilterAuftrag) And Me.cboFilterAuftrag <> "" Then _
            Me.txRechSub = Nz(TLookup("RchNr_Ext", RCHKOPF, "MA_ID = " & Me.ID & " AND VA_ID = " & Me.cboFilterAuftrag.Column(0)), "")
            Me.txRechBezahlt = Nz(TLookup("Zahlung_am", RCHKOPF, "MA_ID = " & Me.ID & " AND VA_ID = " & Me.cboFilterAuftrag.Column(0)), "")
            Me.txRechCheck = Nz(TLookup("Aend_von", RCHKOPF, "MA_ID = " & Me.ID & " AND VA_ID = " & Me.cboFilterAuftrag.Column(0)), "")
    Else
        'lbSummeStunden.Caption = "Gesamt netto: " & Round(calc_brutto_std(Me.ID, Left(Me.AU_von, 10), Left(Me.AU_bis, 10)) * 0.91, 2) & " h"
        lbSummeStunden.caption = "Gesamt netto: " & Round(calc_netto_std(Me.ID, Left(Me.AU_von, 10), Left(Me.AU_bis, 10)), 2) & " h"
    End If
    
End Sub


Private Sub btnLesen_Click()

'Mitarbeiter nochmal aus Puffer nachladen
Me.ID = GMA_ID

Dim strSQL As String

'    'qry_Ins_tmp_Monat4
'        strSQL = ""
'        strSQL = strSQL & " INSERT INTO tbl_MA_Tageszusatzwerte ( VADatum, MA_ID )"
'        strSQL = strSQL & " SELECT qry_Ins_tmp_Monat1a.dtDatum, " & Me!ID & " AS Ausdr1"
'        strSQL = strSQL & " FROM qry_Ins_tmp_Monat1a;"
'        Call CreateQuery(strSQL, "qry_Ins_tmp_Monat4")
'
'    'qry_Ins_tmp_Monat1b
'        strSQL = ""
'        strSQL = strSQL & " SELECT tbl_MA_Tageszusatzwerte.MA_ID, tbl_MA_Tageszusatzwerte.AktDat AS VADatum"
'        strSQL = strSQL & " FROM tbl_MA_Tageszusatzwerte"
'        strSQL = strSQL & " WHERE (((tbl_MA_Tageszusatzwerte.MA_ID)= " & Me!ID & "));"
'        Call CreateQuery(strSQL, "qry_Ins_tmp_Monat1b")

Call Set_Priv_Property("prp_Akt_MA_ID", Me!ID)
Call Set_Priv_Property("prp_AktMonUeb_Monat", Me!cboMonat)
Call Set_Priv_Property("prp_AktMonUeb_Jahr", Me!cboJahr)

Me!EinsProMon = Nz(rstDcount("*", "qry_MA_Monat_VA_Zuordnung"), 0)
Me!TagProMon = Nz(TCount("*", "qry_tmp_MA_ANzTgMon"), 0)

'Insert in Temp-Table tbltmp_MA_Tageszusatzwerte und beim verlassen nur die in die Haupttabelle tbl_MA_Tageszusatzwerte inserten, die Werte enthalten
'  qry_MonZus3 - 5 Ausführen
CurrentDb.Execute ("qry_MonZus3")  ' tmp Table löschen
CurrentDb.Execute ("qry_MonZus4")  ' Insert
CurrentDb.Execute ("qry_MonZus5")  ' Update MA_ID

'CurrentDb.Execute ("qry_Ins_tmp_Monat1")
DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

Me!sub_tbl_MA_Zeitkonto_Aktmon1.LinkMasterFields = ""
Me!sub_tbl_MA_Zeitkonto_Aktmon1.LinkChildFields = ""

Me!sub_tbl_MA_Zeitkonto_Aktmon2.LinkMasterFields = ""
Me!sub_tbl_MA_Zeitkonto_Aktmon2.LinkChildFields = ""

DoEvents
'Me!lst_Mon_Ez.RowSource = "SELECT * FROM tbl_MA_Zeitkonto_Aktmon ORDER BY VADatum"
'Me!lst_Mon_Ez.Requery
Me!sub_tbl_MA_Zeitkonto_Aktmon1.Visible = True
Me!sub_tbl_MA_Zeitkonto_Aktmon2.Visible = True

DoEvents

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

'Me!sub_tbl_MA_Zeitkonto_Aktmon1.Form.RecordSource = "qry_Ins_Aktmon_Zuord"
Me!sub_tbl_MA_Zeitkonto_Aktmon1.Form.Requery
Me!sub_tbl_MA_Zeitkonto_Aktmon2.Form.Requery

'Me!sub_tbl_MA_Zeitkonto_Aktmon1.Form.RecordSource = Me!sub_tbl_MA_Zeitkonto_Aktmon1.Form.RecordSource
'Me!sub_tbl_MA_Zeitkonto_Aktmon2.Form.RecordSource = Me!sub_tbl_MA_Zeitkonto_Aktmon2.Form.RecordSource
DoEvents

'Debug.Print TCount("*", "qry_MonZus6")
'Debug.Print TCount("*", "qry_Ins_Aktmon_Zuord")

Me!lst_Tl1M.RowSource = "SELECT * FROM qry_JB_MA_Jahr_tl1A_Ue WHERE AktJahr = " & Me!cboJahr & " AND AktMon = " & Me!cboMonat & " AND MA_ID = " & Me!ID & " ORDER BY AktJahr, AktMon"
Debug.Print Me!lst_Tl1M.RowSource
Me!lst_Tl1M.Requery
Me!lst_Tl2M.RowSource = "SELECT * FROM qry_JB_MA_Jahr_tl2A_Ue WHERE AktJahr = " & Me!cboJahr & " AND AktMon = " & Me!cboMonat & " AND MA_ID = " & Me!ID & " ORDER BY AktJahr, AktMon"
Me!lst_Tl2M.Requery

DoEvents

End Sub

Private Sub btnMehrfachtermine_Click()
DoCmd.OpenForm "frmTop_MA_Abwesenheitsplanung"
Forms!frmTop_MA_Abwesenheitsplanung!cbo_MA_ID = Me!ID
DoEvents

End Sub

Private Sub btnReport_Dienstkleidung_Click()
DoCmd.OpenReport "rpt_Dienstkleidung", acViewPreview, , "ID = " & Me!ID
End Sub

Private Sub btnUpdJahr_Click()
    Call Ueberlaufstd_Berech_Neu(Me!cboJahr, Me!cboMonat, Me!ID)
End Sub


Private Sub cboJahr_AfterUpdate()
Mon_Ausw
End Sub

Private Sub cboMASuche_AfterUpdate()
Me.Recordset.FindFirst "Nachname = " & Me!cboMASuche.Column(0)
End Sub

Private Sub cboMonat_AfterUpdate()
Mon_Ausw
End Sub

Function Mon_Ausw()

Dim iday As Long
Dim strSQL As String

Me!Mon_aktdat = DateSerial(Me!cboJahr, Me!cboMonat, 1)
Me!lblDatum.caption = Me!cboMonat.Column(1) & " " & Me!cboJahr
strSQL = "SELECT [_tblAlleTage].TagNr, [_tblAlleTage].dtDatum FROM _tblAlleTage WHERE (([_tblAlleTage].JahrNr= " & Me!cboJahr & ") AND ([_tblAlleTage].MonatNr= " & Me!cboMonat & "));"
Call CreateQuery(strSQL, "qry_AlleMonatstage_AKtMon")

'Insert in Temp-Table tbltmp_Ins_Aktmon_Zuord
CurrentDb.Execute ("qry_MonZusA")  ' tmp Table löschen
CurrentDb.Execute ("qry_MonZusB")  ' Insert
CurrentDb.Execute ("qry_MonZusC")  ' Insert NVerfüg

Call Set_Priv_Property("prp_AktMonUeb_Monat", Me!cboMonat)
Call Set_Priv_Property("prp_AktMonUeb_Jahr", Me!cboJahr)

Me!sub_tbl_MA_Zeitkonto_Aktmon1.LinkMasterFields = ""
Me!sub_tbl_MA_Zeitkonto_Aktmon1.LinkChildFields = ""

Me!sub_tbl_MA_Zeitkonto_Aktmon2.LinkMasterFields = ""
Me!sub_tbl_MA_Zeitkonto_Aktmon2.LinkChildFields = ""

Me!sub_tbl_MA_Zeitkonto_Aktmon1.Form.Requery
Me!sub_tbl_MA_Zeitkonto_Aktmon2.Form.Requery

Me!EinsProMon = Nz(rstDcount("*", "qry_MA_Monat_VA_Zuordnung"), 0)
Me!TagProMon = Nz(TCount("*", "qry_tmp_MA_ANzTgMon"), 0)

DoEvents

End Function


'Auswahl Zeitraum
Private Sub cboZeitraum_AfterUpdate()


'' Function StdZeitraum_Von_Bis(ID, von, bis)  und Tabelle _tblZeitraumAngaben (für Combobox)
Dim dtvon As Date
Dim dtbis As Date

    Call StdZeitraum_Von_Bis(Me.cboZeitraum, dtvon, dtbis)

    'immer nur bis zum aktuellen Datum
    'If dtBis > Now() And dtVon < Now() Then dtBis = Now()

    Me.AU_von = dtvon
    Me.AU_bis = dtbis
    DoEvents

    btnAU_Lesen_Click
    
    Call regMA(Me.reg_MA)
    
End Sub

Private Sub Eintrittsdatum_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub


Private Sub Form_AfterUpdate()
   
    If isDirty = True Then
        Adresse_Upd
        isDirty = False
    End If
    
    Me!Lst_MA.RowSource = Me!Lst_MA.RowSource
    Me!Lst_MA.Requery
    'Me!Lst_MA = Me!Lst_MA.ItemData(1)
    'Me.Lst_MA = Get_Priv_Property("prp_Akt_MA_ID")
    
End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)
   On Error GoTo Form_BeforeUpdate_Error

        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo

   On Error GoTo 0
   Exit Sub

Form_BeforeUpdate_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Form_BeforeUpdate of VBA Dokument Form_frm_MA_Mitarbeiterstamm"

End Sub
Private Sub Form_Current()
Dim Bildname As String
Dim Signaturname As String
Dim strSQL As String

    'Nächste freie ID bei neuem Datensatz vorschlagen
    If Me.NewRecord Then
        If IsNull(Me.ID) Then Me.ID = getFreeID(MASTAMM, "ID")
    End If
    
On Error Resume Next

isDirty = False
On Error Resume Next
If Not File_exist(MA_Bildpfad & Me!tblBilddatei) Then
    'Bildname = "KeinBild.jpg"
    Me.MA_Bild.Picture = ""
Else
    Bildname = Me!tblBilddatei
    Me.MA_Bild.Picture = MA_Bildpfad & Bildname
End If
'Me!MA_Bild.Picture = MA_Bildpfad & Bildname

If Not File_exist(MA_Signaturpfad & Me!tblSignaturdatei) Then
    'Signaturname = "KeineSignatur.jpg"
    Me.MA_Signatur.Picture = ""
Else
    Signaturname = Me!tblSignaturdatei
    Me.MA_Signatur.Picture = MA_Signaturpfad & Signaturname
End If
'Me!MA_Signatur.Picture = MA_Signaturpfad & Signaturname

Me!sub_tbl_MA_Zeitkonto_Aktmon1.Visible = False
Me!sub_tbl_MA_Zeitkonto_Aktmon2.Visible = False

strSQL = ""
strSQL = strSQL & ""

Me!lstMA_Vert_All.RowSource = strSQL

Me!lbl_Nachname.caption = Nz(Me!Nachname)
Me!lbl_Vorname.caption = Nz(Me!Vorname)
Me!lbl_PersNr.caption = Nz(Me!PersNr)
Me!lst_Tl1.RowSource = "SELECT * FROM qry_JB_MA_Jahr_tl1A_Ue WHERE AktJahr = " & Me!cboJahrJa & " AND MA_ID = " & Me!ID & " ORDER BY MA_ID, AktJahr, AktMon"
Me!lst_Tl1.Requery
Me!lst_Tl2.RowSource = "SELECT * FROM qry_JB_MA_Jahr_tl2A_Ue WHERE AktJahr = " & Me!cboJahrJa & " AND MA_ID = " & Me!ID & " ORDER BY MA_ID, AktJahr, AktMon"
Me!lst_Tl2.Requery
Me!lst_Tl1M.RowSource = "SELECT * FROM qry_JB_MA_Jahr_tl1A_Ue WHERE AktJahr = " & Me!cboJahr & " AND AktMon = " & Me!cboMonat & " AND MA_ID = " & Me!ID & " ORDER BY MA_ID, AktJahr, AktMon"
Me!lst_Tl1M.Requery
Me!lst_Tl2M.RowSource = "SELECT * FROM qry_JB_MA_Jahr_tl2A_Ue WHERE AktJahr = " & Me!cboJahr & " AND AktMon = " & Me!cboMonat & " AND MA_ID = " & Me!ID & " ORDER BY MA_ID, AktJahr, AktMon"
Me!lst_Tl2M.Requery

Me!sub_tbltmp_MA_Ausgef_Vorlagen.Visible = False

'NVerfüg
TermineAbHeute_AfterUpdate

'If Me!reg_MA.Pages(reg_MA).Name = "pgDienstKl" Then Me.lbGesamt.caption = "Gesamtwert: " & calc_DienstKL(Me.ID) & "€"

On Error GoTo 0

End Sub

Private Sub Form_Open(Cancel As Integer)
Me!lst_Zuo.RowSource = ""

Listfeld = ""

MA_Bildpfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 7"))
MA_Signaturpfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 14"))
Me!lbl_Datum.caption = Date
Gl_MATag_AktDatum = Get_Priv_Property("prp_MA_Aktdat")
Me!cboMonat = Get_Priv_Property("prp_AktMonUeb_Monat")
Me!cboJahr = Get_Priv_Property("prp_AktMonUeb_Jahr")
Mon_Ausw

'Me!sub_tbl_MA_Zeitkonto_Aktmon1.LinkMasterFields = ""
'Me!sub_tbl_MA_Zeitkonto_Aktmon1.LinkChildFields = ""
'
'Me!sub_tbl_MA_Zeitkonto_Aktmon2.LinkMasterFields = ""
'Me!sub_tbl_MA_Zeitkonto_Aktmon2.LinkChildFields = ""
'
'Me!sub_tbl_MA_Zeitkonto_Aktmon1.Visible = False
'Me!sub_tbl_MA_Zeitkonto_Aktmon2.Visible = False

TermineAbHeute_AfterUpdate
isDirty = False

listselect = "SELECT ID, Nachname, Vorname, Ort"

NurAktiveMA_AfterUpdate
Me!Lst_MA = Me!Lst_MA.ItemData(1)

Call Set_Priv_Property("prp_Akt_MA_ID", Me!PersNr)


'Zeitraum für Dienstplan voreinstellen
'ID Bemerkung
'25  Ab Heute
'27  Ab Morgen
'17  Die nächsten 90 Tage
'24  Die nächsten 14 Tage
'8   Aktueller Monat
'22  Die nächsten 30 Tage
'11  Aktuelles Jahr
'18  Nächster Monat
'9   Letzter Monat
'12  Letztes Jahr
'23  Die nächsten 10 Tage



End Sub


Private Sub cboAuswahl_AfterUpdate()
'  0 ; 1 = Tel; 2 = 34 a;3 = email
Select Case Me!cboAuswahl
    Case 1 ' Tel
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Tel_Mobil] as Telefon"
    Case 2 ' 34a
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Hat_keine_34a]"
    Case 3 ' eMail
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Email]"
    Case 4 ' Anstellungsart
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", fAnstellungsart([Anstellungsart_ID]) as Anstellungsart"
    Case 5 'aktiv
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [istaktiv]"
    Case 6 'Geb.Datum
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Geb_Dat]"
    Case 7 ' Arbeitsstd. pro Arbeitstag
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Arbst_pro_Arbeitstag]"
    Case 8 ' Arbeitstage pro Woche
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Arbeitstage_pro_woche]"
    Case 9 ' Resturlaub vom Vorjahr
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Resturl_vorjahr]"
    Case 10 ' Urlaubsanspruch pro Jahr
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Urlaubsanspruch_pro_jahr]"
    Case 11 ' Arbeitsstunden akt. Monat
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [std]"
    Case 12 ' Arbeitsstunden lfd. Jahr
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", []"
    Case 13 ' Kosten pro Mitarbeiter pro Std.
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Kosten_pro_mastunde]"
    Case 14 ' e-pin DFB
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [Epin_DFB]"
    Case 15 ' Sachkunde
        listselect = "SELECT ID, Nachname, Vorname, Ort" & ", [HatSachkunde]"

End Select
NurAktiveMA_AfterUpdate


End Sub

'(Sub) Unternehmer
Private Sub IstSubunternehmer_AfterUpdate()
    If Me.IstSubunternehmer = True Then
        Me.IstNSB = True
        Me.Anstellungsart = 11
    End If
End Sub

Private Sub lbl_Mitarbeitertabelle_Click()
'DoCmd.OpenTable "tbl_ma_mitarbeiterstamm"
DoCmd.OpenQuery "qry_MA_Mitarbeiterstamm_Gueni"

End Sub

Private Sub MANameEingabe_AfterUpdate()

Dim i As Integer
    Me.NurAktiveMA = Null
    Me.Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm ORDER BY Nachname, Vorname;"
    
    Me.Recordset.FindFirst "ID = " & Me!MANameEingabe
    'Listbox entmarkieren
    With Me.Lst_MA
        For i = .ListCount - 1 To 1 Step -1
            .selected(i) = False
        Next i
'        'Eintrag markieren
        For i = 1 To .ListCount - 1
          If CLng(.Column(0, i)) = Me.MANameEingabe.Column(0) Then
             .selected(i) = True
             Exit For
          End If
        Next i
    End With
    Me!MANameEingabe = Null
    
    If Me.IstSubunternehmer = True Then
        Me.pgSubRech.Visible = True
    Else
        Me.pgSubRech.Visible = False
    End If
    
End Sub


Public Sub NurAktiveMA_AfterUpdate()

    Me.cboFilterAuftrag.Visible = False
    Me.btnRch.Visible = False
    Me.txRechSub.Visible = False
    Me.lbRechSub.Visible = False
    Me.txRechCheck.Visible = False
    Me.lbRechCheck.Visible = False
    Me.txRechBezahlt.Visible = False
    Me.lbRechBez.Visible = False
    Me.txRechBezahlt = ""
    Me.txRechCheck = ""
    Me.txRechSub = ""
    Me.lst_Zuo.RowSource = ""
    Me.pgSubRech.Visible = False
    
    Select Case Me!NurAktiveMA
        Case 1 ' Nur Aktive
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 3 or Anstellungsart_ID = 5 or Anstellungsart_ID = 4 ORDER BY Nachname, Vorname;"
        Case 2 ' Nur Festangestellte  'Anstellungsart 3
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 3 ORDER BY Nachname, Vorname;"
        Case 3 ' Nur Minijobber  ' Anstellungsart 5
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 5 ORDER BY Nachname, Vorname;"
        Case 4 ' Nur Unternehmer  ' IstSubunternehmer = True
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where IstSubunternehmer = True ORDER BY Nachname, Vorname;"
            Me.cboFilterAuftrag.Visible = True
            Me.txRechSub.Visible = True
            Me.lbRechSub.Visible = True
            Me.btnRch.Visible = True
            Me.txRechCheck.Visible = True
            Me.lbRechCheck.Visible = True
            Me.txRechBezahlt.Visible = True
            Me.lbRechBez.Visible = True
            Me.pgSubRech.Visible = True
        Case 5 ' Nur Inaktive
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 9 ORDER BY Nachname, Vorname;"
        Case 6 ' Nur Vorrübergehend nicht Tätige
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 6 ORDER BY Nachname, Vorname;"
        Case Else ' Alle
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 2 or Anstellungsart_ID = 3 or Anstellungsart_ID = 4 or Anstellungsart_ID = 5 or Anstellungsart_ID = 6 or Anstellungsart_ID = 9 or Anstellungsart_ID = 10 ORDER BY Nachname, Vorname;"
    End Select
    
    'Ersten Eintrag markieren
    Me.Lst_MA.selected(1) = True
    Call lst_MA_Click
    
End Sub


Private Sub sub_tbl_MA_Zeitkonto_Aktmon2_Exit(Cancel As Integer)
CurrentDb.Execute ("qry_MonZus8")  ' Table löschen
CurrentDb.Execute ("qry_MonZus9")  ' Insert

DoEvents

End Sub


'Rechnungsnummer Subunternehmer
Private Sub txRechSub_AfterUpdate()

Dim sql     As String
Dim VA_ID   As Long
Dim Auftrag As String

    VA_ID = Nz(Me.cboFilterAuftrag.Column(0), 0)
    Auftrag = Me.cboFilterAuftrag
    If Not IsNull(Me.cboFilterAuftrag) And Me.cboFilterAuftrag <> "" Then
        If Nz(TLookup("ID", RCHKOPF, "MA_ID = " & Me.ID & " AND VA_ID = " & VA_ID), "") <> "" Then
            If MsgBox("Eintrag bereits vorhanden - ersetzen?", vbYesNo, "Achtung") = vbYes Then _
                TUpdate "RchNr_Ext = '" & Me.txRechSub & "'", RCHKOPF, "MA_ID = " & Me.ID & " AND VA_ID = " & VA_ID
        Else
            sql = "INSERT INTO " & RCHKOPF & "(MA_ID,VA_ID,RchNr_Ext,RchTyp,Erst_von,Erst_am,Auftrag) VALUES (" & _
                Me.ID & "," & VA_ID & ",'" & Me.txRechSub & "',8,'" & Environ("UserName") & "'," & datumSQL(Now) & ",'" & Auftrag & "')"
            CurrentDb.Execute sql
            
        End If
    End If
    
    Me.txRechSub.SetFocus

End Sub
'
'
''Rechnung bearbeiten
'Private Sub btnRch_Click()
'
'Dim VA_ID As Long
'Dim rchID As Long
'
'    VA_ID = Nz(Me.cboFilterAuftrag.Column(0), 0)
'    rchID = Nz(TLookup("ID", RCHKOPF, "MA_ID = " & Me.ID & " AND VA_ID = " & VA_ID), 0)
'
'    If Not IsNull(Me.cboFilterAuftrag) And Me.cboFilterAuftrag <> "" Then
'        If rchID <> 0 Then
'            DoCmd.OpenForm "frm_Rch_Kopf_simple", acNormal, , "ID = " & rchID
'        Else
'            MsgBox "Bitte erst Rechnung anlegen!", vbCritical
'        End If
'    End If
'
'End Sub


Private Sub TermineAbHeute_AfterUpdate()
Dim strSQL As String
On Error Resume Next

Me!sub_MA_tbl_MA_NVerfuegZeiten.Form!MA_ID.defaultValue = Chr$(34) & Me!PersNr & Chr$(34)

strSQL = ""

strSQL = strSQL & "SELECT tbl_MA_NVerfuegZeiten.ID, tbl_MA_NVerfuegZeiten.MA_ID, tbl_MA_NVerfuegZeiten.Zeittyp_ID, " & _
    "tbl_MA_NVerfuegZeiten.vonDat , tbl_MA_NVerfuegZeiten.bisDat, tbl_MA_NVerfuegZeiten.Bemerkung, tbl_MA_NVerfuegZeiten.Erst_von, " & _
    "tbl_MA_NVerfuegZeiten.Erst_am, tbl_MA_NVerfuegZeiten.Aend_von, tbl_MA_NVerfuegZeiten.Aend_am, tbl_MA_NVerfuegZeiten.vonZeit, tbl_MA_NVerfuegZeiten.bisZeit FROM tbl_MA_NVerfuegZeiten"
strSQL = strSQL & " WHERE MA_ID = " & Me!PersNr
If Me!TermineAbHeute = True Then
    strSQL = strSQL & "  AND (((tbl_MA_NVerfuegZeiten.vonDat) >= Date()))"
Else
    strSQL = strSQL & "  AND (tbl_MA_NVerfuegZeiten.vonDat BETWEEN " & datumSQL(Me.AU_von) & " AND " & datumSQL(Me.AU_bis) & ")"
End If

strSQL = strSQL & " ORDER BY tbl_MA_NVerfuegZeiten.MA_ID, tbl_MA_NVerfuegZeiten.vonDat, tbl_MA_NVerfuegZeiten.bisDat;"

If CreateQuery(strSQL, "qry_tbl_MA_NVerfuegZeiten") Then
    Me!sub_MA_tbl_MA_NVerfuegZeiten.Form.recordSource = "qry_tbl_MA_NVerfuegZeiten"
Else
    'MsgBox "Mööp"
End If
Me!sub_MA_tbl_MA_NVerfuegZeiten.LinkMasterFields = ""
Me!sub_MA_tbl_MA_NVerfuegZeiten.LinkChildFields = ""
Me!sub_MA_tbl_MA_NVerfuegZeiten.Form.Requery
Me!sub_MA_tbl_MA_NVerfuegZeiten.Form.FilterOn = False
End Sub


Private Sub MA_AnzDat_bis_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub MA_AnzDat_von_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub Geb_Dat_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub lst_MA_Click()
On Error Resume Next
    Me.Painting = False
    Me.Controls("subZuoStunden").Form.lstDetails.RowSource = ""
    Me.Controls("subZuoStunden").Form.neuberechnen ("ZUO_ID = 0")
    Me.cboFilterAuftrag = ""
    Me.Recordset.FindFirst "ID = " & Me.Lst_MA.Column(0)
    Gl_Akt_MA_ID = Me.Lst_MA.Column(0)
    GMA_ID = Gl_Akt_MA_ID
    
    'Debug.Print Gl_Akt_MA_ID
    DoEvents
    Call Set_Priv_Property("prp_Akt_MA_ID", Gl_Akt_MA_ID)
    DoEvents
    
    Me!sub_tbl_MA_Zeitkonto_Aktmon1.Visible = False
    Me!sub_tbl_MA_Zeitkonto_Aktmon2.Visible = False
    
    Call Set_Priv_Property("prp_Akt_MA_ID", Me!PersNr)
    MA_Bildpfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 7"))
    MA_Signaturpfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 14"))
    
    Wait 1
    
    If IsNull(Me.Kontoinhaber) Then Me.Kontoinhaber = Me.Nachname & " " & Me.Vorname
    If IsNull(Me.Stundenlohn_brutto) And Me.Anstellungsart_ID = 5 Then Me.Stundenlohn_brutto = 2
    If Me.StundenZahlMax = 0 And Me.Anstellungsart_ID = 5 Then Me.StundenZahlMax = 38.5
    Me.txRechSub = ""
    
    
    'Call btnLesen_Click
    Call btnAU_Lesen_Click
    Call regMA(Me.reg_MA)
    
    Me.Painting = True

End Sub

Private Sub lst_Zuo_DblClick(Cancel As Integer)
Dim iVA_ID As Long
Dim iVADatum_ID
Dim mename As String
Dim i As Long

iVA_ID = Nz(Me!lst_Zuo, 0)
iVADatum_ID = Nz(Me.lst_Zuo.Column(2), 0)

If iVA_ID = 0 Then Exit Sub

DoCmd.OpenForm "frm_VA_Auftragstamm"
Form_frm_VA_Auftragstamm.Recordset.FindFirst "ID = " & iVA_ID
If iVADatum_ID <> 0 Then Form_frm_VA_Auftragstamm.cboVADatum = iVADatum_ID

Form_frm_VA_Auftragstamm.zsub_lstAuftrag.Form.RecordsetClone.FindFirst "tbl_VA_Auftragstamm.ID = " & iVA_ID
Form_frm_VA_Auftragstamm.zsub_lstAuftrag.Form.Bookmark = Form_frm_VA_Auftragstamm.zsub_lstAuftrag.Form.RecordsetClone.Bookmark

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents


End Sub

' Wechsel Register
Private Sub reg_MA_Change()
    Call regMA(Me.reg_MA, True)

End Sub


Function Adresse_Upd()

Dim strSQL As String

strSQL = ""
strSQL = strSQL & "UPDATE tbl_MA_Mitarbeiterstamm SET tbl_MA_Mitarbeiterstamm.Briefkopf = [Anr] & Chr$(13) & Chr$(10) & [Vorname] & ' ' & proper([Nachname]) & Chr$(13) & Chr$(10) & [Strasse] & ' ' & [Nr] & Chr$(13) & Chr$(10) & Chr$(13) & Chr$(10) & [PLZ] & ' ' & [Ort]"
strSQL = strSQL & " WHERE (((tbl_MA_Mitarbeiterstamm.IstBrfAuto)=False) AND ((LCase(Nz(Left([Geschlecht],1))))='m' Or (LCase(Nz(Left([Geschlecht],1))))='w')"
strSQL = strSQL & " AND ((tbl_MA_Mitarbeiterstamm.ID)= " & Me!ID & "));"
CurrentDb.Execute (strSQL)
DoEvents

Me!Briefkopf.Requery
DoEvents

End Function

Function Adresse_Set_Dirty()
isDirty = True
Me.DienstausweisNr = Me.ID
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


Private Sub btnMaps_Click()

Dim WSHShell  As Object
Dim sFFExe    As String    'FF executable path/filename
Dim address   As String
Dim sURL      As String

On Error GoTo Error_Handler

    address = Me.Strasse & " " & Me.Nr & ", " & Me.PLZ & " " & Me.Ort
    sURL = "https://www.google.de/maps/place/" & address
        
    'Determine the Path to FF executable
    Set WSHShell = CreateObject("WScript.Shell")
    sFFExe = WSHShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Firefox.EXE\")
    If sFFExe = "" Then sFFExe = WSHShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Chrome.EXE\")
    'Open the URL
    Shell """" & sFFExe & """" & " -new-tab """ & sURL & "", vbHide
    
Error_Handler_Exit:
    On Error Resume Next
    If Not WSHShell Is Nothing Then Set WSHShell = Nothing
    Exit Sub
 
Error_Handler:
    If Err.Number = -2147024894 Then
        MsgBox "FireFox does not appear to be installed on this compter", _
               vbInformation Or vbOKOnly, "Unable to open the requested URL"
        Resume Next
    Else
        MsgBox "The following error has occurred" & vbCrLf & vbCrLf & _
               "Error Number: " & Err.Number & vbCrLf & _
               "Error Source: OpenURLInFF" & vbCrLf & _
               "Error Description: " & Err.description & _
               Switch(Erl = 0, "", Erl <> 0, vbCrLf & "Line No: " & Erl) _
               , vbOKOnly + vbCritical, "An Error has Occurred!"
    End If
    Resume Error_Handler_Exit
    

End Sub


'Arbeitszeit berechnen (Nettostunden)
Function calc_netto_std(MA_ID As Long, von As Date, bis As Date) As Double
        
Dim rst As Recordset
Dim sql As String
   
On Error GoTo Err

    calc_netto_std = 0
    sql = "SELECT MA_Netto_Std FROM qry_MA_VA_Plan_All_AufUeber2_Zuo WHERE MA_ID = " & MA_ID & " AND VADatum >= " & datumSQL(von) & " AND VADatum <= " & datumSQL(bis)
    Set rst = CurrentDb.OpenRecordset(sql)
    
    Do While Not rst.EOF
        calc_netto_std = calc_netto_std + rst.fields(0)
        rst.MoveNext
    Loop
    
    
Ende:
    Exit Function
Err:
    rst.Close
    Set rst = Nothing
    calc_netto_std = 0
Resume Ende
    
End Function


'Anwesenheitszeit berechnen (Bruttostunden)
Function calc_brutto_std(MA_ID As Long, von As Date, bis As Date, Optional Auftrag As String) As Double
        
Dim rst As Recordset
Dim sql As String
   
On Error GoTo Err

    calc_brutto_std = 0
    sql = "SELECT MA_brutto_Std FROM qry_MA_VA_Plan_All_AufUeber2_Zuo WHERE MA_ID = " & MA_ID & " AND VADatum >= " & datumSQL(von) & " AND VADatum <= " & datumSQL(bis)
    If Auftrag <> "" Then sql = sql & " AND Auftrag = '" & Auftrag & "'"
    Set rst = CurrentDb.OpenRecordset(sql)
    
    Do While Not rst.EOF
        calc_brutto_std = calc_brutto_std + rst.fields(0)
        rst.MoveNext
    Loop
    
    
Ende:
    Exit Function
Err:
    rst.Close
    Set rst = Nothing
    calc_brutto_std = 0
Resume Ende
    
End Function



'Registersteuerung Mitarbeiterstamm
Function regMA(register As Integer, Optional reg_change As Boolean)

Dim strSQL As String
Dim rst As DAO.Recordset
Dim strCriteria As String
Dim j As Long
Dim adresse As String

On Error Resume Next

    'Zeitraum erstmal ausblenden
    Me.cboZeitraum.Visible = False
    Me.AU_von.Visible = False
    Me.AU_bis.Visible = False

    Select Case Me!reg_MA.Pages(register).Name

        Case "pgAdresse"
                       
        Case "pgBem"
        
'        Case "pgDienstKl"
'            Me.lbGesamt.caption = "Gesamtwert: " & calc_DienstKL(Me.ID) & "€"
        
        Case "pgMonat"
            Me.cboMonat.SetFocus
            Me.cboMonat = Get_Priv_Property("prp_AktMonUeb_Monat")
            Me.cboJahr = Get_Priv_Property("prp_AktMonUeb_Jahr")
            Mon_Ausw
        
        Case "pgJahr"
            Me.cboJahrJa = Get_Priv_Property("prp_AktMonUeb_Jahr")
          
        Case "pgAuftrUeb"
            Me.cboZeitraum.Visible = True
            Me.AU_von.Visible = True
            Me.AU_bis.Visible = True
            If reg_change = True Then
                Me.cboZeitraum = 9 'Letzter Monat
                Call cboZeitraum_AfterUpdate
            End If
            
        Case "pgStundenuebersicht"
            Me.cboZeitraum.Visible = True
            Me.AU_von.Visible = True
            Me.AU_bis.Visible = True
        
        Case "pgnVerfueg"
            Me.cboZeitraum.Visible = True
            Me.AU_von.Visible = True
            Me.AU_bis.Visible = True
            Me.TermineAbHeute = False
            Call TermineAbHeute_AfterUpdate
        
        Case "pgPlan"
            If reg_change = True Then
                Me.cboZeitraum = 23 'Die nächsten 10 Tage
                Call cboZeitraum_AfterUpdate
            End If
                
            Me.cboZeitraum.Visible = True
            Me.AU_von.Visible = True
            Me.AU_bis.Visible = True
            btnAUPl_Lesen_Click
        
        Case "pgStdVormonat"
            Me!pgJahrstdvormon = Get_Priv_Property("prp_AktMonUeb_Jahr")
        
        Case "pgMaps"
            Me.ufrm_Maps.Form.Controls("Webbrowser0").ScriptErrorsSuppressed = True
            Me.ufrm_Maps.Form.Controls("Webbrowser0").Silent = True
            Me.ufrm_Maps.Form.Webbrowser0.Object.ScriptErrorsSuppressed = True
            Me.ufrm_Maps.Form.Webbrowser0.Object.Silent = True
            adresse = Me.Strasse & " " & Me.Nr & ", " & Me.PLZ & " " & Me.Ort
            'Me.ufrm_Maps.Form.Controls("Webbrowser0").Navigate "https://www.google.de/maps/place/" & adresse
            Me.ufrm_Maps.Form.Controls("Webbrowser0").Navigate "https://www.google.de/maps/preview/place/" & adresse & "?force=lite"
            'Me.ufrm_Maps.Form.Controls("Webbrowser0").Navigate "https://www.whatsmybrowser.org/"
            
        Case "pgSubRech"
            Me.cboZeitraum.Visible = True
            Me.AU_von.Visible = True
            Me.AU_bis.Visible = True
            If reg_change = True Then
                Me.cboZeitraum = 8 'Dieser Monat
                Call cboZeitraum_AfterUpdate
            End If
            If Not IsInitial(Me.AU_von) And Not IsInitial(Me.AU_bis) Then
                Me.subAuftragRech.Form.filter = "ErsterWertvonVADatum >= " & datumSQL(Me.AU_von) & " AND ErsterWertvonVADatum <= " & datumSQL(Me.AU_bis)
                Me.subAuftragRech.Form.FilterOn = True
            End If
                      
        Case Else

    End Select
    
End Function

' =========================================================================
' Code für: frm_MA_Mitarbeiterstamm
' HINWEIS: Dieser Code muss manuell in das Formular eingefügt werden
' =========================================================================

Private Sub btn_Dokumente_Click()
    ' Öffnet Dokumentenverwaltung für aktuellen Mitarbeiter
    If Not IsNull(Me.ID) Then
        DoCmd.OpenForm "frm_MA_Dokumente", , , "MA_ID=" & Me.ID
    Else
        MsgBox "Bitte zuerst Mitarbeiter auswählen!", vbExclamation
    End If
End Sub

'Private Sub btn_DokumentUpload_Click()
'    ' Upload-Dialog für neues Dokument
'    Dim fd As FileDialog
'    Dim Datei As String
'    Dim dokTyp As String
'
'    If IsNull(Me.ID) Then
'        MsgBox "Bitte zuerst Mitarbeiter auswählen!", vbExclamation
'        Exit Sub
'    End If
'
'    ' Dokumenttyp abfragen
'    dokTyp = InputBox("Dokumenttyp:" & vbCrLf & _
'                      "1 = Personalausweis" & vbCrLf & _
'                      "2 = Arbeitsvertrag" & vbCrLf & _
'                      "3 = §34a Bescheinigung" & vbCrLf & _
'                      "4 = Führerschein" & vbCrLf & _
'                      "5 = DFB Zertifikat" & vbCrLf & _
'                      "6 = Gesundheitszeugnis" & vbCrLf & _
'                      "9 = Sonstiges", "Dokumenttyp auswählen", "1")
'
'    If dokTyp = "" Then Exit Sub
'
'    Select Case dokTyp
'        Case "1": dokTyp = DOK_PERSONALAUSWEIS
'        Case "2": dokTyp = DOK_VERTRAG
'        Case "3": dokTyp = DOK_34A
'        Case "4": dokTyp = DOK_FUEHRERSCHEIN
'        Case "5": dokTyp = DOK_DFB
'        Case "6": dokTyp = DOK_GESUNDHEIT
'        Case Else: dokTyp = DOK_SONSTIG
'    End Select
'
'    ' Datei-Dialog
'    Set fd = Application.FileDialog(msoFileDialogFilePicker)
'    fd.title = "Dokument auswählen"
'    fd.Filters.clear
'    fd.Filters.Add "Alle Dateien", "*.*"
'    fd.Filters.Add "PDF", "*.pdf"
'    fd.Filters.Add "Word", "*.doc;*.docx"
'    fd.Filters.Add "Bilder", "*.jpg;*.jpeg;*.png"
'
'    If fd.Show = -1 Then
'        Datei = fd.SelectedItems(1)
'
'        If UploadDokument(Me.ID, dokTyp, Datei) Then
'            ' Aktualisiere Ansicht falls Unterformular geöffnet
'            On Error Resume Next
'            Forms("frm_MA_Dokumente").Requery
'            On Error GoTo 0
'        End If
'    End If
'
'    Set fd = Nothing
'End Sub

'Private Sub btn_OrdnerOeffnen_Click()
'    ' Öffnet Personalakten-Ordner im Explorer
'    If Not IsNull(Me.ID) Then
'        OeffnePersonalaktenOrdner Me.ID
'    Else
'        MsgBox "Bitte zuerst Mitarbeiter auswählen!", vbExclamation
'    End If
'End Sub
'

Private Sub cmdGeocode_Click()
    GeocodierenMA Me
End Sub
