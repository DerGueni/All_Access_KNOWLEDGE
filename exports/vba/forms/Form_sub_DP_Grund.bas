VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_DP_Grund"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Form_Open(Cancel As Integer)
DoCmd.Maximize
'PosNr_Einfaerben_FormatCondition  ' PER VBA NUR 3 KONDITIONEN PRO FELD MÖGLICH !!!
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
    Form_frm_DP_Dienstplan_Objekt.btnSta
ElseIf KeyCode < 37 Or KeyCode > 40 Then
    KeyCode = 0
End If

End Function

'Doppelklick auf den Auftrag
Private Sub ObjOrt_Anzeige_DblClick(Cancel As Integer)
Dim ZUO_ID As String
Dim VA_ID As String
Dim iVA_ID As Long
'Dim mename As String

    'DoCmd.Echo.False
    Select Case True
        Case Not IsNull(Me.Tag1_Zuo_ID)
            ZUO_ID = Me.Tag1_Zuo_ID
        Case Not IsNull(Me.Tag2_Zuo_ID)
            ZUO_ID = Me.Tag2_Zuo_ID
        Case Not IsNull(Me.Tag3_Zuo_ID)
            ZUO_ID = Me.Tag3_Zuo_ID
        Case Not IsNull(Me.Tag4_Zuo_ID)
            ZUO_ID = Me.Tag4_Zuo_ID
        Case Not IsNull(Me.Tag5_Zuo_ID)
            ZUO_ID = Me.Tag5_Zuo_ID
        Case Not IsNull(Me.Tag6_Zuo_ID)
            ZUO_ID = Me.Tag6_Zuo_ID
        Case Not IsNull(Me.Tag7_Zuo_ID)
            ZUO_ID = Me.Tag7_Zuo_ID
    End Select
        
    VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & ZUO_ID)

    If IsNumeric(VA_ID) Then iVA_ID = VA_ID
    
    If iVA_ID = 0 Then Exit Sub
    
    fopenAuftragstamm (iVA_ID)


    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents
    'DoCmd.Echo.True

End Sub


Private Sub Tag1_bis_DblClick(Cancel As Integer)
Me!Tag1_bis.SetFocus
fTest Cancel
End Sub


'Private Sub Tag1_Name_Click()
'Me!Tag1_Name.SetFocus
'End Sub

Private Sub Tag1_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag1_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag1_Name"
fDel_MA_ID_Zuo iZuo, KeyCode


If KeyCode = 40 Then 'nach unten Taste
    Dim VA_ID As String
    Dim VADatum_ID As String
    
    If iZuo <> 0 Then
        VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
        VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
    End If
    If IsNumeric(VA_ID) And IsNumeric(VADatum_ID) Then Call fopenAuftragstamm(VA_ID, VADatum_ID)
End If
End Sub


'Private Sub Tag1_von_KeyDown(KeyCode As Integer, Shift As Integer)
'If KeyCode = 0 Then
'Me.Recordset.Tag1_von = Me.Recordset.Tag1_von.previous
'End Sub
'
'Private Sub Tag2_Name_Click()
'Me!Tag2_Name.SetFocus
'End Sub

Private Sub Tag1_von_DblClick(Cancel As Integer)
Me!Tag1_von.SetFocus
fTest Cancel
End Sub


Private Sub Tag1_von_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag1_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag1_von"
fDel_MA_ID_Zuo iZuo, KeyCode
End Sub

Private Sub Tag2_bis_DblClick(Cancel As Integer)
Me!Tag2_bis.SetFocus
fTest Cancel
End Sub


Private Sub Tag2_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag2_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag2_Name"
fDel_MA_ID_Zuo iZuo, KeyCode


If KeyCode = 40 Then 'nach unten Taste
    Dim VA_ID As String
    Dim VADatum_ID As String
    
    If iZuo <> 0 Then
        VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
        VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
    End If
    If IsNumeric(VA_ID) And IsNumeric(VADatum_ID) Then Call fopenAuftragstamm(VA_ID, VADatum_ID)
