Option Explicit

Dim accessApp, vbe, vbProject, vbModule, component
Dim vbaCode, fso, logFile, found

Set fso = CreateObject("Scripting.FileSystemObject")
Set logFile = fso.CreateTextFile("C:\Users\guenther.siegert\Documents\formatting_log.txt", True)

Sub WriteLog(msg)
    logFile.WriteLine Now & " - " & msg
    WScript.Echo msg
End Sub

On Error Resume Next

WriteLog "=== START Formatierungskonfiguration ==="

Set accessApp = CreateObject("Access.Application")
If Err.Number <> 0 Then
    WriteLog "FEHLER: " & Err.Description
    WScript.Quit 1
End If
WriteLog "✓ Access.Application erstellt"

accessApp.Visible = False
accessApp.OpenCurrentDatabase "C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb"
If Err.Number <> 0 Then
    WriteLog "FEHLER beim Öffnen: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If
WriteLog "✓ DB geöffnet"

vbaCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Public Sub Configure_Ist_ConditionalFormatting()" & vbCrLf & _
"    Const FORM_NAME As String = ""frm_lst_row_auftrag""" & vbCrLf & _
"    Dim hasTxtOffene As Boolean, ctl As Control, istCtl As Control" & vbCrLf & vbCrLf & _
"    DoCmd.OpenForm FORM_NAME, View:=acDesign, WindowMode:=acHidden" & vbCrLf & vbCrLf & _
"    hasTxtOffene = False" & vbCrLf & _
"    For Each ctl In Forms(FORM_NAME).Controls" & vbCrLf & _
"        If ctl.Name = ""txtOffeneAnfragen"" Then: hasTxtOffene = True: Exit For" & vbCrLf & _
"    Next" & vbCrLf & vbCrLf & _
"    If Not hasTxtOffene Then" & vbCrLf & _
"        Dim txt As Control" & vbCrLf & _
"        Set txt = Application.CreateControl(FORM_NAME, acTextBox, acDetail)" & vbCrLf & _
"        txt.Name = ""txtOffeneAnfragen""" & vbCrLf & _
"        txt.Top = 0: txt.Left = 0: txt.Width = 100: txt.Height = 200" & vbCrLf & _
"    End If" & vbCrLf & vbCrLf & _
"    With Forms(FORM_NAME).Controls(""txtOffeneAnfragen"")" & vbCrLf & _
"        .ControlSource = ""=Nz(DCount(""""""""*""""""""; """"""""qry_MA_Offene_Anfragen""""""""; """"""""VA_ID="""""""" & [ID]);0)""" & vbCrLf & _
"        .Visible = False: .Locked = True: .TabStop = False" & vbCrLf & _
"    End With" & vbCrLf & vbCrLf & _
"    DoCmd.Close acForm, FORM_NAME, acSaveYes" & vbCrLf & _
"    DoCmd.OpenForm FORM_NAME, View:=acNormal" & vbCrLf & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    Set istCtl = Forms(FORM_NAME).Controls(""Ist"")" & vbCrLf & _
"    On Error GoTo 0" & vbCrLf & _
"    If istCtl Is Nothing Then" & vbCrLf & _
"        For Each ctl In Forms(FORM_NAME).Controls" & vbCrLf & _
"            If ctl.ControlType = acTextBox And LCase$(Nz(ctl.ControlSource,"""")) = ""ist"" Then" & vbCrLf & _
"                Set istCtl = ctl: Exit For" & vbCrLf & _
"            End If" & vbCrLf & _
"        Next" & vbCrLf & _
"    End If" & vbCrLf & _
"    If istCtl Is Nothing Then: MsgBox ""Ist-Feld nicht gefunden"", vbExclamation: Exit Sub" & vbCrLf & vbCrLf & _
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
"    DoCmd.Close acForm, FORM_NAME, acSaveYes" & vbCrLf & _
"    MsgBox ""Formatierung konfiguriert!"", vbInformation" & vbCrLf & _
"End Sub"

WriteLog "VBA-Code vorbereitet"

Set vbe = accessApp.VBE
If Err.Number <> 0 Then
    WriteLog "FEHLER VBE: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If

Set vbProject = vbe.ActiveVBProject
WriteLog "✓ VBE-Zugriff"

found = False
For Each component In vbProject.VBComponents
    If component.Name = "mod_InitIstFormat" Then
        vbProject.VBComponents.Remove component
        found = True
        WriteLog "  Altes Modul entfernt"
        Exit For
    End If
Next

Set vbModule = vbProject.VBComponents.Add(1)
If Err.Number <> 0 Then
    WriteLog "FEHLER Modul: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If

vbModule.Name = "mod_InitIstFormat"
vbModule.CodeModule.AddFromString vbaCode
If Err.Number <> 0 Then
    WriteLog "FEHLER Code: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If
WriteLog "✓ Modul erstellt"

WriteLog "Führe Prozedur aus..."
accessApp.Run "Configure_Ist_ConditionalFormatting"
If Err.Number <> 0 Then
    WriteLog "FEHLER Run: " & Err.Description
    accessApp.Quit
    WScript.Quit 1
End If
WriteLog "✓ Prozedur ausgeführt"

accessApp.Quit
WriteLog "✓ Access geschlossen"

WriteLog ""
WriteLog "=========================================="
WriteLog "ERFOLGREICH ABGESCHLOSSEN"
WriteLog "=========================================="
WriteLog "Feld 'Ist' in frm_lst_row_auftrag:"
WriteLog "  • BLAU = Offene Mitarbeiteranfragen"
WriteLog "  • ROT = Keine Anfragen offen, Ist <> Soll"

logFile.Close

WScript.Echo ""
WScript.Echo "Log: C:\Users\guenther.siegert\Documents\formatting_log.txt"
