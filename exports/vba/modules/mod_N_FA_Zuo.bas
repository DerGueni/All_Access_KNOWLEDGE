Attribute VB_Name = "mod_N_FA_Zuo"
Option Explicit

' Modul: mdl_Auto_Festangestellte
' Zweck: Festangestellte automatisch den SPÄTESTEN Schichten
'        definierter Objekte zuordnen (keine neuen Datensätze)
' ===============================================================

Public Sub Auto_Festangestellte_Zuordnen()
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim ws As DAO.Workspace
    Dim rsAuftraege As DAO.Recordset
    Dim rsMitarbeiter As DAO.Recordset
    Dim rsSpaetesteSchicht As DAO.Recordset

    Dim lngAnzahlZugeordnet As Long
    Dim lngAnzahlGeprueft As Long
    Dim lngAnzahlAbwesend As Long
    Dim lngAnzahlBereitsZugeordnet As Long
    Dim strSQL As String

    Set db = CurrentDb
    Set ws = DBEngine.Workspaces(0)

    Debug.Print String(60, "=")
    Debug.Print "START: Auto-Zuordnung Festangestellte"
    Debug.Print "Zeit: " & Now()
    Debug.Print String(60, "=")

    ws.BeginTrans

    ' ===============================================================
    ' 1) Aufträge der nächsten 20 Tage laden (nur bestimmte Objekte)
    ' ===============================================================
    strSQL = "SELECT DISTINCT va.ID AS VA_ID, va.Auftrag, va.Objekt, " & _
             "       vat.ID AS VADatum_ID, vat.VADatum " & _
             "FROM tbl_VA_Auftragstamm AS va " & _
             "INNER JOIN tbl_VA_AnzTage AS vat ON va.ID = vat.VA_ID " & _
             "WHERE vat.VADatum BETWEEN Date() AND Date()+20 " & _
             "  AND (" & _
             "      va.Objekt Like '*Löwensaal*' " & _
             "   OR va.Objekt Like '*Loewensaal*' " & _
             "   OR va.Objekt Like '*KIA Metropol Arena*' " & _
             "   OR va.Objekt Like '*PSD Bank Arena*' " & _
             "   OR va.Objekt Like '*Stadthalle*' " & _
             "   OR va.Objekt Like '*Max-Morlock-Stadion*' " & _
             "   OR va.Objekt Like '*Morlock*' " & _
             "   OR va.Objekt Like '*Hirsch*' " & _
             "   OR va.Objekt Like '*Sportpark am Ronhof*' " & _
             "   OR va.Objekt Like '*Ronhof*' " & _
             "  ) " & _
             "ORDER BY vat.VADatum, va.ID"

    Set rsAuftraege = db.OpenRecordset(strSQL, dbOpenSnapshot)
    If rsAuftraege.EOF Then
        MsgBox "Keine relevanten Aufträge in den nächsten 20 Tagen gefunden.", vbInformation
        ws.Rollback
        GoTo Cleanup
    End If

    ' ===============================================================
    ' 2) Festangestellte laden (Anstellungsart_ID = 3)
    ' ===============================================================
    strSQL = "SELECT ID, Nachname, Vorname " & _
             "FROM tbl_MA_Mitarbeiterstamm " & _
             "WHERE Anstellungsart_ID = 3 " & _
             "  AND IstAktiv = True " & _
             "ORDER BY Nachname, Vorname"

    Set rsMitarbeiter = db.OpenRecordset(strSQL, dbOpenSnapshot)
    If rsMitarbeiter.EOF Then
        MsgBox "Keine festangestellten Mitarbeiter (Anstellungsart 3) gefunden.", vbInformation
        ws.Rollback
        GoTo Cleanup
    End If

    ' ===============================================================
    ' 3) Aufträge durchlaufen
    ' ===============================================================
    rsAuftraege.MoveFirst
    Do While Not rsAuftraege.EOF

        Debug.Print vbCrLf & String(60, "-")
        Debug.Print "AUFTRAG: " & Nz(rsAuftraege!Auftrag, "") & _
                    " | VA_ID: " & rsAuftraege!VA_ID
        Debug.Print "  Objekt: " & Nz(rsAuftraege!Objekt, "")
        Debug.Print "  Datum : " & Format(rsAuftraege!VADatum, "dd.mm.yyyy")

        ' ===========================================================
        ' 4) Späteste Schicht an diesem Tag ermitteln
        ' ===========================================================
        strSQL = "SELECT TOP 1 ID, VADatum_ID, VADatum, MA_Anzahl, " & _
                 "       MVA_Start, MVA_Ende " & _
                 "FROM tbl_VA_Start " & _
                 "WHERE VA_ID = " & rsAuftraege!VA_ID & _
                 "  AND VADatum = #" & Format(rsAuftraege!VADatum, "mm\/dd\/yyyy") & "# " & _
                 "ORDER BY MVA_Start DESC"

        Set rsSpaetesteSchicht = db.OpenRecordset(strSQL, dbOpenSnapshot)

        If Not rsSpaetesteSchicht.EOF Then

            Debug.Print "  Späteste Schicht: ID=" & rsSpaetesteSchicht!ID & _
                        " | " & Format(rsSpaetesteSchicht!MVA_Start, "hh:nn") & _
                        " - " & Format(rsSpaetesteSchicht!MVA_Ende, "hh:nn") & _
                        " | MA_Anzahl: " & Nz(rsSpaetesteSchicht!MA_Anzahl, 0)

            ' =======================================================
            ' 5) Mitarbeiter prüfen und ggf. zuordnen
            ' =======================================================
            rsMitarbeiter.MoveFirst
            Do While Not rsMitarbeiter.EOF

                lngAnzahlGeprueft = lngAnzahlGeprueft + 1

                Debug.Print "    Prüfe MA: " & rsMitarbeiter!Nachname & ", " & rsMitarbeiter!Vorname & _
                            " (ID=" & rsMitarbeiter!ID & ")"

                ' Qualifikation passend zum Objekt?
                If Not IstMitarbeiterQualifiziert(rsMitarbeiter!ID, Nz(rsAuftraege!Objekt, "")) Then
                    Debug.Print "      -> übersprungen (fehlende Qualifikation)"
                    GoTo NextMA
                End If

                ' Abwesend?
                If Not IstMitarbeiterVerfuegbar(rsMitarbeiter!ID, rsSpaetesteSchicht!VADatum) Then
                    lngAnzahlAbwesend = lngAnzahlAbwesend + 1
                    Debug.Print "      -> übersprungen (MA abwesend lt. NVerfuegZeiten)"
                    GoTo NextMA
                End If

                ' Schon in DIESEM Auftrag an DIESEM Tag zugeordnet?
                If IstBereitsZugeordnet(rsAuftraege!VA_ID, rsMitarbeiter!ID, rsSpaetesteSchicht!VADatum) Then
                    lngAnzahlBereitsZugeordnet = lngAnzahlBereitsZugeordnet + 1
                    Debug.Print "      -> übersprungen (im selben Auftrag an diesem Tag schon eingeplant)"
                    GoTo NextMA
                End If

                ' Zeitliche Überschneidung mit anderen Aufträgen an diesem Tag?
                If HatZeitueberlappung( _
                        rsMitarbeiter!ID, _
                        rsSpaetesteSchicht!VADatum, _
                        rsSpaetesteSchicht!MVA_Start, _
                        rsSpaetesteSchicht!MVA_Ende) Then

                    Debug.Print "      -> übersprungen (zeitliche Überlappung mit anderem Einsatz)"
                    GoTo NextMA
                End If

                ' Freier Slot vorhanden?
                If Not HatFreienSlot(rsAuftraege!VA_ID, rsSpaetesteSchicht!ID, rsSpaetesteSchicht!VADatum_ID) Then
                    Debug.Print "      -> keine freien Slots mehr in dieser Schicht, Auftrag fertig."
                    Exit Do ' Keine leeren Zeilen mehr -> Auftrag fertig
                End If

                ' Slot befüllen
                MA_ZuordnenInFreienSlot _
                    rsAuftraege!VA_ID, _
                    rsSpaetesteSchicht!ID, _
                    rsSpaetesteSchicht!VADatum_ID, _
                    rsSpaetesteSchicht!VADatum, _
                    rsMitarbeiter!ID, _
                    rsSpaetesteSchicht!MVA_Start, _
                    rsSpaetesteSchicht!MVA_Ende

                lngAnzahlZugeordnet = lngAnzahlZugeordnet + 1

                Debug.Print "      -> zugeordnet."

