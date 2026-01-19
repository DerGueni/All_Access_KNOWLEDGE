Attribute VB_Name = "mod_N_WebHost_Bridge"
' ========================================
' mod_N_WebHost_Bridge
' Generisches WebView2 Message-Handler Modul
' ========================================
'
' ZWECK:
' Empfängt Messages aus HTML-Formularen (via webview2-bridge.js)
' und verarbeitet CRUD-Operationen auf dem Access-Backend
'
' UNTERSTÜTZTE ACTIONS:
' - loadData:  Einzelnen Datensatz laden (ID)
' - list:      Liste von Datensätzen laden (Filter, Sortierung)
' - save:      INSERT oder UPDATE (bei ID vorhanden)
' - delete:    DELETE nach ID
'
' VERWENDUNG:
' Im Formular-Code WebView2_WebMessageReceived Event:
'   Call mod_N_WebHost_Bridge.WebView2_MessageHandler(Me.webview, args)
' ========================================

Public Sub WebView2_MessageHandler(ByVal webview As Object, ByVal args As Object)
    ' Haupthandler für alle Messages aus dem Browser
    On Error GoTo ErrorHandler

    Dim jsonString As String
    Dim data As Object
    Dim action As String
    Dim requestId As String

    ' JSON-String extrahieren
    jsonString = args.WebMessageAsJson
    Debug.Print "[WebHost Bridge] Message: " & jsonString

    ' JSON parsen (benötigt JsonConverter!)
    Set data = JsonConverter.ParseJson(jsonString)

    ' RequestID und Action extrahieren
    requestId = Nz(data("requestId"), "")
    action = Nz(data("action"), "")

    ' Action dispatchen
    Select Case action

        Case "loadData"
            Call ProcessLoadData(webview, requestId, data("type"), data("id"))

        Case "list"
            Call ProcessList(webview, requestId, data("type"), data)

        Case "save"
            Call ProcessSave(webview, requestId, data("type"), data("data"))

        Case "delete"
            Call ProcessDelete(webview, requestId, data("type"), data("id"))

        Case "START_VBA_BRIDGE"
            Call ProcessStartVBABridge(webview, requestId)

        Case Else
            Call SendError(webview, requestId, "Unbekannte Action: " & action)

    End Select

    Exit Sub

ErrorHandler:
    Debug.Print "[WebHost Bridge] ERROR: " & Err.Description
    Call SendError(webview, requestId, Err.Description)
End Sub

' ========================================
' ACTION HANDLERS
' ========================================

Private Sub ProcessLoadData(ByVal webview As Object, ByVal requestId As String, ByVal dataType As String, ByVal recordId As Variant)
    ' Lädt einzelnen Datensatz nach ID
    On Error GoTo ErrorHandler

    Dim tableName As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String

    ' Typ zu Tabelle mappen
    tableName = GetTableName(dataType)
    If tableName = "" Then
        Call SendError(webview, requestId, "Unbekannter Datentyp: " & dataType)
        Exit Sub
    End If

    ' Query erstellen
    Set db = CurrentDb
    sql = "SELECT * FROM " & tableName & " WHERE ID = " & recordId
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    ' Prüfen ob gefunden
    If rs.EOF Then
        Call SendError(webview, requestId, "Datensatz nicht gefunden: ID=" & recordId)
        rs.Close
        Exit Sub
    End If

    ' JSON erstellen
    json = RecordsetToJSON(rs)
    rs.Close

    ' Response senden
    Call SendResponse(webview, requestId, json)
    Exit Sub

ErrorHandler:
    Debug.Print "[ProcessLoadData] ERROR: " & Err.Description
    Call SendError(webview, requestId, Err.Description)
End Sub

