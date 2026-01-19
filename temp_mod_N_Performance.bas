' =====================================================
' mod_N_Performance
' Performance-Optimierungen fuer Access Frontend
' Erstellt: 05.01.2026
' =====================================================

' Windows API fuer High-Performance Timer
#If VBA7 Then
    Private Declare PtrSafe Function QueryPerformanceCounter Lib "kernel32" (lpPerformanceCount As Currency) As Long
    Private Declare PtrSafe Function QueryPerformanceFrequency Lib "kernel32" (lpFrequency As Currency) As Long
#Else
    Private Declare Function QueryPerformanceCounter Lib "kernel32" (lpPerformanceCount As Currency) As Long
    Private Declare Function QueryPerformanceFrequency Lib "kernel32" (lpFrequency As Currency) As Long
#End If

Private m_Frequency As Currency
Private m_StartTime As Currency
Private m_EchoWasOn As Boolean

' =====================================================
' SCREEN UPDATES CONTROL
' =====================================================

' Deaktiviert Screen-Updates fuer schnellere Ausfuehrung
Public Sub DisableScreenUpdates()
    On Error Resume Next
    m_EchoWasOn = Application.Echo
    Application.Echo False
    DoCmd.SetWarnings False
End Sub

' Reaktiviert Screen-Updates
Public Sub EnableScreenUpdates()
    On Error Resume Next
    Application.Echo True
    DoCmd.SetWarnings True
End Sub

' Fuehrt Code ohne Screen-Updates aus (mit automatischem Restore)
' Verwendung: ExecuteWithoutScreenUpdates "MeineSub"
Public Sub ExecuteWithoutScreenUpdates(SubName As String)
    On Error GoTo ErrorHandler

    DisableScreenUpdates
    Application.Run SubName

Cleanup:
    EnableScreenUpdates
    Exit Sub

ErrorHandler:
    EnableScreenUpdates
    Debug.Print "[Performance] Error in " & SubName & ": " & Err.Description
    Resume Cleanup
End Sub

' =====================================================
' FORM LOADING OPTIMIZATION
' =====================================================

' Optimiert das Laden eines Formulars
Public Sub OptimizedFormOpen(FormName As String, Optional View As AcFormView = acNormal, Optional FilterName As String = "", Optional WhereCondition As String = "")
    On Error GoTo ErrorHandler

    DisableScreenUpdates

    ' Formular oeffnen
    DoCmd.OpenForm FormName, View, FilterName, WhereCondition

    ' Kurze Pause fuer stabiles Rendering
    DoEvents

    EnableScreenUpdates
    Exit Sub

ErrorHandler:
    EnableScreenUpdates
    MsgBox "Fehler beim Oeffnen von " & FormName & ":" & vbCrLf & Err.Description, vbExclamation
End Sub

' Schliesst Formular ohne Rueckfrage
Public Sub OptimizedFormClose(FormName As String)
    On Error Resume Next
    DoCmd.SetWarnings False
    DoCmd.Close acForm, FormName, acSaveNo
    DoCmd.SetWarnings True
End Sub

' =====================================================
' QUERY EXECUTION OPTIMIZATION
' =====================================================

' Fuehrt Query schnell aus (ohne Benutzerinteraktion)
Public Function ExecuteQueryFast(SQL As String, Optional ShowErrors As Boolean = False) As Boolean
    On Error GoTo ErrorHandler

    DoCmd.SetWarnings False
    CurrentDb.Execute SQL, dbFailOnError
    DoCmd.SetWarnings True

    ExecuteQueryFast = True
    Exit Function

ErrorHandler:
    DoCmd.SetWarnings True
    If ShowErrors Then
        Debug.Print "[Performance] SQL Error: " & Err.Description
        Debug.Print "[Performance] SQL: " & Left(SQL, 200)
    End If
    ExecuteQueryFast = False
End Function

