VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_DP_Grund_MA"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub Form_Open(Cancel As Integer)
On Error Resume Next
PosNr_Einfaerben_FormatCondition
Me.OrderBy = ""
End Sub

Function fDel_MA_ID_Zuo(iZuo As Long, ByRef KeyCode As Integer)
Dim iVADatum_ID As Long
Dim iVAStart_ID As Long
'On error resume next
If KeyCode = 46 And iZuo > 0 Then
    KeyCode = 0
    iVADatum_ID = Nz(TLookup("VADatum_ID", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
    iVAStart_ID = Nz(TLookup("VAStart_ID", "tbl_MA_VA_Zuordnung", "ID = " & iZuo), 0)
    CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_ID = 0, IstFraglich = 0 WHERE (((tbl_MA_VA_Zuordnung.ID)= " & iZuo & "));")
    Call fTag_Schicht_Update(iVADatum_ID, iVAStart_ID)
    GL_lngPos = Me.Recordset.AbsolutePosition
    Form_frm_DP_Dienstplan_MA.btnSta
ElseIf KeyCode < 37 Or KeyCode > 40 Then
    KeyCode = 0
End If

End Function

Public Sub maname_dblclick(Cancel As Integer)

Dim iMA_ID As Long
Dim i As Long

iMA_ID = Nz(Me!MA_ID, 0)
If iMA_ID = 0 Then Exit Sub

    DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"

Form_frm_MA_Mitarbeiterstamm.Recordset.FindFirst "ID = " & iMA_ID

Form_frm_VA_Auftragstamm.Painting = False

    For i = 1 To Form_frm_MA_Mitarbeiterstamm!Lst_MA.ListCount
        If Trim(Nz(Form_frm_MA_Mitarbeiterstamm!Lst_MA.Column(0, i))) = iMA_ID Then
            Form_frm_MA_Mitarbeiterstamm!Lst_MA.selected(i) = True
            Exit For
        End If
    Next i


Form_frm_VA_Auftragstamm.Painting = True


DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Sub


Private Sub Tag1_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag1_Zuo_ID, 0)
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub

Private Sub Tag2_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag2_Zuo_ID, 0)
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub




' Private Sub Tag2_Name_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
' DoCmd.OpenForm "sub_MA_FehlZeiten"
' End Sub

Private Sub Tag3_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag3_Zuo_ID, 0)
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub

Private Sub Tag4_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag4_Zuo_ID, 0)
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub

Private Sub Tag5_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag5_Zuo_ID, 0)
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub

Private Sub Tag6_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag6_Zuo_ID, 0)
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub

Private Sub Tag7_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag7_Zuo_ID, 0)
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub

Private Sub Tag1_Name_DblClick(Cancel As Integer)
Me!Tag1_Name.SetFocus
fTest Cancel
End Sub

Private Sub Tag2_Name_DblClick(Cancel As Integer)
Me!Tag2_Name.SetFocus
fTest Cancel
End Sub

Private Sub Tag3_Name_DblClick(Cancel As Integer)
Me!Tag3_Name.SetFocus
fTest Cancel
End Sub

Private Sub Tag4_Name_DblClick(Cancel As Integer)
Me!Tag4_Name.SetFocus
fTest Cancel
End Sub

Private Sub Tag5_Name_DblClick(Cancel As Integer)
Me!Tag5_Name.SetFocus
fTest Cancel
End Sub

Private Sub Tag6_Name_DblClick(Cancel As Integer)
Me!Tag6_Name.SetFocus
fTest Cancel
End Sub

Private Sub Tag7_Name_DblClick(Cancel As Integer)
Me!Tag7_Name.SetFocus
fTest Cancel
End Sub

Function fTest(ByRef Cancel As Integer)
 Dim mycontrol As control
 Dim myTarget As control
 Dim mySubTarget As control
 Dim ctlName
 Dim stprae As String
 Dim iVA_ID As Long
 Dim iMA_ID As Long
 Dim iZuo_ID As Long
 Dim iVAStart_ID As Long
 Dim iVADatum_ID As Long
 Dim dtVADatum As Date
 Dim stObjOrt As String
 Dim strSQL As String
 Dim iTgNr As Long
 Dim dtOdat As Date
 Dim i As Long, j As Long, k As Long

 Dim frm As Form
