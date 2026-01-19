Attribute VB_Name = "mod_N_DP_Dashboard"
' mod_N_DP_Dashboard V26 - PosNr wird gesetzt
' mod_N_DP_Dashboard V12 - Anfragen Button Fix
Private m_CurrentVA_ID As Long
Private m_CurrentAnzTage_ID As Long
Private m_CurrentDatum As Date
Private m_CurrentVAStart_ID As Long
Private m_CurrentMA_Start As Date
Private m_CurrentMA_Ende As Date
Private m_SelectedSlotID As Long

Public Sub DP_Dashboard_Oeffnen()
    DoCmd.OpenForm "frm_N_DP_Dashboard", acNormal
End Sub

Public Sub DP_Dashboard_Oeffnen_MitAuftrag(Optional VA_ID As Long = 0)
    DoCmd.OpenForm "frm_N_DP_Dashboard", acNormal
    If VA_ID > 0 Then
        On Error Resume Next
        Forms!frm_N_DP_Dashboard!sub_lstAuftrag.Form.Recordset.FindFirst "VA_ID = " & VA_ID
        On Error GoTo 0
    End If
End Sub

Public Sub DP_Auftrag_Ausgewaehlt(VA_ID As Long, AnzTage_ID As Long, VADatum As Date)
    On Error Resume Next
    m_CurrentVA_ID = VA_ID
    m_CurrentAnzTage_ID = AnzTage_ID
    m_CurrentDatum = VADatum
    m_CurrentVAStart_ID = 0
    m_SelectedSlotID = 0
    m_CurrentMA_Start = 0
    m_CurrentMA_Ende = 0
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    frm!sub_Einsatzliste.Form.filter = "VA_ID = " & VA_ID & " AND VADatum_ID = " & AnzTage_ID
    frm!sub_Einsatzliste.Form.FilterOn = True
    frm!sub_Einsatzliste.Form.Requery
    DP_Aktualisiere_Verfuegbare_MA VADatum
    DP_Aktualisiere_Angefragte_MA
    On Error GoTo 0
End Sub

Public Sub DP_Einsatzliste_Click(SlotID As Long, VAStart_ID As Long, MA_Start As Date, MA_Ende As Date)
    m_SelectedSlotID = SlotID
    m_CurrentVAStart_ID = VAStart_ID
    m_CurrentMA_Start = MA_Start
    m_CurrentMA_Ende = MA_Ende
End Sub

Public Sub DP_Aktualisiere_Verfuegbare_MA(VADatum As Date)
    On Error Resume Next
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    Dim strDatum As String
    strDatum = Format(VADatum, "mm") & "/" & Format(VADatum, "dd") & "/" & Format(VADatum, "yyyy")
    Dim strSQL As String
    strSQL = "SELECT m.ID AS MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, m.Anstellungsart_ID, 0 AS MonatStd " & _
             "FROM tbl_MA_Mitarbeiterstamm AS m WHERE m.IstAktiv = True AND m.Anstellungsart_ID IN (3, 5) " & _
             "AND m.ID NOT IN (SELECT Nz(MA_ID,0) FROM tbl_MA_VA_Zuordnung WHERE VADatum = #" & strDatum & "# AND Nz(MA_ID,0) > 0) " & _
             "AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_NVerfuegZeiten WHERE #" & strDatum & "# BETWEEN vonDat AND bisDat) " & _
             "AND m.ID NOT IN (SELECT ID FROM ztbl_MA_Schnellauswahl) " & _
             "AND m.ID NOT IN (SELECT MA_ID FROM tbl_MA_VA_Planung WHERE VADatum = #" & strDatum & "# AND Status_ID IN (1,2)) " & _
             "ORDER BY IIf(m.Anstellungsart_ID=3, 1, 2), m.Nachname, m.Vorname"
    frm!lstMA.RowSource = strSQL
    frm!lstMA.Requery
    On Error GoTo 0
End Sub



Public Sub DP_MA_Doppelklick(MA_ID As Long)
    On Error GoTo ErrHandler
    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen.", vbExclamation
        Exit Sub
    End If
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim Anstellungsart As Long
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT Anstellungsart_ID FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID)
    If Not rs.EOF Then Anstellungsart = Nz(rs!Anstellungsart_ID, 0)
    rs.Close
    If Anstellungsart = 3 Then
        DP_MA_In_Slot_Eintragen MA_ID
    ElseIf Anstellungsart = 5 Then
        DP_MA_Zur_Anfrage MA_ID
    End If
    Set db = Nothing
    Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbExclamation
