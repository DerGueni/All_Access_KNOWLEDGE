Option Explicit

Dim accessApp, db, vbe, vbProject, vbModule, component
Dim vbaCode, fso, logFile, found

' Log-Funktion
Set fso = CreateObject("Scripting.FileSystemObject")
Set logFile = fso.CreateTextFile("C:\Users\guenther.siegert\Documents\Access Bridge\vbs_log.txt", True)

Sub WriteLog(msg)
    logFile.WriteLine Now & " - " & msg
    WScript.Echo msg
End Sub

On Error Resume Next

WriteLog "=== START ==="

' Access öffnen
WriteLog "Erstelle Access.Application..."
Set accessApp = CreateObject("Access.Application")
If Err.Number <> 0 Then
    WriteLog "FEHLER beim Erstellen von Access.Application: " & Err.Description
    WScript.Quit 1
End If
WriteLog "OK - Access.Application erstellt"

accessApp.Visible = False
WriteLog "Access auf unsichtbar gesetzt"

Dim dbPath
dbPath = "C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
WriteLog "Öffne DB: " & dbPath

accessApp.OpenCurrentDatabase dbPath
If Err.Number <> 0 Then
    WriteLog "FEHLER beim Öffnen der DB: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If
WriteLog "OK - DB geöffnet"

' VBA-Code
vbaCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Public Sub Configure_Ist_ConditionalFormatting()" & vbCrLf & _
"    Const FORM_NAME As String = ""frm_lst_row_auftrag""" & vbCrLf & _
"    Dim hasTxtOffene As Boolean" & vbCrLf & _
"    Dim ctl As Control" & vbCrLf & _
"    Dim istCtl As Control" & vbCrLf & vbCrLf & _
"    DoCmd.OpenForm FORM_NAME, View:=acDesign, WindowMode:=acHidden" & vbCrLf & vbCrLf & _
"    hasTxtOffene = False" & vbCrLf & _
"    For Each ctl In Forms(FORM_NAME).Controls" & vbCrLf & _
"        If ctl.Name = ""txtOffeneAnfragen"" Then" & vbCrLf & _
"            hasTxtOffene = True" & vbCrLf & _
"            Exit For" & vbCrLf & _
"        End If" & vbCrLf & _
"    Next ctl" & vbCrLf & vbCrLf & _
"    If Not hasTxtOffene Then" & vbCrLf & _
"        Dim txt As Control" & vbCrLf & _
"        Set txt = Application.CreateControl(FORM_NAME, acTextBox, acDetail)" & vbCrLf & _
"        With txt" & vbCrLf & _
"            .Name = ""txtOffeneAnfragen""" & vbCrLf & _
"            .Top = 0: .Left = 0: .Width = 100: .Height = 200" & vbCrLf & _
"        End With" & vbCrLf & _
"    End If" & vbCrLf & vbCrLf & _
"    With Forms(FORM_NAME).Controls(""txtOffeneAnfragen"")" & vbCrLf & _
"        .ControlSource = ""=Nz(DCount(""""*""""; """"qry_MA_Offene_Anfragen""""; """"VA_ID="""" & [ID]);0)""" & vbCrLf & _
"        .Visible = False" & vbCrLf & _
"        .Locked = True" & vbCrLf & _
"        .TabStop = False" & vbCrLf & _
"    End With" & vbCrLf & vbCrLf & _
"    DoCmd.Close acForm, FORM_NAME, acSaveYes" & vbCrLf & _
"    DoCmd.OpenForm FORM_NAME, View:=acNormal" & vbCrLf & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    Set istCtl = Forms(FORM_NAME).Controls(""Ist"")" & vbCrLf & _
"    On Error GoTo 0" & vbCrLf & vbCrLf & _
"    If istCtl Is Nothing Then" & vbCrLf & _
"        For Each ctl In Forms(FORM_NAME).Controls" & vbCrLf & _
"            If ctl.ControlType = acTextBox Then" & vbCrLf & _
"                If LCase$(Nz(ctl.ControlSource, """")) = ""ist"" Then" & vbCrLf & _
"                    Set istCtl = ctl" & vbCrLf & _
"                    Exit For" & vbCrLf & _
"                End If" & vbCrLf & _
"            End If" & vbCrLf & _
"        Next ctl" & vbCrLf & _
"    End If" & vbCrLf & vbCrLf & _
"    If istCtl Is Nothing Then" & vbCrLf & _
"        MsgBox ""Konnte Ist-Feld nicht finden."", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & vbCrLf & _
"    With istCtl.FormatConditions" & vbCrLf & _
"        .Delete" & vbCrLf & _
"        Dim fc As FormatCondition" & vbCrLf & _
"        Set fc = .Add(Type:=acExpression, Expression:=""[txtOffeneAnfragen] > 0"")" & vbCrLf & _
"        fc.ForeColor = vbBlue" & vbCrLf & _
"        Set fc = .Add(Type:=acExpression, Expression:=""[txtOffeneAnfragen] = 0 And Nz([Ist],0) <> Nz([Soll],0)"")" & vbCrLf & _
"        fc.ForeColor = vbRed" & vbCrLf & _
"    End With" & vbCrLf & vbCrLf & _
"    Forms(FORM_NAME).Recalc" & vbCrLf & _
"    DoCmd.RunCommand acCmdSaveRecord" & vbCrLf & _
"    DoCmd.Close acForm, FORM_NAME, acSaveYes" & vbCrLf & vbCrLf & _
"    MsgBox ""Formatierung erfolgreich gesetzt!"", vbInformation" & vbCrLf & _
"End Sub"

WriteLog "VBA-Code vorbereitet"

' VBE zugreifen
WriteLog "Zugriff auf VBE..."
Set vbe = accessApp.VBE
If Err.Number <> 0 Then
    WriteLog "FEHLER beim VBE-Zugriff: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If

Set vbProject = vbe.ActiveVBProject
WriteLog "OK - VBE-Zugriff"

' Altes Modul löschen
WriteLog "Prüfe auf existierendes Modul..."
found = False
For Each component In vbProject.VBComponents
    If component.Name = "mod_InitIstFormat" Then
        WriteLog "Lösche altes Modul..."
        vbProject.VBComponents.Remove component
        found = True
        Exit For
    End If
Next
If found Then
    WriteLog "OK - Altes Modul gelöscht"
Else
    WriteLog "Kein altes Modul gefunden"
End If

' Neues Modul erstellen
WriteLog "Erstelle neues Modul..."
Set vbModule = vbProject.VBComponents.Add(1) ' 1 = vbext_ct_StdModule
If Err.Number <> 0 Then
    WriteLog "FEHLER beim Erstellen des Moduls: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If

vbModule.Name = "mod_InitIstFormat"
vbModule.CodeModule.AddFromString vbaCode
If Err.Number <> 0 Then
    WriteLog "FEHLER beim Hinzufügen des Codes: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If
WriteLog "OK - Modul erstellt und Code eingefügt"

' Prozedur ausführen
WriteLog "Führe Configure_Ist_ConditionalFormatting aus..."
accessApp.Run "Configure_Ist_ConditionalFormatting"
If Err.Number <> 0 Then
    WriteLog "FEHLER beim Ausführen: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If
WriteLog "OK - Prozedur ausgeführt"

' Aufräumen
WriteLog "Schließe Access..."
accessApp.Quit
WriteLog "OK - Access geschlossen"

WriteLog "=== ERFOLGREICH ABGESCHLOSSEN ==="

logFile.Close
WScript.Echo "Log: C:\Users\guenther.siegert\Documents\Access Bridge\vbs_log.txt"
