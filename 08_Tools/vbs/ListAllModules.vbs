Option Explicit

Dim accApp, dbPath, outputPath, fso, outFile

dbPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"
outputPath = "C:\Users\guenther.siegert\Documents\AccessExport\"

Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FolderExists(outputPath) Then
    fso.CreateFolder(outputPath)
End If

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

' Liste alle Module
Dim db, container, doc
Set db = accApp.CurrentDb

Set outFile = fso.CreateTextFile(outputPath & "ALLE_MODULE.txt", True)

' Module Container
On Error Resume Next
Set container = db.Containers("Modules")
If Err.Number = 0 Then
    outFile.WriteLine "=== Module ==="
    For Each doc In container.Documents
        outFile.WriteLine doc.Name
        WScript.Echo "Modul: " & doc.Name

        ' Versuche zu exportieren
        accApp.SaveAsText 5, doc.Name, outputPath & doc.Name & ".txt"
        If Err.Number = 0 Then
            WScript.Echo "  -> Exportiert"
        Else
            WScript.Echo "  -> Fehler: " & Err.Description
            Err.Clear
        End If
    Next
End If
Err.Clear

' Formulare Container
Set container = db.Containers("Forms")
If Err.Number = 0 Then
    outFile.WriteLine ""
    outFile.WriteLine "=== Formulare ==="
    For Each doc In container.Documents
        outFile.WriteLine doc.Name
    Next
End If
Err.Clear

On Error GoTo 0

outFile.Close
WScript.Echo "Liste in ALLE_MODULE.txt geschrieben"

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
