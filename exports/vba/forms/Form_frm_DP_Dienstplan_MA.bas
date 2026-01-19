VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_DP_Dienstplan_MA"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim tmpMA As Long


Private Sub Befehl20_Click()
DoCmd.OpenForm ("frmOff_Outlook_aufrufen")
'Form_frmOff_Outlook_aufrufen.VAOpen (strPfad & strdoc)
End Sub


'Dienstpläne nach Liste verschicken
Private Sub btnDPSenden_Click()

Dim rs      As Recordset
Dim rc      As String
Dim sql     As String
Dim WHERE   As String
Dim sqlvon  As String
Dim sqlbis  As String

    If MsgBox("Dienstpläne nach Auswahl versenden?", vbYesNo) = vbYes Then

        'Zeitraum
        sqlvon = datumSQL(Me.dtStartdatum)
        sqlbis = datumSQL(Me.dtEnddatum)
        
        Set rs = Me.sub_DP_Grund.Form.RecordsetClone
        Do While Not rs.EOF
            'RecordSource Bericht Dienstplan puffern
            WHERE = "MA_ID = " & rs.fields("MA_ID") & " AND (VADatum BETWEEN " & sqlvon & " AND " & sqlbis & ") ORDER BY VADatum, Beginn;"
            sql = "SELECT * FROM qry_Dienstplan WHERE " & WHERE
            'Nur versenden, wenn DP nicht leer
            If Not IsNull(TLookup("MA_ID", "qry_Dienstplan", WHERE)) Then
                Set_Priv_Property "prp_rpt_Dienstplan_MA_Recordsource", sql
                Set_Priv_Property "prp_rpt_Dienstplan_MA_von", Me.dtStartdatum
                Set_Priv_Property "prp_rpt_Dienstplan_MA_bis", Me.dtEnddatum
                DoCmd.OpenReport rptDP, acViewPreview
                DoCmd.Close acReport, rptDP, acSaveYes
                rc = rc & rs.fields("MAName") & ": " & Dienstplan_senden(rs.fields("MA_ID"), Me.dtStartdatum, Me.dtEnddatum) & vbCrLf
            End If
            rs.MoveNext
        Loop
    End If
    
    MsgBox rc
    
    Me.Recalc
    Me.Refresh
    
End Sub


Private Sub btnMADienstpl_Click()
DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
Forms!frm_MA_Mitarbeiterstamm!pgPlan.SetFocus
End Sub

Private Sub btnOutpExcelSend_Click()
FCreate_Dienstplan_Excel_Send (2)
'DoCmd.OpenForm "frm_ma_serienmail_email_dienstplan", acNormal
End Sub


Private Sub Form_Load()
DoCmd.Maximize

Me!lbl_Version.Visible = True
Me!lbl_Version.caption = Get_Priv_Property("prp_V_FE") & " | " & Get_Priv_Property("prp_V_BE")
End Sub

Private Sub btnOutpExcel_Click()
FCreate_Dienstplan_Excel (2)

End Sub


Public Function btnSta()
Call btnStartdatum_Click
End Function

Private Sub btn_Heute_Click()
    Me!dtStartdatum = Date
    tmpMA = Me.sub_DP_Grund.Form.Recordset.fields("MA_ID")
    Call btnStartdatum_Click
    tmpMA = 0
End Sub

Private Sub btnreq_Click()
Call btnStartdatum_Click
End Sub

Private Sub btnrueck_Click()
    Dim dt As Date
    dt = Me!dtStartdatum
    Me!dtStartdatum = dt - 2
    tmpMA = Me.sub_DP_Grund.Form.Recordset.fields("MA_ID")
    Call btnStartdatum_Click
    tmpMA = 0
End Sub

Private Sub btnVor_Click()
    Dim dt As Date
    dt = Me!dtStartdatum
    Me!dtStartdatum = dt + 2
    tmpMA = Me.sub_DP_Grund.Form.Recordset.fields("MA_ID")
    Call btnStartdatum_Click
    tmpMA = 0
End Sub

Private Sub btnStartdatum_Click()