'DoCmd.Echo.False
Set mycontrol = Screen.ActiveForm.ActiveControl

If mycontrol.ControlType = acSubform Then
'If TypeName(myControl) = "SubForm" Then
    Set myTarget = mycontrol.Form.ActiveControl
Else
    Set myTarget = mycontrol
End If
'If myTarget.ControlType = acSubform Then
''If TypeName(myControl) = "SubForm" Then
'    Set mySubTarget = myTarget.Form.ActiveControl
'Else
'    Set mySubTarget = myControl
'End If
'ctlname = mySubTarget.Name
ctlName = myTarget.Name

'Debug.Print "-------"
'Debug.Print "Controlname = " & ctlname
'Debug.Print "-------"

iMA_ID = Me!MA_ID
iZuo_ID = 0
iVADatum_ID = 0
iVA_ID = 0

stprae = Left(ctlName, 5)
If Left(stprae, 3) = "Tag" Then
    iTgNr = Mid(stprae, 4, 1)
    dtOdat = Me!Startdat + (iTgNr - 1)
End If

'Debug.Print "MA_ID = " & iMA_ID
'Debug.Print "MA Name = " & Me!MAName
'Debug.Print "Datum = " & dtOdat
'

'Global GL_DP_Objekt_ID As Long
'Global GL_DP_Objekt_Fld As String
'Global GL_DP_MA_ID As Long
'Global GL_DP_MA_Fld As String

strSQL = ""
strSQL = strSQL & "SELECT tbl_VA_AnzTage.VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum as Datum, fObjektOrt(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjOrt, tbl_VA_AnzTage.TVA_Ist as Ist, tbl_VA_AnzTage.TVA_Soll as Soll"
strSQL = strSQL & " FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
strSQL = strSQL & " WHERE (((tbl_VA_AnzTage.VADatum)= " & SQLDatum(dtOdat) & ") AND tbl_VA_AnzTage.TVA_Offen = True AND tbl_VA_AnzTage.TVA_Soll > 0);"

i = rstDcount("*", strSQL)

If i = 0 Then
    MsgBox "Keine Aufträge mit leeren Plätzen im gewünschten Zeitraum vorhanden"
    Exit Function
End If

If i = 1 Then
    iVADatum_ID = rstDLookUp("VADatum_ID", strSQL)
    iVA_ID = rstDLookUp("VA_ID", strSQL)

    strSQL = ""
    strSQL = strSQL & "SELECT ID AS VAStart_ID, VADatum_ID, MA_Anzahl AS Soll, MA_Anzahl_Ist As Ist, Format([VA_Start],'hh:nn') AS von, Format([VA_Ende],'hh:nn') AS bis FROM tbl_VA_Start"
    strSQL = strSQL & " WHERE VADatum_ID = " & iVADatum_ID & " And VA_ID = " & iVA_ID & " AND (MA_Anzahl > 0 AND MA_Anzahl_Ist < MA_Anzahl) order by VA_Start"

    j = rstDcount("*", strSQL)
    
    If j = 1 Then
        iVAStart_ID = rstDLookUp("VAStart_ID", strSQL)
        
        GL_DP_MA_Fld = ctlName
        k = Nz(DMin("ID", "tbl_MA_VA_Zuordnung", "VAStart_ID = " & iVAStart_ID & " AND MA_ID = 0"), 0)
        CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET tbl_MA_VA_Zuordnung.MA_ID = " & iMA_ID & " WHERE (((tbl_MA_VA_Zuordnung.ID)= " & k & "));")
        Call fTag_Schicht_Update(iVADatum_ID, iVAStart_ID)
        Form_frm_DP_Dienstplan_MA.btnSta
        Exit Function
    Else
        GL_DP_MA_Fld = ctlName
        GL_lngPos = Me.Recordset.AbsolutePosition
    
        DoCmd.OpenForm "frmTop_DP_MA_Auftrag_Zuo"
        Set frm = Forms!frmTop_DP_MA_Auftrag_Zuo
        
        frm!cboMA_ID = iMA_ID
        frm!dtPlanDatum = dtOdat
'
'        frm!MATel_Fest = Nz(TLookup("Tel_Festnetz", "tbl_MA_Mitarbeiterstamm", "ID = " & iMA_ID))
'        frm!MATel_mobil = Nz(TLookup("Tel_Mobil", "tbl_MA_Mitarbeiterstamm", "ID = " & iMA_ID))
'        frm!MAemail = Nz(TLookup("Email", "tbl_MA_Mitarbeiterstamm", "ID = " & iMA_ID))
'
        frm!ListeAuft.RowSource = strSQL
    
    End If