Private Sub ProcessList(ByVal webview As Object, ByVal requestId As String, ByVal dataType As String, ByVal params As Object)
    ' Lädt Liste von Datensätzen (mit Filter/Sort)
    On Error GoTo ErrorHandler

    Dim tableName As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim json As String
    Dim whereClause As String
    Dim orderClause As String
    Dim limit As Long

    ' Typ zu Tabelle mappen
    tableName = GetTableName(dataType)
    If tableName = "" Then
        Call SendError(webview, requestId, "Unbekannter Datentyp: " & dataType)
        Exit Sub
    End If

    ' Base Query
    sql = "SELECT * FROM " & tableName

    ' WHERE-Clause aus Params extrahieren
    whereClause = BuildWhereClause(params)
    If whereClause <> "" Then
        sql = sql & " WHERE " & whereClause
    End If

    ' ORDER BY extrahieren
    On Error Resume Next
    orderClause = params("orderBy")
    On Error GoTo ErrorHandler
    If orderClause <> "" Then
        sql = sql & " ORDER BY " & orderClause
    End If

    ' LIMIT extrahieren
    On Error Resume Next
    limit = CLng(params("limit"))
    On Error GoTo ErrorHandler
    If limit > 0 Then
        sql = sql & " TOP " & limit
    End If

    Debug.Print "[ProcessList] SQL: " & sql

    ' Query ausführen
    Set db = CurrentDb
    Set rs = db.OpenRecordset(sql, dbOpenSnapshot)

    ' JSON erstellen
    json = RecordsetArrayToJSON(rs)
    rs.Close

    ' Response senden
    Call SendResponse(webview, requestId, json)
    Exit Sub

ErrorHandler:
    Debug.Print "[ProcessList] ERROR: " & Err.Description
    Call SendError(webview, requestId, Err.Description)
End Sub

Private Sub ProcessSave(ByVal webview As Object, ByVal requestId As String, ByVal dataType As String, ByVal data As Object)
    ' Speichert Datensatz (INSERT oder UPDATE)
    On Error GoTo ErrorHandler

    Dim tableName As String
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim recordId As Variant
    Dim isUpdate As Boolean

    ' Typ zu Tabelle mappen
    tableName = GetTableName(dataType)
    If tableName = "" Then
        Call SendError(webview, requestId, "Unbekannter Datentyp: " & dataType)
        Exit Sub
    End If

    ' Prüfen ob UPDATE (ID vorhanden) oder INSERT
    On Error Resume Next
    recordId = data("ID")
    On Error GoTo ErrorHandler

    isUpdate = Not IsEmpty(recordId) And recordId > 0

    Set db = CurrentDb

    If isUpdate Then
        ' UPDATE
        sql = "SELECT * FROM " & tableName & " WHERE ID = " & recordId
        Set rs = db.OpenRecordset(sql, dbOpenDynaset)

        If rs.EOF Then
            Call SendError(webview, requestId, "Datensatz nicht gefunden: ID=" & recordId)
            rs.Close
            Exit Sub
        End If

        rs.Edit
        Call ApplyFieldsFromJSON(rs, data)
        rs.Update

        Debug.Print "[ProcessSave] UPDATE: " & tableName & " ID=" & recordId

    Else
        ' INSERT
        Set rs = db.OpenRecordset(tableName, dbOpenDynaset)
        rs.AddNew
        Call ApplyFieldsFromJSON(rs, data)
        rs.Update

        ' ID des neuen Datensatzes holen
        rs.Bookmark = rs.LastModified
        recordId = rs!ID

        Debug.Print "[ProcessSave] INSERT: " & tableName & " ID=" & recordId
    End If

    rs.Close

    ' Erfolgs-Response mit ID
    Call SendResponse(webview, requestId, "{""success"": true, ""id"": " & recordId & "}")
    Exit Sub

ErrorHandler:
    Debug.Print "[ProcessSave] ERROR: " & Err.Description
    Call SendError(webview, requestId, Err.Description)
End Sub