End Sub

Public Sub DP_MA_In_Slot_Eintragen(MA_ID As Long)
    On Error GoTo ErrHandler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim FreeSlotID As Long
    Dim TargetStart As Date
    Dim TargetEnde As Date
    Set db = CurrentDb
    TargetStart = m_CurrentMA_Start
    TargetEnde = m_CurrentMA_Ende
    If m_CurrentMA_Start = 0 Then
        Set rs = db.OpenRecordset("SELECT TOP 1 ID, VAStart_ID, MA_Start, MA_Ende FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) ORDER BY MA_Start, PosNr")
        If rs.EOF Then
            MsgBox "Alle Schichten besetzt.", vbExclamation
            rs.Close
            Set db = Nothing
            Exit Sub
        End If
        FreeSlotID = rs!ID
        TargetStart = rs!MA_Start
        TargetEnde = rs!MA_Ende
        m_CurrentMA_Start = TargetStart
        m_CurrentMA_Ende = TargetEnde
        rs.Close
    Else
        Dim strStartTime As String
        Dim strEndTime As String
        strStartTime = Format(m_CurrentMA_Start, "hh:nn:ss")
        strEndTime = Format(m_CurrentMA_Ende, "hh:nn:ss")
        strSQL = "SELECT TOP 1 ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
                 " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND (MA_ID = 0 OR MA_ID Is Null)" & _
                 " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
                 " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "' ORDER BY PosNr"
        Set rs = db.OpenRecordset(strSQL)
        If rs.EOF Then
            MsgBox "Schicht besetzt.", vbExclamation
            rs.Close
            Set db = Nothing
            Exit Sub
        End If
        FreeSlotID = rs!ID
        rs.Close
    End If
    Set rs = db.OpenRecordset("SELECT ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
        " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND MA_ID = " & MA_ID)
    If Not rs.EOF Then
        MsgBox "MA bereits eingetragen.", vbInformation
        rs.Close
        Set db = Nothing
        Exit Sub
    End If
    rs.Close
    db.Execute "UPDATE tbl_MA_VA_Zuordnung SET MA_ID = " & MA_ID & " WHERE ID = " & FreeSlotID, dbFailOnError
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    frm!sub_Einsatzliste.Form.Requery
    DP_NavigateToNextFreeSlot TargetStart, TargetEnde
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    Set db = Nothing
    Exit Sub
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbExclamation
    Set db = Nothing
End Sub

Private Sub DP_NavigateToNextFreeSlot(TargetStart As Date, TargetEnde As Date)
    On Error Resume Next
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim NextFreeID As Long
    Set db = CurrentDb
    Dim strStartTime As String
    Dim strEndTime As String
    strStartTime = Format(TargetStart, "hh:nn:ss")
    strEndTime = Format(TargetEnde, "hh:nn:ss")
    strSQL = "SELECT TOP 1 ID FROM tbl_MA_VA_Zuordnung WHERE VA_ID = " & m_CurrentVA_ID & _
             " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND (MA_ID = 0 OR MA_ID Is Null)" & _
             " AND Format(MA_Start, 'hh:nn:ss') = '" & strStartTime & "'" & _
             " AND Format(MA_Ende, 'hh:nn:ss') = '" & strEndTime & "' ORDER BY PosNr"
    Set rs = db.OpenRecordset(strSQL)
    If Not rs.EOF Then
        NextFreeID = rs!ID
        rs.Close
        Dim frm As Form
        Set frm = Forms!frm_N_DP_Dashboard
        frm!sub_Einsatzliste.Form.Recordset.FindFirst "ID = " & NextFreeID
        m_CurrentMA_Start = TargetStart
        m_CurrentMA_Ende = TargetEnde
    Else
        rs.Close
        m_CurrentMA_Start = 0
        m_CurrentMA_Ende = 0
    End If
    Set db = Nothing
    On Error GoTo 0
End Sub

