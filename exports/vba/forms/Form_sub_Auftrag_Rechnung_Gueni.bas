VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_Auftrag_Rechnung_Gueni"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Dim Auftrag_aktuell As String

'Stundenliste Auftrag
Private Sub btnStdListe_Click()

    Call Stundenliste_erstellen(Me.VA_ID, Me.MA_ID)
    
End Sub


'Rechnung freigeben
Private Sub btnFreigeben_Click()

Dim rechid          As Long
Dim IstBezahlt      As Boolean

    rechid = Nz(Me.Rch_ID, 0)
    
    If Not IsInitial(rechid) Then
        IstBezahlt = TLookup("IstBezahlt", RCHKOPF, "ID = " & rechid)
        
        If IstBezahlt = True Then
            If MsgBox("Freigabe wirklich zurücknehmen?", vbYesNo) = vbYes Then
                TUpdate "IstBezahlt = False", RCHKOPF, "ID = " & rechid
                TUpdate "Aend_von = Null", RCHKOPF, "ID = " & rechid
                TUpdate "Zahlung_am = Null", RCHKOPF, "ID = " & rechid
                
            End If
            
        Else
            Call Rch_freigeben(Rech_ID)
            
        End If
    
    End If
    
    Me.Requery
    
End Sub


'Rechnung anlegen
Private Sub btnRchAnlegen_Click()

Dim rechid          As Long
Dim RechNr          As String
Dim Criteria        As String
Dim sql             As String

    rechid = Nz(Me.Rch_ID, 0)
    
    If Not IsInitial(rechid) And Not IsInitial(Me.Rch_Nr) Then
        If MsgBox("Rechnungsnummer bereits vorhanden! Ersetzen?", vbYesNo) <> vbYes Then Exit Sub
    End If

    RechNr = InputBox("Rechnungsnummer: ", "Rechnungsnummer eingeben")
    
    If Not IsInitial(RechNr) Then
        If IsInitial(rechid) Then
            sql = "INSERT INTO " & RCHKOPF & "(MA_ID,VA_ID,RchNr_Ext,RchTyp,Erst_von,Erst_am,Auftrag) VALUES (" & _
                Me.MA_ID & "," & Me.VA_ID & ",'" & RechNr & "',8,'" & Environ("UserName") & "'," & datumSQL(Now) & ",'" & Auftrag & "')"
            CurrentDb.Execute sql
            
        Else
            DoEvents
            DBEngine.Idle dbRefreshCache
            DBEngine.Idle dbFreeLocks
            DoEvents
            TUpdate "RchNr_Ext = '" & RechNr & "'", RCHKOPF, "ID = " & rechid
            
        End If
    End If
    
End Sub



'Status ändern
Private Sub cboChangeStatus_AfterUpdate()
    
    'Rechnung vorhanden? -> ggf anlegen
    If IsInitial(Me.Rch_ID) Then Call btnRchAnlegen_Click
    
    'Rechnung vorhanden? -> anpassen
    If Not IsInitial(Me.Rch_ID) Then
        
        Select Case Me.cboChangeStatus
            Case 1
                'Ungeprüft
                If Me.Rch_Status_ID > 1 Then
                    If MsgBox("Status zurücksetzen?", vbYesNo) = vbYes Then Call Rch_ruecksetzen(Me.Rch_ID)
                End If
                
            Case 2
                'Reklamiert
                Call Rch_reklamieren(Me.Rch_ID)
        
            Case 3
                'Freigegeben
                Call Rch_freigeben(Me.Rch_ID)
                'Call Rch_bezahlt(Me.Rch_ID)
                
        End Select
        
        
    End If
    
    Auftrag_aktuell = Me.Auftrag
    Call requery_Auftrag_Rech
    
End Sub


'Neuer Datensatz markiert ->Anpassung Details subZUOStunden
Private Sub Form_Current()
Static VA_ID

Dim sql         As String
Dim SQLINS      As String
Dim WHERE       As String
Dim rs          As Recordset
Dim rechid      As Long

On Error Resume Next
    
    sql = "SELECT ZUO_ID, VADatum, Name, von, bis, Stunden, Nacht, Sonntag, Feiertag, PKW FROM zqry_ZUO_Stunden_Sub_lb"

    If Not IsInitial(Me.VA_ID) Then
        WHERE = "MA_ID = " & Me.Parent.Controls("ID") & " AND VA_ID = " & Me.VA_ID
        
        If Me.VA_ID <> VA_ID And Auftrag_aktuell = "" Then
            If Auftrag_aktuell = "" Then Auftrag_aktuell = Me.Auftrag
            Me.Parent.Form.Painting = False
            
            If IsInitial(Me.Rch_ID) Then
                SQLINS = "INSERT INTO " & RCHKOPF & "(MA_ID,VA_ID,RchTyp,Erst_von,Erst_am,Auftrag) VALUES (" & _
                    Me.MA_ID & "," & Me.VA_ID & ",8,'" & Environ("UserName") & "'," & datumSQL(Now) & ",'" & Auftrag & "')"
                CurrentDb.Execute SQLINS
                rechid = TLookup("ID", RCHKOPF, WHERE)
            Else
                rechid = Me.Rch_ID
            End If

            Me.cboChangeStatus = TLookup("Rch_Status_ID", RCHKOPF, "ID = " & rechid)
            Me.Parent.subZuoStunden.Form.Controls("lstDetails").RowSource = sql & " WHERE " & WHERE
            Me.Parent.subZuoStunden.Form.Controls("lbAuftrag").caption = Me.Auftrag & " " & Me.Objekt & " " & Me.Ort
         
            Call Me.Parent.subZuoStunden.Form.neuberechnen(WHERE, rechid)
            Me.cboChangeStatus = Me.Rch_Status_ID
            VA_ID = Me.VA_ID