NextMA:
                rsMitarbeiter.MoveNext
            Loop

            rsSpaetesteSchicht.Close
            Set rsSpaetesteSchicht = Nothing
        Else
            Debug.Print "  Keine Schicht in tbl_VA_Start für diesen Tag gefunden."
        End If

        rsAuftraege.MoveNext
    Loop

    ws.CommitTrans

    Debug.Print vbCrLf & String(60, "=")
    Debug.Print "FERTIG: Auto-Zuordnung Festangestellte"
    Debug.Print "  MA geprüft        : " & lngAnzahlGeprueft
    Debug.Print "  MA zugeordnet     : " & lngAnzahlZugeordnet
    Debug.Print "  Abwesend          : " & lngAnzahlAbwesend
    Debug.Print "  Bereits zugeordnet: " & lngAnzahlBereitsZugeordnet
    Debug.Print String(60, "=")

    MsgBox "Automatische Zuordnung abgeschlossen." & vbCrLf & _
           "• MA geprüft: " & lngAnzahlGeprueft & vbCrLf & _
           "• MA zugeordnet: " & lngAnzahlZugeordnet & vbCrLf & _
           "• Abwesend: " & lngAnzahlAbwesend & vbCrLf & _
           "• Bereits zugeordnet: " & lngAnzahlBereitsZugeordnet, vbInformation

