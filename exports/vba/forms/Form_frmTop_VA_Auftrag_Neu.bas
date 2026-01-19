VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_VA_Auftrag_Neu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnDienstplan_MA_Click()
Dim s As String
Dim iVA_ID As Long
Dim dtDatum As Date

s = Me.Name

If Not fNeuAuftrag() Then Exit Sub
iVA_ID = Me!ID
dtDatum = Me!Dat_VA_Von
DoCmd.Close acForm, s, acSaveNo

Call Set_Priv_Property("prp_Dienstpl_StartDatum", dtDatum)
DoEvents
DoCmd.OpenForm "frm_DP_Dienstplan_MA"

End Sub

Private Sub Form_Open(Cancel As Integer)
Anz_CboKunde_AfterUpdate
DoEvents
Me!Dat_VA_Von.SetFocus
DoEvents
End Sub

Private Sub Anz_CboKunde_AfterUpdate()
Dim strSQL As String
Select Case Me!Anz_CboKunde
    Case 1
         Me!Veranstalter_ID.ColumnWidths = "0;3,5cm"
         strSQL = "SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Matchcode, tbl_KD_Kundenstamm.kun_Firma FROM tbl_KD_Kundenstamm WHERE (((tbl_KD_Kundenstamm.kun_AdressArt)=1) AND ((Len(Trim(Nz([kun_Matchcode]))))>0)) ORDER BY kun_Matchcode;"

    Case 2
         Me!Veranstalter_ID.ColumnWidths = "0;7,5cm"
         strSQL = "SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Kundenstamm.kun_Matchcode FROM tbl_KD_Kundenstamm WHERE (((tbl_KD_Kundenstamm.kun_AdressArt)=1) AND ((tbl_KD_Kundenstamm.kun_IstAktiv)=True)) ORDER BY kun_Firma;"

    Case Else
         Me!Veranstalter_ID.ColumnWidths = "0;7,5cm"
         strSQL = "SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundenstamm.kun_Firma, tbl_KD_Kundenstamm.kun_Matchcode FROM tbl_KD_Kundenstamm WHERE (((tbl_KD_Kundenstamm.kun_AdressArt)=1)) ORDER BY kun_Firma;"
End Select
Me!Veranstalter_ID.RowSource = strSQL

End Sub

Private Sub btnAngebot_Click()
Dim s As String
s = Me.Name
If Not fNeuAuftrag() Then Exit Sub
DoCmd.Close acForm, s, acSaveNo
End Sub

Private Sub btnAuftrag_Click()

Dim iVA_ID As Long
Dim iVADatum_ID As Long

Dim s As String
s = Me.Name

If Not fNeuAuftrag() Then Exit Sub
iVA_ID = Me!ID

'iVADatum_ID = Me!VADatum_ID
iVADatum_ID = TLookup("ID", "tbl_VA_AnzTage", "VADatum = " & SQLDatum(Me!Dat_VA_Von) & " AND VA_ID = " & iVA_ID)

DoCmd.Close acForm, s, acSaveNo
DoEvents
DoCmd.OpenForm "frm_VA_Auftragstamm"
DoEvents
Form_frm_VA_Auftragstamm.VADateSet (iVADatum_ID)

End Sub

Private Sub btnCancel_Click()
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub btnDienstplan_Click()
Dim s As String
Dim iVA_ID As Long
Dim dtDatum As Date

s = Me.Name

If Not fNeuAuftrag() Then Exit Sub
iVA_ID = Me!ID
dtDatum = Me!Dat_VA_Von
DoCmd.Close acForm, s, acSaveNo

Call Set_Priv_Property("prp_Dienstpl_StartDatum", dtDatum)
DoEvents
DoCmd.OpenForm "frm_DP_Dienstplan_Objekt"

End Sub

Private Sub btnMail_Click()
Dim s As String
s = Me.Name
If Not fNeuAuftrag() Then Exit Sub
DoCmd.Close acForm, s, acSaveNo
End Sub

Private Sub btnUebersicht_Click()
Dim s As String
s = Me.Name
If Not fNeuAuftrag() Then Exit Sub
DoCmd.Close acForm, s, acSaveNo
End Sub

