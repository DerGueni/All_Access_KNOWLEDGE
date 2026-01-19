VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_Rch_Berechnungsliste"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Public Function VAOpen(iVA_ID As Long)
Dim strSQL As String
Dim i As Long

Me!VorlageDokNr = 14
Me!VorlageNr = 4

Me!cboAuftrag = iVA_ID
cboAuftrag_AfterUpdate
Me!RegAuftrag.Enabled = True
Me!cboAuftrag.Locked = True
Me!cboAuftrag.Enabled = False

DoEvents

btnStdBerech_Click

End Function


Private Sub Befehl88_Click()
btnPrint2_Click
End Sub

Private Sub Befehl91_Click()
btnPrint1_Click
btn_zurueck_zur_AV_Click
End Sub

Private Sub Befehl92_Click()
'Me.CloseButton

End Sub

Private Sub btn_ber_best_Click()
Me.pgBerech.SetFocus
Me.pgBerech.Requery

Me.sub_Rch_Pos_Auftrag.Form.Requery
'DoCmd.OpenReport "str_Stundenliste", acViewPreview, , , acWindowNormal
fCreateRech_Neu
Me.btnRchWd_Open.Visible = True

End Sub

Private Sub btn_PDFagain_Click()
Dim myStoryRange
Dim SearchStr As String
Dim ReplaceStr As String
Dim tTmp As String
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim FiCrLf As String
Dim ergCr As String
Dim ergCr1 As String

Dim i As Long
Dim strdoc As String

Dim Docname As String

Dim wdApp As Object
Dim wdDoc As Object

Const wdFormatPDF As Long = 17

WDStart:

Sleep 100

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

On Error Resume Next
Set wdApp = GetObject(, "Word.Application")
If wdApp Is Nothing Then
    Err.clear
    
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    
    Set wdApp = CreateObject("Word.Application")
End If
  
    Docname = Me!strPDF_Rechnung
    i = InStrRev(Docname, ".")
    Docname = Left(Docname, i) & "docx"

    If Not File_exist(Docname) Then
        MsgBox "Word Datei existiert nicht"
        Exit Sub
    End If
    

    wdApp.Documents.Open fileName:=Docname, ReadOnly:=True
    Set wdDoc = wdApp.ActiveDocument

' Word Dokument als PDF ausgeben
'################################
    i = InStrRev(Docname, ".")
    If i > 0 Then
        strdoc = Left(Docname, i) & "pdf"
        wdDoc.SaveAs2 strdoc, wdFormatPDF   'WdSaveFormat-Enum  - wdFormatPDF - 17
    End If

wdApp.Quit False

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

MsgBox "Doc als PDF gedruckt"

End Sub


Private Sub btn_zurueck_zur_AV_Click()
DoCmd.OpenForm "frm_av_auftragstamm", , [veranstalt_status_id = 2]
End Sub

Private Sub btnPrint1_Click()
Dim strDok As String
strDok = Me!strPDF_Rechnung
If File_exist(strDok) Then PrintDoc strDok
End Sub

Private Sub btnPrint2_Click()
Dim strDok As String
strDok = Me!str_Stundenliste
If File_exist(strDok) Then PrintDoc strDok
End Sub

Private Sub btnPrint3_Click()
Dim strDok As String
strDok = Me!strPDF_Einsatzliste
If File_exist(strDok) Then PrintDoc strDok
End Sub

Private Sub btnRchWd_Open_Click()

Dim strVorlageDoc As String
Dim strDateiname As String

Dim docnam As String
Dim docpath As String

Dim ustnam As String
Dim Ustwert As String
Dim i As Long

Dim Ueber_Pfad As String
Dim PDF_Datei As String

Dim strSQL As String

If Me!TaetigkeitArt = 1 Then

    f_tmp_position_fill

End If

fCreateRech_Neu

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))
Ueber_Pfad = Ueber_Pfad & "KD_" & Me!cboKunde & "\"
Call Path_erzeugen(Ueber_Pfad, False, True)
PDF_Datei = Ueber_Pfad & "Stundenliste_Rch_" & Me!VA_ID & ".pdf"
Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!VA_ID)

DoCmd.OutputTo acOutputReport, "rpt_Rch_Stundenliste", "PDF", PDF_Datei
DoEvents
Sleep 2000
DoEvents
    
'Me!str_Stundenliste = PDF_Datei
'Me!ist_Std_Liste = True

Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery
DoEvents

docpath = Get_Priv_Property("prp_CONSYS_GrundPfad") & TLookup("DocPfad", "_tblEigeneFirma_TB_Dok_Dateinamen", "ID = " & Me!VorlageDokNr)
docnam = TLookup("Docname", "_tblEigeneFirma_TB_Dok_Dateinamen", "ID = " & Me!VorlageDokNr)

If Right(docpath, 1) <> "\" Then docpath = docpath & "\"
strVorlageDoc = docpath & docnam

i = InStrRev(Me!strPDF_Rechnung, ".")
strDateiname = Left(Me!strPDF_Rechnung, i) & "docx"

Call WordReplace(strVorlageDoc, strDateiname)

Call Word_Insert_Table(strDateiname)

i = Nz(TLookup("ID", "tbltmp_Textbaustein_Ersetzung", "TB_Name_Kl = '[R_7MwSt]'"), 0)
If i > 0 Then
    Ustwert = TLookup("Ersetzung", "tbltmp_Textbaustein_Ersetzung", "ID = " & i)
    If Ustwert = "0,00 €" Then
        Call Ust_Loesch("Ust7", strDateiname)
    End If
End If

i = Nz(TLookup("ID", "tbltmp_Textbaustein_Ersetzung", "TB_Name_Kl = '[R_19MwSt]'"), 0)
If i > 0 Then
    Ustwert = TLookup("Ersetzung", "tbltmp_Textbaustein_Ersetzung", "ID = " & i)
    If Ustwert = "0,00 €" Then
        Call Ust_Loesch("Ust19", strDateiname)
    End If
End If

PDF_Print strDateiname
Me!ist_Rechnung = True
  
'Rechnung als "erzeugt" mrkieren
If Me!TaetigkeitArt = 1 Then
    CurrentDb.Execute ("qry_Rch_Update_Va_Status4")
    DoEvents
    If isFormLoad("frm_VA_Auftragstamm") Then
        Forms!frm_VA_Auftragstamm.Veranst_Status_ID.Requery
        Forms!frm_VA_Auftragstamm.zsub_lstAuftrag.Form.Recalc
        DoEvents
        Form_frm_VA_Auftragstamm.f_lst_Auft_Cl
    End If
