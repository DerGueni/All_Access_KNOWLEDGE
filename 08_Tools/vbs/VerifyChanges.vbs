Option Explicit

Dim accApp, dbPath, fso, outputPath

dbPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"
outputPath = "C:\Users\guenther.siegert\Documents\AccessExport\"

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

' Exportiere aktualisierten Code
accApp.SaveAsText 5, "mdl_Bridge_Helper", outputPath & "mdl_Bridge_Helper_UPDATED.txt"
If Err.Number = 0 Then
    WScript.Echo "mdl_Bridge_Helper exportiert"
Else
    WScript.Echo "Fehler: " & Err.Description
    Err.Clear
End If

accApp.SaveAsText 2, "frm_VA_Auftragstamm", outputPath & "frm_VA_Auftragstamm_UPDATED.txt"
If Err.Number = 0 Then
    WScript.Echo "frm_VA_Auftragstamm exportiert"
Else
    WScript.Echo "Fehler: " & Err.Description
    Err.Clear
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
