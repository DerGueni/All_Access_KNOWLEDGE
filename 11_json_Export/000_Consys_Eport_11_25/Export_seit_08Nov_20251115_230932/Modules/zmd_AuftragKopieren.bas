Option Compare Database


'Datentyp Veranstaltung
Private Type VA
    Datum         As Date
    datumSQL      As String
    DatumID       As Long
    StartID()     As Long 'Mehrere Start_IDs pro Tag möglich
End Type


Function AuftragKopieren(VA_ID As Long) As String

Dim sql             As String
Dim rs              As Recordset

'Variablen
Dim VA()            As VA
Dim f()             As Variant  'Array zum Puffern eines Datensatzes einer Tabelle
Dim c               As Integer  'Dimensionierungsvarialbe für Array f
Dim i               As Integer  'Counter für Schleifen
Dim TAG             As Integer  'Counter bei mehrtägigen Veranstaltungen
Dim Tage            As Integer  'Anzahl Veranstaltungstage
Dim Start           As Integer  'Counter Starts pro Veranstaltungstag
Dim Starts          As Integer  'Start_IDs pro Tag
Dim Entries         As Integer  'Anzahl Datensätze im Recordset
Dim VADatum         As Date
Dim ID              As Long
Dim von             As Date
Dim bis             As Date
Dim PosNr           As Integer
Dim PKWAnz          As Integer
Dim MVAStart        As Date
Dim MVAEnde         As Date
Dim MAStart         As Date
Dim MAEnde          As Date

On Error GoTo err
    
    'Anzahl Tage der Veranstaltung
    Tage = TCount("ID", anzTage, "VA_ID = " & VA_ID)

    '"Dauerauftrag" mit freien Tagen dazwischen
    von = TLookup("Dat_VA_Von", AUFTRAGSTAMM, "ID = " & VA_ID)
    bis = TLookup("Dat_VA_Bis", AUFTRAGSTAMM, "ID = " & VA_ID)
    If Tage < bis - von Then
        AuftragKopieren = "Dauerläufer - bitte manuell anlegen!"
        GoTo Ende
    End If
    von = 0
    bis = 0
    
    'Zeitraum neue Veranstaltung
    von = InputBox("Startdatum eingeben: ", "Veranstaltungsbeginn")
    
    'Datumsprüfung
    If von < Date Then
        If MsgBox("Achtung!" & vbCrLf & _
            "Datum liegt in der Vergangenheit!" & vbCrLf & _
            "Trotzdem kopieren?", vbYesNo) <> vbYes Then
                AuftragKopieren = "Auftrag wurde nicht kopiert"
                GoTo Ende
        End If
    End If
    

    'Ende der Veranstaltung
    bis = von + Tage - 1 'Erster Tag = von!
    
    'Pro Veranstaltungstag gibt es eine VADatumID und mindestens eine VAStart_ID, die jeweils korrekt zugewiesen werden müssen!
    'Array beginnt bei 0, der Übersicht halber bleibt dieser Eintrag leer und +1
    ReDim VA(Tage)
    
    'Veranstaltungstage hinterlegen
    For i = 1 To Tage
        VA(i).Datum = von + i - 1
        VA(i).datumSQL = "#" & year(von + i - 1) & "-" & Month(von + i - 1) & "-" & Day(von + i - 1) & "#"
    Next i
    
    
'###   Veranstaltung im Auftragstamm duplizieren

    sql = "SELECT * FROM " & AUFTRAGSTAMM & " WHERE [ID] = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql)
    c = rs.fields.Count
    
    ReDim f(c)

    'Feldwerte puffern
    For i = 1 To c - 1
        f(i) = rs.fields(i)
    Next i
    
    'Neuer Datensatz
    rs.AddNew
    
    'gepufferte Werte übertragen
    For i = 1 To c - 1
         rs.fields(i) = f(i)
         'Debug.Print rs.Fields(i).Name & " " & rs.Fields(i)
    Next i
    
    'ID der neuen Veranstaltung holen
    ID = rs.fields("ID")
    
    'Einzelwerte übersteuern
    rs.fields("Erst_von") = Environ("UserName")
    rs.fields("Erst_am") = Date & " " & Time
    rs.fields("Dat_VA_Von") = von
    rs.fields("Dat_VA_Bis") = bis
    rs.fields("AnzTg") = (bis - von) + 1
    rs.fields("Aend_von") = Null
    rs.fields("Aend_am") = Null
    rs.fields("Veranst_Status_ID") = 1
    rs.fields("Rch_Dat") = Null
    rs.fields("Rch_Nr") = Null
    rs.fields("Excel_Dateiname") = Null
    rs.fields("Excel_Path") = Null
    rs.fields("Abschlussdatum") = Null
    
    rs.update
    rs.Close


