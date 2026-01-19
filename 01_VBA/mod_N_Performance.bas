Attribute VB_Name = "mod_N_Performance"
'===============================================================================
' MODUL: mod_N_Performance
' BESCHREIBUNG: Performance-Optimierungen fuer Access Frontend
' AUTOR: Claude Code
' DATUM: 2026-01-06
' VERSION: 1.0
'===============================================================================
' INHALT:
' - Zeitmessung und Logging
' - Stammdaten-Caching
' - Formular-Optimierungen
' - Recordset-Management
' - Slow Query Logging
'===============================================================================

' ============================================================================
' DEKLARATIONEN
' ============================================================================

' Windows API fuer Hochpraezisions-Timer
Private Declare PtrSafe Function QueryPerformanceCounter Lib "kernel32" (lpPerformanceCount As Currency) As Long
Private Declare PtrSafe Function QueryPerformanceFrequency Lib "kernel32" (lpFrequency As Currency) As Long

' Modul-weite Variablen
Private m_TimerStart As Currency
Private m_TimerFrequency As Currency
Private m_SlowQueryThreshold As Double ' in Sekunden
Private m_LogEnabled As Boolean
Private m_LogPath As String

' Cache-Dictionaries (spaete Bindung fuer Kompatibilitaet)
Private m_CacheMitarbeiter As Object
Private m_CacheKunden As Object
Private m_CacheObjekte As Object
Private m_CacheAbwesenheitsgruende As Object
Private m_CacheTimestamps As Object
Private m_CacheMaxAge As Long ' in Sekunden

' ============================================================================
' INITIALISIERUNG
' ============================================================================

Public Sub Performance_Initialize()
    '-------------------------------------------------------------------
    ' Initialisiert das Performance-Modul
    '-------------------------------------------------------------------
    On Error Resume Next

    ' Timer-Frequenz ermitteln
    QueryPerformanceFrequency m_TimerFrequency

    ' Standardwerte setzen
    m_SlowQueryThreshold = 0.5 ' 500ms
    m_LogEnabled = True
    m_LogPath = Environ("TEMP") & "\ConsysPerformance.log"
    m_CacheMaxAge = 300 ' 5 Minuten

    ' Cache-Dictionaries initialisieren
    Set m_CacheMitarbeiter = CreateObject("Scripting.Dictionary")
    Set m_CacheKunden = CreateObject("Scripting.Dictionary")
    Set m_CacheObjekte = CreateObject("Scripting.Dictionary")
    Set m_CacheAbwesenheitsgruende = CreateObject("Scripting.Dictionary")
    Set m_CacheTimestamps = CreateObject("Scripting.Dictionary")

    On Error GoTo 0
End Sub

' ============================================================================
' ZEITMESSUNG
' ============================================================================

Public Sub StartTimer()
    '-------------------------------------------------------------------
    ' Startet den Hochpraezisions-Timer
    '-------------------------------------------------------------------
    QueryPerformanceCounter m_TimerStart
End Sub

Public Function GetElapsedTime() As Double
    '-------------------------------------------------------------------
    ' Gibt die verstrichene Zeit in Sekunden zurueck
    '-------------------------------------------------------------------
    Dim timerEnd As Currency
    QueryPerformanceCounter timerEnd

    If m_TimerFrequency > 0 Then
        GetElapsedTime = (timerEnd - m_TimerStart) / m_TimerFrequency
    Else
        GetElapsedTime = 0
    End If
End Function

Public Function GetElapsedTimeMs() As Double
    '-------------------------------------------------------------------
    ' Gibt die verstrichene Zeit in Millisekunden zurueck
    '-------------------------------------------------------------------
    GetElapsedTimeMs = GetElapsedTime() * 1000
End Function

