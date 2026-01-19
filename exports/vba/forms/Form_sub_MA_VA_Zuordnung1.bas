VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_MA_VA_Zuordnung1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit



Private Function CharConv(strChar As String) As String
Dim strTmp As String

  strTmp = UCase(Left(strChar, 1))
  Select Case strTmp
    Case "Ä": strTmp = "A"
    Case "Ö": strTmp = "O"
    Case "Ü": strTmp = "U"
    Case "ß": strTmp = "S"
  End Select
  CharConv = strTmp
End Function


'Absprung ZUO_Stunden
Private Sub Bemerkungen_DblClick(Cancel As Integer)

'Dim frm As String
'    frm = "zfrm_ZUO_Stunden"
'
'    If TLookup("Anstellungsart_ID", MASTAMM, "ID = " & Me.MA_ID) = 11 Then 'Sub
'        DoCmd.OpenForm frm, , , "[MA_ID] = " & Me.MA_ID & " AND [VA_ID] = " & Me.VA_ID
'
'    Else
'        DoCmd.OpenForm frm, , , "[ZUO_ID] = " & Me.ID
'
'    End If
'
'    Forms(frm).Controls("Auto_Kopfzeile0").Caption = _
'        TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & " " & _
'        TLookup("Objekt", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & " " & _
'        TLookup("Ort", AUFTRAGSTAMM, "ID = " & Me.VA_ID) & ": " & _
'        TLookup("Nachname", MASTAMM, "ID = " & Me.MA_ID) & " " & _
'        TLookup("Vorname", MASTAMM, "ID = " & Me.MA_ID)

End Sub


Private Sub cboMA_Ausw_AfterUpdate()
Me!MA_ID = Me!cboMA_Ausw

Call fTag_Schicht_Update(Me!VADatum_ID, Me!VAStart_ID)
Me!cboMA_Ausw = 0

Start_End_Aend
End Sub


Private Sub cboMA_Ausw_KeyDown(KeyCode As Integer, Shift As Integer)
'Löschen der Zuodnung
'On Error Resume Next
If KeyCode = 46 Then
    Me!cboMA_Ausw = 0
    Me!MA_ID = 0
    Me!IstFraglich = 0
    DoCmd.RunCommand acCmdSaveRecord
    DoEvents
    KeyCode = 0
    Call fTag_Schicht_Update(Me!VADatum_ID, Me!VAStart_ID)
    Me.Recordset.MoveNext
    Start_End_Aend
End If
If KeyCode = 9 Or KeyCode = 13 Then
Me.Recordset.MoveNext

End If
End Sub


Private Sub Form_Current()
' Felder ausblenden wenn Veranstalter_ID = 20760 im Hauptformular
    
    On Error Resume Next
    
    Dim lngVeranstalterID As Long
    
    ' Veranstalter_ID aus Hauptformular holen
    If Not IsNull(Me.Parent![Veranstalter_ID]) Then
        lngVeranstalterID = Me.Parent![Veranstalter_ID]
    Else
        lngVeranstalterID = 0
    End If
    
    ' Felder ausblenden wenn Veranstalter_ID = 20760
    If lngVeranstalterID = 20760 Then
        Me![Einsatzleitung].Visible = False
        Me![PKW].Visible = False
    Else
        Me![Einsatzleitung].Visible = True
        Me![PKW].Visible = True
    End If
    
    On Error GoTo 0

End Sub


'Datensatz aus Zuordnung löschen?
Private Sub Form_Delete(Cancel As Integer)

Dim ZUO_ID As Long

    ZUO_ID = Me.ID
    TempVars!DEL_ZUO_ID = ZUO_ID
    
End Sub


'Datensatz aus Zuordnung löschen bestätigt?
Private Sub Form_AfterDelConfirm(Status As Integer)

Dim sql As String

    If Status = 0 Then 'Löschen bestätigt
        sql = "DELETE FROM " & ZUORDNUNG & " WHERE ID = " & TempVars!DEL_ZUO_ID
        CurrentDb.Execute sql
        sort_zuo_plan Me.VA_ID, Me.VADatum_ID, 1
    End If
    
    TempVars.Remove ("DEL_ZUO_ID")
    Me.Requery

End Sub


Private Sub Form_AfterUpdate()

Dim i As Long, j As Long, k As Long, m As Boolean

