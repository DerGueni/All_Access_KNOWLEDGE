Attribute VB_Name = "mdl_TM-AccessSecurity"
Option Compare Database
Option Explicit

Public Sub TM_ShowAllGroups()
'
'    Name: TM_ShowAllGroups
'   Zweck: Zeigt alle Gruppen im Direktfenster an
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: -
'
'  Output: Die Namen aller Gruppen (im Direktfenster)
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_TM_ShowAllGroups

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim grp As DAO.Group
    
    Set wrk = DBEngine.Workspaces(0)
    
    For Each grp In wrk.Groups
        Debug.Print grp.Name
    Next grp

'Ende
Exit_TM_ShowAllGroups:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Sub

'Fehlerbehandlung
Err_TM_ShowAllGroups:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_TM_ShowAllGroups
    End Select
        
End Sub

Public Sub TM_ShowAllUsers()
'
'    Name: TM_ShowAllUsers
'   Zweck: Zeigt die Namen aller User im Direktfenster an
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: -
'
'  Output: Alle Usewr (im Direktfenster)
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_TM_ShowAllUsers

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim usr As DAO.User
    
    Set wrk = DBEngine.Workspaces(0)
    
    For Each usr In wrk.Users
        Debug.Print usr.Name
    Next usr

'Ende
Exit_TM_ShowAllUsers:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Sub

'Fehlerbehandlung
Err_TM_ShowAllUsers:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_TM_ShowAllUsers
    End Select
        
End Sub

Public Sub TM_ShowAllUsersWithGroups()
'
'    Name: TM_ShowAllUsersWithGroups
'   Zweck: Zeigt alle User und deren Gruppen im Direktfenster an
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: -
'
'  Output: Alle User und deren Gruppen (im Direktfenster)
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_TM_ShowAllUsersWithGroups

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim usr As DAO.User
    Dim i As Integer
    
    Set wrk = DBEngine.Workspaces(0)
    
    For Each usr In wrk.Users
        Debug.Print usr.Name
        For i = 0 To usr.Groups.Count - 1
            Debug.Print "   " & usr.Groups(i).Name
        Next i
    Next usr

'Ende
Exit_TM_ShowAllUsersWithGroups:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Sub

'Fehlerbehandlung
Err_TM_ShowAllUsersWithGroups:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_TM_ShowAllUsersWithGroups
    End Select
        
End Sub

Public Sub TM_ShowAllGroupsWithUsers()
'
'    Name: TM_ShowAllGroupsWithUsers
'   Zweck: Zeigt alle Gruppen und deren User im Direktfenster an
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: -
'
'  Output: Alle Gruppen und deren User (im Direktfenster)
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_TM_ShowAllGroupsWithUsers

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim grp As DAO.Group
    Dim i As Integer
    
    Set wrk = DBEngine.Workspaces(0)
    
    For Each grp In wrk.Groups
        Debug.Print grp.Name
        For i = 0 To grp.Users.Count - 1
            Debug.Print "   " & grp.Users(i).Name
        Next i
    Next grp

'Ende
Exit_TM_ShowAllGroupsWithUsers:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Sub

'Fehlerbehandlung
Err_TM_ShowAllGroupsWithUsers:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_TM_ShowAllGroupsWithUsers
    End Select
        
End Sub

Public Function fTM_AddUser(UserName As String, PID As String, Passwort As String) As Boolean
'
'    Name: fTM_AddUser
'   Zweck: Fügt einen neuen Benutzer hinzu
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - UserName
'          - PID
'          - Passwort
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_AddUser

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim usr As DAO.User
    
    fTM_AddUser = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set usr = wrk.CreateUser(UserName, PID, Passwort)
    wrk.Users.append usr
    
    fTM_AddUser = True

'Ende
Exit_fTM_AddUser:
    On Error Resume Next
    Set usr = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_AddUser:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_AddUser
    End Select
        