Public Sub DP_MA_Zur_Anfrage(MA_ID As Long)
    On Error GoTo ErrHandler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim rsSlot As DAO.Recordset
    Dim strSQL As String
    Dim dVADatum As Date
    Dim dBeginn As Date
    Dim dEnde As Date
    Dim lngPosNr As Long
    
    Set db = CurrentDb
    
    ' Pruefe ob Auftrag ausgewaehlt
    If m_CurrentVA_ID = 0 Or m_CurrentAnzTage_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen.", vbExclamation
        Set db = Nothing
        Exit Sub
    End If
    
    ' Wenn keine Schicht ausgewaehlt, erste freie Schicht nehmen
    If m_CurrentVAStart_ID = 0 Then
        Set rs = db.OpenRecordset("SELECT TOP 1 VAStart_ID, MA_Start, MA_Ende FROM tbl_MA_VA_Zuordnung " & _
            "WHERE VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID & _
            " AND (MA_ID = 0 OR MA_ID Is Null) ORDER BY MA_Start, PosNr")
        If rs.EOF Then
            MsgBox "Alle Schichten besetzt.", vbExclamation
            rs.Close
            Set db = Nothing
            Exit Sub
        End If
        m_CurrentVAStart_ID = rs!VAStart_ID
        m_CurrentMA_Start = rs!MA_Start
        m_CurrentMA_Ende = rs!MA_Ende
        rs.Close
    End If
    
    ' Pruefe ob MA bereits in dieser Schicht eingeplant
    Dim existingID As Variant
    existingID = DLookup("ID", "tbl_MA_VA_Planung", "MA_ID = " & MA_ID & " AND VAStart_ID = " & m_CurrentVAStart_ID)
    
    If Not IsNull(existingID) Then
        MsgBox "Mitarbeiter ist bereits fuer diese Schicht eingeplant.", vbInformation
        Set db = Nothing
        Exit Sub
    End If
    
    ' Hole Schicht-Daten
    Set rsSlot = db.OpenRecordset("SELECT VA_Start, VA_Ende, VADatum FROM tbl_VA_Start WHERE ID = " & m_CurrentVAStart_ID)
    If rsSlot.EOF Then
        MsgBox "Schicht nicht gefunden.", vbExclamation
        rsSlot.Close
        Set db = Nothing
        Exit Sub
    End If
    
    dBeginn = rsSlot!VA_Start
    dEnde = rsSlot!VA_Ende
    dVADatum = Nz(rsSlot!VADatum, m_CurrentDatum)
    rsSlot.Close
    
    ' Naechste PosNr ermitteln
    lngPosNr = Nz(DMax("PosNr", "tbl_MA_VA_Planung", "VAStart_ID = " & m_CurrentVAStart_ID), 0) + 1
    
    ' MA in tbl_MA_VA_Planung eintragen mit Status 1 (Geplant)
    ' WICHTIG: MVA_Start und MVA_Ende muessen fuer E-Mail-Zeiten befuellt werden
    strSQL = "INSERT INTO tbl_MA_VA_Planung (VA_ID, VADatum_ID, VAStart_ID, MA_ID, Status_ID, PosNr, " & _
             "VADatum, VA_Start, VA_Ende, MVA_Start, MVA_Ende, Erst_von, Erst_am) VALUES (" & _
             m_CurrentVA_ID & ", " & m_CurrentAnzTage_ID & ", " & m_CurrentVAStart_ID & ", " & MA_ID & ", 1, " & lngPosNr & ", " & _
             "#" & Format(dVADatum, "yyyy-mm-dd") & "#, " & _
             "#" & Format(dVADatum, "yyyy-mm-dd") & " " & Format(dBeginn, "hh:nn:ss") & "#, " & _
             "#" & Format(dVADatum, "yyyy-mm-dd") & " " & Format(dEnde, "hh:nn:ss") & "#, " & _
             "#" & Format(dVADatum, "yyyy-mm-dd") & " " & Format(dBeginn, "hh:nn:ss") & "#, " & _
             "#" & Format(dVADatum, "yyyy-mm-dd") & " " & Format(dEnde, "hh:nn:ss") & "#, " & _
             "'" & Environ("USERNAME") & "', Now())"
    
    db.Execute strSQL, dbFailOnError
    
    Set db = Nothing
    
    ' Listen aktualisieren
    DP_Aktualisiere_Angefragte_MA
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    
    Exit Sub