Cleanup:
    On Error Resume Next

    If Not rsSpaetesteSchicht Is Nothing Then rsSpaetesteSchicht.Close
    If Not rsMitarbeiter Is Nothing Then rsMitarbeiter.Close
    If Not rsAuftraege Is Nothing Then rsAuftraege.Close

    Set rsSpaetesteSchicht = Nothing
    Set rsMitarbeiter = Nothing
    Set rsAuftraege = Nothing
    Set db = Nothing
    Set ws = Nothing

    Exit Sub

Err_Handler:
    On Error Resume Next
    If Not ws Is Nothing Then ws.Rollback
    Debug.Print "FEHLER in Auto_Festangestellte_Zuordnen: " & Err.description
    MsgBox "Fehler bei Auto-Zuordnung: " & Err.description, vbCritical
    Resume Cleanup
End Sub

' ============================================================
' Prüft, ob Mitarbeiter an einem Datum verfügbar ist
' (kein Eintrag in tbl_MA_NVerfuegZeiten)
' ============================================================
Private Function IstMitarbeiterVerfuegbar(MA_ID As Long, Datum As Date) As Boolean
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT COUNT(*) AS Anzahl " & _
          "FROM tbl_MA_NVerfuegZeiten " & _
          "WHERE MA_ID=" & MA_ID & _
          "  AND #" & Format(Datum, "mm\/dd\/yyyy") & "# BETWEEN vonDat AND bisDat"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    IstMitarbeiterVerfuegbar = (rs!Anzahl = 0)

Cleanup:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Function

Err_Handler:
    Debug.Print "  [IstMitarbeiterVerfuegbar] Fehler: " & Err.description & " (MA_ID=" & MA_ID & ")"
    IstMitarbeiterVerfuegbar = False
    Resume Cleanup
End Function

' ============================================================
' Prüft, ob MA an diesem Tag im gleichen Auftrag schon eingeteilt ist
' ============================================================
Private Function IstBereitsZugeordnet(VA_ID As Long, MA_ID As Long, Datum As Date) As Boolean
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT COUNT(*) AS Anzahl " & _
          "FROM tbl_MA_VA_Zuordnung " & _
          "WHERE VA_ID=" & VA_ID & _
          "  AND MA_ID=" & MA_ID & _
          "  AND VADatum=#" & Format(Datum, "mm\/dd\/yyyy") & "#"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    IstBereitsZugeordnet = (rs!Anzahl > 0)

Cleanup:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Function

Err_Handler:
    Debug.Print "  [IstBereitsZugeordnet] Fehler: " & Err.description & _
                " (VA_ID=" & VA_ID & ", MA_ID=" & MA_ID & ")"
    ' Im Zweifel: blockieren
    IstBereitsZugeordnet = True
    Resume Cleanup
End Function

