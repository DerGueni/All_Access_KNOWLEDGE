Option Compare Database
Option Explicit

'**********************************************************************************************************************************************
'*  Module created by Jean Pierre Allain
'*  Copyright (c) by ABISS GmbH, www.abiss.de
'*  Code is allowed to be copied and distributed as long as there exist a legal key for the ATM
'**********************************************************************************************************************************************

Public Function actLanguage() As Long
    actLanguage = 1
    On Error Resume Next
    actLanguage = Forms![frmOptions]![Language]
    err.clear
End Function

Public Function MsgTxt(TextunitID As Long, Language As Long, Sound As Byte, ParamArray varText()) As String
    Dim rs As Object, i As Integer, tmp As String
    On Error GoTo ErrHandling
    If Language = 0 Then Language = actLanguage()
    Set rs = CodeDb.OpenRecordset("SELECT sysTextunit.ID, sysText.Wording FROM sysText INNER JOIN sysTextunit ON sysText.ID = sysTextunit.TextID WHERE sysTextunit.LanguageID = " & Language & " And sysTextunit.ID = " & TextunitID, 4) 'dbOpenSnapshot)
    If rs.EOF Then
        Beep
        MsgBox "TextunitID " & TextunitID & " was not found!", vbCritical, "Message error"
        MsgTxt = "!no text!"
    Else
        tmp = rs("Wording") & ""
        For i = 0 To UBound(varText)
            varText(i) = Replace(varText(i), "|", Chr(254), , 1)
            tmp = Replace(tmp, "|", varText(i), , 1)
        Next
        tmp = Replace(tmp, "|", "")
        tmp = Replace(tmp, Chr(254), "|")
        MsgTxt = tmp
    End If
    For i = 1 To Sound
        Beep
    Next

Leave:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Exit Function
    
ErrHandling:
    ShowError err.description, err.Number
    Resume Leave
End Function

Public Sub objLabeling(Optional obj As Object, Optional Language As Byte)
    If Language = 0 Then Language = actLanguage()
    If obj Is Nothing Then
        For Each obj In Forms
            If Not obj.CurrentView = 0 Then Labeling obj, Language, True
        Next
        For Each obj In Reports
            If Not obj.CurrentView = 0 Then Labeling obj, Language, True
        Next
    Else
        Labeling obj, Language
    End If
End Sub

Private Sub Labeling(obj As Object, Language As Byte, Optional subForm As Boolean)
    Dim rs As Object, tmp As String, tmpOBJ As Object
    If subForm Then
        On Error Resume Next
        obj.INI
        For Each tmpOBJ In obj.Controls
            If TypeName(tmpOBJ) = "SubForm" Then Labeling tmpOBJ.Form, Language, True
        Next
    End If
    On Error GoTo ErrHandling
    Set rs = CodeDb.OpenRecordset("SELECT sysTextunitObject.*, sysText.Wording, sysTextunit.LanguageID FROM sysText RIGHT JOIN (sysTextunit RIGHT JOIN sysTextunitObject ON sysTextunit.ID = sysTextunitObject.TextunitID) ON sysText.ID = sysTextunit.TextID WHERE Not ObjecttypeID=6 AND (sysTextunit.LanguageID=" & Language & " OR sysTextunit.LanguageID Is Null) AND Formularname = """ & obj.Name & """", 8) 'dbOpenForwardOnly)
    Do Until rs.EOF
        If rs("ObjecttypeID") < 100 Then
            Set tmpOBJ = obj
        Else
            Set tmpOBJ = obj.Controls(rs("Objectname"))
        End If
        tmp = rs("Prefix") & rs("Wording") & rs("Suffix") & ""
        If IsNull(rs("textunitID")) Then
            If tmp = "" And Not tmpOBJ.Properties(rs("prpName")) = "" Then tmp = "***" & tmpOBJ.Properties(rs("prpName"))
        Else
            If IsNull(rs("Wording")) And Not tmpOBJ.Properties(rs("prpName")) = "" Then
                tmp = "***" & tmpOBJ.Properties(rs("prpName"))
            End If
        End If
        tmpOBJ.Properties(rs("prpName")) = tmp
NextItem:
        rs.MoveNext
    Loop

Leave:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Exit Sub
    
ErrHandling:
    If err.Number = 2455 Or err.Number = 2465 Or err.Number = 2485 Or err.Number = 7794 Or err.Number = 438 Then Resume NextItem
    ShowError err.description, err.Number
    Resume Leave
End Sub

Public Function GetOfficeLanguageID() As Long
    Dim rs As Object
    On Error GoTo ErrHandling
    GetOfficeLanguageID = 1
    Set rs = CodeDb.OpenRecordset("SELECT sysOfficeLanguage.*, sysLanguage.IsBasic FROM sysLanguage INNER JOIN sysOfficeLanguage ON sysLanguage.ID = sysOfficeLanguage.LanguageID", 4) 'dbOpenSnapshot)
    rs.FindFirst "OfficeLanguageID=" & GetOfficeLanguage()
    If Not rs.NoMatch Then
        If Not rs("LanguageID") = 0 Then GetOfficeLanguageID = rs("LanguageID")
    Else
        rs.FindFirst "IsBasic=True"
        If Not rs.NoMatch Then GetOfficeLanguageID = rs("LanguageID")
    End If
    
Leave:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Exit Function
    
ErrHandling:
    ShowError err.description, err.Number
    Resume Leave
End Function

Public Function GetOfficeLanguage() As Long
    On Error Resume Next
    GetOfficeLanguage = LanguageSettings.LanguageID(2)
End Function
    
Private Sub ShowError(description As String, Number As Long)
    Beep
    MsgBox description, vbCritical, "Error " & Number
End Sub