End If

MsgBox "Rechnung erstellt"

If Me!IsWordAutoClose Then
    wd_Close_All
    Reset_Word_Objekt
Else
    Reset_Word_Objekt
End If
DoCmd.OpenForm "frm_va_auftragstamm"
End Sub

Private Sub btnSendenAn_Click()
Dim s As String
CurrentDb.Execute ("Delete * FROM tbltmp_Attachfile")
DoEvents
If Me!ist_Rechnung Then
    s = Nz(Me!strPDF_Rechnung)
    If File_exist(s) Then
        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
    End If
End If
If Me!ist_Std_Liste Then
    s = Nz(Me!str_Stundenliste)
    If File_exist(s) Then
        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
    End If
End If
If Me!ist_Einsatzliste Then
    s = Nz(Me!strPDF_Einsatzliste)
    If File_exist(s) Then
        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
    End If
End If

DoCmd.OpenForm "frmOff_Outlook_aufrufen", , , , , , Me!cboKunde.Column(0)
Form_frmOff_Outlook_aufrufen.VAOpen_rch

End Sub

Private Sub cboAuftrag_AfterUpdate()

Dim Ueber_Pfad As String
Dim PDF_Datei As String

'Me!cboKunde.Enabled = True
'Me!cboKunde.Locked = False

Me!VA_ID = Me!cboAuftrag.Column(0)
Me!cboKunde = Me!cboAuftrag.Column(1)
If Me!cboKunde > 0 Then
    Me!cboKunde.Enabled = False
    Me!cboKunde.Locked = True
    FSetStdPreis (Me!cboKunde)
Else
    Me!cboKunde.Enabled = True
    Me!cboKunde.Locked = False
    Exit Sub
End If

' Nur wenn Kunde im auftrag existiert

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))
Ueber_Pfad = Ueber_Pfad & "KD_" & Me!cboKunde & "\"

' Prüfen ob Einsatzliste existiert
PDF_Datei = Ueber_Pfad & "Einsatz_Alle_" & Me!VA_ID & ".pdf"
If File_exist(PDF_Datei) Then
    Me!strPDF_Einsatzliste = PDF_Datei
    Me!ist_Einsatzliste = True
End If

' Prüfen ob Stunden-Liste existiert
PDF_Datei = Ueber_Pfad & "Stundenliste_Rch_" & Me!VA_ID & ".pdf"
If File_exist(PDF_Datei) Then
    Me!str_Stundenliste = PDF_Datei
    Me!ist_Std_Liste = True
End If

' Prüfen ob Rechnung existiert
PDF_Datei = Ueber_Pfad & "Rch_" & Me!VA_ID & ".pdf"
If File_exist(PDF_Datei) Then
    Me!strPDF_Rechnung = PDF_Datei
    Me!ist_Rechnung = True
End If

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub


Private Sub btnAusgEinsatzliste_Click()
'Dim Ueber_Pfad As String
'Dim PDF_Datei As String
'Dim s As String
'Dim i As Long
Dim Datum As Date
Dim SDatum As String
Dim Auftrag As String

Datum = Me.Controls("Dat_VA_Von")
SDatum = Mid(Datum, 4, 2) & "-" & Left(Datum, 2) & "-" & Right(Datum, 2)
Auftrag = Me.Controls("Auftrag")

'Hier mault der Compiler
'Call fXL_Export_Auftrag(ID, "\\consecpc5\e\TERASTATION 13.06.14\CONSEC\CONSEC PLANUNG AKTUELL\E Aufträge 2015 noch zu berechnen\", SDatum & " " & Auftrag & " " & Objekt & ".xlsm")
Call fXL_Export_Auftrag(Me.VA_ID, CONSYS & "CONSEC\CONSEC PLANUNG AKTUELL\E Aufträge 2015 noch zu berechnen\", SDatum & " " & Auftrag & " " & Me.cboAuftrag.Value & ".xlsm")
'
'If Len(Trim(Nz(VA_ID))) = 0 Or Me!VA_ID.Visible = False Then Exit Sub
'
'i = Get_Priv_Property("prp_Report1_Auftrag_IstTage")
'Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))
'Ueber_Pfad = Ueber_Pfad & "KD_" & Me!cboKunde & "\"
'
'Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", -1)
'
'Call Path_erzeugen(Ueber_Pfad, False, True)
'
'PDF_Datei = Ueber_Pfad & "Einsatz_Alle_" & Me!VA_ID & ".pdf"
'
'Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!VA_ID)
''Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", Me!cboVADatum)
'
'DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei
'DoEvents
'Sleep 2000
'DoEvents
'
'Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", i)
'
'Me!strPDF_Einsatzliste = PDF_Datei
'
'Me!ist_Einsatzliste = True
    
's = PDF_Datei
'If Len(Trim(Nz(s))) > 0 Then
'    CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
'    Me!sub_tbltmp_Attachfile.Form.Requery
'End If


End Sub

Private Function fbtnStunden()

Dim Ueber_Pfad As String
Dim PDF_Datei As String

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))
Ueber_Pfad = Ueber_Pfad & "KD_" & Me!cboKunde & "\"
Call Path_erzeugen(Ueber_Pfad, False, True)
PDF_Datei = Ueber_Pfad & "Stundenliste_Rch_" & Me!VA_ID & ".pdf"
Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!VA_ID)

DoCmd.OutputTo acOutputReport, "rpt_Rch_Stundenliste", "PDF", PDF_Datei
DoEvents
Sleep 200
DoEvents
    
Me!str_Stundenliste = PDF_Datei
Me!ist_Std_Liste = True

End Function


Private Sub btnStdBerech_Click()
Dim i As Long
Dim j As Long
Dim iVA_ID As Long

If Len(Trim(Nz(Me!cboAuftrag))) = 0 Then
    Exit Sub
End If
If Nz(Me!cboKunde, 0) = 0 Then
    MsgBox "Bitte erst Auftraggeber zuordnen"
    Exit Sub
End If

Me!strPDF_Rechnung = ""
Me!str_Stundenliste = ""
Me!strPDF_Einsatzliste = ""

Me!pgStd.SetFocus

CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.PKW_Anzahl = 1 WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & Me!VA_ID & ") AND ((Nz([PKW],0))>0) AND ((Nz([PKW_Anzahl],0))=0));")
DoEvents
Me!Anz_PKW = Nz(TSum("PKW_Anzahl", "tbl_MA_VA_Zuordnung", "VA_ID= " & Me!VA_ID), 0)
Me!SumPKW_MA = Nz(TSum("PKW", "tbl_MA_VA_Zuordnung", "VA_ID= " & Me!VA_ID), 0)
DoEvents
Me!sub_MA_VA_Zuordnung.Form.Requery
DoEvents

If Me!StdF1 = 0 Then
    MsgBox "Standard Preis fehlt. Bitte Stundensatz eingeben"
    Me.StdF1.SetFocus
    Exit Sub
End If
i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID = 0 AND VA_ID = " & Me!VA_ID), 0)
If i > 0 Then
    MsgBox "Bitte erst alle MA zuordnen"
    Me!sub_MA_VA_Zuordnung.SetFocus
    Me!sub_MA_VA_Zuordnung.MA_ID.SetFocus
    
    Exit Sub
End If
'i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "len(trim(Nz(MA_Ende))) = 0 AND VA_ID = " & Me!VA_ID), 0)
'If i > 0 Then
'    MsgBox "Bitte erst alle Endzeiten setzen"
'    Me!sub_MA_VA_Zuordnung.SetFocus
'    Me!sub_MA_VA_Zuordnung.VA_Ende.SetFocus
'    Exit Sub
'End If
i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "len(trim(Nz(MA_Start))) = 0 AND VA_ID = " & Me!VA_ID), 0)
If i > 0 Then
    MsgBox "Bitte erst alle Startzeiten setzen"
    Me!sub_MA_VA_Zuordnung.SetFocus
    Me!sub_MA_VA_Zuordnung.VA_Start.SetFocus
    Exit Sub
End If
i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "PreisArt_ID = 3 AND VA_ID = " & Me!VA_ID), 0)
If Me!StdF3 = 0 And i > 0 Then
    MsgBox "Einsatzleiter vorhanden, aber Preis fehlt. Bitte Stundensatz EL eingeben"
    Me.StdF3.SetFocus
    Exit Sub
End If
If Me!Anz_PKW > 0 And Me!StdPKW = 0 Then
    If vbCancel = MsgBox("PKW vergütet aber keine berechnet - so ok ?", vbOKCancel + vbQuestion, "Keine Fahrtkosten berechnen") Then
        Exit Sub
    End If
End If

fStundenberech Me!VA_ID

Me!sub_MA_VA_Zuordnung.Form.Requery
DoEvents

End Sub



Private Sub btnBerList_Click()

Dim iRch_ID As Long
Dim strSQL As String

Dim Ges_Alles As Currency

strSQL = ""

CurrentDb.Execute ("Delete * FROM tbltmp_Position;")
DoEvents

Me!Rch_ID = fRch_ID_fuell(Me!VA_ID, 1)

CurrentDb.Execute ("Delete * FROM tbl_Rch_Pos_Auftrag WHERE VA_ID = " & Me!VA_ID & ";")
DoEvents

Call Set_Priv_Property("EZ_Preisart_1", Me!StdF1)
Call Set_Priv_Property("EZ_Preisart_3", Me!StdF3)
Call Set_Priv_Property("EZ_Preisart_4", Me!StdPKW)

strSQL = ""
strSQL = strSQL & "INSERT INTO tbl_Rch_Pos_Auftrag ( VA_ID, VorlageNr, kun_ID, VADatum, VAStart_ID, MA_Start, MA_Ende, Menge, EzPreis,"
strSQL = strSQL & " Mengenheit, MwSt, Beschreibung, Preisart_ID, GesPreis, Rch_ID, Anz_MA )"
strSQL = strSQL & " SELECT tbl_MA_VA_Zuordnung.VA_ID, 404 AS VorlageNr, tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID,"
strSQL = strSQL & " tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VAStart_ID, tbl_VA_Start.VA_Start,"
strSQL = strSQL & " Max(tbl_MA_VA_Zuordnung.MA_Ende) AS VA_Ende, Sum(tbl_MA_VA_Zuordnung.MA_Brutto_Std2) AS Menge,"
strSQL = strSQL & " fEzPreis([tbl_MA_VA_Zuordnung].[Preisart_ID]) AS EzPreis, tbl_KD_Artikelbeschreibung.Mengenheit,"
strSQL = strSQL & " tbl_KD_Artikelbeschreibung.MwSt_Satz, tbl_KD_Artikelbeschreibung.Beschreibung,"
strSQL = strSQL & " tbl_MA_VA_Zuordnung.Preisart_ID, Sum([MA_Brutto_Std2]*fEzPreis([tbl_MA_VA_Zuordnung].[Preisart_ID])) AS GesPreis, " & Me!Rch_ID & " AS Rch_ID,"
strSQL = strSQL & " Count(tbl_MA_VA_Zuordnung.ID) As Anz_MA"
strSQL = strSQL & " FROM (tbl_VA_Auftragstamm INNER JOIN (tbl_MA_VA_Zuordnung LEFT JOIN tbl_VA_Start"
strSQL = strSQL & " ON tbl_MA_VA_Zuordnung.VAStart_ID = tbl_VA_Start.ID) ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID)"
strSQL = strSQL & " LEFT JOIN tbl_KD_Artikelbeschreibung ON tbl_MA_VA_Zuordnung.PreisArt_ID = tbl_KD_Artikelbeschreibung.ID"
strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID) = " & Me!VA_ID & ") And ((tbl_MA_VA_Zuordnung.Preisart_ID) < 4))"
strSQL = strSQL & " GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_VA_Auftragstamm.Veranstalter_ID, tbl_MA_VA_Zuordnung.VADatum,"
strSQL = strSQL & " tbl_MA_VA_Zuordnung.VAStart_ID, tbl_VA_Start.VA_Start, fEzPreis([tbl_MA_VA_Zuordnung].[Preisart_ID]),"
strSQL = strSQL & " tbl_KD_Artikelbeschreibung.Mengenheit, tbl_KD_Artikelbeschreibung.MwSt_Satz,"
strSQL = strSQL & " tbl_KD_Artikelbeschreibung.Beschreibung, tbl_MA_VA_Zuordnung.Preisart_ID;"
CurrentDb.Execute (strSQL)

