Option Compare Database
Option Explicit

' ===================================================================
' Modul: mdl_Auto_Festangestellte
' Zweck: Festangestellte automatisch den SPÄTESTEN Schichten
'        definierter Objekte zuordnen (keine neuen Datensätze)
' ===================================================================

Public Sub Auto_Festangestellte_Zuordnen()
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim ws As DAO.Workspace
    Dim rsAuftraege As DAO.Recordset
    Dim rsMitarbeiter As DAO.Recordset
    Dim rsAlleSchichten As DAO.Recordset
    Dim rsSpaestesteSchicht As DAO.Recordset

    Dim lngAnzahlZugeordnet As Long
    Dim lngAnzahlGeprueft As Long
    Dim lngAnzahlAbwesend As Long
    Dim lngAnzahlBereitsZugeordnet As Long
    Dim strSQL As String

    Set db = CurrentDb
    Set ws = DBEngine.Workspaces(0)

    Debug.Print String(40, "=")
    Debug.Print "START: Auto-Zuordnung Festangestellte"
    Debug.Print "Zeit: " & Now()
    Debug.Print String(40, "=")

    ws.BeginTrans

    ' ===============================================================
    ' 1) Aufträge der nächsten 20 Tage laden (nur bestimmte Objekte)
    ' ===============================================================
    strSQL = "SELECT DISTINCT va.ID AS VA_ID, va.Auftrag, va.Objekt, vat.ID AS VADatum_ID, vat.VADatum " & _
             "FROM tbl_VA_Auftragstamm AS va " & _
             "INNER JOIN tbl_VA_AnzTage AS vat ON va.ID = vat.VA_ID " & _
             "WHERE vat.VADatum BETWEEN Date() AND Date()+20 " & _
             "AND (" & _
             "      va.Objekt Like '*Löwensaal*' " & _
             "   OR va.Objekt Like '*Loewensaal*' " & _
             "   OR va.Objekt Like '*KIA Metropol Arena*' " & _
             "   OR va.Objekt Like '*PSD Bank Arena*' " & _
             "   OR va.Objekt Like '*Stadthalle*' " & _
             "   OR va.Objekt Like '*Max-Morlock-Stadion*' " & _
             "   OR va.Objekt Like '*Morlock*' " & _
             "   OR va.Objekt Like '*Sportpark am Ronhof*' " & _
             "   OR va.Objekt Like '*Ronhof*' " & _
             ") " & _
             "ORDER BY vat.VADatum, va.ID"

    Set rsAuftraege = db.OpenRecordset(strSQL, dbOpenSnapshot)
    If rsAuftraege.EOF Then
        MsgBox "Keine relevanten Aufträge in den nächsten 20 Tagen gefunden.", vbInformation
        ws.Rollback
        Exit Sub
    End If

    ' ===============================================================
    ' 2) Festangestellte laden (Anstellungsart_ID = 3)
    ' ===============================================================
    strSQL = "SELECT ID, Nachname, Vorname " & _
             "FROM tbl_MA_Mitarbeiterstamm " & _
             "WHERE Anstellungsart_ID = 3 AND IstAktiv = True " & _
             "ORDER BY Nachname, Vorname"
    Set rsMitarbeiter = db.OpenRecordset(strSQL, dbOpenSnapshot)
    If rsMitarbeiter.EOF Then
        MsgBox "Keine festangestellten Mitarbeiter (Anstellungsart 3) gefunden.", vbInformation
        ws.Rollback
        Exit Sub
    End If

    ' ===============================================================
    ' 3) Aufträge durchlaufen
    ' ===============================================================
    rsAuftraege.MoveFirst
    Do While Not rsAuftraege.EOF
        Debug.Print vbCrLf & String(40, "-")
        Debug.Print "AUFTRAG: " & rsAuftraege!Auftrag
        Debug.Print "VA_ID: " & rsAuftraege!VA_ID
        Debug.Print "Objekt: " & Nz(rsAuftraege!Objekt, "")
        Debug.Print "Datum: " & Format(rsAuftraege!VADatum, "dd.mm.yyyy")

        ' ===========================================================
        ' 4) Späteste Schicht an diesem Tag ermitteln
        ' ===========================================================
        strSQL = "SELECT TOP 1 ID, VADatum_ID, VADatum, MA_Anzahl, MVA_Start, MVA_Ende " & _
                 "FROM tbl_VA_Start " & _
                 "WHERE VA_ID = " & rsAuftraege!VA_ID & _
                 " AND VADatum = #" & Format(rsAuftraege!VADatum, "mm\/dd\/yyyy") & "# " & _
                 "ORDER BY MVA_Start DESC"
        Set rsSpaestesteSchicht = db.OpenRecordset(strSQL, dbOpenSnapshot)

        If Not rsSpaestesteSchicht.EOF Then
            Debug.Print "  Späteste Schicht-ID: " & rsSpaestesteSchicht!ID & _
                        " (" & Format(rsSpaestesteSchicht!MVA_Start, "hh:nn") & " - " & _
                        Format(rsSpaestesteSchicht!MVA_Ende, "hh:nn") & ")"

            ' =======================================================
            ' 5) Mitarbeiter prüfen und ggf. zuordnen
            ' =======================================================
            rsMitarbeiter.MoveFirst
            Do While Not rsMitarbeiter.EOF
                lngAnzahlGeprueft = lngAnzahlGeprueft + 1

                ' Abwesend?
                If Not IstMitarbeiterVerfuegbar(rsMitarbeiter!ID, rsSpaestesteSchicht!VADatum) Then
                    lngAnzahlAbwesend = lngAnzahlAbwesend + 1
                    GoTo NextMA
                End If

                ' Schon zugeordnet?
                If IstBereitsZugeordnet(rsAuftraege!VA_ID, rsMitarbeiter!ID, rsSpaestesteSchicht!VADatum) Then
                    lngAnzahlBereitsZugeordnet = lngAnzahlBereitsZugeordnet + 1
                    GoTo NextMA
                End If

                ' Freier Slot vorhanden?
                If Not HatFreienSlot(rsAuftraege!VA_ID, rsSpaestesteSchicht!ID) Then
                    Exit Do ' Keine leeren Zeilen mehr -> Auftrag fertig
                End If

                ' Slot befüllen
                Call MA_ZuordnenInFreienSlot( _
                    rsAuftraege!VA_ID, _
                    rsSpaestesteSchicht!ID, _
                    rsSpaestesteSchicht!VADatum_ID, _
                    rsSpaestesteSchicht!VADatum, _
                    rsMitarbeiter!ID, _
                    rsSpaestesteSchicht!MVA_Start, _
                    rsSpaestesteSchicht!MVA_Ende)

                lngAnzahlZugeordnet = lngAnzahlZugeordnet + 1

