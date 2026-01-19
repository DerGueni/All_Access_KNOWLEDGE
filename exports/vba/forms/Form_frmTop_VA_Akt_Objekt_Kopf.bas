VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_VA_Akt_Objekt_Kopf"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit



Public Function VAOpen(iVA_ID As Long, iObj_ID As Long, iVADatum_ID As Long, dtVADatum As Date)
Dim strSQL As String
Dim i As Long
Dim strSuch As String
Dim strSuch1 As String

Dim iVA_Akt_Objekt_Kopf_ID As Long

strSuch = "VA_ID = " & iVA_ID & " AND OB_Objekt_Kopf_ID = " & iObj_ID
iVA_Akt_Objekt_Kopf_ID = Nz(TLookup("ID", "tbl_VA_Akt_Objekt_Kopf", strSuch), 0)

If iVA_Akt_Objekt_Kopf_ID = 0 Then
    
    strSQL = ""

    strSQL = strSQL & "INSERT INTO tbl_VA_Akt_Objekt_Kopf ( OB_Objekt_Kopf_ID, VA_ID, VADatum, VADatum_ID )"
    strSQL = strSQL & " SELECT " & iObj_ID & " AS Ausdr4, " & iVA_ID & " AS Ausdr1, " & SQLDatum(dtVADatum) & " AS Ausdr2, " & iVADatum_ID & " AS Ausdr3"
    strSQL = strSQL & " FROM _tblInternalSystemFE;"

    CurrentDb.Execute (strSQL)
    DoEvents
End If

iVA_Akt_Objekt_Kopf_ID = Nz(TLookup("ID", "tbl_VA_Akt_Objekt_Kopf", strSuch), 0)

VAOpen_ID iVA_Akt_Objekt_Kopf_ID

End Function
Public Function VAOpen_ID(iVA_Akt_Objekt_Kopf_ID As Long)

Dim strSQL As String
Dim i As Long
Dim sd As Single
Dim strSuch As String
Dim strSuch1 As String
Dim iVA_ID As Long, iObj_ID As Long, iVADatum_ID As Long

Me.Recordset.FindFirst "ID = " & iVA_Akt_Objekt_Kopf_ID
DoEvents

iObj_ID = Me!Obj_ID.Column(0)
iVA_ID = Me!VA_ID.Column(0)
iVADatum_ID = Me!cboVADatum.Column(0)

strSuch = "VA_Akt_Objekt_Kopf_ID = " & iVA_Akt_Objekt_Kopf_ID
i = Nz(TCount("*", "tbl_VA_Akt_Objekt_Pos", strSuch), 0)

If i = 0 Then
    strSQL = ""
    
    strSQL = strSQL & "INSERT INTO tbl_VA_Akt_Objekt_Pos ( OB_Objekt_Pos_ID, OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Zusatztext2, Geschlecht, Anzahl,"
    strSQL = strSQL & " Rel_Beginn, Rel_Ende, VA_Akt_Objekt_Kopf_ID )"
    strSQL = strSQL & " SELECT tbl_OB_Objekt_Positionen.ID, tbl_OB_Objekt_Positionen.OB_Objekt_Kopf_ID, tbl_OB_Objekt_Positionen.Sort, tbl_OB_Objekt_Positionen.Gruppe,"
    strSQL = strSQL & " tbl_OB_Objekt_Positionen.Zusatztext, tbl_OB_Objekt_Positionen.Zusatztext2, tbl_OB_Objekt_Positionen.Geschlecht,"
    strSQL = strSQL & " tbl_OB_Objekt_Positionen.Anzahl, tbl_OB_Objekt_Positionen.Rel_Beginn, tbl_OB_Objekt_Positionen.Rel_Ende, " & iVA_Akt_Objekt_Kopf_ID & " AS Ausdr1"
    strSQL = strSQL & " FROM tbl_OB_Objekt_Positionen WHERE (((tbl_OB_Objekt_Positionen.OB_Objekt_Kopf_ID)= " & iObj_ID & "));"

    CurrentDb.Execute (strSQL)
    DoEvents
End If

