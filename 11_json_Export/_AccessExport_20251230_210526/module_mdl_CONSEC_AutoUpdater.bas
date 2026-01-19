' CONSEC AUTO-UPDATER
' ================================================
' Automatisches Update von VBA-Code ohne Import/Export
' Selbst-modifizierender Code für schnelle Entwicklung
' ================================================

Option Compare Database
Option Explicit

' ===== Sleep für Watcher (32/64-Bit) =====
#If VBA7 Then
    Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)
#Else
    Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
#End If

Private mWatching As Boolean   ' Steuerung für File-Watcher

' ========================================
' AUTO-UPDATE HAUPTFUNKTION
' ========================================

Public Sub AutoUpdate()
    Debug.Print "=== CONSEC AUTO-UPDATE ==="
    Debug.Print "Start: " & Now()

    Dim updatePath As String
    updatePath = CurrentProject.path & "\CONSEC_UPDATE.txt"

    If Dir(updatePath) <> "" Then
        Debug.Print "Update-Datei gefunden!"
        ApplyCodeUpdate updatePath
    Else
        Debug.Print "Keine Update-Datei gefunden."
        Debug.Print "Erstelle Beispiel-Update-Datei..."
        CreateSampleUpdateFile
    End If
End Sub

' ========================================
' SELBST-MODIFIZIERENDER CODE-UPDATER
' ========================================

Public Sub UpdateModuleCode(moduleName As String, newCode As String)
    ' ACHTUNG: Diese Funktion modifiziert VBA-Code zur Laufzeit!
    Dim vbProj As Object
    Dim vbComp As Object
    Dim codeModule As Object

    Set vbProj = Application.vbe.ActiveVBProject

    For Each vbComp In vbProj.VBComponents
        If vbComp.Name = moduleName Then
            Set codeModule = vbComp.codeModule

            If codeModule.CountOfLines > 0 Then
                codeModule.DeleteLines 1, codeModule.CountOfLines
            End If

            codeModule.AddFromString newCode
            Debug.Print "? Modul " & moduleName & " aktualisiert!"
            Exit Sub
        End If
    Next

    Set vbComp = vbProj.VBComponents.Add(1) ' 1 = vbext_ct_StdModule
    vbComp.Name = moduleName
    vbComp.codeModule.AddFromString newCode
    Debug.Print "? Neues Modul " & moduleName & " erstellt!"
End Sub

' ========================================
' DYNAMISCHER FUNKTIONS-UPDATER
' ========================================

Public Sub UpdateSingleFunction(moduleName As String, functionName As String, newFunctionCode As String)
    Dim vbProj As Object
    Dim vbComp As Object
    Dim codeModule As Object
    Dim startLine As Long
    Dim endLine As Long

    Set vbProj = Application.vbe.ActiveVBProject

    For Each vbComp In vbProj.VBComponents
        If vbComp.Name = moduleName Then
            Set codeModule = vbComp.codeModule

            startLine = FindFunctionStart(codeModule, functionName)
            If startLine > 0 Then
                endLine = FindFunctionEnd(codeModule, startLine)
                codeModule.DeleteLines startLine, endLine - startLine + 1
                codeModule.InsertLines startLine, newFunctionCode
                Debug.Print "? Funktion " & functionName & " aktualisiert!"
            Else
                codeModule.InsertLines codeModule.CountOfLines + 1, vbCrLf & newFunctionCode
                Debug.Print "? Funktion " & functionName & " hinzugefügt!"
            End If
            Exit Sub
        End If
    Next

    Debug.Print "? Modul " & moduleName & " nicht gefunden!"
End Sub

