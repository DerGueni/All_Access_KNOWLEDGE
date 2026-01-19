Option Explicit

Dim accApp, db, comp, fso, outFile, dbPath, outputPath

dbPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"
outputPath = "C:\Users\guenther.siegert\Documents\AccessExport\"

Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FolderExists(outputPath) Then
    fso.CreateFolder(outputPath)
End If

Set accApp = CreateObject("Access.Application")
accApp.Visible = True
accApp.OpenCurrentDatabase dbPath

WScript.Sleep 5000

' Export alle Module
Dim vbe, proj
Set vbe = accApp.VBE

WScript.Echo "VBE Projects Count: " & vbe.VBProjects.Count

If vbe.VBProjects.Count > 0 Then
    Set proj = vbe.VBProjects(1)
    WScript.Echo "Projekt: " & proj.Name

    For Each comp In proj.VBComponents
        WScript.Echo "Komponente: " & comp.Name & " - Type: " & comp.Type

        If comp.Name = "mdl_Bridge_Helper" Or comp.Name = "Form_frm_VA_Auftragstamm" Then
            If comp.CodeModule.CountOfLines > 0 Then
                Set outFile = fso.CreateTextFile(outputPath & comp.Name & ".txt", True)
                outFile.Write comp.CodeModule.Lines(1, comp.CodeModule.CountOfLines)
                outFile.Close
                WScript.Echo "  -> Exportiert nach " & outputPath & comp.Name & ".txt"
            End If
        End If
    Next
Else
    WScript.Echo "Keine VBProjects gefunden"
End If

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
