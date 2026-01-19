' =====================================================
' IMPORTIERE_WEBVIEW2_MODUL.vbs
' Importiert mod_N_WebView2_forms3 automatisch in Access
' Datum: 14.01.2026
' =====================================================

Option Explicit

Dim accessApp, vbProj, vbe, component
Dim basFile, moduleName
Dim found, deleted, fso

' Konfiguration
basFile = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\mod_N_WebView2_forms3.bas"
moduleName = "mod_N_WebView2_forms3"

WScript.Echo "=== MODUL-IMPORT STARTEN ==="
WScript.Echo ""

' Prüfe ob .bas Datei existiert
Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FileExists(basFile) Then
    WScript.Echo "[FEHLER] Datei nicht gefunden:"
    WScript.Echo "  " & basFile
    WScript.Echo ""
    WScript.Echo "Import abgebrochen."
    WScript.Quit 1
End If

WScript.Echo "[1/5] Verbinde mit Access..."

On Error Resume Next
Set accessApp = GetObject(, "Access.Application")
If Err.Number <> 0 Then
    Err.Clear
    WScript.Echo "  [INFO] Access nicht geöffnet, starte Access..."
    Set accessApp = CreateObject("Access.Application")
    accessApp.OpenCurrentDatabase "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb", False
    WScript.Sleep 2000
End If
On Error GoTo 0

If accessApp Is Nothing Then
    WScript.Echo "  [FEHLER] Kann Access nicht öffnen!"
    WScript.Quit 1
End If

' accessApp.Visible = True  ' Kann Fehler verursachen, weglassen
WScript.Echo "  [OK] Access verbunden"

WScript.Echo ""
WScript.Echo "[2/5] Zugriff auf VBA Projekt..."

On Error Resume Next
Set vbe = accessApp.VBE
Set vbProj = vbe.VBProjects(1)
If Err.Number <> 0 Then
    WScript.Echo "  [FEHLER] Kein Zugriff auf VBA Projekt!"
    WScript.Echo "  " & Err.Description
    WScript.Echo ""
    WScript.Echo "HINWEIS: Makro-Sicherheitseinstellungen prüfen!"
    WScript.Quit 1
End If
On Error GoTo 0

WScript.Echo "  [OK] VBA Projekt verfügbar"

WScript.Echo ""
WScript.Echo "[3/5] Lösche alte " & moduleName & " Module..."

deleted = 0
On Error Resume Next
For Each component In vbProj.VBComponents
    If InStr(component.Name, moduleName) > 0 Then
        vbProj.VBComponents.Remove component
        If Err.Number = 0 Then
            WScript.Echo "  [OK] Gelöscht: " & component.Name
            deleted = deleted + 1
        Else
            WScript.Echo "  [WARNUNG] Konnte " & component.Name & " nicht löschen"
            Err.Clear
        End If
    End If
Next
On Error GoTo 0

If deleted = 0 Then
    WScript.Echo "  [INFO] Keine alten Module vorhanden"
End If

WScript.Sleep 500

WScript.Echo ""
WScript.Echo "[4/5] Importiere " & moduleName & ".bas..."

On Error Resume Next
vbProj.VBComponents.Import basFile
If Err.Number <> 0 Then
    WScript.Echo "  [FEHLER] Import fehlgeschlagen!"
    WScript.Echo "  " & Err.Description
    WScript.Quit 1
End If
On Error GoTo 0

WScript.Echo "  [OK] Modul importiert"

WScript.Sleep 500

WScript.Echo ""
WScript.Echo "[5/5] Kompiliere VBA Projekt..."

On Error Resume Next
accessApp.DoCmd.RunCommand 125 ' acCmdCompileAndSaveAllModules
If Err.Number <> 0 Then
    WScript.Echo "  [WARNUNG] Kompilierung mit Fehler"
    WScript.Echo "  " & Err.Description
    Err.Clear
Else
    WScript.Echo "  [OK] VBA kompiliert erfolgreich"
End If
On Error GoTo 0

' Prüfe ob Modul vorhanden ist
found = False
For Each component In vbProj.VBComponents
    If component.Name = moduleName Then
        found = True
        Exit For
    End If
Next

WScript.Echo ""
WScript.Echo "=== IMPORT ABGESCHLOSSEN ==="
WScript.Echo ""

If found Then
    WScript.Echo "[SUCCESS] Modul erfolgreich importiert!"
    WScript.Echo ""
    WScript.Echo "Nächste Schritte:"
    WScript.Echo "  1. In Access: Formular frm_va_Auftragstamm öffnen"
    WScript.Echo "  2. Button 'HTML Ansicht' klicken"
    WScript.Echo "  3. Browser sollte HTML-Formular anzeigen"
    WScript.Echo ""
    WScript.Echo "Falls API Server nicht läuft:"
    WScript.Echo "  Batch-Datei verwenden: START_ACCESS_MIT_SERVERN.bat"
Else
    WScript.Echo "[FEHLER] Modul nicht gefunden nach Import!"
    WScript.Echo ""
    WScript.Echo "Manuelle Schritte erforderlich:"
    WScript.Echo "  1. VBA Editor öffnen (Alt+F11)"
    WScript.Echo "  2. Datei → Datei importieren (Strg+M)"
    WScript.Echo "  3. Datei auswählen: " & basFile
End If

WScript.Echo ""
WScript.Echo "Drücken Sie Enter zum Beenden..."
WScript.StdIn.ReadLine
