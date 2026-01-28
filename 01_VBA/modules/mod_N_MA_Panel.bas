Attribute VB_Name = "mod_N_MA_Panel"
'===============================================================================
' Modul: mod_N_MA_Panel
' Beschreibung: VBA-Funktionen fuer das HTML MA-Panel (Festangestellte + Minijobber)
' Erstellt: 2026-01-17
' Autor: Claude Code
'
' Funktionen:
'   - GetVerfuegbareFestangestellte: Laedt verfuegbare Festangestellte (Anstellungsart_ID=3)
'   - GetVerfuegbareMinijobber: Laedt verfuegbare Minijobber (Anstellungsart_ID=5)
'   - ZuordneMAZuSchicht: Ordnet einen Mitarbeiter direkt einer Schicht zu
'   - SendeMinijobberAnfragen: Sendet Anfragen an ausgewaehlte Minijobber
'===============================================================================

' Konstanten fuer Anstellungsarten
Private Const ANSTELLUNGSART_FESTANGESTELLT As Integer = 3
Private Const ANSTELLUNGSART_MINIJOBBER As Integer = 5

'-------------------------------------------------------------------------------
' GetVerfuegbareFestangestellte
' Laedt alle verfuegbaren Festangestellten fuer einen bestimmten Auftrag/Tag
' Geprueft werden: nicht bereits eingeteilt, nicht krank, nicht Urlaub, nicht privat verplant
'-------------------------------------------------------------------------------
Public Function GetVerfuegbareFestangestellte(Optional VA_ID As Long = 0, _
                                               Optional VADatum As Date = 0) As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String
    Dim count As Long

    On Error GoTo ErrHandler

    Set db = CurrentDb()

    ' Basis-Query: Aktive Festangestellte
    sql = "SELECT MA.ID, MA.Nachname, MA.Vorname, MA.Anstellungsart_ID " & _
          "FROM tbl_MA_Mitarbeiterstamm AS MA " & _
          "WHERE MA.IstAktiv = True " & _
          "AND MA.Anstellungsart_ID = " & ANSTELLUNGSART_FESTANGESTELLT

    ' Falls Datum angegeben: Pruefe Verfuegbarkeit
    If VADatum > 0 Then
        ' Nicht krank oder Urlaub an diesem Tag
        sql = sql & " AND MA.ID NOT IN (" & _
              "SELECT NV.MA_ID FROM tbl_MA_NVerfuegZeiten AS NV " & _
              "WHERE #" & Format(VADatum, "yyyy-mm-dd") & "# BETWEEN NV.vonDat AND NV.bisDat)"
    End If

    ' Falls VA_ID angegeben: Pruefe ob nicht bereits eingeteilt
    If VA_ID > 0 And VADatum > 0 Then
        sql = sql & " AND MA.ID NOT IN (" & _
              "SELECT P.MA_ID FROM tbl_MA_VA_Planung AS P " & _
              "WHERE P.VA_ID = " & VA_ID & " " & _
              "AND P.VADatum = #" & Format(VADatum, "yyyy-mm-dd") & "#)"
    End If

    sql = sql & " ORDER BY MA.Nachname, MA.Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    ' JSON Array erstellen
    json = "["
    count = 0

    Do While Not rs.EOF
        If count > 0 Then json = json & ","

        json = json & "{" & _
               """ID"":" & rs!ID & "," & _
               """Nachname"":""" & Replace(Nz(rs!Nachname, ""), """", "\""") & """," & _
               """Vorname"":""" & Replace(Nz(rs!Vorname, ""), """", "\""") & """" & _
               "}"

        count = count + 1
        rs.MoveNext
    Loop

    json = json & "]"

    rs.Close
    Set rs = Nothing
    Set db = Nothing

    GetVerfuegbareFestangestellte = json
    Exit Function

ErrHandler:
    GetVerfuegbareFestangestellte = "[]"
    Debug.Print "Fehler in GetVerfuegbareFestangestellte: " & Err.Description
End Function

'-------------------------------------------------------------------------------
' GetVerfuegbareMinijobber
' Laedt alle verfuegbaren Minijobber fuer einen bestimmten Auftrag/Tag
'-------------------------------------------------------------------------------
Public Function GetVerfuegbareMinijobber(Optional VA_ID As Long = 0, _
                                          Optional VADatum As Date = 0) As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String
    Dim count As Long

    On Error GoTo ErrHandler

    Set db = CurrentDb()

    ' Basis-Query: Aktive Minijobber
    sql = "SELECT MA.ID, MA.Nachname, MA.Vorname, MA.Anstellungsart_ID " & _
          "FROM tbl_MA_Mitarbeiterstamm AS MA " & _
          "WHERE MA.IstAktiv = True " & _
          "AND MA.Anstellungsart_ID = " & ANSTELLUNGSART_MINIJOBBER

    ' Falls Datum angegeben: Pruefe Verfuegbarkeit
    If VADatum > 0 Then
        ' Nicht privat verplant an diesem Tag
        sql = sql & " AND MA.ID NOT IN (" & _
              "SELECT NV.MA_ID FROM tbl_MA_NVerfuegZeiten AS NV " & _
              "WHERE #" & Format(VADatum, "yyyy-mm-dd") & "# BETWEEN NV.vonDat AND NV.bisDat)"
    End If

    ' Falls VA_ID angegeben: Pruefe ob nicht bereits eingeteilt
    If VA_ID > 0 And VADatum > 0 Then
        sql = sql & " AND MA.ID NOT IN (" & _
              "SELECT P.MA_ID FROM tbl_MA_VA_Planung AS P " & _
              "WHERE P.VA_ID = " & VA_ID & " " & _
              "AND P.VADatum = #" & Format(VADatum, "yyyy-mm-dd") & "#)"
    End If

    sql = sql & " ORDER BY MA.Nachname, MA.Vorname"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    ' JSON Array erstellen
    json = "["
    count = 0

    Do While Not rs.EOF
        If count > 0 Then json = json & ","

        json = json & "{" & _
               """ID"":" & rs!ID & "," & _
               """Nachname"":""" & Replace(Nz(rs!Nachname, ""), """", "\""") & """," & _
               """Vorname"":""" & Replace(Nz(rs!Vorname, ""), """", "\""") & """" & _
               "}"

        count = count + 1
        rs.MoveNext
    Loop

    json = json & "]"

    rs.Close
    Set rs = Nothing
    Set db = Nothing

    GetVerfuegbareMinijobber = json
    Exit Function

ErrHandler:
    GetVerfuegbareMinijobber = "[]"
    Debug.Print "Fehler in GetVerfuegbareMinijobber: " & Err.Description
End Function

'-------------------------------------------------------------------------------
' ZuordneMAZuSchicht
' Ordnet einen Mitarbeiter direkt einer Schicht zu (fuer Festangestellte)
'-------------------------------------------------------------------------------
Public Function ZuordneMAZuSchicht(VA_ID As Long, MA_ID As Long, _
                                    VADatum As Date, _
                                    Optional VAStart_ID As Long = 0) As Boolean
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim newId As Long

    On Error GoTo ErrHandler

    Set db = CurrentDb()

    ' Pruefe ob bereits zugeordnet
    sql = "SELECT COUNT(*) AS Cnt FROM tbl_MA_VA_Planung " & _
          "WHERE VA_ID = " & VA_ID & " AND MA_ID = " & MA_ID & " " & _
          "AND VADatum = #" & Format(VADatum, "yyyy-mm-dd") & "#"

    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    If rs!Cnt > 0 Then
        rs.Close
        Set rs = Nothing
        Set db = Nothing
        ZuordneMAZuSchicht = False ' Bereits zugeordnet
        Exit Function
    End If

    rs.Close

    ' Hole Schicht-Zeiten falls VAStart_ID angegeben
    Dim vaStart As Date, vaEnde As Date
    vaStart = TimeValue("08:00:00")
    vaEnde = TimeValue("18:00:00")

    If VAStart_ID > 0 Then
        sql = "SELECT VA_Start, VA_Ende FROM tbl_VA_Start WHERE ID = " & VAStart_ID
        Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
        If Not rs.EOF Then
            vaStart = Nz(rs!VA_Start, TimeValue("08:00:00"))
            vaEnde = Nz(rs!VA_Ende, TimeValue("18:00:00"))
        End If
        rs.Close
    End If

    ' Neue Zuordnung erstellen
    sql = "INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, MVA_Start, MVA_Ende, " & _
          "Status, Erstellt_am, Erstellt_von) VALUES (" & _
          VA_ID & ", " & MA_ID & ", #" & Format(VADatum, "yyyy-mm-dd") & "#, " & _
          "#" & Format(vaStart, "hh:nn:ss") & "#, " & _
          "#" & Format(vaEnde, "hh:nn:ss") & "#, " & _
          "2, Now(), " & _
          "'" & Environ("USERNAME") & "')"

    db.Execute sql, dbFailOnError

    ' MA-Anzahl_Ist in tbl_VA_Start aktualisieren falls vorhanden
    If VAStart_ID > 0 Then
        sql = "UPDATE tbl_VA_Start SET MA_Anzahl_Ist = Nz(MA_Anzahl_Ist, 0) + 1 " & _
              "WHERE ID = " & VAStart_ID
        db.Execute sql, dbFailOnError
    End If

    Set db = Nothing

    ZuordneMAZuSchicht = True
    Exit Function

ErrHandler:
    ZuordneMAZuSchicht = False
    Debug.Print "Fehler in ZuordneMAZuSchicht: " & Err.Description
End Function

'-------------------------------------------------------------------------------
' SendeMinijobberAnfragen
' Sendet Anfragen an ausgewaehlte Minijobber fuer einen Auftrag
' MA_IDs: Komma-separierte Liste von MA-IDs
'-------------------------------------------------------------------------------
Public Function SendeMinijobberAnfragen(VA_ID As Long, MA_IDs As String, _
                                         Optional VADatum As Date = 0) As Boolean
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim maIdArray() As String
    Dim i As Long
    Dim maId As Long
    Dim insertCount As Long

    On Error GoTo ErrHandler

    If Len(Trim(MA_IDs)) = 0 Then
        SendeMinijobberAnfragen = False
        Exit Function
    End If

    Set db = CurrentDb()

    ' Falls kein Datum: Hole erstes Datum des Auftrags
    If VADatum = 0 Then
        sql = "SELECT TOP 1 VADatum FROM tbl_VA_AnzTage WHERE VA_ID = " & VA_ID & " ORDER BY VADatum"
        Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
        If Not rs.EOF Then
            VADatum = rs!VADatum
        Else
            VADatum = Date
        End If
        rs.Close
    End If

    ' MA_IDs aufteilen
    maIdArray = Split(MA_IDs, ",")
    insertCount = 0

    For i = LBound(maIdArray) To UBound(maIdArray)
        maId = CLng(Trim(maIdArray(i)))

        If maId > 0 Then
            ' Pruefe ob Anfrage bereits existiert
            sql = "SELECT COUNT(*) AS Cnt FROM tbl_MA_VA_Planung " & _
                  "WHERE VA_ID = " & VA_ID & " AND MA_ID = " & maId & " " & _
                  "AND VADatum = #" & Format(VADatum, "yyyy-mm-dd") & "# " & _
                  "AND Status = 1"  ' Status 1 = Angefragt

            Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

            If rs!Cnt = 0 Then
                ' Neue Anfrage erstellen (Status 1 = Angefragt)
                sql = "INSERT INTO tbl_MA_VA_Planung (VA_ID, MA_ID, VADatum, Status, " & _
                      "Erstellt_am, Erstellt_von) VALUES (" & _
                      VA_ID & ", " & maId & ", #" & Format(VADatum, "yyyy-mm-dd") & "#, " & _
                      "1, Now(), " & _
                      "'" & Environ("USERNAME") & "')"

                db.Execute sql, dbFailOnError
                insertCount = insertCount + 1
            End If

            rs.Close
        End If
    Next i

    Set db = Nothing

    SendeMinijobberAnfragen = (insertCount > 0)
    Exit Function

ErrHandler:
    SendeMinijobberAnfragen = False
    Debug.Print "Fehler in SendeMinijobberAnfragen: " & Err.Description
End Function

'-------------------------------------------------------------------------------
' HTML_GetFestangestellte
' Wrapper-Funktion fuer HTML-Aufruf via VBA Bridge
'-------------------------------------------------------------------------------
Public Function HTML_GetFestangestellte(Optional VA_ID As Long = 0, _
                                         Optional VADatum As String = "") As String
    Dim dt As Date

    If Len(VADatum) > 0 Then
        dt = CDate(VADatum)
    Else
        dt = 0
    End If

    HTML_GetFestangestellte = GetVerfuegbareFestangestellte(VA_ID, dt)
End Function

'-------------------------------------------------------------------------------
' HTML_GetMinijobber
' Wrapper-Funktion fuer HTML-Aufruf via VBA Bridge
'-------------------------------------------------------------------------------
Public Function HTML_GetMinijobber(Optional VA_ID As Long = 0, _
                                    Optional VADatum As String = "") As String
    Dim dt As Date

    If Len(VADatum) > 0 Then
        dt = CDate(VADatum)
    Else
        dt = 0
    End If

    HTML_GetMinijobber = GetVerfuegbareMinijobber(VA_ID, dt)
End Function

'-------------------------------------------------------------------------------
' HTML_ZuordneMA
' Wrapper-Funktion fuer HTML-Aufruf via VBA Bridge
'-------------------------------------------------------------------------------
Public Function HTML_ZuordneMA(VA_ID As Long, MA_ID As Long, _
                                VADatum As String, _
                                Optional VAStart_ID As Long = 0) As String
    Dim dt As Date
    Dim result As Boolean

    dt = CDate(VADatum)
    result = ZuordneMAZuSchicht(VA_ID, MA_ID, dt, VAStart_ID)

    If result Then
        HTML_ZuordneMA = "{""success"":true,""message"":""Mitarbeiter erfolgreich zugeordnet""}"
    Else
        HTML_ZuordneMA = "{""success"":false,""message"":""Zuordnung fehlgeschlagen""}"
    End If
End Function

'-------------------------------------------------------------------------------
' HTML_SendeAnfragen
' Wrapper-Funktion fuer HTML-Aufruf via VBA Bridge
'-------------------------------------------------------------------------------
Public Function HTML_SendeAnfragen(VA_ID As Long, MA_IDs As String, _
                                    Optional VADatum As String = "") As String
    Dim dt As Date
    Dim result As Boolean

    If Len(VADatum) > 0 Then
        dt = CDate(VADatum)
    Else
        dt = 0
    End If

    result = SendeMinijobberAnfragen(VA_ID, MA_IDs, dt)

    If result Then
        HTML_SendeAnfragen = "{""success"":true,""message"":""Anfragen gesendet""}"
    Else
        HTML_SendeAnfragen = "{""success"":false,""message"":""Keine Anfragen gesendet""}"
    End If
End Function