Private Sub Dat_VA_Bis_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub

Private Sub Dat_VA_Bis_Exit(Cancel As Integer)
Dim strSQL As String

strSQL = "SELECT tbl_VA_Auftragstamm.Dat_VA_Von, fObjektOrt([Auftrag],[Ort],[Objekt]) AS ObjOrt FROM tbl_VA_Auftragstamm WHERE Dat_VA_Von Between " & SQLDatum(Me!Dat_VA_Von) & " and " & SQLDatum(Me!Dat_VA_Bis) & ";"

Me!ListeAuft.RowSource = strSQL

End Sub

Private Sub Dat_VA_Von_DblClick(Cancel As Integer)
Set Global_AufrufCtrl = Me.ActiveControl
DoCmd.OpenForm "_frmHlp_Kalender_3Mon", , , , , , "XXXSubformXXX"
End Sub


Private Sub Dat_VA_Von_Exit(Cancel As Integer)
Dim strSQL As String
If Len(Trim(Nz(Me!Dat_VA_Bis))) = 0 And Len(Trim(Nz(Me!Dat_VA_Von))) = 0 Then
    Exit Sub
ElseIf Len(Trim(Nz(Me!Dat_VA_Bis))) = 0 And Len(Trim(Nz(Me!Dat_VA_Von))) > 0 Then
    Me!Dat_VA_Bis = Me!Dat_VA_Von
End If

strSQL = "SELECT tbl_VA_Auftragstamm.Dat_VA_Von, fObjektOrt([Auftrag],[Ort],[Objekt]) AS ObjOrt FROM tbl_VA_Auftragstamm WHERE Dat_VA_Von Between " & SQLDatum(Me!Dat_VA_Von) & " and " & SQLDatum(Me!Dat_VA_Bis) & ";"

Me!ListeAuft.RowSource = strSQL

End Sub


Private Sub Zt1_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!Zt1.Text
        If Not IsNumeric(st) Then
            Me!ZtE1.SetFocus
            Exit Sub
        End If
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!Zt1 = uz
        Me!ZtE1.SetFocus
    End If

End Sub

Private Sub Zt2_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!Zt2.Text
        If Not IsNumeric(st) Then
            Me!ZtE2.SetFocus
            Exit Sub
        End If

        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!Zt2 = uz
        Me!ZtE2.SetFocus
 End If


End Sub

Private Sub Zt3_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!Zt3.Text
        If Not IsNumeric(st) Then
            Me!ZtE3.SetFocus
            Exit Sub
        End If
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!Zt3 = uz
        Me!ZtE3.SetFocus
    End If


End Sub

Private Sub ZtE1_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!ZtE1.Text
        If Not IsNumeric(st) Then
            Me!Anz2.SetFocus
            Exit Sub
        End If
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!ZtE1 = uz
        Me!Anz2.SetFocus
    End If

End Sub

Private Sub ZtE2_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!ZtE2.Text
        If Not IsNumeric(st) Then
            Me!Anz3.SetFocus
            Exit Sub
        End If

        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!ZtE2 = uz
        Me!Anz3.SetFocus
 End If


End Sub

Private Sub ZtE3_KeyDown(KeyCode As Integer, Shift As Integer)
Dim st
Dim s As Long
Dim m As Long
Dim uz As Date

    If KeyCode = vbKeyReturn Or KeyCode = vbKeyTab Then
        KeyCode = 0
        st = Me!ZtE3.Text
        If Not IsNumeric(st) Then
            Me!Veranst_Status_ID.SetFocus
            Exit Sub
        End If
        If Len(Trim(Nz(st))) < 3 Then
            s = st
            m = 0
        Else
            s = Left(st, 2)
            m = Mid(st, 3)
        End If
        uz = CDate(TimeSerial(s, m, 0))
        Me!ZtE3 = uz
        Me!Veranst_Status_ID.SetFocus
    End If


End Sub