'            Me.requery
'            If Auftrag_aktuell <> "" Then
'                Me.Auftrag.SetFocus
'                DoCmd.FindRecord Auftrag_aktuell
'                Auftrag_aktuell = ""
'            End If
            Call requery_Auftrag_Rech
            Me.Parent.Form.Painting = True
        End If
        Me.Parent.subZuoStunden.Form.Controls("lstDetails").RowSource = sql & " WHERE " & WHERE
        Me.Parent.subZuoStunden.Form.Controls("lbAuftrag").caption = Me.Auftrag & " " & Me.Objekt & " " & Me.Ort
        Call Me.Parent.subZuoStunden.Form.neuberechnen(WHERE)
    End If
    
    Me.Parent.Form.Painting = True
    
End Sub

'requery (Bookmark erhalten)
Function requery_Auftrag_Rech()

Dim actcontrol As String

On Error Resume Next
    actcontrol = Screen.ActiveForm.ActiveControl.Form.Name
On Error GoTo 0

    If Me.Parent.Controls("reg_ma") = 12 And actcontrol = "sub_Auftrag_Rechnung_Gueni" Then
        Me.Requery
        If Auftrag_aktuell <> "" Then
            Me.Auftrag.SetFocus
            DoCmd.FindRecord Auftrag_aktuell
            Auftrag_aktuell = ""
            actcontrol = ""
        End If
    Else
        Auftrag_aktuell = ""
    End If
    
End Function


'Rechnung öffnen / hinterlegen
Private Sub Rch_Nr_DblClick(Cancel As Integer)

Dim RchDatei As String

    If Not IsInitial(Me.Rch_ID) And Not IsInitial(Me.Rch_Nr) Then
        RchDatei = Nz(TLookup("Dateiname", RCHKOPF, "ID = " & Me.Rch_ID), 0)
        
        If Not IsInitial(RchDatei) Then
            Application.FollowHyperlink RchDatei
            
        Else
            RchDatei = Dateiauswahl("Rechnung auswählen", "*.pdf,*.doc,*.docx", CONSYS & "CONSEC\CONSEC PLANUNG AKTUELL\A  - Eingangsrechnungen\")
            If RchDatei <> "" Then TUpdate "Dateiname = '" & RchDatei & "'", RCHKOPF, "ID = " & Me.Rch_ID
        
        End If
        
    Else
        'If MsgBox("Rechnung existiert noch nicht! Anlegen?", vbYesNo) = vbYes Then
            Call btnRchAnlegen_Click
            Auftrag_aktuell = Me.Auftrag
            Call requery_Auftrag_Rech
            
        'Else
            'Exit Sub
        
        'End If
    End If

End Sub

'Rechnung reklamieren
Function Rch_reklamieren(ByVal Rech_ID As Long)

    'TUpdate "IstBezahlt = True", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Aend_von = '" & Environ("UserName") & "'", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Aend_am = " & datumSQL(Now), RCHKOPF, "ID = " & Rech_ID
    TUpdate "Zahlung_am = Null", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Rch_Status_ID = " & Me.cboChangeStatus, RCHKOPF, "ID = " & Rech_ID
    
End Function

'Rechnung freigeben
Function Rch_freigeben(ByVal Rech_ID As Long)

    'TUpdate "IstBezahlt = True", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Aend_von = '" & Environ("UserName") & "'", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Aend_am = " & datumSQL(Now), RCHKOPF, "ID = " & Rech_ID
    TUpdate "Zahlung_am = Null", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Rch_Status_ID = " & Me.cboChangeStatus, RCHKOPF, "ID = " & Rech_ID

End Function

'Rechnung bezahlt markieren
Function Rch_bezahlt(ByVal Rech_ID As Long)

    'TUpdate "IstBezahlt = True", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Aend_von = '" & Environ("UserName") & "'", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Aend_am = " & datumSQL(Now), RCHKOPF, "ID = " & Rech_ID
    TUpdate "Zahlung_am = Null", RCHKOPF, "ID = " & Rech_ID
    'TUpdate "Zahlung_am = " & DatumSQL(Now), RCHKOPF, "ID = " & Rech_ID
    'TUpdate "Rch_Status_ID = " & Me.cboChangeStatus, RCHKOPF, "ID = " & Me.Rch_ID
    
End Function

'Rechnung ungeprüft
Function Rch_ruecksetzen(ByVal Rech_ID As Long)

    TUpdate "IstBezahlt = False", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Aend_von = '" & Environ("UserName") & "'", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Zahlung_am = Null", RCHKOPF, "ID = " & Rech_ID
    TUpdate "Rch_Status_ID = " & Me.cboChangeStatus, RCHKOPF, "ID = " & Me.Rch_ID
    
End Function

'Rechnungsnummer korrigieren mit Taste ESC
Private Sub Rch_Nr_KeyPress(KeyAscii As Integer)

    If KeyAscii = 27 Then
        Call btnRchAnlegen_Click
        Me.Requery
    End If

End Sub
