VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_MA_VA_Zuordnung_MARechnung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub cboMA_Ausw_AfterUpdate()
Me!MA_ID = Me!cboMA_Ausw
Start_End_Aend
    
Call fTag_Schicht_Update(Me!VADatum_ID, Me!VAStart_ID)

'DoCmd.Close acForm, Me.Parent.Name, acSaveNo
'Form_frm_DP_Dienstplan_Objekt.btnSta

End Sub


Private Sub cboMA_Ausw_Click()
On Error Resume Next
Me!cboMA_Ausw.SetFocus
If Me.Parent!Veranst_Status_ID < 3 Then
    Me!cboMA_Ausw.Dropdown
End If
End Sub


Private Sub Form_AfterUpdate()

Dim i As Long, j As Long, k As Long, m As Boolean


i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "PKW > 0 AND VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!VADatum_ID), 0)
j = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID > 0 AND VA_ID = " & Me!VA_ID & " AND VADatum_ID = " & Me!VADatum_ID), 0)
k = Nz(TLookup("TVA_Soll", "tbl_VA_AnzTage", "ID = " & Me!VADatum_ID), 0)
m = Not (k > 0 And k <= j)

CurrentDb.Execute ("UPDATE tbl_VA_AnzTage SET TVA_Ist = " & j & ", TVA_Offen = " & CLng(m) & ", tbl_VA_AnzTage.PKW_Anzahl = " & i & " WHERE (tbl_VA_AnzTage.ID = " & Me!VADatum_ID & ");")

Call VA_AnzTage_Upd(Me!VA_ID, Me!VADatum_ID)

'If i > 0 Then Me.Parent!PKW_Anzahl.Visible = True
'Me.Parent!PKW_Anzahl.Requery

End Sub

Private Sub Form_Current()
Dim strSQL As String
Dim iVerfueg As Long
On Error Resume Next

Me!VADatum_ID.RowSource = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID) = " & Me!VA_ID & "));"
Me!VAStart_ID.RowSource = "SELECT tbl_VA_Start.ID, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende FROM tbl_VA_Start WHERE (((tbl_VA_Start.VA_ID) = " & Me!VA_ID & ")) ORDER BY VA_Start;"

CurrentDb.Execute ("UPDATE tbltmp_MA_Verfueg_tmp SET tbltmp_MA_Verfueg_tmp.IstVerfuegbar = -1;")
Call fCreateQuery_Verplant(Me.VA_ID, Me!MVA_Start, Me!MVA_Ende)
DoEvents
iVerfueg = Nz(TCount("*", "qry_VV_tmp_belegt"), 0)
DoEvents
CurrentDb.Execute ("DELETE * FROM tbltmp_VV_Belegt")
If iVerfueg > 0 Then
    CurrentDb.Execute ("qry_VV_tmp_belegt_ADD")
    CurrentDb.Execute ("qry_VV_Upd_Verfueg_All")
    CurrentDb.Execute ("UPDATE tbltmp_MA_Verfueg_tmp SET tbltmp_MA_Verfueg_tmp.IstVerfuegbar = -1 Where IstSubunternehmer = True;")
End If
Me.Parent.fMA_Selektion_AfterUpdate
'Me!cboMA_Ausw.Requery

End Sub




Private Sub MA_Ende_AfterUpdate()
'If keycode = 13 Then
'Me.Recordset.MoveNext
Start_End_Aend
End Sub



Private Sub MA_ID_AfterUpdate()
Start_End_Aend
Call fTag_Schicht_Update(Me!VADatum_ID, Me!VAStart_ID)
End Sub

Private Sub MA_Start_AfterUpdate()
Start_End_Aend
End Sub

Function Start_End_Aend()

Dim bNSG As Boolean
Dim tempbis As Date

Me!MVA_Start = Startzeit_G(Me!VADatum, Me!MA_Start)
If Len(Trim(Nz(Me!MA_Ende))) = 0 Then
    tempbis = DateAdd("h", CDbl(Get_Priv_Property("prp_VA_Start_AutoLaenge")), Me!MVA_Start)
Else
    tempbis = Me!MA_Ende
End If
    
Me!MVA_Ende = Endezeit_G(Me!VADatum, Me!MA_Start, tempbis)

DoEvents '
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Function


Function brutto_Std2_Berech() As Single
Dim h_start As Date, h_ende As Date, dtdat As Date

dtdat = Me!VADatum_ID.Column(1)
h_start = Me!MA_Start
h_ende = Me!MA_Ende

brutto_Std2_Berech = timeberech_G(dtdat, h_start, h_ende)
DoEvents

End Function

Private Sub MA_Start_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!MA_Start.Text
        If Not IsNumeric(st) Then Exit Sub
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!MA_Start = uz
    End If

End Sub

Private Sub MA_Ende_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date
'If keycode = 13 Then
'Me.Recordset.MoveNext
''    If keycode = vbKeyReturn Or keycode = vbKeyTab Then
'        keycode = 0
        st = Me!MA_Ende.Text
        If Not IsNumeric(st) Then Exit Sub
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!MA_Ende = uz
'    End If


End Sub


Private Sub PKW_AfterUpdate()
DoCmd.RunCommand acCmdSaveRecord
Dim i As Long

If Nz(Me!PKW_Anzahl, 0) = 0 Then Me!PKW_Anzahl = 1

DoEvents
End Sub

Private Sub PreisArt_ID_DblClick(Cancel As Integer)
DoCmd.OpenForm "frmTop_KD_Preisarten"
End Sub

Private Sub VAStart_ID_AfterUpdate()
Dim h_start As Date
Dim h_ende As Date

Dim dtdat As Date
Dim sAnz As Single

Dim dtdatzeitvon As Date
Dim dtdatzeitbis As Date

If Len(Trim(Nz(Me!VADatum_ID))) = 0 Then
    MsgBox "Bitte erst Startdatum ändern"
    Me!VADatum_ID.SetFocus
    Exit Sub
End If

dtdat = Me!VADatum_ID.Column(1)
Me!MA_Start = Me!VAStart_ID.Column(1)
If Len(Trim(Nz(Me!VAStart_ID.Column(2)))) > 0 Then
    Me!MA_Ende = Me!VAStart_ID.Column(2)
End If

Start_End_Aend

End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)

   On Error GoTo Form_BeforeUpdate_Error

        Me!Aend_am = Now()
        Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
        
   On Error GoTo 0
   Exit Sub

Form_BeforeUpdate_Error:

    MsgBox "Error " & Err.Number & " (" & Err.description & ") in procedure Form_BeforeUpdate of VBA Dokument Form_sub_MA_VA_Zuordnung"

End Sub
