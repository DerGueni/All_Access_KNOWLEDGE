# frm_Zeiterfassung

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Zeiterfassung |
| **Datensatzquelle** | - |
| **Default View** | SingleForm |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Nein |
| **Data Entry** | Ja |
| **Navigation Buttons** | Nein |

## Controls


### ComboBoxen (Auswahllisten)

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------|
| cmbEinsatz | - | 3005 / 795 | 12462 x 435 | 0 |

### Buttons (Schaltflaechen)

| Name | Caption | Position (L/T) | Groesse (W/H) | Events |
|------|---------|----------------|---------------|--------|
| btnCheckIn | Einchecken | 1860 / 3525 | 1371 x 283 | OnClick: [Event Procedure] |
| btnChangeZuo | Ändern | 3405 / 3525 | 1086 x 283 | OnClick: [Event Procedure] |
| btnDeleteCheckIn | Löschen | 11625 / 3525 | 1086 x 283 | OnClick: [Event Procedure] |
| btnCheckOut | Auschecken | 8325 / 3525 | 1371 x 283 | OnClick: [Event Procedure] |
| btnChangeIn | Ändern | 9870 / 3525 | 1086 x 283 | OnClick: [Event Procedure] |
| btnDeleteCheckOut | Löschen | 17746 / 3514 | 1086 x 283 | OnClick: [Event Procedure] |
| btnChangeOut | Ändern | 15363 / 3514 | 1086 x 283 | OnClick: [Event Procedure] |
### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------||
| Bezeichnungsfeld3 | 3005 / 113 | 12462 x 524 | 0 (Schwarz) |
| Bezeichnungsfeld5 | 1020 / 795 | 1935 x 300 | 0 (Schwarz) |
| Bezeichnungsfeld7 | 570 / 2610 | 2145 x 780 | 0 (Schwarz) |
| lblStatus | 3005 / 2085 | 12462 x 401 | 32768 (Unbekannt) |
| Bezeichnungsfeld14 | 1020 / 1425 | 690 x 315 | 0 (Schwarz) |
| lbCheckedIn | 6690 / 3525 | 1467 x 315 | -2147483617 (Unbekannt) |
| lbCheckedOut | 12810 / 3525 | 1587 x 315 | -2147483617 (Unbekannt) |
| lbZuo | 570 / 3525 | 1185 x 315 | -2147483617 (Unbekannt) |

### ListBoxs

| Name | Caption | Position (L/T) | Groesse (W/H) |
|------|---------|----------------|---------------|
| lstCheckedIn | - | 6690 / 3865 | 6012 x 6292 |
| lstCheckedOut | - | 12810 / 3865 | 6012 x 6292 |
| lstZuo | - | 570 / 3865 | 6012 x 6292 |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------||
| txtQRScan | - | 3005 / 2610 | 1751 x 675 | 1 |
| lblAusgewaehlterAuftrag | - | 3005 / 1425 | 12462 x 390 | 2 |

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: Keine
- OnClose: Keine
- OnCurrent: [Event Procedure]
- BeforeUpdate: Keine
- AfterUpdate: Keine
- OnActivate: Keine
- OnDeactivate: Keine

## VBA-Code