If fEzPreis(4) > 0 Then
    strSQL = ""
    strSQL = strSQL & "INSERT INTO tbl_Rch_Pos_Auftrag ( VA_ID, VorlageNr, kun_ID, VADatum, VAStart_ID, MA_Start, MA_Ende, Menge, EzPreis,"
    strSQL = strSQL & " Preisart_ID, Mengenheit, MwSt, Beschreibung, GesPreis, Rch_ID, Anz_MA )"
    strSQL = strSQL & " SELECT tbl_MA_VA_Zuordnung.VA_ID, 405 AS VorlageNr, tbl_VA_Auftragstamm.Veranstalter_ID AS kun_ID, tbl_MA_VA_Zuordnung.VADatum, "
    strSQL = strSQL & " tbl_MA_VA_Zuordnung.VAStart_ID, tbl_MA_VA_Zuordnung.MA_Start, Max(tbl_MA_VA_Zuordnung.MA_Ende) AS MaxvonMA_Ende,"
    strSQL = strSQL & " Sum(tbl_MA_VA_Zuordnung.PKW_Anzahl) AS SummevonPKW_Anzahl, fEzPreis(4) AS EzPreis,"
    strSQL = strSQL & " tbl_KD_Artikelbeschreibung.ID AS Preisart_ID, tbl_KD_Artikelbeschreibung.Mengenheit,"
    strSQL = strSQL & " tbl_KD_Artikelbeschreibung.MwSt_Satz AS MwSt, tbl_KD_Artikelbeschreibung.Beschreibung,"
    strSQL = strSQL & " Sum(fEzPreis(4)*[PKW_Anzahl]) AS GesPreis, " & Me!Rch_ID & " AS Rch_ID, 0 AS Anz_MA"
    strSQL = strSQL & " FROM tbl_KD_Artikelbeschreibung, tbl_VA_Auftragstamm INNER JOIN tbl_MA_VA_Zuordnung"
    strSQL = strSQL & " ON tbl_VA_Auftragstamm.ID = tbl_MA_VA_Zuordnung.VA_ID"
    strSQL = strSQL & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID) = " & Me!VA_ID & "))"
    strSQL = strSQL & " GROUP BY tbl_MA_VA_Zuordnung.VA_ID, tbl_VA_Auftragstamm.Veranstalter_ID, tbl_MA_VA_Zuordnung.VADatum, tbl_MA_VA_Zuordnung.VAStart_ID, "
    strSQL = strSQL & " tbl_MA_VA_Zuordnung.MA_Start, fEzPreis(4), tbl_KD_Artikelbeschreibung.ID, tbl_KD_Artikelbeschreibung.Mengenheit,"
    strSQL = strSQL & " tbl_KD_Artikelbeschreibung.MwSt_Satz, tbl_KD_Artikelbeschreibung.Beschreibung, 0, 4, 0"
    strSQL = strSQL & " HAVING (((Sum(tbl_MA_VA_Zuordnung.PKW_Anzahl))>0) AND ((tbl_KD_Artikelbeschreibung.ID)=4));"
    CurrentDb.Execute (strSQL)
End If

f_tmp_position_fill

Textbau_Replace_Felder_Fuellen (Me!VorlageDokNr)

'fCreateRech_Neu

fbtnStunden

Me!sub_MA_VA_Zuordnung.Form.Requery
Me!sub_Rch_Pos_Auftrag.Form.Requery
Me!sub_tbltmp_Position.Form.Requery
Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery

Me!pgBerech.SetFocus

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
Me!btn_ber_best.Visible = True
Me!btnWord.Visible = True
'btnWord_Click

End Sub

Function f_tmp_position_fill()

Dim Ges_Alles As Currency
Dim Ges_PKW As Currency
Dim Ges_Sonst As Currency
Dim strSQL As String

CurrentDb.Execute ("Delete * FROM tbltmp_Position;")
DoEvents

strSQL = ""
strSQL = strSQL & " INSERT INTO tbltmp_Position ( Menge, EzPreis, ME, MwStSatz, Art_Beschreibung, Int_ArtNr, GesPreis, kun_ID, anz_MA, VorlageNr)"
strSQL = strSQL & " SELECT Sum(qry_Rch_Pos_Auftrag.Menge) AS SummevonMenge, qry_Rch_Pos_Auftrag.EzPreis, qry_Rch_Pos_Auftrag.Mengenheit, qry_Rch_Pos_Auftrag.MwSt,"
strSQL = strSQL & " qry_Rch_Pos_Auftrag.Beschreibung, qry_Rch_Pos_Auftrag.PreisArt_ID, Sum(qry_Rch_Pos_Auftrag.GesPreis) AS SummevonGesPreis,"
strSQL = strSQL & " qry_Rch_Pos_Auftrag.kun_ID, Sum(qry_Rch_Pos_Auftrag.Anz_MA) AS SummevonAnz_MA, " & Me!VorlageNr & " AS VorlageNr"
strSQL = strSQL & " FROM qry_Rch_Pos_Auftrag WHERE (((qry_Rch_Pos_Auftrag.VA_ID) = " & Me!VA_ID & "))"
strSQL = strSQL & " GROUP BY qry_Rch_Pos_Auftrag.EzPreis, qry_Rch_Pos_Auftrag.Mengenheit, qry_Rch_Pos_Auftrag.MwSt, qry_Rch_Pos_Auftrag.Beschreibung,"
strSQL = strSQL & " qry_Rch_Pos_Auftrag.PreisArt_ID , qry_Rch_Pos_Auftrag.kun_ID"
strSQL = strSQL & " ORDER BY qry_Rch_Pos_Auftrag.PreisArt_ID;"
CurrentDb.Execute (strSQL)
DoEvents

Ges_Alles = Nz(TSum("GesPreis", "tbl_Rch_Pos_Auftrag", "VA_ID = " & Me!VA_ID), 0)
Ges_PKW = Nz(TSum("GesPreis", "qry_Rch_Pos_Auftrag", "VA_ID = " & Me!VA_ID & " AND Preisart_ID = 4"), 0)
Ges_Sonst = Nz(TSum("GesPreis", "qry_Rch_Pos_Auftrag", "VA_ID = " & Me!VA_ID & " AND Preisart_ID > 4"), 0)
CurrentDb.Execute ("UPDATE tbl_Rch_Kopf SET tbl_Rch_Kopf.Zwi_Sum1 = " & str(Ges_Alles) & ", FahrtkostenNetto = " & str(Ges_PKW) & ", SonstigesNetto = " & str(Ges_Sonst) & " WHERE (((tbl_Rch_Kopf.ID)= " & Me!Rch_ID & "));")