' ============================================================
' Prüft, ob MA an diesem Tag zeitlich überlappend
' bereits irgendwo (Auftrag/Schicht) eingeplant ist
' ============================================================
Private Function HatZeitueberlappung( _
                    MA_ID As Long, _
                    Datum As Date, _
                    startzeit As Date, _
                    EndeZeit As Date) As Boolean
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    Debug.Print "    [Overlap-Check] MA_ID=" & MA_ID & _
                ", Datum=" & Format(Datum, "dd.mm.yyyy") & _
                ", geplanter Zeitraum: " & Format(startzeit, "hh:nn") & _
                " - " & Format(EndeZeit, "hh:nn")

    sql = "SELECT VA_ID, VAStart_ID, VADatum, MVA_Start, MVA_Ende " & _
          "FROM tbl_MA_VA_Zuordnung " & _
          "WHERE MA_ID = " & MA_ID & _
          "  AND VADatum = #" & Format(Datum, "mm\/dd\/yyyy") & "# " & _
          "  AND MVA_Start IS NOT NULL " & _
          "  AND MVA_Ende IS NOT NULL"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    Do While Not rs.EOF

        Debug.Print "      vorhandene Schicht: VA_ID=" & Nz(rs!VA_ID, 0) & _
                    ", VAStart_ID=" & Nz(rs!VAStart_ID, 0) & _
                    ", " & Format(rs!MVA_Start, "hh:nn") & _
                    " - " & Format(rs!MVA_Ende, "hh:nn")

        ' Überlappungsprüfung:
        ' geplanter Start < bestehendes Ende
        ' und geplanter Ende > bestehender Start
        If (startzeit < rs!MVA_Ende) And (EndeZeit > rs!MVA_Start) Then
            Debug.Print "        -> ÜBERLAPPUNG gefunden!"
            HatZeitueberlappung = True
            GoTo Cleanup
        Else
            Debug.Print "        -> keine Überlappung mit dieser Schicht."
        End If

        rs.MoveNext
    Loop

    Debug.Print "    [Overlap-Check] keine Konflikte gefunden."
    HatZeitueberlappung = False

Cleanup:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Function

Err_Handler:
    Debug.Print "    [Overlap-Check] FEHLER: " & Err.description & _
                " (MA_ID=" & MA_ID & ")"
    ' Sicherheitshalber blockieren:
    HatZeitueberlappung = True
    Resume Cleanup
End Function

' ============================================================
' Prüft, ob es noch freie Slots (leere Zeilen) gibt
' (jetzt inkl. Filter auf VADatum_ID)
' ============================================================
Private Function HatFreienSlot(VA_ID As Long, VAStart_ID As Long, VADatum_ID As Long) As Boolean
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT COUNT(*) AS Freie " & _
          "FROM tbl_MA_VA_Zuordnung " & _
          "WHERE VA_ID=" & VA_ID & _
          "  AND VAStart_ID=" & VAStart_ID & _
          "  AND VADatum_ID=" & VADatum_ID & _
          "  AND (MA_ID IS NULL OR MA_ID=0)"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    HatFreienSlot = (Nz(rs!Freie, 0) > 0)

Cleanup:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Function

Err_Handler:
    Debug.Print "  [HatFreienSlot] Fehler: " & Err.description & _
                " (VA_ID=" & VA_ID & ", VAStart_ID=" & VAStart_ID & ", VADatum_ID=" & VADatum_ID & ")"
    HatFreienSlot = False
    Resume Cleanup
End Function

' ============================================================
' Weist MA in bestehenden leeren Slot ein (kein INSERT!)
' ============================================================
Private Sub MA_ZuordnenInFreienSlot( _
                VA_ID As Long, _
                VAStart_ID As Long, _
                VADatum_ID As Long, _
                VADatum As Date, _
                MA_ID As Long, _
                pMVA_Start As Date, _
                pMVA_Ende As Date)
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim rsSlot As DAO.Recordset
    Dim sql As String

    Set db = CurrentDb

    sql = "SELECT TOP 1 * " & _
          "FROM tbl_MA_VA_Zuordnung " & _
          "WHERE VA_ID=" & VA_ID & _
          "  AND VADatum_ID=" & VADatum_ID & _
          "  AND VAStart_ID=" & VAStart_ID & _
          "  AND (MA_ID IS NULL OR MA_ID=0) " & _
          "ORDER BY Nz(PosNr,0), ID"

    Set rsSlot = db.OpenRecordset(sql, dbOpenDynaset)

    If rsSlot.EOF Then
        Debug.Print "  [MA_ZuordnenInFreienSlot] Kein freier Slot gefunden (VA_ID=" & VA_ID & ", VAStart_ID=" & VAStart_ID & ")"
        GoTo Cleanup
    End If

    With rsSlot
        .Edit
        !MA_ID = MA_ID
        If IsNull(!MVA_Start) Or IsEmpty(!MVA_Start) Then !MVA_Start = pMVA_Start
        If IsNull(!MVA_Ende) Or IsEmpty(!MVA_Ende) Then !MVA_Ende = pMVA_Ende
        !Erst_von = Environ$("USERNAME")
        !Erst_am = Now()
        .update
    End With

