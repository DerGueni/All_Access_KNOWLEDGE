Attribute VB_Name = "mod_N_Messezettel"


' CONSEC Messezettel & Versand - VERSION v18 (erweitert)
' =====================================================
' - Stempel-Funktion wie bisher
' - Neue Workflows:
'       BWN_Beschriften_und_Drucken
'       BWN_Beschriften_und_Senden
' - Nur Seite 1 drucken (Python: extract_first)
' - Auswahl-Logik:
'       Wenn Rch_Erstellt=TRUE vorhanden -> nur Auswahl
'       Wenn keine Auswahl -> alle
' =====================================================

Option Compare Database
Option Explicit

Private Const PDF_ORDNER As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\D - Messezettel"
Private Const PYTHON_SCRIPT As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\D - Messezettel\pdf_stempel.py"
Private Const PDFTK_PATH As String = "C:\Program Files (x86)\PDFtk Server\bin\pdftk.exe"   ' Pfad zu pdftk.exe anpassen

' Druckername genau wie im Druckdialog
Private Const ZIEL_DRUCKER As String = "HP2D76FA (HP LaserJet Pro MFP 4102)"

#If VBA7 Then
    Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
        ByVal hwnd As LongPtr, _
        ByVal lpOperation As String, _
        ByVal lpFile As String, _
        ByVal lpParameters As String, _
        ByVal lpDirectory As String, _
        ByVal nShowCmd As Long) As LongPtr
#Else
    Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
        ByVal hwnd As Long, _
        ByVal lpOperation As String, _
        ByVal lpFile As String, _
        ByVal lpParameters As String, _
        ByVal lpDirectory As String, _
        ByVal nShowCmd As Long) As Long
#End If


