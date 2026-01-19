# zfrm_Lohnabrechnungen

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | zfrm_Lohnabrechnungen |
| **Datensatzquelle** | SELECT * FROM zqry_Lohnabrechnungen WHERE Jahr = 2026 AND Monat = 1 |
| **Datenquellentyp** | SQL |
| **Default View** | Continuous |
| **Allow Edits** | Ja |
| **Allow Additions** | Nein |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Ja |

## Controls


### ComboBoxen (Auswahllisten)

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------|
| cboMonat | - | 1294 / 460 | 1701 x 300 | 3 |
| cboJahr | - | 1300 / 120 | 1701 x 300 | 0 |
| cboAnstArt | - | 1294 / 795 | 1701 x 300 | 4 |

### Buttons (Schaltflaechen)

| Name | Caption | Position (L/T) | Groesse (W/H) | Events |
|------|---------|----------------|---------------|--------|
| btnLoad | Lohnabrechnungen laden | 5100 / 285 | 2046 x 568 | OnClick: [Event Procedure] |
| btnSend | Lohnabrechnungen versenden | 8730 / 285 | 2046 x 568 | OnClick: [Event Procedure] |
### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------||
| Bezeichnungsfeld6 | 225 / 460 | 1080 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld11 | 165 / 1245 | 630 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld12 | 855 / 1245 | 2730 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld13 | 4755 / 1245 | 8070 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld14 | 19140 / 1245 | 720 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld15 | 3645 / 1245 | 1050 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld16 | 12885 / 1245 | 2295 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld8 | 225 / 120 | 1080 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld55 | 225 / 795 | 1125 x 315 | 0 (Schwarz) |
| Bezeichnungsfeld67 | 15240 / 1245 | 3840 x 315 | 0 (Schwarz) |

### OptionButtons

| Name | Caption | Position (L/T) | Groesse (W/H) |
|------|---------|----------------|---------------|
| versenden | - | 3645 / 30 | 1050 x 300 |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------||
| Monat | Monat | 165 / 30 | 630 x 300 | 0 |
| Name | Name | 855 / 30 | 2730 x 300 | 1 |
| Datei | Datei | 4755 / 30 | 8070 x 300 | 3 |
| Anstellungsart_ID | Anstellungsart_ID | 19140 / 30 | 720 x 300 | 6 |
| versendet_am | versendet_am | 12885 / 30 | 2295 x 300 | 4 |
| Protokoll | Protokoll | 15240 / 30 | 3840 x 300 | 5 |

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: [Event Procedure]
- OnClose: Keine
- OnCurrent: Keine
- BeforeUpdate: Keine
- AfterUpdate: Keine
- OnActivate: Keine
- OnDeactivate: Keine

## VBA-Code