NextMA:
                rsMitarbeiter.MoveNext
            Loop
            rsSpaestesteSchicht.Close
        End If
        rsAuftraege.MoveNext
    Loop

    ws.CommitTrans

    Debug.Print vbCrLf & String(40, "=")
    Debug.Print "FERTIG"
    Debug.Print "MA geprüft: " & lngAnzahlGeprueft
    Debug.Print "MA zugeordnet: " & lngAnzahlZugeordnet
    Debug.Print "Abwesend: " & lngAnzahlAbwesend
    Debug.Print "Bereits zugeordnet: " & lngAnzahlBereitsZugeordnet
    Debug.Print String(40, "=")

    MsgBox "Automatische Zuordnung abgeschlossen." & vbCrLf & _
           "• MA geprüft: " & lngAnzahlGeprueft & vbCrLf & _
           "• MA zugeordnet: " & lngAnzahlZugeordnet & vbCrLf & _
           "• Abwesend: " & lngAnzahlAbwesend & vbCrLf & _
           "• Bereits zugeordnet: " & lngAnzahlBereitsZugeordnet, vbInformation

    Exit Sub

Err_Handler:
    If Not ws Is Nothing Then On Error Resume Next: ws.Rollback
    MsgBox "Fehler bei Auto-Zuordnung: " & err.description, vbCritical
End Sub