End Function

Public Function fTM_AddGroup(GroupName As String, PID As String) As Boolean
'
'    Name: fTM_AddGroup
'   Zweck: Fügt einen neue Gruppe hinzu
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Gruppenname
'          - PID
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_AddGroup

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim grp As DAO.Group
    
    fTM_AddGroup = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set grp = wrk.CreateGroup(GroupName, PID)
    wrk.Groups.append grp
    
    fTM_AddGroup = True

'Ende
Exit_fTM_AddGroup:
    On Error Resume Next
    Set grp = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_AddGroup:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_AddGroup
    End Select
        
End Function

Public Function fTM_DeleteUser(UserName As String) As Boolean
'
'    Name: fTM_DeleteUser
'   Zweck: Löscht einen vorhandenen Benutzer
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - UserName
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_DeleteUser

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    
    fTM_DeleteUser = False
    
    Set wrk = DBEngine.Workspaces(0)
    wrk.Users.Delete (UserName)
    wrk.Users.Refresh
    
    fTM_DeleteUser = True

'Ende
Exit_fTM_DeleteUser:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_DeleteUser:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_DeleteUser
    End Select
        
End Function

Public Function fTM_DeleteGroup(GroupName As String) As Boolean
'
'    Name: fTM_DeleteGroup
'   Zweck: Löscht eine vorhandene Gruppe
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Benutzername
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_DeleteGroup

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    
    fTM_DeleteGroup = False
    
    Set wrk = DBEngine.Workspaces(0)
    wrk.Groups.Delete GroupName
    wrk.Groups.Refresh
    
    fTM_DeleteGroup = True

'Ende
Exit_fTM_DeleteGroup:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_DeleteGroup:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_DeleteGroup
    End Select
        
End Function

Public Function fTM_AddUserToGroup(UserName As String, GroupName As String) As Boolean
'
'    Name: fTM_AddUserToGroup
'   Zweck: Fügt einen Benutzer zu einer Gruppe hinzu
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Benutzername
'          - Gruppenname
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_AddUserToGroup

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim grp As DAO.Group
    Dim usr As DAO.User
    
    fTM_AddUserToGroup = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set usr = wrk.Users(UserName)
    Set grp = usr.CreateGroup(GroupName)
    usr.Groups.append grp
    usr.Groups.Refresh
    
    fTM_AddUserToGroup = True

'Ende
Exit_fTM_AddUserToGroup:
    On Error Resume Next
    Set usr = Nothing
    Set grp = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_AddUserToGroup:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_AddUserToGroup
    End Select
        
End Function

Public Function fTM_AddGroupToUser(UserName As String, GroupName As String) As Boolean
'
'    Name: fTM_AddGroupToUser
'   Zweck: Fügt eine Gruppe zu einem Benutzer hinzu
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Benutzername
'          - Gruppenname
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_AddGroupToUser

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim grp As DAO.Group
    Dim usr As DAO.User
    
    fTM_AddGroupToUser = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set grp = wrk.Groups(GroupName)
    Set usr = grp.CreateUser(UserName)
    grp.Users.append usr
    grp.Users.Refresh
    
    fTM_AddGroupToUser = True

'Ende
Exit_fTM_AddGroupToUser:
    On Error Resume Next
    Set usr = Nothing
    Set grp = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_AddGroupToUser:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_AddGroupToUser
    End Select
        
End Function

Public Function fTM_DelteUserFromGroup(UserName As String, GroupName As String) As Boolean
'
'    Name: fTM_DelteUserFromGroup
'   Zweck: Löscht einen Benutzer aus einer Gruppe
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Benutzername
'          - Gruppenname
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_DelteUserFromGroup

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim grp As DAO.Group
    
    fTM_DelteUserFromGroup = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set grp = wrk.Groups(GroupName)
    grp.Users.Delete UserName
    grp.Users.Refresh
    
    fTM_DelteUserFromGroup = True