Public Function MeasureExecutionTime(ByVal procName As String, Optional ByVal logResult As Boolean = True) As Double
    '-------------------------------------------------------------------
    ' Gibt die aktuelle Ausfuehrungszeit zurueck und loggt bei Bedarf
    '-------------------------------------------------------------------
    Dim elapsed As Double
    elapsed = GetElapsedTime()

    If logResult And m_LogEnabled Then
        If elapsed >= m_SlowQueryThreshold Then
            LogSlowQuery procName, elapsed
        End If
    End If

    MeasureExecutionTime = elapsed
End Function

' ============================================================================
' SLOW QUERY LOGGING
' ============================================================================

Public Sub LogSlowQuery(ByVal queryName As String, ByVal executionTime As Double)
    '-------------------------------------------------------------------
    ' Protokolliert langsame Abfragen
    '-------------------------------------------------------------------
    Dim fileNum As Integer
    Dim logEntry As String

    On Error Resume Next

    logEntry = Format(Now(), "yyyy-mm-dd hh:nn:ss") & vbTab & _
               Format(executionTime * 1000, "0.00") & " ms" & vbTab & _
               queryName

    fileNum = FreeFile
    Open m_LogPath For Append As #fileNum
    Print #fileNum, logEntry
    Close #fileNum

    ' Auch in Immediate Window ausgeben
    Debug.Print "SLOW: " & logEntry

    On Error GoTo 0
End Sub

Public Sub SetSlowQueryThreshold(ByVal thresholdSeconds As Double)
    '-------------------------------------------------------------------
    ' Setzt den Schwellwert fuer langsame Abfragen
    '-------------------------------------------------------------------
    m_SlowQueryThreshold = thresholdSeconds
End Sub

Public Sub EnableLogging(ByVal enabled As Boolean)
    '-------------------------------------------------------------------
    ' Aktiviert/deaktiviert das Logging
    '-------------------------------------------------------------------
    m_LogEnabled = enabled
End Sub

Public Sub SetLogPath(ByVal logPath As String)
    '-------------------------------------------------------------------
    ' Setzt den Pfad fuer die Log-Datei
    '-------------------------------------------------------------------
    m_LogPath = logPath
End Sub

' ============================================================================
' FORMULAR-OPTIMIERUNGEN
' ============================================================================

Public Sub OptimizeFormLoad(frm As Form)
    '-------------------------------------------------------------------
    ' Optimiert das Laden eines Formulars
    ' - Deaktiviert temporaer Painting und Berechnungen
    '-------------------------------------------------------------------
    On Error Resume Next

    With frm
        ' Warnungen deaktivieren
        DoCmd.SetWarnings False

        ' Echo deaktivieren fuer schnelleres Laden
        Application.Echo False

        ' Sanduhr anzeigen
        DoCmd.Hourglass True
    End With

    On Error GoTo 0
End Sub

Public Sub OptimizeFormLoadEnd(frm As Form)
    '-------------------------------------------------------------------
    ' Stellt die normalen Einstellungen nach dem Laden wieder her
    '-------------------------------------------------------------------
    On Error Resume Next

    ' Echo wieder aktivieren
    Application.Echo True

    ' Sanduhr ausschalten
    DoCmd.Hourglass False

    ' Warnungen wieder aktivieren (je nach Bedarf)
    DoCmd.SetWarnings True

    ' Cache aktualisieren
    DBEngine.Idle dbRefreshCache

    On Error GoTo 0
End Sub

Public Sub OptimizeSubformLoad(sfrmControl As SubForm)
    '-------------------------------------------------------------------
    ' Optimiert das Laden eines Unterformulars
    ' - Deaktiviert temporaer die Datenquelle
    '-------------------------------------------------------------------
    On Error Resume Next

    With sfrmControl.Form
        ' RecordSource temporaer leeren
        .RecordSource = ""
    End With

    On Error GoTo 0
End Sub

