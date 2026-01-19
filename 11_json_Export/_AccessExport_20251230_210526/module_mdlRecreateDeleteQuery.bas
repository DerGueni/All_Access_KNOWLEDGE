Option Compare Database
Option Explicit

' VBA MODULE: Undelete tables and queries in Microsoft Access
' (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
' Written 18/04/2005
'
' REQUIREMENTS: VBA DAO Reference, Access 97/2000/2002(XP)/2003
'
' This module will allow you to undelete tables and queries
' after they have been deleted in Access/Jet.
'
' Please note that this will only work if you haven't run the
' 'Compact' or 'Compact And Repair' option from Access/DAO.
' If you have run the compact option, your tables/queries
' have been permananetly deleted.
'
' You may modify this code as you please,
' However you must leave the copyright notices in place.
' Thank you.
'
' USAGE: Just import this VBA module into your project
' and call FnUndeleteObjects()
'
' If any un-deletable objects are found, you will be prompted
' to choose names for the undeleted objects.
' Note: In Access 2000, table names are usually recovered too.

Public Function FnUndeleteObjects() As Boolean

'Module (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
'Written 18/04/2005

On Error GoTo ErrorHandler:

    Dim strObjectName As String
    Dim rsTables As DAO.Recordset
    Dim dbsDatabase As DAO.Database

    Dim tDef As DAO.TableDef
    Dim qDef As DAO.QueryDef

    Dim intNumDeletedItemsFound As Integer

    Set dbsDatabase = CurrentDb

    For Each tDef In dbsDatabase.TableDefs
        'This is actually used as a 'Deleted Flag'
        If tDef.attributes And dbHiddenObject Then

            strObjectName = FnGetDeletedTableNameByProp(tDef.Name)
            strObjectName = InputBox("A deleted TABLE has been found." & _
                                     vbCrLf & vbCrLf & _
                                     "To undelete this object, enter a new name:", _
                                     "Access Undelete Table", strObjectName)

            If Len(strObjectName) > 0 Then

                 FnUndeleteTable CurrentDb, tDef.Name, strObjectName

            End If

            intNumDeletedItemsFound = intNumDeletedItemsFound + 1

        End If

    Next tDef

    For Each qDef In dbsDatabase.QueryDefs

        'Note 'Attributes' flag is not exposed for QueryDef objects,
        'We could look up the flag by using MSysObjects but
        'new queries don't get written to MSysObjects until
        'Access is closed. Therefore we'll just check the
        'start of the name is '~TMPCLP' ...

        If InStr(1, qDef.Name, "~TMPCLP") = 1 Then

            strObjectName = ""
            strObjectName = InputBox("A deleted QUERY has been found." & _
                                     vbCrLf & vbCrLf & _
                                     "To undelete this object, enter a new name:", _
                                     "Access Undelete Query", strObjectName)

            If Len(strObjectName) > 0 Then

                 If FnUndeleteQuery(CurrentDb, qDef.Name, strObjectName) Then

                     'We'll rename the deleted object since we've made a
                     'copy and won't be needing to re-undelete it.
                     '(To break the condition "~TMPCLP" in future...)
                     qDef.Name = "~TMPCLQ" & Right$(qDef.Name, Len(qDef.Name) - 7)

                 End If

            End If

            intNumDeletedItemsFound = intNumDeletedItemsFound + 1

        End If

    Next qDef

    If intNumDeletedItemsFound = 0 Then

        MsgBox "Unable to find any deleted tables/queries to undelete!"

    End If

    Set dbsDatabase = Nothing
    FnUndeleteObjects = True

ExitFunction:
    Exit Function

ErrorHandler:
    MsgBox "Error occured in FnUndeleteObjects() - " & _
            Err.description & " (" & CStr(Err.Number) & ")"
    GoTo ExitFunction

End Function

Private Function FnUndeleteTable(dbDatabase As DAO.Database, _
                                                strDeletedTableName As String, _
                                                strNewTableName As String)

'Module (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
'Written 18/04/2005

    Dim tDef As DAO.TableDef

    Set tDef = dbDatabase.TableDefs(strDeletedTableName)

    'Remove the Deleted Flag...
    tDef.attributes = tDef.attributes And Not dbHiddenObject

    'Rename the deleted object to the original or new name...
        tDef.Name = strNewTableName

    dbDatabase.TableDefs.Refresh
    Application.RefreshDatabaseWindow

    Set tDef = Nothing

