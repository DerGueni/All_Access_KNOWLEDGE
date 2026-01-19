# TODO: VBA Bridge Funktionen für Auftragstamm

**Erstellt:** 2026-01-15
**Zweck:** Diese VBA-Funktionen müssen in Access erstellt werden, damit die HTML-Button-Integration funktioniert

---

## Erforderliche VBA-Funktionen

### 1. SendeEinsatzliste_MA

**Button:** "E-Mail an MA" im Auftragstamm
**Zweck:** Sendet Einsatzliste per E-Mail an Mitarbeiter

```vba
Public Function SendeEinsatzliste_MA(VA_ID As Long, Datum As String, Datum_ID As Long, Typ As String) As String
    ' Sendet Einsatzliste an Mitarbeiter per E-Mail
    '
    ' Parameter:
    '   VA_ID      - Auftrags-ID
    '   Datum      - Datum im Format "YYYY-MM-DD"
    '   Datum_ID   - VADatum_ID (optional, kann 0 sein)
    '   Typ        - "MA" für Mitarbeiter
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

    Set db = CurrentDb()

    ' Mitarbeiter-Adressen für diesen Auftrag holen
    strSQL = "SELECT DISTINCT m.eMail, m.Nachname, m.Vorname " & _
             "FROM tbl_MA_Mitarbeiterstamm m " & _
             "INNER JOIN tbl_MA_VA_Zuordnung z ON m.ID = z.MA_ID " & _
             "WHERE z.VA_ID = " & VA_ID & " " & _
             "AND m.eMail Is Not Null AND m.eMail <> '' " & _
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

    ' Für jeden Mitarbeiter E-Mail senden
    Do While Not rs.EOF
        Set outlookMail = outlookApp.CreateItem(0) ' olMailItem

        ' Betreff und Body erstellen
        strBetreff = "Einsatzliste - Auftrag " & TLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & VA_ID)
        strBody = "Hallo " & rs!Vorname & " " & rs!Nachname & "," & vbCrLf & vbCrLf
        strBody = strBody & "anbei die Einsatzliste für den Auftrag." & vbCrLf & vbCrLf
        strBody = strBody & "Mit freundlichen Grüßen" & vbCrLf
        strBody = strBody & "Ihr CONSEC Team"

        With outlookMail
            .To = rs!eMail
            .Subject = strBetreff
            .Body = strBody
            .Send ' Oder .Display zum Anzeigen vor Versand
        End With

        intCount = intCount + 1
        rs.MoveNext
    Loop

    rs.Close
    Set rs = Nothing
    Set outlookMail = Nothing
    Set outlookApp = Nothing

    SendeEinsatzliste_MA = "OK - " & intCount & " E-Mails versendet"
    Exit Function

ErrorHandler:
    SendeEinsatzliste_MA = "Fehler: " & Err.Description
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set outlookMail = Nothing
    Set outlookApp = Nothing
End Function
```

---

### 2. ExportNamenlisteESS

**Button:** "ESS Namensliste" im Auftragstamm
**Zweck:** Erstellt Excel-Export mit ESS-Namensliste

```vba
Public Function ExportNamenlisteESS(VA_ID As Long, Datum As String, Datum_ID As Long) As String
    ' Exportiert ESS Namensliste für Auftrag
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

    ' Excel-Datei vorbereiten
    strPfad = "C:\temp\"
    strDateiname = "ESS_Namensliste_VA" & VA_ID & "_" & Format(Now, "yyyymmdd_hhnnss") & ".xlsx"

    ' Prüfe ob Temp-Ordner existiert
    If Not FolderExists(strPfad) Then
        MkDir strPfad
    End If

    ' Excel initialisieren
    Set xlApp = CreateObject("Excel.Application")
    Set xlWkb = xlApp.Workbooks.Add
    Set xlWks = xlWkb.Sheets(1)

    xlApp.Visible = True

    ' Überschrift
    xlWks.Range("A1").Value = "ESS Namensliste - Auftrag " & TLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & VA_ID)
    xlWks.Range("A1").Font.Bold = True
    xlWks.Range("A1").Font.Size = 14

    ' Header-Zeile (Zeile 3)
    intZeile = 3
    xlWks.Cells(intZeile, 1).Value = "Nachname"
    xlWks.Cells(intZeile, 2).Value = "Vorname"
    xlWks.Cells(intZeile, 3).Value = "Kurzname"
    xlWks.Cells(intZeile, 4).Value = "Geburtsdatum"
    xlWks.Cells(intZeile, 5).Value = "Geburtsort"
    xlWks.Cells(intZeile, 6).Value = "Nationalität"
    xlWks.Cells(intZeile, 7).Value = "Ausweis-Nr"
    xlWks.Cells(intZeile, 8).Value = "Ausweis gültig bis"
    xlWks.Cells(intZeile, 9).Value = "IHK 34a Nr"
    xlWks.Cells(intZeile, 10).Value = "IHK gültig bis"
    xlWks.Cells(intZeile, 11).Value = "Telefon"
    xlWks.Cells(intZeile, 12).Value = "E-Mail"

    ' Header formatieren
    With xlWks.Range(xlWks.Cells(intZeile, 1), xlWks.Cells(intZeile, 12))
        .Font.Bold = True
        .Interior.Color = RGB(220, 220, 220)
        .Borders.Weight = 2
    End With

    ' Daten laden
    strSQL = "SELECT m.Nachname, m.Vorname, m.Kurzname, " & _
             "m.Geburtsdatum, m.Geburtsort, m.Nationalitaet, " & _
             "m.Ausweis_Nr, m.Ausweis_Gueltig_Bis, " & _
             "m.IHK_34a_Nr, m.IHK_34a_Gueltig_Bis, " & _
             "m.Tel_Mobil, m.eMail " & _
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
        xlWks.Cells(intZeile, 3).Value = Nz(rs!Kurzname, "")
        xlWks.Cells(intZeile, 4).Value = IIf(IsNull(rs!Geburtsdatum), "", Format(rs!Geburtsdatum, "dd.mm.yyyy"))
        xlWks.Cells(intZeile, 5).Value = Nz(rs!Geburtsort, "")
        xlWks.Cells(intZeile, 6).Value = Nz(rs!Nationalitaet, "")
        xlWks.Cells(intZeile, 7).Value = Nz(rs!Ausweis_Nr, "")
        xlWks.Cells(intZeile, 8).Value = IIf(IsNull(rs!Ausweis_Gueltig_Bis), "", Format(rs!Ausweis_Gueltig_Bis, "dd.mm.yyyy"))
        xlWks.Cells(intZeile, 9).Value = Nz(rs!IHK_34a_Nr, "")
        xlWks.Cells(intZeile, 10).Value = IIf(IsNull(rs!IHK_34a_Gueltig_Bis), "", Format(rs!IHK_34a_Gueltig_Bis, "dd.mm.yyyy"))
        xlWks.Cells(intZeile, 11).Value = Nz(rs!Tel_Mobil, "")
        xlWks.Cells(intZeile, 12).Value = Nz(rs!eMail, "")

        intZeile = intZeile + 1
        rs.MoveNext
    Loop

    rs.Close
    Set rs = Nothing

    ' Spaltenbreite automatisch anpassen
    xlWks.Columns("A:L").AutoFit

    ' Speichern
    xlWkb.SaveAs strPfad & strDateiname

    ' Excel anzeigen
    xlApp.Visible = True

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

' Hilfsfunktion
Private Function FolderExists(strPath As String) As Boolean
    On Error Resume Next
    FolderExists = (GetAttr(strPath) And vbDirectory) = vbDirectory
End Function
```

