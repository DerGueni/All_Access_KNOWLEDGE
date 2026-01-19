VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_Kalender_3Mon"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Autor: Klaus Oberdalhoff

'Damit der Kalender funktioniert, müssen die verwendeten Objekte mitkopiert werden:

'Aufruf als Unterformular testen
' Forms!frmTest.SetFocus
' Forms!frmTest!frmTest_ufrm.SetFocus
' Forms!frmTest!frmTest_ufrm.Form!Testfeld.SetFocus

' Verwendet: mdlSonstigesDatumUhrzeit
'            mdlPrivProperty
'            qryHlp_Feiertag
'            qryAlleFeiertage (qryHlp_Feiertag)
'            tblFeierStd      (qryHlp_Feiertag)
'            _tblBundesLand

' Dieses Formular wurde weitestgehend "automatisch" via VBA erzeugt. Function KalenderErstellen
' im Modul mdlNeuesFormular

' Ich wollte einerseits wissen, wie man einen Popup-Kalender erstellt, andererseits
' fand ich keinen, der gleichzeitig die bundeslandabhängigen Feiertage, die Wochennummern,
' Montag als ersten und Sonntag als letzten Tag, sowie eine Eingabe über 3 Monate hinweg ermöglicht.

' Die anderen Kalender bieten wohl das eine oder andere, aber nie alles auf einmal. Das Kalender-
' steuerelement will ich nicht benutzen. Auf der technischen Seite hat mich gereizt, zu erfahren, ob -
' und wenn wie - man alle 3 Monate mit einer 3-fach-loop setzen kann. Mir erschienen die anderen
' Kalender-Routinen recht "aufwendig" programmiert.

' Der Kalender von Herrn John hat mir vom Layout her als Vorlage gedient. Dafür möchte ich Herrn John
' danken.

Dim xClose As Boolean
Dim XHeight

Private Sub Befehl177_Click() 'Heute
Dim x
x = Datum_Neuaufbau(Me, Date)
End Sub

Private Sub Befehl181_Click() ' Ende
xClose = False
DoCmd.Close
End Sub

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"

End Sub

Private Sub cboMinute_AfterUpdate()
Global_iMinute = Me!cboMinute.Text
End Sub

Private Sub cboMinute_BeforeUpdate(Cancel As Integer)
If Me!cboMinute < 0 Or Me!cboMinute > 59 Then
    MsgBox "Uhrzeit muss zwischen 0 und 59 liegen"
    Cancel = True
End If
End Sub

Private Sub cboMinute_Change()
Global_iMinute = Me!cboMinute.Text
End Sub

Private Sub cboMinute_Exit(Cancel As Integer)
Global_iMinute = Me!cboMinute.Text
End Sub

Private Sub cboStunde_AfterUpdate()
Global_iStunde = Me!cboStunde.Text
End Sub

Private Sub cboStunde_Exit(Cancel As Integer)
Global_iStunde = Me!cboStunde.Text
End Sub

Private Sub cmbBundesland_AfterUpdate()
Dim y
y = Set_Priv_Property("Default_Bundesland", Me!cmbBundesland)
y = Datum_Neuaufbau(Me, Me!AktDat)
Call create_Default_AlleTage(Me!cmbBundesland)
End Sub

Private Sub CmdNextMonth_Click()
Dim x, xdat As Date
xdat = DateAdd("m", 1, Me!AktDat)
x = Datum_Neuaufbau(Me, xdat)
End Sub

Private Sub CmdNextYear_Click()
Dim x, xdat As Date
xdat = DateAdd("yyyy", 1, Me!AktDat)
x = Datum_Neuaufbau(Me, xdat)
End Sub

Private Sub CmdPreviousMonth_Click()
Dim x, xdat As Date
xdat = DateAdd("m", -1, Me!AktDat)
x = Datum_Neuaufbau(Me, xdat)
End Sub

Private Sub CmdPreviousYear_Click()
Dim x, xdat As Date
xdat = DateAdd("yyyy", -1, Me!AktDat)
x = Datum_Neuaufbau(Me, xdat)
End Sub

Private Sub Form_Close()
Dim xctrl As control, xFrm As Form, x, j, y, z