End Function

Private Function FnUndeleteQuery(dbDatabase As DAO.Database, _
                                                strDeletedQueryName As String, _
                                                strNewQueryName As String)

'Module (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
'Written 18/04/2005

    'We can't just remove the Deleted flag on queries
    '('Attributes' is not an exposed property)
    'So instead we create a new query with the SQL...

    'Note: Can't use DoCmd.CopyObject as it copies the dbHiddenObject attribute!
        If FnCopyQuery(dbDatabase, strDeletedQueryName, strNewQueryName) Then

            FnUndeleteQuery = True
            Application.RefreshDatabaseWindow

        End If

End Function

Private Function FnCopyQuery(dbDatabase As DAO.Database, _
                                            strSourceName As String, _
                                            strDestinationName As String)

'Module (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
'Written 18/04/2005

    On Error GoTo ErrorHandler:

    Dim qDefOld As DAO.QueryDef
    Dim qDefNew As DAO.QueryDef
    Dim field As DAO.field

    Set qDefOld = dbDatabase.QueryDefs(strSourceName)
    Set qDefNew = dbDatabase.CreateQueryDef(strDestinationName, qDefOld.sql)

    'Copy root query properties...
        FnCopyLvProperties qDefNew, qDefOld.Properties, qDefNew.Properties

    For Each field In qDefOld.fields

        'Copy each fields individual properties...
            FnCopyLvProperties qDefNew.fields(field.Name), _
                                field.Properties, _
                                qDefNew.fields(field.Name).Properties

    Next field

    dbDatabase.QueryDefs.Refresh

    FnCopyQuery = True

ExitFunction:
    Set qDefNew = Nothing
    Set qDefOld = Nothing

    Exit Function

ErrorHandler:
    MsgBox "Error re-creating query '" & strDestinationName & "':" & vbCrLf & _
                Err.description & " (" & CStr(Err.Number) & ")"
    GoTo ExitFunction

End Function

Private Function PropExists(Props As DAO.Properties, _
                             strPropName As String) As Boolean

'Module (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
'Written 18/04/2005

'If properties fail to be created, we'll just ignore the errors
On Error Resume Next

    Dim Prop As DAO.Property

    For Each Prop In Props

        If Prop.Name = strPropName Then

            PropExists = True
            Exit Function ' Short circuit

        End If

    Next Prop

    PropExists = False

End Function

Private Sub FnCopyLvProperties(objObject As Object, _
                                                OldProps As DAO.Properties, _
                                                NewProps As DAO.Properties)

'Module (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
'Written 18/04/2005

'If properties fail to be created, we'll just ignore the errors
On Error Resume Next

    Dim Prop As DAO.Property
    Dim NewProp As DAO.Property

    For Each Prop In OldProps

        If Not PropExists(NewProps, Prop.Name) Then

            If IsNumeric(Prop.Value) Then
                NewProps.append objObject.CreateProperty(Prop.Name, _
                                                         Prop.Type, _
                                                         CLng(Prop.Value))
            Else
                NewProps.append objObject.CreateProperty(Prop.Name, _
                                                         Prop.Type, _
                                                         Prop.Value)
            End If

        Else

            With NewProps(Prop.Name)

                .Type = Prop.Type
                .Value = Prop.Value

            End With

        End If

    Next Prop

End Sub

Private Function FnGetDeletedTableNameByProp(strRealTableName As String) _
                                             As String

'Module (c) 2005 Wayne Phillips (http://www.everythingaccess.com)
'Written 18/04/2005

'If an error occurs here, just ignore (user will override the blank name)
On Error Resume Next

    Dim i As Long
    Dim strNameMap As String

    'Try to extract the name from the AutoCorrect data if it's available...

    strNameMap = CurrentDb.TableDefs(strRealTableName).Properties("NameMap")
    strNameMap = Mid(strNameMap, 23) 'Offset of the table name...

    'Find the null terminator...
    i = 1
    If Len(strNameMap) > 0 Then

        While (i < Len(strNameMap)) And (Asc(Mid(strNameMap, i)) <> 0)

            i = i + 1

        Wend

    End If

    FnGetDeletedTableNameByProp = Left(strNameMap, i - 1)

End Function