Public Sub LoadSubformData(sfrmControl As SubForm, ByVal recordSource As String, Optional ByVal whereClause As String = "")
    '-------------------------------------------------------------------
    ' Laedt Daten in ein Unterformular mit optimierter Performance
    '-------------------------------------------------------------------
    Dim sql As String

    On Error Resume Next

    ' SQL aufbauen
    sql = recordSource
    If Len(whereClause) > 0 Then
        If InStr(1, sql, "WHERE", vbTextCompare) > 0 Then
            sql = sql & " AND " & whereClause
        Else
            sql = sql & " WHERE " & whereClause
        End If
    End If

    ' Daten laden
    With sfrmControl.Form
        .RecordSource = sql
        .Requery
    End With

    On Error GoTo 0
End Sub

' ============================================================================
' STAMMDATEN-CACHING
' ============================================================================

Public Function GetCachedMitarbeiter(ByVal MA_ID As Long) As Variant
    '-------------------------------------------------------------------
    ' Holt Mitarbeiterdaten aus dem Cache oder der Datenbank
    '-------------------------------------------------------------------
    Dim cacheKey As String
    Dim rs As DAO.Recordset
    Dim result As Variant

    On Error GoTo ErrorHandler

    ' Cache initialisieren falls noetig
    If m_CacheMitarbeiter Is Nothing Then
        Performance_Initialize
    End If

    cacheKey = "MA_" & MA_ID

    ' Pruefen ob im Cache und nicht abgelaufen
    If m_CacheMitarbeiter.Exists(cacheKey) Then
        If IsCacheValid(cacheKey) Then
            GetCachedMitarbeiter = m_CacheMitarbeiter(cacheKey)
            Exit Function
        End If
    End If

    ' Aus Datenbank laden
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT ID, Nachname, Vorname, IstAktiv FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID, _
        dbOpenSnapshot, dbReadOnly)

    If Not rs.EOF Then
        result = Array(rs!ID, Nz(rs!Nachname, ""), Nz(rs!Vorname, ""), Nz(rs!IstAktiv, 0))
    Else
        result = Array(0, "", "", 0)
    End If

    rs.Close
    Set rs = Nothing

    ' In Cache speichern
    If m_CacheMitarbeiter.Exists(cacheKey) Then
        m_CacheMitarbeiter(cacheKey) = result
    Else
        m_CacheMitarbeiter.Add cacheKey, result
    End If
    UpdateCacheTimestamp cacheKey

    GetCachedMitarbeiter = result
    Exit Function

ErrorHandler:
    GetCachedMitarbeiter = Array(0, "", "", 0)
End Function

Public Function GetCachedKunde(ByVal KD_ID As Long) As Variant
    '-------------------------------------------------------------------
    ' Holt Kundendaten aus dem Cache oder der Datenbank
    '-------------------------------------------------------------------
    Dim cacheKey As String
    Dim rs As DAO.Recordset
    Dim result As Variant

    On Error GoTo ErrorHandler

    If m_CacheKunden Is Nothing Then
        Performance_Initialize
    End If

    cacheKey = "KD_" & KD_ID

    If m_CacheKunden.Exists(cacheKey) Then
        If IsCacheValid(cacheKey) Then
            GetCachedKunde = m_CacheKunden(cacheKey)
            Exit Function
        End If
    End If

    Set rs = CurrentDb.OpenRecordset( _
        "SELECT kun_Id, kun_Firma, kun_IstAktiv FROM tbl_KD_Kundenstamm WHERE kun_Id = " & KD_ID, _
        dbOpenSnapshot, dbReadOnly)

    If Not rs.EOF Then
        result = Array(rs!kun_Id, Nz(rs!kun_Firma, ""), Nz(rs!kun_IstAktiv, 0))
    Else
        result = Array(0, "", 0)
    End If

    rs.Close
    Set rs = Nothing

    If m_CacheKunden.Exists(cacheKey) Then
        m_CacheKunden(cacheKey) = result
    Else
        m_CacheKunden.Add cacheKey, result
    End If
    UpdateCacheTimestamp cacheKey

    GetCachedKunde = result
    Exit Function

ErrorHandler:
    GetCachedKunde = Array(0, "", 0)
End Function

