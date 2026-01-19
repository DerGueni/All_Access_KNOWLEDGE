VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Menuefuehrung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

Private Sub btnClose_Click()
If vbOK = MsgBox("Access benden", vbQuestion + vbOKCancel, "Access beenden") Then
    DoCmd.Quit acQuitSaveAll
End If
End Sub




Private Sub Befehl92_Click()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgPlan.SetFocus
End Sub

Private Sub btn_Auftragsuebersicht2_Click()
DoCmd.OpenReport "rpt_auftragsuebersicht", acPreview
End Sub

Private Sub btn_emailupdate_Click()
'Email-Antworten Synchronisieren
'MsgBox "Synchronisieren: " & synchronisieren

End Sub


Private Sub btn_MA_Monatsstunden_Click()
    DoCmd.OpenForm "zfrm_MA_Stunden_Lexware"
End Sub


Private Sub btn_Stundenuebersicht_Click()
DoCmd.OpenForm "frm_stundenuebersicht"

End Sub

Private Sub btn_Angebot_Click()
DoCmd.OpenForm "frmTop_Rch_Berechnungsliste"
Forms!frmtop_rch_berechnungsliste!TaetigkeitArt = 2
Form_frmTop_Rch_Berechnungsliste.f_TaetArt_Upd

End Sub

Private Sub btn_Abwesenheitsuebersicht_Click()
DoCmd.OpenForm "frmtop_ma_abwesenheitsplanung"
End Sub

Private Sub btn_Auftragsuebersicht1_Click()
DoCmd.OpenForm "frm_auftragsuebersicht_neu"
End Sub

Private Sub btn_Auftragsverwaltung_Click()
DoCmd.OpenForm "frm_VA_Auftragstamm"
End Sub

Private Sub btn_Datenbank_wechseln_Click()
DatenMDBWechselAcc
End Sub

Private Sub btn_Dienstausweis_Click()
DoCmd.OpenForm "frm_Ausweis_Create"
End Sub

Private Sub btn_Dienstplanuebersicht_Click()
DoCmd.OpenForm "frm_DP_Dienstplan_MA"
End Sub