```vba
Option Compare Database

'Lohnabrechnungsdateien laden
Private Sub btnLoad_Click()

Dim SQL     As String
Dim WHERE   As String
Dim rs      As Recordset
Dim lex     As Variant
Dim LexID   As Long
Dim i       As Integer
Dim Datei   As String
Dim perMail As Boolean

    Select Case Me.cboAnstArt.Column(0)
        Case 3
            WHERE = "Anstellungsart_ID = 3 AND IstAktiv = TRUE"
            
        Case 5
            WHERE = "Anstellungsart_ID = 5 AND IstAktiv = TRUE"
            
        Case 13
            WHERE = "(Anstellungsart_ID = 3 OR Anstellungsart_ID = 5 OR Anstellungsart_ID = 4) AND IstAktiv = TRUE"
            
        Case Else
            Exit Sub
            
    End Select
    
    'Lexware IDs ermitteln
    lex = select_in_array(MASTAMM, "Lexware_ID", WHERE)

    For i = LBound(lex) To UBound(lex)
        WHERE = "Lex_ID = " & lex(i) & " AND Jahr = " & Me.cboJahr & " AND Monat = " & Me.cboMonat.Column(0)
        
        If Not IsNull(lex(i)) Then
            'Datensatz für Abrechnung vorhanden?
            If Not IsNumeric(TLookup("Lex_ID", "ztbl_Lohnabrechnungen", WHERE)) Then _
                CurrentDb.Execute "INSERT INTO ztbl_Lohnabrechnungen (Lex_ID, Jahr, Monat) VALUES (" & lex(i) & ", " & Me.cboJahr & ", " & Me.cboMonat.Column(0) & ")"
    
            Datei = Lohnabrechnung_ermitteln(lex(i), Me.cboJahr, Me.cboMonat.Column(0))
            
            If Datei <> "" Then TUpdate "Datei = '" & Datei & "'", "ztbl_Lohnabrechnungen", WHERE
            
            'Abrechnung per eMail?
            perMail = TLookup("eMail_Abrechnung", MASTAMM, "LEXWare_ID = " & lex(i))
            If perMail = True Then TUpdate "versenden = true", "ztbl_Lohnabrechnungen", WHERE

        End If
        
    Next i

    Call filtern
    
End Sub

'Abrechnungen versenden
Private Sub btnSend_Click()

'Dim IDs As String
Dim SQL As String
Dim rs As Recordset
Dim Protokoll As String

    'IDs = select_in_string("zqry_Lohnabrechnungen", "ID", "versenden = TRUE")
    
    DoCmd.RunCommand acCmdSaveRecord
    
    'Bereits versendete angehakt?
    If Not IsNull(TLookup("Lex_ID", "ztbl_Lohnabrechnungen", "versenden = TRUE AND versendet_am IS NOT NULL")) Then
        Select Case MsgBox("Bereits versendete erneut verschicken?", vbYesNoCancel, "Achtung")
            Case vbYes
                SQL = "SELECT * FROM ztbl_Lohnabrechnungen WHERE versenden = TRUE"
            Case vbNo
                SQL = "SELECT * FROM ztbl_Lohnabrechnungen WHERE versenden = TRUE AND versendet_am IS NULL"
            Case Else
                Exit Sub
        End Select
    Else
        SQL = "SELECT * FROM ztbl_Lohnabrechnungen WHERE versenden = TRUE"
    End If
    
    
    Set rs = CurrentDb.OpenRecordset(SQL)
    
    Do While Not rs.EOF
        If Not IsNull(rs.fields("Datei")) Then
            Protokoll = Lohnabrechnung_senden(rs.fields("Lex_ID"), Monat_lang(rs.fields("Monat")), rs.fields("Jahr"), rs.fields("Datei"))
            If Protokoll = "Email wurde versendet" Then
                rs.Edit
                rs.fields("versendet_am") = Now() 'DatumSQL(Now)
                rs.fields("versenden") = False
                rs.fields("Protokoll") = Protokoll & " (" & Environ("UserName") & ")"
                rs.update
                
            End If
        End If
        rs.MoveNext
    Loop
    
    Me.Requery
    
End Sub

Private Sub cboAnstArt_AfterUpdate()
    Call filtern
End Sub

Private Sub cboJahr_AfterUpdate()
    Call filtern
End Sub

Private Sub cboMonat_AfterUpdate()
    Call filtern
End Sub

Private Sub Form_Load()
    
    Me.Painting = False
    
    Me.cboJahr = Year(Now)
    Me.cboMonat = Monat_lang(Month(Now) - 1)
    If Me.cboMonat = "" Then Me.cboMonat = Monat_lang(Month(Now))
    Me.cboAnstArt = "Fest + Mini"
    
    Call filtern

    Me.Painting = True
    
End Sub

'Formular filtern
Function filtern()
    
Dim WHERE  As String
    
    'TUpdate "versenden = False", "ztbl_Lohnabrechnungen", "versenden = TRUE"
    WHERE = "Jahr = " & Me.cboJahr & " AND Monat = " & Me.cboMonat.Column(0)
    
        Select Case Me.cboAnstArt.Column(0)
        Case 3
            WHERE = WHERE & " AND Anstellungsart_ID = 3"
            
        Case 5
            WHERE = WHERE & " AND Anstellungsart_ID = 5"
            
        Case 13
            WHERE = WHERE & " AND ( Anstellungsart_ID = 3 OR Anstellungsart_ID = 5 OR Anstellungsart_ID = 4)"
            
        Case Else
            
    End Select
    
    Me.RecordSource = "SELECT * FROM zqry_Lohnabrechnungen WHERE " & WHERE
    Me.Requery

End Function```