End If

End Sub

Private Sub Tag2_von_DblClick(Cancel As Integer)
Me!Tag2_von.SetFocus
fTest Cancel
End Sub


Private Sub Tag3_bis_DblClick(Cancel As Integer)
Me!Tag3_bis.SetFocus
fTest Cancel
End Sub


'Private Sub Tag3_Name_Click()
'Me!Tag3_Name.SetFocus
'End Sub

Private Sub Tag3_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag3_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag3_Name"
fDel_MA_ID_Zuo iZuo, KeyCode


If KeyCode = 40 Then 'nach unten Taste
    Dim VA_ID As String
    Dim VADatum_ID As String
    
    If iZuo <> 0 Then
        VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
        VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
    End If
    If IsNumeric(VA_ID) And IsNumeric(VADatum_ID) Then Call fopenAuftragstamm(VA_ID, VADatum_ID)
End If
End Sub
'
'Private Sub Tag4_Name_Click()
'Me!Tag4_Name.SetFocus
'End Sub

Private Sub Tag3_von_DblClick(Cancel As Integer)
Me!Tag3_von.SetFocus
fTest Cancel
End Sub


Private Sub Tag4_bis_DblClick(Cancel As Integer)
Me!Tag4_von.SetFocus
fTest Cancel
End Sub

Private Sub Tag4_Name_Click()
Me.Tag4_Name.SetFocus
End Sub

Private Sub Tag4_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag4_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag4_Name"
fDel_MA_ID_Zuo iZuo, KeyCode


If KeyCode = 40 Then 'nach unten Taste
    Dim VA_ID As String
    Dim VADatum_ID As String
    
    If iZuo <> 0 Then
        VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
        VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
    End If
    If IsNumeric(VA_ID) And IsNumeric(VADatum_ID) Then Call fopenAuftragstamm(VA_ID, VADatum_ID)
End If
End Sub

Private Sub Tag4_von_DblClick(Cancel As Integer)
Me!Tag4_von.SetFocus
fTest Cancel
End Sub

Private Sub Tag5_bis_DblClick(Cancel As Integer)
Me!Tag5_bis.SetFocus
fTest Cancel
End Sub

'Private Sub Tag5_Name_Click()
'Me!Tag5_Name.SetFocus
'End Sub

Private Sub Tag5_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag5_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag5_Name"
fDel_MA_ID_Zuo iZuo, KeyCode


If KeyCode = 40 Then 'nach unten Taste
    Dim VA_ID As String
    Dim VADatum_ID As String
    
    If iZuo <> 0 Then
        VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
        VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
    End If
    If IsNumeric(VA_ID) And IsNumeric(VADatum_ID) Then Call fopenAuftragstamm(VA_ID, VADatum_ID)
End If
End Sub
'
'Private Sub Tag6_Name_Click()
'Me!Tag6_Name.SetFocus
'End Sub

Private Sub Tag5_von_DblClick(Cancel As Integer)
Me!Tag5_von.SetFocus
fTest Cancel
End Sub

Private Sub Tag6_bis_DblClick(Cancel As Integer)
Me!Tag6_bis.SetFocus
fTest Cancel
End Sub

Private Sub Tag6_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag6_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag6_Name"
fDel_MA_ID_Zuo iZuo, KeyCode


If KeyCode = 40 Then 'nach unten Taste
    Dim VA_ID As String
    Dim VADatum_ID As String
    
    If iZuo <> 0 Then
        VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
        VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
    End If
    If IsNumeric(VA_ID) And IsNumeric(VADatum_ID) Then Call fopenAuftragstamm(VA_ID, VADatum_ID)
End If
End Sub
'
'Private Sub Tag7_Name_Click(cancel As Integer)
'Me!Tag7_Name.SetFocus
'End Sub

Private Sub Tag6_von_DblClick(Cancel As Integer)
Me!Tag6_von.SetFocus
fTest1 Cancel
End Sub