Private Sub ProcessStartVBABridge(ByVal webview As Object, ByVal requestId As String)
    ' Startet den VBA Bridge Server (unsichtbar)
    On Error GoTo ErrorHandler

    Dim vbsPath As String
    Dim shellCmd As String

    ' Pfad zum VBS Script
    vbsPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\start_vba_bridge_hidden.vbs"

    ' Prüfen ob Datei existiert
    If Dir(vbsPath) = "" Then
        Call SendError(webview, requestId, "VBS Script nicht gefunden: " & vbsPath)
        Exit Sub
    End If

    ' Script ausführen (unsichtbar via wscript)
    shellCmd = "wscript.exe """ & vbsPath & """"
    Shell shellCmd, vbHide

    Debug.Print "[ProcessStartVBABridge] VBA Bridge Server wird gestartet..."

    ' Erfolgs-Response senden
    Call SendResponse(webview, requestId, "{""started"": true}")
    Exit Sub

ErrorHandler:
    Debug.Print "[ProcessStartVBABridge] ERROR: " & Err.Description
    Call SendError(webview, requestId, Err.Description)
End Sub

Private Sub ProcessDelete(ByVal webview As Object, ByVal requestId As String, ByVal dataType As String, ByVal recordId As Variant)
    ' Löscht Datensatz nach ID
    On Error GoTo ErrorHandler

    Dim tableName As String
    Dim db As DAO.Database
    Dim sql As String

    ' Typ zu Tabelle mappen
    tableName = GetTableName(dataType)
    If tableName = "" Then
        Call SendError(webview, requestId, "Unbekannter Datentyp: " & dataType)
        Exit Sub
    End If

    ' DELETE ausführen
    Set db = CurrentDb
    sql = "DELETE FROM " & tableName & " WHERE ID = " & recordId
    db.Execute sql, dbFailOnError

    Debug.Print "[ProcessDelete] DELETE: " & tableName & " ID=" & recordId

    ' Erfolgs-Response
    Call SendResponse(webview, requestId, "{""success"": true}")
    Exit Sub

ErrorHandler:
    Debug.Print "[ProcessDelete] ERROR: " & Err.Description
    Call SendError(webview, requestId, Err.Description)
End Sub

' ========================================
' RESPONSE HELPERS
' ========================================

Private Sub SendResponse(ByVal webview As Object, ByVal requestId As String, ByVal dataJson As String)
    ' Sendet Success-Response an Browser
    Dim json As String
    json = "{""requestId"": """ & requestId & """, ""success"": true, ""data"": " & dataJson & "}"
    webview.PostWebMessageAsJson json
    Debug.Print "[WebHost Bridge] Response sent: " & requestId
End Sub

Private Sub SendError(ByVal webview As Object, ByVal requestId As String, ByVal errorMsg As String)
    ' Sendet Error-Response an Browser
    Dim json As String
    json = "{""requestId"": """ & requestId & """, ""success"": false, ""error"": """ & EscapeJSON(errorMsg) & """}"
    webview.PostWebMessageAsJson json
    Debug.Print "[WebHost Bridge] Error sent: " & errorMsg
End Sub

' ========================================
' MAPPING & HELPERS
' ========================================

Private Function GetTableName(ByVal dataType As String) As String
    ' Mappt dataType zu Tabellenname
    Select Case dataType
        Case "mitarbeiter"
            GetTableName = "tbl_MA_Mitarbeiterstamm"
        Case "kunden"
            GetTableName = "tbl_KD_Kundenstamm"
        Case "auftraege"
            GetTableName = "tbl_VA_Auftragstamm"
        Case "objekte"
            GetTableName = "tbl_OB_Objekt"
        Case "zuordnungen"
            GetTableName = "tbl_MA_VA_Planung"
        Case "anfragen"
            GetTableName = "tbl_MA_VA_Anfragen"
        Case "schichten"
            GetTableName = "tbl_VA_Start"
        Case "einsatztage"
            GetTableName = "tbl_VA_AnzTage"
        Case "abwesenheiten"
            GetTableName = "tbl_MA_NVerfuegZeiten"
        Case "bewerber"
            GetTableName = "tbl_MA_Bewerber"
        Case "lohnabrechnungen"
            GetTableName = "tbl_Lohn_Abrechnungen"
        Case "zeitkonten"
            GetTableName = "tbl_Zeitkonten_Importfehler"
        Case Else
            GetTableName = ""
    End Select
End Function

Private Function BuildWhereClause(ByVal params As Object) As String
    ' Baut WHERE-Clause aus params-Objekt
    ' Beispiel: params = { "IstAktiv": true, "PLZ": "12345" }
    ' Result: "IstAktiv = True AND PLZ = '12345'"

    On Error Resume Next

    Dim filters As Object
    Dim key As Variant
    Dim value As Variant
    Dim clause As String
    Dim firstFilter As Boolean

    ' filters-Objekt extrahieren
    Set filters = params("filters")
    If filters Is Nothing Then Exit Function

    firstFilter = True

    ' Alle Filter durchlaufen
    For Each key In filters.Keys
        value = filters(key)

        If Not firstFilter Then clause = clause & " AND "

        ' Typ-basiertes Quoting
        Select Case VarType(value)
            Case vbBoolean
                clause = clause & key & " = " & IIf(value, "True", "False")
            Case vbString
                clause = clause & key & " = '" & Replace(value, "'", "''") & "'"
            Case vbDate
                clause = clause & key & " = #" & Format(value, "yyyy-mm-dd") & "#"
            Case vbNull, vbEmpty
                clause = clause & key & " IS NULL"
            Case Else
                clause = clause & key & " = " & value
        End Select

        firstFilter = False
    Next

    BuildWhereClause = clause
End Function

Private Function RecordsetToJSON(ByVal rs As DAO.Recordset) As String
    ' Konvertiert einzelnen Recordset-Datensatz zu JSON
    Dim json As String
    Dim fld As DAO.Field
    Dim firstField As Boolean

    json = "{"
    firstField = True

    For Each fld In rs.Fields
        If Not firstField Then json = json & ","

        json = json & """" & fld.Name & """: "
        json = json & FieldValueToJSON(fld)

        firstField = False
    Next

    json = json & "}"
    RecordsetToJSON = json