---

### 3. fXL_Export_Auftrag (EXISTIERT BEREITS)

**Button:** "Einsatzliste drucken" im Auftragstamm
**Status:** ✅ Funktion existiert bereits in `mdl_Excel_Export.bas`

**Signatur:**
```vba
Function fXL_Export_Auftrag(VA_ID As Long, XLPfad As String, XLName As String)
```

**Keine Änderung erforderlich!**

---

## Installation

1. Öffne `0_Consys_FE_Test.accdb`
2. Gehe zu VBA-Editor (Alt+F11)
3. Erstelle neues Modul oder verwende bestehendes
4. Füge die beiden Funktionen ein:
   - `SendeEinsatzliste_MA`
   - `ExportNamenlisteESS`
5. Prüfe Dependencies:
   - `TLookup()` Funktion muss vorhanden sein
   - DAO-Library muss referenziert sein
6. Kompiliere VBA-Code (Debug > Compile)
7. Starte VBA Bridge Server neu

---

## Test-Checklist

### VBA-Funktionen testen (direkt in Access):

```vba
' Direkt im Direktfenster (Strg+G) testen:

' Test 1: E-Mail senden
? SendeEinsatzliste_MA(12345, "2026-01-15", 0, "MA")
' Erwartetes Ergebnis: "OK - X E-Mails versendet"

' Test 2: ESS Namensliste
? ExportNamenlisteESS(12345, "2026-01-15", 0)
' Erwartetes Ergebnis: "OK - Datei gespeichert: C:\temp\ESS_Namensliste_..."

' Test 3: Excel-Export (existiert bereits)
? fXL_Export_Auftrag(12345, "C:\temp\", "Auftrag_12345.xlsx")
```

### HTML-Buttons testen:

1. Öffne Auftragstamm im Browser/WebView2
2. Wähle einen Auftrag aus (z.B. VA_ID = 12345)
3. Klicke nacheinander:
   - Button "E-Mail an MA"
   - Button "Einsatzliste drucken"
   - Button "ESS Namensliste"
4. Prüfe:
   - Console-Logs (F12)
   - Toast-Messages
   - Excel-Dateien werden erstellt
   - E-Mails werden versendet

---

## Troubleshooting

### Fehler: "Access nicht geöffnet"
- Öffne `0_Consys_FE_Test.accdb` manuell
- Stelle sicher, dass Access im Hintergrund läuft

### Fehler: "Funktion nicht gefunden"
- Prüfe ob Funktionsname exakt übereinstimmt (Case-Sensitive!)
- Kompiliere VBA-Code neu (Debug > Compile)

### Fehler: "Type mismatch"
- Prüfe Parameter-Typen (Long, String, etc.)
- Stelle sicher, dass `VA_ID` als Integer/Long übergeben wird

### E-Mails werden nicht versendet
- Prüfe ob Outlook installiert und konfiguriert ist
- Teste `.Display` statt `.Send` zum Debuggen

---

**Status:** 🟡 **TODO** - VBA-Funktionen müssen erstellt werden
**Priorität:** Hoch
**Aufwand:** ca. 30-60 Minuten