'PKW
i = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "PKW IS NOT NULL AND VA_ID = " & Me.Parent!ID & " AND VADatum_ID = " & Me.Parent.cboVADatum), 0)
'IST
j = Nz(TCount("*", "tbl_MA_VA_Zuordnung", "MA_ID > 0 AND VA_ID = " & Me.Parent!ID & " AND VADatum_ID = " & Me.Parent.cboVADatum), 0)
'Soll
k = Nz(TLookup("TVA_Soll", "tbl_VA_AnzTage", "ID = " & Me.Parent.cboVADatum), 0)
'TVA_Offen
m = Not (k > 0 And k <= j)

'AnzTage -> IST
CurrentDb.Execute ("UPDATE tbl_VA_AnzTage SET TVA_Ist = " & j & ", TVA_Offen = " & CLng(m) & ", tbl_VA_AnzTage.PKW_Anzahl = " & i & " WHERE (tbl_VA_AnzTage.ID = " & Me.Parent.cboVADatum & ");")

'AnzTage -> Soll (sinnfrei?)
Call VA_AnzTage_Upd(Me!VA_ID, Me!VADatum_ID)
'Call brutto_Std2_Berech
'If i > 0 Then
'    Me.Parent!PKW_Anzahl.Visible = True
'    Me!PKW_Anzahl = i
'    'Me.Parent!PKW_Anzahl.Requery
'End If

'Stunden- & Kostenberechnung -> hier nicht nötig
'Call calc_ZUO_Stunden(Me.ID, Nz(Me.MA_ID, 0), Me.VA_ID)

End Sub


Function reload()
    Form_Load
End Function


Private Sub Form_Load()

On Error GoTo Err

       
    'Verfügbarkeiten
    SysCmd acSysCmdInitMeter, "Bitte warten...", 100
    Me.VADatum_ID.RowSource = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID) = " & VA_ID & "));"
    Me.VAStart_ID.RowSource = "SELECT tbl_VA_Start.ID, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende FROM tbl_VA_Start WHERE (((tbl_VA_Start.VA_ID) = " & VA_ID & ")) ORDER BY VA_Start;"
    
    Call upd_Vergleichszeiten(Me.VA_ID, Me.MVA_Start, Me.MVA_Ende)
    
    SysCmd acSysCmdRemoveMeter
    
    
Exit Sub

Err:
'    if err.Number = ??? then
'        Resume Next
'    Else
'
'    End If
    
    Resume Next
    
End Sub


Private Sub Form_Open(Cancel As Integer)

Dim ctl As control
Dim fcd As FormatCondition

Dim i As Long, j As Long, k As Long, l As Long

Dim st As String
Dim st1 As String
Dim st2 As String

On Error Resume Next

Me.RowHeight = 270

Set ctl = Me("MA_ID")

With ctl.FormatConditions
  .Delete
  Set fcd = .Add(acExpression, , "[IstFraglich] = -1")
   fcd.backColor = Get_Priv_Property("prp_MA_Fraglich_Farbe")   ' türkisblau
  Set fcd = .Add(acExpression, , "[MA_ID].[column](8)=0")       ' Schrift Rot
   fcd.ForeColor = vbRed
End With
DoEvents


End Sub
Public Sub Brutto_Std2_berechnen_neu(MA_Brutto_Std2 As Single)

Dim dt As Date
Dim st As Date
Dim en As Date
Dim Min As Long
Dim std As Long
Dim sek As Long
dt = Me!sub_MA_VA_Zuordnung.VA_Datum
st = Me!sub_MA_VA_Zuordnung.MA_Start
en = Me!sub_MA_VA_Zuordnung.MA_Ende

'Zeit1 = "27.03.04 04:54:45"
'Zeit2 = "29.03.04 06:34:12"

MA_Brutto_Std2 = DateDiff("h", Me!sub_MA_VA_Zuordnung.MA_Start, Me!sub_MA_VA_Zuordnung.MA_Ende)

std = Int(sek / 3600)
Min = Int((sek - (std * 3600)) / 60)

End Sub

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
'   fcd.BackColor = 16766999  '' hellblau mit grünem Tatsch
'   fcd.BackColor = 111143 '' mittelgrün
'   fcd.BackColor = 130043 '' grelles hellgelb
'   fcd.BackColor = 127231 '' hellgelb
'   fcd.BackColor = 131043 '' helleres gelbrün
   fcd.backColor = 110043 '' helleres Kakibraun
 '  fcd.BackColor = 170343 '' Dunkles grün
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

