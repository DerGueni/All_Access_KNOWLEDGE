VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_Textbaustein_Brief"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim vorlPfad As String
Dim VorlNamen As String
Dim DokPfad As String

Dim strVorlage As String
Dim strDokument As String
Dim strPDFDokument As String


Private Sub btnFelderErsetzen_Click()

If Len(Trim(Nz(Me!cboEmpf1.Column(0)))) > 0 And Len(Trim(Nz(Me!strTextvorlage))) > 0 Then
    Me!strDokname = DokPfad
    If Me!EmpfaengerArt = 1 Then '  Pro Kunde eigenen Subdirectory Path erzeugen
        Me!strDokPfad = Me!strDokPfad & "KD_" & Me!cboEmpf1.Column(0) & "\"
        Call Path_erzeugen(Me!strDokPfad, False, True)
    End If
    If Me!EmpfaengerArt = 2 Then '  Pro Mitarbeiter eigenen Subdirectory Path erzeugen
        Me!strDokPfad = Me!strDokPfad & "M_" & Me!cboEmpf1.Column(0) & "\"
        Call Path_erzeugen(Me!strDokPfad, False, True)
    End If
    
    
    Me!strDokname = Me!strTextvorlage.Column(3)
    
    Call Textbau_Replace_Felder_Fuellen(Me!strTextvorlage.Column(0))
    
    If Me!EmpfaengerArt = 1 Then
        Call fReplace_Table_Felder_Ersetzen(0, Me!cboEmpf1.Column(0), 0, 0)
    Else
        Call fReplace_Table_Felder_Ersetzen(0, 0, Me!cboEmpf1.Column(0), 0)
    End If
    
    Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery
Else
    MsgBox "Kunde / Mitarbeiter und oder Vorlage auswählen"
End If

End Sub

Private Sub btnNeuVorlage_Click()
DoCmd.OpenForm "frmTop_Neue_Vorlagen"
End Sub

Private Sub btnWord_Click()
strDokument = Me!strDokPfad & Me!strDokname

Call WordReplace(strVorlage, strDokument)
PDF_Print strDokument
Reset_Word_Objekt

Form_Open False

End Sub


Private Sub EmpfaengerArt_AfterUpdate()

Dim iDokVorlage_ID As Long

Dim iRch_KopfID As Long
Dim strSQL As String

If Me!EmpfaengerArt = 1 Then
    Me!lbl_Empf1.caption = "Kunde"
    Me!strTextvorlage.RowSource = "SELECT ID, DocTyp, DocPfad, Docname From _tblEigeneFirma_TB_Dok_Dateinamen Where Doctyp = 2"
    Me!strTextvorlage.Requery
    Me!cboEmpf1.RowSource = "SELECT kun_ID, kun_Firma From tbl_KD_Kundenstamm Order by kun_Firma"
    Me!cboEmpf1.Requery
'    Call fReplace_Table_Felder_Ersetzen(0, Me!cboEmpf1.Column(0), 0, 0)

    DokPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"))

Else
    Me!lbl_Empf1.caption = "Mitarbeiter"
    Me!strTextvorlage.RowSource = "SELECT ID, DocTyp, DocPfad, Docname From _tblEigeneFirma_TB_Dok_Dateinamen Where Doctyp = 1"
    Me!strTextvorlage.Requery
    Me!cboEmpf1.RowSource = "SELECT ID, [Nachname] & ', ' & [Vorname] as GesName From tbl_MA_Mitarbeiterstamm Order by Nachname, Vorname"
    Me!cboEmpf1.Requery
'    Call fReplace_Table_Felder_Ersetzen(0, 0, Me!cboEmpf1.Column(0), 0)

    DokPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 1"))

End If

Me!strDokPfad = DokPfad

End Sub

Private Sub Form_Open(Cancel As Integer)

Me!strTextvorlage = ""
Me!cboEmpf1 = ""
Me!strDokPfad = ""
Me!strDokname = ""

EmpfaengerArt_AfterUpdate
CurrentDb.Execute ("DELETE * FROM tbltmp_Textbaustein_Ersetzung")
Me!sub_tbltmp_Textbaustein_Ersetzung.Form.Requery
DoEvents

End Sub

Private Sub strTextvorlage_AfterUpdate()

    vorlPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Me!strTextvorlage.Column(2)
    strVorlage = vorlPfad & Me!strTextvorlage.Column(3)

'    Call Textbau_Replace_Felder_Fuellen(Me!strTextvorlage.Column(0))

End Sub


'Call Textbau_Replace_Felder_Fuellen(iDokVorlage_ID)

'Call fReplace_Table_Felder_Ersetzen(Me!ID, ikun_ID, 0, Me!VA_ID)

'    DoEvents
'
'    Call WordReplace(strVorlage, strDokument)
'
'    PDF_Print strDokument
'
'    'MsgBox "Rechnung / Angebot erzeugt"
'
'    'If Me!IsWordAutoClose Then
'    '    wd_Close_All
'    '    Reset_Word_Objekt
'    'Else
'        Reset_Word_Objekt
'    'End If
