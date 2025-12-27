Attribute VB_Name = "zmd_Sync"
Option Compare Database
Option Explicit

    
''Zusagen/Absagen synchronisieren   -> Nicht mehr in Verwendung, läuft per Job
'Function synchronisieren() As String
'
'Dim SQL         As String
'Dim CRITERIA    As String
'Dim rst         As Recordset
'Dim MA_ID       As String
'Dim VA_ID       As String
'Dim VADatum_ID  As String
'Dim VAStart_ID  As String
'
'
'On Error GoTo Err_Sync
'
'    'SyncDb leeren
'    SQL = "DELETE * FROM " & SYNC
'    CurrentDb.Execute SQL
'
'    'Daten aus SyncDB laden
'    SQL = "INSERT INTO " & SYNC & _
'                " SELECT * FROM " & SYNC & " IN '" & SyncPfad & SYNCDB & "'" & _
'                " WHERE [Sync] = FALSE AND MA_ID <> 0 "
'    CurrentDb.Execute SQL
'
'    'Zusagen/Absagen eintragen, wenn Synchronisation erfolgreich
'    Set rst = CurrentDb.OpenRecordset(SYNC)
'
'    'Daten zum Synchronisieren vorhanden?
'    If rst.RecordCount > 0 Then
'        Do
'            MA_ID = rst.Fields("MA_ID")
'            VA_ID = rst.Fields("VA_ID")
'            VADatum_ID = rst.Fields("VADatum_ID")
'            VAStart_ID = rst.Fields("VAStart_ID")
'
'            CRITERIA = "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & _
'                        " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID
'
'            Select Case rst.Fields("Zusage")
'                Case True
'                    'Planungstabelle updaten
'                    TUpdate "Status_ID = 3", PLANUNG, CRITERIA
'
'                    'Satz in Zuordnungstabelle schreiben
'                    synchronisieren = einplanen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)
'
'                    'Rückgabewert aufbereiten, wenn nötig
'                    If synchronisieren <> "OK" Then synchronisieren = synchronisieren & vbCrLf & _
'                        "Mitarbeiter " & MA_ID & " konnte nicht eingeplant werden!"
'
'                Case False
'                    'Planungstabelle updaten
'                    TUpdate "Status_ID = 4", PLANUNG, CRITERIA
'            End Select
'
'            'Datensatz in SyncDB als synchronisiert markieren
'            If synchronisieren = "OK" Or synchronisieren = "" Then
'                SQL = "UPDATE " & SYNC & " IN '" & SyncPfad & SYNCDB & "'" & _
'                    " SET [Sync] = TRUE" & " WHERE " & CRITERIA
'                CurrentDb.Execute SQL
'            End If
'
'            rst.MoveNext
'
'        Loop Until rst.EOF
'
'        'Synchronisierte Sätze im Backend löschen
'        CurrentDb.Execute "DELETE * FROM " & SYNC
'
'    End If
'
'    'Wenn Absage -> kein Einplanen -> OK
'    If synchronisieren = "" Then synchronisieren = "OK"
'
'End_Sync:
'    Exit Function
'Err_Sync:
'    synchronisieren = Err.Number & " " & Err.Description
'    Resume End_Sync
'End Function


''Mitarbeiter von Planungstabelle in Zuordnungstabelle übertragen
'Function einplanen(MA_ID As String, VA_ID As String, VADatum_ID As String, VAStart_ID As String) As String
'
'Dim SQL         As String
'Dim rst         As Recordset
'Dim CRITERIA    As String
'Dim CRITERIA2   As String 'Vorbelegungssätze mit MA_ID = 0
'
''Benötigte Felder
'Dim MVA_Start       As Date
'Dim MVA_Ende        As Date
'Dim VADatum         As Date
'Dim RL34a           As Boolean
'Dim PosNr           As Integer
'
'
'On Error GoTo Err_Einplan
'
'    CRITERIA = "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID
'    CRITERIA2 = "MA_ID = 0 AND VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID
'
'    'Felder aus Planung lesen
'On Error Resume Next
'    MVA_Start = TLookup("MVA_Start", PLANUNG, CRITERIA)
'    MVA_Ende = TLookup("MVA_Start", PLANUNG, CRITERIA)
'    VADatum = TLookup("VADatum ", PLANUNG, CRITERIA)
'    RL34a = TLookup("Hat_keine_34a", MASTAMM, "ID = " & MA_ID)
'On Error GoTo Err_Einplan
'
'
'
'    'Wenn bereits Sätze mit MA_ID = 0 (Vorbelegungen) in der Zuordnung sind, müssen diese verwendet werden!
'    'Wenn nicht, müssen neue Sätze angelegt werden!
'    SQL = "SELECT * FROM [" & ZUORDNUNG & "] WHERE " & CRITERIA2
'
'    'Recordset über Vorbelegungssätze in der Zuordnung
'    Set rst = CurrentDb.OpenRecordset(SQL)
'
'    'Fall 1: Es sind (noch) Vorbelegungssätze vorhanden -> nächsten freien Satz Verwenden!
'    If rst.RecordCount > 0 Then
'        rst.Edit
'        rst.Fields("MA_ID") = MA_ID
'        rst.Update
'        rst.Close
'
'    'Fall 2: Keine Vorbelegungen (mehr) vorhanden -> neuen Satz anlegen
'    Else
'        PosNr = TMax("PosNr", ZUORDNUNG, "VA_ID = " & VA_ID) + 1
'        rst.Close
'        Set rst = Nothing
'
'        Set rst = CurrentDb.OpenRecordset(ZUORDNUNG)
'        rst.Edit
'        rst.AddNew
'
'        'Datensatz füllen
'        rst.Fields("MA_ID") = MA_ID
'        rst.Fields("VA_ID") = VA_ID
'        rst.Fields("VADatum_ID") = VADatum_ID
'        rst.Fields("VAStart_ID") = VAStart_ID
'        rst.Fields("VADatum") = VADatum
'        rst.Fields("MA_Start") = MVA_Start
'        rst.Fields("MA_Ende") = MVA_Ende
'        rst.Fields("PosNr") = PosNr
'        rst.Fields("Info") = "Überschuss"
'        'RST.Fields("RL34a") = RL34a    ' --> WÄHRUNG !!! Muss anhand der Stunden kalkuliert werden
'
'        rst.Update
'        rst.Close
'
'    End If
'
'
'     einplanen = "OK"
'
'
'End_Einplan:
'    Set rst = Nothing
'    Exit Function
'Err_Einplan:
'    einplanen = Err.Number & " " & Err.Description
'    Resume End_Einplan
'End Function


''Positionsnummer ermitteln
'Function detect_posnr(VA_ID As String) As Integer
'
'    detect_posnr = TMax("PosNr", ZUORDNUNG, "VA_ID = " & VA_ID) + 1
'
'End Function
