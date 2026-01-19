'═══════════════════════════════════════════════════════════════════════════════
' Modul:     mod_ExportRelations
' Zweck:     Export aller Tabellen-Beziehungen zu JSON
' Autor:     Access-Forensiker Agent
' Datum:     2025-10-31
' Version:   1.0
'═══════════════════════════════════════════════════════════════════════════════

Option Compare Database
Option Explicit

'═══════════════════════════════════════════════════════════════════════════════
' HAUPT-EXPORT-FUNKTION
'═══════════════════════════════════════════════════════════════════════════════

Public Sub ExportRelationsToJSON(ByVal exportPath As String)
    On Error GoTo ErrorHandler
    
    Dim db As DAO.Database
    Dim rel As DAO.Relation
    Dim fld As DAO.field
    Dim f As Integer
    Dim filePath As String
    Dim firstRelation As Boolean
    Dim firstField As Boolean
    Dim relationCount As Integer
    
    Set db = CurrentDb()
    filePath = exportPath & "\relations.json"
    f = FreeFile
    
    Open filePath For Output As #f
    
    ' JSON-Array starten
    Print #f, "["
    
    firstRelation = True
    relationCount = 0
    
    ' Alle Beziehungen durchgehen
    For Each rel In db.Relations
        ' System-Beziehungen überspringen
        If Left$(rel.Name, 4) <> "MSys" Then
            
            ' Komma vor weiteren Einträgen
            If Not firstRelation Then
                Print #f, ","
            End If
            firstRelation = False
            relationCount = relationCount + 1
            
            ' Beziehungs-Objekt öffnen
            Print #f, "  {"
            Print #f, "    ""name"": """ & mod_ExportConsys.EscapeJSON(rel.Name) & ""","
            Print #f, "    ""table"": """ & mod_ExportConsys.EscapeJSON(rel.Table) & ""","
            Print #f, "    ""foreignTable"": """ & mod_ExportConsys.EscapeJSON(rel.ForeignTable) & ""","
            Print #f, "    ""attributes"": " & rel.attributes & ","
            Print #f, "    ""relationshipType"": """ & GetRelationshipType(rel.attributes) & ""","
            
            ' Relationship-Attribute auswerten
            Print #f, "    ""properties"": {"
            Print #f, "      ""enforceReferentialIntegrity"": " & LCase((rel.attributes And dbRelationUpdateCascade) = dbRelationUpdateCascade Or (rel.attributes And dbRelationDeleteCascade) = dbRelationDeleteCascade) & ","
            Print #f, "      ""cascadeUpdates"": " & LCase((rel.attributes And dbRelationUpdateCascade) = dbRelationUpdateCascade) & ","
            Print #f, "      ""cascadeDeletes"": " & LCase((rel.attributes And dbRelationDeleteCascade) = dbRelationDeleteCascade) & ","
            Print #f, "      ""unique"": " & LCase((rel.attributes And dbRelationUnique) = dbRelationUnique) & ","
            Print #f, "      ""inheritedByReplicaSet"": " & LCase((rel.attributes And dbRelationInherited) = dbRelationInherited)
            Print #f, "    },"
            
            ' Felder exportieren (Primär- und Fremdschlüssel)
            Print #f, "    ""fields"": ["
            firstField = True
            For Each fld In rel.fields
                If Not firstField Then
                    Print #f, ","
                End If
                firstField = False
                
                Print #f, "      {"
                Print #f, "        ""name"": """ & mod_ExportConsys.EscapeJSON(fld.Name) & ""","
                Print #f, "        ""foreignName"": """ & mod_ExportConsys.EscapeJSON(fld.ForeignName) & """"
                Print #f, "      }"
            Next fld
            Print #f, "    ]"
            
            Print #f, "  }"
        End If
    Next rel
    
    ' JSON-Array schließen
    Print #f, "]"
    
    Close #f
    
    Debug.Print "      → " & relationCount & " Beziehungen exportiert"
    
    Exit Sub

ErrorHandler:
    Close #f
    Debug.Print "      ✗ Fehler: " & err.description
    err.Raise err.Number, "ExportRelationsToJSON", err.description
End Sub

'═══════════════════════════════════════════════════════════════════════════════
' HILFSFUNKTIONEN
'═══════════════════════════════════════════════════════════════════════════════

' Bestimmt den Beziehungstyp
Private Function GetRelationshipType(attributes As Long) As String
    ' Standardmäßig One-to-Many
    Dim relType As String
    relType = "One-to-Many"
    
    ' Wenn Unique-Attribut gesetzt ist, dann One-to-One
    If (attributes And dbRelationUnique) = dbRelationUnique Then
        relType = "One-to-One"
    End If
    
    GetRelationshipType = relType
End Function