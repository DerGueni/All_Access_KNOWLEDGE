Option Explicit

Dim accApp, dbPath, outputPath, fso

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

' Aktiviere VBA-Zugriff in Trust Center (Registry)
' accApp.SetOption "Force Untrusted", False

accApp.OpenCurrentDatabase dbPath
WScript.Sleep 5000

' Jetzt die Module ueber SaveAsText exportieren
On Error Resume Next

accApp.SaveAsText 1, "mdl_Bridge_Helper", outputPath & "mdl_Bridge_Helper.txt"
If Err.Number <> 0 Then
    WScript.Echo "Fehler bei mdl_Bridge_Helper: " & Err.Description
    Err.Clear
Else
    WScript.Echo "mdl_Bridge_Helper exportiert"
End If

accApp.SaveAsText 1, "Form_frm_VA_Auftragstamm", outputPath & "Form_frm_VA_Auftragstamm.txt"
If Err.Number <> 0 Then
    WScript.Echo "Fehler bei Form_frm_VA_Auftragstamm: " & Err.Description
    Err.Clear
Else
    WScript.Echo "Form_frm_VA_Auftragstamm exportiert"
End If

' Versuche auch das Formular direkt zu exportieren
accApp.SaveAsText 2, "frm_VA_Auftragstamm", outputPath & "frm_VA_Auftragstamm_Form.txt"
If Err.Number <> 0 Then
    WScript.Echo "Fehler bei frm_VA_Auftragstamm Form: " & Err.Description
    Err.Clear
Else
    WScript.Echo "frm_VA_Auftragstamm Form exportiert"
End If

accApp.SaveAsText 2, "frm_OB_Objekt", outputPath & "frm_OB_Objekt_Form.txt"
If Err.Number <> 0 Then
    WScript.Echo "Fehler bei frm_OB_Objekt Form: " & Err.Description
    Err.Clear
Else
    WScript.Echo "frm_OB_Objekt Form exportiert"
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