' Alle Flächen ohne Projekt ausgrauen - Name
'####################################

   st1 = "_Zuo_ID"
   st2 = st & i & st1
   Set ctl = Me(st & i & "_Name")
    With ctl.FormatConditions
   Set fcd = .Add(acExpression, , "IsNull([" & st2 & "])")
   fcd.backColor = 14474460
   End With

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


'Mitarbeiterinfos aktualisieren
Private Sub Form_Query()
    Me.MA_ID.Requery
End Sub


'Detailansicht Stunden öffnen
Private Sub MA_Brutto_Std_DblClick(Cancel As Integer)

Dim frm As String
    frm = "zfrm_ZUO_Stunden_MA"

    If TLookup("Anstellungsart_ID", MASTAMM, "ID = " & Me.MA_ID) = 11 Then 'Sub
        'DoCmd.OpenForm frm, , , "[MA_ID] = " & Me.MA_ID & " AND [VA_ID] = " & Me.VA_ID

    Else
        'DoCmd.OpenForm frm, , , "[ZUO_ID] = " & Me.ID

    End If

End Sub


'Private Sub MA_ID_BeforeUpdate(Cancel As Integer)
'Dim bFehlerAnz As Boolean
'
'Dim i As Long
'Dim strSQL As String
'
'strSQL = ""
'strSQL = strSQL & "(ID = " & Me!VAStart_ID & ") AND (MA_ID = " & Nz(Me!MA_ID, 0) & ") AND (IstSubunternehmer = False)"
'
'i = Nz(TCount("*", "qry_Echtzeit_MA_VA_Vergleich_Alle", strSQL), 0)
'
'If i > 0 Then
'    DoCmd.OpenForm "frmTop_BereitsVerplant", , , , , acDialog, Me!MA_ID & ";" & Me!VAStart_ID
'    If GL_Verpl_Uebername = False Then
'        Cancel = True
'        Exit Sub
'    End If
'End If
'End Sub


Private Sub MA_Ende_AfterUpdate()
On Error Resume Next
    Start_End_Aend
    'Me.Recordset.MoveNext
    'Me!MA_Ende.DefaultValue = str(CDbl(Me!MA_Ende))
    'Me!MA_Ende.DefaultValue = Chr$(34) & Me!MA_Ende & Chr$(34)
    'Me!MA_Ende.DefaultValue = Me!MA_Ende
    Me.Recordset.MoveNext
End Sub


'NACH MITARBEITERAUSWAHL
Private Sub MA_ID_AfterUpdate()
           
    'Zeitpunkte rausnehmen (Bei Änderung des MA würde das nur verfälschen)
    Me.Anfragezeitpunkt = ""
    Me.Rueckmeldezeitpunkt = ""
    Me.IstFraglich = 0
'    If Not Me.Recordset.EOF Then Me.Recordset.MoveNext

    'Stunden & Kosten berechnen
    Call calc_ZUO_Stunden(Me.ID, Nz(Me.MA_ID, 0), Me.VA_ID)
    
    '34a bei Fussball
    If Me.Parent.Form.Controls("veranstalter_id") = 20771 Or Me.Parent.Form.Controls("veranstalter_id") = 20737 Then Call check_34a_fussball

End Sub

'Prüfung Lex_Aktiv Mitarbeiterstamm
Function fcnLexAktiv()

Dim rs As Recordset
    Set rs = Me.RecordsetClone
    rs.MoveFirst
    Do While Not rs.EOF
        Debug.Print Me.MA_ID
        rs.MoveNext
    Loop
    Set rs = Nothing
    
'    If TLookup("Lex_Aktiv", MASTAMM, "ID = " & Me.MA_ID) = False Then
'        Me.MA_ID.ForeColor = vbRed
'    Else
'        Me.MA_ID.ForeColor = vbBlack
'    End If
    
End Function

'Private Sub MA_ID_Enter()
'If Me.GotFocus Then
'Me!cboMA_Ausw.SetFocus
'End If
'End Sub

'Private Sub MA_ID_Click()
'Me!cboMA_Ausw.SetFocus
'If Me.Parent!Veranst_Status_ID < 3 Then
'    Me!cboMA_Ausw.Dropdown
'End If
'End Sub
'
'Private Sub MA_ID_Enter()
'Me!cboMA_Ausw.SetFocus
'If Me.Parent!Veranst_Status_ID < 3 Then
'    Me!cboMA_Ausw.Dropdown
'End If
'End Sub






