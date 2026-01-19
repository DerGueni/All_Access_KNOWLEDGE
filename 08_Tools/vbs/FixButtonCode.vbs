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

On Error Resume Next

' Aendere den Button-Code im Formular
Dim vbe, proj, comp, codeModule, lineCount, i, lineText
Dim found

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_VA_Auftragstamm" Then
        Set codeModule = comp.CodeModule
        lineCount = codeModule.CountOfLines

        WScript.Echo "Form_frm_VA_Auftragstamm gefunden, " & lineCount & " Zeilen"

        ' Suche nach der Zeile mit OpenPositionszuordnungFromAuftrag im btn_Posliste_oeffnen_Click
        found = False
        For i = 1 To lineCount
            lineText = codeModule.Lines(i, 1)
            If InStr(lineText, "OpenPositionszuordnungFromAuftrag") > 0 Then
                ' Pruefe ob es die richtige Stelle ist (nach btn_Posliste_oeffnen_Click)
                If i > 1 Then
                    Dim prevLine
                    prevLine = codeModule.Lines(i - 1, 1)
                    If InStr(prevLine, "btn_Posliste_oeffnen_Click") > 0 Then
                        ' Ersetze die Zeile
                        codeModule.ReplaceLine i, "    ' Oeffnet frm_OB_Objekt mit Positionen fuer das aktuelle Objekt"
                        codeModule.InsertLines i + 1, "    OpenObjektPositionenFromAuftrag"
                        WScript.Echo "Zeile " & i & " ersetzt mit OpenObjektPositionenFromAuftrag"
                        found = True
                        Exit For
                    End If
                End If
            End If
        Next

        If Not found Then
            WScript.Echo "Suche OpenPositionszuordnungFromAuftrag ueberall..."
            For i = 1 To lineCount
                lineText = codeModule.Lines(i, 1)
                If InStr(lineText, "btn_Posliste_oeffnen_Click") > 0 And InStr(lineText, "Private Sub") > 0 Then
                    WScript.Echo "btn_Posliste_oeffnen_Click gefunden in Zeile " & i
                    ' Naechste Zeile sollte der Aufruf sein
                    Dim nextLine
                    nextLine = codeModule.Lines(i + 1, 1)
                    WScript.Echo "Naechste Zeile: " & nextLine

                    If InStr(nextLine, "OpenPositionszuordnungFromAuftrag") > 0 Then
                        codeModule.ReplaceLine i + 1, "    ' Oeffnet frm_OB_Objekt mit Positionen fuer das aktuelle Objekt"
                        codeModule.InsertLines i + 2, "    OpenObjektPositionenFromAuftrag"
                        WScript.Echo "Code aktualisiert"
                        found = True
                    End If
                    Exit For
                End If
            Next
        End If

        Exit For
    End If
Next

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

' Speichere das Formular explizit
accApp.DoCmd.Close 2, "frm_VA_Auftragstamm", 1 ' acSaveYes = 1
WScript.Sleep 1000

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
