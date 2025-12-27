Attribute VB_Name = "zmd_Ersatzfunktionen"
Option Compare Database

'Ersatz für DLookup()
Public Function TLookup(ByVal expression As String, ByVal domain As String, _
                Optional ByVal Criteria, Optional ByVal extDB) As Variant
 
On Error GoTo TLookup_Err
 
Dim strSQL As String

    strSQL = "SELECT [" & expression & "] FROM [" & domain & "]"
    If Not IsMissing(extDB) Then strSQL = strSQL & " IN '" & extDB & "'"
    If Not IsMissing(Criteria) Then strSQL = strSQL & " WHERE " & Criteria
    TLookup = DBEngine(0)(0).OpenRecordset(strSQL, dbOpenSnapshot)(0)
    Exit Function
 
TLookup_Err:
  Select Case Err.Number
    Case 3021  'kein Datensatz gefunden
      TLookup = Null
    Case 3061  'einer der Feldnamen (Ausdruck oder Kriterium) stimmt nicht
      TLookup = "#Ausdruck/Kriterium"
    Case 3078  'Name der Tabelle oder Abfrage stimmt nicht
      TLookup = "#Domäne"
    Case 3464  'Datentyp im Kriterium ist falsch
      TLookup = "#Kriterium"
    Case Else  'Sonstige Fehler
      TLookup = "#Fehler"
  End Select
 
End Function


'Ersatz für DLookup() mit mehreren Ausgaben
Public Function TLookupMulti(sExpr As String, sDomain As String, Optional vCriteria As Variant, Optional sOrderClause As String) As Variant

Dim rs      As DAO.Recordset
Dim sSQL    As String
Dim tmp     As Variant
Dim result  As Variant

On Error GoTo Mark_Error
        
    ReDim result(0)
    
    If sExpr <> "" And sDomain <> "" Then
        ' SQL-String zusammensetzen
        sSQL = "SELECT " & sExpr & " FROM " & sDomain
        If Not IsMissing(vCriteria) Then
            sSQL = sSQL & " WHERE " & vCriteria
        End If
        If sOrderClause <> "" Then
            sSQL = sSQL & " ORDER BY " & sOrderClause
        End If
        sSQL = sSQL & ";"
        ' Abfrage ausführen
        Set rs = CurrentDb.OpenRecordset(sSQL, dbOpenSnapshot)
        ' Ergebnis übergeben
        If Not rs.EOF Then
            rs.MoveLast
            rs.MoveFirst
            tmp = rs.GetRows(rs.RecordCount)
            For i = LBound(tmp, 2) To UBound(tmp, 2)
                ReDim Preserve result(i)
                result(i) = tmp(0, i)
            Next i
        End If
        rs.Close
    End If
    
Mark_Exit:
    TLookupMulti = result
    Set rs = Nothing
    Exit Function
Mark_Error:
    Resume Mark_Exit
End Function



'Ersatz für DMax()
Public Function TMax(ByVal expression As String, ByVal domain As String, _
                       Optional ByVal Criteria, Optional ByVal extDB) As Variant
 
On Error GoTo TMax_Err
 
Dim strSQL As String

    strSQL = "SELECT Max(" & expression & ") FROM " & domain
    If Not IsMissing(extDB) Then strSQL = strSQL & " IN '" & extDB & "'"
    If Not IsMissing(Criteria) Then strSQL = strSQL & " WHERE " & Criteria
    TMax = DBEngine(0)(0).OpenRecordset(strSQL, 8)(0)
    Exit Function
 
TMax_Err:
  Select Case Err.Number
    Case 3061  'einer der Feldnamen (Ausdruck oder Kriterium) stimmt nicht
      TMax = "#Ausdruck/Kriterium"
    Case 3078  'Name der Tabelle oder Abfrage stimmt nicht
      TMax = "#Domäne"
    Case 3464  'Datentyp im Kriterium ist falsch
      TMax = "#Kriterium"
    Case Else  'Sonstige Fehler
      TMax = "#Fehler"
  End Select
 
End Function


'Ersatz für DCount()
Public Function TCount(ByVal expression As String, ByVal domain As String, _
                       Optional ByVal Criteria, Optional ByVal extDB) As Variant
 
On Error GoTo TCount_Err
 
Dim strSQL As String

    strSQL = "SELECT COUNT(" & expression & ") FROM " & domain
    If Not IsMissing(extDB) Then strSQL = strSQL & " IN '" & extDB & "'"
    If Not IsMissing(Criteria) Then strSQL = strSQL & " WHERE " & Criteria
    TCount = DBEngine(0)(0).OpenRecordset(strSQL, 8)(0)
    Exit Function
 
TCount_Err:
  Select Case Err.Number
    Case 3061  'einer der Feldnamen (Ausdruck oder Kriterium) stimmt nicht
      TCount = "#Ausdruck/Kriterium"
    Case 3078  'Name der Tabelle oder Abfrage stimmt nicht
      TCount = "#Domäne"
    Case 3464  'Datentyp im Kriterium ist falsch
      TCount = "#Kriterium"
    Case Else  'Sonstige Fehler
      TCount = "#Fehler"
  End Select
 
End Function


'Ersatz für DSum()
Public Function TSum(ByVal expression As String, ByVal domain As String, _
                Optional ByVal Criteria, Optional ByVal extDB) As Variant
 
On Error GoTo TSum_Err
 
Dim strSQL As String

    strSQL = "SELECT SUM(" & expression & ") FROM " & domain
    If Not IsMissing(extDB) Then strSQL = strSQL & " IN '" & extDB & "'"
    If Not IsMissing(Criteria) Then strSQL = strSQL & " WHERE " & Criteria
    TSum = DBEngine(0)(0).OpenRecordset(strSQL, 8)(0)
    Exit Function
 
