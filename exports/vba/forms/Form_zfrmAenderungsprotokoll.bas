VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrmAenderungsprotokoll"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'
' Version : 3.01
'  Update : 21.04.2010
'
' Erweit- : - Sortierung durch Klicken auf Spalten-Überschriften möglich.
' erungen   - 2 mal Klicken ändert Sortierrichtung.
'           - Sortierung zusätzlich nach ID absteigend.
'           - Wenn OpenArgs fehlen, dann Abbruch.
'           - Über Zeitraum kann Anzeige eingeschränkt werden.
'           - Das Formular findet über die optionale IN-Klausel auch
'             aus einer Bibliotheksdatenbank die Protokolltabelle.
'           - Öffnen des Formulars/Ermitteln der Datenquelle optimiert.
'           - Größenänderung passt Listenfeld an.
'           - Seit der Version 3.0 wird Listview statt Listenfeld verwendet.
'

Private lvAenderungen As MSComctlLib.ListView
Private strTabelle As String
Private strFormName As String
Private strWert As String

Private Sub Form_Open(Cancel As Integer)
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Variablen deklarieren
    Dim pos As Long
    
    Set lvAenderungen = Me!lvAenderungsProtokoll.Object
    
    'Prüfen, ob OpenArgs vorhanden
    If IsNull(Me.OpenArgs) Then
        Exit Sub
    End If
    
    'OpenArgs "zerlegen"
    strTabelle = Split(Me.OpenArgs, ",")(0)
    strFormName = Split(Me.OpenArgs, ",")(1)
    strWert = Split(Me.OpenArgs, ",")(2)
    
    'Liste füllen
    Call ListviewFuellen

'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_zfrmAenderungsprotokoll " & vbCrLf & _
                   "Prozedur: Form_Open" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub Form_Close()
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Variablen deklarieren
    
    Set lvAenderungen = Nothing
    
'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_zfrmAenderungsprotokoll " & vbCrLf & _
                   "Prozedur: Form_Close" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub Form_Resize()
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Variablen deklarieren
    Dim lngHöhe As Long
    Dim lngBreite As Long
    
    'Höhe ermitteln
    lngHöhe = Me.InsideHeight
    
    'Mindesthöhe berücksichtigen
    If lngHöhe < 2000 Then
        lngHöhe = 2000
    End If
    
    'Höhenänderung umsetzen
    Me.Section(acDetail).height = lngHöhe - Me.Section(acHeader).height
    Me!lvAenderungsProtokoll.height = lngHöhe - Me.Section(acHeader).height
    
    'Breite ermitteln
    lngBreite = Me.InsideWidth
    
    'Mindestbreite berücksichtigen
    If lngBreite < 7000 Then
        lngBreite = 7000
    End If
    
    'Breiteänderung umsetzen
    Me!cmdHilfe.Left = lngBreite - 1147
    Me!cmdSchließen.Left = lngBreite - 541
    Me!lblZeitraum.Left = lngBreite * 0.472
    Me!cboZeitraum.Left = (lngBreite * 0.472) + 905
    Me!lvAenderungsProtokoll.width = lngBreite

'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_sfrmAenderungsprotokoll" & vbCrLf & _
                   "Prozedur:  Form_Resize" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub cboZeitraum_AfterUpdate()
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    Call ListviewFuellen

'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_sfrmAenderungsprotokoll" & vbCrLf & _
                   "Prozedur:  cboZeitraum_AfterUpdate" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub cboZeitraum_NotInList(NewData As String, response As Integer)
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Variablen deklarieren
    Dim strTitel As String
    Dim strHinweis As String
    
    strTitel = "Zeitraum nicht möglich"
    strHinweis = "Der von Ihnen gewünschte Zeitraum" & vbCrLf & _
                 "ist nicht möglich." & vbCrLf & vbCrLf & _
                 "Bitte wählen Sie einen Wert aus" & vbCrLf & _
                 "der Liste aus."
    MsgBox strHinweis, vbCritical, strTitel
    response = acDataErrContinue

'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_sfrmAenderungsprotokoll" & vbCrLf & _
                   "Prozedur:  cboZeitraum_NotInList" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub cmdHilfe_Click()
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Variablen deklarieren
    Dim strTitel As String
    Dim strHinweis As String
    
    strTitel = "Hilfe zu ""Bisherige Änderungen"""
    strHinweis = "Mit diesem Formular werden die bisherigen Änderungen am aus-" & vbCrLf & _
                 "gewählten Datensatz angezeigt." & vbCrLf & vbCrLf & _
                 "Die Änderungen sind dabei nach dem Datum absteigend sortiert." & vbCrLf & vbCrLf & _
                 "Wenn Sie auf eine Spaltenüberschrift klicken, wird das Formular" & vbCrLf & _
                 "nach dieser Spalte sortiert. Nochmaliges Klicken dreht die Reihen-" & vbCrLf & _
                 "folge der Sortierung um (aufsteigend => absteigend)." & vbCrLf & vbCrLf & _
                 "Durch Auswahl im Feld 'Zeitraum' kann die Anzeige weiter einge-" & vbCrLf & _
                 "schränkt werden."
    
    MsgBox strHinweis, vbInformation, strTitel

'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_sfrmAenderungsprotokoll" & vbCrLf & _
                   "Prozedur:  cmdHilfe_Click" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub cmdSchließen_Click()
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Formular schließen
    DoCmd.Close