' Fuehrt mehrere Queries in einer Transaktion aus
Public Function ExecuteQueriesInTransaction(Queries As Variant) As Boolean
    On Error GoTo ErrorHandler

    Dim db As DAO.Database
    Dim ws As DAO.Workspace
    Dim i As Long

    Set ws = DBEngine.Workspaces(0)
    Set db = CurrentDb

    DoCmd.SetWarnings False
    ws.BeginTrans

    For i = LBound(Queries) To UBound(Queries)
        If Len(Trim(Queries(i))) > 0 Then
            db.Execute Queries(i), dbFailOnError
        End If
    Next i

    ws.CommitTrans
    DoCmd.SetWarnings True

    ExecuteQueriesInTransaction = True
    Exit Function

ErrorHandler:
    On Error Resume Next
    ws.Rollback
    DoCmd.SetWarnings True
    Debug.Print "[Performance] Transaction Error: " & Err.Description
    ExecuteQueriesInTransaction = False
End Function

' =====================================================
' RECORDSET OPTIMIZATION
' =====================================================

' Schnelles Recordset oeffnen (Forward-Only, Read-Only)
Public Function OpenFastRecordset(SQL As String) As DAO.Recordset
    On Error GoTo ErrorHandler
    Set OpenFastRecordset = CurrentDb.OpenRecordset(SQL, dbOpenForwardOnly, dbReadOnly)
    Exit Function

ErrorHandler:
    Set OpenFastRecordset = Nothing
    Debug.Print "[Performance] Recordset Error: " & Err.Description
End Function

' Schnelles Zaehlen von Datensaetzen
Public Function FastRecordCount(TableOrQuery As String, Optional WhereClause As String = "") As Long
    On Error GoTo ErrorHandler

    Dim SQL As String
    SQL = "SELECT COUNT(*) AS Cnt FROM " & TableOrQuery
    If Len(WhereClause) > 0 Then
        SQL = SQL & " WHERE " & WhereClause
    End If

    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset(SQL, dbOpenForwardOnly, dbReadOnly)

    If Not rs.EOF Then
        FastRecordCount = rs!Cnt
    End If

    rs.Close
    Set rs = Nothing
    Exit Function

ErrorHandler:
    FastRecordCount = -1
    Debug.Print "[Performance] Count Error: " & Err.Description
End Function

' =====================================================
' TIMER / PROFILING
' =====================================================

' Startet Timer fuer Performance-Messung
Public Sub StartTimer()
    QueryPerformanceFrequency m_Frequency
    QueryPerformanceCounter m_StartTime
End Sub

' Gibt verstrichene Zeit in Millisekunden zurueck
Public Function GetElapsedMs() As Double
    Dim endTime As Currency
    QueryPerformanceCounter endTime

    If m_Frequency > 0 Then
        GetElapsedMs = (endTime - m_StartTime) / m_Frequency * 1000
    Else
        GetElapsedMs = 0
    End If
End Function

' Stoppt Timer und gibt Ergebnis aus
Public Sub StopTimer(Optional Label As String = "Operation")
    Dim elapsed As Double
    elapsed = GetElapsedMs()
    Debug.Print "[Performance] " & Label & ": " & Format(elapsed, "0.00") & " ms"
End Sub

' =====================================================
' FORM CONTROL OPTIMIZATION
' =====================================================

' Deaktiviert alle Controls waehrend einer Operation
Public Sub DisableFormControls(frm As Form)
    On Error Resume Next
    Dim ctl As Control
    For Each ctl In frm.Controls
        ctl.Enabled = False
    Next ctl
End Sub

' Reaktiviert alle Controls
Public Sub EnableFormControls(frm As Form)
    On Error Resume Next
    Dim ctl As Control
    For Each ctl In frm.Controls
        ctl.Enabled = True
    Next ctl
End Sub