Private Sub Objekt_Exit(Cancel As Integer)
Dim i As Long
If Len(Trim(Nz(Me!Objekt_ID))) = 0 Then
    i = Nz(TLookup("ID", "tbl_OB_Objekt", "Objekt = '" & Me!Objekt & "'"), 0)
    If i > 0 Then
        If vbOK = MsgBox("Objekt als Positionsliste verfügbar, zuordnen ?", vbQuestion + vbOKCancel, Me!Objekt) Then
            Me!Objekt_ID = i
            Objekt_ID_AfterUpdate
        End If
    End If
End If
End Sub

Private Sub Objekt_ID_AfterUpdate()
Dim strSQL As String

Me!Objekt_ID.backColor = 11063436

DoCmd.RunCommand acCmdSaveRecord
DoEvents

End Sub

Function fNeuAuftrag() As Boolean

Dim strSQL As String
Dim iID As Long
Dim AnzArr(2) As Long
Dim ZtArr(2) As Date
Dim ZtEndArr(2) As Variant
Dim i As Long, j As Long
Dim iArr As Long
Dim iAnzTage As Long
Dim VADatum_ID As Long
Dim Datakt As Date

fNeuAuftrag = False

If Len(Trim(Nz(Me!Dat_VA_Von))) = 0 Then
    MsgBox "Bitte von und bis Datum eingeben"
    Exit Function
End If
If Len(Trim(Nz(Me!Auftrag))) = 0 Then
    MsgBox "Bitte Auftrag eingeben"
    Exit Function
End If
If Len(Trim(Nz(Me!Ort))) = 0 And Len(Trim(Nz(Me!Objekt))) = 0 Then
    MsgBox "Bitte entweder Ort oder Objekt eingeben"
    Exit Function
End If
If Len(Trim(Nz(Me!Veranstalter_ID))) = 0 Or Me!Veranstalter_ID = 0 Then
    MsgBox "Bitte Auftraggeber eingeben"
    Exit Function
End If
If Len(Trim(Nz(Me!Anz1))) > 0 And Len(Trim(Nz(Me!Zt1))) = 0 Then
    MsgBox "Anzahl1: Wenn Personenanzahl > 0, dann bitte auch eine Startzeit festlegen"
    Exit Function
End If
If Len(Trim(Nz(Me!Anz2))) > 0 And Len(Trim(Nz(Me!Zt2))) = 0 Then
    MsgBox "Anzahl2: Wenn Personenanzahl > 0, dann bitte auch eine Startzeit festlegen"
    Exit Function
End If
If Len(Trim(Nz(Me!Anz3))) > 0 And Len(Trim(Nz(Me!Zt3))) = 0 Then
    MsgBox "Anzahl3: Wenn Personenanzahl > 0, dann bitte auch eine Startzeit festlegen"
    Exit Function
End If

'###### SO jetzt kanns losgehen mit denm speichern

strSQL = ""
strSQL = strSQL & "INSERT INTO tbl_VA_Auftragstamm (Dat_VA_Von, Dat_VA_Bis, Auftrag, Objekt, Objekt_ID, Ort, Veranstalter_ID, Bemerkungen, Veranst_Status_ID)"
strSQL = strSQL & " SELECT " & SQLDatum(Me!Dat_VA_Von) & " AS A1, " & SQLDatum(Me!Dat_VA_Bis) & " As A2, '" & Me!Auftrag & "' As A3, '" & Nz(Me!Objekt) & "' As A4, "
strSQL = strSQL & IIf(Nz(Me!Objekt_ID, 0) > 0, Me!Objekt_ID, 0) & ", '" & Nz(Me!Ort) & "' As A6, "
strSQL = strSQL & Me!Veranstalter_ID & " As A7, '" & Nz(Me!Bemerkungen) & "' As A8, " & Me!Veranst_Status_ID & " As A9 FROM _tblInternalSystemFE;"
CurrentDb.Execute (strSQL)
DoEvents
Me!ID = TMax("ID", "tbl_VA_Auftragstamm")
DoEvents
iAnzTage = fAnzTage_Crea
iArr = -1
For i = 0 To 2
    If Len(Trim(Nz(Me("Anz" & i + 1)))) > 0 Then
        If Me("Anz" & i + 1) > 0 Then
            AnzArr(i) = Me("Anz" & i + 1)
            ZtArr(i) = Me("Zt" & i + 1)
            If Len(Trim(Nz(Me("ZtE" & i + 1)))) > 0 Then
                ZtEndArr(i) = Me("ZtE" & i + 1)
            Else
                ZtEndArr(i) = Null
            End If
            iArr = iArr + 1
        End If
    End If