'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_sfrmAenderungsprotokoll" & vbCrLf & _
                   "Prozedur:  cmdSchließen_Click" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub lvAenderungsProtokoll_ColumnClick(ByVal ColumnHeader As Object)
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Variablen deklarieren

    'Sortierung anpassen
    If lvAenderungen.SortKey = ColumnHeader.Index - 1 Then
        If lvAenderungen.SortOrder = lvwAscending Then
            lvAenderungen.SortOrder = lvwDescending
        Else
            lvAenderungen.SortOrder = lvwAscending
        End If
    Else
        lvAenderungen.SortKey = ColumnHeader.Index - 1
        lvAenderungen.SortOrder = lvwAscending
    End If
    lvAenderungen.Sorted = True
    
    'Erste Änderung selektieren
    If lvAenderungen.ListItems.Count > 0 Then
        lvAenderungen.ListItems.item(1).selected = True
    End If

'Ende
Exit_Here:
    On Error Resume Next
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_sfrmAenderungsprotokoll " & vbCrLf & _
                   "Prozedur: lvAenderungsProtokoll_ColumnClick" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub

Private Sub ListviewFuellen()
'Fehlerbehandlung definieren
On Error GoTo Error_Handler

    'Variablen deklarieren
    Dim db As DAO.Database
    Dim rst As DAO.Recordset
    Dim strIn As String
    Dim strSQL As String
    Dim dteZeitpunkt As Date
    Dim liAenderung As MSComctlLib.ListItem

    'String für Datenquelle aufbauen
    If CurrentDb.Name = CodeDb.Name Then
        strIn = ""
    Else
        strIn = " IN '" & CurrentDb.Name & "'"
    End If
    strSQL = "SELECT ID, Wert_Name, Wert_Alt, Wert_Neu, Datum, Benutzer, UserName, ComputerName " & _
             "FROM " & strTabelle & strIn & _
             " WHERE ((Datensatznr='" & strWert & "') AND (FormName='" & strFormName & "')"
                             
    'Zeitraum berücksichtigen
    Select Case Me!cboZeitraum
        Case 0    'Alle
            strSQL = strSQL & ") "
        Case 1    'Heute
            strSQL = strSQL & " AND (Datum >= " & Format(Date, "\#mm\/dd\/yyyy\#)) ")
        Case 2    'Gestern
            strSQL = strSQL & " AND (Datum BETWEEN " & Format(Date - 1, "\#mm\/dd\/yyyy\# ") & _
                              "AND " & Format(Date, "\#mm\/dd\/yyyy\#)) ")
        Case 3    'Letzte Woche
            dteZeitpunkt = DateAdd("ww", -1, Date) + 1
            strSQL = strSQL & " AND (Datum >= " & Format(dteZeitpunkt, "\#mm\/dd\/yyyy\#)) ")
        Case 4    'Letzter Monat
            dteZeitpunkt = DateAdd("m", -1, Date) + 1
            strSQL = strSQL & " AND (Datum >= " & Format(dteZeitpunkt, "\#mm\/dd\/yyyy\#)) ")
        Case 5    'Letztes Jahr
            dteZeitpunkt = DateAdd("yyyy", -1, Date) + 1
            strSQL = strSQL & " AND (Datum >= " & Format(dteZeitpunkt, "\#mm\/dd\/yyyy\#)) ")
        Case Else 'Kann nicht sein
            strSQL = strSQL & ") "
    End Select
    
    'Listview fuellen
    Set db = CurrentDb
    Set rst = db.OpenRecordset(strSQL, dbOpenSnapshot)
    lvAenderungen.ListItems.clear
    Do While Not rst.EOF
        Set liAenderung = lvAenderungen.ListItems.Add(, "A" & rst!ID, rst!ID)
        liAenderung.ListSubItems.Add , , rst!Wert_Name
        liAenderung.ListSubItems.Add , , Nz(rst!Wert_Alt, vbNullString)
        liAenderung.ListSubItems.Add , , Nz(rst!Wert_Neu, vbNullString)
        liAenderung.ListSubItems.Add , , Nz(Format$(rst!Datum, "yyyy-mm-dd hh:nn:ss"), vbNullString)
        liAenderung.ListSubItems.Add , , Nz(rst!benutzer, vbNullString)
        liAenderung.ListSubItems.Add , , Nz(rst!UserName, vbNullString)
        liAenderung.ListSubItems.Add , , Nz(rst!ComputerName, vbNullString)
        rst.MoveNext
    Loop
    
    'Nach Datum absteigend sortieren
    lvAenderungen.SortKey = 4
    lvAenderungen.SortOrder = lvwDescending
    lvAenderungen.Sorted = True
    
'Ende
Exit_Here:
    On Error Resume Next
    rst.Close
    Set rst = Nothing
    Set db = Nothing
    Exit Sub

'Fehlerbehandlung
Error_Handler:
    Select Case Err.Number
        Case 0
            Resume Next
        Case Else
            MsgBox "Ein Fehler ist aufgetreten: " & vbCrLf & _
                   "VBA Dokument Form_sfrmAenderungsprotokoll " & vbCrLf & _
                   "Prozedur: ListviewFuellen" & vbCrLf & _
                   "Fehler-Nr.: " & Err.Number & vbCrLf & _
                   Err.description, vbCritical
            Resume Exit_Here
    End Select

End Sub
