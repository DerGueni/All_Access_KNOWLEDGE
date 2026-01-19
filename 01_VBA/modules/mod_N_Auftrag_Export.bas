Attribute VB_Name = "mod_N_Auftrag_Export"
' ============================================================================
' Modul: mod_N_Auftrag_Export
' Zweck: VBA-Funktionen fuer HTML-Button-Integration (Auftragstamm)
' Erstellt: 2026-01-15 via Claude Code
' ============================================================================

Public Function SendeEinsatzliste_MA(VA_ID As Long, Datum As String, Datum_ID As Long, Typ As String) As String
    ' Sendet Einsatzliste an Mitarbeiter per E-Mail
    '
    ' Parameter:
    '   VA_ID      - Auftrags-ID
    '   Datum      - Datum im Format "YYYY-MM-DD"
    '   Datum_ID   - VADatum_ID (optional, kann 0 sein)
    '   Typ        - "MA" fuer Mitarbeiter
    '
    ' Return:
    '   "OK" bei Erfolg
    '   Fehlermeldung bei Fehler

    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim outlookApp As Object
    Dim outlookMail As Object
    Dim strBody As String
    Dim strBetreff As String
    Dim intCount As Integer
    Dim strAuftrag As String

    Set db = CurrentDb()

    ' Auftragsname holen
    strAuftrag = Nz(DLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & VA_ID), "Unbekannt")

    ' Mitarbeiter-Adressen fuer diesen Auftrag holen
    strSQL = "SELECT DISTINCT m.Email, m.Nachname, m.Vorname " & _
             "FROM tbl_MA_Mitarbeiterstamm m " & _
             "INNER JOIN tbl_MA_VA_Zuordnung z ON m.ID = z.MA_ID " & _
             "WHERE z.VA_ID = " & VA_ID & " " & _
             "AND m.Email Is Not Null AND m.Email <> '' " & _
             "ORDER BY m.Nachname, m.Vorname"

    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    If rs.EOF Then
        SendeEinsatzliste_MA = "Keine E-Mail-Adressen gefunden"
        rs.Close
        Set rs = Nothing
        Exit Function
    End If

    ' Outlook initialisieren
    Set outlookApp = CreateObject("Outlook.Application")

    intCount = 0

    ' Fuer jeden Mitarbeiter E-Mail senden
    Do While Not rs.EOF
        Set outlookMail = outlookApp.CreateItem(0) ' olMailItem

        ' Betreff und Body erstellen
        strBetreff = "Einsatzliste - " & strAuftrag
        strBody = "Hallo " & rs!Vorname & " " & rs!Nachname & "," & vbCrLf & vbCrLf
        strBody = strBody & "anbei die Einsatzliste fuer den Auftrag." & vbCrLf & vbCrLf
        strBody = strBody & "Mit freundlichen Gruessen" & vbCrLf
        strBody = strBody & "Ihr CONSEC Team"

        With outlookMail
            .To = rs!Email
            .Subject = strBetreff
            .Body = strBody
            .Display ' Anzeigen vor Versand (zum Testen)
        End With

        intCount = intCount + 1
        rs.MoveNext
    Loop

    rs.Close
    Set rs = Nothing
    Set outlookMail = Nothing
    Set outlookApp = Nothing

    SendeEinsatzliste_MA = "OK - " & intCount & " E-Mails erstellt"
    Exit Function

ErrorHandler:
    SendeEinsatzliste_MA = "Fehler: " & Err.Description
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set outlookMail = Nothing
    Set outlookApp = Nothing
End Function