TSum_Err:
  Select Case Err.Number
    Case 3061  'einer der Feldnamen (Ausdruck oder Kriterium) stimmt nicht
      TSum = "#Ausdruck/Kriterium"
    Case 3075  'Summierender Ausdruck ist falsch (z.B. "*" ist n. mgl.)
      TSum = "#Ausdruck"
    Case 3078  'Name der Tabelle oder Abfrage stimmt nicht
      TSum = "#Domäne"
    Case 3464  'Datentyp im Kriterium ist falsch
      TSum = "#Kriterium"
    Case Else  'Sonstige Fehler
      TSum = "#Fehler"
  End Select
 
End Function


'Tabelle updaten
Function TUpdate(ByVal expression As String, ByVal domain As String, Optional ByVal Criteria, Optional ByVal extDB) As Variant

On Error GoTo TUpdate_Err
 
Dim strSQL As String

    If Not IsMissing(extDB) Then
        strSQL = "UPDATE [" & domain & "] IN '" & extDB & "' SET " & expression
    Else
        strSQL = "UPDATE [" & domain & "] SET " & expression
    End If
    If Not IsMissing(Criteria) Then strSQL = strSQL & " WHERE " & Criteria
    CurrentDb.Execute strSQL
    TUpdate = "OK"
    Exit Function
 
TUpdate_Err:
  Select Case Err.Number
    Case 3061  'einer der Feldnamen (Ausdruck oder Kriterium) stimmt nicht
      TUpdate = "#Ausdruck/Kriterium"
    Case 3075  'Summierender Ausdruck ist falsch (z.B. "*" ist n. mgl.)
      TUpdate = "#Ausdruck"
    Case 3078  'Name der Tabelle oder Abfrage stimmt nicht
      TUpdate = "#Domäne"
    Case 3464  'Datentyp im Kriterium ist falsch
      TUpdate = "#Kriterium"
    Case Else  'Sonstige Fehler
      TUpdate = "#Fehler"
  End Select
  
End Function

'Tabelle insert
Function TInsert(ByVal expression As String, ByVal domain As String, ByVal Criteria, Optional ByVal extDB) As Variant

On Error GoTo Tinsert_Err
 
Dim strSQL As String

    If Not IsMissing(extDB) Then
        strSQL = "UPDATE [" & domain & "] IN '" & extDB & "' VALUES " & expression
    Else
        strSQL = "UPDATE [" & domain & "] VALUES " & expression
    End If
    If Not IsMissing(Criteria) Then strSQL = strSQL & " WHERE " & Criteria
    CurrentDb.Execute strSQL
    TInsert = "OK"
    Exit Function
 
Tinsert_Err:
  Select Case Err.Number
    Case 3061  'einer der Feldnamen (Ausdruck oder Kriterium) stimmt nicht
      TInsert = "#Ausdruck/Kriterium"
    Case 3075  'Summierender Ausdruck ist falsch (z.B. "*" ist n. mgl.)
      TInsert = "#Ausdruck"
    Case 3078  'Name der Tabelle oder Abfrage stimmt nicht
      TInsert = "#Domäne"
    Case 3464  'Datentyp im Kriterium ist falsch
      TInsert = "#Kriterium"
    Case Else  'Sonstige Fehler
      TInsert = "#Fehler"
  End Select
  
End Function


'Autowert zurücksetzen
Function autowert_reset(tbl As String, spalte As String)

Dim tbltmp As String

    tbltmp = "temp_buffer"
    
    If TableExists(tbltmp) Then CurrentDb.Execute "DROP TABLE " & tbltmp
    
    CurrentDb.Execute "SELECT * INTO " & tbltmp & " FROM " & tbl
    CurrentDb.Execute "DELETE * FROM " & tbl
    CurrentDb.Execute "ALTER TABLE " & tbl & " ALTER COLUMN " & spalte & " COUNTER(1, 1)"
    CurrentDb.Execute "INSERT INTO " & tbl & " SELECT * FROM " & tbltmp
    CurrentDb.Execute "DROP TABLE " & tbltmp
    
End Function


'Autowert reset
Function autowert_reset_extDB(db As String, tbl As String, spalte As String, spaltenart As String)

    Dim ConnDB As Object
    Set ConnDB = CreateObject("ADODB.Connection")
    
    tbltmp = "temp_buffer"
        
    ConnDB.Open "Provider=Microsoft.ACE.OLEDB.12.0; Data Source=" & db
    ConnDB.Execute "SELECT * INTO " & tbltmp & " FROM " & tbl
    ConnDB.Execute "DELETE * FROM " & tbl
    ConnDB.Execute "ALTER TABLE " & tbl & " ALTER COLUMN " & spalte & " COUNTER(1, 1)"
    ConnDB.Execute "ALTER TABLE " & tbltmp & " DROP COLUMN " & spalte
    ConnDB.Execute "ALTER TABLE " & tbltmp & " ADD COLUMN " & spalte & " " & spaltenart
    ConnDB.Execute "INSERT INTO " & tbl & " SELECT * FROM " & tbltmp
    ConnDB.Execute "DROP TABLE " & tbltmp
    ConnDB.Close
    Set ConnDB = Nothing

End Function

'Autowert zurücksetzen
Function Restet_ZK_Stunden_autowert()

    Call autowert_reset_extDB(PfadProd & Backend, "ztbl_ZK_Stunden", "ID", "COUNTER;")
    
End Function


