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
Dim vbe, proj, comp, codeModule, lineCount, i, lines(), lineText
Dim startLine, endLine, found

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_VA_Auftragstamm" Then
        Set codeModule = comp.CodeModule
        lineCount = codeModule.CountOfLines

        WScript.Echo "Form_frm_VA_Auftragstamm gefunden, " & lineCount & " Zeilen"

        ' Suche nach btn_Posliste_oeffnen_Click
        found = False
        For i = 1 To lineCount
            lineText = codeModule.Lines(i, 1)
            If InStr(lineText, "btn_Posliste_oeffnen_Click") > 0 And InStr(lineText, "Private Sub") > 0 Then
                startLine = i
                found = True
                WScript.Echo "Funktion gefunden in Zeile " & i
            End If
            If found And InStr(lineText, "End Sub") > 0 And i > startLine Then
                endLine = i
                WScript.Echo "Ende gefunden in Zeile " & i

                ' Loesche alte Zeilen
                codeModule.DeleteLines startLine, endLine - startLine + 1

                ' Fuege neue Funktion ein
                Dim newCode
                newCode = "Private Sub btn_Posliste_oeffnen_Click()" & vbCrLf & _
                          "    ' Oeffnet frm_OB_Objekt mit Positionen fuer das aktuelle Objekt" & vbCrLf & _
                          "    OpenObjektPositionenFromAuftrag" & vbCrLf & _
                          "End Sub"
                codeModule.InsertLines startLine, newCode

                WScript.Echo "Button-Code aktualisiert"
                Exit For
            End If
        Next

        If Not found Then
            WScript.Echo "Funktion btn_Posliste_oeffnen_Click nicht gefunden"
        End If

        Exit For
    End If
Next

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

' Speichern
accApp.DoCmd.Save

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
