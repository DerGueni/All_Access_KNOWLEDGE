Attribute VB_Name = "mdl_Query_Creator"
Option Compare Database
Option Explicit

' Zeigt ALLE Queries die mit qry_KreuzTab beginnen
Sub Show_All_KreuzTab_Queries()
    Dim db As DAO.Database
    Dim qdf As DAO.QueryDef
    Dim strOutput As String
    Dim i As Integer
    
    Set db = CurrentDb
    
    strOutput = "ALLE KREUZABFRAGE-QUERIES:" & vbCrLf & String(60, "=") & vbCrLf & vbCrLf
    
    i = 0
    For Each qdf In db.QueryDefs
        If Left(qdf.Name, 14) = "qry_KreuzTab_" Then
            strOutput = strOutput & qdf.Name & vbCrLf
            i = i + 1
        End If
    Next qdf
    
    strOutput = strOutput & vbCrLf & "GESAMT: " & i & " Queries"
    
    Debug.Print strOutput
    MsgBox strOutput, vbInformation, "Alle Kreuzabfragen"
    
    Set qdf = Nothing
    Set db = Nothing
End Sub

' Erstellt gefilterte Versionen basierend auf tatsächlichen Namen
Sub Create_Filtered_Queries_Auto()
    Dim db As DAO.Database
    Dim qdfSource As DAO.QueryDef
    Dim qdfNew As DAO.QueryDef
    Dim strSQL As String
    Dim strBaseName As String
    Dim i As Integer
    Dim arrTargets As Variant
    Dim target As Variant
    
    Set db = CurrentDb
    i = 0
    
    ' Zielmuster für Queries (ohne Jahr-Suffix)
    arrTargets = Array("qry_KreuzTab_MA_Stunden_", "qry_KreuzTab_Privat_", _
                      "qry_KreuzTab_Urlaub_", "qry_KreuzTab_Krank_")
    
    ' Alle Kreuzabfragen durchsuchen
    For Each qdfSource In db.QueryDefs
        If Left(qdfSource.Name, 14) = "qry_KreuzTab_" Then
            
            ' Prüfen ob es eine der Ziel-Queries ist (mit Jahr)
            Dim bIsTarget As Boolean
            bIsTarget = False
            
            For Each target In arrTargets
                If Left(qdfSource.Name, Len(target)) = target Then
                    bIsTarget = True
                    Exit For
                End If
            Next
            
            If bIsTarget Then
                strSQL = qdfSource.sql
                strBaseName = qdfSource.Name
                
                ' Prüfen ob bereits _Fest oder _Mini Suffix hat
                If Right(strBaseName, 5) = "_Fest" Or Right(strBaseName, 5) = "_Mini" Then
                    Debug.Print "○ Übersprungen (bereits Filter): " & strBaseName
                    GoTo NextQuery
                End If
                
                ' === FESTANGESTELLTE ===
                Dim strQryFest As String
                strQryFest = strBaseName & "_Fest"
                
                On Error Resume Next
                db.QueryDefs.Delete strQryFest
                Err.clear
                On Error GoTo 0
                
                Dim strSQLFest As String
                strSQLFest = Add_Where_Smart(strSQL, "tbl_MA_Mitarbeiterstamm.Anstellungsart_ID = 3")
                
                If strSQLFest <> "" Then
                    Set qdfNew = db.CreateQueryDef(strQryFest, strSQLFest)
                    Debug.Print "✓ " & strQryFest
                    i = i + 1
                End If
                
                ' === MINIJOBBER ===
                Dim strQryMini As String
                strQryMini = strBaseName & "_Mini"
                
                On Error Resume Next
                db.QueryDefs.Delete strQryMini
                Err.clear
                On Error GoTo 0
                
                Dim strSQLMini As String
                strSQLMini = Add_Where_Smart(strSQL, "tbl_MA_Mitarbeiterstamm.Anstellungsart_ID = 5")
                
                If strSQLMini <> "" Then
                    Set qdfNew = db.CreateQueryDef(strQryMini, strSQLMini)
                    Debug.Print "✓ " & strQryMini
                    i = i + 1
                End If
            End If
        End If
NextQuery:
    Next qdfSource
    
    Set qdfNew = Nothing
    Set qdfSource = Nothing
    Set db = Nothing
    
    MsgBox "Fertig!" & vbCrLf & vbCrLf & _
           i & " gefilterte Queries erstellt", vbInformation
End Sub

Private Function Add_Where_Smart(strSQL As String, strWhere As String) As String
    Dim strResult As String
    strResult = strSQL
    
    ' Prüfen ob tbl_MA_Mitarbeiterstamm vorkommt
    If InStr(UCase(strResult), "TBL_MA_MITARBEITERSTAMM") = 0 Then
        Add_Where_Smart = ""
        Exit Function
    End If
    
    ' WHERE-Klausel intelligent einfügen
    If InStr(UCase(strResult), " WHERE ") > 0 Then
        ' WHERE existiert - AND hinzufügen
        strResult = Replace(strResult, " WHERE ", " WHERE " & strWhere & " AND ", 1, 1, vbTextCompare)
    ElseIf InStr(UCase(strResult), " GROUP BY ") > 0 Then
        strResult = Replace(strResult, " GROUP BY ", " WHERE " & strWhere & " GROUP BY ", 1, 1, vbTextCompare)
    ElseIf InStr(UCase(strResult), " PIVOT ") > 0 Then
        strResult = Replace(strResult, " PIVOT ", " WHERE " & strWhere & " PIVOT ", 1, 1, vbTextCompare)
    Else
        strResult = strResult & " WHERE " & strWhere
    End If
    
    Add_Where_Smart = strResult
End Function

