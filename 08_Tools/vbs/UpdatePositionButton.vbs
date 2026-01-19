Option Explicit

Dim accApp, dbPath, fso

dbPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

Set fso = CreateObject("Scripting.FileSystemObject")

' Beende alle Access Prozesse
On Error Resume Next
Dim objWMI, colProcesses, objProcess
Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
Set colProcesses = objWMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'MSACCESS.EXE'")
For Each objProcess in colProcesses
    objProcess.Terminate()
Next
On Error GoTo 0

WScript.Sleep 3000

Set accApp = CreateObject("Access.Application")
accApp.Visible = True
accApp.OpenCurrentDatabase dbPath
WScript.Sleep 5000

' Neuen Code zur mdl_Bridge_Helper hinzufuegen
Dim newCode
newCode = "Public Sub OpenObjektPositionenFromAuftrag()" & vbCrLf & _
"    Dim lngObjekt_ID As Long" & vbCrLf & _
"    " & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    lngObjekt_ID = Nz(Forms!frm_VA_Auftragstamm!Objekt_ID, 0)" & vbCrLf & _
"    On Error GoTo 0" & vbCrLf & _
"    " & vbCrLf & _
"    If lngObjekt_ID = 0 Then" & vbCrLf & _
"        MsgBox ""Bitte erst ein Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    ' Oeffne frm_OB_Objekt mit Filter auf das ausgewaehlte Objekt" & vbCrLf & _
"    DoCmd.OpenForm ""frm_OB_Objekt"", , , ""ID = "" & lngObjekt_ID" & vbCrLf & _
"    " & vbCrLf & _
"    ' Setze Fokus auf Unterformular mit Positionen" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    Forms!frm_OB_Objekt!sub_OB_Objekt_Positionen.SetFocus" & vbCrLf & _
"    On Error GoTo 0" & vbCrLf & _
"End Sub"

On Error Resume Next

' Fuege neuen Code zu mdl_Bridge_Helper hinzu
Dim vbe, proj, comp, codeModule, lineCount

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

For Each comp In proj.VBComponents
    If comp.Name = "mdl_Bridge_Helper" Then
        Set codeModule = comp.CodeModule
        lineCount = codeModule.CountOfLines

        ' Pruefe ob Funktion bereits existiert
        Dim existingCode
        existingCode = codeModule.Lines(1, lineCount)

        If InStr(existingCode, "OpenObjektPositionenFromAuftrag") = 0 Then
            ' Funktion existiert noch nicht, fuege hinzu
            codeModule.InsertLines lineCount + 2, newCode
            WScript.Echo "Neue Funktion OpenObjektPositionenFromAuftrag hinzugefuegt"
        Else
            WScript.Echo "Funktion OpenObjektPositionenFromAuftrag existiert bereits"
        End If
        Exit For
    End If
Next

If Err.Number <> 0 Then
    WScript.Echo "Fehler beim Hinzufuegen: " & Err.Description
    Err.Clear

    ' Alternative: Neues Modul erstellen
    WScript.Echo "Versuche Code in neues Modul zu schreiben..."

    Set comp = proj.VBComponents.Add(1) ' 1 = vbext_ct_StdModule
    comp.Name = "mdl_ObjektPositionen"
    comp.CodeModule.InsertLines 1, "Option Compare Database" & vbCrLf & "Option Explicit"
    comp.CodeModule.InsertLines 3, ""
    comp.CodeModule.InsertLines 4, newCode

    If Err.Number = 0 Then
        WScript.Echo "Neues Modul mdl_ObjektPositionen erstellt"
    Else
        WScript.Echo "Fehler: " & Err.Description
    End If
End If

On Error GoTo 0

' Speichern
accApp.DoCmd.Save

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
