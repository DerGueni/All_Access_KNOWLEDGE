VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__subfrmKalender"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim aktTag As Long


' ##########################################################################
' Wird aufgerufen, wenn der Tag ausgewählt wird - muss selbst befüllt werden
' Verwendbare/gefüllte Werte:
' ---------------------------
'  Me!cboJahr   - ausgewähltes Jahr (Long)
'  Me!cboMonat  - Ausgewählter Monat (Long)
'  AktTag       - Ausgewählter Tag (Long)
'  Gl_MATag_AktDatum     - Ausgewähltes Datum (Date)

' Intern verwendet:
'   Tabellen: _tblAlleJahre
'             _tblAlleMonate
'             _tblAlleTage
'   Dieses Formular als Subformular: _subfrmKalender
' ##########################################################################

Public Function EigeneTagesFunktion()

Dim strSQL As String
'Dim frm As Form
'Set frm = Me.Parent!sub_lst_MA_Tageszusatzwerte.Form

    Call Set_Priv_Property("prp_MA_Aktdat", Gl_MATag_AktDatum)
    
    Me.Parent!AuswDatum = Gl_MATag_AktDatum
'    MsgBox "Gesetzt wurde " & Format(Gl_MATag_AktDatum, "dd.mm.yyyy", 2, 2)

    strSQL = ""
    strSQL = strSQL & "SELECT VA_ID, [Auftrag] & ' - ' & [Objekt] AS Auftr FROM qry_MA_VA_Zuo_All WHERE VADatum = " & SQLDatum(Gl_MATag_AktDatum) & " AND MA_ID = " & Me.Parent!ID
    
    'On Error Resume Next ' Beim Open ist das Sub noch nicht geladen, daher erst beim Tab aufrufen ...
    
    Me.Parent!sub_lst_MA_Tageszusatzwerte.Form!VA_ID.RowSource = strSQL
'    Me.Parent!sub_lst_MA_Tageszusatzwerte.Form!AktDat = Gl_MATag_AktDatum
'    Me.Parent!sub_lst_MA_Tageszusatzwerte.Form!MA_ID = Gl_Akt_MA_ID
    
    DoEvents
    
    strSQL = ""
    strSQL = strSQL & "SELECT * FROM qry_MA_VA_Zuo_All WHERE VADatum = " & SQLDatum(Gl_MATag_AktDatum) & " AND MA_ID = " & Me.Parent!ID
    Me.Parent!lst_Zuo.RowSource = strSQL
    Me.Parent!lst_Zuo.Requery
    DoEvents
    
    Me.Parent!AnzVATag = rstDcount("*", strSQL)
    
    Call Set_Priv_Property("prp_AktMonUeb_Monat", Me!cboMonat)
    Call Set_Priv_Property("prp_AktMonUeb_Jahr", Me!cboJahr)

End Function


' ##########################################################################
' ##########################################################################















' ##########################################################################
' Interne Funktionen der Submaske
' ===============================
' ##########################################################################

Private Sub btnHeute_Click()
Form_Open False
EigeneTagesFunktion
End Sub

Private Sub cboJahr_AfterUpdate()
KalFill
End Sub

Private Sub cboMonat_AfterUpdate()
KalFill
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!cboMonat = Month(Date)
Me!cboJahr = Year(Date)
aktTag = Format(Date, "d", 2, 2)
Gl_MATag_AktDatum = Date
Me!btnHeute.caption = "Heute: " & Format(Gl_MATag_AktDatum, "dd.mm.yyyy", 2, 2)
'Rest wird bei TabChange da beim open fehler
End Sub

Public Function KalFill()
Dim i As Long
Dim It As Long, Jt As Long  ' Tag
Dim Iw As Long, Jw As Long  ' Woche
Dim strSQL As String
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

Me!lblDatum.caption = CStr(Me!cboMonat.Column(1)) & " " & CStr(Me!cboJahr)


Me!btnHeute.SetFocus

For i = 1 To 42
    Me("T" & i) = False
    Me("T" & i).Visible = False
Next i
For i = 1 To 6
    Me("W" & i).caption = ""
Next i

recsetSQL1 = ""
recsetSQL1 = "SELECT JahrNr, MonatNr, TagNr, WN_KalMon, KW_D, WN_KalTag FROM _tblAlleTage"
recsetSQL1 = recsetSQL1 & " WHERE (((JahrNr)= " & Me!cboJahr & ") AND ((MonatNr)=" & Me!cboMonat & "));"

ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        It = DAOARRAY1(2, iZl) ' TagNr
        Jt = DAOARRAY1(5, iZl) ' Lfd TagNr innerhalb des Monats
        Iw = DAOARRAY1(4, iZl) ' Deutsche Wochennr
        Jw = DAOARRAY1(3, iZl) ' Lfd Wochennr innerhalb des Monats
       
        Me("T" & Jt).Visible = True
        
        Me("W" & Jw).caption = Iw
        Me("T" & Jt).caption = It
        
        If It = aktTag Then Me("T" & Jt) = True
    
    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function

Private Function TagSetzen()
Dim ctlName As String
Dim It As Long, Jt As Long  ' Tag
Dim i As Long


Dim mycontrol As control
Dim myTarget As control

Set mycontrol = Screen.ActiveForm.ActiveControl
If TypeName(mycontrol) = "SubForm" Then
    Set myTarget = mycontrol.Form.ActiveControl
Else
    Set myTarget = mycontrol
End If
    
'Ermitteln des aufrufenden Controls ...
ctlName = myTarget.Name
'ctlname = Application.Screen.ActiveForm.ActiveControl.Name
It = Me(ctlName).caption
Jt = Mid(ctlName, 2)
aktTag = It

For i = 1 To 42
    Me("T" & i) = False
Next i
Me("T" & Jt) = True

Gl_MATag_AktDatum = DateSerial(Me!cboJahr, Me!cboMonat, aktTag)
EigeneTagesFunktion

End Function

Public Function Activate_Tab()
'Gl_MATag_AktDatum = Date '' Beim Open gesetzt

Me!cboMonat = Get_Priv_Property("prp_AktMonUeb_Monat")
Me!cboJahr = Get_Priv_Property("prp_AktMonUeb_Jahr")

DoEvents
Me!lblDatum.caption = CStr(Me!cboMonat.Column(1)) & " " & CStr(Me!cboJahr)
DoEvents
KalFill
EigeneTagesFunktion
End Function