' ========================================
' HOT-RELOAD SYSTEM
' ========================================
Public Sub HotReload()
    On Error GoTo EH
    Debug.Print "? HOT-RELOAD..."

    ' Kompiliere alle Module
    DoCmd.RunCommand acCmdCompileAndSaveAllModules

    ' --- References prüfen/aufräumen ---
    Dim ref As Access.Reference
    Dim removed As Long
    On Error Resume Next
    For Each ref In Access.Application.References
        If ref.IsBroken Then
            Debug.Print "• Entferne defekten Verweis: " & SafeRefName(ref)
            Access.Application.References.Remove ref
            removed = removed + 1
        End If
    Next ref
    On Error GoTo 0
    If removed = 0 Then
        Debug.Print "• Keine defekten Verweise gefunden."
    Else
        Debug.Print "• " & removed & " defekte(r) Verweis(e) entfernt."
    End If
    ' (Kein References.Refresh in Access vorhanden)

    Debug.Print "? Hot-Reload abgeschlossen!"
    Exit Sub
EH:
    Debug.Print "? Hot-Reload-Fehler: " & Err.Number & " - " & Err.description
    Err.clear
End Sub

' ========================================
' CODE-GENERATOR FÜR FIXES
' ========================================

Public Function GenerateFixCode(errorDescription As String) As String
    Dim fixCode As String

    Select Case True
        Case InStr(errorDescription, "Syntaxfehler") > 0
            fixCode = GenerateSyntaxFix()

        Case InStr(errorDescription, "Variable nicht definiert") > 0
            fixCode = GenerateVariableFix(errorDescription)

        Case InStr(errorDescription, "Objekt erforderlich") > 0
            fixCode = GenerateObjectFix()

        Case Else
            fixCode = "' Fix für: " & errorDescription & vbCrLf & _
                      "' TODO: Manueller Fix erforderlich"
    End Select

    GenerateFixCode = fixCode
End Function

Private Function GenerateSyntaxFix() As String
    GenerateSyntaxFix = "' Syntax-Fix" & vbCrLf & _
                        "' Prüfe Zeilenfortsetzungen (_)" & vbCrLf & _
                        "' Prüfe Anführungszeichen" & vbCrLf & _
                        "' Prüfe Klammern"
End Function

Private Function GenerateVariableFix(errorDesc As String) As String
    Dim varName As String
    varName = "unbekannt" ' Hier könnte Parsing erfolgen
    GenerateVariableFix = "Dim " & varName & " As Variant"
End Function

Private Function GenerateObjectFix() As String
    GenerateObjectFix = "Set obj = CreateObject(""ClassName"")"
End Function

' ========================================
' FILE-WATCHER FÜR AUTO-UPDATE (Access-kompatibel)
' ========================================

Public Sub StartFileWatcher()
    If mWatching Then
        Debug.Print "File-Watcher läuft bereits."
        Exit Sub
    End If

    mWatching = True
    Debug.Print "??? File-Watcher gestartet..."
    WatcherLoop
End Sub

Public Sub StopFileWatcher()
    mWatching = False
    Debug.Print "File-Watcher gestoppt."
End Sub

Private Sub WatcherLoop()
    Do While mWatching
        CheckForUpdates
        DoEvents
        Sleep 10000          ' 10 Sekunden
        DoEvents
    Loop
End Sub

Public Sub CheckForUpdates()
    Static lastModified As Date
    Dim updatePath As String
    Dim currentModified As Date

    updatePath = CurrentProject.path & "\CONSEC_UPDATE.txt"

    If Dir(updatePath) <> "" Then
        currentModified = FileDateTime(updatePath)
        If currentModified > lastModified Then
            Debug.Print "?? Update erkannt!"
            ApplyCodeUpdate updatePath
            lastModified = currentModified
        End If
    End If
End Sub

' ========================================
' UPDATE VON DATEI ANWENDEN
' ========================================

