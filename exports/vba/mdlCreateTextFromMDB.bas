Attribute VB_Name = "mdlCreateTextFromMDB"
Option Compare Database
Option Explicit

' Author Arvin Meyer
' Enhancements: Klaus Oberdalhoff

'################## IMPORTANT - WICHTIG ##############
' On recreation of the mdb, the processs would stop if you would
' try to override the module which is currently used

' This (the own) modulename must be named like this

Private Const CONST_mdlCreateTxtFromMDB As String = "mdlCreateTxtFromMDB"
'#####################################################


Private Const Const_DaBaPath As String = "C:\dabadoc\"

Private Declare PtrSafe Function MakePath Lib "imagehlp.dll" Alias _
    "MakeSureDirectoryPathExists" (ByVal lpPath As String) As Long

Public Function DocDatabaseCrea()
 '====================================================================
 ' Name:    DocDatabase
 ' Purpose: Documents the database to a series of text files
 '
 ' Author:  Arvin Meyer
 ' Date:    June 02, 1999
 ' Comment: Uses the undocumented [Application.SaveAsText] syntax
 '          To reload use the syntax [Application.LoadFromText]
 '====================================================================
On Error GoTo Err_DocDatabase
Dim dbs As DAO.Database
Dim cnt As Container
Dim doc As Document
Dim i As Integer