Public Function GetCachedObjekt(ByVal OB_ID As Long) As Variant
    '-------------------------------------------------------------------
    ' Holt Objektdaten aus dem Cache oder der Datenbank
    '-------------------------------------------------------------------
    Dim cacheKey As String
    Dim rs As DAO.Recordset
    Dim result As Variant

    On Error GoTo ErrorHandler

    If m_CacheObjekte Is Nothing Then
        Performance_Initialize
    End If

    cacheKey = "OB_" & OB_ID

    If m_CacheObjekte.Exists(cacheKey) Then
        If IsCacheValid(cacheKey) Then
            GetCachedObjekt = m_CacheObjekte(cacheKey)
            Exit Function
        End If
    End If

    Set rs = CurrentDb.OpenRecordset( _
        "SELECT ID, ob_Objekt, ob_Ort FROM tbl_OB_Objektliste WHERE ID = " & OB_ID, _
        dbOpenSnapshot, dbReadOnly)

    If Not rs.EOF Then
        result = Array(rs!ID, Nz(rs!ob_Objekt, ""), Nz(rs!ob_Ort, ""))
    Else
        result = Array(0, "", "")
    End If

    rs.Close
    Set rs = Nothing

    If m_CacheObjekte.Exists(cacheKey) Then
        m_CacheObjekte(cacheKey) = result
    Else
        m_CacheObjekte.Add cacheKey, result
    End If
    UpdateCacheTimestamp cacheKey

    GetCachedObjekt = result
    Exit Function

ErrorHandler:
    GetCachedObjekt = Array(0, "", "")
End Function

Private Function IsCacheValid(ByVal cacheKey As String) As Boolean
    '-------------------------------------------------------------------
    ' Prueft ob ein Cache-Eintrag noch gueltig ist
    '-------------------------------------------------------------------
    Dim cacheTime As Date

    On Error GoTo ErrorHandler

    If m_CacheTimestamps Is Nothing Then
        IsCacheValid = False
        Exit Function
    End If

    If Not m_CacheTimestamps.Exists(cacheKey) Then
        IsCacheValid = False
        Exit Function
    End If

    cacheTime = m_CacheTimestamps(cacheKey)
    IsCacheValid = (DateDiff("s", cacheTime, Now()) < m_CacheMaxAge)
    Exit Function

ErrorHandler:
    IsCacheValid = False
End Function

Private Sub UpdateCacheTimestamp(ByVal cacheKey As String)
    '-------------------------------------------------------------------
    ' Aktualisiert den Zeitstempel eines Cache-Eintrags
    '-------------------------------------------------------------------
    On Error Resume Next

    If m_CacheTimestamps Is Nothing Then
        Set m_CacheTimestamps = CreateObject("Scripting.Dictionary")
    End If

    If m_CacheTimestamps.Exists(cacheKey) Then
        m_CacheTimestamps(cacheKey) = Now()
    Else
        m_CacheTimestamps.Add cacheKey, Now()
    End If

    On Error GoTo 0
End Sub

Public Sub ClearAllCaches()
    '-------------------------------------------------------------------
    ' Leert alle Caches
    '-------------------------------------------------------------------
    On Error Resume Next

    If Not m_CacheMitarbeiter Is Nothing Then m_CacheMitarbeiter.RemoveAll
    If Not m_CacheKunden Is Nothing Then m_CacheKunden.RemoveAll
    If Not m_CacheObjekte Is Nothing Then m_CacheObjekte.RemoveAll
    If Not m_CacheAbwesenheitsgruende Is Nothing Then m_CacheAbwesenheitsgruende.RemoveAll
    If Not m_CacheTimestamps Is Nothing Then m_CacheTimestamps.RemoveAll

    Debug.Print "Alle Caches geleert: " & Format(Now(), "hh:nn:ss")

    On Error GoTo 0
End Sub