' ============================================================
' Prüft ob Mitarbeiter an einem Datum verfügbar ist
' ============================================================
Private Function IstMitarbeiterVerfuegbar(MA_ID As Long, Datum As Date) As Boolean
    On Error GoTo Err_Handler
    Dim db As DAO.Database, rs As DAO.Recordset, sql As String
    Set db = CurrentDb
    sql = "SELECT COUNT(*) AS Anzahl FROM tbl_MA_NVerfuegZeiten " & _
          "WHERE MA_ID=" & MA_ID & _
          " AND #" & Format(Datum, "mm\/dd\/yyyy") & "# BETWEEN vonDat AND bisDat"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    IstMitarbeiterVerfuegbar = (rs!Anzahl = 0)
    rs.Close
    Exit Function
Err_Handler:
    IstMitarbeiterVerfuegbar = False
End Function

' ============================================================
' Prüft, ob MA an diesem Tag/Auftrag schon eingeteilt ist
' ============================================================
Private Function IstBereitsZugeordnet(VA_ID As Long, MA_ID As Long, Datum As Date) As Boolean
    On Error GoTo Err_Handler
    Dim db As DAO.Database, rs As DAO.Recordset, sql As String
    Set db = CurrentDb
    sql = "SELECT COUNT(*) AS Anzahl FROM tbl_MA_VA_Zuordnung " & _
          "WHERE VA_ID=" & VA_ID & " AND MA_ID=" & MA_ID & _
          " AND VADatum=#" & Format(Datum, "mm\/dd\/yyyy") & "#"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    IstBereitsZugeordnet = (rs!Anzahl > 0)
    rs.Close
    Exit Function
Err_Handler:
    IstBereitsZugeordnet = True
End Function

' ============================================================
' Prüft, ob es noch freie Slots (leere Zeilen) gibt
' ============================================================
Private Function HatFreienSlot(VA_ID As Long, VAStart_ID As Long) As Boolean
    On Error GoTo Err_Handler
    Dim db As DAO.Database, rs As DAO.Recordset, sql As String
    Set db = CurrentDb
    sql = "SELECT COUNT(*) AS Freie FROM tbl_MA_VA_Zuordnung " & _
          "WHERE VA_ID=" & VA_ID & " AND VAStart_ID=" & VAStart_ID & _
          " AND (MA_ID IS NULL OR MA_ID=0)"
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
    HatFreienSlot = (Nz(rs!Freie, 0) > 0)
    rs.Close
    Exit Function
Err_Handler:
    HatFreienSlot = False
End Function

' ============================================================
' Weist MA in bestehenden leeren Slot ein (kein INSERT!)
' ============================================================
Private Sub MA_ZuordnenInFreienSlot(VA_ID As Long, VAStart_ID As Long, VADatum_ID As Long, _
                                    VADatum As Date, MA_ID As Long, MVA_Start As Date, MVA_Ende As Date)
    On Error GoTo Err_Handler
    Dim db As DAO.Database, rsSlot As DAO.Recordset, sql As String
    Set db = CurrentDb

    sql = "SELECT TOP 1 * FROM tbl_MA_VA_Zuordnung " & _
          "WHERE VA_ID=" & VA_ID & " AND VADatum_ID=" & VADatum_ID & _
          " AND VAStart_ID=" & VAStart_ID & _
          " AND (MA_ID IS NULL OR MA_ID=0) " & _
          "ORDER BY Nz(PosNr,0), ID"
    Set rsSlot = db.OpenRecordset(sql, dbOpenDynaset)

    If rsSlot.EOF Then
        rsSlot.Close
        Exit Sub
    End If

    rsSlot.Edit
    rsSlot!MA_ID = MA_ID
    If IsNull(rsSlot!MVA_Start) Or IsEmpty(rsSlot!MVA_Start) Then rsSlot!MVA_Start = MVA_Start
    If IsNull(rsSlot!MVA_Ende) Or IsEmpty(rsSlot!MVA_Ende) Then rsSlot!MVA_Ende = MVA_Ende
    rsSlot!Erst_von = Environ$("USERNAME")
    rsSlot!Erst_am = Now()
    rsSlot.update
    rsSlot.Close
    Exit Sub

Err_Handler:
    Debug.Print "Fehler bei MA_ZuordnenInFreienSlot: " & err.description
End Sub