Me!GesSumNetto = Ges_Alles

fPosNr_Update
DoEvents

End Function



Function fPosNr_Update()

Dim i As Long

i = Nz(DMin("ID", "tbltmp_Position"), 0)

CurrentDb.Execute ("UPDATE tbltmp_Position SET tbltmp_Position.PosNr = [ID] - " & i & " +1")

End Function

Private Sub btnWord_Click()

Dim strVorlageDoc As String
Dim strDateiname As String

Dim docnam As String
Dim docpath As String

Dim ustnam As String
Dim Ustwert As String
Dim i As Long

Dim Ueber_Pfad As String
Dim PDF_Datei As String

Dim strSQL As String

If Me!TaetigkeitArt = 1 Then

    f_tmp_position_fill

End If

fCreateRech_Neu

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))
Ueber_Pfad = Ueber_Pfad & "KD_" & Me!cboKunde & "\"
Call Path_erzeugen(Ueber_Pfad, False, True)
PDF_Datei = Ueber_Pfad & "Stundenliste_Rch_" & Me!VA_ID & ".pdf"
Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!VA_ID)

DoCmd.OutputTo acOutputReport, "rpt_Rch_Stundenliste", "PDF", PDF_Datei
DoEvents
Sleep 2000
DoEvents
    
'Me!str_Stundenliste = PDF_Datei
'Me!ist_Std_Liste = True

Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery
DoEvents

docpath = Get_Priv_Property("prp_CONSYS_GrundPfad") & TLookup("DocPfad", "_tblEigeneFirma_TB_Dok_Dateinamen", "ID = " & Me!VorlageDokNr)
docnam = TLookup("Docname", "_tblEigeneFirma_TB_Dok_Dateinamen", "ID = " & Me!VorlageDokNr)

If Right(docpath, 1) <> "\" Then docpath = docpath & "\"
strVorlageDoc = docpath & docnam

i = InStrRev(Me!strPDF_Rechnung, ".")
strDateiname = Left(Me!strPDF_Rechnung, i) & "docx"

Call WordReplace(strVorlageDoc, strDateiname)

Call Word_Insert_Table(strDateiname)

i = Nz(TLookup("ID", "tbltmp_Textbaustein_Ersetzung", "TB_Name_Kl = '[R_7MwSt]'"), 0)
If i > 0 Then
    Ustwert = TLookup("Ersetzung", "tbltmp_Textbaustein_Ersetzung", "ID = " & i)
    If Ustwert = "0,00 €" Then
        Call Ust_Loesch("Ust7", strDateiname)
    End If
End If

i = Nz(TLookup("ID", "tbltmp_Textbaustein_Ersetzung", "TB_Name_Kl = '[R_19MwSt]'"), 0)
If i > 0 Then
    Ustwert = TLookup("Ersetzung", "tbltmp_Textbaustein_Ersetzung", "ID = " & i)
    If Ustwert = "0,00 €" Then
        Call Ust_Loesch("Ust19", strDateiname)
    End If
End If

PDF_Print strDateiname
Me!ist_Rechnung = True
  
'Rechnung als "erzeugt" markieren
If Me!TaetigkeitArt = 1 Then
    CurrentDb.Execute ("qry_Rch_Update_Va_Status4")
    DoEvents
    If isFormLoad("frm_VA_Auftragstamm") Then
        Forms!frm_VA_Auftragstamm.Veranst_Status_ID.Requery
        Forms!frm_VA_Auftragstamm.zsub_lstAuftrag.Form.Recalc
        DoEvents
        Form_frm_VA_Auftragstamm.f_lst_Auft_Cl
    End If
End If

MsgBox "Rechnung erstellt"

If Me!IsWordAutoClose Then
    wd_Close_All
    Reset_Word_Objekt
Else
    Reset_Word_Objekt
End If
DoCmd.OpenForm "frm_va_auftragstamm"
End Sub



Private Function fCreateRech_Neu()

Dim kun_ID As Long
'Dim MA_ID As Long
Dim RG_Num As String
Dim Rch_Ext_ID As Long
Dim Rg_Dateiname As String
'
Dim Praefix As String
Dim Praefix1 As String

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim sufld As String
Dim Loginname As String
Dim qryName As String
Dim PKName As String
Dim fldName As String
Dim strWhere As String
Dim iSammel As Long
Dim VaDat_von As Date
Dim VaDat_bis As Date
Dim PDF_Datei As String
Dim strWD_Dateiname As String

Dim dtDate As Date

Dim VA_ID As Long

Dim i As Long
Dim j As Long
Dim Gesbt As Currency

Dim strSQL As String

Dim ZwiSum_Net As Currency
Dim MwSt19 As Currency
Dim MwSt7 As Currency
Dim MwStGes As Currency
Dim Gessum_Brut As Currency

Dim iA As Long
Dim AngBis As Date

Dim iZahlBed As Long
Dim ZahlBetrag_Netto As Currency
Dim Zahlung_Bis As Date
Dim iWert As Long

Dim Ueber_Pfad As String

If Nz(Me!cboKunde.Column(0), 0) = 0 Then
    MsgBox "Erst Kunden auswählen"
    Exit Function
End If

Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))
Ueber_Pfad = Ueber_Pfad & "KD_" & Me!cboKunde & "\"
Call Path_erzeugen(Ueber_Pfad, False, True)
'PDF_Datei = Ueber_Pfad & "Stundenliste_Rch_" & Me!VA_ID & ".pdf"
'Call Set_Priv_Property("prp_Report1_Auftrag_ID", Me!VA_ID)
'
'DoCmd.OutputTo acOutputReport, "rpt_Rch_Stundenliste", "PDF", PDF_Datei
'DoEvents
'Sleep 2000
'DoEvents
    
'Me!str_Stundenliste = PDF_Datei
'Me!ist_Std_Liste = True

VA_ID = 0
iSammel = 0

If Me!TaetigkeitArt = 2 Then ' Angebot
    i = 11
    iA = Nz(TLookup("Ang_Gueltig_Bis_AnzTage", "_tblEigeneFIrma", "FirmenID = 1"), 0)
    AngBis = Date + iA