Public Sub InvalidateMitarbeiterCache(Optional ByVal MA_ID As Long = 0)
    '-------------------------------------------------------------------
    ' Invalidiert den Mitarbeiter-Cache (komplett oder einzeln)
    '-------------------------------------------------------------------
    On Error Resume Next

    If m_CacheMitarbeiter Is Nothing Then Exit Sub

    If MA_ID = 0 Then
        m_CacheMitarbeiter.RemoveAll
    Else
        Dim cacheKey As String
        cacheKey = "MA_" & MA_ID
        If m_CacheMitarbeiter.Exists(cacheKey) Then
            m_CacheMitarbeiter.Remove cacheKey
        End If
        If m_CacheTimestamps.Exists(cacheKey) Then
            m_CacheTimestamps.Remove cacheKey
        End If
    End If

    On Error GoTo 0
End Sub

Public Sub SetCacheMaxAge(ByVal ageInSeconds As Long)
    '-------------------------------------------------------------------
    ' Setzt die maximale Cache-Lebenszeit
    '-------------------------------------------------------------------
    m_CacheMaxAge = ageInSeconds
End Sub

' ============================================================================
' RECORDSET-MANAGEMENT
' ============================================================================

Public Sub CloseRecordsetSafe(rs As DAO.Recordset)
    '-------------------------------------------------------------------
    ' Schliesst ein Recordset sicher
    '-------------------------------------------------------------------
    On Error Resume Next

    If Not rs Is Nothing Then
        If rs.State = 1 Then ' dbStateOpen
            rs.Close
        End If
        Set rs = Nothing
    End If

    On Error GoTo 0
End Sub

Public Function OpenRecordsetOptimized(ByVal sql As String, Optional ByVal readOnly As Boolean = True) As DAO.Recordset
    '-------------------------------------------------------------------
    ' Oeffnet ein Recordset mit optimierten Einstellungen
    '-------------------------------------------------------------------
    Dim rs As DAO.Recordset
    Dim options As Long

    On Error GoTo ErrorHandler

    If readOnly Then
        options = dbOpenSnapshot + dbReadOnly
    Else
        options = dbOpenDynaset
    End If

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot, dbReadOnly)
    Set OpenRecordsetOptimized = rs
    Exit Function

ErrorHandler:
    Set OpenRecordsetOptimized = Nothing
End Function

' ============================================================================
' WARNUNGEN STEUERN
' ============================================================================

Public Sub SetWarningsOff()
    '-------------------------------------------------------------------
    ' Deaktiviert Access-Warnungen (fuer Batch-Operationen)
    '-------------------------------------------------------------------
    On Error Resume Next
    DoCmd.SetWarnings False
    On Error GoTo 0
End Sub

Public Sub SetWarningsOn()
    '-------------------------------------------------------------------
    ' Aktiviert Access-Warnungen wieder
    '-------------------------------------------------------------------
    On Error Resume Next
    DoCmd.SetWarnings True
    On Error GoTo 0
End Sub

' ============================================================================
' DATENBANK-OPTIMIERUNGEN
' ============================================================================

Public Sub RefreshDatabaseCache()
    '-------------------------------------------------------------------
    ' Aktualisiert den Datenbank-Cache
    '-------------------------------------------------------------------
    On Error Resume Next

    DBEngine.Idle dbRefreshCache
    DBEngine.Idle dbFreeLocks
    DoEvents

    On Error GoTo 0
End Sub

Public Sub CompactCurrentDatabase()
    '-------------------------------------------------------------------
    ' Komprimiert die aktuelle Datenbank
    ' ACHTUNG: Nur ausfuehren wenn keine anderen Benutzer verbunden sind!
    '-------------------------------------------------------------------
    Dim dbPath As String
    Dim dbTemp As String

    On Error GoTo ErrorHandler

    dbPath = CurrentDb.Name
    dbTemp = Replace(dbPath, ".accdb", "_temp.accdb")

    ' Alle Objekte schliessen
    DoCmd.SetWarnings False
    DoCmd.Close

    ' Komprimieren
    DBEngine.CompactDatabase dbPath, dbTemp

    ' Umbenennen
    Kill dbPath
    Name dbTemp As dbPath

    MsgBox "Datenbank wurde komprimiert.", vbInformation
    Exit Sub