'Ende
Exit_fTM_DelteUserFromGroup:
    On Error Resume Next
    Set grp = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_DelteUserFromGroup:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_DelteUserFromGroup
    End Select
        
End Function

Public Function fTM_DelteGroupFromUser(UserName As String, GroupName As String) As Boolean
'
'    Name: fTM_DelteGroupFromUser
'   Zweck: Löscht eine Gruppe von einem User
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Benutzername
'          - Gruppenname
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_DelteGroupFromUser

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim usr As DAO.User
    
    fTM_DelteGroupFromUser = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set usr = wrk.Users(UserName)
    usr.Groups.Delete GroupName
    usr.Groups.Refresh
    
    fTM_DelteGroupFromUser = True

'Ende
Exit_fTM_DelteGroupFromUser:
    On Error Resume Next
    Set usr = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_DelteGroupFromUser:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_DelteGroupFromUser
    End Select
        
End Function

Public Function fTM_GroupExist(GroupName As String) As Boolean
'
'    Name: fTM_GroupExist
'   Zweck: Prüft, ob eine Gruppe existiert
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Gruppenname
'
'  Output: - True, wenn Gruppe existiert
'          - False, wenn Gruppe nicht existiert
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_GroupExist

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim grp As DAO.Group
    
    fTM_GroupExist = False
    
    Set wrk = DBEngine.Workspaces(0)
    wrk.Groups.Refresh
    
    For Each grp In wrk.Groups
        If grp.Name = GroupName Then
            fTM_GroupExist = True
            Exit For
        End If
    Next grp

'Ende
Exit_fTM_GroupExist:
    On Error Resume Next
    Set grp = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_GroupExist:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_GroupExist
    End Select
        
End Function

Public Function fTM_UserExist(UserName As String) As Boolean
'
'    Name: fTM_UserExist
'   Zweck: Prüft, ob ein User existiert
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Username
'
'  Output: - True, wenn User existiert
'          - False, wenn User nicht existiert
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_UserExist

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim usr As DAO.User
    
    fTM_UserExist = False
    
    Set wrk = DBEngine.Workspaces(0)
    wrk.Users.Refresh
    
    For Each usr In wrk.Users
        If usr.Name = UserName Then
            fTM_UserExist = True
            Exit For
        End If
    Next usr

'Ende
Exit_fTM_UserExist:
    On Error Resume Next
    Set usr = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_UserExist:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_UserExist
    End Select
        
End Function

Public Function fTM_UserInGroupExist(UserName As String, GroupName As String) As Boolean
'
'    Name: fTM_UserInGroupExist
'   Zweck: Prüft, ob ein User zu einer Gruppe gehört
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Username
'          - Gruppenname
'
'  Output: - True, wenn User zu Gruppe gehört
'          - False, wenn User nicht zu Gruppe gehört
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_UserInGroupExist

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim usr As DAO.User
    Dim i As Integer
    
    fTM_UserInGroupExist = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set usr = wrk.Users(UserName)
    
    For i = 0 To usr.Groups.Count - 1
        If usr.Groups(i).Name = GroupName Then
            fTM_UserInGroupExist = True
            Exit For
        End If
    Next i

'Ende
Exit_fTM_UserInGroupExist:
    On Error Resume Next
    Set usr = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_UserInGroupExist:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_UserInGroupExist
    End Select
        
End Function

Public Function fTM_ChangeUserPwd(UserName As String, AltesKennwort As String, NeuesKennwort As String) As Boolean
'
'    Name: fTM_ChangeUserPwd
'   Zweck: Das Kennwort eines Users ändern
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Username
'          - Bisheriges Kennwort
'          - Neues Kennwort
'
'  Output: - True, wenn Aktion erfolgreich
'          - False, wenn Aktion fehlgeschlagen
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_fTM_ChangeUserPwd

    'Variablen deklarieren
    Dim wrk As DAO.Workspace
    Dim usr As DAO.User
    
    fTM_ChangeUserPwd = False
    
    Set wrk = DBEngine.Workspaces(0)
    Set usr = wrk.Users(UserName)
    usr.NewPassword AltesKennwort, NeuesKennwort
    
    fTM_ChangeUserPwd = True