If xClose And Len(Trim(Nz(Me.OpenArgs))) > 0 Then
    
    x = Me.OpenArgs
    
    If x = "XXXSubformXXX" Then
        Set xctrl = Global_AufrufCtrl
    ElseIf x = "XXXfrm_DP_Dienstplan_MAXXX" Then
        Set xctrl = Global_AufrufCtrl
        Form_frm_DP_Dienstplan_MA.btnSta
    ElseIf x = "XXXfrm_DP_Dienstplan_ObjektXXX" Then
        Set xctrl = Global_AufrufCtrl
        Form_frm_DP_Dienstplan_Objekt.btnSta
    Else
        j = InStr(1, x, "!")
        y = Left(x, j - 1)
        z = Mid(x, j + 1)
        Set xFrm = Forms(y)
        Set xctrl = xFrm.Controls(z)
    End If
    xctrl.Value = Me!AktDat
    
    Set xctrl = Nothing
    Set xFrm = Nothing
End If

Global_iMinute = 0
Global_iStunde = 0
    
On Error Resume Next
    

End Sub

Private Sub Form_Open(Cancel As Integer)
Dim x As String, y As String, xctrl As control, xFrm As Form, i, j, k, z
Dim db As DAO.Database, Moonx
Me.SetFocus
xClose = True

Set Global_PrevCtrl = Me!btn1Tg34 'PreviousControl auf irgendwas setzen, damit es gesetzt ist

x = Trim(Nz(Get_Priv_Property("Default_Bundesland")))
If Len(x) = 0 Then
    y = Set_Priv_Property("Default_Bundesland", "BY")
    x = "BY"
End If
Me!cmbBundesland.defaultValue = Chr(34) & x & Chr(34)

'Das heutige Datum setzen
Me!Heutex.caption = Format(Date, """Heute ist: "" dddd   dd. mm ""(""mmmm"")""  yyyy"",   ""ww"". KW   ""y"". Tag""", vbMonday, vbFirstFourDays)

''Eines der kleinen 8 übernanderliegenden Mondphasenbilder sichtbar setzen
'Moonx = "Moon" & Mondphase()
'Me(Moonx).Visible = True

'Wenn Aufruf ohne OpenArgs dann ist es ein "normaler" Kalender

Global_iMinute = 0
Global_iStunde = 0

If Len(Trim(Nz(Me.OpenArgs))) = 0 Then
    Me!AktDat = Date
Else 'Andernfalls versuchen das Datum (aus dem Übergabefeld) zu übernehmen
    x = Me.OpenArgs
    If x = "XXXSubformXXX" Then
        Set xctrl = Global_AufrufCtrl
    ElseIf x = "XXXfrm_DP_Dienstplan_MAXXX" Then
        Set xctrl = Global_AufrufCtrl
    ElseIf x = "XXXfrm_DP_Dienstplan_ObjektXXX" Then
        Set xctrl = Global_AufrufCtrl
    Else
        j = InStr(1, x, "!")
        y = Left(x, j - 1)
        z = Mid(x, j + 1)
        Set xFrm = Forms(y)
        Set xctrl = xFrm.Controls(z)
    End If
    If Len(Trim(Nz(xctrl.Text))) > 0 Then
        Me!AktDat = CDate(xctrl.Text)
        If Not IsDate(Me!AktDat) Then
            Me!AktDat = Date
        Else
            Me!cboMinute = Format(Me!AktDat, "nn", 2, 2)
            Me!cboStunde = Format(Me!AktDat, "hh", 2, 2)
        
            Global_iMinute = Me!cboMinute
            Global_iStunde = Me!cboStunde
        
        End If
    Else
        Me!AktDat = Date
    End If
    Set xctrl = Nothing
End If
x = Datum_Neuaufbau(Me, Me!AktDat)

'Größe des Kalenders - mit / ohne Feiertagsanzeige
XHeight = Me.WindowHeight
x = Trim(Nz(Get_Priv_Property("Default_Feiertag")))
If Len(x) = 0 Then
    y = Set_Priv_Property("Default_Feiertag", True)
    x = True
End If
Me!JNFeiertag = x
If Me!JNFeiertag = "Wahr" Then
    Me!JNFeiertag = -1
ElseIf Me!JNFeiertag = "Falsch" Then
    Me!JNFeiertag = 0
End If
XSmall Me!JNFeiertag
End Sub

Function XSmall(XSmallX As Boolean)
'Feiertagsanzeige ein- ausschalten
Dim j, k, l
If XSmallX = False Then
    k = Me!Fei1.height
    l = XHeight - k - 80
    DoCmd.MoveSize , , , l
Else
    DoCmd.MoveSize , , , XHeight
End If
End Function

Private Sub JNFeiertag_AfterUpdate()
Dim y
y = Set_Priv_Property("Default_Feiertag", Me!JNFeiertag)
XSmall Me!JNFeiertag
End Sub
