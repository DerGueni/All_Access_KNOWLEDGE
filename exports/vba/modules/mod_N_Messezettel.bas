Attribute VB_Name = "mod_N_Messezettel"
' ========================================
' CONSEC Messezettel & Versand - VERSION v18
' ========================================
' KORREKTUR: Standnummer-Vergleich durch Extraktion aus beiden Seiten
' ========================================

Option Compare Database
Option Explicit

Private Const PDF_ORDNER As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\D - Messezettel"
Private Const PYTHON_SCRIPT As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\D - Messezettel\pdf_stempel.py"


'##############################
' FUNKTION 1: PDF-Stempel füllen
'##############################
Public Function FuelleMessezettel(auftragsID As Long) As Boolean
    
    Dim intAntwort As Integer
    intAntwort = MsgBox("Nur Auswahl bedrucken bzw versenden ?" & vbCrLf & vbCrLf & _
                        "Ja = Nur Auswahl" & vbCrLf & _
                        "Nein = Alle bedrucken bzw versenden" & vbCrLf & _
                        "Abbrechen = Vorgang abbrechen", _
                        vbQuestion + vbYesNoCancel, "Messezettel bearbeiten")
    
    If intAntwort = vbCancel Then
        FuelleMessezettel = False
        Exit Function
    End If
    
    If intAntwort = vbYes Then
        FuelleMessezettel = FuelleMessezettel_Intern(auftragsID, True)
    Else
        FuelleMessezettel = FuelleMessezettel_Intern(auftragsID, False)
    End If
    
End Function