Else
    GL_DP_MA_Fld = ctlName
    GL_lngPos = Me.Recordset.AbsolutePosition

    DoCmd.OpenForm "frmTop_DP_MA_Auftrag_Zuo"
    Set frm = Forms!frmTop_DP_MA_Auftrag_Zuo
    
    frm!cboMA_ID = iMA_ID
'    frm!dtPlanDatum = dtOdat
    
'    frm!MATel_Fest = Nz(TLookup("Tel_Festnetz", "tbl_MA_Mitarbeiterstamm", "ID = " & iMA_ID))
'    frm!MATel_mobil = Nz(TLookup("Tel_Mobil", "tbl_MA_Mitarbeiterstamm", "ID = " & iMA_ID))
'    frm!MAemail = Nz(TLookup("Email", "tbl_MA_Mitarbeiterstamm", "ID = " & iMA_ID))
'
    frm!ListeAuft.RowSource = strSQL

End If

'cboMA_ID
''    COl1 = Mobil, 2 =Fest, 3 eMail
'dtPlanDatum
''Forms!frmTop_DP_Auftrageingabe.lbl_ObjOrt.Caption = stObjOrt
''Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.RecordSource = "qry_DP_Obj_ab_Heute"
''Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.Requery
'
'strSQL = ""
'strSQL = strSQL & "SELECT VADatum, [Auftrag] & ' ' & [Objekt] & ' ' [Ort] As Auftragsname, TVA_Soll, TVA_Ist"
'strSQL = strSQL & " FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID"
'strSQL = strSQL & " WHERE (((tbl_VA_AnzTage.VADatum)= " & SQLDatum(dtOdat) & ") AND (TVA_Soll > 0 AND TVA_Ist < [TVA_SOll]));"
'
''iZuo_ID = Nz(Me(stprae & "Zuo_ID").Value, 0)
'
'
'iVA_ID = Nz(TLookup("VA_ID", "tbl_MA_VA_Zuordnung", "ID = " & Nz(Me(stprae & "Zuo_ID").Value, 0)))
''Debug.Print "Zuo_ID " & iZuo_ID
''Debug.Print "VA_ID " & iVA_ID
'If iVA_ID = 0 Or iZuo_ID = 0 Then
'    MsgBox "Es können nur Aufträge, die Positionen beinhalten, bearbeitet werden"
'    Cancel = True
'    Exit Function
'End If
'
'stObjOrt = Nz(Me!ObjOrt)
'iMA_ID = Nz(Me(stprae & "MA_ID").Value, 0)
'iVAdatum_ID = Nz(TLookup("VADatum_ID", "tbl_MA_VA_Zuordnung", "ID = " & iZuo_ID))
'dtVADatum = Nz(TLookup("VADatum", "tbl_MA_VA_Zuordnung", "ID = " & iZuo_ID))
'
'strSQL = ""
'strSQL = strSQL & "SELECT clng(ZuordID) as Zuo_ID FROM qry_DP_Alle"
'strSQL = strSQL & " Where (((qry_DP_Alle.ObjOrt) = '" & stObjOrt & "')"
'strSQL = strSQL & " And ((qry_DP_Alle.VADatum) >= " & SQLDatum(dtVADatum) & "));"
'If Not CreateQuery(strSQL, "qry_DP_Obj_ab_Heute_ZW") Then
'    MsgBox strSQL, vbCritical, "'qry_DP_Obj_ab_Heute_ZW' wurde nicht erstellt, Abbruch"
'    Exit Function
'End If
'
'DoCmd.OpenForm "frmTop_DP_Auftrageingabe"
'Forms!frmTop_DP_Auftrageingabe.lbl_ObjOrt.Caption = stObjOrt
'Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.RecordSource = "qry_DP_Obj_ab_Heute"
'Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.Requery
''MsgBox "Hallo"
'
'
''Debug.Print "Name " & Me(stprae & "Name").Value
''Debug.Print "ID " & Me!ID.Value
''Debug.Print "Zuo_ID " & Me(stprae & "Zuo_ID").Value
''Debug.Print "MA_ID " & Me(stprae & "MA_ID").Value
''Debug.Print "von " & Me(stprae & "von").Value
''Debug.Print "bis " & Me(stprae & "bis").Value
''Debug.Print "VA_ID " & iVA_ID
''Debug.Print "Backcol " & mySubTarget.BackColor
'
''PosNr_Einfaerben_FormatCondition
'DoCmd.Echo.true
End Function


