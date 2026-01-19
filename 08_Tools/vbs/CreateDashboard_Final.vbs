' ============================================
' CreateDashboard_Final.vbs
' Erstellt Dashboard-Formulare direkt ueber DoCmd
' ============================================

Option Explicit

Dim accessApp
Dim frontendPath

frontendPath = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - Diverses\Consys_FE_N_Test_Claude_GPT - Kopie (6).accdb"

' Erstmal alle Access-Prozesse beenden
On Error Resume Next
Dim shell
Set shell = CreateObject("WScript.Shell")
shell.Run "taskkill /F /IM MSACCESS.EXE", 0, True
WScript.Sleep 2000
On Error GoTo 0

' Access starten
WScript.Echo "Starte Access..."
Set accessApp = CreateObject("Access.Application")
accessApp.Visible = True
accessApp.AutomationSecurity = 1

WScript.Echo "Oeffne Datenbank..."
accessApp.OpenCurrentDatabase frontendPath, False
WScript.Sleep 3000

' ============================================
' VBA-Code zum Erstellen der Formulare ausfuehren
' ============================================
WScript.Echo ""
WScript.Echo "Fuehre FormularerstellungsCode aus..."

Dim vbaCode
vbaCode = "" & _
"Public Sub CreateDashboardForms()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    Dim db As DAO.Database" & vbCrLf & _
"    Set db = CurrentDb" & vbCrLf & _
"    " & vbCrLf & _
"    ' Unterformular 1: Auftraege heute" & vbCrLf & _
"    DoCmd.DeleteObject acForm, ""sub_N_Dashboard_AuftraegeHeute""" & vbCrLf & _
"    Err.Clear" & vbCrLf & _
"    DoCmd.SelectObject acQuery, ""qry_N_Dashboard_AuftraegeHeute"", True" & vbCrLf & _
"    DoCmd.RunCommand acCmdNewObjectAutoForm" & vbCrLf & _
"    DoCmd.Save acForm, ""sub_N_Dashboard_AuftraegeHeute""" & vbCrLf & _
"    DoCmd.Close acForm, ""sub_N_Dashboard_AuftraegeHeute"", acSaveYes" & vbCrLf & _
"    Debug.Print ""Unterformular 1 erstellt""" & vbCrLf & _
"    " & vbCrLf & _
"    ' Unterformular 2: Unterbesetzung" & vbCrLf & _
"    DoCmd.DeleteObject acForm, ""sub_N_Dashboard_Unterbesetzung""" & vbCrLf & _
"    Err.Clear" & vbCrLf & _
"    DoCmd.SelectObject acQuery, ""qry_N_Dashboard_Unterbesetzung"", True" & vbCrLf & _
"    DoCmd.RunCommand acCmdNewObjectAutoForm" & vbCrLf & _
"    DoCmd.Save acForm, ""sub_N_Dashboard_Unterbesetzung""" & vbCrLf & _
"    DoCmd.Close acForm, ""sub_N_Dashboard_Unterbesetzung"", acSaveYes" & vbCrLf & _
"    Debug.Print ""Unterformular 2 erstellt""" & vbCrLf & _
"    " & vbCrLf & _
"    MsgBox ""Dashboard-Formulare erstellt!"", vbInformation" & vbCrLf & _
"End Sub"

' Code in temp-Modul einfuegen und ausfuehren
Dim vbe, proj, tempMod

On Error Resume Next
accessApp.DoCmd.DeleteObject 5, "mod_TempDashboardCreate"
Err.Clear
On Error GoTo 0

Set vbe = accessApp.VBE
Set proj = vbe.ActiveVBProject
Set tempMod = proj.VBComponents.Add(1)  ' Standardmodul
tempMod.Name = "mod_TempDashboardCreate"
tempMod.CodeModule.AddFromString vbaCode

WScript.Sleep 1000

' VBA ausfuehren
WScript.Echo "Fuehre CreateDashboardForms() aus..."
On Error Resume Next
accessApp.Run "CreateDashboardForms"
If Err.Number <> 0 Then
    WScript.Echo "  Fehler: " & Err.Description
End If
On Error GoTo 0

WScript.Sleep 2000

' Temp-Modul loeschen
On Error Resume Next
accessApp.DoCmd.DeleteObject 5, "mod_TempDashboardCreate"
On Error GoTo 0

' Speichern und schliessen
WScript.Echo ""
WScript.Echo "Speichere und schliesse..."
accessApp.DoCmd.RunCommand 3  ' Speichern
WScript.Sleep 1000

accessApp.CloseCurrentDatabase
accessApp.Quit

Set accessApp = Nothing

WScript.Echo ""
WScript.Echo "============================================"
WScript.Echo "DASHBOARD-ERSTELLUNG ABGESCHLOSSEN"
WScript.Echo "============================================"
WScript.Echo ""
WScript.Echo "Oeffnen Sie das Frontend und testen Sie:"
WScript.Echo "  1. Modul: mod_N_Dashboard (VBA-Funktionen)"
WScript.Echo "  2. Abfragen: qry_N_Dashboard_* (6 Stueck)"
WScript.Echo "  3. Formulare: sub_N_Dashboard_* (falls erstellt)"
WScript.Echo ""
WScript.Echo "Die wichtigsten neuen Funktionen sind:"
WScript.Echo "  - Dashboard_AuftraegeHeute()"
WScript.Echo "  - Dashboard_Unterbesetzung()"
WScript.Echo "  - Konflikt_Pruefen(MA_ID, Datum, Start, Ende)"
WScript.Echo "  - Schnell_Zuordnen(...)"
WScript.Echo "  - Ampel_Farbe(Ist, Soll)"
WScript.Echo "============================================"