ErrorHandler:
    MsgBox "Fehler beim Komprimieren: " & Err.Description, vbExclamation
End Sub

' ============================================================================
' BATCH-OPERATIONEN
' ============================================================================

Public Function ExecuteBatchSQL(sqlStatements As Variant) As Long
    '-------------------------------------------------------------------
    ' Fuehrt mehrere SQL-Statements als Batch aus
    ' Gibt die Anzahl der erfolgreichen Statements zurueck
    '-------------------------------------------------------------------
    Dim i As Long
    Dim successCount As Long

    On Error Resume Next

    SetWarningsOff

    For i = LBound(sqlStatements) To UBound(sqlStatements)
        CurrentDb.Execute CStr(sqlStatements(i)), dbFailOnError
        If Err.Number = 0 Then
            successCount = successCount + 1
        Else
            Debug.Print "Batch-Fehler bei Statement " & i & ": " & Err.Description
            Err.Clear
        End If
    Next i

    SetWarningsOn

    ExecuteBatchSQL = successCount

    On Error GoTo 0
End Function

' ============================================================================
' PERFORMANCE-REPORT
' ============================================================================

Public Function GeneratePerformanceReport() As String
    '-------------------------------------------------------------------
    ' Generiert einen Performance-Report
    '-------------------------------------------------------------------
    Dim report As String
    Dim fileNum As Integer
    Dim logLine As String
    Dim slowQueries As Long
    Dim totalTime As Double

    On Error Resume Next

    report = "PERFORMANCE REPORT - " & Format(Now(), "yyyy-mm-dd hh:nn:ss") & vbCrLf
    report = report & String(60, "=") & vbCrLf & vbCrLf

    ' Cache-Statistiken
    report = report & "CACHE-STATISTIKEN:" & vbCrLf
    report = report & String(40, "-") & vbCrLf

    If Not m_CacheMitarbeiter Is Nothing Then
        report = report & "Mitarbeiter-Cache: " & m_CacheMitarbeiter.Count & " Eintraege" & vbCrLf
    End If
    If Not m_CacheKunden Is Nothing Then
        report = report & "Kunden-Cache: " & m_CacheKunden.Count & " Eintraege" & vbCrLf
    End If
    If Not m_CacheObjekte Is Nothing Then
        report = report & "Objekte-Cache: " & m_CacheObjekte.Count & " Eintraege" & vbCrLf
    End If
    report = report & "Cache-Max-Alter: " & m_CacheMaxAge & " Sekunden" & vbCrLf
    report = report & vbCrLf

    ' Slow Query Log analysieren
    report = report & "LANGSAME ABFRAGEN (letzte Session):" & vbCrLf
    report = report & String(40, "-") & vbCrLf

    If Dir(m_LogPath) <> "" Then
        fileNum = FreeFile
        Open m_LogPath For Input As #fileNum
        Do While Not EOF(fileNum)
            Line Input #fileNum, logLine
            slowQueries = slowQueries + 1
            report = report & logLine & vbCrLf
        Loop
        Close #fileNum

        report = report & vbCrLf & "Gesamt langsame Abfragen: " & slowQueries & vbCrLf
    Else
        report = report & "Keine Log-Datei gefunden." & vbCrLf
    End If

    report = report & vbCrLf
    report = report & "EINSTELLUNGEN:" & vbCrLf
    report = report & String(40, "-") & vbCrLf
    report = report & "Slow-Query-Schwellwert: " & m_SlowQueryThreshold * 1000 & " ms" & vbCrLf
    report = report & "Logging aktiviert: " & m_LogEnabled & vbCrLf
    report = report & "Log-Pfad: " & m_LogPath & vbCrLf

    GeneratePerformanceReport = report

    On Error GoTo 0
End Function