```vba
Option Explicit


' Ändern Zuo
Private Sub btnChangeZuo_Click()

Dim ZUO_ID As Long

    ZUO_ID = Nz(Me.lstZuo.Column(0), 0)
    
    If IsInitial(ZUO_ID) Then
        MsgBox "Kein Datensatz markiert!", vbCritical
        Exit Sub
    End If
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", ZUO_ID)
    
    Call MA_Zeiterfassung_popup(0, 0, 0, ZUO_ID)
    
    Call listBox_requery
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", 0)
    
End Sub


' Ändern CheckIN
Private Sub btnChangeIn_Click()

Dim ZUO_ID As Long

    ZUO_ID = Nz(Me.lstCheckedIn.Column(0), 0)
    
    If IsInitial(ZUO_ID) Then
        MsgBox "Kein Datensatz markiert!", vbCritical
        Exit Sub
    End If
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", ZUO_ID)
    
    Call MA_Zeiterfassung_popup(0, 0, 0, ZUO_ID)
    
    Call listBox_requery
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", 0)
    
End Sub


'Ändern CheckOUT
Private Sub btnChangeOut_Click()

Dim ZUO_ID As Long

    ZUO_ID = Nz(Me.lstCheckedOut.Column(0), 0)
    
    If IsInitial(ZUO_ID) Then
        MsgBox "Kein Datensatz markiert!", vbCritical
        Exit Sub
    End If
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", ZUO_ID)
    
    Call MA_Zeiterfassung_popup(0, 0, 0, ZUO_ID)
    
    Call listBox_requery
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", 0)
    
End Sub


'Einchecken
Private Sub btnCheckIn_Click()

Dim ZUO_ID As Long
Dim MA_ID As Long

    ZUO_ID = Nz(Me.lstZuo.Column(0), 0)
    MA_ID = Nz(Me.lstZuo.Column(1), 0)
    
    If IsInitial(ZUO_ID) Then
        MsgBox "Kein Datensatz markiert!", vbCritical
        Exit Sub
    End If
    
    Call MA_Zeiterfassung(MA_ID, ZUO_ID)
    
    Call listBox_requery

End Sub


'Auschecken
Private Sub btnCheckOut_Click()

Dim ZUO_ID As Long
Dim MA_ID As Long

    ZUO_ID = Nz(Me.lstCheckedIn.Column(0), 0)
    MA_ID = Nz(Me.lstCheckedIn.Column(1), 0)
    
    If IsInitial(ZUO_ID) Then
        MsgBox "Kein Datensatz markiert!", vbCritical
        Exit Sub
    End If
    
    Call MA_Zeiterfassung(MA_ID, ZUO_ID)
    
    Call listBox_requery

End Sub


'Check-In löschen
Private Sub btnDeleteCheckIn_Click()

Dim ZUO_ID     As Long

    ZUO_ID = Nz(Me.lstCheckedIn.Column(0), 0)
    
    If IsInitial(ZUO_ID) Then
        MsgBox "Kein Datensatz markiert!", vbCritical
        Exit Sub
    End If
    
    'geplant oder ungeplant?
    If TLookup("ungeplant", "tbl_Zeiterfassung", "ZUO_ID=" & ZUO_ID) = True Then
        CurrentDb.Execute "DELETE FROM " & ZUORDNUNG & " WHERE ID=" & ZUO_ID
    
    Else
        CurrentDb.Execute "UPDATE " & ZUORDNUNG & " SET MA_Start=" & UhrzeitSQL(TLookup("MA_Start", "tbl_Zeiterfassung", "ZUO_ID=" & ZUO_ID))
        CurrentDb.Execute "UPDATE " & ZUORDNUNG & " SET MVA_Start=" & DatumUhrzeitSQL(TLookup("MVA_Start", "tbl_Zeiterfassung", "ZUO_ID=" & ZUO_ID))
    
    End If
    
    CurrentDb.Execute "DELETE FROM tbl_Zeiterfassung WHERE ZUO_ID=" & ZUO_ID

    Call listBox_requery
    
End Sub


'Check-Out löschen
Private Sub btnDeleteCheckOut_Click()

Dim ZUO_ID   As Long
Dim MA_Ende  As Date
Dim MVA_Ende As Date

    ZUO_ID = Nz(Me.lstCheckedOut.Column(0), 0)
    
    If IsInitial(ZUO_ID) Then
        MsgBox "Kein Datensatz markiert!", vbCritical
        Exit Sub
    End If
    
    MA_Ende = Nz(TLookup("MA_Ende", "tbl_Zeiterfassung", "ZUO_ID=" & ZUO_ID), 0)
    MVA_Ende = Nz(TLookup("MVA_Ende", "tbl_Zeiterfassung", "ZUO_ID=" & ZUO_ID), 0)
    
    If Not IsInitial(MA_Ende) Then
        CurrentDb.Execute "UPDATE " & ZUORDNUNG & " SET MA_Ende=" & UhrzeitSQL(MA_Ende)
    Else
        CurrentDb.Execute "UPDATE " & ZUORDNUNG & " SET MA_Ende=Null"
    End If
    
    If Not IsInitial(MVA_Ende) Then
        CurrentDb.Execute "UPDATE " & ZUORDNUNG & " SET MVA_Ende=" & DatumUhrzeitSQL(MVA_Ende)
    Else
        CurrentDb.Execute "UPDATE " & ZUORDNUNG & " SET MVA_Ende=Null"
    End If

    
    CurrentDb.Execute "UPDATE tbl_Zeiterfassung SET CheckOut_Zeit=Null WHERE ZUO_ID=" & ZUO_ID
    CurrentDb.Execute "UPDATE tbl_Zeiterfassung SET CheckOut_Original=Null WHERE ZUO_ID=" & ZUO_ID

    Call listBox_requery
        
End Sub


Private Sub cmbEinsatz_AfterUpdate()

Dim sqlZuo As String

    If Not IsNull(Me.cmbEinsatz.Value) Then
        ' Column(0) = Datum
        ' Column(1) = Auftrag
        ' Column(2) = Ort
        ' Column(3) = Objekt
        ' Column(4) = ID (VA_ID)
        ' Column(5) = VADatum_ID
        
        Me.lblAusgewaehlterAuftrag = Me.cmbEinsatz.Column(0) & " " & _
                                      Me.cmbEinsatz.Column(1) & " " & _
                                      Me.cmbEinsatz.Column(2) & " " & _
                                      Me.cmbEinsatz.Column(3)
        
        Me.lblAusgewaehlterAuftrag.ForeColor = RGB(0, 128, 0)
    Else
        Me.lblAusgewaehlterAuftrag = "Auftrag: (noch nicht ausgewählt)"
        Me.lblAusgewaehlterAuftrag.ForeColor = RGB(128, 128, 128)
    End If
    Me.txtQRScan.SetFocus
    Me.lblStatus.caption = "Einsatz ausgewählt - bereit für Scan!"
    Me.lblStatus.ForeColor = RGB(0, 128, 0)
    
    Call listBox_requery
    
End Sub


Private Sub ZeigeErfolg(nachricht As String)
    ' Zeigt grünen Haken für 1 Sekunde
    On Error Resume Next
    
    With Me
        ' Sound
        Beep
        
        ' Bild anzeigen
        '.imgErfolg.Visible = True
        '.imgFehler.Visible = False
        
        ' Status-Text
        .lblStatus.caption = nachricht
        .lblStatus.ForeColor = RGB(0, 128, 0) ' Grün
        .lblStatus.Visible = True
        
        ' Timer starten für automatisches Ausblenden
        '.TimerInterval = 1500 ' x Sekunden
        .txtQRScan = ""
        .txtQRScan.SetFocus
        
    End With
End Sub

Private Sub ZeigeFehler(nachricht As String)
    ' Zeigt rotes X (muss weggeklickt werden)
    On Error Resume Next
    
    With Me
        ' Fehler-Sound (doppelter Beep)
        Beep
        DoEvents
        Beep
        
        ' Bild anzeigen
        '.imgFehler.Visible = True
        '.imgErfolg.Visible = False
        
        ' Status-Text
        .lblStatus.caption = nachricht
        .lblStatus.ForeColor = RGB(255, 0, 0) ' Rot
        .lblStatus.Visible = True
        
        ' Kein Timer - muss manuell geschlossen werden
        '.TimerInterval = 0
        .txtQRScan = ""
        .txtQRScan.SetFocus
        
    End With
End Sub

Private Sub Form_Current()
    With Me
        .txtQRScan = ""
        .txtQRScan.SetFocus
    
    End With
        
End Sub

' ==========================================
' ALTERNATIVE: LABEL-BASIERTES SYSTEM
' ==========================================

' Falls Sie keine Bilder verwenden möchten:

Private Sub ZeigeErfolgMitLabel(nachricht As String)
    ' Alternative mit Label statt Bild
    On Error Resume Next
    
    With Forms!frm_Zeiterfassung_QR
        ' Sound
        Beep
        
        ' Label konfigurieren
        .lblSymbol.caption = "?"
        .lblSymbol.FontSize = 72
        .lblSymbol.ForeColor = RGB(0, 255, 0)
        .lblSymbol.BackStyle = 1 ' Nicht transparent
        .lblSymbol.BackColor = RGB(240, 255, 240)
        .lblSymbol.BorderStyle = 1
        .lblSymbol.BorderColor = RGB(0, 128, 0)
        .lblSymbol.TextAlign = 2 ' Zentriert
        .lblSymbol.Visible = True
        
        ' Status
        .lblStatus.caption = nachricht
        .lblStatus.ForeColor = RGB(0, 128, 0)
        .lblStatus.Visible = True
        
        ' Timer
        .TimerInterval = 5000
    End With
End Sub

Private Sub ZeigeFehlerMitLabel(nachricht As String)
    ' Alternative mit Label statt Bild
    On Error Resume Next
    
    With Forms!frm_Zeiterfassung_QR
        ' Fehler-Sound
Beep:         DoEvents: Beep
        
        ' Label konfigurieren
        .lblSymbol.caption = "?"
        .lblSymbol.FontSize = 72
        .lblSymbol.ForeColor = RGB(255, 0, 0)
        .lblSymbol.BackStyle = 1
        .lblSymbol.BackColor = RGB(255, 240, 240)
        .lblSymbol.BorderStyle = 1
        .lblSymbol.BorderColor = RGB(128, 0, 0)
        .lblSymbol.TextAlign = 2
        .lblSymbol.Visible = True
        
        ' Status
        .lblStatus.caption = nachricht
        .lblStatus.ForeColor = RGB(255, 0, 0)
        .lblStatus.Visible = True
        
        ' Kein Timer - muss weggeklickt werden
        .TimerInterval = 0
    End With
End Sub


Private Function ZeitAufViertelstundeRunden(eingabeZeit As Date) As Date
    ' Rundet Zeit auf nächste Viertelstunde
    Dim stunden As Integer
    Dim minuten As Integer
    Dim neueMinuten As Integer

    stunden = Hour(eingabeZeit)
    minuten = minute(eingabeZeit)

    ' Rundungslogik
    Select Case minuten
        Case 0 To 7
            neueMinuten = 0
        Case 8 To 22
            neueMinuten = 15
        Case 23 To 37
            neueMinuten = 30
        Case 38 To 52
            neueMinuten = 45
        Case 53 To 59
            neueMinuten = 0
            stunden = stunden + 1
    End Select

    ZeitAufViertelstundeRunden = TimeSerial(stunden, neueMinuten, 0)
    
End Function


Private Sub StatusAnzeigen(Text As String, farbe As String)
    ' Zeigt Status in verschiedenen Farben an
    Me.lblStatus.caption = Text

    Select Case UCase(farbe)
        Case "GRUEN": Me.lblStatus.ForeColor = RGB(0, 128, 0)
        Case "ROT":   Me.lblStatus.ForeColor = RGB(255, 0, 0)
        Case "ORANGE": Me.lblStatus.ForeColor = RGB(255, 165, 0)
        Case Else:    Me.lblStatus.ForeColor = RGB(0, 0, 0)
    End Select
End Sub


'Mitarbeiter auschecken
Private Sub lstCheckedIn_DblClick(Cancel As Integer)

Dim MA_ID   As Long
Dim VA_ID   As Long
Dim ZUO_ID  As Long
Dim MA_Name  As String

    MA_ID = Me.lstCheckedIn.Column(1)
    ZUO_ID = IIf(IsInitial(Me.lstCheckedIn.Column(0)), 0, Me.lstCheckedIn.Column(0))
    VA_ID = Me.cmbEinsatz.Column(4)
    MA_Name = Me.lstCheckedIn.Column(2)
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", ZUO_ID)
    
    If Not IsNull(MA_ID) Then
        If MsgBox(MA_Name & " auschecken?", vbYesNo) = vbYes Then Call MA_Zeiterfassung(MA_ID, ZUO_ID)
    End If

    Call listBox_requery
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", 0)

End Sub


'Checkout entfernen?
Private Sub lstCheckedOut_DblClick(Cancel As Integer)
    'Do Nothing
    
End Sub

''Entfernen
'Private Sub lstCheckedOut_KeyPress(KeyAscii As Integer)
'
'Dim MA_ID   As Long
'Dim VA_ID   As Long
'Dim ZUO_ID  As Long
'Dim MA_Name As String
'
'    MA_ID = Nz(Me.lstCheckedOut.Column(1), 0)
'    ZUO_ID = IIf(IsInitial(Me.lstCheckedIn.Column(0)), 0, Me.lstCheckedIn.Column(0))
'    VA_ID = Me.cmbEinsatz.Column(4)
'    MA_Name = Me.lstCheckedOut.Column(2)
'
' If KeyAscii = 8 Then 'Zurück-Taste
'     If Not IsNull(MA_ID) Then
'        If MsgBox(MA_Name & " Checkout entfernen?", vbYesNo) = vbYes Then Call MitarbeiterZeiterfassungErweitert(MA_ID, VA_ID)
'    End If
' End If
'
'End Sub


'Mitarbeiter einchecken
Private Sub lstZuo_DblClick(Cancel As Integer)

Dim MA_ID   As Long
Dim VA_ID   As Long
Dim ZUO_ID  As Long
Dim MA_Name As String

    MA_ID = Me.lstZuo.Column(1)
    ZUO_ID = Me.lstZuo.Column(0)
    VA_ID = Me.cmbEinsatz.Column(4)
    MA_Name = Me.lstZuo.Column(2)
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", ZUO_ID)
    
    Call MA_Zeiterfassung(MA_ID, ZUO_ID)
    
    Call listBox_requery
    
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", 0)

End Sub


'Scanfeld
Private Sub txtQRScan_AfterUpdate()

Dim MA_ID  As Long

On Error Resume Next

    MA_ID = Me.txtQRScan
    
    If Not IsInitial(MA_ID) Then
        Call MA_Zeiterfassung(MA_ID)
    Else
        MsgBox ">" & Me.txtQRScan & "< ist keine Mitarbeiter-ID!", vbCritical
        Me.lblStatus.caption = ""
        Me.txtQRScan = ""
        Me.txtQRScan.SetFocus
    End If
    
    Call listBox_requery

End Sub


' Ein- & Auschecken
Function MA_Zeiterfassung(iMA_ID As Long, Optional iZuo_ID As Long)

Dim ZUO_ID          As Long
Dim MA_ID           As Long
Dim ZUO_IDs()       As Variant
Dim VA_ID           As Long
Dim MAName          As String
Dim gerundeteZeit   As Date
Dim istEingecheckt  As Boolean
Dim istAusgecheckt  As Boolean
Dim rs              As Recordset
Dim SQL             As String
Dim ungeplant       As Boolean
Dim arbeitszeit     As Double
Dim meldungstext    As String
Dim subunternehmer  As Boolean

On Error GoTo Fehler
    
    MA_ID = iMA_ID
    VA_ID = Me.cmbEinsatz.Column(4)
    subunternehmer = TLookup("istSubunternehmer", MASTAMM, "ID=" & MA_ID)

    'Prüfung ZUO_ID
    If Not IsInitial(iZuo_ID) Then
        ZUO_ID = iZuo_ID
        
    Else 'Bei Scan der Personalnummer initial!
        ZUO_ID = MA_Zeiterfassung_zuocheck(MA_ID, subunternehmer)
        
        If IsInitial(ZUO_ID) Then 'keine ZUO_ID ermittelt!
            'Fehlermeldung
            Call ZeigeFehler("Mitarbeiter " & MA_ID & " nicht ein- oder ausgecheckt!")
            Exit Function
            
        End If
    End If
    
    'Name für Erfolgsmeldung
    If Not subunternehmer Then
        MAName = TLookup("Nachname", MASTAMM, "ID=" & MA_ID) & " " & TLookup("Vorname", MASTAMM, "ID=" & MA_ID)
    Else
        MAName = TLookup("Nachname", MASTAMM, "ID=" & MA_ID) & " " & TLookup("Vorname", MASTAMM, "ID=" & MA_ID) & _
            ": " & TLookup("Bemerkungen", ZUORDNUNG, "ID=" & ZUO_ID)
    End If
    
    gerundeteZeit = ZeitAufViertelstundeRunden(Now())
    
    SQL = "SELECT * FROM tbl_Zeiterfassung WHERE ZUO_ID=" & ZUO_ID
    Set rs = CurrentDb.OpenRecordset(SQL)
    
    If Not rs.EOF Then
        If IsInitial(rs.fields("CheckIn_Zeit")) Then
            'Ungeplanter Check-In
            rs.Edit
            rs.fields("CheckIn_Zeit").Value = gerundeteZeit
            rs.fields("CheckIn_Original").Value = Now()
            rs.fields("Erfasst_Am").Value = Date
            rs.fields("Status").Value = "EINGECHECKT"
            rs.update
            'Zeit in Zuordnung eintragen
            TUpdate "MA_Start=" & UhrzeitSQL(gerundeteZeit), ZUORDNUNG, "ID=" & ZUO_ID
            TUpdate "MVA_Start=" & DatumUhrzeitSQL(Date & " " & gerundeteZeit), ZUORDNUNG, "ID=" & ZUO_ID
            
            meldungstext = "CHECK-IN ohne Einteilung: " & MAName & " - " & Format(gerundeteZeit, "hh:nn")
            
        Else
            'Check-Out
            rs.Edit
            rs.fields("CheckOut_Zeit").Value = gerundeteZeit
            rs.fields("CheckOut_Original").Value = Now()
            rs.fields("Status").Value = "AUSGECHECKT"
            If IsNull(rs.fields("ZUO_ID")) Then rs.fields("ZUO_ID").Value = TLookup("ID", ZUORDNUNG, "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID)
            rs.update
                    
            'Zeit in Zuordnung eintragen
            TUpdate "MA_Ende=" & UhrzeitSQL(gerundeteZeit), ZUORDNUNG, "ID=" & ZUO_ID
            TUpdate "MVA_Ende=" & DatumUhrzeitSQL(Date & " " & gerundeteZeit), ZUORDNUNG, "ID=" & ZUO_ID
            
            arbeitszeit = gerundeteZeit - rs.fields("CheckIn_Zeit").Value
            meldungstext = "CHECK-OUT: " & MAName & " - " & Format(arbeitszeit, "h:nn") & " Std"
            
        End If
    
    Else
        'normaler Check-In
        rs.AddNew
        rs.fields("ZUO_ID").Value = ZUO_ID
        rs.fields("MA_ID").Value = MA_ID
        rs.fields("VA_ID").Value = VA_ID
        rs.fields("MA_Start").Value = TLookup("MA_Start", ZUORDNUNG, "ID=" & ZUO_ID) ' UhrzeitSQL(TLookup("MA_Start", ZUORDNUNG, "ID=" & ZUO_ID))
        rs.fields("MVA_Start").Value = TLookup("MVA_Start", ZUORDNUNG, "ID=" & ZUO_ID) ' DatumUhrzeitSQL(TLookup("MVA_Start", ZUORDNUNG, "ID=" & ZUO_ID))
        rs.fields("MA_Ende").Value = TLookup("MA_Ende", ZUORDNUNG, "ID=" & ZUO_ID) 'UhrzeitSQL(TLookup("MA_Ende", ZUORDNUNG, "ID=" & ZUO_ID))
        rs.fields("MVA_Ende").Value = TLookup("MVA_Ende", ZUORDNUNG, "ID=" & ZUO_ID) 'DatumUhrzeitSQL(TLookup("MVA_Ende", ZUORDNUNG, "ID=" & ZUO_ID))
        rs.fields("CheckIn_Zeit").Value = gerundeteZeit
        rs.fields("CheckIn_Original").Value = Now()
        rs.fields("Erfasst_Am").Value = Date
        rs.fields("Status").Value = "EINGECHECKT"
        
        rs.update
        
        'Zeit in Zuordnung eintragen
        TUpdate "MA_Start=" & UhrzeitSQL(gerundeteZeit), ZUORDNUNG, "ID=" & ZUO_ID
        TUpdate "MVA_Start=" & DatumUhrzeitSQL(Date & " " & gerundeteZeit), ZUORDNUNG, "ID=" & ZUO_ID
    
        meldungstext = "CHECK-IN: " & MAName & " - " & Format(gerundeteZeit, "hh:nn")
    End If
    
    rs.Close
    Set rs = Nothing
    
    
    ' ERFOLG anzeigen
    Call ZeigeErfolg(meldungstext)
    
    Me.txtQRScan = ""
    Me.txtQRScan.SetFocus
    
Ende:
    Exit Function
Fehler:
    Call ZeigeFehler("FEHLER: " & Err.description)
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Resume Ende
End Function



' Prüfungen gegen MA_VA_ZUORDNUNG
Function MA_Zeiterfassung_zuocheck(MA_ID As Long, Optional iSub As Boolean) As Long

Dim ZUO_ID     As Long
Dim VA_ID      As Long
Dim VADatum_ID As Long

    VA_ID = Me.cmbEinsatz.Column(4)
    VADatum_ID = Me.cmbEinsatz.Column(5)
    
    If Not IsNull(MA_ID) Then 'Popup immer bei mehreren Schichte der MA_ID zur Auswahl und für eventuelle kommentare
        
        'Subunternehmer?
        If iSub Then
            ZUO_ID = MA_Zeiterfassung_popup(VA_ID, VADatum_ID, MA_ID, , True)
        
        Else 'Mitarbeiter
            Select Case TCount("ID", ZUORDNUNG, "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & _
                " AND ID NOT IN (SELECT ZUO_ID FROM tbl_Zeiterfassung)")
                Case 0 'keinen Zuordnungssatz gefunden
                    'checkIn vorhanden?
                    If TCount("ZUO_ID", "tbl_Zeiterfassung", "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & " AND CheckOut_Zeit is Null") > 0 Then
                        ZUO_ID = TLookup("ZUO_ID", "tbl_Zeiterfassung", "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & " AND CheckOut_Zeit is Null")
                    Else
                        'kein CheckIn -> einteilen
                        If ZUO_ID = 0 Then ZUO_ID = einteilen_checkIn(MA_ID, VA_ID, VADatum_ID)
                    End If
    
                Case 1 'genau einen Zuordnungssatz gefunden
                    ZUO_ID = TLookup("ID", ZUORDNUNG, "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & _
                        " AND ID NOT IN (SELECT ZUO_ID FROM tbl_Zeiterfassung)")
                    
                Case Else 'mehrere Zuordnungssätze gefunden -> Auswahlpopup
                    ZUO_ID = MA_Zeiterfassung_popup(VA_ID, VADatum_ID, MA_ID, , False)
                
            End Select
        End If
    
        MA_Zeiterfassung_zuocheck = ZUO_ID
         
    End If
    
End Function


'Auswahlpopup Zeiterfassung
Function MA_Zeiterfassung_popup(VA_ID As Long, VADatum_ID As Long, MA_ID As Long, Optional ZUO_ID As Long, Optional iSub As Boolean) As Long

Dim frm As String
Dim SQL As String

    frm = "zfrm_Popup_Zeiterfassung_Zuo"
    
    'Recorsource für Popup aufbauen
    If Not IsInitial(ZUO_ID) Then
        SQL = "SELECT * FROM " & ZUORDNUNG & " WHERE ID = " & ZUO_ID
        
    ElseIf iSub Then
        SQL = "SELECT * FROM " & ZUORDNUNG & " WHERE VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " AND MA_ID = " & MA_ID
    
    Else
        SQL = "SELECT * FROM " & ZUORDNUNG & " WHERE VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " AND MA_ID = " & MA_ID & _
            " AND ID NOT IN (SELECT ZUO_ID FROM tbl_Zeiterfassung)"
            
    End If
    
    'Recorsource für Popup puffern
    Call Set_Priv_Property("prp_MA_Zeiterfassung_MA_ID", MA_ID)
    Call Set_Priv_Property("prp_Popup_MA_Zeiterfassung_Recordsource", SQL)
    
    If SysCmd(acSysCmdGetObjectState, acForm, frm) <> 0 Then DoCmd.Close acForm, frm
    
    DoCmd.OpenForm frm, , , , , acDialog
    
    'Gewählte ZUO_ID aus Puffer laden
    MA_Zeiterfassung_popup = Get_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID")
    
    'Reset Properties
    Call Set_Priv_Property("prp_MA_Zeiterfassung_MA_ID", 0)
    Call Set_Priv_Property("prp_MA_Zeiterfassung_ZUO_ID", 0)
    Call Set_Priv_Property("prp_Popup_MA_Zeiterfassung_Recordsource", "")
    
End Function


' Nicht eingeteilte MA bei Checkin einplanen
Function einteilen_checkIn(ByVal MA_ID As Long, ByVal VA_ID As Long, ByVal VADatum_ID As Long) As Long


Dim rs         As Recordset
Dim VADatum    As Date
Dim PosNr      As Integer
Dim ZUO_ID     As Long

On Error GoTo Err_Einplan
    
    VADatum = TLookup("VADatum ", ZUORDNUNG, "VADatum_ID = " & VADatum_ID)
    PosNr = TMax("PosNr", ZUORDNUNG, "VA_ID = " & VA_ID) + 1 'neue Position

    ' Neuer Datensatz Zuordnung
    Set rs = CurrentDb.OpenRecordset(ZUORDNUNG)
    rs.Edit
    rs.AddNew
    ZUO_ID = rs.fields("ID")
    rs.fields("MA_ID") = MA_ID
    rs.fields("VA_ID") = VA_ID
    rs.fields("VADatum_ID") = VADatum_ID
    rs.fields("VADatum") = VADatum
    rs.fields("PosNr") = PosNr
    rs.fields("Bemerkungen") = "ohne Einteilung!"
    rs.fields("Info") = "ohne Einteilung!"
    rs.update
    rs.Close
    
    ' Neuer Datensatz Zeiterfassung
    Set rs = CurrentDb.OpenRecordset("tbl_Zeiterfassung")
    rs.Edit
    rs.AddNew
    rs.fields("ZUO_ID") = ZUO_ID
    rs.fields("MA_ID") = MA_ID
    rs.fields("VA_ID") = VA_ID
    'rs.Fields("VADatum_ID") = VADatum_ID
    rs.fields("ungeplant") = True
    rs.update
    rs.Close
    
    einteilen_checkIn = ZUO_ID
        
End_Einplan:
    Set rs = Nothing
    Exit Function
Err_Einplan:
    Debug.Print Err.Number & " " & Err.description
    Resume End_Einplan
End Function


'Listboxen aktualisieren
Function listBox_requery()

'On Error Resume Next

    Me.lstZuo.Requery
    Me.lstCheckedIn.Requery
    Me.lstCheckedOut.Requery
    
    ClearListBoxSelection Me.lstCheckedIn
    ClearListBoxSelection Me.lstCheckedOut
    ClearListBoxSelection Me.lstZuo
   
    Me.txtQRScan.SetFocus
    
End Function


'Listbox Auswahl entfernen
Function ClearListBoxSelection(box As Variant)
Dim i As Long
box.SetFocus
   For i = 0 To box.ListCount - 1
     box.selected(i) = False
   Next i
End Function


' VADatum_ID für lstZuo -> zmd_qry_frm_Funktionen
Public Function get_cmbVADatum_ID() As Long
    get_cmbVADatum_ID = Me.cmbEinsatz.Column(5)
End Function```