'Ende
Exit_fTM_ChangeUserPwd:
    On Error Resume Next
    Set usr = Nothing
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_fTM_ChangeUserPwd:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_fTM_ChangeUserPwd
    End Select
        
End Function

Function TM_ListAllGroups(Feld As control, ID As Variant, zeile As Variant, spalte As Variant, code As Variant) As Variant
'
'    Name: TM_ListAllGroups
'   Zweck: Callback-Funktion als Datenquelle für Listen- oder Kombinationsfelder
'          Liefert alle Gruppen
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Wert für Callback-Funktion
'
'  Output: - Wert für Callback-Funktion
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_TM_ListAllGroups

    'Variablen deklarieren
    Static i As Integer
    Dim Rueckgabewert As Variant
    Dim wrk As DAO.Workspace
    
    Set wrk = DBEngine.Workspaces(0)
    
    Select Case code
        Case acLBInitialize
            i = wrk.Groups.Count
            Rueckgabewert = i
        Case acLBOpen
            Rueckgabewert = Timer
        Case acLBGetRowCount
            Rueckgabewert = i
        Case acLBGetColumnCount
            Rueckgabewert = 1
        Case acLBGetColumnWidth
            Rueckgabewert = -1
        Case acLBGetValue
            Rueckgabewert = wrk.Groups(zeile).Name
        Case acLBGetFormat
        Case acLBEnd
    End Select
    TM_ListAllGroups = Rueckgabewert

'Ende
Exit_TM_ListAllGroups:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_TM_ListAllGroups:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_TM_ListAllGroups
    End Select
        
End Function

Function ListAllUsers(Feld As control, ID As Variant, zeile As Variant, spalte As Variant, code As Variant) As Variant
'
'    Name: ListAllUsers
'   Zweck: Callback-Funktion als Datenquelle für Listen- oder Kombinationsfelder
'          Liefert alle Benutzer
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 19.07.2003
' Version: 1.0
'
'   Input: - Wert für Callback-Funktion
'
'  Output: - Wert für Callback-Funktion
'
'Benötigt: Verweis auf DAO 3.6
'
'Komment.: -
'
'Fehlerbehandlung definieren
On Error GoTo Err_ListAllUsers

    'Variablen deklarieren
    Static i As Integer
    Dim Rueckgabewert As Variant
    Dim wrk As DAO.Workspace
    
    Set wrk = DBEngine.Workspaces(0)
    
    Select Case code
        Case acLBInitialize
            i = wrk.Users.Count
            Rueckgabewert = i
        Case acLBOpen
            Rueckgabewert = Timer
        Case acLBGetRowCount
            Rueckgabewert = i
        Case acLBGetColumnCount
            Rueckgabewert = 1
        Case acLBGetColumnWidth
            Rueckgabewert = -1
        Case acLBGetValue
            Rueckgabewert = wrk.Users(zeile).Name
        Case acLBGetFormat
        Case acLBEnd
    End Select
    ListAllUsers = Rueckgabewert

'Ende
Exit_ListAllUsers:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_ListAllUsers:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_ListAllUsers
    End Select
        
End Function

