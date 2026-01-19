VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zsub_MA_ZK_top"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Abrechnungsdetails
Private Sub btnDetails_Click()

Dim frm     As String
Dim WHERE   As String
Dim MA_ID   As Long
Dim Jahr    As Integer
Dim Monat   As Integer

    frm = "zfrm_ZUO_Stunden"
    MA_ID = Nz(Me.Parent.cboMA.Column(0), 0)
    Jahr = Nz(Me.Parent.Form.Controls("cboJahr"), 0)
    Monat = Nz(Me.Parent.Form.Controls("RegZK"), 0)
    
    
    WHERE = "MA_ID = " & MA_ID
    WHERE = WHERE & " AND ID in (SELECT ID from zqry_ZUO_Stunden WHERE MA_ID = " & MA_ID & " AND Jahr = " & Jahr & " AND Monat = " & Monat & ")"
    
    DoCmd.OpenForm frm, acNormal, , WHERE
    
End Sub


'Zeitkonto einzeln: Daten/Delta für Lexware exportieren
Private Sub btnExportLex_Click()

Dim sql     As String
Dim qdf     As QueryDef
Dim tbl     As String
Dim ABF     As String
Dim qryTmp  As String
Dim WHERE   As String
Dim MA_ID   As Long
Dim MA      As String
Dim Jahr    As Integer
Dim Monat   As Integer

    tbl = "ztbl_ZK_Stunden"
    ABF = "zqry_ZK_Stunden_export"
    qryTmp = "temp"
    
    MA_ID = Nz(Me.Parent.cboMA.Column(0), 0)
    Monat = Me.Parent.RegZK
    Jahr = Me.Parent.cboJahr
    
    WHERE = "MA_ID = " & MA_ID & " AND Jahr = " & Jahr & " AND Monat = " & Monat '& " AND exportieren = TRUE"
    
    If Not IsInitial(MA_ID) Then
        
        MA = TLookup("Nachname", MASTAMM, "ID = " & MA_ID) & "_" & TLookup("Vorname", MASTAMM, "ID = " & MA_ID)
        
        If MsgBox("Zeitkonto " & MA & " Monat " & Monat & " komplett exportieren?", vbYesNo) <> vbYes Then Exit Sub
        
        'SQL = "SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert FROM " & abf & " WHERE " & where '& " AND exportiert = FALSE"
        sql = "SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert, Stundensatz, Währung, Name FROM " & ABF & " WHERE " & WHERE '& " AND exportiert = FALSE"
        
        If queryExists(qryTmp) Then DoCmd.DeleteObject acQuery, qryTmp
        
        Set qdf = CurrentDb.CreateQueryDef(qryTmp, sql)
          
        'DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE", qrytmp, PfadPlanungAktuell & "A  - Lexware Datenträger\Lexware_Import.txt"
        DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE_FULL_SPALTEN", qryTmp, PfadPlanungAktuell & "A  - Lexware Datenträger\" & Jahr & "_" & Monat & "_" & MA & ".txt"
        
        CurrentDb.Execute "UPDATE " & tbl & " SET exportiert = TRUE WHERE " & WHERE
        
        Call Me.Parent.filtern_MA
        
        MsgBox "Importdatei wurde erstellt"
            
    Else
        MsgBox "Bitte Mitarbeiter auswählen!", vbCritical
        
    End If

End Sub

'Korrektursatz anlegen
Private Sub btnKorrektur_Click()

Dim MA_ID           As Long
Dim Jahr            As Integer
Dim Monat           As Integer
Dim frm             As String
Dim sql             As String


    frm = "zfrm_MA_ZK_Korrekturen"
    
    MA_ID = Nz(Me.Parent.cboMA.Column(0), 0)
    Jahr = Nz(Me.Parent.Form.Controls("cboJahr"), 0)
    Monat = Nz(Me.Parent.Form.Controls("RegZK"), 0)
    
    sql = "SELECT * FROM [ztbl_MA_ZK_Korrekturen] WHERE [MA_ID] = " & MA_ID & _
       " AND [Jahr] = " & Jahr & " AND Monat = " & Monat

    DoCmd.OpenForm frm, acNormal
    Forms(frm).Form.txMA_ID = MA_ID
    Forms(frm).Form.txMonat = Monat
    Forms(frm).Form.txJahr = Jahr
    Forms(frm).Form.txJahrZ = Jahr
    Forms(frm).Form.txMonatZ = Monat
    
    Forms(frm).recordSource = sql

End Sub

'Nicht abgerechnet Aufträge
Private Sub btnNichtAbgerechnet_Click()

