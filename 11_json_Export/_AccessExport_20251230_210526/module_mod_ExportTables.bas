'═══════════════════════════════════════════════════════════════════════════════
' Modul:     mod_ExportTables
' Zweck:     Export aller Tabellen-Definitionen zu JSON
' Autor:     Access-Forensiker Agent
' Datum:     2025-10-31
' Version:   1.0
'═══════════════════════════════════════════════════════════════════════════════

Option Compare Database
Option Explicit

'═══════════════════════════════════════════════════════════════════════════════
' HAUPT-EXPORT-FUNKTION
'═══════════════════════════════════════════════════════════════════════════════

Public Sub ExportTableDefsToJSON(ByVal exportPath As String)
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim tdf As DAO.TableDef
    Dim fld As DAO.field
    Dim idx As DAO.Index
    Dim f As Integer
    Dim filePath As String
    Dim firstTable As Boolean
    Dim firstField As Boolean
    Dim firstIndex As Boolean
    Dim tableCount As Integer
    
    Set db = CurrentDb()
    filePath = exportPath & "\tables.json"
    f = FreeFile
    
    Open filePath For Output As #f
    
    ' JSON-Array starten
    Print #f, "["
    
    firstTable = True
    tableCount = 0
    
    ' Alle Tabellen durchgehen
    For Each tdf In db.TableDefs
        ' System-Tabellen überspringen
        If Left$(tdf.Name, 4) <> "MSys" And Left$(tdf.Name, 1) <> "~" Then
            
            ' Komma vor weiteren Einträgen
            If Not firstTable Then
                Print #f, ","
            End If
            firstTable = False
            tableCount = tableCount + 1
            
            ' Tabellen-Objekt öffnen
            Print #f, "  {"
            Print #f, "    ""name"": """ & mod_ExportConsys.EscapeJSON(tdf.Name) & ""","
            Print #f, "    ""recordCount"": " & tdf.RecordCount & ","
            Print #f, "    ""dateCreated"": """ & Format(tdf.DateCreated, "yyyy-mm-dd hh:nn:ss") & ""","
            Print #f, "    ""lastUpdated"": """ & Format(tdf.LastUpdated, "yyyy-mm-dd hh:nn:ss") & ""","
            
            ' Felder exportieren
            Print #f, "    ""fields"": ["
            firstField = True
            For Each fld In tdf.fields
                If Not firstField Then
                    Print #f, ","
                End If
                firstField = False
                
                Print #f, "      {"
                Print #f, "        ""name"": """ & mod_ExportConsys.EscapeJSON(fld.Name) & ""","
                Print #f, "        ""type"": " & fld.Type & ","
                Print #f, "        ""typeName"": """ & GetFieldTypeName(fld.Type) & ""","
                Print #f, "        ""size"": " & fld.Size & ","
                Print #f, "        ""required"": " & LCase(fld.Required) & ","
                Print #f, "        ""allowZeroLength"": " & LCase(GetFieldProperty(fld, "AllowZeroLength"))
                
                ' Default Value wenn vorhanden
                If Len(Nz(fld.defaultValue, "")) > 0 Then
                    Print #f, ","
                    Print #f, "        ""defaultValue"": """ & mod_ExportConsys.EscapeJSON(fld.defaultValue) & """"
                End If
                
                ' Validation Rule wenn vorhanden
                If Len(Nz(fld.ValidationRule, "")) > 0 Then
                    Print #f, ","
                    Print #f, "        ""validationRule"": """ & mod_ExportConsys.EscapeJSON(fld.ValidationRule) & ""","
                    Print #f, "        ""validationText"": """ & mod_ExportConsys.EscapeJSON(fld.ValidationText) & """"
                End If
                
                Print #f, "      }"
            Next fld
            Print #f, "    ],"
            
            ' Indizes exportieren
            Print #f, "    ""indexes"": ["
            firstIndex = True
            For Each idx In tdf.Indexes
                If Not firstIndex Then
                    Print #f, ","
                End If
                firstIndex = False
                
                Print #f, "      {"
                Print #f, "        ""name"": """ & mod_ExportConsys.EscapeJSON(idx.Name) & ""","
                Print #f, "        ""primary"": " & LCase(idx.Primary) & ","
                Print #f, "        ""unique"": " & LCase(idx.Unique) & ","
                Print #f, "        ""required"": " & LCase(idx.Required) & ","
                Print #f, "        ""fields"": """ & GetIndexFields(idx) & """"
                Print #f, "      }"
            Next idx
            Print #f, "    ]"
            
            Print #f, "  }"
        End If
    Next tdf
    
    ' JSON-Array schließen
    Print #f, "]"
    
    Close #f
    
    Debug.Print "      → " & tableCount & " Tabellen exportiert"
    
    Exit Sub

ErrorHandler:
    Close #f
    Debug.Print "      ✗ Fehler: " & Err.description
    Err.Raise Err.Number, "ExportTableDefsToJSON", Err.description
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' HILFSFUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════

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
        Case dbLongBinary: GetFieldTypeName = "OLE Object"
        Case dbMemo: GetFieldTypeName = "Memo"
        Case dbGUID: GetFieldTypeName = "GUID"
        Case dbBigInt: GetFieldTypeName = "BigInt"
        Case dbVarBinary: GetFieldTypeName = "VarBinary"
        Case dbChar: GetFieldTypeName = "Char"
        Case dbNumeric: GetFieldTypeName = "Numeric"
        Case dbDecimal: GetFieldTypeName = "Decimal"
        Case dbFloat: GetFieldTypeName = "Float"
        Case dbTime: GetFieldTypeName = "Time"
        Case dbTimeStamp: GetFieldTypeName = "TimeStamp"
        Case Else: GetFieldTypeName = "Unknown (" & fieldType & ")"
    End Select
End Function

' Gibt Field-Property zurück
Private Function GetFieldProperty(fld As DAO.field, propName As String) As Variant
    On Error Resume Next
    GetFieldProperty = fld.Properties(propName)
    If Err.Number <> 0 Then
        GetFieldProperty = False
    End If
    On Error GoTo 0
End Function

' Gibt Index-Felder als kommaseparierte Liste zurück
Private Function GetIndexFields(idx As DAO.Index) As String
    Dim fld As DAO.field
    Dim fieldList As String
    
    fieldList = ""
    For Each fld In idx.fields
        If Len(fieldList) > 0 Then
            fieldList = fieldList & ", "
        End If
        fieldList = fieldList & fld.Name
    Next fld
    
    GetIndexFields = fieldList
End Function