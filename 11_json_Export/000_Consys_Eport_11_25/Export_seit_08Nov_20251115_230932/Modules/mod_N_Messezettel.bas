'Attribute VB_Name = "mod_N_Messezettel"
' ========================================
' CONSEC Messezettel - FINAL VERSION
' ========================================
' - Sicherere MsgBox
' - Auswahl wird automatisch zurückgesetzt
' - Alte Stempel werden überschrieben
' ========================================

Option Compare Database
Option Explicit

Private Const PDF_ORDNER As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\D - Messezettel"
Private Const PYTHON_SCRIPT As String = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\D - Messezettel\pdf_stempel.py"


Public Function FuelleMessezettel(auftragsID As Long) As Boolean
    
    ' === AUSWAHL-DIALOG (SICHERER!) ===
    Dim intAntwort As Integer
    intAntwort = MsgBox("Nur ausgewählte Standwachen bearbeiten?" & vbCrLf & vbCrLf & _
                        "JA = Nur markierte Standwachen (Auswahl = Ja)" & vbCrLf & _
                        "NEIN = Alle Standwachen" & vbCrLf & _
                        "ABBRECHEN = Vorgang abbrechen", _
                        vbQuestion + vbYesNoCancel, "Messezettel bearbeiten")
    
    If intAntwort = vbCancel Then
        FuelleMessezettel = False
        Exit Function
    End If
    
    If intAntwort = vbYes Then
        ' NUR MARKIERTE bearbeiten
        FuelleMessezettel = FuelleMessezettel_Intern(auftragsID, True)
    Else
        ' ALLE bearbeiten
        FuelleMessezettel = FuelleMessezettel_Intern(auftragsID, False)
    End If
    
End Function