End If


If Me!TaetigkeitArt = 1 Then ' Rechnung
    i = 14
    VA_ID = Me!VA_ID
'    Abschlussdatum statt date - 13.8.2015 - Abschlussdatum aus Auftrag, wenn Einzelrechnung
'    dtDate = Nz(TLookup("Abschlussdatum", "tbl_VA_Auftragstamm", "ID = " & VA_ID))
    VaDat_von = Nz(TLookup("Dat_VA_Von", "tbl_VA_Auftragstamm", "ID = " & VA_ID))
    VaDat_bis = Nz(TLookup("Dat_VA_Bis", "tbl_VA_Auftragstamm", "ID = " & VA_ID))
    Call Set_Priv_Property("prp_Akt_Rch_VA_ID", Me!VA_ID)

End If

'Bei Gutschrift ist nicht sicher, ob die Info im BE vorhanden ist
If Me!TaetigkeitArt = 3 Then ' Gutschrift
    i = Nz(TCount("ID", "_tblEigeneFirma_Word_Nummernkreise", "Praefix = 'Gut' AND FirmenID = 1"), 0)
    If i = 0 Then
        CurrentDb.Execute ("INSERT INTO _tblEigeneFirma_Word_Nummernkreise ( FirmenID, Praefix, Praefix1, NummernKreis, Bemerkungen ) SELECT 1 AS Ausdr1, 'Gut' AS Ausdr2, 'GS' AS Ausdr5, 0 AS Ausdr3, 'Gutschrift' AS Ausdr4 FROM _tblInternalSystemFE;")
        DoEvents
        i = Nz(TLookup("ID", "_tblEigeneFirma_Word_Nummernkreise", "Praefix = 'Gut' AND FirmenID = 1"), 0)
    Else
        i = Nz(TLookup("ID", "_tblEigeneFirma_Word_Nummernkreise", "Praefix = 'Gut' AND FirmenID = 1"), 0)
    End If
End If ' Rechnungs / Angebotsnummer erzeugen

RG_Num = Nz(TLookup("RchNr_Ext", "tbl_Rch_Kopf", "ID = " & Me!Rch_ID))

If Len(Trim(Nz(RG_Num))) > 0 Then
    Me!strPDF_Rechnung = Nz(TLookup("Dateiname", "tbl_Rch_Kopf", "ID = " & Me!Rch_ID))
Else
     Me!strPDF_Rechnung = ""
End If

If Not File_exist(Me!strPDF_Rechnung) Then
    Rch_Ext_ID = Update_Rch_Nr(i)
    
    Praefix = Nz(TLookup("Praefix", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & i))
    Praefix1 = Nz(TLookup("Praefix1", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & i))
    RG_Num = Praefix1 & Right("00000" & Rch_Ext_ID, 5)

    Rg_Dateiname = Praefix & "_" & RG_Num & "_" & Me!cboKunde.Column(0) & ".docx"
    strWD_Dateiname = Ueber_Pfad & Rg_Dateiname
    PDF_Datei = Praefix & "_" & RG_Num & "_" & Me!cboKunde.Column(0) & ".pdf"
    Me!strPDF_Rechnung = Ueber_Pfad & PDF_Datei
End If

Loginname = atCNames(1)

dtDate = Date

kun_ID = Me!cboKunde.Column(0)
Call Set_Priv_Property("prp_Akt_Rch_ID", Me!Rch_ID)

' Rechnungsdaten auslesen
ZwiSum_Net = Nz(TSum("GesPreis", "tbltmp_Position"), 0)
MwSt19 = Nz(TSum("GesPreis", "tbltmp_Position", "MwStSatz = 1") * TLookup("MwStSatz", "tbl_hlp_MwStSatz", "ID = 1"), 0)
MwSt7 = Nz(TSum("GesPreis", "tbltmp_Position", "MwStSatz = 2") * TLookup("MwStSatz", "tbl_hlp_MwStSatz", "ID = 2"), 0)
MwStGes = MwSt19 + MwSt7
Gessum_Brut = ZwiSum_Net + MwSt19 + MwSt7

iZahlBed = Nz(TLookup("kun_Zahlbed", "tbl_KD_Kundenstamm", "kun_Id = " & kun_ID), 0)
ZahlBetrag_Netto = Zahlbed_Zahlbar_BetragNetto(iZahlBed, Gessum_Brut)
Zahlung_Bis = Zahlbed_Zahlbar_Bis(iZahlBed)

' Rechnungskopf-Datei mit den aktuellen Werten updaten
'#####################################################

strSQL = ""
strSQL = strSQL & "UPDATE tbl_Rch_Kopf SET tbl_Rch_Kopf.IstSammelRch = " & iSammel
strSQL = strSQL & " , tbl_Rch_Kopf.Leist_Datum_von = " & SQLDatum(VaDat_von)
'############
'Kobd 13.08.2015
'If iSammel Then
If Len(Trim(Nz(VaDat_bis))) > 0 Then
    strSQL = strSQL & " , tbl_Rch_Kopf.Leist_Datum_Bis = " & SQLDatum(VaDat_bis)
End If
'#############
If Me!TaetigkeitArt = 2 Then ' Angebot
    strSQL = strSQL & " , tbl_Rch_Kopf.Ang_Gueltig_Bis = " & SQLDatum(AngBis)
End If

strSQL = strSQL & " , tbl_Rch_Kopf.RchNr_Ext = '" & RG_Num & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.Dateiname = '" & Me!strPDF_Rechnung & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.VA_ID = " & VA_ID

