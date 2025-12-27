Attribute VB_Name = "mdlCreateTextFromMDB_CL"
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

'Private Const Const_DaBaPath As String = "C:\dabadoc\"

Public gl_DaBaPath As String

Private Declare PtrSafe Function MakePath Lib "imagehlp.dll" Alias _
    "MakeSureDirectoryPathExists" (ByVal lpPath As String) As Long

Public Function DocDatabaseCrea_CL(Optional DaBaPath As String = "")
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

If Len(Trim(Nz(DaBaPath))) = 0 Then
    DaBaPath = Left(CurrentDb.Name, Len(CurrentDb.Name) - Len(Dir(CurrentDb.Name))) & "DaBaDoc\"
End If

If Right(DaBaPath, 1) <> "\" Then DaBaPath = DaBaPath & "\"

gl_DaBaPath = DaBaPath

Call Path_erzeugen(DaBaPath & "frm\", , True)
Call Path_erzeugen(DaBaPath & "rpt\", , True)
'Call Path_erzeugen(DaBaPath & "mac\", , True)
Call Path_erzeugen(DaBaPath & "mdl\", , True)
'Call Path_erzeugen(DaBaPath & "qry\", , True)

On Error Resume Next
Kill DaBaPath & "frm\*.*"
Kill DaBaPath & "rpt\*.*"
Kill DaBaPath & "mdl\*.*"
On Error GoTo 0

Set dbs = CurrentDb() ' use CurrentDb() to refresh Collections

Set cnt = dbs.Containers("Forms")
For Each doc In cnt.Documents
    Application.SaveAsText acForm, doc.Name, DaBaPath & "frm\" & doc.Name & ".txt"
Next doc

Set cnt = dbs.Containers("Reports")
For Each doc In cnt.Documents
    Application.SaveAsText acReport, doc.Name, DaBaPath & "rpt\" & doc.Name & ".txt"
Next doc

'Set cnt = Dbs.Containers("Scripts")
'For Each doc In cnt.Documents
'    Application.SaveAsText acMacro, doc.Name, DaBaPath & "mac\" & doc.Name & ".txt"
'Next doc

Set cnt = dbs.Containers("Modules")
For Each doc In cnt.Documents
    If Not doc.Name = CONST_mdlCreateTxtFromMDB Then
        Application.SaveAsText acModule, doc.Name, DaBaPath & "mdl\" & doc.Name & ".txt"
    Else
        Application.SaveAsText acModule, doc.Name, DaBaPath & "mdl\" & doc.Name & ".txx"
    End If
Next doc

'For I = 0 To Dbs.QueryDefs.Count - 1
'    Application.SaveAsText acQuery, Dbs.QueryDefs(I).Name, DaBaPath & "qry\" & Dbs.QueryDefs(I).Name & ".txt"
'Next I

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



Private Function Path_erzeugen(ByVal Pathnamen As String, Optional IsWarnBeforeCreate As Boolean = False, Optional IsWarnOnErr As Boolean = True) As Boolean
' Path mit mehreren Subs auf einmal erzeugen
' Idee aus VB-Tips & Tricks in der BasicWorld
' www.basicworld.com
' Der optionale Parameter NoIsWarnOnErr wird als "False" interpretiert, wenn nicht vorhanden.
' Wenn IsWarnOnErr = False, dann wird keine Fehlermeldungs-Messagebox ausgegeben
' Wenn IsWarnBeforeCreate = True, dann wird gefragt, ob das Directory erzeugt werden soll, wenn es nicht existiert.
' Wenn versucht wird, ein Directory anzulegen, das bereits existiert, so erfolgt keine Fehlermeldung

' Declare PtrSafe Function MakePath Lib "imagehlp.dll" Alias _
'    "MakeSureDirectoryPathExists" (ByVal lpPath As String) As Long

  
Dim nix
  
'Pfadnamen muß immer mit einem "\" enden
If Right(Pathnamen, 1) <> "\" Then
    Pathnamen = Pathnamen & "\"
End If

nix = Dir(Pathnamen, vbDirectory)

If IsWarnBeforeCreate And Len(Nz(nix)) = 0 Then ' Pfad existiert nicht und Warnungs-MsgBox on
    nix = MsgBox("Verzeichnis existiert nicht, soll es erstellt werden ?", vbQuestion + vbOKCancel, _
                  "Verzeichnis erstellen")
    If nix = vbCancel Then 'Abbruch der Funktion
        Path_erzeugen = False
        Exit Function
    End If
End If
        
'Pfad erstellen
If MakePath(Pathnamen) = 0 Then
    If IsWarnOnErr Then
        Path_erzeugen = False
        MsgBox "Verzeichnis konnte nicht erstellt werden.", vbCritical
    End If
Else
    Path_erzeugen = True
End If

    
End Function

'**********************************************************************************
'Function Dir_Exist ()
'
'   Überprüft, ob das Directory vorhanden ist
'   Rückgabe:  True, Directory vorhanden
'              False, Directory nicht vorhanden
'   Autor: Thomas Schremser
'**********************************************************************************
Private Function Dir_Exist(ByVal pPfad As String) As Boolean
   On Error Resume Next
   Dir_Exist = GetAttr(pPfad) And vbDirectory
End Function