'###   Veranstaltung in tbl_VA_Start duplizieren und ID holen

    'Zuordnungen nach Datum der Veranstaltungstage und Start_ID aufsteigend sortiert
    sql = "SELECT * FROM " & VASTART & " WHERE [VA_ID] = " & VA_ID & " ORDER BY [VADatum] ASC, [ID] ASC"
    Set rs = CurrentDb.OpenRecordset(sql)
    
    'Anzahl Spalten
    c = rs.fields.Count
    
    'Alle Datensätze im Recordset registrieren
    If rs.RecordCount <> 0 Then
        rs.MoveLast
        rs.MoveFirst
    End If
    Entries = rs.RecordCount

    'Mehrere Einträge pro Tag möglich!
    If Entries >= Tage Then
        ReDim f(c)

        'Schleife über Anzahl der Tage
        TAG = 1
        Start = 1
        Starts = TCount("ID", VASTART, "VA_ID = " & VA_ID & " AND VADatum = " & datumSQL(rs.fields("VADatum")))
        ReDim VA(TAG).StartID(Starts)
        Do
            If rs.fields("VADatum") <> VADatum And VADatum <> "00:00:00" Then
                TAG = TAG + 1
                Start = 1
                Starts = TCount("ID", VASTART, "VA_ID = " & VA_ID & " AND VADatum = " & datumSQL(rs.fields("VADatum")))
                ReDim VA(TAG).StartID(Starts)
            End If
            VADatum = rs.fields("VADatum")


            'Feldwerte puffern
            For i = 1 To c - 1
                f(i) = rs.fields(i)
            Next i

            'Neuer Datensatz
            rs.AddNew

            'Schlüssel ID (VAStartID) puffern
            VA(TAG).StartID(Start) = rs.fields("ID")
            Start = Start + 1

            'gepufferte Werte übertragen
            For i = 1 To c - 1
                 rs.fields(i) = f(i)
            Next i

            'Einzelwerte übersteuern -> VA_Start und VA_Ende OHNE Datum!
            rs.fields("VA_ID") = ID
            rs.fields("VADatum_ID") = Null 'wird später erstellt und zugewiesen
            rs.fields("VADatum") = VA(TAG).Datum
            If Not IsNull(rs.fields("MVA_Start")) And Len(rs.fields("MVA_Start")) = 19 Then rs.fields("MVA_Start") = VA(TAG).Datum & " " & Right(rs.fields("MVA_Start"), 8)
            If Not IsNull(rs.fields("MVA_Ende")) And Len(rs.fields("MVA_Ende")) = 19 Then rs.fields("MVA_Ende") = VA(TAG).Datum & " " & Right(rs.fields("MVA_Ende"), 8)

            rs.update
            rs.MoveNext
        'Erste Postion im RS = 0!
        Loop Until rs.AbsolutePosition = Entries
        rs.Close

    'Wenn weniger Einträge als Veranstaltungstage -> Ein Eintrag pro Veranstaltungstag
    Else
        'Datensätze anlegen
        For TAG = 1 To Tage
            rs.AddNew
            'Schlüssel ID (VAStartID) puffern
            ReDim VA(TAG).StartID(1)
            VA(TAG).StartID(1) = rs.fields("ID")
            rs.fields("VA_ID") = ID
            rs.fields("VADatum") = VA(TAG).Datum
            rs.update
        Next TAG
        rs.Close
    End If