Public Function ExportNamenlisteESS(VA_ID As Long, Datum As String, Datum_ID As Long) As String
    ' Exportiert ESS Namensliste fuer Auftrag
    '
    ' Parameter:
    '   VA_ID      - Auftrags-ID
    '   Datum      - Datum im Format "YYYY-MM-DD"
    '   Datum_ID   - VADatum_ID (optional, kann 0 sein)
    '
    ' Return:
    '   Pfad zur erstellten Excel-Datei
    '   Fehlermeldung bei Fehler

    On Error GoTo ErrorHandler

    Dim strSQL As String
    Dim strPfad As String
    Dim strDateiname As String
    Dim xlApp As Object
    Dim xlWkb As Object
    Dim xlWks As Object
    Dim rs As DAO.Recordset
    Dim intZeile As Integer
    Dim strAuftrag As String

    ' Excel-Datei vorbereiten
    strPfad = "C:\temp\"
    strDateiname = "ESS_Namensliste_VA" & VA_ID & "_" & Format(Now, "yyyymmdd_hhnnss") & ".xlsx"

    ' Auftragsname holen
    strAuftrag = Nz(DLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & VA_ID), "Unbekannt")

    ' Pruefe ob Temp-Ordner existiert
    If Not FolderExistsESS(strPfad) Then
        MkDir strPfad
    End If

    ' Excel initialisieren
    Set xlApp = CreateObject("Excel.Application")
    Set xlWkb = xlApp.Workbooks.Add
    Set xlWks = xlWkb.Sheets(1)

    xlApp.Visible = True

    ' Ueberschrift
    xlWks.Range("A1").Value = "ESS Namensliste - " & strAuftrag
    xlWks.Range("A1").Font.Bold = True
    xlWks.Range("A1").Font.Size = 14

    ' Header-Zeile (Zeile 3)
    intZeile = 3
    xlWks.Cells(intZeile, 1).Value = "Nachname"
    xlWks.Cells(intZeile, 2).Value = "Vorname"
    xlWks.Cells(intZeile, 3).Value = "MA-Nr"
    xlWks.Cells(intZeile, 4).Value = "Geburtsdatum"
    xlWks.Cells(intZeile, 5).Value = "Geburtsort"
    xlWks.Cells(intZeile, 6).Value = "Staatsangehoerigkeit"
    xlWks.Cells(intZeile, 7).Value = "Dienstausweis-Nr"
    xlWks.Cells(intZeile, 8).Value = "Ausweis gueltig bis"
    xlWks.Cells(intZeile, 9).Value = "Datum 34a"
    xlWks.Cells(intZeile, 10).Value = "Hat Sachkunde"
    xlWks.Cells(intZeile, 11).Value = "Telefon"
    xlWks.Cells(intZeile, 12).Value = "E-Mail"

    ' Header formatieren
    With xlWks.Range(xlWks.Cells(intZeile, 1), xlWks.Cells(intZeile, 12))
        .Font.Bold = True
        .Interior.Color = RGB(220, 220, 220)
        .Borders.Weight = 2
    End With

    ' Daten laden - Felder angepasst an echte Datenbank-Struktur
    strSQL = "SELECT m.Nachname, m.Vorname, m.Nr, " & _
             "m.Geb_Dat, m.Geb_Ort, m.Staatsang, " & _
             "m.DienstausweisNr, m.Ausweis_Endedatum, " & _
             "m.Datum_34a, m.HatSachkunde, " & _
             "m.Tel_Mobil, m.Email " & _
             "FROM tbl_MA_Mitarbeiterstamm m " & _
             "INNER JOIN tbl_MA_VA_Zuordnung z ON m.ID = z.MA_ID " & _
             "WHERE z.VA_ID = " & VA_ID & " " & _
             "ORDER BY m.Nachname, m.Vorname"

    Set rs = CurrentDb.OpenRecordset(strSQL, dbOpenSnapshot)

    ' Daten schreiben
    intZeile = 4
    Do While Not rs.EOF
        xlWks.Cells(intZeile, 1).Value = Nz(rs!Nachname, "")
        xlWks.Cells(intZeile, 2).Value = Nz(rs!Vorname, "")
        xlWks.Cells(intZeile, 3).Value = Nz(rs!Nr, "")
        xlWks.Cells(intZeile, 4).Value = IIf(IsNull(rs!Geb_Dat), "", Format(rs!Geb_Dat, "dd.mm.yyyy"))
        xlWks.Cells(intZeile, 5).Value = Nz(rs!Geb_Ort, "")
        xlWks.Cells(intZeile, 6).Value = Nz(rs!Staatsang, "")
        xlWks.Cells(intZeile, 7).Value = Nz(rs!DienstausweisNr, "")
        xlWks.Cells(intZeile, 8).Value = IIf(IsNull(rs!Ausweis_Endedatum), "", Format(rs!Ausweis_Endedatum, "dd.mm.yyyy"))
        xlWks.Cells(intZeile, 9).Value = Nz(rs!Datum_34a, "")
        xlWks.Cells(intZeile, 10).Value = IIf(rs!HatSachkunde = True, "Ja", "Nein")
        xlWks.Cells(intZeile, 11).Value = Nz(rs!Tel_Mobil, "")
        xlWks.Cells(intZeile, 12).Value = Nz(rs!Email, "")

        intZeile = intZeile + 1
        rs.MoveNext
    Loop

    rs.Close
    Set rs = Nothing

    ' Spaltenbreite automatisch anpassen
    xlWks.Columns("A:L").AutoFit

    ' Speichern
    xlWkb.SaveAs strPfad & strDateiname

    ExportNamenlisteESS = "OK - Datei gespeichert: " & strPfad & strDateiname
    Exit Function

ErrorHandler:
    ExportNamenlisteESS = "Fehler: " & Err.Description
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    If Not xlWkb Is Nothing Then xlWkb.Close False
    If Not xlApp Is Nothing Then xlApp.Quit
    Set xlWks = Nothing
    Set xlWkb = Nothing
    Set xlApp = Nothing
End Function


Private Function FolderExistsESS(strPath As String) As Boolean
    On Error Resume Next
    FolderExistsESS = (GetAttr(strPath) And vbDirectory) = vbDirectory
End Function