Me!sub_VA_Start.Form.Requery
i = Nz(TLookup("id", "tbl_VA_Start", "va_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID), 0)
If i > 0 Then
    Me!VA_Start_Abs = TLookup("VA_Start", "tbl_VA_Start", "ID = " & i)
    Me!VA_Ende_Abs = TLookup("VA_Ende", "tbl_VA_Start", "ID = " & i)
    If Len(Trim(Nz(Me!VA_Ende_Abs))) = 0 Then
        sd = Get_Priv_Property("prp_VA_Start_AutoLaenge") * 60
        Me!VA_Ende_Abs = DateAdd("n", sd, Me!VA_Start_Abs)
    End If
End If

DoEvents
strSuch = "VA_Akt_Objekt_Kopf_ID = " & iVA_Akt_Objekt_Kopf_ID
Me!AnzMA_Obj = Nz(TSum("Anzahl", "tbl_VA_Akt_Objekt_Pos", strSuch), 0)

strSuch1 = "VA_ID = " & iVA_ID & " AND VADatum_ID = " & iVADatum_ID
Me!AnzMA_VA = Nz(TSum("MA_Anzahl", "tbl_VA_Start", strSuch1), 0)

Me!sub_VA_Akt_Objekt_Pos.Form.Requery

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents
End Function

Private Sub btn_OB_Bearb_Click()
Dim i As Long
i = Me!ID
DoCmd.OpenForm "frm_OB_Objekt", , , "ID = " & Me!Obj_ID, , , i
DoCmd.Close acForm, "frmTop_VA_Akt_Objekt_Kopf", acSaveNo
End Sub

Private Sub btn_VA_Akt_OB_Pos_Neu_Click()

Dim strSuch As String
Dim i As Long
Dim strSQL As String

CurrentDb.Execute ("DELETE * FROM tbl_VA_Akt_Objekt_Pos WHERE VA_Akt_Objekt_Kopf_ID = " & Me!ID)
DoEvents

strSuch = "VA_Akt_Objekt_Kopf_ID = " & Me!ID
i = Nz(TCount("*", "tbl_VA_Akt_Objekt_Pos", strSuch), 0)

If i = 0 Then
    strSQL = ""

    strSQL = strSQL & "INSERT INTO tbl_VA_Akt_Objekt_Pos ( OB_Objekt_Pos_ID, OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Zusatztext2, Geschlecht, Anzahl,"
    strSQL = strSQL & " Rel_Beginn, Rel_Ende, VA_Akt_Objekt_Kopf_ID )"
    strSQL = strSQL & " SELECT tbl_OB_Objekt_Positionen.ID, tbl_OB_Objekt_Positionen.OB_Objekt_Kopf_ID, tbl_OB_Objekt_Positionen.Sort, tbl_OB_Objekt_Positionen.Gruppe,"
    strSQL = strSQL & " tbl_OB_Objekt_Positionen.Zusatztext, tbl_OB_Objekt_Positionen.Zusatztext2, tbl_OB_Objekt_Positionen.Geschlecht,"
    strSQL = strSQL & " tbl_OB_Objekt_Positionen.Anzahl, tbl_OB_Objekt_Positionen.Rel_Beginn, tbl_OB_Objekt_Positionen.Rel_Ende, " & Me!ID & " AS Ausdr1"
    strSQL = strSQL & " FROM tbl_OB_Objekt_Positionen WHERE (((tbl_OB_Objekt_Positionen.OB_Objekt_Kopf_ID)= " & Me!Obj_ID & "));"

    CurrentDb.Execute (strSQL)
    DoEvents
End If

fNeu_Pos

Me!sub_VA_Akt_Objekt_Pos.Form.Requery

strSuch = "VA_Akt_Objekt_Kopf_ID = " & Me!ID
i = Nz(TCount("*", "tbl_VA_Akt_Objekt_Pos", strSuch), 0)

End Sub

Private Sub btn_VA_Objekt_Akt_Teil2_Click()
Dim i As Long
Dim x As Variant

If Len(Trim(Nz(Me!ID))) = 0 Then Exit Sub

i = Me!ID
If Nz(TCount("*", "qry_VA_Akt_Pos_NULL"), 0) > 0 Then
'    MsgBox "Bitte erst die absoluten Zeiten zuordnen"
'    exit Sub
    btnAbsTime_Click
    DoEvents
End If

If Me!AnzMA_VA = Me!AnzMA_Obj Then
    DoCmd.OpenForm "frm_N_MA_VA_Positionszuordnung"
    Form_frm_N_MA_VA_Positionszuordnung.VAOpen (i)
    DoCmd.Close acForm, "frmTop_VA_Akt_Objekt_Kopf", acSaveNo
    DoEvents
Else
    ' Hinweis deaktiviert: MsgBox "Anzahl Positionen lt. Auftrag und Anzahl Positionen lt. Positionsliste stimmen nicht überein, bitte überprüfen!"
End If
End Sub

Private Sub btnAbsTime_Click()

Dim dt1 As Date
Dim dt2 As Date
Dim strSQL As String

If Len(Trim(Nz(Me!VA_Start_Abs))) > 0 And Len(Trim(Nz(Me!VA_Ende_Abs))) > 0 Then

    dt1 = Me!VA_Start_Abs
    dt2 = Me!VA_Ende_Abs
    
    strSQL = ""
    strSQL = strSQL & "Update tbl_VA_Akt_Objekt_Pos"
    strSQL = strSQL & " Set tbl_VA_Akt_Objekt_Pos.Abs_Beginn = date_Umsetz(" & DateTimeForSQL(Me!VA_Start_Abs) & ", [Rel_Beginn]), "
    strSQL = strSQL & " tbl_VA_Akt_Objekt_Pos.Abs_Ende = date_Umsetz(" & DateTimeForSQL(Me!VA_Ende_Abs) & ", [Rel_Ende])"
    strSQL = strSQL & " WHERE (((tbl_VA_Akt_Objekt_Pos.VA_Akt_Objekt_Kopf_ID)= " & Me!ID & "));"
    CurrentDb.Execute (strSQL)
    DoEvents
    
    Me!sub_VA_Akt_Objekt_Pos.Form.Requery
    
    fNeu_Pos

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



Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Obj_ID_AfterUpdate()
New_Obj
End Sub

Private Sub sub_VA_Akt_Objekt_Pos_Exit(Cancel As Integer)
Form_Current
End Sub

Private Sub VA_Ende_Abs_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!VA_Ende_Abs.Text
        If Not IsNumeric(st) Then Exit Sub
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!VA_Ende_Abs = uz
        Me!VA_Ende_Abs.SetFocus
    End If

End Sub

Private Sub VA_ID_AfterUpdate()
New_Obj
End Sub

Private Sub cboVADatum_AfterUpdate()
New_Obj
End Sub

Private Sub Form_Current()

Dim strSuch As String
Dim strSuch1 As String

strSuch = "VA_Akt_Objekt_Kopf_ID = " & Nz(Me!ID, 0)
Me!AnzMA_Obj = Nz(TSum("Anzahl", "tbl_VA_Akt_Objekt_Pos", strSuch), 0)

strSuch1 = "VA_ID = " & Nz(Me!VA_ID, 0) & " AND VADatum_ID = " & Nz(Me!cboVADatum.Column(0), 0)
Me!AnzMA_VA = Nz(TSum("MA_Anzahl", "tbl_VA_Start", strSuch1), 0)

End Sub

Function New_Obj()

If Len(Trim(Nz(Me!VA_ID))) > 0 And Len(Trim(Nz(Me!Obj_ID))) > 0 And Len(Trim(Nz(Me!cboVADatum.Column(0)))) > 0 Then
    Call VAOpen(Nz(Me!VA_ID, 0), Nz(Me!Obj_ID, 0), Nz(Me!cboVADatum.Column(0), 0), Nz(Me!cboVADatum.Column(1)))
End If
End Function

Private Sub VA_Start_Abs_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!VA_Start_Abs.Text
        If Not IsNumeric(st) Then Exit Sub
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!VA_Start_Abs = uz
        Me!VA_Ende_Abs.SetFocus
    End If

End Sub