End Function

Private Function RecordsetArrayToJSON(ByVal rs As DAO.Recordset) As String
    ' Konvertiert Recordset zu JSON-Array
    Dim json As String
    Dim firstRow As Boolean

    json = "["
    firstRow = True

    Do While Not rs.EOF
        If Not firstRow Then json = json & ","
        json = json & RecordsetToJSON(rs)
        firstRow = False
        rs.MoveNext
    Loop

    json = json & "]"
    RecordsetArrayToJSON = json
End Function

Private Function FieldValueToJSON(ByVal fld As DAO.Field) As String
    ' Konvertiert Field-Wert zu JSON-Format

    If IsNull(fld.Value) Then
        FieldValueToJSON = "null"
        Exit Function
    End If

    Select Case fld.Type
        Case dbBoolean
            FieldValueToJSON = IIf(fld.Value, "true", "false")

        Case dbDate
            FieldValueToJSON = """" & Format(fld.Value, "yyyy-mm-dd hh:nn:ss") & """"

        Case dbText, dbMemo
            FieldValueToJSON = """" & EscapeJSON(fld.Value) & """"

        Case dbByte, dbInteger, dbLong, dbSingle, dbDouble, dbDecimal, dbCurrency
            FieldValueToJSON = CStr(fld.Value)

        Case Else
            FieldValueToJSON = """" & EscapeJSON(CStr(fld.Value)) & """"
    End Select
End Function

Private Sub ApplyFieldsFromJSON(ByRef rs As DAO.Recordset, ByVal data As Object)
    ' Übernimmt Felder aus JSON-Objekt in Recordset

    Dim key As Variant
    Dim value As Variant
    Dim fld As DAO.Field

    For Each key In data.Keys
        ' ID-Feld überspringen
        If UCase(key) = "ID" Then GoTo NextField

        ' Prüfen ob Feld existiert
        On Error Resume Next
        Set fld = rs.Fields(key)
        If Err.Number <> 0 Then
            Debug.Print "[ApplyFields] Feld nicht gefunden: " & key
            Err.Clear
            GoTo NextField
        End If
        On Error GoTo 0

        ' Wert setzen
        value = data(key)
        If IsNull(value) Or IsEmpty(value) Then
            fld.Value = Null
        Else
            fld.Value = value
        End If

NextField:
    Next
End Sub

Private Function EscapeJSON(ByVal text As String) As String
    ' Escaped Sonderzeichen für JSON
    EscapeJSON = Replace(text, "\", "\\")
    EscapeJSON = Replace(EscapeJSON, """", "\""")
    EscapeJSON = Replace(EscapeJSON, vbCrLf, "\n")
    EscapeJSON = Replace(EscapeJSON, vbCr, "\n")
    EscapeJSON = Replace(EscapeJSON, vbLf, "\n")
    EscapeJSON = Replace(EscapeJSON, vbTab, "\t")
End Function