Function PosNr_Einfaerben_FormatCondition_Loesch()

Dim ctl As control
Dim fcd As FormatCondition

Dim i As Long, j As Long, k As Long, l As Long

Dim st As String
Dim st1 As String
Dim st2 As String

st = "Tag"
For i = 1 To 7
   Set ctl = Me(st & i & "_Name")
    ctl.FormatConditions.Delete
   Set ctl = Me(st & i & "_von")
    ctl.FormatConditions.Delete
   Set ctl = Me(st & i & "_bis")
    ctl.FormatConditions.Delete
  Next i

Set ctl = Me("MAName")
ctl.FormatConditions.Delete

End Function

Function PosNr_Einfaerben_FormatCondition()

Dim ctl As control
Dim fcd As FormatCondition
Dim i As Long, j As Long, k As Long, l As Long

Dim st As String
Dim st1 As String
Dim st2 As String
Dim st3 As String
Dim st4 As String

PosNr_Einfaerben_FormatCondition_Loesch

st = "Tag"
For i = 1 To 7

' _fraglich angekreuzt - Name hervorheben
'#####################

    st1 = "_fraglich"
   st2 = st & i & st1
   Set ctl = Me(st & i & "_Name")
    With ctl.FormatConditions
   Set fcd = .Add(acExpression, , "[" & st2 & "] = -1")
'   fcd.BackColor = 16766999  '' türkisblau
   fcd.backColor = Get_Priv_Property("prp_MA_Fraglich_Farbe")
'   fcd.BackColor = 111143 '' mittelgrün
'   fcd.BackColor = 130043 '' grelles hellgelb
'   fcd.BackColor = 127231 '' hellgelb
'   fcd.BackColor = 131043 '' helleres gelbrün
'   fcd.BackColor = 110043 '' helleres Kakibraun  ' <--
'   fcd.BackColor = 170343 '' Dunkles grün
'   fcd.BackColor = 180343 '' Helleres Mittelgrün grün
'   fcd.BackColor = 255 '' knalle Rot
'   fcd.BackColor = 157650 '' knalle Rot
'   fcd.BackColor = 16619021  '' knalle Blau
'   fcd.BackColor = 10547455  ''  schwaches gelb
   End With
'
'' Fehlende Namen
''####################################
'
'   st3 = "_MA_ID"
'   st1 = "_Zuo_ID"
'   st2 = st & i & st1
'    st4 = st & i & st3
'   Set ctl = Me(st & i & "_Name")
'    With ctl.FormatConditions
'   Set fcd = .Add(acExpression, , "[" & st2 & "] > 0 AND [" & st4 & "] = 0")
'   fcd.BackColor = 10547455
'   End With
'
'' Alle Flächen ohne Projekt ausgrauen - Name
''####################################
'
'   st1 = "_Zuo_ID"
'   st2 = st & i & st1
'   Set ctl = Me(st & i & "_Name")
'    With ctl.FormatConditions
'   Set fcd = .Add(acExpression, , "IsNull([" & st2 & "])")
'   fcd.BackColor = 14474460
'   End With
'
'' Alle Flächen ohne Projekt ausgrauen - von
''####################################
'
'   st1 = "_Zuo_ID"
'   st2 = st & i & st1
'   Set ctl = Me(st & i & "_von")
'    With ctl.FormatConditions
'   Set fcd = .Add(acExpression, , "IsNull([" & st2 & "])")
'   fcd.BackColor = 14474460
'   End With
'
'' Alle Flächen ohne Projekt ausgrauen - bis
''####################################
'
'   st1 = "_Zuo_ID"
'   st2 = st & i & st1
'   Set ctl = Me(st & i & "_bis")
'    With ctl.FormatConditions
'   Set fcd = .Add(acExpression, , "IsNull([" & st2 & "])")
'   fcd.BackColor = 14474460
'   End With
Next i

' Erste Spalte fett
'####################################

Set ctl = Me("MAName")
With ctl.FormatConditions
Set fcd = .Add(acExpression, , "1 = 1")
fcd.FontBold = True
End With
    
End Function
