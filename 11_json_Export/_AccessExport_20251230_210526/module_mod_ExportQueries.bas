'═══════════════════════════════════════════════════════════════════════════════
' Modul:     mod_ExportQueries
' Zweck:     Export aller Query-Definitionen zu JSON
' Autor:     Access-Forensiker Agent
' Datum:     2025-10-31
' Version:   1.0
'═══════════════════════════════════════════════════════════════════════════════

Option Compare Database
Option Explicit

'═══════════════════════════════════════════════════════════════════════════════
' HAUPT-EXPORT-FUNKTION
'═══════════════════════════════════════════════════════════════════════════════

Public Sub ExportQueryDefsToJSON(ByVal exportPath As String)
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim fld As DAO.field
    Dim prm As DAO.Parameter
    Dim f As Integer
    Dim filePath As String
    Dim firstQuery As Boolean
    Dim firstField As Boolean
    Dim firstParam As Boolean
    Dim queryCount As Integer
    
    Set db = CurrentDb()
    filePath = exportPath & "\queries.json"
    f = FreeFile
    
    Open filePath For Output As #f
    
    ' JSON-Array starten
    Print #f, "["
    
    firstQuery = True
    queryCount = 0
    
    ' Alle Queries durchgehen
    For Each qdf In db.QueryDefs
        ' System-Queries überspringen (beginnend mit ~)
        If Left$(qdf.Name, 1) <> "~" Then
            
            ' Komma vor weiteren Einträgen
            If Not firstQuery Then
                Print #f, ","
            End If
            firstQuery = False
            queryCount = queryCount + 1
            
            ' Query-Objekt öffnen
            Print #f, "  {"
            Print #f, "    ""name"": """ & mod_ExportConsys.EscapeJSON(qdf.Name) & ""","
            Print #f, "    ""type"": " & qdf.Type & ","
            Print #f, "    ""typeName"": """ & GetQueryTypeName(qdf.Type) & ""","
            Print #f, "    ""sql"": """ & mod_ExportConsys.EscapeJSON(qdf.sql) & ""","
            Print #f, "    ""returnsRecords"": " & LCase(qdf.ReturnsRecords) & ","
            Print #f, "    ""recordsAffected"": " & qdf.RecordsAffected & ","
            
            ' Felder exportieren (wenn verfügbar)
            Print #f, "    ""fields"": ["
            On Error Resume Next ' Manche Queries haben keine Felder
            firstField = True
            For Each fld In qdf.fields
                If Err.Number = 0 Then
                    If Not firstField Then
                        Print #f, ","
                    End If
                    firstField = False
                    
                    Print #f, "      {"
                    Print #f, "        ""name"": """ & mod_ExportConsys.EscapeJSON(fld.Name) & ""","
                    Print #f, "        ""type"": " & fld.Type & ","
                    Print #f, "        ""typeName"": """ & GetFieldTypeName(fld.Type) & ""","
                    Print #f, "        ""size"": " & fld.Size
                    Print #f, "      }"
                End If
            Next fld
            On Error GoTo ErrorHandler
            Print #f, "    ],"
            
            ' Parameter exportieren (für Parameter-Queries)
            Print #f, "    ""parameters"": ["
            firstParam = True
            For Each prm In qdf.Parameters
                If Not firstParam Then
                    Print #f, ","
                End If
                firstParam = False
                
                Print #f, "      {"
                Print #f, "        ""name"": """ & mod_ExportConsys.EscapeJSON(prm.Name) & ""","
                Print #f, "        ""type"": " & prm.Type & ","
                Print #f, "        ""typeName"": """ & GetFieldTypeName(prm.Type) & """"
                Print #f, "      }"
            Next prm
            Print #f, "    ],"
            
            ' SQL-Analyse: Tabellen und Felder erkennen
            Print #f, "    ""analysis"": {"
            Print #f, "      ""tablesUsed"": """ & ExtractTablesFromSQL(qdf.sql) & ""","
            Print #f, "      ""hasJoin"": " & LCase(InStr(1, qdf.sql, "JOIN", vbTextCompare) > 0) & ","
            Print #f, "      ""hasWhere"": " & LCase(InStr(1, qdf.sql, "WHERE", vbTextCompare) > 0) & ","
            Print #f, "      ""hasGroupBy"": " & LCase(InStr(1, qdf.sql, "GROUP BY", vbTextCompare) > 0) & ","
            Print #f, "      ""hasOrderBy"": " & LCase(InStr(1, qdf.sql, "ORDER BY", vbTextCompare) > 0) & ""
            Print #f, "    }"
            
            Print #f, "  }"
        End If
    Next qdf
    
    ' JSON-Array schließen
    Print #f, "]"
    
    Close #f
    
    Debug.Print "      → " & queryCount & " Queries exportiert"
    
    Exit Sub