ErrHandler:
    MsgBox "Fehler bei Minijobber-Anfrage: " & Err.description, vbExclamation
    Set db = Nothing
End Sub



Public Sub DP_MA_Aus_Anfrage(MA_ID As Long)
    On Error Resume Next
    
    ' Loesche MA aus tbl_MA_VA_Planung fuer aktuelle Schicht
    ' Nur loeschen wenn Status 1 (Geplant) - nicht wenn bereits angefragt
    If m_CurrentVAStart_ID > 0 Then
        Dim Status_ID As Variant
        Status_ID = DLookup("Status_ID", "tbl_MA_VA_Planung", "MA_ID = " & MA_ID & " AND VAStart_ID = " & m_CurrentVAStart_ID)
        
        If Nz(Status_ID, 0) = 1 Then
            ' Nur Geplante loeschen
            CurrentDb.Execute "DELETE FROM tbl_MA_VA_Planung WHERE MA_ID = " & MA_ID & " AND VAStart_ID = " & m_CurrentVAStart_ID
        ElseIf Nz(Status_ID, 0) = 2 Then
            MsgBox "Mitarbeiter wurde bereits angefragt und kann nicht entfernt werden.", vbInformation
        End If
    End If
    
    ' Auch aus Schnellauswahl loeschen (falls dort)
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl WHERE ID = " & MA_ID
    
    DP_Aktualisiere_Angefragte_MA
    DP_Aktualisiere_Verfuegbare_MA m_CurrentDatum
    On Error GoTo 0
End Sub

Public Sub DP_Aktualisiere_Angefragte_MA()
    On Error Resume Next
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    Dim strSQL As String

    ' Zeige MA aus tbl_MA_VA_Planung fuer aktuellen Auftrag und Tag
    ' Nicht nur fuer eine Schicht, sondern alle MA des Tages
    If m_CurrentVA_ID > 0 And m_CurrentAnzTage_ID > 0 Then
        strSQL = "SELECT p.MA_ID, p.PosNr AS Lfd, m.Nachname, m.Vorname, " & _
                 "Format(p.MVA_Start, 'hh:nn') AS Beginn, " & _
                 "s.Status " & _
                 "FROM (tbl_MA_VA_Planung AS p " & _
                 "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID) " & _
                 "INNER JOIN tbl_MA_Plan_Status AS s ON p.Status_ID = s.ID " & _
                 "WHERE p.VA_ID = " & m_CurrentVA_ID & " " & _
                 "AND p.VADatum_ID = " & m_CurrentAnzTage_ID & " " & _
                 "AND p.Status_ID IN (1, 2) " & _
                 "ORDER BY p.PosNr"
        
        ' 6 Spalten: MA_ID (hidden), Lfd, Nachname, Vorname, Beginn, Status
        frm!lst_MA_Auswahl.ColumnCount = 6
        frm!lst_MA_Auswahl.ColumnWidths = "0;400;1200;1000;600;1000"
    Else
        ' Fallback
        strSQL = "SELECT 0 AS MA_ID, '' AS Lfd, '' AS Nachname, '' AS Vorname, '' AS Beginn, '' AS Status FROM tbl_MA_Plan_Status WHERE 1=0"
        frm!lst_MA_Auswahl.ColumnCount = 6
        frm!lst_MA_Auswahl.ColumnWidths = "0;400;1200;1000;600;1000"
    End If

    frm!lst_MA_Auswahl.RowSource = strSQL
    frm!lst_MA_Auswahl.Requery
    On Error GoTo 0
End Sub