' Batch-Update fuer Textboxen (verhindert einzelne Repaints)
Public Sub BatchUpdateTextboxes(frm As Form, Updates As Object)
    On Error Resume Next

    Dim key As Variant
    Dim ctl As Control

    ' Screen-Updates ausschalten
    frm.Painting = False

    ' Alle Updates durchfuehren
    For Each key In Updates.Keys
        Set ctl = frm.Controls(key)
        If Not ctl Is Nothing Then
            ctl.Value = Updates(key)
        End If
    Next key

    ' Screen-Updates wieder einschalten
    frm.Painting = True
End Sub

' =====================================================
' COMBOBOX / LISTBOX OPTIMIZATION
' =====================================================

' Schnelles Fuellen einer Combobox
Public Sub FastFillCombo(cmb As ComboBox, SQL As String)
    On Error GoTo ErrorHandler

    ' RowSource temporaer leeren fuer schnelleres Update
    cmb.RowSource = ""
    cmb.Requery

    ' Neue Daten setzen
    cmb.RowSource = SQL
    cmb.Requery

    Exit Sub

ErrorHandler:
    Debug.Print "[Performance] Combo Fill Error: " & Err.Description
End Sub

' Schnelles Fuellen einer Listbox mit Array
Public Sub FastFillListFromArray(lst As ListBox, DataArray As Variant)
    On Error GoTo ErrorHandler

    Dim i As Long

    lst.RowSourceType = "Value List"
    lst.RowSource = ""

    If IsArray(DataArray) Then
        For i = LBound(DataArray) To UBound(DataArray)
            lst.AddItem DataArray(i)
        Next i
    End If

    Exit Sub

ErrorHandler:
    Debug.Print "[Performance] List Fill Error: " & Err.Description
End Sub

' =====================================================
' STARTUP OPTIMIZATION
' =====================================================

' Optimierte Startup-Routine
Public Sub OptimizedStartup()
    On Error Resume Next

    ' Warnungen aus
    DoCmd.SetWarnings False

    ' Ribbon minimieren (falls vorhanden)
    DoCmd.ShowToolbar "Ribbon", acToolbarNo

    ' Status-Bar Text
    SysCmd acSysCmdSetStatus, "CONSYS wird geladen..."

    ' Garbage Collection
    VBA.DoEvents

    Debug.Print "[Performance] Startup optimiert"
End Sub

' =====================================================
' MEMORY OPTIMIZATION
' =====================================================

' Kompaktiert die Frontend-Datenbank (sollte regelmaessig ausgefuehrt werden)
Public Sub CompactFrontend()
    On Error GoTo ErrorHandler

    Dim strCurrentDb As String
    Dim strBackupDb As String
    Dim strTempDb As String

    strCurrentDb = CurrentDb.Name
    strBackupDb = Replace(strCurrentDb, ".accdb", "_backup.accdb")
    strTempDb = Replace(strCurrentDb, ".accdb", "_temp.accdb")

    ' Backup erstellen
    FileCopy strCurrentDb, strBackupDb

    MsgBox "Bitte Access neu starten und dann:" & vbCrLf & _
           "Datei > Komprimieren und Reparieren ausfuehren.", vbInformation

    Exit Sub

ErrorHandler:
    Debug.Print "[Performance] Compact Error: " & Err.Description
End Sub

' =====================================================
' TEST FUNCTIONS
' =====================================================

Public Sub Test_PerformanceTimer()
    StartTimer

    ' Simuliere Arbeit
    Dim i As Long
    For i = 1 To 100000
        DoEvents
    Next i

    StopTimer "100k DoEvents Loop"
End Sub

Public Sub Test_FastQuery()
    StartTimer

    Dim count As Long
    count = FastRecordCount("tbl_MA_Mitarbeiterstamm", "IstAktiv = True")

    StopTimer "Aktive MA zaehlen"
    Debug.Print "[Performance] Aktive Mitarbeiter: " & count
End Sub