'dtdate statt date - 13.8.2015 - Abschlussdatum aus Auftrag, wenn Einzelrechnung
strSQL = strSQL & " , tbl_Rch_Kopf.RchDatum = " & SQLDatum(dtDate)
strSQL = strSQL & " , tbl_Rch_Kopf.Zwi_Sum1 = " & str(ZwiSum_Net)
strSQL = strSQL & " , tbl_Rch_Kopf.MwSt19_Sum1 = " & str(MwSt19)
strSQL = strSQL & " , tbl_Rch_Kopf.MwSt7_Sum1 = " & str(MwSt7)
strSQL = strSQL & " , tbl_Rch_Kopf.MwSt_Sum1 = " & str(MwStGes)
strSQL = strSQL & " , tbl_Rch_Kopf.Gesamtsumme1 = " & str(Gessum_Brut)
strSQL = strSQL & " , tbl_Rch_Kopf.ZahlBed_ID = " & iZahlBed
strSQL = strSQL & " , tbl_Rch_Kopf.ZahlBetrag_Netto1 = " & str(ZahlBetrag_Netto)
strSQL = strSQL & " , tbl_Rch_Kopf.Zahlung_Bis = " & SQLDatum(Zahlung_Bis)
strSQL = strSQL & " , tbl_Rch_Kopf.IstBezahlt = 0"
strSQL = strSQL & " , tbl_Rch_Kopf.Erst_von = '" & atCNames(1) & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.Erst_am = " & SQLDatum(Date)
strSQL = strSQL & " , tbl_Rch_Kopf.Aend_von = '" & atCNames(1) & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.Aend_am = " & SQLDatum(Date)
strSQL = strSQL & " WHERE (((tbl_Rch_Kopf.ID)= " & Me!Rch_ID & "));"
CurrentDb.Execute (strSQL)

DoEvents

'###################################################

'Früher erzeugte (vorhandene) Replace Tabelle mit den aktuellen Werten ersetzen
'##########################################################
Call fReplace_Table_Felder_Ersetzen(Me!Rch_ID, kun_ID, 0, VA_ID)

End Function



Function fRch_ID_fuell(iVA_ID As Long, Optional iTaetart As Long = 1) As Long

' _tblEigeneFirma_TB_Dok_Dateinamen
' iTaetart 1              2               3
' RchTyp = 4 - Rechnung   7 - angebot    12 - Gutschrift
' ID       14            18              24

Dim iRch_ID As Long
Dim strSQL As String
Dim iVorlageDokNr As Long
Dim iRchTyp As Long
Dim strAuftrag As String

strAuftrag = ""

If iTaetart = 1 Then
    strAuftrag = Nz(Me!cboAuftrag.Column(3))
    iVorlageDokNr = 14
    iRchTyp = 4
ElseIf iTaetart = 2 Then
    iVorlageDokNr = 18
    iRchTyp = 7
ElseIf iTaetart = 3 Then
    iVorlageDokNr = 24
    iRchTyp = 12
End If

'Nur bei eindeutiger VA_ID auf bestehende prüfen, sonst immer neu
If iVA_ID > 0 Then
    iRch_ID = Nz(TLookup("ID", "tbl_Rch_Kopf", "VA_ID = " & iVA_ID), 0)
    If iRch_ID > 0 Then
        fRch_ID_fuell = iRch_ID
        Exit Function
    End If
End If

strSQL = ""
strSQL = strSQL & "INSERT INTO tbl_Rch_Kopf ( VA_ID, kun_ID, Erst_am, Erst_von, VorlageDokNr, RchTyp, Auftrag )"
strSQL = strSQL & " SELECT " & iVA_ID & " AS Ausdr1, " & Me!cboKunde.Column(0) & " AS Ausdr2, Date() AS Ausdr3, atcnames(1) AS Ausdr4, " & iVorlageDokNr & " AS Ausdr5, " & iRchTyp & " AS Ausdr6, '" & strAuftrag & "' AS Ausdr7 FROM _tblInternalSystemFE;"
CurrentDb.Execute (strSQL)
iRch_ID = Nz(TMax("ID", "tbl_Rch_Kopf"), 0)

fRch_ID_fuell = iRch_ID

End Function

Private Sub btnBisWertFuell_Click()

CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_Ende = " & DateTimeForSQL(Me!Std_bis) & " WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & Me!VA_ID & ") AND ((Len(Trim(Nz([MA_Ende]))))=0));")
'DCurrentDb.Execute ("UPDATE tbl_VA_Start SET tbl_VA_Start.VA_Ende = " & DateTimeForSQL(Me!Std_bis) & " WHERE (((tbl_VA_Start.VA_ID)= " & Me!VA_ID & ") AND ((Len(Trim(Nz([MA_Ende]))))=0));")
DoEvents
Me!sub_MA_VA_Zuordnung.Form.Requery
DoEvents

End Sub

'Private Sub btnPfadsuche_Click()
'Dim s As String
'
's = Folder_Such("Folder für Speicherung der Excel-Aufträge")
'If Len(Trim(Nz(s))) > 0 Then
'    If Right(s, 1) <> "\" Then s = s & "\"
'    Me!strPfad = s
'    Call Set_Priv_Property("prp_XL_Exportpfad_Auftrag", s)
'    DoEvents
'End If
'
'End Sub

Private Sub cboKunde_AfterUpdate()
Dim strSQL As String


Me!RegAuftrag.Enabled = True
If Me!TaetigkeitArt = 1 Then
    
    If Me!cboKunde > 0 Then
        strSQL = ""
        strSQL = strSQL & "SELECT tbl_VA_Auftragstamm.ID, tbl_VA_Auftragstamm.Veranstalter_ID, "
        strSQL = strSQL & " Format([Dat_VA_Von], 'mm-dd-yy',2,2) & ' ' & Trim([Auftrag] & ' ' & Trim(Nz([Ort] & ' ' & [Objekt]))) & '.xlsm' AS Auftr,'"
        strSQL = strSQL & " [Dat_VA_Von] & ' - ' & [Auftrag] & ' ' & [Ort] & ' ' & [Objekt] AS AufObjOrt"
        strSQL = strSQL & " FROM tbl_VA_Auftragstamm WHERE (((tbl_VA_Auftragstamm.Veranstalter_ID) = ' & Me!cboKunde & ' ) And ((tbl_VA_Auftragstamm.Veranst_Status_ID) = 3))'"
        strSQL = strSQL & " ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von, [Dat_VA_Von] & ' ' & [Auftrag] & ' ' & [Ort] & ' ' & [Objekt];"
        
        Me!cboAuftrag.RowSource = strSQL
    End If
    
    FSetStdPreis (Me!cboKunde)
    CurrentDb.Execute ("UPDATE tbl_VA_Auftragstamm SET tbl_VA_Auftragstamm.Veranstalter_ID = " & Me!cboKunde & " WHERE (((tbl_VA_Auftragstamm.ID)= " & Me!VA_ID & "));")
    DoEvents
    Me!cboAuftrag.Enabled = True
    Me!cboAuftrag.Locked = False
    cboAuftrag_AfterUpdate