Private Sub ApplyCodeUpdate(filePath As String)
    Dim fileNum As Integer
    Dim fileContent As String
    Dim lineText As String

    fileNum = FreeFile
    Open filePath For Input As #fileNum
    fileContent = ""
    Do While Not EOF(fileNum)
        Line Input #fileNum, lineText
        fileContent = fileContent & lineText & vbCrLf
    Loop
    Close #fileNum

    If InStr(fileContent, "[MODULE]") > 0 Then
        Dim moduleName As String
        Dim moduleCode As String
        moduleName = ExtractModuleName(fileContent)
        moduleCode = ExtractModuleCode(fileContent)
        UpdateModuleCode moduleName, moduleCode

    ElseIf InStr(fileContent, "[FUNCTION]") > 0 Then
        Dim funcModule As String
        Dim funcName As String
        Dim funcCode As String
        funcModule = ExtractValue(fileContent, "MODULE:")
        funcName = ExtractValue(fileContent, "FUNCTION:")
        funcCode = ExtractFunctionCode(fileContent)
        UpdateSingleFunction funcModule, funcName, funcCode
    End If

    HotReload
End Sub

' ========================================
' HILFSFUNKTIONEN
' ========================================

Private Function FindFunctionStart(codeModule As Object, functionName As String) As Long
    Dim i As Long, lineText As String
    For i = 1 To codeModule.CountOfLines
        lineText = codeModule.lines(i, 1)
        If InStr(1, lineText, "Function " & functionName, vbTextCompare) > 0 Or _
           InStr(1, lineText, "Sub " & functionName, vbTextCompare) > 0 Then
            FindFunctionStart = i
            Exit Function
        End If
    Next i
    FindFunctionStart = 0
End Function

Private Function FindFunctionEnd(codeModule As Object, startLine As Long) As Long
    Dim i As Long, lineText As String
    For i = startLine + 1 To codeModule.CountOfLines
        lineText = codeModule.lines(i, 1)
        If InStr(1, lineText, "End Function", vbTextCompare) > 0 Or _
           InStr(1, lineText, "End Sub", vbTextCompare) > 0 Then
            FindFunctionEnd = i
            Exit Function
        End If
    Next i
    FindFunctionEnd = codeModule.CountOfLines
End Function

Private Function ExtractModuleName(content As String) As String
    Dim startPos As Long, endPos As Long
    startPos = InStr(content, "[MODULE]") + 8
    endPos = InStr(startPos, content, vbCrLf)
    If startPos > 8 And endPos > startPos Then
        ExtractModuleName = Trim(Mid$(content, startPos, endPos - startPos))
    Else
        ExtractModuleName = "mdl_Updated"
    End If
End Function

Private Function ExtractModuleCode(content As String) As String
    Dim startPos As Long
    startPos = InStr(content, "[CODE]") + 6
    If startPos > 6 Then
        ExtractModuleCode = Mid$(content, startPos)
    Else
        ExtractModuleCode = content
    End If
End Function

Private Function ExtractValue(content As String, key As String) As String
    Dim startPos As Long, endPos As Long
    startPos = InStr(content, key) + Len(key)
    endPos = InStr(startPos, content, vbCrLf)
    If startPos > Len(key) And endPos > startPos Then
        ExtractValue = Trim(Mid$(content, startPos, endPos - startPos))
    Else
        ExtractValue = ""
    End If
End Function

Private Function ExtractFunctionCode(content As String) As String
    Dim startPos As Long
    startPos = InStr(content, "[CODE]") + 6
    If startPos > 6 Then
        ExtractFunctionCode = Mid$(content, startPos)
    Else
        ExtractFunctionCode = ""
    End If
End Function

Private Function SafeRefName(ByVal ref As Access.Reference) As String
    On Error Resume Next
    SafeRefName = ref.Name
    If Err.Number <> 0 Or Len(SafeRefName) = 0 Then
        SafeRefName = "(unbekannt)"
        Err.clear
    End If
    On Error GoTo 0
End Function

' ========================================
' TEST-UPDATE ERSTELLEN
' ========================================