Function ListUsersOfaGroup(Feld As control, ID As Variant, zeile As Variant, spalte As Variant, code As Variant) As Variant
'
'    Name: ListUsersOfaGroup
'   Zweck: Callback-Funktion als Datenquelle für Listen- oder Kombinationsfelder
'          Liefert alle Benutzer einer Gruppe
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 26.02.2004
' Version: 1.1
'
'   Input: - Wert für Callback-Funktion
'
'  Output: - Wert für Callback-Funktion
'
'Benötigt: Verweis auf DAO 3.6
'          Formular mit Kombinationsfeld "cboGruppen"
'
'Komment.: Diese Funktion in den Quellcode eines Formulars
'          kopieren das ein Feld mit der Gruppe enthält
'
'Fehlerbehandlung definieren
On Error GoTo Err_ListUsersOfaGroup

    'Variablen deklarieren
    Static i As Integer
    Dim Rueckgabewert As Variant
    Dim wrk As DAO.Workspace
    Dim gruppen As String
    'gruppen = Me!cboGruppen
    Set wrk = DBEngine.Workspaces(0)
    
    Select Case code
        Case acLBInitialize
            wrk.Groups(gruppen).Users.Refresh
            i = wrk.Groups(gruppen).Users.Count
            Rueckgabewert = i
        Case acLBOpen
            Rueckgabewert = Timer
        Case acLBGetRowCount
            Rueckgabewert = i
        Case acLBGetColumnCount
            Rueckgabewert = 1
        Case acLBGetColumnWidth
            Rueckgabewert = -1
        Case acLBGetValue
            Rueckgabewert = wrk.Groups(gruppen).Users(zeile).Name
        Case acLBGetFormat
        Case acLBEnd
    End Select
    ListUsersOfaGroup = Rueckgabewert

'Ende
Exit_ListUsersOfaGroup:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_ListUsersOfaGroup:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_ListUsersOfaGroup
    End Select
        
End Function

Function ListGroupsOfaUser(Feld As control, ID As Variant, zeile As Variant, spalte As Variant, code As Variant) As Variant
'
'    Name: ListGroupsOfaUser
'   Zweck: Callback-Funktion als Datenquelle für Listen- oder Kombinationsfelder
'          Liefert alle Gruppen eines Users
'
'   Autor: Thomas Möller
'          Access@Team-Moeller.de
'
'Erstellt: 19.07.2003
'  Update: 26.02.2004
' Version: 1.1
'
'   Input: - Wert für Callback-Funktion
'
'  Output: - Wert für Callback-Funktion
'
'Benötigt: Verweis auf DAO 3.6
'          Formular mit Kombinationsfeld "cboGruppen"
'
'Komment.: Diese Funktion in den Quellcode eines Formulars
'          kopieren das ein Feld mit dem Benutzer enthält
'
'Fehlerbehandlung definieren
On Error GoTo Err_ListGroupsOfaUser

    'Variablen deklarieren
    Static i As Integer
    Dim Rueckgabewert As Variant
    Dim wrk As DAO.Workspace
    Dim benutzer As String
    'benutzer = Me!cboBenutzer
    Set wrk = DBEngine.Workspaces(0)
    
    Select Case code
        Case acLBInitialize
            i = wrk.Users(benutzer).Groups.Count
            Rueckgabewert = i
        Case acLBOpen
            Rueckgabewert = Timer
        Case acLBGetRowCount
            Rueckgabewert = i
        Case acLBGetColumnCount
            Rueckgabewert = 1
        Case acLBGetColumnWidth
            Rueckgabewert = -1
        Case acLBGetValue
            Rueckgabewert = wrk.Users(benutzer).Groups(zeile).Name
        Case acLBGetFormat
        Case acLBEnd
    End Select
    ListGroupsOfaUser = Rueckgabewert

'Ende
Exit_ListGroupsOfaUser:
    On Error Resume Next
    wrk.Close
    Set wrk = Nothing
    Exit Function

'Fehlerbehandlung
Err_ListGroupsOfaUser:
    Select Case Err.Number
        Case 0    'Wenn's kein Fehler war
            Resume Next
        Case Else 'Fehlermeldung anzeigen
            MsgBox Err.description, vbCritical, Err.Number
            Resume Exit_ListGroupsOfaUser
    End Select
        
End Function