Else
    Me!Rch_ID = fRch_ID_fuell(0, Me!TaetigkeitArt)
    
    Textbau_Replace_Felder_Fuellen (Me!VorlageDokNr)

    'Früher erzeugte (vorhandene) Replace Tabelle mit den aktuellen Werten ersetzen
    '##########################################################
    Call fReplace_Table_Felder_Ersetzen(Me!Rch_ID, Me!cboKunde.Column(0), 0, 0)
    Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery

End If
End Sub

Function FSetStdPreis(KD_ID As Long)
Me!StdF1 = Nz(TLookup("StdPreis", "tbl_KD_Standardpreise", "kun_ID = " & KD_ID & " AND Preisart_ID = 1"), 0)
Me!StdF3 = Nz(TLookup("StdPreis", "tbl_KD_Standardpreise", "kun_ID = " & KD_ID & " AND Preisart_ID = 3"), 0)
Me!StdPKW = Nz(TLookup("StdPreis", "tbl_KD_Standardpreise", "kun_ID = " & KD_ID & " AND Preisart_ID = 4"), 0)
CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.PKW_Anzahl = 1 WHERE (((tbl_MA_VA_Zuordnung.VA_ID)= " & Me!VA_ID & ") AND ((Nz([PKW],0))>0) AND ((Nz([PKW_Anzahl],0))=0));")
DoEvents
Me!Anz_PKW = Nz(TSum("PKW_Anzahl", "tbl_MA_VA_Zuordnung", "VA_ID= " & Me!VA_ID), 0)
Me!SumPKW_MA = Nz(TSum("PKW", "tbl_MA_VA_Zuordnung", "VA_ID= " & Me!VA_ID), 0)
DoEvents
Me!sub_MA_VA_Zuordnung.Form.Requery
DoEvents
End Function

Private Sub Form_Load()
DoCmd.Maximize
End Sub

'Private Sub cboQuali_DblClick(Cancel As Integer)
'DoCmd.OpenForm "frm_Top_Einsatzart"
'End Sub

Private Sub Form_Open(Cancel As Integer)
'Me!strPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 9")
'If Not Dir_Exist(Nz(Me!strPfad)) Then Call Path_erzeugen(Me!strPfad, False, True)
TaetigkeitArt_AfterUpdate
btn_ber_best.Visible = False
btnRchWd_Open.Visible = False
End Sub

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
MA_Selektion_AfterUpdate
End Sub

Private Sub MA_Selektion_AfterUpdate()

Dim strSQL As String
Dim sto As String

sto = " Order by MAName"

strSQL = ""
If Me!MA_Selektion = 1 Then
    strSQL = "SELECT ID, MAName AS Name, ID as PersNr From tbltmp_MA_Verfueg_tmp WHERE IstAktiv = True"
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

Me!sub_MA_VA_Zuordnung.Form!cboMA_Ausw.RowSource = strSQL & sto

End Sub

Private Sub Std_bis_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!Std_bis.Text
        If Not IsNumeric(st) Then Exit Sub
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!Std_bis = uz
    End If

End Sub

Private Sub str_Stundenliste_DblClick(Cancel As Integer)
If Len(Trim(Nz(Me!str_Stundenliste))) > 0 Then
    Application.FollowHyperlink Me!str_Stundenliste
End If
End Sub

Private Sub strPDF_Einsatzliste_DblClick(Cancel As Integer)
If Len(Trim(Nz(Me!strPDF_Einsatzliste))) > 0 Then
    Application.FollowHyperlink Me!strPDF_Einsatzliste
End If
End Sub

Private Sub strPDF_Rechnung_DblClick(Cancel As Integer)
If Len(Trim(Nz(Me!strPDF_Rechnung.Text))) > 0 Then
    Application.FollowHyperlink Me!strPDF_Rechnung.Text
End If
End Sub


Public Function f_TaetArt_Upd()
TaetigkeitArt_AfterUpdate
End Function

Private Sub TaetigkeitArt_AfterUpdate()

CurrentDb.Execute ("DELETE * FROM tbltmp_Position")
CurrentDb.Execute ("DELETE * FROM tbltmp_Textbaustein_Ersetzung")
Me!cboKunde = Null

DoEvents

Me!sub_tbltmp_Position.Form.Requery
Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery
Me!Rch_ID = Null

DoEvents

Select Case Me!TaetigkeitArt
    Case 1
        Me!lbl_Daten.caption = "Rechnung"
        fSet_ctrl_Visible True
'        Me!pgStd.SetFocus
        Me!VorlageNr = 4
        Me!VorlageDokNr = 14
        Me!btnWord.Visible = False
        Me!IsWordAutoClose.Visible = False
        Me!IsWordAutoClose = True
    Case 2
        Me!RegAuftrag.Enabled = False
        Me!lbl_Daten.caption = "Angebot"
        fSet_ctrl_Visible False
        Me!VorlageNr = 7
        Me!VorlageDokNr = 18
        Me!cboKunde.Enabled = True
        Me!cboKunde.Locked = False
        Me!btnWord.Visible = True
        Me!IsWordAutoClose.Visible = True
        Me!IsWordAutoClose = True
    Case 3
        Me!RegAuftrag.Enabled = False
        Me!lbl_Daten.caption = "Gutschrift"
        fSet_ctrl_Visible False
        Me!VorlageNr = 12
        Me!VorlageDokNr = 24
        Me!cboKunde.Enabled = True
        Me!cboKunde.Locked = False
        Me!btnWord.Visible = True
        Me!IsWordAutoClose.Visible = True
        Me!IsWordAutoClose = True
        Me!btnBerList.Visible = False
        Me!Befehl88.Visible = False
        Me!btnRchWd_Open.Visible = False
        Me!IsWordAutoClose.Visible = False
        Me!btnSendenAn.Visible = False
        Me!btnWord.Visible = False
        Me!btn_PDFagain.Visible = False
        
        
End Select
DoEvents

Me!cboKunde.Enabled = True
Me!cboKunde.Locked = False

Me!cboKunde.SetFocus
Me!cboKunde.Dropdown

End Sub

Function fSet_ctrl_Visible(bv As Boolean)
 Dim ctl
 Me!TaetigkeitArt.SetFocus
 DoEvents
  For Each ctl In Me
    If ctl.TAG = "Rch" Then  ' acTextbox
        ctl.Visible = bv
    End If
  Next ctl

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