Private Sub CreateSampleUpdateFile()
    Dim filePath As String
    Dim fileNum As Integer
    Dim sampleContent As String

    filePath = CurrentProject.path & "\CONSEC_UPDATE.txt"

    sampleContent = "[FUNCTION]" & vbCrLf & _
                    "MODULE:mdl_CONSEC_AI_DEBUG" & vbCrLf & _
                    "FUNCTION:TestUpdate" & vbCrLf & _
                    "[CODE]" & vbCrLf & _
                    "Public Function TestUpdate() As String" & vbCrLf & _
                    "    TestUpdate = ""Update wurde angewendet: "" & Now()" & vbCrLf & _
                    "    Debug.Print TestUpdate" & vbCrLf & _
                    "End Function"

    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, sampleContent
    Close #fileNum

    Debug.Print "? Beispiel-Update-Datei erstellt: " & filePath
    MsgBox "Update-Datei erstellt!" & vbCrLf & vbCrLf & _
           "Bearbeiten Sie: " & filePath & vbCrLf & _
           "Dann rufen Sie AutoUpdate auf", vbInformation
End Sub

' ========================================
' QUICK-FIX FUNKTIONEN
' ========================================

Public Sub QuickFix(moduleName As String, lineNumber As Long)
    Dim vbProj As Object
    Dim vbComp As Object
    Dim codeModule As Object
    Dim errorLine As String

    Set vbProj = Application.vbe.ActiveVBProject

    For Each vbComp In vbProj.VBComponents
        If vbComp.Name = moduleName Then
            Set codeModule = vbComp.codeModule
            errorLine = codeModule.lines(lineNumber, 1)

            Debug.Print "Fehlerhafte Zeile: " & errorLine

            If InStr(errorLine, " & _") > 0 And Len(Trim$(codeModule.lines(lineNumber + 1, 1))) = 0 Then
                codeModule.ReplaceLine lineNumber, Replace$(errorLine, " & _", "")
                Debug.Print "? Fixed: Überflüssigen Fortsetzungs-Operator entfernt"
            ElseIf InStr(errorLine, """") = 0 And InStr(errorLine, "=") > 0 Then
                Debug.Print "?? Mögliches Problem mit Anführungszeichen"
            End If
            Exit Sub
        End If
    Next
End Sub

' ========================================
' ENTWICKLER-KONSOLE
' ========================================

Public Sub DevConsole()
    Dim cmd As String
    Do
        cmd = InputBox("Dev-Konsole (help für Hilfe, exit zum Beenden):", "CONSEC Dev Console", "help")
        Select Case LCase$(cmd)
            Case "help"
                MsgBox "Befehle:" & vbCrLf & _
                       "update - Code-Update anwenden" & vbCrLf & _
                       "reload - Hot-Reload" & vbCrLf & _
                       "watch - File-Watcher starten" & vbCrLf & _
                       "stop - File-Watcher stoppen" & vbCrLf & _
                       "test - Test ausführen" & vbCrLf & _
                       "exit - Beenden", vbInformation

            Case "update": AutoUpdate
            Case "reload": HotReload
            Case "watch":  StartFileWatcher
            Case "stop":   StopFileWatcher
            Case "test":   Debug.Print "Test: " & Now()
            Case "exit", "": Exit Do
            Case Else: Debug.Print "Unbekannter Befehl: " & cmd
        End Select
    Loop
    Debug.Print "Dev-Konsole beendet"
End Sub

' ========================================
' INSTALLATION
' ========================================

Public Sub InstallAutoUpdater()
    MsgBox "CONSEC Auto-Updater installiert!" & vbCrLf & vbCrLf & _
           "Verwendung:" & vbCrLf & _
           "1. AutoUpdate - Update von Datei" & vbCrLf & _
           "2. StartFileWatcher/StopFileWatcher - Auto-Überwachung" & vbCrLf & _
           "3. DevConsole - Entwickler-Konsole" & vbCrLf & vbCrLf & _
           "WICHTIG: In den Einstellungen 'Zugriff auf das VBA-Projekt vertrauen' aktivieren!", vbInformation
    CreateSampleUpdateFile
End Sub