Private Sub btn_Einsatzuebersicht_Click()
'DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
'Forms!frm_MA_Mitarbeiterstamm!pgAuftrUeb.SetFocus

   Call Shell("explorer.exe """ & PfadZK & """", vbNormalFocus)
   
End Sub

Private Sub btn_Kundenverwaltung_Click()
DoCmd.OpenForm "frm_KD_Kundenstamm"
End Sub

Private Sub btn_Menue2_Click()
DoCmd.OpenForm "frm_menuefuehrung1", , , , , acDialog
End Sub



Private Sub Btn_Mitabeiterverwaltung_Click()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"

End Sub

Private Sub btn_Mitarbeiterauswahl_Click()
DoCmd.OpenForm "frm_MA_VA_Schnellauswahl"
End Sub

Private Sub btn_Monatsplan_Hirsch_Click()
DoCmd.OpenReport "rpt_einsatzplan_hirsch", acViewPreview
End Sub

Private Sub btn_Monatsplan_Terminal90_Click()
DoCmd.OpenForm "frm_einsatzplan_terminal_91"
End Sub

Private Sub btn_Neue_Rechnung_Click()
DoCmd.OpenForm "frmTop_Rch_Berechnungsliste"
End Sub

Private Sub btn_Objektverwaltung_Click()
DoCmd.OpenForm "frm_OB_Objekt"
End Sub

Private Sub Btn_planungsuebersicht_Click()
DoCmd.OpenForm "frm_DP_Dienstplan_Objekt"

End Sub

Private Sub Btn_Positionsliste_Click()
DoCmd.OpenForm "frm_N_MA_VA_Positionszuordnung"
End Sub

Private Sub btn_Rechnungsarchiv_Click()
DoCmd.OpenForm "frmTop_RechnungsStamm"
End Sub

Private Sub btn_Systeminfo_Click()
DoCmd.OpenForm "_frmHlp_SysInfo"
End Sub

Private Sub btn_tagesuebersicht_Click()
DoCmd.OpenForm "frm_UE_Uebersicht"
End Sub

Private Sub btn_Umplanung_Click()
DoCmd.OpenForm "frm_MA_Maintainance"
End Sub

Private Sub btn_tbd_Click()
DoCmd.OpenForm "frmOff_Outlook_aufrufen"
End Sub

Private Sub btn_Verrechnungss‰tze_Click()
    'DoCmd.OpenForm "zfrm_KD_Kundenpreise"
    DoCmd.OpenForm "frm_Kundenpreise_gueni"
End Sub

Private Sub Btn_Zeitkonten_Click()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgMonat.SetFocus
End Sub




Private Sub btnSubRech_Click()

Dim frm As String

    frm = "frm_MA_Mitarbeiterstamm"

    DoCmd.OpenForm frm
    
    Forms(frm).Controls("NurAktiveMA") = 4
    
    Call Forms(frm).NurAktiveMA_AfterUpdate
    
    Forms(frm).Controls("reg_MA") = 12


''Auftragsliste exportieren
'Dim filename As String
'
'On Error Resume Next
'
'    Kill PfadTemp & "Auftragsliste*.xlsx"
'
'    filename = PfadTemp & "Auftragsliste_" & Left(Now(), 10) & ".xlsx"
'
'    DoCmd.OutputTo acOutputQuery, "qry_lst_Row_Auftrag_3", acFormatXLSX, filename, Autostart:=True
    

End Sub

'Zeitkonten
Private Sub btnZeitkonten_Click()

    DoCmd.OpenForm "zfrm_MA_ZK_top", acNormal
    DoCmd.Maximize
    
End Sub


Private Sub Form_Load()
    
Dim iMenueNr_Vgl As Long
Dim iMenueNr As Long
Dim i As Long
Dim strFkt As String
Dim strMakro As String
'PosWiederherstellen Me

'Schlieﬂformular im Hintergrund
If Not fctIsFormOpen("zfrm_Close") Then
    DoCmd.OpenForm "zfrm_Close", acNormal, "", "", , acHidden
End If

'SELECT * FROM tbl_Menuefuehrung_Neu order by MenueNr, SortNr
Set DAOARRAY1 = Nothing
DoEvents
recsetSQL1 = "SELECT * FROM tbl_Menuefuehrung_Neu order by MenueNr, SortNr"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If Not ArrFill_DAO_OK1 Then
    DoCmd.Close acForm, Me.Name, acSaveNo
    Exit Sub
End If
DoEvents
    
End Sub

Public Function call_Menu(iMenu As Long)
Dim i As Long

'i = Forms!frm_Menuefuehrung("cboF" & iMenu).Column(0)
i = Me("cboF" & iMenu).Column(0)

Call getMenu(i)
End Function

Function getMenu(i As Long)
Dim bLoesch As Boolean

'Neu - Doppelklick nach Fehler funktioniert nicht - Array immer neu f¸llen
Form_Load

For iZl = 0 To iZLMax1
    If DAOARRAY1(0, iZl) = i Then Exit For
Next iZl
bLoesch = CLng(DAOARRAY1(7, iZl))
If bLoesch = True Then
    CloseAllForms_Neu
    DoCmd.OpenForm "__frmHlp_Uebersicht"
    DoEvents
End If
If Len(Trim(Nz(DAOARRAY1(3, iZl)))) > 0 Then
    Eval (DAOARRAY1(3, iZl))
ElseIf Len(Trim(Nz(DAOARRAY1(4, iZl)))) > 0 Then
    Eval (DAOARRAY1(4, iZl))
End If
End Function


Function CloseAllForms_Neu()
' Schlieﬂen aller Forms
' aus der Newsgroup

Dim frm As Form
Dim FormNummer, i As Integer
Dim Ausnahme As String

FormNummer = 0
i = 0
Ausnahme = "frm_Menuefuehrung"

While Forms.Count > 1
    i = i + 1
    Set frm = Forms(FormNummer)
    If frm.formName = Ausnahme Then
        FormNummer = 1
    Else
        If frm.Modal Then frm.Modal = False  '<<<added
        If frm.PopUp Then frm.PopUp = False  '<<<added
        DoCmd.Close acForm, frm.Name, acSaveNo
    End If
Wend

End Function


Private Sub Monatsplan_Green_Goose_Click()
DoCmd.OpenForm "frm_einsatzplan_green_goose2"
End Sub



Private Sub Offene_Mail_Anfragen_Click()

'DoCmd.OpenQuery "qry_MA_Offene_Anfragen"
DoCmd.OpenForm "frm_MA_Offene_anfragen", acViewNormal

End Sub