Private Function FuelleMessezettel_Intern(auftragsID As Long, NurMarkierte As Boolean) As Boolean
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim rsAlle As DAO.Recordset
    Dim rsDatum As DAO.Recordset
    Dim rsMA As DAO.Recordset
    
    Dim dictPDFs As Object
    Dim dictPDFZeiten As Object
    Dim dictZuBearbeiten As Object
    Set dictPDFs = CreateObject("Scripting.Dictionary")
    Set dictPDFZeiten = CreateObject("Scripting.Dictionary")
    Set dictZuBearbeiten = CreateObject("Scripting.Dictionary")
    
    Dim strMitarbeiterVorname As String
    Dim strMitarbeiterNachname As String
    Dim strMitarbeiterName As String
    Dim strStandnummer As String
    Dim strBemerkungen As String
    Dim datArbeitsdatum As Date
    Dim dtmStartzeit As Date
    Dim lngVADatumID As Long
    Dim lngMAID As Long
    Dim strPDFPfad As String
    Dim strCommand As String
    Dim strSQL As String
    Dim strStandDatumKey As String
    
    Dim intErfolg As Integer, intFehler As Integer
    Dim vKey As Variant
    
    Dim colMA As Collection
    Dim colZeiten As Collection
    
    On Error GoTo Err_Handler
    
    Debug.Print "=== START MESSEZETTEL " & IIf(NurMarkierte, "(NUR MARKIERTE)", "(ALLE)") & " ==="
    Debug.Print "Auftrag: " & auftragsID
    Debug.Print ""
    
    Set db = CurrentDb
    intErfolg = 0: intFehler = 0
    
    ' ============================================
    ' SCHRITT 1: Welche Stand/Datum Kombinationen sollen bearbeitet werden?
    ' ============================================
    Debug.Print "=== SCHRITT 1: ERMITTLE ZU BEARBEITENDE STAND/DATUM ==="
    
    strSQL = "SELECT VADatum_ID, Bemerkungen FROM tbl_MA_VA_Zuordnung " & _
             "WHERE VA_ID = " & auftragsID
    
    If NurMarkierte Then
        strSQL = strSQL & " AND Rch_Erstellt = True"
    End If
    
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
    
    If rs.EOF Then
        If NurMarkierte Then
            MsgBox "Keine markierten Standwachen gefunden!" & vbCrLf & vbCrLf & _
                   "Bitte setzen Sie bei den gewünschten Standwachen" & vbCrLf & _
                   "das Feld 'Rch_Erstellt' auf Ja.", vbExclamation, "Keine Auswahl"
        Else
            MsgBox "Keine Mitarbeiter gefunden!", vbExclamation
        End If
        rs.Close: Set rs = Nothing: Set db = Nothing
        FuelleMessezettel_Intern = False
        Exit Function
    End If
    
    Do While Not rs.EOF
        lngVADatumID = Nz(rs!VADatum_ID, 0)
        strBemerkungen = Trim(Nz(rs!Bemerkungen, ""))
        
        If lngVADatumID > 0 And Len(strBemerkungen) > 0 Then
            strStandnummer = ExtrahiereStandnummerAusBemerkungen(strBemerkungen)
            
            If Len(strStandnummer) > 0 Then
                Set rsDatum = db.OpenRecordset( _
                    "SELECT VADatum FROM tbl_VA_AnzTage WHERE [ID] = " & lngVADatumID, _
                    dbOpenSnapshot)
                
                If Not rsDatum.EOF Then
                    datArbeitsdatum = rsDatum!VADatum
                    rsDatum.Close: Set rsDatum = Nothing
                    
                    strStandDatumKey = strStandnummer & "|" & Format(datArbeitsdatum, "yyyy-mm-dd")
                    
                    If Not dictZuBearbeiten.Exists(strStandDatumKey) Then
                        dictZuBearbeiten.Add strStandDatumKey, lngVADatumID
                        Debug.Print "  Zu bearbeiten: " & strStandnummer & " am " & Format(datArbeitsdatum, "dd.mm.yyyy")
                    End If
                Else
                    If Not rsDatum Is Nothing Then rsDatum.Close: Set rsDatum = Nothing
                End If
            End If
        End If
        rs.MoveNext
    Loop
    rs.Close: Set rs = Nothing
    
    Debug.Print "Anzahl zu bearbeitende Stand/Datum: " & dictZuBearbeiten.Count
    Debug.Print ""
    
    If dictZuBearbeiten.Count = 0 Then
        MsgBox "Keine gültigen Stand/Datum Kombinationen gefunden!", vbExclamation
        Set db = Nothing
        FuelleMessezettel_Intern = False
        Exit Function
    End If
    
    ' ============================================
    ' SCHRITT 2: Für jede Stand/Datum Kombination ALLE Mitarbeiter holen
    ' ============================================
    Debug.Print "=== SCHRITT 2: HOLE ALLE MITARBEITER PRO STAND/DATUM ==="
    Debug.Print ""
    
    For Each vKey In dictZuBearbeiten.Keys
        strStandDatumKey = CStr(vKey)
        
        Dim arrParts() As String
        Dim intJahr As Integer, intMonat As Integer, intTag As Integer
        arrParts = Split(strStandDatumKey, "|")
        strStandnummer = arrParts(0)
        
        Dim arrDatum() As String
        arrDatum = Split(arrParts(1), "-")
        intJahr = CInt(arrDatum(0))
        intMonat = CInt(arrDatum(1))
        intTag = CInt(arrDatum(2))
        datArbeitsdatum = DateSerial(intJahr, intMonat, intTag)
        
        Debug.Print "Stand/Datum: " & strStandnummer & " am " & Format(datArbeitsdatum, "dd.mm.yyyy")
        
        strPDFPfad = FindePDF_NachDatumUndStand(datArbeitsdatum, strStandnummer)
        
        If Len(strPDFPfad) = 0 Then
            Debug.Print "  ! Kein PDF gefunden"
            Debug.Print ""
            GoTo NextStandDatum
        End If
        
        strPDFPfad = LCase(Trim(strPDFPfad))
        Debug.Print "  PDF: " & Dir(strPDFPfad)
        
        ' WICHTIG: OHNE Markierungsfilter - ALLE MA für diesen Stand/Tag!
        strSQL = "SELECT z.MA_ID, z.Bemerkungen, z.MVA_Start " & _
                 "FROM tbl_MA_VA_Zuordnung AS z " & _
                 "INNER JOIN tbl_VA_AnzTage AS d ON z.VADatum_ID = d.ID " & _
                 "WHERE z.VA_ID = " & auftragsID & " " & _
                 "AND d.VADatum = #" & intMonat & "/" & intTag & "/" & intJahr & "# " & _
                 "ORDER BY z.MVA_Start"
        
        Set rsAlle = db.OpenRecordset(strSQL, dbOpenSnapshot)
        
        Set colMA = New Collection
        Set colZeiten = New Collection
        
        Debug.Print "  Suche MA für Stand: " & strStandnummer
        
        Do While Not rsAlle.EOF
            lngMAID = Nz(rsAlle!MA_ID, 0)
            strBemerkungen = Trim(Nz(rsAlle!Bemerkungen, ""))
            dtmStartzeit = Nz(rsAlle!MVA_Start, #12:00:00 AM#)
            
            ' KORRIGIERT: Extrahiere Standnummer aus Bemerkung und vergleiche
            Dim strBemStand As String
            strBemStand = ExtrahiereStandnummerAusBemerkungen(strBemerkungen)
            
            Debug.Print "    Bem: " & Left(strBemerkungen, 25) & "... -> " & strBemStand & " = " & strStandnummer & "? " & (strBemStand = strStandnummer)
            
            ' Vergleiche extrahierte Standnummern
            If lngMAID > 0 And strBemStand = strStandnummer Then
                
                Set rsMA = db.OpenRecordset( _
                    "SELECT Vorname, Nachname FROM tbl_MA_Mitarbeiterstamm WHERE [ID] = " & lngMAID, _
                    dbOpenSnapshot)
                
                If Not rsMA.EOF Then
                    strMitarbeiterVorname = Trim(Nz(rsMA!Vorname, ""))
                    strMitarbeiterNachname = Trim(Nz(rsMA!Nachname, ""))
                    rsMA.Close: Set rsMA = Nothing
                    
                    strMitarbeiterName = strMitarbeiterNachname & " " & strMitarbeiterVorname
                    
                    If colMA.Count < 2 Then
                        colMA.Add strMitarbeiterName
                        colZeiten.Add dtmStartzeit
                        Debug.Print "      -> HINZUGEFÜGT: " & strMitarbeiterName & " (Start: " & Format(dtmStartzeit, "hh:nn") & ")"
                    Else
                        Debug.Print "      -> ÜBERSPRUNGEN (max 2 erreicht)"
                    End If
                Else
                    If Not rsMA Is Nothing Then rsMA.Close: Set rsMA = Nothing
                End If
            End If
            
            rsAlle.MoveNext
        Loop
        rsAlle.Close: Set rsAlle = Nothing
        
        Debug.Print "  Gesammelte MA für PDF: " & colMA.Count
        
        If colMA.Count > 0 Then
            If Not dictPDFs.Exists(strPDFPfad) Then
                dictPDFs.Add strPDFPfad, colMA
                dictPDFZeiten.Add strPDFPfad, colZeiten
                Debug.Print "  -> " & colMA.Count & " MA für dieses PDF gespeichert"
            End If
        End If
        
NextStandDatum:
        Debug.Print ""
    Next vKey
    
    ' ============================================
    ' SCHRITT 3: PDFs bearbeiten
    ' ============================================
    Debug.Print "=== SCHRITT 3: BEARBEITE PDFs ==="
    Debug.Print "Anzahl PDFs im Dictionary: " & dictPDFs.Count
    Debug.Print ""
    
    If dictPDFs.Count = 0 Then
        Debug.Print "! WARNUNG: Keine PDFs zum Bearbeiten gefunden!"
        MsgBox "Keine PDFs zum Bearbeiten gefunden!", vbExclamation
        Set db = Nothing
        FuelleMessezettel_Intern = False
        Exit Function
    End If
    
    For Each vKey In dictPDFs.Keys
        
        strPDFPfad = CStr(vKey)
        
        Debug.Print "=== Bearbeite PDF ==="
        Debug.Print "Pfad: " & strPDFPfad
        Debug.Print "Existiert: " & (Dir(strPDFPfad) <> "")
        
        Dim colTemp As Collection
        Set colTemp = dictPDFs(vKey)
        
        Debug.Print "Anzahl MA in Collection: " & colTemp.Count
        
        If colTemp.Count = 0 Then
            Debug.Print "! Leere Collection!"
            GoTo NextPDF
        End If
        
        Dim j As Integer
        For j = 1 To colTemp.Count
            Debug.Print "  MA(" & j & "): " & colTemp(j)
        Next j
        
        Call ErstelleBackup(strPDFPfad)
        
        If colTemp.Count = 1 Then
            Debug.Print "Modus: 1 Mitarbeiter"
            strCommand = "python """ & PYTHON_SCRIPT & """ """ & _
                         strPDFPfad & """ """ & strPDFPfad & """ """ & _
                         Replace(colTemp(1), """", """""") & """ 1"
        ElseIf colTemp.Count >= 2 Then
            Debug.Print "Modus: 2 Mitarbeiter"
            strCommand = "python """ & PYTHON_SCRIPT & """ """ & _
                         strPDFPfad & """ """ & strPDFPfad & """ """ & _
                         Replace(colTemp(1), """", """""") & """ """ & _
                         Replace(colTemp(2), """", """""") & """"
        End If
        
        Debug.Print "CMD: " & strCommand
        
        Dim objShell As Object
        Set objShell = CreateObject("WScript.Shell")
        Dim intResult As Integer
        
        Debug.Print "Starte Python..."
        intResult = objShell.Run(strCommand, 0, True)
        Set objShell = Nothing
        
        Debug.Print "Python Exit-Code: " & intResult
        
        If intResult = 0 Then
            Debug.Print "OK"
            intErfolg = intErfolg + 1
        Else
            Debug.Print "Fehler (Code: " & intResult & ")"
            intFehler = intFehler + 1
        End If
        
NextPDF:
        Debug.Print ""
        
    Next vKey
    
    If NurMarkierte And intErfolg > 0 Then
        Debug.Print "=== SETZE AUSWAHL ZURÜCK ==="
        db.Execute "UPDATE tbl_MA_VA_Zuordnung SET Rch_Erstellt = False WHERE VA_ID = " & auftragsID & " AND Rch_Erstellt = True", dbFailOnError
        Debug.Print "Auswahl-Checkboxen zurückgesetzt"
        Debug.Print ""
    End If
    
    Set db = Nothing
    
    Debug.Print "=== ENDE MESSEZETTEL ==="
    Debug.Print "PDFs: " & dictPDFs.Count
    Debug.Print "Erfolg: " & intErfolg
    Debug.Print "Fehler: " & intFehler
    
    Dim strMsg As String
    strMsg = "Erledigt!" & vbCrLf & vbCrLf & "PDFs bearbeitet: " & intErfolg
    
    If intFehler > 0 Then
        strMsg = strMsg & vbCrLf & "Fehler: " & intFehler
    End If
    
    MsgBox strMsg, IIf(intFehler = 0, vbInformation, vbExclamation), "Messezettel"
    
    FuelleMessezettel_Intern = (intErfolg > 0)
    Exit Function
    
Err_Handler:
    Debug.Print "FEHLER " & Err.Number & ": " & Err.description
    MsgBox "Fehler " & Err.Number & ": " & Err.description, vbCritical
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close: Set rs = Nothing
    If Not rsAlle Is Nothing Then rsAlle.Close: Set rsAlle = Nothing
    If Not rsDatum Is Nothing Then rsDatum.Close: Set rsDatum = Nothing
    If Not rsMA Is Nothing Then rsMA.Close: Set rsMA = Nothing
    Set db = Nothing
    FuelleMessezettel_Intern = False
End Function


Private Function ExtrahiereStandnummerAusBemerkungen(Bemerkungen As String) As String
    Dim strHalle As String, strNummer As String, intPos As Integer
    Dim i As Integer, strChar As String, strRest As String
    
    intPos = InStr(1, Bemerkungen, "Halle ", vbTextCompare)
    If intPos = 0 Then: ExtrahiereStandnummerAusBemerkungen = "": Exit Function
    
    strRest = Mid(Bemerkungen, intPos + 6)
    strHalle = ""
    
    For i = 1 To Len(strRest)
        strChar = Mid(strRest, i, 1)
        If (strChar >= "0" And strChar <= "9") Or (strChar >= "A" And strChar <= "Z") Or (strChar >= "a" And strChar <= "z") Then
            strHalle = strHalle & strChar
        Else
            Exit For
        End If
    Next i
    
    intPos = InStr(1, strRest, "-")
    If intPos > 0 Then
        strRest = Mid(strRest, intPos + 1): strNummer = ""
        For i = 1 To Len(strRest)
            strChar = Mid(strRest, i, 1)
            If strChar >= "0" And strChar <= "9" Then strNummer = strNummer & strChar Else Exit For
        Next i
    End If
    
    If Len(strHalle) > 0 And Len(strNummer) > 0 Then
        ExtrahiereStandnummerAusBemerkungen = "H" & strHalle & " " & strNummer
    Else
        ExtrahiereStandnummerAusBemerkungen = ""
    End If
End Function


Private Function FindePDF_NachDatumUndStand(AuftragsDatum As Date, Standnummer As String) As String
    Dim strDatei As String, strDatum As String, arrDateien() As String, intAnzahl As Integer
    strDatum = Format(AuftragsDatum, "dd.mm.yyyy")
    strDatei = Dir(PDF_ORDNER & "\*.pdf"): intAnzahl = 0
    Do While Len(strDatei) > 0
        If InStr(1, strDatei, strDatum, vbTextCompare) > 0 And _
           InStr(1, strDatei, Standnummer, vbTextCompare) > 0 Then
            intAnzahl = intAnzahl + 1: ReDim Preserve arrDateien(1 To intAnzahl)
            arrDateien(intAnzahl) = strDatei
        End If
        strDatei = Dir()
    Loop
    If intAnzahl = 0 Then FindePDF_NachDatumUndStand = "" Else FindePDF_NachDatumUndStand = PDF_ORDNER & "\" & arrDateien(1)
End Function


Private Sub ErstelleBackup(pdfPfad As String)
On Error Resume Next
    Dim strBackup As String, strOrdner As String
    strOrdner = PDF_ORDNER & "\Z - abgerechnet"
    If Dir(strOrdner, vbDirectory) = "" Then MkDir strOrdner
    strBackup = strOrdner & "\" & Replace(Dir(pdfPfad), ".pdf", "_backup_" & Format(Now, "yyyymmdd_hhnnss") & ".pdf")
    FileCopy pdfPfad, strBackup
On Error GoTo 0
End Sub


'##############################
' FUNKTION 2: Bewachungsnachweise versenden
'##############################
Public Sub SendeBewachungsnachweise(frm As Form)
    On Error GoTo Err_Handler

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim rsAuftrag As DAO.Recordset
    Dim outlookApp As Object
    Dim outlookMail As Object

    Dim pdfPfad As String, empfaenger As String
    Dim maID As Long, auftragsID As Long
    Dim datArbeitsdatum As Date
    Dim strBemerkungen As String, strStandnummer As String
    Dim counter As Integer, anzahlPDFs As Integer
    Dim sendOk As Boolean
    Dim colPDFs As Collection
    Dim pdfDatei As Variant
    Dim mitarbeiterName As String
    Dim tStart As Single: tStart = Timer
    Dim strUpdateSQL As String
    Dim NurMarkierte As Boolean
    Dim intAntwort As Integer

    Dim dictMitarbeiter As Object
    Set dictMitarbeiter = CreateObject("Scripting.Dictionary")
    
    Dim iMA As Integer

    Debug.Print "--------------------------------------------"
    Debug.Print "Start: SendeBewachungsnachweise " & Now()
    Debug.Print ""

    intAntwort = MsgBox("Nur markierte Mitarbeiter versenden?" & vbCrLf & vbCrLf & _
                        "Ja = Nur markierte (Rch_Erstellt = Ja)" & vbCrLf & _
                        "Nein = ALLE Mitarbeiter" & vbCrLf & _
                        "Abbrechen = Vorgang abbrechen", _
                        vbQuestion + vbYesNoCancel, "Bewachungsnachweise versenden")

    Select Case intAntwort
        Case vbCancel
            Debug.Print "Abgebrochen durch Benutzer."
            Exit Sub
        Case vbYes
            NurMarkierte = True
            Debug.Print "Modus: NUR MARKIERTE (Rch_Erstellt = True)"
        Case vbNo
            NurMarkierte = False
            Debug.Print "Modus: ALLE MITARBEITER"
    End Select

    Debug.Print ""

    Set db = CurrentDb
    auftragsID = frm.ID
    
    Dim strSQLMitarbeiter As String
    strSQLMitarbeiter = "SELECT DISTINCT MA_ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & auftragsID
    
    If NurMarkierte Then
        strSQLMitarbeiter = strSQLMitarbeiter & " AND Rch_Erstellt = True"
    End If
    
    strSQLMitarbeiter = strSQLMitarbeiter & " AND MA_ID Is Not Null ORDER BY MA_ID"
    
    Debug.Print "SQL: " & strSQLMitarbeiter
    Debug.Print ""
    
    Set rs = db.OpenRecordset(strSQLMitarbeiter, dbOpenSnapshot)

    If (rs.BOF And rs.EOF) Then
        Debug.Print "Keine Datensätze gefunden – Vorgang abgebrochen."
        GoTo Exit_Handler
    End If

    Debug.Print "=== Sammle eindeutige Mitarbeiter ==="
    Do While Not rs.EOF
        maID = Nz(rs!MA_ID, 0)
        
        If maID > 0 Then
            dictMitarbeiter.Add maID, True
            Debug.Print "  + MA_ID " & maID & " hinzugefügt"
        End If

        rs.MoveNext
    Loop
    
    rs.Close: Set rs = Nothing

    Debug.Print "Insgesamt: " & dictMitarbeiter.Count & " eindeutige Mitarbeiter"
    Debug.Print ""

    If dictMitarbeiter.Count = 0 Then
        MsgBox "Keine Mitarbeiter zum Versenden gefunden!", vbExclamation
        GoTo Exit_Handler
    End If

    Debug.Print "=== Verarbeite jeden Mitarbeiter ==="
    Debug.Print ""

    Dim arrKeys As Variant
    If dictMitarbeiter.Count > 0 Then
        arrKeys = dictMitarbeiter.Keys
    Else
        MsgBox "Keine Mitarbeiter zum Versenden gefunden!", vbExclamation
        GoTo Exit_Handler
    End If

    For iMA = 0 To UBound(arrKeys)
        maID = CLng(arrKeys(iMA))
        
        Set colPDFs = New Collection
        mitarbeiterName = GetMitarbeiterAnzeigename(maID)

        Debug.Print "--------------------------------------------"
        Debug.Print "Mitarbeiter: " & mitarbeiterName & " (ID=" & maID & ")"
        Debug.Print "Suche zugehörige Termine und PDFs ..."

        Dim strWhereClause As String
        strWhereClause = "WHERE z.VA_ID = " & auftragsID & " AND z.MA_ID = " & maID
        
        If NurMarkierte Then
            strWhereClause = strWhereClause & " AND z.Rch_Erstellt = True"
        End If
        
        Set rsAuftrag = db.OpenRecordset( _
            "SELECT z.MA_ID, z.VADatum_ID, z.Bemerkungen, d.VADatum " & _
            "FROM tbl_MA_VA_Zuordnung AS z " & _
            "INNER JOIN tbl_VA_AnzTage AS d ON z.VADatum_ID = d.ID " & _
            strWhereClause & " " & _
            "ORDER BY d.VADatum", dbOpenSnapshot)

        Do While Not rsAuftrag.EOF
            datArbeitsdatum = rsAuftrag!VADatum
            strBemerkungen = Trim$(Nz(rsAuftrag!Bemerkungen, ""))
            strStandnummer = ExtrahiereStandnummerAusBemerkungen(strBemerkungen)

            If Len(strStandnummer) > 0 Then
                pdfPfad = FindePDF_NachDatumUndStand(datArbeitsdatum, strStandnummer)
                If Len(pdfPfad) > 0 Then
                    If Not IstPDFBereitsVorhanden(colPDFs, pdfPfad) Then
                        colPDFs.Add pdfPfad
                        Debug.Print "  PDF gefunden: " & Dir(pdfPfad)
                    End If
                Else
                    Debug.Print "  Kein PDF für " & Format(datArbeitsdatum, "dd.mm.yyyy") & " | Stand " & strStandnummer
                End If
            Else
                Debug.Print "  Keine Standnummer in Bemerkung (" & Format(datArbeitsdatum, "dd.mm.yyyy") & ")"
            End If
            rsAuftrag.MoveNext
        Loop
        rsAuftrag.Close: Set rsAuftrag = Nothing

        If colPDFs.Count > 0 Then
            Debug.Print "  " & colPDFs.Count & " PDF(s) gefunden – versende Mail..."
            
            empfaenger = GetMitarbeiterEmail(maID)
            
            If Len(empfaenger) = 0 Or InStr(empfaenger, "@") = 0 Then
                Debug.Print "  ! Ungültige oder fehlende E-Mail-Adresse: '" & empfaenger & "'"
                Debug.Print "  ! MAIL WIRD NICHT VERSENDET"
                GoTo NextMA
            End If

            Debug.Print "  E-Mail-Adresse: " & empfaenger

            If outlookApp Is Nothing Then Set outlookApp = CreateObject("Outlook.Application")
            sendOk = False

            On Error Resume Next
            Set outlookMail = outlookApp.CreateItem(0)
            If Err.Number <> 0 Then
                Debug.Print "  ! Fehler beim Erstellen der Mail: " & Err.description
                On Error GoTo Err_Handler
                GoTo NextMA
            End If
            On Error GoTo Err_Handler
            
            With outlookMail
                On Error Resume Next
                .TO = Trim$(empfaenger)
                
                If Err.Number <> 0 Then
                    Debug.Print "  ! Fehler beim Setzen des Empfängers: " & Err.description
                    Set outlookMail = Nothing
                    On Error GoTo Err_Handler
                    GoTo NextMA
                End If
                On Error GoTo Err_Handler
                
                .Subject = "Bewachungsnachweise Messe - " & mitarbeiterName & " (" & colPDFs.Count & " Dateien)"
                .HTMLBody = ErzeugeMailTextHTML()
                
                On Error Resume Next
                If Len(.TO) > 0 Then .Recipients.ResolveAll
                On Error GoTo Err_Handler

                For Each pdfDatei In colPDFs
                    .Attachments.Add CStr(pdfDatei)
                    Debug.Print "    Anhang: " & Dir(pdfDatei)
                Next pdfDatei

                Debug.Print "  Sende Mail an " & .TO & " ..."
                Err.clear
                On Error Resume Next
                .send
                sendOk = (Err.Number = 0)
                If Not sendOk Then
                    Debug.Print "    ! Fehler beim Senden: " & Err.description
                Else
                    Debug.Print "    Mail erfolgreich gesendet."
                End If
                On Error GoTo Err_Handler
            End With
            Set outlookMail = Nothing

            If sendOk And NurMarkierte Then
                strUpdateSQL = "UPDATE tbl_MA_VA_Zuordnung SET Rch_Erstellt = False " & _
                               "WHERE VA_ID = " & auftragsID & " AND MA_ID = " & maID
                
                On Error Resume Next
                db.Execute strUpdateSQL, dbFailOnError
                
                If Err.Number = 0 Then
                    Debug.Print "  Markierung zurückgesetzt"
                Else
                    Debug.Print "  ! Warnung beim Update: " & Err.description
                End If
                On Error GoTo Err_Handler
            End If

            If sendOk Then
                counter = counter + 1
                anzahlPDFs = anzahlPDFs + colPDFs.Count
            End If
        Else
            Debug.Print "  Keine PDFs für Mitarbeiter gefunden – keine Mail gesendet."
        End If

NextMA:
        Set colPDFs = Nothing
    Next iMA

    frm.sub_MA_VA_Zuordnung.Form.Requery

    Debug.Print ""
    Debug.Print "--------------------------------------------"
    Debug.Print "Modus: " & IIf(NurMarkierte, "NUR MARKIERTE", "ALLE")
    Debug.Print "E-Mails versendet: " & counter
    Debug.Print "PDFs versendet: " & anzahlPDFs
    Debug.Print "Fertig in " & Format(Timer - tStart, "0.00") & " Sekunden."
    Debug.Print "--------------------------------------------"

    MsgBox "Erledigt!" & vbCrLf & vbCrLf & _
           counter & " E-Mail(s) mit insgesamt " & anzahlPDFs & " PDF(s) versendet.", _
           vbInformation, "Versand abgeschlossen"

Exit_Handler:
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    If Not rsAuftrag Is Nothing Then rsAuftrag.Close
    Set rs = Nothing
    Set rsAuftrag = Nothing
    Set outlookMail = Nothing
    Set outlookApp = Nothing
    Set colPDFs = Nothing
    Set dictMitarbeiter = Nothing
    Set db = Nothing
    Exit Sub

Err_Handler:
    Debug.Print "! FEHLER: " & Err.Number & " - " & Err.description
    MsgBox "Fehler beim Senden der E-Mails: " & Err.description, vbCritical, "Fehler"
    Resume Exit_Handler
End Sub


Private Function IstPDFBereitsVorhanden(col As Collection, pdfPfad As String) As Boolean
    Dim item As Variant
    For Each item In col
        If StrComp(Trim$(CStr(item)), Trim$(pdfPfad), vbTextCompare) = 0 Then
            IstPDFBereitsVorhanden = True
            Exit Function
        End If
    Next item
End Function


Private Function GetMitarbeiterAnzeigename(ByVal maID As Long) As String
    On Error GoTo Fehler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim n As String, v As String, nm As String

    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID=" & maID, dbOpenSnapshot)

    If Not (rs.BOF And rs.EOF) Then
        n = SafeFld(rs, "Nachname")
        v = SafeFld(rs, "Vorname")
        If Len(n) = 0 Then n = SafeFld(rs, "MA_Nachname")
        If Len(v) = 0 Then v = SafeFld(rs, "MA_Vorname")
        nm = SafeFld(rs, "Name")
        If Len(nm) = 0 Then nm = SafeFld(rs, "MA_Name")
        If Len(nm) > 0 Then
            GetMitarbeiterAnzeigename = nm
        Else
            GetMitarbeiterAnzeigename = Trim$(v & " " & n)
        End If
    End If
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    If Len(GetMitarbeiterAnzeigename) = 0 Then GetMitarbeiterAnzeigename = "Mitarbeiter " & maID
    Exit Function
Fehler:
    Debug.Print "! Fehler beim Lesen von Mitarbeiter " & maID & ": " & Err.description
    GetMitarbeiterAnzeigename = "Mitarbeiter " & maID
End Function


Private Function GetMitarbeiterEmail(ByVal maID As Long) As String
    On Error GoTo Fehler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strEmail As String
    Dim i As Integer
    Dim feldGefunden As Boolean
    
    GetMitarbeiterEmail = ""
    strEmail = ""
    feldGefunden = False

    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID=" & maID, dbOpenSnapshot)
    
    If rs Is Nothing Then
        Debug.Print "! Recordset konnte nicht geöffnet werden für MA_ID " & maID
        GoTo Cleanup
    End If

    If Not (rs.BOF And rs.EOF) Then
        On Error Resume Next
        
        For i = 0 To rs.fields.Count - 1
            If UCase(rs.fields(i).Name) = "EMAIL" Then
                feldGefunden = True
                If Not IsNull(rs.fields(i).Value) Then
                    strEmail = CStr(rs.fields(i).Value)
                End If
                Exit For
            End If
        Next i
        
        If Not feldGefunden Then
            For i = 0 To rs.fields.Count - 1
                If InStr(1, UCase(rs.fields(i).Name), "MAIL") > 0 Then
                    feldGefunden = True
                    If Not IsNull(rs.fields(i).Value) Then
                        strEmail = CStr(rs.fields(i).Value)
                    End If
                    Exit For
                End If
            Next i
        End If
        
        On Error GoTo Fehler
        
        If feldGefunden Then
            strEmail = Trim$(strEmail)
            GetMitarbeiterEmail = strEmail
        End If
    End If

Cleanup:
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close: Set rs = Nothing
    If Not db Is Nothing Then Set db = Nothing
    Exit Function
    
Fehler:
    Debug.Print "! FEHLER GetMitarbeiterEmail (" & maID & "): " & Err.Number & " - " & Err.description
    GetMitarbeiterEmail = ""
    Resume Cleanup
End Function


Private Function SafeFld(ByVal rs As DAO.Recordset, ByVal fldName As String) As String
    On Error GoTo Fehlt
    SafeFld = Nz(rs.fields(fldName).Value, "")
    Exit Function
Fehlt:
    SafeFld = ""
End Function


Private Function ErzeugeMailTextHTML() As String
    Dim h As String

    h = "<html><body style='font-family:Arial,Helvetica,sans-serif;font-size:11pt;color:#000;'>"
    h = h & "<p>Hi,</p>"
    h = h & "<p>anbei Deine Bewachungsnachweise für die kommende Messe.</p>"
    h = h & "<p>Viele Grüße,</p>"
    h = h & "<div style='line-height:1.35;'>"
    h = h & "<p><span style='font-weight:bold;color:#003399;'>CONSEC Veranstaltungsservice &amp; Sicherheitsdienst oHG</span><br>"
    h = h & "<span style='font-weight:bold;'>Vogelweiherstr. 70</span><br>"
    h = h & "<span style='font-weight:bold;'>90441 Nürnberg</span></p>"
    h = h & "<p><span style='font-weight:bold;'>0911 - 40 99 77 99 (Tel.)</span><br>"
    h = h & "<span style='font-weight:bold;'>0911 - 40 99 77 92 (Fax)</span><br>"
    h = h & "<span style='font-weight:bold;'>0171 - 20 57 404 (Mobil)</span></p>"
    h = h & "<p>E-Mail: <a href='mailto:siegert@consec-nuernberg.de' style='color:#003399;text-decoration:none;'>siegert@consec-nuernberg.de</a><br>"
    h = h & "<a href='http://www.consec-nuernberg.de' style='color:#003399;text-decoration:none;'>http://www.consec-nuernberg.de</a></p>"
    h = h & "<p><span style='font-weight:bold;'>Geschäftsführer:</span> Melanie Oberndorfer, Günther Siegert<br>"
    h = h & "HR A 10816 Amtsgericht Nürnberg<br>Steuernr. 240/154/55205</p>"
    h = h & "<p><span style='font-weight:bold;'>Wir sind zertifiziert nach DIN</span><br>ISO 9001 &nbsp;&nbsp; 77200</p>"
    h = h & "</div>"
    h = h & "<p style='font-size:10pt;color:#555;margin-top:10px;'>"
    h = h & "Diese E-Mail könnte vertrauliche und/oder rechtlich geschützte Informationen enthalten. "
    h = h & "Wenn Sie nicht der richtige Adressat sind oder diese E-Mail irrtümlich erhalten haben, informieren Sie bitte sofort den Absender und vernichten Sie diese Mail. "
    h = h & "Das unerlaubte Kopieren, sowie die unbefugte Weitergabe dieser Mail sind nicht gestattet.</p>"
    h = h & "<p style='font-size:10pt;color:#008000;margin-top:6px;'>"
    h = h & "Bitte denken Sie an die Umwelt, bevor Sie diese E-Mail ausdrucken / Think before you print!!!</p>"
    h = h & "</body></html>"

    ErzeugeMailTextHTML = h
End Function