Private Sub Tag7_bis_DblClick(Cancel As Integer)
Me!Tag7_bis.SetFocus
fTest1 Cancel
End Sub

Private Sub Tag7_Name_KeyDown(KeyCode As Integer, Shift As Integer)
Dim iZuo As Long
iZuo = Nz(Me!Tag7_Zuo_ID, 0)
GL_DP_Objekt_Fld = "Tag7_Name"
fDel_MA_ID_Zuo iZuo, KeyCode


If KeyCode = 40 Then 'nach unten Taste
    Dim VA_ID As String
    Dim VADatum_ID As String
    
    If iZuo <> 0 Then
        VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
        VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
    End If
    If IsNumeric(VA_ID) And IsNumeric(VADatum_ID) Then Call fopenAuftragstamm(VA_ID, VADatum_ID)
End If
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
 Dim iVADatum_ID As Long
 Dim dtVADatum As Date
 Dim stObjOrt As String
 Dim strSQL As String
'DoCmd.Echo = False
'Global GL_strBookmark_Object As String
'GL_strBookmark_Object = Me.Recordset.Bookmark

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

iMA_ID = 0
iZuo_ID = 0
iVADatum_ID = 0
iVA_ID = 0
stprae = Left(ctlName, 5)

iZuo_ID = Nz(Me(stprae & "Zuo_ID").Value, 0)
iVA_ID = Nz(TLookup("VA_ID", "tbl_MA_VA_Zuordnung", "ID = " & Nz(Me(stprae & "Zuo_ID").Value, 0)))
'Debug.Print "Zuo_ID " & iZuo_ID
'Debug.Print "VA_ID " & iVA_ID
If iVA_ID = 0 Or iZuo_ID = 0 Then
    MsgBox "Es können nur Aufträge, die Positionen beinhalten, bearbeitet werden"
    Cancel = True
    Exit Function
End If

stObjOrt = Nz(Me!ObjOrt)
iMA_ID = Nz(Me(stprae & "MA_ID").Value, 0)
iVADatum_ID = Nz(TLookup("VADatum_ID", "tbl_MA_VA_Zuordnung", "ID = " & iZuo_ID))
dtVADatum = Nz(TLookup("VADatum", "tbl_MA_VA_Zuordnung", "ID = " & iZuo_ID))

strSQL = ""
strSQL = strSQL & "SELECT clng(ZuordID) as Zuo_ID FROM qry_DP_Alle"
strSQL = strSQL & " Where (((qry_DP_Alle.ObjOrt) = '" & stObjOrt & "')"
strSQL = strSQL & " And ((qry_DP_Alle.VADatum) >= " & SQLDatum(dtVADatum) & "));"
If Not CreateQuery(strSQL, "qry_DP_Obj_ab_Heute_ZW") Then
    MsgBox strSQL, vbCritical, "'qry_DP_Obj_ab_Heute_ZW' wurde nicht erstellt, Abbruch"
    Exit Function
End If
GL_lngPos = Me.Recordset.AbsolutePosition
GL_DP_Objekt_Fld = ctlName

DoCmd.OpenForm "frmTop_DP_Auftrageingabe"
Forms!frmTop_DP_Auftrageingabe.lbl_ObjOrt.caption = stObjOrt & " " & Nz(Me(stprae & "von").Value, 0) & " - " & Nz(Me(stprae & "bis").Value, 0) & " Uhr"
Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.recordSource = "SELECT * FROM tbl_MA_VA_Zuordnung WHERE ID = " & iZuo_ID & ";"
Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.Requery
'MsgBox "Hallo"

'Verfügbarkeiten updaten
'Call refresh_zuoplanfe
Call Forms.frmTop_DP_Auftrageingabe.update
Call Forms.frmTop_DP_Auftrageingabe.fMA_Selektion_AfterUpdate
Forms.frmTop_DP_Auftrageingabe.sub_MA_VA_Zuordnung.Form.cboMA_Ausw.Dropdown