Private Sub MA_ID_DblClick(Cancel As Integer)

'Dim iMA_ID As Long
'Dim i As Long
'
'iMA_ID = Nz(Me!MA_ID, 0)
'If iMA_ID = 0 Then Exit Sub
'
'    DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
'
'Form_frm_MA_Mitarbeiterstamm.Recordset.FindFirst "ID = " & iMA_ID
'
'Form_frm_VA_Auftragstamm.Painting = False
'
'    For i = 1 To Form_frm_MA_Mitarbeiterstamm!Lst_MA.ListCount
'        If Trim(Nz(Form_frm_MA_Mitarbeiterstamm!Lst_MA.Column(0, i))) = iMA_ID Then
'            Form_frm_MA_Mitarbeiterstamm!Lst_MA.selected(i) = True
'            Exit For
'        End If
'    Next i
'
'Form_frm_VA_Auftragstamm.Painting = True
'
'DoEvents
'DBEngine.Idle dbRefreshCache
'DBEngine.Idle dbFreeLocks
'DoEvents


End Sub

Private Sub MA_Start_AfterUpdate()
On Error Resume Next
    Start_End_Aend
    'If keycode = 9 Or keycode = 13 Then
    Me.Recordset.MoveNext
    'End If

End Sub


Function Start_End_Aend()

Dim bNSG As Boolean
Dim tempbis As Date

    'Kontrollfunktion Stunden -> MA_Start und MA_Ende nur Uhrzeit ohne Datum!!!
    If Len(Me.MA_Start) > 8 Then Me.MA_Start = Right(Me.MA_Start, 8)
    If Len(Me.MA_Ende) > 8 Then Me.MA_Ende = Right(Me.MA_Ende, 8)

    
    Me!VADatum = Me.Parent!cboVADatum.Column(1)
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
    
    'Details aktualisieren (Stunden)
    Call calc_ZUO_Stunden(Me.ID, Me.MA_ID, Me.VA_ID)

End Function

'Private Sub MA_Ende_KeyDown(KeyCode As Integer, Shift As Integer)
'DoCmd.Function brutto_Std2_Berech()
'End Sub
Function brutto_Std2_Berech() As Single
Dim h_start As Date, h_ende As Date, dtdat As Date

dtdat = Me!VADatum_ID.Column(1)
h_start = Me!MA_Start
h_ende = Me!MA_Ende

brutto_Std2_Berech = timeberech_G(dtdat, h_start, h_ende)
DoEvents

End Function
'
'Private Sub MA_Start_KeyDown(KeyCode As Integer, Shift As Integer)
'On Error Resume Next
'If KeyCode = 9 Or KeyCode = 13 Then
'Me.Recordset.MoveNext
'End If
'Start_End_Aend
'End Sub


Private Sub MA_Start_KeyDown(KeyCode As Integer, Shift As Integer)

'        If st <> "" Then Me!MA_Ende.SetFocus
Dim st As String

 If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        'KeyCode = 0
        st = Me!MA_Start.Text
        Select Case True
            Case Len(st) = 1 And IsNumeric(st) = False
                st = "00:00"
            Case Len(st) = 1 And IsNumeric(st)
                st = "0" & st & ":00"
            Case Len(st) = 2 And Right(st, 1) = ":"
                st = "0" & st & "00"
            Case Len(st) = 2
                st = st & ":00"
            Case Len(st) = 3 And Right(st, 1) = ":"
                st = st & "00"
                
            Case Len(st) = 4
                st = Left(st, 2) & ":" & Right(st, 2)
                
                
        End Select
        Me.MA_Start.Text = st
'        If st <> "" Then Me!MA_Ende.SetFocus
'
'
   End If



'Dim st
'Dim s As Long
'Dim m As Long
'Dim uz As Date
'
'    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
'        KeyCode = 0
'        st = Me!MA_Start.Text
'        If Not IsNumeric(st) Then Exit Sub
'        If Len(Trim(Nz(st))) < 3 Then
'            s = st
'            m = 0
'        Else
'            s = Left(st, 2)
'           m = Mid(st, 3)
'        End If
'        uz = CDate(TimeSerial(s, m, 0))
'        Me!MA_Start = uz
'    End If