'###   Veranstaltung in VA_AnzTage duplizieren

    sql = "SELECT * FROM " & anzTage & " WHERE [VA_ID] = " & VA_ID
    Set rs = CurrentDb.OpenRecordset(sql)
    
    'Anzahl Spalten
    c = rs.fields.Count
    'Alle Datensätze im Recordset registrieren
    If rs.RecordCount <> 0 Then
        rs.MoveLast
        rs.MoveFirst
    End If
    Entries = rs.RecordCount
    
    'Daten nur kopieren, wenn Einträge mit der Anzahl Tage im Auftragstamm übereinstimmen!
    '-> Ansonsten wird pro Tag ein neuer Antrag angelegt
    If Entries = Tage Then
        ReDim f(c)
        
        'Schleife über Anzahl der Tage
        TAG = 1
        Do
            'Feldwerte puffern
            For i = 1 To c - 1
                f(i) = rs.fields(i)
            Next i
            
            'Neuer Datensatz
            rs.AddNew
            
            'Schlüssel ID (VADatumID) puffern
            VA(TAG).DatumID = rs.fields("ID")
            
            'gepufferte Werte übertragen
            For i = 1 To c - 1
                 rs.fields(i) = f(i)
            Next i
            
            'Einzelwerte übersteuern
            rs.fields("VA_ID") = ID
            rs.fields("VADatum") = VA(TAG).Datum
            rs.update
            
            'VADatum_ID in tbl_VA_Start aktualisieren (Hier Schlüssel "ID")
            sql = "UPDATE " & VASTART & " SET VADatum_ID = " & VA(TAG).DatumID & " WHERE VA_ID = " & ID & " AND VADatum = " & VA(TAG).datumSQL
            CurrentDb.Execute sql
            
            TAG = TAG + 1
            rs.MoveNext
        
        'Erste Postion im RS = 0!
        Loop Until rs.AbsolutePosition = Entries
        rs.Close
    Else
        'Datensätze anlegen
        For TAG = 1 To Tage
            'VADatum = von + Tag
            rs.AddNew
            
            'Schlüssel ID (VADatumID) puffern
            VA(TAG).DatumID = rs.fields("ID")
            
            rs.fields("VA_ID") = ID
            rs.fields("VADatum") = VA(TAG).Datum
            rs.update
            
            'VADatum_ID in tbl_VA_Start aktualisieren (Hier Schlüssel "ID")
            sql = "UPDATE " & VASTART & " SET VADatum_ID = " & VA(TAG).DatumID & " WHERE VA_ID = " & ID & " AND VADatum = " & VA(TAG).datumSQL
            CurrentDb.Execute sql
            
        Next TAG
        rs.Close
    End If


'###   Veranstaltung in MA_VA_Zuordnung duplizieren -> FÜHRT ZU FEHLERN!!! -> Einträge werden eh automatisch erzeugt!!!!