ErrorHandler:
    Close #f
    Debug.Print "      ✗ Fehler: " & Err.description
    Err.Raise Err.Number, "ExportQueryDefsToJSON", Err.description
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' HILFSFUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════

' Gibt den Query-Typ-Namen zurück
Private Function GetQueryTypeName(queryType As Integer) As String
    Select Case queryType
        Case dbQSelect: GetQueryTypeName = "Select"
        Case dbQAction: GetQueryTypeName = "Action"
        Case dbQCrosstab: GetQueryTypeName = "Crosstab"
        Case dbQDelete: GetQueryTypeName = "Delete"
        Case dbQUpdate: GetQueryTypeName = "Update"
        Case dbQAppend: GetQueryTypeName = "Append"
        Case dbQMakeTable: GetQueryTypeName = "MakeTable"
        Case dbQDDL: GetQueryTypeName = "DDL"
        Case dbQSQLPassThrough: GetQueryTypeName = "SQLPassThrough"
        Case dbQSetOperation: GetQueryTypeName = "SetOperation"
        Case dbQSPTBulk: GetQueryTypeName = "SPTBulk"
        Case Else: GetQueryTypeName = "Unknown (" & queryType & ")"
    End Select
End Function

' Gibt den Feld-Typ-Namen zurück
Private Function GetFieldTypeName(fieldType As Integer) As String
    Select Case fieldType
        Case dbBoolean: GetFieldTypeName = "Boolean"
        Case dbByte: GetFieldTypeName = "Byte"
        Case dbInteger: GetFieldTypeName = "Integer"
        Case dbLong: GetFieldTypeName = "Long"
        Case dbCurrency: GetFieldTypeName = "Currency"
        Case dbSingle: GetFieldTypeName = "Single"
        Case dbDouble: GetFieldTypeName = "Double"
        Case dbDate: GetFieldTypeName = "Date/Time"
        Case dbText: GetFieldTypeName = "Text"
        Case dbMemo: GetFieldTypeName = "Memo"
        Case Else: GetFieldTypeName = "Unknown (" & fieldType & ")"
    End Select
End Function

' Extrahiert Tabellennamen aus SQL (einfache Version)
Private Function ExtractTablesFromSQL(sql As String) As String
    Dim tableList As String
    Dim pos As Long
    Dim fromPos As Long
    Dim wherePos As Long
    Dim tableSection As String
    
    ' SQL normalisieren
    sql = UCase(sql)
    
    ' FROM-Position finden
    fromPos = InStr(sql, " FROM ")
    If fromPos = 0 Then
        ExtractTablesFromSQL = ""
        Exit Function
    End If
    
    ' WHERE-Position finden (oder Ende)
    wherePos = InStr(fromPos, sql, " WHERE ")
    If wherePos = 0 Then wherePos = InStr(fromPos, sql, " ORDER ")
    If wherePos = 0 Then wherePos = InStr(fromPos, sql, " GROUP ")
    If wherePos = 0 Then wherePos = Len(sql)
    
    ' Tabellen-Bereich extrahieren
    tableSection = Mid$(sql, fromPos + 6, wherePos - fromPos - 6)
    
    ' Vereinfachen (JOIN entfernen, etc.)
    tableSection = Replace(tableSection, " INNER JOIN ", ",")
    tableSection = Replace(tableSection, " LEFT JOIN ", ",")
    tableSection = Replace(tableSection, " RIGHT JOIN ", ",")
    tableSection = Replace(tableSection, " ON ", " ")
    
    ' Nur Tabellennamen extrahieren (sehr vereinfacht)
    tableList = Trim(tableSection)
    
    ExtractTablesFromSQL = tableList
End Function