'##############################
' FUNKTION 1: PDF-Stempel f llen
'   - NEU: Optionaler Parameter NurMarkierteFilter
'   - Wenn ausgelassen -> alter Dialog (Fallback)
'   - Wenn gesetzt     -> kein Dialog, direkte Steuerung
'##############################
Public Function FuelleMessezettel(auftragsID As Long, _
                                  Optional NurMarkierteFilter As Variant) As Boolean
    Dim intAntwort As Integer
    Dim NurMarkierte As Boolean
    
    ' Neue Steuerung von au en (Buttons)
    If Not IsMissing(NurMarkierteFilter) Then
        NurMarkierte = CBool(NurMarkierteFilter)
        FuelleMessezettel = FuelleMessezettel_Intern(auftragsID, NurMarkierte)
        Exit Function
    End If
    
    ' Fallback: alter Dialog bleibt f r evtl. andere Aufrufe
    intAntwort = MsgBox("Nur Auswahl bedrucken bzw versenden ?" & vbCrLf & vbCrLf & _
                        "Ja = Nur Auswahl" & vbCrLf & _
                        "Nein = Alle bedrucken bzw versenden", _
                        vbQuestion + vbYesNo, "Messezettel bearbeiten")
    
    NurMarkierte = (intAntwort = vbYes)
    FuelleMessezettel = FuelleMessezettel_Intern(auftragsID, NurMarkierte)
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
    ' SCHRITT 1: Welche Stand/Datum Kombinationen?
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
                   "Bitte setzen Sie bei den gew nschten Standwachen" & vbCrLf & _
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
        MsgBox "Keine g ltigen Stand/Datum Kombinationen gefunden!", vbExclamation
        Set db = Nothing
        FuelleMessezettel_Intern = False
        Exit Function
    End If
    
    ' ============================================
    ' SCHRITT 2: F r jede Stand/Datum alle MA holen
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
        
        ' Alle MA f r diesen Stand/Tag (ohne Markierungsfilter)
        strSQL = "SELECT z.MA_ID, z.Bemerkungen, z.MVA_Start " & _
                 "FROM tbl_MA_VA_Zuordnung AS z " & _
                 "INNER JOIN tbl_VA_AnzTage AS d ON z.VADatum_ID = d.ID " & _
                 "WHERE z.VA_ID = " & auftragsID & " " & _
                 "AND d.VADatum = #" & intMonat & "/" & intTag & "/" & intJahr & "# " & _
                 "ORDER BY z.MVA_Start"
        
        Set rsAlle = db.OpenRecordset(strSQL, dbOpenSnapshot)
        
        Set colMA = New Collection
        Set colZeiten = New Collection
        
        Debug.Print "  Suche MA f r Stand: " & strStandnummer
        
        Do While Not rsAlle.EOF
            lngMAID = Nz(rsAlle!MA_ID, 0)
            strBemerkungen = Trim(Nz(rsAlle!Bemerkungen, ""))
            dtmStartzeit = Nz(rsAlle!MVA_Start, #12:00:00 AM#)
            
            Dim strBemStand As String
            strBemStand = ExtrahiereStandnummerAusBemerkungen(strBemerkungen)
            
            Debug.Print "    Bem: " & Left(strBemerkungen, 25) & "... -> " & strBemStand & " = " & strStandnummer & "? " & (strBemStand = strStandnummer)
            
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
                        Debug.Print "      -> HINZUGEF GT: " & strMitarbeiterName & " (Start: " & Format(dtmStartzeit, "hh:nn") & ")"
                    Else
                        Debug.Print "      ->  BERSPRUNGEN (max 2 erreicht)"
                    End If
                Else
                    If Not rsMA Is Nothing Then rsMA.Close: Set rsMA = Nothing
                End If
            End If
            
            rsAlle.MoveNext
        Loop
        rsAlle.Close: Set rsAlle = Nothing
        
        Debug.Print "  Gesammelte MA f r PDF: " & colMA.Count
        
        If colMA.Count > 0 Then
            If Not dictPDFs.Exists(strPDFPfad) Then
                dictPDFs.Add strPDFPfad, colMA
                dictPDFZeiten.Add strPDFPfad, colZeiten
                Debug.Print "  -> " & colMA.Count & " MA f r dieses PDF gespeichert"
            End If
        End If
        
NextStandDatum:
        Debug.Print ""
    Next vKey
    
    ' ============================================
    ' SCHRITT 3: PDFs bearbeiten (Python Stempel)
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
    
    ' WICHTIG: Ab hier KEIN Zur cksetzen der Auswahl mehr!
    ' (Das erfolgt jetzt nach Druck/Versand, nicht beim Stempeln.)
    
    Set db = Nothing
    
  Debug.Print "=== ENDE MESSEZETTEL ==="
Debug.Print "PDFs: " & dictPDFs.Count
Debug.Print "Erfolg: " & intErfolg
Debug.Print "Fehler: " & intFehler

' Keine Meldung mehr anzeigen   nur R ckgabewert setzen
FuelleMessezettel_Intern = (intErfolg > 0)
Exit Function

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
    If intPos = 0 Then
        ExtrahiereStandnummerAusBemerkungen = ""
        Exit Function
    End If
    
    strRest = Mid(Bemerkungen, intPos + 6)
    strHalle = ""
    
    For i = 1 To Len(strRest)
        strChar = Mid(strRest, i, 1)
        If (strChar >= "0" And strChar <= "9") Or _
           (strChar >= "A" And strChar <= "Z") Or _
           (strChar >= "a" And strChar <= "z") Then
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
            If (strChar >= "0" And strChar <= "9") Or _
             (strChar >= "A" And strChar <= "Z") Or _
            (strChar >= "a" And strChar <= "z") Then
                strNummer = strNummer & strChar
            Else
                Exit For
            End If
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
    strDatei = Dir(PDF_ORDNER & "\*.pdf")
    intAnzahl = 0
    Do While Len(strDatei) > 0
        If InStr(1, strDatei, strDatum, vbTextCompare) > 0 And _
           InStr(1, strDatei, Standnummer, vbTextCompare) > 0 Then
            intAnzahl = intAnzahl + 1
            ReDim Preserve arrDateien(1 To intAnzahl)
            arrDateien(intAnzahl) = strDatei
        End If
        strDatei = Dir()
    Loop
    If intAnzahl = 0 Then
        FindePDF_NachDatumUndStand = ""
    Else
        FindePDF_NachDatumUndStand = PDF_ORDNER & "\" & arrDateien(1)
    End If
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
Public Sub SendeBewachungsnachweise(frm As Form, Optional Modus As Integer = 0)
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
    Dim dictMitarbeiter As Object
    Dim iMA As Integer
    Dim strSQLMitarbeiter As String

    Set dictMitarbeiter = CreateObject("Scripting.Dictionary")

    Debug.Print "--------------------------------------------"
    Debug.Print "Start: SendeBewachungsnachweise " & Now()
    Debug.Print "Modus: " & Modus & " (0=Alle, 1=Nur markierte Schichten, 2=Alle Schichten der markierten MA)"
    Debug.Print ""

    Set db = CurrentDb
    auftragsID = frm.ID
    
    ' 1) Mitarbeiterliste bestimmen
    strSQLMitarbeiter = "SELECT DISTINCT MA_ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & auftragsID & " AND MA_ID Is Not Null"
    
    Select Case Modus
        Case 0
            ' Alle Mitarbeiter des Auftrags
        Case 1, 2
            ' Nur Mitarbeiter, die mindestens eine markierte Schicht haben
            strSQLMitarbeiter = strSQLMitarbeiter & " AND Rch_Erstellt = True"
        Case Else
            GoTo Exit_Handler
    End Select
    
    strSQLMitarbeiter = strSQLMitarbeiter & " ORDER BY MA_ID"
    
    Debug.Print "SQL (Mitarbeiter): " & strSQLMitarbeiter
    Debug.Print ""
    
    Set rs = db.OpenRecordset(strSQLMitarbeiter, dbOpenSnapshot)

    If (rs.BOF And rs.EOF) Then
        Debug.Print "Keine Mitarbeiter gefunden   Vorgang abgebrochen."
        GoTo Exit_Handler
    End If

    Do While Not rs.EOF
        maID = Nz(rs!MA_ID, 0)
        If maID > 0 Then
            If Not dictMitarbeiter.Exists(maID) Then
                dictMitarbeiter.Add maID, True
                Debug.Print "  + MA_ID " & maID & " hinzugef gt"
            End If
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
    arrKeys = dictMitarbeiter.Keys

    For iMA = 0 To UBound(arrKeys)
        maID = CLng(arrKeys(iMA))
        
        Set colPDFs = New Collection
        mitarbeiterName = GetMitarbeiterAnzeigename(maID)

        Debug.Print "--------------------------------------------"
        Debug.Print "Mitarbeiter: " & mitarbeiterName & " (ID=" & maID & ")"
        Debug.Print "Suche zugeh rige Termine und PDFs ..."

        Dim strWhereClause As String
        strWhereClause = "WHERE z.VA_ID = " & auftragsID & " AND z.MA_ID = " & maID
        
        Select Case Modus
            Case 0
                ' alle Schichten dieses MA (kein Filter)
            Case 1
                ' nur markierte Schichten dieses MA
                strWhereClause = strWhereClause & " AND z.Rch_Erstellt = True"
            Case 2
                ' alle Schichten dieses MA (kein weiterer Filter)
            Case Else
                GoTo NextMA
        End Select
        
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
                    Debug.Print "  Kein PDF f r " & Format(datArbeitsdatum, "dd.mm.yyyy") & " | Stand " & strStandnummer
                End If
            Else
                Debug.Print "  Keine Standnummer in Bemerkung (" & Format(datArbeitsdatum, "dd.mm.yyyy") & ")"
            End If
            rsAuftrag.MoveNext
        Loop
        rsAuftrag.Close: Set rsAuftrag = Nothing

        If colPDFs.Count > 0 Then
            Debug.Print "  " & colPDFs.Count & " PDF(s) gefunden   versende Mail..."
            
            empfaenger = GetMitarbeiterEmail(maID)
            
            If Len(empfaenger) = 0 Or InStr(empfaenger, "@") = 0 Then
                Debug.Print "  ! Ung ltige oder fehlende E-Mail-Adresse: '" & empfaenger & "'"
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
                .Send
                sendOk = (Err.Number = 0)
                On Error GoTo Err_Handler
            End With
            Set outlookMail = Nothing

            ' Markierungen zur cksetzen nur, wenn wir mit markierten gearbeitet haben
            If sendOk And (Modus = 1 Or Modus = 2) Then
                strUpdateSQL = "UPDATE tbl_MA_VA_Zuordnung SET Rch_Erstellt = False " & _
                               "WHERE VA_ID = " & auftragsID & " AND MA_ID = " & maID & " AND Rch_Erstellt = True"
                
                On Error Resume Next
                db.Execute strUpdateSQL, dbFailOnError
                On Error GoTo Err_Handler
            End If

            If sendOk Then
                counter = counter + 1
                anzahlPDFs = anzahlPDFs + colPDFs.Count
            End If
        Else
            Debug.Print "  Keine PDFs f r Mitarbeiter gefunden   keine Mail gesendet."
        End If

NextMA:
        Set colPDFs = Nothing
    Next iMA

    frm.sub_MA_VA_Zuordnung.Form.Requery

    Debug.Print ""
    Debug.Print "--------------------------------------------"
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
        Debug.Print "! Recordset konnte nicht ge ffnet werden f r MA_ID " & maID
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
    h = h & "<p>anbei Deine Bewachungsnachweise f r die kommende Messe.</p>"
    h = h & "<p>Viele Gr  e,</p>"
    h = h & "<div style='line-height:1.35;'>"
    h = h & "<p><span style='font-weight:bold;color:#003399;'>CONSEC Veranstaltungsservice &amp; Sicherheitsdienst oHG</span><br>"
    h = h & "<span style='font-weight:bold;'>Vogelweiherstr. 70</span><br>"
    h = h & "<span style='font-weight:bold;'>90441 N rnberg</span></p>"
    h = h & "<p><span style='font-weight:bold;'>0911 - 40 99 77 99 (Tel.)</span><br>"
    h = h & "<span style='font-weight:bold;'>0911 - 40 99 77 92 (Fax)</span><br>"
    h = h & "<span style='font-weight:bold;'>0171 - 20 57 404 (Mobil)</span></p>"
    h = h & "<p>E-Mail: <a href='mailto:siegert@consec-nuernberg.de' style='color:#003399;text-decoration:none;'>siegert@consec-nuernberg.de</a><br>"
    h = h & "<a href='http://www.consec-nuernberg.de' style='color:#003399;text-decoration:none;'>http://www.consec-nuernberg.de</a></p>"
    h = h & "<p><span style='font-weight:bold;'>Gesch ftsf hrer:</span> Melanie Oberndorfer, G nther Siegert<br>"
    h = h & "HR A 10816 Amtsgericht N rnberg<br>Steuernr. 240/154/55205</p>"
    h = h & "<p><span style='font-weight:bold;'>Wir sind zertifiziert nach DIN</span><br>ISO 9001 &nbsp;&nbsp; 77200</p>"
    h = h & "</div>"
    h = h & "<p style='font-size:10pt;color:#555;margin-top:10px;'>"
    h = h & "Diese E-Mail k nnte vertrauliche und/oder rechtlich gesch tzte Informationen enthalten. "
    h = h & "Wenn Sie nicht der richtige Adressat sind oder diese E-Mail irrt mlich erhalten haben, informieren Sie bitte sofort den Absender und vernichten Sie diese Mail. "
    h = h & "Das unerlaubte Kopieren, sowie die unbefugte Weitergabe dieser Mail sind nicht gestattet.</p>"
    h = h & "<p style='font-size:10pt;color:#008000;margin-top:6px;'>"
    h = h & "Bitte denken Sie an die Umwelt, bevor Sie diese E-Mail ausdrucken / Think before you print!!!</p>"
    h = h & "</body></html>"

    ErzeugeMailTextHTML = h
End Function
Public Sub DruckeBewachungsnachweise(frm As Form, Optional Modus As Integer = 0)
    On Error GoTo Err_Handler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim auftragsID As Long
    Dim datArbeitsdatum As Date
    Dim strBemerkungen As String
    Dim strStandnummer As String
    Dim pdfPfad As String
    
    Dim colPDFs As Collection
    Dim vItem As Variant
    Dim intGedruckt As Long
    Dim intFehler As Long
    Dim tStart As Single
    Dim strSQL As String
    
    tStart = Timer
    
    Debug.Print "--------------------------------------------"
    Debug.Print "Start: DruckeBewachungsnachweise " & Now()
    Debug.Print "Modus: " & Modus & " (0=Alle, 1=Nur markierte Schichten, 2=Alle Schichten der markierten MA)"
    Debug.Print ""
    
    Set db = CurrentDb
    auftragsID = frm.ID
    
    ' Grund-Select
    strSQL = "SELECT z.VADatum_ID, z.Bemerkungen, d.VADatum, z.MA_ID " & _
             "FROM tbl_MA_VA_Zuordnung AS z " & _
             "INNER JOIN tbl_VA_AnzTage AS d ON z.VADatum_ID = d.ID " & _
             "WHERE z.VA_ID = " & auftragsID
    
    Select Case Modus
        Case 0
            ' Alle Schichten aller Mitarbeiter -> kein weiterer Filter
        Case 1
            ' Nur die markierten Schichten
            strSQL = strSQL & " AND z.Rch_Erstellt = True"
        Case 2
            ' Alle Schichten aller markierten Mitarbeiter
            strSQL = strSQL & _
                " AND z.MA_ID IN (" & _
                "SELECT DISTINCT MA_ID FROM tbl_MA_VA_Zuordnung " & _
                "WHERE VA_ID=" & auftragsID & " AND Rch_Erstellt=True AND MA_ID Is Not Null)"
        Case Else
            ' unbekannter Modus -> abbrechen
            GoTo Exit_Handler
    End Select
    
    strSQL = strSQL & " ORDER BY d.VADatum"
    
    Debug.Print "SQL (Druck): " & strSQL
    Debug.Print ""
    
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
    
    If (rs.BOF And rs.EOF) Then
        MsgBox "Keine Schichten zum Drucken gefunden!", vbExclamation, "Drucken"
        GoTo Exit_Handler
    End If
    
    Set colPDFs = New Collection
    
    Debug.Print "=== Sammle zu druckende PDFs ==="
    
    Do While Not rs.EOF
        datArbeitsdatum = rs!VADatum
        strBemerkungen = Trim$(Nz(rs!Bemerkungen, ""))
        strStandnummer = ExtrahiereStandnummerAusBemerkungen(strBemerkungen)
        
        If Len(strStandnummer) > 0 Then
            pdfPfad = FindePDF_NachDatumUndStand(datArbeitsdatum, strStandnummer)
            If Len(pdfPfad) > 0 Then
                On Error Resume Next
                colPDFs.Add pdfPfad, LCase$(pdfPfad)
                If Err.Number = 0 Then
                    Debug.Print "  PDF hinzugef gt: " & Dir(pdfPfad)
                Else
                    Err.clear
                End If
                On Error GoTo Err_Handler
            Else
                Debug.Print "  Kein PDF f r " & Format(datArbeitsdatum, "dd.mm.yyyy") & " | Stand " & strStandnummer
            End If
        Else
            Debug.Print "  Keine Standnummer in Bemerkung (" & Format(datArbeitsdatum, "dd.mm.yyyy") & ")"
        End If
        
        rs.MoveNext
    Loop
    rs.Close: Set rs = Nothing
    
    Debug.Print ""
    Debug.Print "Zu druckende eindeutige PDFs: " & colPDFs.Count
    Debug.Print ""
    
    If colPDFs.Count = 0 Then
        MsgBox "Keine PDFs zum Drucken gefunden!", vbExclamation, "Drucken"
        GoTo Exit_Handler
    End If
    
    For Each vItem In colPDFs
        pdfPfad = CStr(vItem)
        Debug.Print "Drucke: " & pdfPfad
        
        If DruckeNurErsteSeite(pdfPfad) Then
            intGedruckt = intGedruckt + 1
        Else
            intFehler = intFehler + 1
        End If
    Next vItem
    
    Debug.Print ""
    Debug.Print "--------------------------------------------"
    Debug.Print "PDFs gedruckt: " & intGedruckt
    Debug.Print "Fehler: " & intFehler
    Debug.Print "Fertig in " & Format(Timer - tStart, "0.00") & " Sekunden."
    Debug.Print "--------------------------------------------"
    
    ' Markierungen zur cksetzen:
    ' Modus 0: alle Schichten gedruckt -> alles zur cksetzen
    ' Modus 1/2: nur markierte / alle Schichten der markierten MA -> markierte zur cksetzen
    Select Case Modus
        Case 0
            On Error Resume Next
            db.Execute "UPDATE tbl_MA_VA_Zuordnung SET Rch_Erstellt = False " & _
                       "WHERE VA_ID = " & auftragsID, dbFailOnError
            On Error GoTo Err_Handler
        Case 1, 2
            On Error Resume Next
            db.Execute "UPDATE tbl_MA_VA_Zuordnung SET Rch_Erstellt = False " & _
                       "WHERE VA_ID = " & auftragsID & " AND Rch_Erstellt = True", dbFailOnError
            On Error GoTo Err_Handler
    End Select
    
    MsgBox "Druck abgeschlossen!" & vbCrLf & vbCrLf & _
           "PDFs gedruckt: " & intGedruckt & IIf(intFehler > 0, vbCrLf & "Fehler: " & intFehler, ""), _
           IIf(intFehler = 0, vbInformation, vbExclamation), "Drucken"

Exit_Handler:
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set colPDFs = Nothing
    Set db = Nothing
    Exit Sub

Err_Handler:
    Debug.Print "! FEHLER: " & Err.Number & " - " & Err.description
    MsgBox "Fehler beim Drucken der Bewachungsnachweise: " & Err.description, vbCritical, "Fehler"
    Resume Exit_Handler
End Sub




' -------------------------------------------------------------------
' Erstellt mit pdftk eine 1-Seiten-PDF und druckt diese.
' Fallback: Wenn pdftk fehlt ? komplette PDF drucken
' -------------------------------------------------------------------
Private Function DruckeNurErsteSeite(pdfPfad As String) As Boolean
    Dim tmpPDF As String
    Dim cmd As String
    Dim wsh As Object
    Dim intResult As Long
    
    On Error GoTo Err_Handler

    ' Sicherheitspr fung
    If Len(Dir(pdfPfad)) = 0 Then
        Debug.Print "PDF nicht gefunden: " & pdfPfad
        Exit Function
    End If

    ' Temp-Datei f r die 1-Seiten-PDF
    tmpPDF = Environ$("TEMP") & "\BW_" & Replace(Dir(pdfPfad), ".pdf", "") & "_page1.pdf"

    ' -----------------------------
    ' 1) pdftk pr fen
    ' -----------------------------
    Const PDFTK_PATH As String = "C:\Program Files (x86)\PDFtk\bin\pdftk.exe"

    If Len(Dir(PDFTK_PATH)) > 0 Then
        ' -----------------------------
        ' pdftk ist verf gbar ? erste Seite extrahieren
        ' -----------------------------
        cmd = """" & PDFTK_PATH & """ """ & pdfPfad & """ cat 1 output """ & tmpPDF & """"
        Debug.Print "CMD pdftk: " & cmd

        Set wsh = CreateObject("WScript.Shell")
        intResult = wsh.Run(cmd, 0, True)
        Set wsh = Nothing

        Debug.Print "pdftk Exit-Code: " & intResult

        If intResult = 0 And Len(Dir(tmpPDF)) > 0 Then
            ' 1-Seiten-PDF erfolgreich erzeugt ? jetzt drucken
            If DruckePDFDatei(tmpPDF) Then
                DruckeNurErsteSeite = True
            Else
                DruckeNurErsteSeite = False
            End If

            ' Temp-Datei nur l schen, wenn Foxit stabil arbeitet:
            'On Error Resume Next
            'Kill tmpPDF

            Exit Function
        Else
            Debug.Print "pdftk konnte Datei nicht erstellen   Fallback auf Voll-PDF."
        End If
    Else
        Debug.Print "pdftk nicht gefunden   drucke komplette PDF."
    End If

    ' -----------------------------
    ' 2) Fallback: komplette PDF drucken
    ' -----------------------------
    DruckeNurErsteSeite = DruckePDFDatei(pdfPfad)
    Exit Function

Err_Handler:
    Debug.Print "Fehler DruckeNurErsteSeite: " & Err.Number & " - " & Err.description
    DruckeNurErsteSeite = False
End Function


Private Function DruckePDFDatei(ByVal pdfPfad As String) As Boolean
#If VBA7 Then
    Dim ret As LongPtr
#Else
    Dim ret As Long
#End If
    
    If Len(Dir(pdfPfad)) = 0 Then
        Debug.Print "PDF zum Drucken nicht gefunden: " & pdfPfad
        Exit Function
    End If
    
    If Len(ZIEL_DRUCKER) > 0 Then
        ret = ShellExecute(0, "printto", pdfPfad, """" & ZIEL_DRUCKER & """", vbNullString, 0)
    Else
        ret = ShellExecute(0, "print", pdfPfad, vbNullString, vbNullString, 0)
    End If
    
    DruckePDFDatei = (ret > 32)
    
    If Not DruckePDFDatei Then
        Debug.Print "ShellExecute-Fehler beim Drucken: R ckgabewert=" & ret
    End If
End Function

Public Sub BWN_Beschriften_und_Drucken(frm As Form)
    Dim auftragsID As Long
    Dim lngMarkiert As Long
    Dim Modus As Integer
    Dim intAntwort As Integer
    
    On Error GoTo Err_Handler
    DoCmd.Hourglass True
    Application.Echo False
    
    If frm Is Nothing Then GoTo CleanExit
    If IsNull(frm!ID) Then
        MsgBox "Bitte Auftrag ausw hlen!", vbExclamation
        GoTo CleanExit
    End If
    
    auftragsID = frm!ID
    
    ' Wie viele Schichten sind markiert?
    lngMarkiert = Nz(DCount("*", "tbl_MA_VA_Zuordnung", _
                      "VA_ID = " & auftragsID & " AND Rch_Erstellt = True"), 0)
    
    If lngMarkiert > 0 Then
        ' Es gibt markierte Schichten
        intAntwort = MsgBox("Alle BWN f r diese Mitarbeiter drucken ?", _
                            vbQuestion + vbYesNoCancel, "Bewachungsnachweise drucken")
        Select Case intAntwort
            Case vbYes
                ' Alle Schichten aller markierten Mitarbeiter
                Modus = 2
            Case vbNo
                ' Nur die markierten Schichten
                Modus = 1
            Case vbCancel
                GoTo CleanExit
            Case Else
                GoTo CleanExit
        End Select
    Else
        ' Keine Auswahl -> alles wie gehabt
        intAntwort = MsgBox("Alle BWN beschriften und ausdrucken ?", _
                            vbQuestion + vbYesNo, "Bewachungsnachweise drucken")
        If intAntwort <> vbYes Then GoTo CleanExit
        Modus = 0    ' Alle Schichten aller Mitarbeiter
    End If
    
    ' Beschriften:
    ' Modus 1 = nur markierte Schichten -> NurMarkierte=True
    ' Modus 0/2 = alle Schichten -> NurMarkierte=False
    If Not FuelleMessezettel(auftragsID, (Modus = 1)) Then GoTo CleanExit
    
    ' Drucken mit Modus
    Call DruckeBewachungsnachweise(frm, Modus)

CleanExit:
    On Error Resume Next
    DoCmd.Hourglass False
    Application.Echo True
    Exit Sub

Err_Handler:
    Debug.Print "Fehler in BWN_Beschriften_und_Drucken: " & Err.Number & " - " & Err.description
    MsgBox "Fehler beim Beschriften/Drucken der Bewachungsnachweise:" & vbCrLf & Err.description, vbCritical, "Fehler"
    Resume CleanExit
End Sub



Public Sub BWN_Beschriften_und_Senden(frm As Form)
    Dim auftragsID As Long
    Dim lngMarkiert As Long
    Dim Modus As Integer
    Dim intAntwort As Integer
    
    On Error GoTo Err_Handler
    DoCmd.Hourglass True
    Application.Echo False
    
    If frm Is Nothing Then GoTo CleanExit
    If IsNull(frm!ID) Then
        MsgBox "Bitte Auftrag ausw hlen!", vbExclamation
        GoTo CleanExit
    End If
    
    auftragsID = frm!ID
    
    ' Wie viele Schichten sind markiert?
    lngMarkiert = Nz(DCount("*", "tbl_MA_VA_Zuordnung", _
                      "VA_ID = " & auftragsID & " AND Rch_Erstellt = True"), 0)
    
    If lngMarkiert > 0 Then
        ' Es gibt markierte Schichten
        intAntwort = MsgBox("Alle BWN f r diese Mitarbeiter versenden ?", _
                            vbQuestion + vbYesNoCancel, "Bewachungsnachweise versenden")
        Select Case intAntwort
            Case vbYes
                ' Alle Schichten aller markierten Mitarbeiter
                Modus = 2
            Case vbNo
                ' Nur die markierten Schichten
                Modus = 1
            Case vbCancel
                GoTo CleanExit
            Case Else
                GoTo CleanExit
        End Select
    Else
        ' Keine Auswahl -> alles wie gehabt
        intAntwort = MsgBox("Alle BWN beschriften und versenden ?", _
                            vbQuestion + vbYesNo, "Bewachungsnachweise versenden")
        If intAntwort <> vbYes Then GoTo CleanExit
        Modus = 0    ' Alle Schichten aller Mitarbeiter
    End If
    
    ' Beschriften:
    ' Modus 1 = nur markierte Schichten -> NurMarkierte=True
    ' Modus 0/2 = alle Schichten -> NurMarkierte=False
    If Not FuelleMessezettel(auftragsID, (Modus = 1)) Then GoTo CleanExit
    
    ' Versenden mit Modus
    Call SendeBewachungsnachweise(frm, Modus)

CleanExit:
    On Error Resume Next
    DoCmd.Hourglass False
    Application.Echo True
    Exit Sub

Err_Handler:
    Debug.Print "Fehler in BWN_Beschriften_und_Senden: " & Err.Number & " - " & Err.description
    MsgBox "Fehler beim Beschriften/Versenden der Bewachungsnachweise:" & vbCrLf & Err.description, vbCritical, "Fehler"
    Resume CleanExit
End Sub