Cleanup:
    On Error Resume Next
    rsSlot.Close
    Set rsSlot = Nothing
    Set db = Nothing
    Exit Sub

Err_Handler:
    Debug.Print "Fehler bei MA_ZuordnenInFreienSlot: " & Err.description & _
                " (VA_ID=" & VA_ID & ", VAStart_ID=" & VAStart_ID & ", MA_ID=" & MA_ID & ")"
    Resume Cleanup
End Sub

' ============================================================
' Prüft, ob MA für das Objekt laut tbl_MA_Einsatzart qualifiziert ist
' Verknüpfungstabelle: tbl_MA_Einsatz_Zuo (MA_ID, Einsatzart_ID)
' ============================================================
Private Function IstMitarbeiterQualifiziert(MA_ID As Long, Objekt As String) As Boolean
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim QualiName As String
    

    
      Select Case True
          Case Objekt Like "*Hirsch*"
            QualiName = "Hirsch"

'        Case Objekt Like "*Max-Morlock-Stadion*" Or Objekt Like "*Morlock*"
'            QualiName = "Fussball"
'
'        Case Objekt Like "*Sportpark am Ronhof*" Or Objekt Like "*Ronhof*"
'            QualiName = "Fussball"

        Case Else
            ' kein spezieller Qualifikationsbedarf -> alle zulassen
            IstMitarbeiterQualifiziert = True
            Exit Function
    End Select

    Set db = CurrentDb

    sql = "SELECT COUNT(*) AS Anzahl " & _
          "FROM tbl_MA_Einsatz_Zuo AS z " & _
          "WHERE z.MA_ID = " & MA_ID & _
          "  AND z.Einsatzart_QualiName = " & QualiName

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    IstMitarbeiterQualifiziert = (Nz(rs!Anzahl, 0) > 0)

Cleanup:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    Exit Function

Err_Handler:
    Debug.Print "  [IstMitarbeiterQualifiziert] Fehler: " & Err.description & _
                " (MA_ID=" & MA_ID & ", Objekt=" & Objekt & ")"
    ' Im Fehlerfall lieber blockieren als falsch zuordnen
    IstMitarbeiterQualifiziert = False
    Resume Cleanup
End Function

' ============================================================
' Test-Hilfsroutine (optional)
' ============================================================
Public Sub TestVAStartID()
    On Error GoTo Err_Handler

    Dim rs As DAO.Recordset

    Set rs = CurrentDb.OpenRecordset( _
        "SELECT VAStart_ID, COUNT(*) AS Anz " & _
        "FROM tbl_MA_VA_Zuordnung " & _
        "WHERE VA_ID=10315 " & _
        "GROUP BY VAStart_ID")

    Debug.Print "=== Zuordnung VAStart_ID ==="
    Do While Not rs.EOF
        Debug.Print "VAStart_ID: " & Nz(rs!VAStart_ID, "NULL") & " -> " & rs!Anz & " Zeilen"
        rs.MoveNext
    Loop
    rs.Close

    Debug.Print vbCrLf & "=== tbl_VA_Start IDs ==="
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT ID, MVA_Start, MVA_Ende " & _
        "FROM tbl_VA_Start " & _
        "WHERE VA_ID=10315")

    Do While Not rs.EOF
        Debug.Print "ID: " & rs!ID & " -> " & _
                    Format(rs!MVA_Start, "hh:nn") & "-" & _
                    Format(rs!MVA_Ende, "hh:nn")
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    Exit Sub

Err_Handler:
    Debug.Print "Fehler in TestVAStartID: " & Err.description
End Sub


