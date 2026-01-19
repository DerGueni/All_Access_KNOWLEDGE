Option Compare Database
Option Explicit

Function Set_Priv_Property(ByVal PropertyName As String, ByVal PropertyWert As String, Optional ByVal PropLogin As String = "All")
' Ideal um Einzelwerte in der Datenbank zu speichern

If Len(Trim(Nz(PropLogin))) = 0 Then
    PropLogin = "All"
End If

Dim sqlStr As String
               
On Error Resume Next

'Nicht standardmäßig ausführen, da Tabelle in Backend ...
'Call CreateTabletblProperty

If Len(Trim(Nz(PropertyName))) = 0 Then Exit Function
PropertyWert = Nz(PropertyWert)

    If TCount("PropName", "_tblProperty", "[PropName] = '" & PropertyName & "' AND [PropUser] = '" & PropLogin & "'") > 0 Then
        sqlStr = "UPDATE _tblProperty SET [_tblProperty].PropUser = '" & PropLogin & "', [_tblProperty].PropName = '" & PropertyName & "', [_tblProperty].PropInhalt = '" & fCnvQM(PropertyWert) & "' WHERE ((([_tblProperty].PropName)='" & PropertyName & "' AND [PropUser] = '" & PropLogin & "'));"
    Else
        sqlStr = "INSERT INTO _tblProperty ( PropName, PropUser, PropInhalt ) SELECT '" & PropertyName & "' AS Ausdr1, '" & PropLogin & "' As Ausdr3, '" & fCnvQM(PropertyWert) & "' AS Ausdr2;"
    End If

    CurrentDb.Execute (sqlStr)
End Function

Sub CreateTabletblProperty()

If Not ObjectExists("Table", "_tblProperty") Then
    CurrentDb.Execute ("CREATE TABLE _tblProperty (PropName TEXT(50), PropUser TEXT(50), CONSTRAINT PrimKey PRIMARY KEY (PropName ,PropUser), PropInhalt MEMO);")
End If

End Sub


Function Get_Priv_Property(ByVal PropertyName As String, Optional ByVal PropLogin As String = "All")

On Error Resume Next

If Len(Trim(Nz(PropLogin))) = 0 Then
    PropLogin = "All"
End If

If Len(Trim(Nz(PropertyName))) = 0 Then Exit Function
Get_Priv_Property = Nz(TLookup("PropInhalt", "_tblProperty", "[PropName] = '" & PropertyName & "' AND PropUser = '" & PropLogin & "'"))
End Function


Function Del_Priv_Property(ByVal PropertyName As String, Optional ByVal PropLogin As String = "All")

Dim sqlStr As String

If Len(Trim(Nz(PropLogin))) = 0 Then
    PropLogin = "All"
End If

On Error Resume Next

If Len(Trim(Nz(PropertyName))) = 0 Then Exit Function

sqlStr = "DELETE * FROM _tblProperty WHERE ((([_tblProperty].PropName)='" & PropertyName & "' AND PropUser = ' & PropLogin & " '));"

CurrentDb.Execute (sqlStr)

End Function


Function Get_All_Priv_Property()
Dim db As DAO.Database, i, y As Integer
Set db = DBEngine(0)(0)
y = db.Properties.Count - 1
On Error Resume Next
'ReDim X(Y)
'ReDim XX(Y)
    
For i = 0 To y
'    X(I) = db.Properties(I).Inherited
'    XX(I) = db.Properties(I).Name
    Debug.Print db.Properties(i).Name & " = " & db.Properties(i) '& " " & db.Properties(i).Inherited
Next i

End Function

Private Function ObjectExists(strObjectType As String, strObjectName As String) As Boolean
' Pass the Object type: Table, Query, Form, Report, Macro, or Module
' Pass the Object Name
     Dim db As DAO.Database
     Dim tbl As TableDef
     Dim QRY As QueryDef
     Dim i As Integer
     
     Set db = CurrentDb()
     ObjectExists = False
     
     If strObjectType = "Table" Then
          For Each tbl In db.TableDefs
               If tbl.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next tbl
     ElseIf strObjectType = "Query" Then
          For Each QRY In db.QueryDefs
               If QRY.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next QRY
     ElseIf strObjectType = "Form" Or strObjectType = "Report" Or strObjectType = "Module" Then
          For i = 0 To db.Containers(strObjectType & "s").Documents.Count - 1
               If db.Containers(strObjectType & "s").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     ElseIf strObjectType = "Macro" Then
          For i = 0 To db.Containers("Scripts").Documents.Count - 1
               If db.Containers("Scripts").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     Else
          MsgBox "Invalid Object Type passed, must be Table, Query, Form, Report, Macro, or Module"
     End If

Set db = Nothing
     
End Function