VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_Lohnabrechnungen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

'Lohnabrechnungsdateien laden
Private Sub btnLoad_Click()

Dim sql     As String
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
            WHERE = "(Anstellungsart_ID = 3 OR Anstellungsart_ID = 5 ) AND IstAktiv = TRUE"
            
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
Dim sql As String
Dim rs As Recordset
Dim Protokoll As String

    'IDs = select_in_string("zqry_Lohnabrechnungen", "ID", "versenden = TRUE")
    
    DoCmd.RunCommand acCmdSaveRecord
    
    'Bereits versendete angehakt?
    If Not IsNull(TLookup("Lex_ID", "ztbl_Lohnabrechnungen", "versenden = TRUE AND versendet_am IS NOT NULL")) Then
        Select Case MsgBox("Bereits versendete erneut verschicken?", vbYesNoCancel, "Achtung")
            Case vbYes
                sql = "SELECT * FROM ztbl_Lohnabrechnungen WHERE versenden = TRUE"
            Case vbNo
                sql = "SELECT * FROM ztbl_Lohnabrechnungen WHERE versenden = TRUE AND versendet_am IS NULL"
            Case Else
                Exit Sub
        End Select
    Else
        sql = "SELECT * FROM ztbl_Lohnabrechnungen WHERE versenden = TRUE"
    End If
    
    
    Set rs = CurrentDb.OpenRecordset(sql)
    
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
            WHERE = WHERE & " AND ( Anstellungsart_ID = 3 OR Anstellungsart_ID = 5 )"
            
        Case Else
            
    End Select
    
    Me.recordSource = "SELECT * FROM zqry_Lohnabrechnungen WHERE " & WHERE
    Me.Requery

End Function