Private Function FuelleMessezettel_Intern(auftragsID As Long, NurMarkierte As Boolean) As Boolean
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim rsDatum As DAO.Recordset
    Dim rsMA As DAO.Recordset
    
    Dim dictPDFs As Object
    Set dictPDFs = CreateObject("Scripting.Dictionary")
    
    Dim strMitarbeiterVorname As String
    Dim strMitarbeiterNachname As String
    Dim strMitarbeiterName As String
    Dim strStandnummer As String
    Dim strBemerkungen As String
    Dim datArbeitsdatum As Date
    Dim lngVADatumID As Long
    Dim lngMAID As Long
    Dim strPDFPfad As String
    Dim strCommand As String
    Dim strSQL As String
    
    Dim intErfolg As Integer, intFehler As Integer
    Dim arrMA() As String
    Dim vKey As Variant, arrMitarbeiter As Variant
    
    On Error GoTo Err_Handler
    
    Debug.Print "=== START " & IIf(NurMarkierte, "(NUR MARKIERTE)", "(ALLE)") & " ==="
    Debug.Print "Auftrag: " & auftragsID
    Debug.Print ""
    
    Set db = CurrentDb
    intErfolg = 0: intFehler = 0
    
    ' === SQL AUFBAUEN ===
    strSQL = "SELECT MA_ID, VADatum_ID, Bemerkungen FROM tbl_MA_VA_Zuordnung " & _
             "WHERE VA_ID = " & auftragsID
    
    If NurMarkierte Then
        strSQL = strSQL & " AND Auswahl = True"
    End If
    
    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
    
    If rs.EOF Then
        If NurMarkierte Then
            MsgBox "Keine markierten Standwachen gefunden!" & vbCrLf & vbCrLf & _
                   "Bitte setzen Sie bei den gewünschten Standwachen" & vbCrLf & _
                   "das Feld 'Auswahl' auf Ja.", vbExclamation, "Keine Auswahl"
        Else
            MsgBox "Keine Mitarbeiter gefunden!", vbExclamation
        End If
        rs.Close: Set rs = Nothing: Set db = Nothing
        FuelleMessezettel_Intern = False
        Exit Function
    End If
    
    Debug.Print "=== SAMMLE MITARBEITER PRO PDF ==="
    Debug.Print ""
    
    ' === JEDEN MA VERARBEITEN ===
    Do While Not rs.EOF
        
        lngMAID = Nz(rs!MA_ID, 0)
        lngVADatumID = Nz(rs!VADatum_ID, 0)
        strBemerkungen = Trim(Nz(rs!Bemerkungen, ""))
        
        If lngMAID > 0 And lngVADatumID > 0 And Len(strBemerkungen) > 0 Then
            
            Set rsDatum = db.OpenRecordset( _
                "SELECT VADatum FROM tbl_VA_AnzTage WHERE [ID] = " & lngVADatumID, _
                dbOpenSnapshot)
            
            If Not rsDatum.EOF Then
                datArbeitsdatum = rsDatum!VADatum
                rsDatum.Close: Set rsDatum = Nothing
                
                Set rsMA = db.OpenRecordset( _
                    "SELECT Vorname, Nachname FROM tbl_MA_Mitarbeiterstamm WHERE [ID] = " & lngMAID, _
                    dbOpenSnapshot)
                
                If Not rsMA.EOF Then
                    strMitarbeiterVorname = Trim(Nz(rsMA!Vorname, ""))
                    strMitarbeiterNachname = Trim(Nz(rsMA!Nachname, ""))
                    rsMA.Close: Set rsMA = Nothing
                    
                    ' OHNE KOMMA
                    strMitarbeiterName = strMitarbeiterNachname & " " & strMitarbeiterVorname
                    strStandnummer = ExtrahiereStandnummerAusBemerkungen(strBemerkungen)
                    
                    Debug.Print "MA: " & strMitarbeiterName
                    Debug.Print "  Datum: " & Format(datArbeitsdatum, "dd.mm.yyyy")
                    Debug.Print "  Stand: " & strStandnummer
                    
                    If Len(strStandnummer) > 0 Then
                        
                        strPDFPfad = FindePDF_NachDatumUndStand(datArbeitsdatum, strStandnummer)
                        
                        If Len(strPDFPfad) > 0 Then
                            
                            Debug.Print "  PDF: " & Dir(strPDFPfad)
                            
                            If dictPDFs.Exists(strPDFPfad) Then
                                arrMA = dictPDFs(strPDFPfad)
                                If UBound(arrMA) < 1 Then
                                    ReDim Preserve arrMA(UBound(arrMA) + 1)
                                    arrMA(UBound(arrMA)) = strMitarbeiterName
                                    dictPDFs(strPDFPfad) = arrMA
                                    Debug.Print "  -> Pos " & UBound(arrMA) + 1
                                Else
                                    Debug.Print "  ! Max 2 MA"
                                End If
                            Else
                                ReDim arrMA(0)
                                arrMA(0) = strMitarbeiterName
                                dictPDFs.Add strPDFPfad, arrMA
                                Debug.Print "  -> Pos 1"
                            End If
                        Else
                            Debug.Print "  ! Kein PDF"
                        End If
                    Else
                        Debug.Print "  ! Kein Stand"
                    End If
                    Debug.Print ""
                Else
                    If Not rsMA Is Nothing Then rsMA.Close: Set rsMA = Nothing
                End If
            Else
                If Not rsDatum Is Nothing Then rsDatum.Close: Set rsDatum = Nothing
            End If
        End If
        
        rs.MoveNext
    Loop
    
    rs.Close: Set rs = Nothing
    
    Debug.Print "=== BEARBEITE PDFs ==="
    Debug.Print ""
    
    ' === PDFs BEARBEITEN ===
    For Each vKey In dictPDFs.Keys
        
        strPDFPfad = CStr(vKey)
        arrMitarbeiter = dictPDFs(vKey)
        
        Debug.Print "PDF: " & Dir(strPDFPfad)
        Debug.Print "  MA: " & UBound(arrMitarbeiter) + 1
        
        Call ErstelleBackup(strPDFPfad)
        
        ' COMMAND MIT SAUBEREN QUOTES
        If UBound(arrMitarbeiter) = 0 Then
            Debug.Print "  1. " & arrMitarbeiter(0)
            ' NUR 1 MITARBEITER
            strCommand = "python """ & PYTHON_SCRIPT & """ """ & _
                         strPDFPfad & """ """ & strPDFPfad & """ """ & _
                         Replace(arrMitarbeiter(0), """", """""") & """ 1"
        Else
            Debug.Print "  1. " & arrMitarbeiter(0)
            Debug.Print "  2. " & arrMitarbeiter(1)
            ' 2 MITARBEITER
            strCommand = "python """ & PYTHON_SCRIPT & """ """ & _
                         strPDFPfad & """ """ & strPDFPfad & """ """ & _
                         Replace(arrMitarbeiter(0), """", """""") & """ """ & _
                         Replace(arrMitarbeiter(1), """", """""") & """"
        End If
        
        Debug.Print "  CMD: " & strCommand
        
        Dim objShell As Object
        Set objShell = CreateObject("WScript.Shell")
        Dim intResult As Integer
        intResult = objShell.Run(strCommand, 0, True)
        Set objShell = Nothing
        
        If intResult = 0 Then
            Debug.Print "  OK"
            intErfolg = intErfolg + 1
        Else
            Debug.Print "  Fehler (Code: " & intResult & ")"
            intFehler = intFehler + 1
        End If
        Debug.Print ""
    Next vKey
    
    ' === AUSWAHL ZURÜCKSETZEN ===
    If NurMarkierte And intErfolg > 0 Then
        Debug.Print "=== SETZE AUSWAHL ZURÜCK ==="
        db.Execute "UPDATE tbl_MA_VA_Zuordnung SET Auswahl = False WHERE VA_ID = " & auftragsID & " AND Auswahl = True", dbFailOnError
        Debug.Print "Auswahl-Checkboxen zurückgesetzt"
        Debug.Print ""
    End If
    
    Set db = Nothing
    
    Debug.Print "=== ENDE ==="
    Debug.Print "PDFs: " & dictPDFs.Count
    Debug.Print "Erfolg: " & intErfolg
    Debug.Print "Fehler: " & intFehler
    
    Dim strMsg As String
    strMsg = "Fertig!" & vbCrLf & vbCrLf
    If NurMarkierte Then
        strMsg = strMsg & "Nur markierte Standwachen" & vbCrLf
    Else
        strMsg = strMsg & "Alle Standwachen" & vbCrLf
    End If
    strMsg = strMsg & vbCrLf & _
             "PDFs bearbeitet: " & dictPDFs.Count & vbCrLf & _
             "Erfolgreich: " & intErfolg
    
    If intFehler > 0 Then
        strMsg = strMsg & vbCrLf & "Fehler: " & intFehler
    End If
    
    If NurMarkierte And intErfolg > 0 Then
        strMsg = strMsg & vbCrLf & vbCrLf & "Auswahl-Markierungen wurden zurückgesetzt."
    End If
    
    MsgBox strMsg, IIf(intFehler = 0, vbInformation, vbExclamation), "Messezettel"
    
    FuelleMessezettel_Intern = (intErfolg > 0)
    Exit Function
    
Err_Handler:
    Debug.Print "FEHLER " & err.Number & ": " & err.description
    MsgBox "Fehler " & err.Number & ": " & err.description, vbCritical
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close: Set rs = Nothing
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
        If strChar >= "0" And strChar <= "9" Then strHalle = strHalle & strChar Else Exit For
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
' Bewachungsnachweise versenden
'##############################
'###############################################################
'  SendeBewachungsnachweise
'  Ausgabe aller Schritte & Fehler ins Direktfenster
'###############################################################
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

    Debug.Print "--------------------------------------------"
    Debug.Print "Start: SendeBewachungsnachweise " & Now()

    Set db = CurrentDb
    Set rs = frm.sub_MA_VA_Zuordnung.Form.RecordsetClone
    auftragsID = frm.ID

    If (rs.BOF And rs.EOF) Then
        Debug.Print "Keine Datensätze gefunden – Vorgang abgebrochen."
        GoTo Exit_Handler
    End If

    rs.MoveFirst
    Do While Not rs.EOF
        If Nz(rs!Auswahl, False) = True Then
            maID = Nz(rs!MA_ID, 0)
            If maID > 0 Then
                Set colPDFs = New Collection
                mitarbeiterName = GetMitarbeiterAnzeigename(maID)

                Debug.Print "--------------------------------------------"
                Debug.Print "Mitarbeiter: " & mitarbeiterName & " (ID=" & maID & ")"
                Debug.Print "Suche zugehörige Termine und PDFs ..."

                ' Termine lesen
                Set rsAuftrag = db.OpenRecordset( _
                    "SELECT z.MA_ID, z.VADatum_ID, z.Bemerkungen, d.VADatum " & _
                    "FROM tbl_MA_VA_Zuordnung AS z " & _
                    "INNER JOIN tbl_VA_AnzTage AS d ON z.VADatum_ID = d.ID " & _
                    "WHERE z.VA_ID = " & auftragsID & " AND z.MA_ID = " & maID & " " & _
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
                                Debug.Print "  ? PDF gefunden: " & pdfPfad
                            End If
                        Else
                            Debug.Print "  ? Kein PDF für " & Format(datArbeitsdatum, "dd.mm.yyyy") & _
                                        " | Stand " & strStandnummer
                        End If
                    Else
                        Debug.Print "  Hinweis: Keine Standnummer in Bemerkung gefunden (" & _
                                    Format(datArbeitsdatum, "dd.mm.yyyy") & ")"
                    End If
                    rsAuftrag.MoveNext
                Loop
                rsAuftrag.Close: Set rsAuftrag = Nothing

                If colPDFs.Count > 0 Then
                    Debug.Print "? " & colPDFs.Count & " PDF(s) gefunden. Messezettel wird geprüft/erstellt ..."
                    Call FuelleMessezettel(auftragsID)

                    empfaenger = "siegert@consec-nuernberg.de"

                    If outlookApp Is Nothing Then Set outlookApp = CreateObject("Outlook.Application")
                    sendOk = False

                    Set outlookMail = outlookApp.CreateItem(0)
                    With outlookMail
                        .TO = empfaenger
                        .Subject = "Bewachungsnachweise Messe - " & mitarbeiterName & _
                                   " (" & colPDFs.Count & " Dateien)"
                        .HTMLBody = ErzeugeMailTextHTML()
                        If Len(.TO) > 0 Then .Recipients.ResolveAll

                        For Each pdfDatei In colPDFs
                            .Attachments.Add CStr(pdfDatei)
                        Next pdfDatei

                        Debug.Print "? Sende Mail an " & .TO & " ..."
                        err.clear
                        On Error Resume Next
                        .Send
                        sendOk = (err.Number = 0)
                        If Not sendOk Then
                            Debug.Print "  ? Fehler beim Senden: " & err.description
                        Else
                            Debug.Print "  ? Mail erfolgreich gesendet."
                        End If
                        On Error GoTo Err_Handler
                    End With
                    Set outlookMail = Nothing

                    If sendOk Then
                        rs.Edit
                        rs!Auswahl = False
                        rs.update
                        counter = counter + 1
                        anzahlPDFs = anzahlPDFs + colPDFs.Count
                    End If
                Else
                    Debug.Print "? Keine PDFs für Mitarbeiter gefunden – keine Mail gesendet."
                End If

                Set colPDFs = Nothing
            Else
                Debug.Print "? Ungültige MA_ID in Datensatz."
            End If
        End If
        rs.MoveNext
    Loop

    frm.sub_MA_VA_Zuordnung.Form.Requery

    Debug.Print "--------------------------------------------"
    Debug.Print counter & " Mail(s) mit insgesamt " & anzahlPDFs & " PDF(s) versendet."
    Debug.Print "Fertig in " & Format(Timer - tStart, "0.00") & " Sekunden."
    Debug.Print "--------------------------------------------"

    MsgBox counter & " Mail(s) mit insgesamt " & anzahlPDFs & " PDF(s) versendet.", _
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
    Set db = Nothing
    Exit Sub

Err_Handler:
    Debug.Print "? FEHLER: " & err.Number & " - " & err.description
    MsgBox "Fehler beim Senden der E-Mails: " & err.description, vbExclamation, "Fehler"
    Resume Exit_Handler
End Sub


'----------------------------------------------------------
' Prüft auf doppelte PDF-Pfade (Case-insensitive)
'----------------------------------------------------------
Private Function IstPDFBereitsVorhanden(col As Collection, pdfPfad As String) As Boolean
    Dim item As Variant
    For Each item In col
        If StrComp(Trim$(CStr(item)), Trim$(pdfPfad), vbTextCompare) = 0 Then
            IstPDFBereitsVorhanden = True
            Exit Function
        End If
    Next item
End Function


'----------------------------------------------------------
' Mitarbeitername robust ermitteln aus tbl_MA_Mitarbeiterstamm
'----------------------------------------------------------
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
    Debug.Print "? Fehler beim Lesen von Mitarbeiter " & maID & ": " & err.description
    GetMitarbeiterAnzeigename = "Mitarbeiter " & maID
End Function


'----------------------------------------------------------
' Sicheres Lesen von Feldwerten
'----------------------------------------------------------
Private Function SafeFld(ByVal rs As DAO.Recordset, ByVal fldName As String) As String
    On Error GoTo Fehlt
    SafeFld = Nz(rs.fields(fldName).Value, "")
    Exit Function
Fehlt:
    SafeFld = ""
End Function

Private Function ErzeugeMailTextHTML() As String
    Dim h As String

    h = ""
    h = h & "<html><body style='font-family:Arial,Helvetica,sans-serif;font-size:11pt;color:#000;'>"

    ' Einleitung
    h = h & "<p>Hi,</p>"
    h = h & "<p>anbei Deine Bewachungsnachweise für die kommende Messe.</p>"

    h = h & "<p>Viele Grüße,</p>"

    ' Signatur – Layout wie im Screenshot (ohne Bilder)
    h = h & "<div style='line-height:1.35;'>"
    h = h & "  <p>"
    h = h & "    <span style='font-weight:bold;color:#003399;'>CONSEC Veranstaltungsservice &amp; Sicherheitsdienst oHG</span><br>"
    h = h & "    <span style='font-weight:bold;'>Vogelweiherstr. 70</span><br>"
    h = h & "    <span style='font-weight:bold;'>90441 Nürnberg</span>"
    h = h & "  </p>"

    h = h & "  <p>"
    h = h & "    <span style='font-weight:bold;'>0911 - 40 99 77 99 (Tel.)</span><br>"
    h = h & "    <span style='font-weight:bold;'>0911 - 40 99 77 92 (Fax)</span><br>"
    h = h & "    <span style='font-weight:bold;'>0171 - 20 57 404 (Mobil)</span>"
    h = h & "  </p>"

    h = h & "  <p>"
    h = h & "    E-Mail: <a href='mailto:siegert@consec-nuernberg.de' style='color:#003399;text-decoration:none;'>siegert@consec-nuernberg.de</a><br>"
    h = h & "    <a href='http://www.consec-nuernberg.de' style='color:#003399;text-decoration:none;'>http://www.consec-nuernberg.de</a>"
    h = h & "  </p>"

    h = h & "  <p>"
    h = h & "    <span style='font-weight:bold;'>Geschäftsführer:</span> Melanie Oberndorfer, Günther Siegert<br>"
    h = h & "    HR A 10816 Amtsgericht Nürnberg<br>"
    h = h & "    Steuernr. 240/154/55205"
    h = h & "  </p>"

    h = h & "  <p>"
    h = h & "    <span style='font-weight:bold;'>Wir sind zertifiziert nach DIN</span><br>"
    h = h & "    ISO 9001 &nbsp;&nbsp; 77200"
    h = h & "  </p>"
    h = h & "</div>"

    ' Rechtlicher Hinweis
    h = h & "<p style='font-size:10pt;color:#555;margin-top:10px;'>"
    h = h & "Diese E-Mail könnte vertrauliche und/oder rechtlich geschützte Informationen enthalten. "
    h = h & "Wenn Sie nicht der richtige Adressat sind oder diese E-Mail irrtümlich erhalten haben, informieren Sie bitte sofort den Absender und vernichten Sie diese Mail. "
    h = h & "Das unerlaubte Kopieren, sowie die unbefugte Weitergabe dieser Mail sind nicht gestattet."
    h = h & "</p>"

    ' Umwelt-Hinweis (grün)
    h = h & "<p style='font-size:10pt;color:#008000;margin-top:6px;'>"
    h = h & "Bitte denken Sie an die Umwelt, bevor Sie diese E-Mail ausdrucken / Think before you print!!!"
    h = h & "</p>"

    h = h & "</body></html>"

    ErzeugeMailTextHTML = h
End Function