'Debug.Print "Name " & Me(stprae & "Name").Value
'Debug.Print "ID " & Me!ID.Value
'Debug.Print "Zuo_ID " & Me(stprae & "Zuo_ID").Value
'Debug.Print "MA_ID " & Me(stprae & "MA_ID").Value
'Debug.Print "von " & Me(stprae & "von").Value
'Debug.Print "bis " & Me(stprae & "bis").Value
'Debug.Print "VA_ID " & iVA_ID
'Debug.Print "Backcol " & mySubTarget.BackColor

'PosNr_Einfaerben_FormatCondition
'DoCmd.Echo = True
End Function

Function fTest1(ByRef Cancel As Integer)
 Dim mycontrol As control
 Dim myTarget As control
 Dim mySubTarget As control
 Dim ctlName
 Dim stprae As String
 Dim iVA_ID As Long
 Dim iMA_ID As Long
 Dim iZuo_ID As Long
 Dim iVADatum_ID As Long
 Dim dtVADatum As Date
 Dim stObjOrt As String
 Dim strSQL As String
DoCmd.Echo (False)
'Global GL_strBookmark_Object As String
'GL_strBookmark_Object = Me.Recordset.Bookmark

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

iMA_ID = 0
iZuo_ID = 0
iVADatum_ID = 0
iVA_ID = 0

stprae = Left(ctlName, 5)

iZuo_ID = Nz(Me(stprae & "Zuo_ID").Value, 0)
iVA_ID = Nz(TLookup("VA_ID", "tbl_MA_VA_Zuordnung", "ID = " & Nz(Me(stprae & "Zuo_ID").Value, 0)))
'Debug.Print "Zuo_ID " & iZuo_ID
'Debug.Print "VA_ID " & iVA_ID
If iVA_ID = 0 Or iZuo_ID = 0 Then
    MsgBox "Es können nur Aufträge, die Positionen beinhalten, bearbeitet werden"
    Cancel = True
    Exit Function
End If

stObjOrt = Nz(Me!ObjOrt)
iMA_ID = Nz(Me(stprae & "MA_ID").Value, 0)
iVADatum_ID = Nz(TLookup("VADatum_ID", "tbl_MA_VA_Zuordnung", "ID = " & iZuo_ID))
dtVADatum = Nz(TLookup("VADatum", "tbl_MA_VA_Zuordnung", "ID = " & iZuo_ID))

strSQL = ""
strSQL = strSQL & "SELECT clng(ZuordID) as Zuo_ID FROM qry_DP_Alle"
strSQL = strSQL & " Where (((qry_DP_Alle.ObjOrt) = '" & stObjOrt & "')"
strSQL = strSQL & " And ((qry_DP_Alle.VADatum) >= " & SQLDatum(dtVADatum) & "));"
If Not CreateQuery(strSQL, "qry_DP_Obj_ab_Heute_ZW") Then
    MsgBox strSQL, vbCritical, "'qry_DP_Obj_ab_Heute_ZW' wurde nicht erstellt, Abbruch"
    Exit Function
End If
GL_lngPos = Me.Recordset.AbsolutePosition
GL_DP_Objekt_Fld = ctlName


DoCmd.OpenForm "frmTop_DP_Auftrageingabe"
Forms!frmTop_DP_Auftrageingabe.lbl_ObjOrt.caption = stObjOrt & " " & Nz(Me(stprae & "von").Value, 0) & " - " & Nz(Me(stprae & "bis").Value, 0) & " Uhr"
Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.recordSource = "SELECT * FROM tbl_MA_VA_Zuordnung WHERE ID = " & iZuo_ID & ";"
Forms!frmTop_DP_Auftrageingabe!sub_MA_VA_Zuordnung.Form.Requery
'MsgBox "Hallo"


