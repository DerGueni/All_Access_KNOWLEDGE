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

' ========================================
' Formulare umbenennen
' ========================================

WScript.Echo "=== Benenne Formulare um ==="

' Liste der umzubenennenden Formulare
Dim formRenames
formRenames = Array( _
    "frm_PositionenKopieren|frm_N_PositionenKopieren", _
    "frm_VorlageAuswahl|frm_N_VorlageAuswahl" _
)

Dim i, parts, oldName, newName

For i = 0 To UBound(formRenames)
    parts = Split(formRenames(i), "|")
    oldName = parts(0)
    newName = parts(1)

    ' Pruefe ob altes Formular existiert
    On Error Resume Next
    accApp.DoCmd.Rename newName, 2, oldName ' acForm = 2
    If Err.Number = 0 Then
        WScript.Echo "Formular umbenannt: " & oldName & " -> " & newName
    ElseIf Err.Number = 7874 Then
        WScript.Echo "Formular existiert nicht: " & oldName
    Else
        WScript.Echo "Fehler bei " & oldName & ": " & Err.Description
    End If
    Err.Clear
Next

' ========================================
' Module umbenennen
' ========================================

WScript.Echo ""
WScript.Echo "=== Benenne Module um ==="

Dim vbe, proj, comp

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' Liste der umzubenennenden Module
Dim moduleRenames
moduleRenames = Array( _
    "mdl_PositionslistenExport|mdl_N_PositionslistenExport", _
    "mdl_PositionslistenImport|mdl_N_PositionslistenImport", _
    "mdl_PositionsVorlagen|mdl_N_PositionsVorlagen", _
    "mdl_ObjektFilter|mdl_N_ObjektFilter", _
    "mdl_ZeitHeader|mdl_N_ZeitHeader", _
    "mdl_FormBuilder|mdl_N_FormBuilder" _
)

For i = 0 To UBound(moduleRenames)
    parts = Split(moduleRenames(i), "|")
    oldName = parts(0)
    newName = parts(1)

    On Error Resume Next
    For Each comp In proj.VBComponents
        If comp.Name = oldName Then
            comp.Name = newName
            If Err.Number = 0 Then
                WScript.Echo "Modul umbenannt: " & oldName & " -> " & newName
            Else
                WScript.Echo "Fehler bei " & oldName & ": " & Err.Description
            End If
            Err.Clear
            Exit For
        End If
    Next
Next

' ========================================
' Referenzen im Code aktualisieren
' ========================================

WScript.Echo ""
WScript.Echo "=== Aktualisiere Code-Referenzen ==="

' Aktualisiere Referenzen in allen Modulen
Dim codeModule, lineCount, j, lineText, newLineText
Dim replacements
replacements = Array( _
    "frm_PositionenKopieren|frm_N_PositionenKopieren", _
    "frm_VorlageAuswahl|frm_N_VorlageAuswahl", _
    "mdl_PositionslistenExport|mdl_N_PositionslistenExport", _
    "mdl_PositionslistenImport|mdl_N_PositionslistenImport", _
    "mdl_PositionsVorlagen|mdl_N_PositionsVorlagen", _
    "mdl_ObjektFilter|mdl_N_ObjektFilter", _
    "mdl_ZeitHeader|mdl_N_ZeitHeader", _
    "mdl_FormBuilder|mdl_N_FormBuilder" _
)

For Each comp In proj.VBComponents
    If comp.Type = 1 Or comp.Type = 100 Then ' Standard Module or Form Module
        Set codeModule = comp.CodeModule
        lineCount = codeModule.CountOfLines

        If lineCount > 0 Then
            For j = 1 To lineCount
                lineText = codeModule.Lines(j, 1)
                newLineText = lineText

                ' Ersetze alle alten Namen durch neue
                For i = 0 To UBound(replacements)
                    parts = Split(replacements(i), "|")
                    oldName = parts(0)
                    newName = parts(1)

                    If InStr(newLineText, oldName) > 0 Then
                        newLineText = Replace(newLineText, oldName, newName)
                    End If
                Next

                ' Wenn Zeile geaendert wurde, ersetzen
                If newLineText <> lineText Then
                    codeModule.ReplaceLine j, newLineText
                End If
            Next
        End If
    End If
Next

WScript.Echo "Code-Referenzen aktualisiert"

' ========================================
' Tabellen umbenennen (falls vorhanden)
' ========================================

WScript.Echo ""
WScript.Echo "=== Benenne Tabellen um ==="

Dim tableRenames
tableRenames = Array( _
    "tbl_Positions_Vorlagen|tbl_N_Positions_Vorlagen", _
    "tbl_Positions_Vorlagen_Details|tbl_N_Positions_Vorlagen_Details" _
)

Dim db
Set db = accApp.CurrentDb

For i = 0 To UBound(tableRenames)
    parts = Split(tableRenames(i), "|")
    oldName = parts(0)
    newName = parts(1)

    On Error Resume Next
    accApp.DoCmd.Rename newName, 0, oldName ' acTable = 0
    If Err.Number = 0 Then
        WScript.Echo "Tabelle umbenannt: " & oldName & " -> " & newName
    ElseIf Err.Number = 7874 Then
        WScript.Echo "Tabelle existiert nicht: " & oldName
    Else
        WScript.Echo "Fehler bei " & oldName & ": " & Err.Description
    End If
    Err.Clear
Next

' Aktualisiere Tabellen-Referenzen im Code
WScript.Echo ""
WScript.Echo "=== Aktualisiere Tabellen-Referenzen im Code ==="

Dim tableReplacements
tableReplacements = Array( _
    "tbl_Positions_Vorlagen_Details|tbl_N_Positions_Vorlagen_Details", _
    "tbl_Positions_Vorlagen|tbl_N_Positions_Vorlagen" _
)

For Each comp In proj.VBComponents
    If comp.Type = 1 Or comp.Type = 100 Then
        Set codeModule = comp.CodeModule
        lineCount = codeModule.CountOfLines

        If lineCount > 0 Then
            For j = 1 To lineCount
                lineText = codeModule.Lines(j, 1)
                newLineText = lineText

                For i = 0 To UBound(tableReplacements)
                    parts = Split(tableReplacements(i), "|")
                    oldName = parts(0)
                    newName = parts(1)

                    If InStr(newLineText, oldName) > 0 Then
                        newLineText = Replace(newLineText, oldName, newName)
                    End If
                Next

                If newLineText <> lineText Then
                    codeModule.ReplaceLine j, newLineText
                End If
            Next
        End If
    End If
Next

WScript.Echo "Tabellen-Referenzen aktualisiert"

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo ""
WScript.Echo "=== Umbenennung abgeschlossen ==="