Call Path_erzeugen(Const_DaBaPath & "frm\")
Call Path_erzeugen(Const_DaBaPath & "rep\")
Call Path_erzeugen(Const_DaBaPath & "mac\")
Call Path_erzeugen(Const_DaBaPath & "mod\")
Call Path_erzeugen(Const_DaBaPath & "qry\")

Set dbs = CurrentDb() ' use CurrentDb() to refresh Collections

Set cnt = dbs.Containers("Forms3")
For Each doc In cnt.Documents
    Application.SaveAsText acForm, doc.Name, Const_DaBaPath & "frm\" & doc.Name & ".txt"
Next doc

Set cnt = dbs.Containers("Reports")
For Each doc In cnt.Documents
    Application.SaveAsText acReport, doc.Name, Const_DaBaPath & "rep\" & doc.Name & ".txt"
Next doc

Set cnt = dbs.Containers("Scripts")
For Each doc In cnt.Documents
    Application.SaveAsText acMacro, doc.Name, Const_DaBaPath & "mac\" & doc.Name & ".txt"
Next doc

Set cnt = dbs.Containers("Modules")
For Each doc In cnt.Documents
    If Not doc.Name = CONST_mdlCreateTxtFromMDB Then
        Application.SaveAsText acModule, doc.Name, Const_DaBaPath & "mod\" & doc.Name & ".txt"
    Else
        Application.SaveAsText acModule, doc.Name, Const_DaBaPath & "mod\" & doc.Name & ".txx"
    End If
Next doc

For i = 0 To dbs.QueryDefs.Count - 1
    Application.SaveAsText acQuery, dbs.QueryDefs(i).Name, Const_DaBaPath & "qry\" & dbs.QueryDefs(i).Name & ".txt"
Next i

Set doc = Nothing
Set cnt = Nothing
Set dbs = Nothing

Exit_DocDatabase:
    Exit Function


Err_DocDatabase:
    Select Case Err

    Case Else
        MsgBox Err.description
        Resume Exit_DocDatabase
    End Select

End Function


Public Function DocDatabaseMrge()
 '====================================================================
 ' Name:    DocDatabase
 ' Purpose: Reimports the created documents to a database
 '
 ' Author:  Arvin Meyer
 ' Date:    June 02, 1999
 ' Comment: Uses the undocumented [Application.SaveAsText] syntax
 '          To reload use the syntax [Application.LoadFromText]
 '====================================================================
On Error GoTo Err_DocDatabase

Dim dbs As DAO.Database
Dim fileName As String
Dim Docname As String

Set dbs = CurrentDb() ' use CurrentDb() to refresh Collections

fileName = Dir(Const_DaBaPath & "frm\*.txt", vbDirectory)
While fileName <> ""
    Docname = Left(fileName, Len(fileName) - 4)
    Application.LoadFromText acForm, Docname, Const_DaBaPath & "frm\" & fileName
    fileName = Dir
    DoEvents
Wend

fileName = Dir(Const_DaBaPath & "rep\*.txt", vbDirectory)
While fileName <> ""
    Docname = Left(fileName, Len(fileName) - 4)
    Application.LoadFromText acReport, Docname, Const_DaBaPath & "rep\" & fileName
    fileName = Dir
    DoEvents
Wend

fileName = Dir(Const_DaBaPath & "mac\*.txt", vbDirectory)
While fileName <> ""
    Docname = Left(fileName, Len(fileName) - 4)
    Application.LoadFromText acMacro, Docname, Const_DaBaPath & "mac\" & fileName
    fileName = Dir
    DoEvents
Wend

fileName = Dir(Const_DaBaPath & "mod\*.txt", vbDirectory)
While fileName <> ""
    Docname = Left(fileName, Len(fileName) - 4)
    Application.LoadFromText acModule, Docname, Const_DaBaPath & "mod\" & fileName
    fileName = Dir
    DoEvents
Wend

fileName = Dir(Const_DaBaPath & "qry\*.txt", vbDirectory)
While fileName <> ""
    Docname = Left(fileName, Len(fileName) - 4)
    Application.LoadFromText acQuery, Docname, Const_DaBaPath & "qry\" & fileName
    fileName = Dir
    DoEvents
Wend

Exit_DocDatabase:
    Exit Function


Err_DocDatabase:
    Select Case Err

    Case Else
        MsgBox Err.description
        Resume Exit_DocDatabase
    End Select

End Function


Private Function Path_erzeugen(ByVal Pathnamen As String, Optional CreatWarn As Boolean = False, Optional WarnOnErr As Boolean = True) As Boolean
' Path mit mehreren Subs auf einmal erzeugen
' Idee aus VB-Tips & Tricks in der BasicWorld
' www.basicworld.com
' Der optionale Parameter NoWarnOnErr wird als "False" interpretiert, wenn nicht vorhanden.
' Wenn WarnOnErr = False, dann wird keine Fehlermeldungs-Messagebox ausgegeben
' Wenn CreatWarn = True, dann wird gefragt, ob das Directory erzeugt werden soll, wenn es nicht existiert.
' Wenn versucht wird, ein Directory anzulegen, das bereits existiert, so erfolgt keine Fehlermeldung

' Declare PtrSafe Function MakePath Lib "imagehlp.dll" Alias _
'    "MakeSureDirectoryPathExists" (ByVal lpPath As String) As Long

  
Dim nix
  
'Pfadnamen muﬂ immer mit einem "\" enden
If Right(Pathnamen, 1) <> "\" Then
    Pathnamen = Pathnamen & "\"
End If

nix = Dir(Pathnamen, vbDirectory)

If CreatWarn And Len(Nz(nix)) = 0 Then ' Pfad existiert nicht und Warnungs-MsgBox on
    nix = MsgBox("Verzeichnis existiert nicht, soll es erstellt werden ?", vbQuestion + vbOKCancel, _
                  "Verzeichnis erstellen")
    If nix = vbCancel Then 'Abbruch der Funktion
        Path_erzeugen = False
        Exit Function
    End If
End If
        
'Pfad erstellen
If MakePath(Pathnamen) = 0 Then
    If WarnOnErr Then
        Path_erzeugen = False
        MsgBox "Verzeichnis konnte nicht erstellt werden.", vbCritical
    End If
Else
    Path_erzeugen = True
End If

    
End Function
Public Sub Test_SimpleHTML()

    ' Testet mit der einfachen Test-Seite

    Debug.Print "=== SIMPLE TEST START ==="

    OpenHTML_Form "simple_test", 0

    Debug.Print "=== SIMPLE TEST ENDE ==="

End Sub
