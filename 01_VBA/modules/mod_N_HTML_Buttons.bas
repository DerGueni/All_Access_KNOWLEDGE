Attribute VB_Name = "mod_N_HTML_Buttons"
' ============================================================================
' Modul: mod_N_HTML_Buttons
' Zweck: Public Wrapper-Funktionen fuer HTML-Button Aufrufe via VBA Bridge
' Erstellt: 2026-01-15
' ============================================================================
' Diese Funktionen fuehren exakt die gleichen Ablaeufe aus wie die
' Original-Access-Buttons, koennen aber von extern aufgerufen werden.
' ============================================================================

' ============================================================================
' btnMailEins_Click - Einsatzliste per E-Mail an MA senden
' Original: Form_frm_VA_Auftragstamm.btnMailEins_Click
' Autosend Typ 2 = MA Einsatzliste
' ============================================================================
Public Function HTML_btnMailEins_Click(VA_ID As Long, VADatum_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim i1 As Long

    ' Refresh wie im Original
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    ' Kein Filter auf Zeitraum (wie im Original)
    Set_Priv_Property "prp_Report1_Auftrag_IstTage", "-1"

    ' Pruefe ob MA-Zuordnungen vorhanden
    i1 = TCount("*", "tbl_MA_VA_Zuordnung", "VADatum_ID = " & VADatum_ID & " AND VA_ID = " & VA_ID & " AND MA_ID > 0")

    If i1 > 0 Then
        ' Oeffne Serien-E-Mail Formular
        DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
        DoEvents
        Wait 2 ' Sekunden wie im Original

        ' Rufe Autosend auf (2 = MA Einsatzliste)
        Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(2, VA_ID, VADatum_ID)

        HTML_btnMailEins_Click = "OK - E-Mails werden versendet"
    Else
        HTML_btnMailEins_Click = "Keine Mitarbeiter vorhanden"
    End If

    Exit Function

ErrorHandler:
    HTML_btnMailEins_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' btn_Autosend_BOS - Einsatzliste an BOS (Betriebsordnungsstelle) senden
' Original: Form_frm_VA_Auftragstamm.btn_Autosend_BOS_Click
' Autosend Typ 4 = BOS
' NUR fuer Veranstalter_ID: 10720, 20770, 20771
' ============================================================================
Public Function HTML_btn_Autosend_BOS_Click(VA_ID As Long, VADatum_ID As Long, Veranstalter_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim i1 As Long
    Dim strEmpfaenger As String

    ' Pruefe ob BOS-Auftrag (nur bestimmte Veranstalter)
    If Veranstalter_ID = 10720 Or Veranstalter_ID = 20770 Or Veranstalter_ID = 20771 Then

        DoEvents
        DBEngine.Idle dbRefreshCache
        DBEngine.Idle dbFreeLocks
        DoEvents

        Set_Priv_Property "prp_Report1_Auftrag_IstTage", "-1"

        i1 = TCount("*", "tbl_MA_VA_Zuordnung", "VADatum_ID = " & VADatum_ID & " AND VA_ID = " & VA_ID & " AND MA_ID > 0")

        ' BOS Empfaenger-Adressen (wie im Original)
        strEmpfaenger = "marcus.wuest@bos-franken.de; sb-dispo@bos-franken.de; frank.fischer@bos-franken.de"

        If i1 > 0 Then
            DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
            DoEvents
            Wait 2

            ' Autosend Typ 4 = BOS mit speziellem Empfaenger
            Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(4, VA_ID, VADatum_ID, strEmpfaenger)

            HTML_btn_Autosend_BOS_Click = "OK - BOS E-Mails werden versendet"
        Else
            HTML_btn_Autosend_BOS_Click = "Keine Mitarbeiter vorhanden"
        End If

        DoEvents
        DBEngine.Idle dbRefreshCache
        DBEngine.Idle dbFreeLocks
        DoEvents

    Else
        HTML_btn_Autosend_BOS_Click = "Kein BOS-Auftrag (Veranstalter_ID muss 10720, 20770 oder 20771 sein)"
    End If

    Exit Function

ErrorHandler:
    HTML_btn_Autosend_BOS_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' btnMailSub - Einsatzliste an Subunternehmer senden
' Original: Form_frm_VA_Auftragstamm.btnMailSub_Click
' Autosend Typ 5 = Subunternehmer
' ============================================================================
Public Function HTML_btnMailSub_Click(VA_ID As Long, VADatum_ID As Long) As String
    On Error GoTo ErrorHandler

    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    If VA_ID > 0 Then
        DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"
        DoEvents

        ' Autosend Typ 5 = Subunternehmer
        Call Form_frm_MA_Serien_eMail_Auftrag.Autosend(5, VA_ID, VADatum_ID)

        HTML_btnMailSub_Click = "OK - Subunternehmer E-Mails werden versendet"
    Else
        HTML_btnMailSub_Click = "Keine Mitarbeiter vorhanden"
    End If

    Exit Function

ErrorHandler:
    HTML_btnMailSub_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' btnDruckZusage - Excel-Export der Einsatzliste + Status auf Beendet
' Original: Form_frm_VA_Auftragstamm.btnDruckZusage_Click
' ============================================================================
Public Function HTML_btnDruckZusage_Click(VA_ID As Long, Auftrag As String, Objekt As String, Dat_VA_Von As String) As String
    On Error GoTo ErrorHandler

    Dim SDatum As String
    Dim strPfad As String
    Dim strDatei As String
    Dim c As Integer

    ' Datum formatieren wie im Original (MM-DD-YY)
    ' Eingabe erwartet: DD.MM.YYYY
    If Len(Dat_VA_Von) >= 10 Then
        SDatum = Mid(Dat_VA_Von, 4, 2) & "-" & Left(Dat_VA_Von, 2) & "-" & Right(Dat_VA_Von, 2)
    Else
        SDatum = Format(Date, "mm-dd-yy")
    End If

    ' Pfad wie im Original (consys Pfad)
    strPfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & "CONSEC\CONSEC PLANUNG AKTUELL\"
    strDatei = SDatum & " " & Auftrag & " " & Objekt & ".xlsm"

    ' Excel-Export ausfuehren
    Call fXL_Export_Auftrag(VA_ID, strPfad, strDatei)

    ' Warten wie im Original
    Sleep 1000
    For c = 1 To 10000
        DoEvents
    Next c
    Sleep 1000

    ' Status auf Beendet setzen (Veranst_Status_ID = 2)
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    On Error Resume Next
    ' Status-Update via SQL
    CurrentDb.Execute "UPDATE tbl_VA_Auftragstamm SET Veranst_Status_ID = 2 WHERE ID = " & VA_ID, dbFailOnError
    On Error GoTo ErrorHandler

    Wait 2

    HTML_btnDruckZusage_Click = "OK - Excel erstellt: " & strPfad & strDatei & " - Status auf Beendet gesetzt"

    Exit Function

ErrorHandler:
    HTML_btnDruckZusage_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' btn_ListeStd - ESS Namensliste/Stundenliste exportieren
' Original: Form_frm_VA_Auftragstamm.btn_ListeStd_Click
' Ruft Stundenliste_erstellen aus zmd_Listen auf
' ============================================================================
Public Function HTML_btn_ListeStd_Click(VA_ID As Long, Veranstalter_ID As Long) As String
    On Error GoTo ErrorHandler

    ' Ruft Original-Funktion aus zmd_Listen auf (wie im Access-Button)
    ' Signatur: Stundenliste_erstellen(VA_ID As Long, Optional MA_ID As Long, Optional kun_ID As Long)
    ' Im Original: Stundenliste_erstellen Me.ID, , Me.Veranstalter_ID
    Call Stundenliste_erstellen(VA_ID, , Veranstalter_ID)

    HTML_btn_ListeStd_Click = "OK - Stundenliste/Namensliste erstellt"

    Exit Function

ErrorHandler:
    HTML_btn_ListeStd_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' btn_BWN_Druck - BWN Meldeliste drucken (FCN/Fuerth)
' Original: Form_frm_VA_Auftragstamm.btn_BWN_Druck_Click
' HINWEIS: Der Original-Button ist in Access auskommentiert!
' Diese Funktion ist NICHT aktiv im Original-Access-Formular.
' ============================================================================
Public Function HTML_btn_BWN_Druck_Click(VA_ID As Long, Veranstalter_ID As Long) As String
    On Error GoTo ErrorHandler

    ' HINWEIS: Im Original Access ist btn_BWN_Druck_Click AUSKOMMENTIERT!
    ' Der Button ruft normalerweise DruckeBewachungsnachweise(Me) auf,
    ' aber diese Funktion existiert nicht im aktuellen Code.
    HTML_btn_BWN_Druck_Click = "HINWEIS: BWN Druck ist im Original-Access deaktiviert"

    Exit Function

ErrorHandler:
    HTML_btn_BWN_Druck_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' cmd_BWN_send - BWN Meldeliste per E-Mail senden (FCN/Fuerth)
' Original: Form_frm_VA_Auftragstamm.cmd_BWN_send_Click
' Ruft SendeBewachungsnachweise(Me) aus mod_N_Messezettel auf
' ============================================================================
Public Function HTML_cmd_BWN_send_Click(VA_ID As Long, Veranstalter_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim frm As Form

    ' Oeffne Auftragstamm-Formular mit dem Auftrag (wie Original Click-Event)
    DoCmd.OpenForm "frm_VA_Auftragstamm", , , "ID = " & VA_ID
    DoEvents
    Wait 1

    Set frm = Forms("frm_VA_Auftragstamm")

    ' Rufe Original-Funktion aus mod_N_Messezettel auf (exakt wie cmd_BWN_send_Click)
    Call SendeBewachungsnachweise(frm)

    HTML_cmd_BWN_send_Click = "OK - BWN werden per E-Mail versendet"

    Exit Function

ErrorHandler:
    HTML_cmd_BWN_send_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' btn_LoewensaalSync - Loewensaal Sync (Excel + Access)
' Original: frm_Menuefuehrung1.btn_LoewensaalSync_Click
' Ruft RunLoewensaalSync_WithWebScan aus mod_N_Loewensaal auf
' ============================================================================
Public Function HTML_btn_LoewensaalSync_Click() As String
    On Error GoTo ErrorHandler

    ' Rufe Original-Funktion aus mod_N_Loewensaal auf
    ' RunLoewensaalSync_WithWebScan ruft intern RunLoewensaalSync_2Etappen auf
    Call RunLoewensaalSync_WithWebScan

    HTML_btn_LoewensaalSync_Click = "OK - Loewensaal Sync gestartet"

    Exit Function

ErrorHandler:
    HTML_btn_LoewensaalSync_Click = "Fehler: " & Err.Description
End Function


' ============================================================================
' HTML_AuftragKopieren - Auftrag kopieren mit neuem Startdatum
' Original: Form_frm_VA_Auftragstamm.Befehl640_Click -> AuftragKopieren(Me.ID)
' HINWEIS: Das Startdatum wird als Parameter uebergeben (keine InputBox!)
' Diese Funktion implementiert die Logik von AuftragKopieren direkt,
' da die Original-Funktion eine InputBox verwendet die via COM nicht funktioniert.
' ============================================================================
Public Function HTML_AuftragKopieren(VA_ID As Long, NeuesStartdatum As String) As String
    On Error GoTo ErrorHandler

    Dim sql             As String
    Dim rs              As Recordset
    Dim f()             As Variant
    Dim c               As Integer
    Dim i               As Integer
    Dim TAG             As Integer
    Dim Tage            As Integer
    Dim Start           As Integer
    Dim Starts          As Integer
    Dim Entries         As Integer
    Dim VADatum         As Date
    Dim ID              As Long
    Dim von             As Date
    Dim bis             As Date

    ' Datentyp fuer Veranstaltungstage
    Dim vaDaten() As Variant  ' (Tag, Datum, DatumSQL, DatumID, StartIDs)

    ' Anzahl Tage der Veranstaltung - MAX aus AnzTage und distinkten Start-Datumswerten
    Dim TageAnzTage As Integer, TageVAStart As Integer
    TageAnzTage = Nz(TCount("ID", anzTage, "VA_ID = " & VA_ID), 0)

    ' Zaehle distinkte Datumswerte in tbl_VA_Start (kann abweichen!)
    ' Access SQL: Unterabfrage MIT ALIAS (erforderlich in Access!)
    Dim rsCount As DAO.Recordset
    Set rsCount = CurrentDb.OpenRecordset("SELECT COUNT(*) AS cnt FROM (SELECT DISTINCT VADatum FROM " & VAStart & " WHERE VA_ID = " & VA_ID & ") AS T")
    If Not rsCount.EOF Then
        TageVAStart = Nz(rsCount.Fields("cnt"), 0)
    Else
        TageVAStart = 0
    End If
    rsCount.Close

    ' Verwende das Maximum fuer sichere Array-Dimensionierung
    If TageAnzTage > TageVAStart Then
        Tage = TageAnzTage
    Else
        Tage = TageVAStart
    End If

    If Tage = 0 Then
        HTML_AuftragKopieren = "Fehler: Keine Veranstaltungstage gefunden"
        Exit Function
    End If

    ' "Dauerauftrag" mit freien Tagen dazwischen pruefen
    Dim origVon As Date, origBis As Date
    origVon = Nz(TLookup("Dat_VA_Von", AUFTRAGSTAMM, "ID = " & VA_ID), 0)
    origBis = Nz(TLookup("Dat_VA_Bis", AUFTRAGSTAMM, "ID = " & VA_ID), 0)
    If Tage < (origBis - origVon) Then
        HTML_AuftragKopieren = "Fehler: Dauerlaeufer - bitte manuell anlegen!"
        Exit Function
    End If

    ' Startdatum aus Parameter parsen (Format: DD.MM.YYYY oder YYYY-MM-DD)
    On Error Resume Next
    If InStr(NeuesStartdatum, ".") > 0 Then
        ' Deutsches Format: DD.MM.YYYY
        Dim parts() As String
        parts = Split(NeuesStartdatum, ".")
        If UBound(parts) >= 2 Then
            von = DateSerial(CInt(parts(2)), CInt(parts(1)), CInt(parts(0)))
        Else
            von = CDate(NeuesStartdatum)
        End If
    Else
        von = CDate(NeuesStartdatum)
    End If
    On Error GoTo ErrorHandler

    If von = 0 Then
        HTML_AuftragKopieren = "Fehler: Ungueltiges Startdatum: " & NeuesStartdatum
        Exit Function
    End If

    ' Ende der Veranstaltung berechnen
    bis = von + Tage - 1

    ' Array fuer Veranstaltungstage dimensionieren
    ReDim vaDaten(1 To Tage, 1 To 4)  ' (Datum, DatumSQL, DatumID, StartIDs als String)

    For i = 1 To Tage
        vaDaten(i, 1) = von + i - 1  ' Datum
        vaDaten(i, 2) = "#" & Year(von + i - 1) & "-" & Month(von + i - 1) & "-" & Day(von + i - 1) & "#"  ' DatumSQL
        vaDaten(i, 3) = 0  ' DatumID (wird spaeter gefuellt)
        vaDaten(i, 4) = ""  ' StartIDs (wird spaeter gefuellt)
    Next i

    ' === Veranstaltung im Auftragstamm duplizieren ===
    sql = "SELECT * FROM " & AUFTRAGSTAMM & " WHERE [ID] = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql)
    c = rs.Fields.Count

    ReDim f(c)

    ' Feldwerte puffern (ohne ID = Feld 0)
    For i = 1 To c - 1
        f(i) = rs.Fields(i)
    Next i

    ' Neuer Datensatz
    rs.AddNew

    ' Gepufferte Werte uebertragen
    For i = 1 To c - 1
        rs.Fields(i) = f(i)
    Next i

    ' ID der neuen Veranstaltung holen
    ID = rs.Fields("ID")

    ' Einzelwerte uebersteuern
    rs.Fields("Erst_von") = Environ("UserName")
    rs.Fields("Erst_am") = Date & " " & Time
    rs.Fields("Dat_VA_Von") = von
    rs.Fields("Dat_VA_Bis") = bis
    rs.Fields("AnzTg") = (bis - von) + 1
    rs.Fields("Aend_von") = Null
    rs.Fields("Aend_am") = Null
    rs.Fields("Veranst_Status_ID") = 1  ' Status auf "Neu"
    rs.Fields("Rch_Dat") = Null
    rs.Fields("Rch_Nr") = Null
    rs.Fields("Excel_Dateiname") = Null
    rs.Fields("Excel_Path") = Null
    rs.Fields("Abschlussdatum") = Null

    rs.Update
    rs.Close

    ' === Veranstaltung in tbl_VA_Start duplizieren ===
    sql = "SELECT * FROM " & VAStart & " WHERE [VA_ID] = " & VA_ID & " ORDER BY [VADatum] ASC, [ID] ASC"
    Set rs = CurrentDb.OpenRecordset(sql)

    c = rs.Fields.Count

    If rs.RecordCount <> 0 Then
        rs.MoveLast
        rs.MoveFirst
    End If
    Entries = rs.RecordCount

    If Entries >= Tage Then
        ReDim f(c)

        TAG = 1
        Start = 1
        VADatum = 0

        Do While Not rs.EOF
            ' Naechster Tag wenn Datum wechselt
            If rs.Fields("VADatum") <> VADatum And VADatum <> 0 Then
                TAG = TAG + 1
                Start = 1
            End If
            VADatum = rs.Fields("VADatum")

            ' Dynamische Array-Erweiterung: Falls TAG > Tage, Array vergroessern
            ' Dies kann passieren wenn das Recordset durch AddNew mehr Iterationen hat
            If TAG > Tage Then
                ' Array dynamisch erweitern
                Tage = TAG
                ReDim Preserve vaDaten(1 To Tage, 1 To 4)
                ' Neue Array-Elemente initialisieren
                vaDaten(TAG, 1) = von + TAG - 1  ' Datum
                vaDaten(TAG, 2) = "#" & Year(von + TAG - 1) & "-" & Month(von + TAG - 1) & "-" & Day(von + TAG - 1) & "#"
                vaDaten(TAG, 3) = 0
                vaDaten(TAG, 4) = ""
            End If

            ' Feldwerte puffern
            For i = 1 To c - 1
                f(i) = rs.Fields(i)
            Next i

            ' Neuer Datensatz
            rs.AddNew

            Dim newStartID As Long
            newStartID = rs.Fields("ID")

            ' StartID speichern (mit Bounds-Check)
            If TAG >= 1 And TAG <= Tage Then
                If Len(vaDaten(TAG, 4)) > 0 Then
                    vaDaten(TAG, 4) = vaDaten(TAG, 4) & "," & newStartID
                Else
                    vaDaten(TAG, 4) = CStr(newStartID)
                End If
            End If
            Start = Start + 1

            ' Gepufferte Werte uebertragen
            For i = 1 To c - 1
                rs.Fields(i) = f(i)
            Next i

            ' Einzelwerte uebersteuern
            rs.Fields("VA_ID") = ID
            rs.Fields("VADatum_ID") = Null  ' Wird spaeter zugewiesen
            rs.Fields("VADatum") = vaDaten(TAG, 1)

            ' MVA_Start und MVA_Ende mit neuem Datum
            If Not IsNull(rs.Fields("MVA_Start")) And Len(rs.Fields("MVA_Start") & "") = 19 Then
                rs.Fields("MVA_Start") = vaDaten(TAG, 1) & " " & Right(rs.Fields("MVA_Start"), 8)
            End If
            If Not IsNull(rs.Fields("MVA_Ende")) And Len(rs.Fields("MVA_Ende") & "") = 19 Then
                rs.Fields("MVA_Ende") = vaDaten(TAG, 1) & " " & Right(rs.Fields("MVA_Ende"), 8)
            End If

            rs.Update
            rs.MoveNext
        Loop
        rs.Close
    Else
        ' Weniger Eintraege als Tage -> Ein Eintrag pro Tag anlegen
        For TAG = 1 To Tage
            rs.AddNew
            vaDaten(TAG, 4) = CStr(rs.Fields("ID"))
            rs.Fields("VA_ID") = ID
            rs.Fields("VADatum") = vaDaten(TAG, 1)
            rs.Update
        Next TAG
        rs.Close
    End If

    ' === Veranstaltung in VA_AnzTage duplizieren ===
    sql = "SELECT * FROM " & anzTage & " WHERE [VA_ID] = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql)

    c = rs.Fields.Count
    If rs.RecordCount <> 0 Then
        rs.MoveLast
        rs.MoveFirst
    End If
    Entries = rs.RecordCount

    If Entries = Tage Then
        ReDim f(c)

        TAG = 1
        Do While Not rs.EOF
            ' Feldwerte puffern
            For i = 1 To c - 1
                f(i) = rs.Fields(i)
            Next i

            ' Neuer Datensatz
            rs.AddNew

            ' DatumID speichern
            vaDaten(TAG, 3) = rs.Fields("ID")

            ' Gepufferte Werte uebertragen
            For i = 1 To c - 1
                rs.Fields(i) = f(i)
            Next i

            ' Einzelwerte uebersteuern
            rs.Fields("VA_ID") = ID
            rs.Fields("VADatum") = vaDaten(TAG, 1)
            rs.Update

            ' VADatum_ID in tbl_VA_Start aktualisieren
            sql = "UPDATE " & VAStart & " SET VADatum_ID = " & vaDaten(TAG, 3) & " WHERE VA_ID = " & ID & " AND VADatum = " & vaDaten(TAG, 2)
            CurrentDb.Execute sql

            TAG = TAG + 1
            rs.MoveNext
        Loop
        rs.Close
    Else
        ' Datensaetze anlegen
        For TAG = 1 To Tage
            rs.AddNew
            vaDaten(TAG, 3) = rs.Fields("ID")
            rs.Fields("VA_ID") = ID
            rs.Fields("VADatum") = vaDaten(TAG, 1)
            rs.Update

            ' VADatum_ID in tbl_VA_Start aktualisieren
            sql = "UPDATE " & VAStart & " SET VADatum_ID = " & vaDaten(TAG, 3) & " WHERE VA_ID = " & ID & " AND VADatum = " & vaDaten(TAG, 2)
            CurrentDb.Execute sql
        Next TAG
        rs.Close
    End If

    ' Erfolg: Neue VA_ID zurueckgeben
    HTML_AuftragKopieren = "OK:" & ID

    Exit Function

ErrorHandler:
    HTML_AuftragKopieren = "Fehler: " & Err.Number & " " & Err.Description
End Function


' ============================================================================
' HTML_AuftragLoeschen - Auftrag endgueltig loeschen (echtes DELETE!)
' Original: Form_frm_VA_Auftragstamm.mcobtnDelete_Click
' WARNUNG: Loescht den Auftrag PERMANENT aus der Datenbank!
' ============================================================================
Public Function HTML_AuftragLoeschen(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    Dim sql As String

    ' Exakt wie im Original: Echtes DELETE (kein Soft-Delete!)
    DoCmd.SetWarnings False
    DoCmd.RunCommand acCmdSaveRecord

    sql = "DELETE FROM " & AUFTRAGSTAMM & " WHERE ID = " & VA_ID
    CurrentDb.Execute sql, dbFailOnError

    DoCmd.SetWarnings True

    HTML_AuftragLoeschen = "OK - Auftrag geloescht"

    Exit Function

ErrorHandler:
    DoCmd.SetWarnings True
    HTML_AuftragLoeschen = "Fehler: " & Err.Description
End Function


' ============================================================================
' HTML_AuftragAktualisieren - Formular-Daten aktualisieren (Requery)
' Original: Diverse Requery-Aufrufe im Auftragstamm-Formular
' ============================================================================
Public Function HTML_AuftragAktualisieren(VA_ID As Long) As String
    On Error GoTo ErrorHandler

    ' Datenbank-Cache aktualisieren wie im Original
    DoEvents
    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    ' Falls Auftragstamm-Formular offen ist, auch das aktualisieren
    If IsFormOpen("frm_VA_Auftragstamm") Then
        Forms("frm_VA_Auftragstamm").Requery
        If Not IsNull(Forms("frm_VA_Auftragstamm")!zsub_lstAuftrag) Then
            Forms("frm_VA_Auftragstamm")!zsub_lstAuftrag.Form.Requery
        End If
    End If

    HTML_AuftragAktualisieren = "OK - Daten aktualisiert"

    Exit Function

ErrorHandler:
    HTML_AuftragAktualisieren = "Fehler: " & Err.Description
End Function


' Hilfsfunktion: Prueft ob ein Formular geoeffnet ist
Private Function IsFormOpen(FormName As String) As Boolean
    On Error Resume Next
    IsFormOpen = (SysCmd(acSysCmdGetObjectState, acForm, FormName) = acObjStateOpen)
End Function