Next i
If iArr > -1 Then
    For j = 0 To iAnzTage
        Datakt = Me!Dat_VA_Von + j
        VADatum_ID = Nz(TLookup("ID", "tbl_VA_AnzTage", "VA_ID = " & Me!ID & " AND VADatum = " & SQLDatum(Datakt)), 0)
        For i = 0 To iArr
            If AnzArr(i) > 0 Then
                strSQL = ""
                strSQL = strSQL & "INSERT INTO tbl_VA_Start ( VA_ID, VADatum_ID, MA_Anzahl, VA_Start, VaDatum, MVA_Start"
                If Len(Trim(Nz(ZtEndArr(i)))) > 0 Then
                    strSQL = strSQL & ", VA_Ende, MVA_Ende)"
                Else
                    strSQL = strSQL & ")"
                End If
                strSQL = strSQL & " SELECT " & Me!ID & " As A1, " & VADatum_ID & " As A2, " & AnzArr(i) & " AS A3, " & DateTimeForSQL(TimeSerial(Hour(ZtArr(i)), minute(ZtArr(i)), 0))
                strSQL = strSQL & " As A4, " & SQLDatum(Datakt) & " AS A5, " & DateTimeForSQL(Startzeit_G(Datakt, TimeSerial(Hour(ZtArr(i)), minute(ZtArr(i)), 0)))
                strSQL = strSQL & " As A6 "
                If Len(Trim(Nz(ZtEndArr(i)))) > 0 Then
                    strSQL = strSQL & ", " & DateTimeForSQL(TimeSerial(Hour(ZtEndArr(i)), minute(ZtEndArr(i)), 0)) & " AS A7"
                    strSQL = strSQL & ", " & DateTimeForSQL(Endezeit_G(Datakt, TimeSerial(Hour(ZtArr(i)), minute(ZtArr(i)), 0), TimeSerial(Hour(ZtEndArr(i)), minute(ZtEndArr(i)), 0))) & " AS A8"
                End If
                strSQL = strSQL & " FROM _tblInternalSystemFE;"
                CurrentDb.Execute (strSQL)
                strSQL = ""
            End If
        Next i
        Zuord_Fill VADatum_ID, Me!ID
    Next j
End If
DoEvents

fNeuAuftrag = True

End Function


Function fAnzTage_Crea() As Long

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long, iAnz As Long
Dim dtdat As Date
Dim strSQL As String

strSQL = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID)= " & Me!ID & "));"

If Len(Trim(Nz(Me!Dat_VA_Bis))) = 0 Then
    Me!Dat_VA_Bis = Me!Dat_VA_Von
End If
If Not (IsDate(Me!Dat_VA_Von) Or IsDate(Me!Dat_VA_Bis)) Then
    MsgBox "Bitte berichtigen Sie das Datum"
    Exit Function
End If
If Me!Dat_VA_Bis < Me!Dat_VA_Von Then
    MsgBox "Bitte berichtigen Sie die Datumsreihenfolge - Bis < Von"
    Me!Dat_VA_Bis = Null
    Me!Dat_VA_Bis.SetFocus
    Exit Function
End If
'CurrentDb.Execute ("DELETE * FROM tbl_VA_AnzTage WHERE VA_ID = " & Me!ID & ";")
DoEvents
iAnz = Fix(Me!Dat_VA_Bis) - Fix(Me!Dat_VA_Von)

dtdat = Fix(Me!Dat_VA_Von)
Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT top 1 * FROM tbl_VA_AnzTage;")
With rst
    For i = 0 To iAnz
        .AddNew
            .fields(1).Value = Me!ID
            .fields(2).Value = dtdat
            dtdat = dtdat + 1
On Error Resume Next
        .update
Err.clear
On Error GoTo 0
    Next i
    .Close
End With
Set rst = Nothing
fAnzTage_Crea = iAnz
End Function