End Sub

Private Sub MA_Ende_KeyDown(KeyCode As Integer, Shift As Integer)

Dim st As String

 If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        'KeyCode = 0
        st = Me!MA_Ende.Text
        Select Case True
            Case Len(st) = 1 And IsNumeric(st) = False
                st = "00:00"
            Case Len(st) = 1 And IsNumeric(st)
                st = "0" & st & ":00"
            Case Len(st) = 2 And Right(st, 1) = ":"
                st = "0" & st & "00"
            Case Len(st) = 2
                st = st & ":00"
            Case Len(st) = 3 And Right(st, 1) = ":"
                st = st & "00"
                
            Case Len(st) = 4
                st = Left(st, 2) & ":" & Right(st, 2)
                
                
        End Select
        Me.MA_Ende.Text = st
'        If st <> "" Then Me!MA_Ende.SetFocus
'
'
   End If


'Dim st
'Dim s As Long
'Dim m As Long
'Dim uz As Date
'
'    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
'        KeyCode = 0
'        st = Me!MA_Ende.Text
'        If Not IsNumeric(st) Then Exit Sub
'        If Len(Trim(Nz(st))) < 3 Then
'            s = st
'            m = 0
'        Else
'            s = Left(st, 2)
'            m = Mid(st, 3)
'        End If
'        uz = CDate(TimeSerial(s, m, 0))
'        Me!MA_Ende = uz
'    End If
'
'
End Sub


'Fahrtkosten & Anzahl PKW aktualisieren
Private Sub PKW_Anzahl_AfterUpdate()

On Error Resume Next

    DoCmd.RunCommand acCmdSaveRecord
    Me.Parent.Controls("PKW_Anzahl") = TSum("PKW_Anzahl", ZUORDNUNG, "VA_ID = " & Me.VA_ID)
    Me.Parent.Controls("lb_Fahrtkosten") = TSum("PKW", ZUORDNUNG, "VA_ID = " & Me.VA_ID) & " €"
    
End Sub


'Fahrtkosten & Anzahl PKW aktualisieren
Private Sub PKW_AfterUpdate()

On Error Resume Next

    'Wenn Fahrtkosten eingetragen werden -> Pkw nachziehen
    If Me.PKW_Anzahl = 0 And Me.PKW <> 0 Then Me.PKW_Anzahl = 1
    DoCmd.RunCommand acCmdSaveRecord

    Me.Parent.Controls("PKW_Anzahl") = TSum("PKW_Anzahl", ZUORDNUNG, "VA_ID = " & Me.VA_ID)
    Me.Parent.Controls("lb_Fahrtkosten") = TSum("PKW", ZUORDNUNG, "VA_ID = " & Me.VA_ID) & " €"
    
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

On Error Resume Next

        Me!Aend_am = Now()
        Me!Aend_von = Environ("UserName") 'atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
        
End Sub


'Stunden- & Kostenberechnung komplett
Function calc_ZUO_Stunden_all(Optional VAStart_ID As Long)

Dim rs      As Recordset
Dim MA_ID   As Long
Dim ZUO_ID  As Long
Dim VA_ID   As Long

    Set rs = Me.RecordsetClone
On Error Resume Next
    rs.MoveLast
    rs.MoveFirst
On Error GoTo 0
    Do While Not rs.EOF
        MA_ID = Nz(rs.fields("MA_ID"), 0)
        ZUO_ID = rs.fields("ID")
        VA_ID = rs.fields("VA_ID")
        If (VAStart_ID = 0 Or rs.fields("VAStart_ID") = VAStart_ID) And MA_ID <> 0 Then _
            Call calc_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID)
            'Debug.Print VAStart_ID & "  " & ZUO_ID & "  " & MA_ID
        rs.MoveNext
    Loop

End Function


'34a bei Fussball
Public Function check_34a_fussball()

    If TLookup("Hat_keine_34a", MASTAMM, "ID = " & Me.MA_ID) = False Then
        If Not IsNull(Me.Bemerkungen) Then
            If InStr(Me.Bemerkungen, "Service") = 0 Then Me.Bemerkungen = Me.Bemerkungen & " Service"
        Else
            Me.Bemerkungen = "Service"
        End If
    Else
        If Not IsNull(Me.Bemerkungen) Then Me.Bemerkungen = Replace(Me.Bemerkungen, "Service", "")
    End If

End Function

'