' ============================================================================
' ANFRAGEN BUTTON - Nutzt bestehende Logik aus frm_ma_va_schnellauswahl
' ============================================================================
Public Sub DP_Mitarbeiter_Anfragen()
    On Error GoTo ErrHandler
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    Dim lst As ListBox
    Set lst = frm!lst_MA_Auswahl
    
    ' Pruefe ob Auftrag/Schicht ausgewaehlt
    If m_CurrentVA_ID = 0 Then
        MsgBox "Bitte zuerst einen Auftrag auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    ' Sammle zu anfragende MA_IDs
    Dim colMA As Collection
    Set colMA = New Collection
    Dim i As Long
    Dim lngMA_ID As Long
    Dim bHasSelection As Boolean
    bHasSelection = False
    
    ' Pruefe ob MA markiert sind (MultiSelect)
    For i = 0 To lst.ListCount - 1
        If lst.selected(i) Then
            bHasSelection = True
            lngMA_ID = lst.Column(0, i)  ' MA_ID ist in Spalte 0
            If lngMA_ID > 0 Then
                On Error Resume Next
                colMA.Add lngMA_ID, CStr(lngMA_ID)
                On Error GoTo ErrHandler
            End If
        End If
    Next i
    
    ' Wenn keine Markierung: alle aus der Liste nehmen
    If Not bHasSelection Then
        For i = 0 To lst.ListCount - 1
            lngMA_ID = lst.Column(0, i)
            If lngMA_ID > 0 Then
                On Error Resume Next
                colMA.Add lngMA_ID, CStr(lngMA_ID)
                On Error GoTo ErrHandler
            End If
        Next i
    End If
    
    If colMA.Count = 0 Then
        MsgBox "Keine Mitarbeiter zum Anfragen vorhanden!", vbExclamation
        Exit Sub
    End If
    
    ' Anfragen senden
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strResult As String
    Dim lngAngefragt As Long
    Dim varMA As Variant
    
    Set db = CurrentDb
    lngAngefragt = 0
    
    For Each varMA In colMA
        lngMA_ID = CLng(varMA)
        
        ' Hole Planungsdaten fuer diesen MA
        strSQL = "SELECT MA_ID, VA_ID, VADatum_ID, VAStart_ID FROM tbl_MA_VA_Planung " & _
                 "WHERE MA_ID = " & lngMA_ID & " AND VA_ID = " & m_CurrentVA_ID & _
                 " AND VADatum_ID = " & m_CurrentAnzTage_ID & " AND Status_ID = 1"
        Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)
        
        If Not rs.EOF Then
            ' Texte laden und Anfrage senden
            strResult = Texte_lesen(CStr(rs!MA_ID), CStr(rs!VA_ID), CStr(rs!VADatum_ID), CStr(rs!VAStart_ID))
            strResult = Anfragen(CInt(rs!MA_ID), CLng(rs!VA_ID), CLng(rs!VADatum_ID), CLng(rs!VAStart_ID))
            
            ' Status auf 2 setzen
            db.Execute "UPDATE tbl_MA_VA_Planung SET Status_ID = 2 WHERE ID = " & _
                DLookup("ID", "tbl_MA_VA_Planung", "MA_ID = " & lngMA_ID & _
                " AND VA_ID = " & m_CurrentVA_ID & " AND VADatum_ID = " & m_CurrentAnzTage_ID), dbFailOnError
            
            lngAngefragt = lngAngefragt + 1
        End If
        rs.Close
    Next varMA
    
    Set rs = Nothing
    Set db = Nothing
    
    ' Listen aktualisieren
    DP_Aktualisiere_Angefragte_MA
    
    ' Erfolgsmeldung
    If lngAngefragt > 0 Then
        MsgBox lngAngefragt & " Mitarbeiter wurden angefragt.", vbInformation
    Else
        MsgBox "Keine Mitarbeiter konnten angefragt werden." & vbCrLf & _
               "(Nur MA mit Status 'Geplant' werden angefragt)", vbExclamation
    End If
    
    Exit Sub

ErrHandler:
    MsgBox "Fehler beim Anfragen: " & Err.description, vbCritical
End Sub





Private Function DP_IsFormOpen(strFormName As String) As Boolean
    On Error Resume Next
    DP_IsFormOpen = (SysCmd(acSysCmdGetObjectState, acForm, strFormName) <> 0)
    On Error GoTo 0
End Function

Public Sub DP_Schnellauswahl_Leeren()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    DP_Aktualisiere_Angefragte_MA
    On Error GoTo 0
End Sub

Public Function DP_Get_CurrentVA_ID() As Long
    DP_Get_CurrentVA_ID = m_CurrentVA_ID
End Function

Public Function DP_Get_CurrentAnzTage_ID() As Long
    DP_Get_CurrentAnzTage_ID = m_CurrentAnzTage_ID
End Function

Public Function DP_Get_CurrentDatum() As Date
    DP_Get_CurrentDatum = m_CurrentDatum
End Function

Public Function DP_Get_SelectedSlotID() As Long
    DP_Get_SelectedSlotID = m_SelectedSlotID
End Function