Dim MA_ID           As Long
Dim Jahr            As Integer
Dim Monat           As Integer

    MA_ID = Nz(Me.Parent.cboMA.Column(0), 0)
    Jahr = Nz(Me.Parent.Form.Controls("cboJahr"), 0)
    Monat = Nz(Me.Parent.Form.Controls("RegZK"), 0)
    
    'DoCmd.OpenForm "zfrm_zk_Stunden_Nicht_Abgerechnet", acFormDS, , "MA_ID = " & MA_ID & " AND Jahr <= " & Jahr & " AND Monat <= " & Monat
    DoCmd.OpenForm "zfrm_zk_Stunden_Nicht_Abgerechnet", acNormal, , "MA_ID = " & MA_ID & " AND VADatum <= " & datumSQL(Now)

End Sub

Private Sub Form_Load()

    Me.Parent.Form.cboMA = Null
    Me.lb_ZK_Header.caption = "ZEITKONTO"
    Call Me.Parent.filtern_MA
    Me.zsub_MA_ZK_Daten.Form.Requery
    
    
End Sub


'Mitarbeiterauswahl Klick
Private Sub lst_MA_Click()

     Me.Parent.Form.cboMA = Me.Lst_MA
     Call Me.Parent.filtern_MA
     
End Sub



'Mitarbeiterauswahl Suche
Private Sub MANameEingabe_AfterUpdate()

Dim i As Integer

    Me.Painting = False
    Me.Parent.Form.cboMA = Me.MANameEingabe.Column(0)
    Call Me.Parent.filtern_MA
    'Listbox entmarkieren
    With Me.Lst_MA
        For i = .ListCount - 1 To 1 Step -1
            .selected(i) = False
        Next i
'        'Eintrag markieren
        For i = 1 To .ListCount - 1
          If CLng(.Column(0, i)) = Me.MANameEingabe.Column(0) Then
             .selected(i) = True
             Exit For
          End If
        Next i
    End With
    Me.MANameEingabe = Null
    Me.Painting = True
    
End Sub


'Filter Mitarbeiter
Public Sub NurAktiveMA_AfterUpdate()

Dim listselect As String

    listselect = "SELECT ID, Nachname, Vorname, Ort"
    
    Select Case Me!NurAktiveMA
        Case 1 ' Nur Aktive
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 3 or Anstellungsart_ID = 5 ORDER BY Nachname, Vorname;"
        Case 2 ' Nur Festangestellte  'Anstellungsart 3
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 3 ORDER BY Nachname, Vorname;"
        Case 3 ' Nur Minijobber  ' Anstellungsart 5
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 5 ORDER BY Nachname, Vorname;"
        Case 4 ' Nur Unternehmer  ' IstSubunternehmer = True
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where IstSubunternehmer = True ORDER BY Nachname, Vorname;"
        Case 5 ' Nur Inaktive
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 9 ORDER BY Nachname, Vorname;"
        Case 6 ' Nur Vorrübergehend nicht Tätige
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 6 ORDER BY Nachname, Vorname;"
        Case Else ' Alle
            Me!Lst_MA.RowSource = listselect & " FROM tbl_MA_Mitarbeiterstamm Where Anstellungsart_ID = 2 or Anstellungsart_ID = 3 or Anstellungsart_ID = 4 or Anstellungsart_ID = 5 or Anstellungsart_ID = 6 or Anstellungsart_ID = 9 or Anstellungsart_ID = 10 ORDER BY Nachname, Vorname;"
    End Select
    
End Sub


'Update nach Eingabe Lohnsteuer
Private Sub txLohnsteuer_AfterUpdate()

Dim MA_ID           As Integer
Dim Jahr            As Integer
Dim Monat           As Integer
Dim sql             As String

    
    MA_ID = Nz(Me.Parent.cboMA.Column(0), 0)
    Jahr = Nz(Me.Parent.Form.Controls("cboJahr"), 0)
    Monat = Nz(Me.Parent.Form.Controls("RegZK"), 0)
    
    Call korrektur_anlegen_wert(MA_ID, 57, Jahr, Monat, Me.txLohnsteuer)
    Call Me.Parent.filtern_MA

End Sub


'Update nach Eingabe Sozialversicherung
Private Sub txSozVers_AfterUpdate()

Dim MA_ID           As Integer
Dim Jahr            As Integer
Dim Monat           As Integer
Dim sql             As String

    
    MA_ID = Nz(Me.Parent.cboMA.Column(0), 0)
    Jahr = Nz(Me.Parent.Form.Controls("cboJahr"), 0)
    Monat = Nz(Me.Parent.Form.Controls("RegZK"), 0)
    
    Call korrektur_anlegen_wert(MA_ID, 58, Jahr, Monat, Me.txSozVers)
    Call Me.Parent.filtern_MA
    
End Sub
