VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_RechnungsStamm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnFIlterLoesch_Click()
'Me!Mahndok.ControlSource = ""
'Me!Mahndat.ControlSource = ""
'Me!MahnVon.ControlSource = ""
'Me!Mahnbetrag.ControlSource = ""
'Me!IstGemahnt.ControlSource = ""
'Me!Mahn_Bemerkungen.ControlSource = ""
'
Me!kun_firma.ControlSource = ""
Me!kun_BriefKopf.ControlSource = ""

Me!cboKunde = ""
Me!cboMahnstufe = ""

Me.recordSource = "tbl_Rch_Kopf"
Me.Requery
End Sub


Private Sub cboKunde_AfterUpdate()
Me.recordSource = "SELECT * FROM tbl_Rch_Kopf WHERE kun_ID = " & Me!cboKunde.Column(0)
Me.Requery
End Sub

Public Function fMahnsetz()
Dim iRch_KopfID As Long
Dim strSQL As String

'Me!Mahndok.ControlSource = "M" & i & "Mahndok"
'Me!Mahndat.ControlSource = "M" & i & "Mahndat"
'Me!MahnVon.ControlSource = "M" & i & "MahnVon"
'Me!Mahnbetrag.ControlSource = "M" & i & "Mahnbetrag"
'Me!IstGemahnt.ControlSource = "M" & i & "IstGemahnt"
'Me!Mahn_Bemerkungen.ControlSource = "M" & i & "Mahn_Bemerkungen"
'
Me!kun_firma.ControlSource = "kun_Firma"
Me!kun_BriefKopf.ControlSource = "kun_BriefKopf"
Me!lbl_Mahnstufe.caption = Me!cboMahnstufe.Column(1)
Me!MahnBetrag = Me!ZahlBetrag_Netto1
Me!Mahndat = Date
Me!MahnVon = atCNames(1)
Me!IstGemahnt = True

DoEvents

'Me.Requery

End Function

Private Sub cboMahnstufe_AfterUpdate()
Dim i As Long
i = Me!cboMahnstufe.Column(0)

Me.recordSource = "qry_Rch_Mahnstufe" & i
Me.Requery

fMahnsetz
End Sub


'Function fMahnen(iMahnstufe As Long, rch_ID As Long)

Private Sub btnMahnen_Click()

Dim i As Long
Dim ikun_ID As Long
Dim Mah_ID As Long
Dim Mah_Num As String
Dim Praefix As String
Dim Praefix1 As String
Dim Mah_Dateiname As String
Dim Mah_PDFDateiname As String
Dim iDokVorlage_ID As Long

Dim vorlPfad As String
Dim VorlNamen As String
Dim DokPfad As String

Dim strVorlage As String
Dim strDokument As String
Dim strPDFDokument As String

Dim iRch_KopfID As Long
Dim strSQL As String

ikun_ID = Nz(TLookup("kun_ID", "tbl_Rch_Kopf", "ID = " & Me!ID), 0)

If ikun_ID = 0 Then
    MsgBox "Keine Kundenrechnung - Keine Mahnung"
    Exit Sub
End If

i = 15  ' Mahnung

' Rechnungsnummer erzeugen
Mah_ID = Update_Rch_Nr(i)
Praefix = Nz(TLookup("Praefix", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & i))
Praefix1 = Nz(TLookup("Praefix1", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & i))
Mah_Num = Praefix1 & Right("00000" & Mah_ID, 5)
Mah_Dateiname = Praefix & "_" & Mah_Num & ".docx"
Mah_PDFDateiname = Praefix & "_" & Mah_Num & ".pdf"

vorlPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 5"))
DokPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))

If Right(vorlPfad, 1) <> "\" Then vorlPfad = vorlPfad & "\"
If Right(DokPfad, 1) <> "\" Then DokPfad = DokPfad & "\"

Select Case Me!cboMahnstufe.Column(0)
    Case 1
        iDokVorlage_ID = 19
    Case 2
        iDokVorlage_ID = 20
    Case 3
        iDokVorlage_ID = 21
    Case Else
End Select

VorlNamen = Nz(TLookup("Docname", "_tblEigeneFirma_TB_Dok_Dateinamen", "ID = " & iDokVorlage_ID))

strVorlage = vorlPfad & VorlNamen
DokPfad = DokPfad & "KD_" & ikun_ID & "\"
strDokument = DokPfad & Mah_Dateiname
strPDFDokument = DokPfad & Mah_PDFDateiname

iRch_KopfID = Me!ID

Me!Mahndok = strDokument

i = Me!cboMahnstufe.Column(0)

strSQL = ""
strSQL = strSQL & "UPDATE tbl_Rch_Kopf SET"
strSQL = strSQL & " tbl_Rch_Kopf.M" & i & "Mahndok = '" & Nz(Me!Mahndok) & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "Mahndat = " & SQLDatum(Me!Mahndat)
strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "MahnVon = '" & Nz(Me!MahnVon) & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "Mahnbetrag1 = " & str(Me!MahnBetrag)
strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "IstGemahnt1 = " & CLng(Me!IstGemahnt)
strSQL = strSQL & " , tbl_Rch_Kopf.M" & i & "Mahn_Bemerkungen = '" & Nz(Me!Mahn_Bemerkungen) & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.Aend_von = '" & atCNames(1) & "'"
strSQL = strSQL & " , tbl_Rch_Kopf.Aend_am = " & SQLDatum(Date)
strSQL = strSQL & " WHERE ((tbl_Rch_Kopf.ID)= " & iRch_KopfID & ");"
CurrentDb.Execute (strSQL)

DoEvents

Call Textbau_Replace_Felder_Fuellen(iDokVorlage_ID)

Call fReplace_Table_Felder_Ersetzen(Me!ID, ikun_ID, 0, Me!VA_ID)

DoEvents

Call WordReplace(strVorlage, strDokument)

PDF_Print strDokument

'MsgBox "Rechnung / Angebot erzeugt"

'If Me!IsWordAutoClose Then
'    wd_Close_All
'    Reset_Word_Objekt
'Else
    Reset_Word_Objekt
'End If


End Sub


Private Sub cboRchID_AfterUpdate()
Me.Recordset.FindFirst "ID = " & Me!cboRchID
End Sub

Private Sub Dateiname_DblClick(Cancel As Integer)

Dim Datei As String

On Error GoTo Err


    Application.FollowHyperlink Me!Dateiname
    
Ende:
    Exit Sub
Err:
    Datei = Dateiauswahl("Rechnung auswählen", "*.pdf,*.doc,*.docx", CONSYS)
    If Datei <> "" Then Me.Dateiname = Datei
    Resume Ende
End Sub


Private Sub Form_Current()
If Me!reg_Rech.Pages(Me!reg_Rech).Name = "pgMahnen" And Nz(Me!cboMahnstufe.Column(0), 0) > 0 Then
    Call fMahnsetz
End If
End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub istRechnung_AfterUpdate()
If Me!istRechnung Then
    Me!istRechnung.caption = "Rechnung"
    Me.recordSource = "qry_tbl_Rch_Kopf"
    Me.Requery

Else
    Me!istRechnung.caption = "Angebot"
    Me.recordSource = "qry_tbl_Rch_Kopf_Ang"
    Me.Requery
End If

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