'    'Zuordnungen nach Datum der Veranstaltungstage und Mitarbeiter aufsteigend sortiert
'    sql = "SELECT * FROM " & ZUORDNUNG & " WHERE [VA_ID] = " & VA_ID & " ORDER BY [VADatum] ASC, [PosNr] ASC"
'    Set rs = CurrentDb.OpenRecordset(sql)
'
'    'Alle Datensätze im Recordset registrieren
'    If rs.RecordCount <> 0 Then
'        rs.MoveLast
'        rs.MoveFirst
'    End If
'    Entries = rs.RecordCount
'
'    If Entries > 0 Then
'
'        'Loop über alle gefundenen Datensätze
'        TAG = 1
'        Start = 1
'        VADatum = rs.Fields("VADatum") 'VADatum für Abgleich neu zuweisen!
'        Do
'            'Nächster Start, wenn sich die Uhrzeit ändert
'            If MAStart < rs.Fields("MA_Start") And MAStart <> "00:00:00" Then
'                Start = Start + 1
'            End If
'
''            'Nächster Tag, wenn Positionsnummern neu beginnen  ->Funktioniert nicht, wenn nur eine Posnr pro tag!
''            If rs.Fields("PosNr") < PosNr Then
''                Tag = Tag + 1
''                Start = 1
''            End If
'            'Nächster Tag, wenn Datum wechselt
'            If rs.Fields("VADatum") <> VADatum Then
'                TAG = TAG + 1
'                Start = 1
'                VADatum = rs.Fields("VADatum")
'            End If
'            'Werte, die übernommen werden sollen -> MA_ = OHNE Datum, MVA_ = MIT Datum!
'On Error Resume Next
'            PosNr = rs.Fields("PosNr")
'            PKWAnz = rs.Fields("PKW_Anzahl")
'            MVAStart = VA(TAG).Datum & " " & Right(rs.Fields("MVA_Start"), 8)
'            MVAEnde = VA(TAG).Datum & " " & Right(rs.Fields("MVA_Ende"), 8)
'            If Not IsNull(rs.Fields("MA_Start")) Then MAStart = Right(rs.Fields("MA_Start"), 8)
'            If Not IsNull(rs.Fields("MA_Ende")) Then MAEnde = Right(rs.Fields("MA_Ende"), 8)
'On Error GoTo err
'
'
''            Debug.Print "INSERT INTO " & ZUORDNUNG & " (VA_ID, VADatum, PosNr, VADatum_ID, VAStart_ID, Erst_von, Erst_am, MVA_Start, MVA_Ende) VALUES (" _
'                & ID & ", " & Format(VA(Tag).Datum, "\#yyyy-mm-dd\#") & ", " & PosNr & ", " & VA(Tag).DatumID & ", " & VA(Tag).StartID(Start) & ", '" & Environ("UserName") _
'                & "', " & Format(Now, "\#yyyy-mm-dd hh:nn:ss\#") & ", " & Format(MVAStart, "\#yyyy-mm-dd hh:nn:ss\#") & ", " & Format(MVAEnde, "\#yyyy-mm-dd hh:nn:ss\#") & ");"
''
''            CurrentDb.Execute "INSERT INTO " & ZUORDNUNG & " (VA_ID, VADatum, PosNr, VADatum_ID, VAStart_ID, Erst_von, Erst_am, MVA_Start, MVA_Ende) VALUES (" _
''                & ID & ", " & Format(VA(Tag).Datum, "\#yyyy-mm-dd\#") & ", " & PosNr & ", " & VA(Tag).DatumID & ", " & VA(Tag).StartID(Start) & ", '" & Environ("UserName") _
''                & "', " & Format(Now, "\#yyyy-mm-dd hh:nn:ss\#") & ", " & Format(MVAStart, "\#yyyy-mm-dd hh:nn:ss\#") & ", " & Format(MVAEnde, "\#yyyy-mm-dd hh:nn:ss\#") & ");"
''
''            If MAStart <> 0 Then TUpdate "MA_Start = " & Format(MAStart, "\#hh:nn:ss\#"), ZUORDNUNG, "ID = " & TMax("ID", ZUORDNUNG, "VA_ID = " & ID)
''            If MAEnde <> 0 Then TUpdate "MA_ende = " & Format(MAEnde, "\#hh:nn:ss\#"), ZUORDNUNG, "ID = " & TMax("ID", ZUORDNUNG, "VA_ID = " & ID)
'
'
'            rs.AddNew
'
'            'Datensatz bearbeiten
'            rs.Fields("VA_ID") = ID
'            rs.Fields("VADatum") = VA(TAG).Datum
'            rs.Fields("PosNr") = PosNr
'            rs.Fields("VADatum_ID") = VA(TAG).DatumID
'            rs.Fields("VAStart_ID") = VA(TAG).StartID(Start)
'            rs.Fields("Erst_von") = Environ("UserName")
'            rs.Fields("Erst_am") = Date & " " & Time
'            'rs.Fields("MVA_Start") = MVAStart
'            'If MVAEnde <> "00:00:00" Then rs.Fields("MVA_Ende") = MVAEnde
'            'rs.Fields("MA_Start") = MAStart
'            'If MAEnde <> "00:00:00" Then rs.Fields("MA_Ende") = MAEnde
'            'rs.Fields("PreisArt") =
'            'rs.Fields("IstFraglich") =
'        rs.update
'        rs.MoveNext
'
'        'Erste Postion im RS = 0!
'        Loop Until rs.AbsolutePosition = Entries
'
'        rs.Close
'
'    'Wenn keine Datensätze in MA_VA_Zuordnung sind, dann einen Datensatz pro Veranstaltungstag anlegen
'    Else
'        'Datensätze anlegen
'        For TAG = 1 To Tage
'            rs.AddNew
'
'            rs.Fields("VA_ID") = ID
'            rs.Fields("VADatum") = VA(TAG).Datum
'            rs.Fields("VADatum_ID") = VA(TAG).DatumID
'            rs.Fields("VAStart_ID") = VA(TAG).StartID(1)
'            rs.Fields("Erst_von") = Environ("UserName")
'            rs.Fields("Erst_am") = Date & " " & Time
'            'rs.Fields("PreisArt") =
'            'rs.Fields("IstFraglich") =
'            rs.update
'        Next TAG
'        rs.Close
'    End If
    
    AuftragKopieren = ID
            
Ende:
    Exit Function
err:
    AuftragKopieren = err.Number & " " & err.description
    Resume Ende
End Function