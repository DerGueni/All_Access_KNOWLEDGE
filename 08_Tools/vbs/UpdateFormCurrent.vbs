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

Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' Aktualisiere Form_frm_OB_Objekt Code
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_OB_Objekt" Then
        Set codeModule = comp.CodeModule
        Dim lineCount, i, lineText
        lineCount = codeModule.CountOfLines

        ' Suche nach der Zeile mit UpdateZeitHeaderLabels und fuege UpdateSummenAnzeige hinzu
        For i = 1 To lineCount
            lineText = codeModule.Lines(i, 1)

            If InStr(lineText, "UpdateZeitHeaderLabels") > 0 Then
                ' Pruefe ob UpdateSummenAnzeige bereits vorhanden
                Dim nextLine
                nextLine = codeModule.Lines(i + 1, 1)
                If InStr(nextLine, "UpdateSummenAnzeige") = 0 Then
                    codeModule.InsertLines i + 1, "    UpdateSummenAnzeige Me"
                    WScript.Echo "UpdateSummenAnzeige in Form_Current eingefuegt"
                Else
                    WScript.Echo "UpdateSummenAnzeige bereits vorhanden"
                End If
                Exit For
            End If
        Next

        ' Fuege auch After_Update Event fuer Unterformular hinzu
        Dim afterDelCode
        afterDelCode = vbCrLf & _
            "Private Sub sub_OB_Objekt_Positionen_Exit(Cancel As Integer)" & vbCrLf & _
            "    ' Aktualisiere Summen wenn Unterformular verlassen wird" & vbCrLf & _
            "    On Error Resume Next" & vbCrLf & _
            "    UpdateSummenAnzeige Me" & vbCrLf & _
            "End Sub"

        ' Pruefe ob Exit Event bereits existiert
        Dim exitExists
        exitExists = False
        lineCount = codeModule.CountOfLines
        For i = 1 To lineCount
            If InStr(codeModule.Lines(i, 1), "sub_OB_Objekt_Positionen_Exit") > 0 Then
                exitExists = True
                Exit For
            End If
        Next

        If Not exitExists Then
            codeModule.InsertLines codeModule.CountOfLines + 1, afterDelCode
            WScript.Echo "sub_OB_Objekt_Positionen_Exit Event hinzugefuegt"
        End If

        Exit For
    End If
Next

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