Public Sub PrintPerformanceReport()
    '-------------------------------------------------------------------
    ' Gibt den Performance-Report im Direktfenster aus
    '-------------------------------------------------------------------
    Debug.Print GeneratePerformanceReport()
End Sub

Public Sub ClearSlowQueryLog()
    '-------------------------------------------------------------------
    ' Loescht das Slow-Query-Log
    '-------------------------------------------------------------------
    On Error Resume Next

    If Dir(m_LogPath) <> "" Then
        Kill m_LogPath
        Debug.Print "Slow-Query-Log geloescht."
    End If

    On Error GoTo 0
End Sub

' ============================================================================
' HILFSFUNKTIONEN
' ============================================================================

Public Function FormatDuration(ByVal seconds As Double) As String
    '-------------------------------------------------------------------
    ' Formatiert eine Dauer in lesbares Format
    '-------------------------------------------------------------------
    If seconds < 0.001 Then
        FormatDuration = Format(seconds * 1000000, "0.00") & " us"
    ElseIf seconds < 1 Then
        FormatDuration = Format(seconds * 1000, "0.00") & " ms"
    ElseIf seconds < 60 Then
        FormatDuration = Format(seconds, "0.00") & " s"
    Else
        FormatDuration = Format(seconds / 60, "0.00") & " min"
    End If
End Function

' ============================================================================
' OPTIMIERTE ERSATZ-FUNKTIONEN FUER TLOOKUP/TCOUNT/TSUM
' ============================================================================

Public Function FastLookup(ByVal fieldName As String, ByVal tableName As String, Optional ByVal criteria As String = "") As Variant
    '-------------------------------------------------------------------
    ' Schnellere Alternative zu TLookup mit Caching
    '-------------------------------------------------------------------
    Dim sql As String
    Dim rs As DAO.Recordset

    On Error GoTo ErrorHandler

    sql = "SELECT TOP 1 " & fieldName & " FROM " & tableName
    If Len(criteria) > 0 Then
        sql = sql & " WHERE " & criteria
    End If

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot, dbReadOnly)

    If Not rs.EOF Then
        FastLookup = rs.Fields(0).Value
    Else
        FastLookup = Null
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    FastLookup = Null
End Function

Public Function FastCount(ByVal fieldName As String, ByVal tableName As String, Optional ByVal criteria As String = "") As Long
    '-------------------------------------------------------------------
    ' Schnellere Alternative zu TCount
    '-------------------------------------------------------------------
    Dim sql As String
    Dim rs As DAO.Recordset

    On Error GoTo ErrorHandler

    sql = "SELECT COUNT(" & fieldName & ") AS Cnt FROM " & tableName
    If Len(criteria) > 0 Then
        sql = sql & " WHERE " & criteria
    End If

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot, dbReadOnly)

    If Not rs.EOF Then
        FastCount = Nz(rs!Cnt, 0)
    Else
        FastCount = 0
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    FastCount = 0
End Function

Public Function FastSum(ByVal fieldName As String, ByVal tableName As String, Optional ByVal criteria As String = "") As Double
    '-------------------------------------------------------------------
    ' Schnellere Alternative zu TSum
    '-------------------------------------------------------------------
    Dim sql As String
    Dim rs As DAO.Recordset

    On Error GoTo ErrorHandler

    sql = "SELECT SUM(" & fieldName & ") AS Total FROM " & tableName
    If Len(criteria) > 0 Then
        sql = sql & " WHERE " & criteria
    End If

    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot, dbReadOnly)

    If Not rs.EOF Then
        FastSum = Nz(rs!Total, 0)
    Else
        FastSum = 0
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    FastSum = 0
End Function

' ============================================================================
' AUTO-INITIALISIERUNG
' ============================================================================

Public Sub Auto_Open()
    '-------------------------------------------------------------------
    ' Wird automatisch beim Oeffnen der Datenbank ausgefuehrt
    '-------------------------------------------------------------------
    Performance_Initialize
End Sub