'Debug.Print "Name " & Me(stprae & "Name").Value
'Debug.Print "ID " & Me!ID.Value
'Debug.Print "Zuo_ID " & Me(stprae & "Zuo_ID").Value
'Debug.Print "MA_ID " & Me(stprae & "MA_ID").Value
'Debug.Print "von " & Me(stprae & "von").Value
'Debug.Print "bis " & Me(stprae & "bis").Value
'Debug.Print "VA_ID " & iVA_ID
'Debug.Print "Backcol " & mySubTarget.BackColor

'PosNr_Einfaerben_FormatCondition
DoCmd.Echo (True)
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

Set ctl = Me("ObjOrt_Anzeige")
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

' Fehlende Namen
'####################################

   st3 = "_MA_ID"
   st1 = "_Zuo_ID"
   st2 = st & i & st1
    st4 = st & i & st3
   Set ctl = Me(st & i & "_Name")
    With ctl.FormatConditions
   Set fcd = .Add(acExpression, , "[" & st2 & "] > 0 AND [" & st4 & "] = 0")
   fcd.backColor = 10547455
   End With

' nicht "Lex_aktiv"
'####################################
   st1 = "_MA_ID"
   st2 = st & i & st1
   Set ctl = Me(st & i & "_Name")
    With ctl.FormatConditions
   Set fcd = .Add(acExpression, , "[" & st2 & "].[column](1)=0")
   fcd.ForeColor = vbRed
   End With

' Alle Flächen ohne Projekt ausgrauen - Name
'####################################

'   st1 = "_Zuo_ID"
'   st2 = st & i & st1
'   Set ctl = Me(st & i & "_Name")
'    With ctl.FormatConditions
'   Set fcd = .Add(acExpression, , "IsNull([" & st2 & "])")
'   fcd.BackColor = 14474460
'   End With

' Alle Flächen ohne Projekt ausgrauen - von
'####################################

   st1 = "_Zuo_ID"
   st2 = st & i & st1
   Set ctl = Me(st & i & "_von")
    With ctl.FormatConditions
   Set fcd = .Add(acExpression, , "IsNull([" & st2 & "])")
   fcd.backColor = 14474460
   End With

' Alle Flächen ohne Projekt ausgrauen - bis
'####################################
 
   st1 = "_Zuo_ID"
   st2 = st & i & st1
   Set ctl = Me(st & i & "_bis")
    With ctl.FormatConditions
   Set fcd = .Add(acExpression, , "IsNull([" & st2 & "])")
   fcd.backColor = 14474460
   End With
Next i

' Erste Spalte fett
'####################################

Set ctl = Me("ObjOrt_Anzeige")
With ctl.FormatConditions
Set fcd = .Add(acExpression, , "1 = 1")
fcd.FontBold = True
End With
    
End Function

Private Sub Tag7_von_DblClick(Cancel As Integer)
Me!Tag7_von.SetFocus
fTest Cancel
End Sub


'Absprung in Auftragstamm
Function fopenAuftragstamm(ByVal iVA_ID As Long, Optional ByVal iVADatum_ID As Long)

Dim i As Long

    DoCmd.OpenForm "frm_VA_Auftragstamm" ', , , "ID = " & iVA_ID
    
    Form_frm_VA_Auftragstamm.zsub_lstAuftrag.Form.Recordset.FindFirst "ID = " & iVA_ID
    
End Function


'Schnellere Selektion der relevanten Mitarbeiter
Function zf_MA_Selektion()

Dim strSQL As String
Dim srctbl As String

    Me.Painting = False
    srctbl = "ztbl_MA_Schnellauswahl"
    'strsql = upd_qry_Verfuegbarkeit(Me.IstVerfuegbar, Me.cboAnstArt, Me.cboQuali, Me.istaktiv, Me.cbVerplantVerfuegbar, Me.cbNur34a)
    strSQL = upd_qry_Verfuegbarkeit(False, 13, 1, True, False, False)
    CurrentDb.Execute "DELETE FROM " & srctbl
    CurrentDb.Execute "INSERT INTO " & srctbl & " " & strSQL
    DoEvents
    
End Function
