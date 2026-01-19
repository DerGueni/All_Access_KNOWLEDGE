Attribute VB_Name = "mdl_Universal_Filter"
Option Compare Database
Option Explicit



' UNIVERSELLE FILTER-LÖSUNG für ALLE Query-Typen

Sub Show_All_Queries_With_Bemerkungen()
    ' Zeigt alle Queries an, die das Feld "Bemerkungen" verwenden
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim strMsg As String
    Dim intCount As Integer
    
    Set db = CurrentDb
    strMsg = "QUERIES MIT FELD 'Bemerkungen':" & vbCrLf & vbCrLf
    intCount = 0
    
    For Each qdf In db.QueryDefs
        If InStr(1, qdf.sql, "Bemerkungen", vbTextCompare) > 0 Then
            intCount = intCount + 1
            strMsg = strMsg & intCount & ". " & qdf.Name & vbCrLf
        End If
    Next qdf
    
    If intCount = 0 Then
        strMsg = "Keine Queries mit Feld 'Bemerkungen' gefunden."
    Else
        strMsg = strMsg & vbCrLf & "GESAMT: " & intCount & " Queries"
    End If
    
    MsgBox strMsg, vbInformation, "Bemerkungen-Filter Kandidaten"
    
    Set db = Nothing
End Sub

Sub Create_Filtered_Versions_Universal()
    ' Erstellt gefilterte Versionen für ALLE Queries mit Bemerkungen-Feld
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim qdfNew As DAO.QueryDef
    Dim strSQL As String
    Dim strNewName As String
    Dim intCreated As Integer
    Dim intSkipped As Integer
    
    Set db = CurrentDb
    intCreated = 0
    intSkipped = 0
    
    On Error Resume Next
    
    For Each qdf In db.QueryDefs
        ' Nur Queries die "Bemerkungen" enthalten
        If InStr(1, qdf.sql, "Bemerkungen", vbTextCompare) > 0 And _
           Not qdf.Name Like "*_Filtered" Then
            
            strNewName = qdf.Name & "_Filtered"
            strSQL = qdf.sql
            
            ' WHERE-Klausel intelligent einfügen
            strSQL = Add_Bemerkungen_Filter(strSQL)
            
            If strSQL <> "" Then
                ' Alte Version löschen
                db.QueryDefs.Delete strNewName
                Err.clear
                
                ' Neue erstellen
                Set qdfNew = db.CreateQueryDef(strNewName, strSQL)
                
                If Err.Number = 0 Then
                    intCreated = intCreated + 1
                    Debug.Print "✓ " & strNewName
                Else
                    intSkipped = intSkipped + 1
                    Debug.Print "✗ " & qdf.Name & " - " & Err.description
                End If
            Else
                intSkipped = intSkipped + 1
            End If
        End If
    Next qdf
    
    MsgBox intCreated & " gefilterte Queries erstellt!" & vbCrLf & _
           intSkipped & " übersprungen" & vbCrLf & vbCrLf & _
           "Details im Direktfenster (STRG+G)", vbInformation, "Erfolg"
    
    Set db = Nothing
End Sub

Private Function Add_Bemerkungen_Filter(ByVal strSQL As String) As String
    ' Fügt WHERE-Filter für Bemerkungen hinzu (intelligent)
    Dim strResult As String
    
    On Error GoTo ErrHandler
    
    strResult = strSQL
    
    ' Entferne Semikolon am Ende
    strResult = Trim(strResult)
    If Right(strResult, 1) = ";" Then
        strResult = Left(strResult, Len(strResult) - 1)
    End If
    
    ' Prüfe ob WHERE bereits existiert
    If InStr(1, strResult, " WHERE ", vbTextCompare) > 0 Then
        ' WHERE existiert - AND hinzufügen
        strResult = strResult & " AND ([Bemerkungen] Is Null OR [Bemerkungen] = '')"
    Else
        ' Kein WHERE - neu hinzufügen
        ' Für UNION, ORDER BY, GROUP BY vor dem Anhängen suchen
        Dim pos As Long
        pos = InStr(1, strResult, " UNION ", vbTextCompare)
        If pos = 0 Then pos = InStr(1, strResult, " ORDER BY ", vbTextCompare)
        If pos = 0 Then pos = InStr(1, strResult, " GROUP BY ", vbTextCompare)
        
        If pos > 0 Then
            ' Vor UNION/ORDER/GROUP einfügen
            strResult = Left(strResult, pos - 1) & _
                       " WHERE ([Bemerkungen] Is Null OR [Bemerkungen] = '')" & _
                       Mid(strResult, pos)
        Else
            ' Am Ende anfügen
            strResult = strResult & " WHERE ([Bemerkungen] Is Null OR [Bemerkungen] = '')"
        End If
    End If
    
    strResult = strResult & ";"
    Add_Bemerkungen_Filter = strResult
    Exit Function
    
ErrHandler:
    Add_Bemerkungen_Filter = ""
End Function

Sub Remove_All_Filtered_Queries()
    ' Entfernt alle *_Filtered Queries
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim intDeleted As Integer
    
    Set db = CurrentDb
    intDeleted = 0
    
    On Error Resume Next
    
    For Each qdf In db.QueryDefs
        If qdf.Name Like "*_Filtered" Then
            db.QueryDefs.Delete qdf.Name
            If Err.Number = 0 Then
                intDeleted = intDeleted + 1
            End If
            Err.clear
        End If
    Next qdf
    
    MsgBox intDeleted & " gefilterte Queries gelöscht!", vbInformation
    
    Set db = Nothing
End Sub