On Error Resume Next

    Me.Painting = False
    
    Me.SetFocus
    
    If tmpMA = 0 Then tmpMA = Me.sub_DP_Grund.Form.Recordset.fields("MA_ID")
    
    Me!dtStartdatum = Me!dtStartdatum
    Me.dtEnddatum = Me.dtStartdatum + 9
    
    Me!dtStartdatum.SetFocus
    
    Call fCreate_DP_MA_tmptable(Me!dtStartdatum, Me!NurAktiveMA)
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    
    Me!sub_DP_Grund.Form.recordSource = Me!sub_DP_Grund.Form.recordSource
    
    Me!dtStartdatum.SetFocus
    fset_Tage
    DoEvents
    Me!sub_DP_Grund.Form.Requery
    DoEvents
    Call Set_Priv_Property("prp_Dienstpl_StartDatum", Me!dtStartdatum)
    Me!dtStartdatum.SetFocus
    'Me!frm_DP_Dienstplan_Objekt.SetFocus
    DoEvents
    Me!sub_DP_Grund.SetFocus
    Me!sub_DP_Grund.Form!Tag1_Name.SetFocus
    DoCmd.RunCommand acCmdRecordsGoToLast
    DoCmd.RunCommand acCmdRecordsGoToFirst
    
    If GL_lngPos > 0 Then
        Me!sub_DP_Grund.Form.Recordset.AbsolutePosition = GL_lngPos
    End If
    If Len(Trim(Nz(GL_DP_MA_Fld))) > 0 Then
        Me!sub_DP_Grund.SetFocus
        Me!sub_DP_Grund.Form(GL_DP_MA_Fld).SetFocus
    End If
    
    'Feiertage einfärben
    Dim i As Integer
        For i = 1 To 7
            If Feiertag(Me.Controls("lbl_Tag_" & i).Value) = "" Then
                Me.Controls("lbl_Tag_" & i).backColor = 16179314 'Türkis
                Me.Controls("lbl_Tag_" & i).ForeColor = 8 'Schwarz
            Else
                'Me.Controls("lbl_Tag_" & i).BackColor = 255 'Rot
                Me.Controls("lbl_Tag_" & i).ForeColor = 255 'Rot
            End If
        Next i
    
    
    Me.sub_DP_Grund.Form.Recordset.FindFirst "MA_ID = " & tmpMA
    Me.Painting = True
    Me.SetFocus

End Sub

Private Sub dtStartdatum_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXfrm_DP_Dienstplan_MAXXX"
End Sub

Private Sub dtStartdatum_Exit(Cancel As Integer)
Call btnStartdatum_Click
End Sub


Function fset_Tage()
Dim i As Long
Dim st As String
For i = 0 To 6
    st = "lbl_Tag_" & (i + 1)
    Me(st).Value = Me!dtStartdatum + i
Next i
End Function


Private Sub Form_Close()
GL_DP_MA_Fld = ""
End Sub

Private Sub Form_Open(Cancel As Integer)
DoCmd.Maximize
Dim dtdat As Date
    
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
'    DoCmd.ShowToolbar "Ribbon", acToolbarNo

dtdat = Get_Priv_Property("prp_Dienstpl_StartDatum")
Me!dtStartdatum = dtdat
Call btnStartdatum_Click
'btn_Heute_Click
    
End Sub

Private Sub lbl_Tag_1_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_1
Call btnStartdatum_Click
End Sub

Private Sub lbl_Tag_2_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_2
Call btnStartdatum_Click
End Sub

Private Sub lbl_Tag_3_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_3
Call btnStartdatum_Click
End Sub

Private Sub lbl_Tag_4_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_4
Call btnStartdatum_Click
End Sub

Private Sub lbl_Tag_5_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_5
Call btnStartdatum_Click
End Sub

Private Sub lbl_Tag_6_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_6
Call btnStartdatum_Click
End Sub

Private Sub lbl_Tag_7_DblClick(Cancel As Integer)
Me!dtStartdatum = Me!lbl_Tag_7
Call btnStartdatum_Click
End Sub

Private Sub NurAktiveMA_AfterUpdate()
Call btnStartdatum_Click
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


