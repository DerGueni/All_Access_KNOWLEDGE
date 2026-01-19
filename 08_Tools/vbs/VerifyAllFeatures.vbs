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

WScript.Echo "=========================================="
WScript.Echo "FUNKTIONALITAETSPRUEFUNG"
WScript.Echo "=========================================="
WScript.Echo ""

Dim db, vbe, proj, comp
Set db = accApp.CurrentDb
Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' ========================================
' 1. Pruefe Module
' ========================================

WScript.Echo "=== 1. MODULE ==="

Dim moduleList, moduleName, moduleFound
moduleList = Array( _
    "mdl_N_PositionslistenExport", _
    "mdl_N_PositionslistenImport", _
    "mdl_N_PositionsVorlagen", _
    "mdl_N_ObjektFilter", _
    "mdl_N_ZeitHeader", _
    "mdl_N_FormBuilder" _
)

Dim i
For i = 0 To UBound(moduleList)
    moduleName = moduleList(i)
    moduleFound = False

    For Each comp In proj.VBComponents
        If comp.Name = moduleName Then
            moduleFound = True
            WScript.Echo "[OK] " & moduleName & " (" & comp.CodeModule.CountOfLines & " Zeilen)"
            Exit For
        End If
    Next

    If Not moduleFound Then
        WScript.Echo "[FEHLT] " & moduleName
    End If
Next

' ========================================
' 2. Pruefe Formulare
' ========================================

WScript.Echo ""
WScript.Echo "=== 2. FORMULARE ==="

Dim formList, formName, formFound, container, doc
formList = Array( _
    "frm_N_PositionenKopieren", _
    "frm_N_VorlageAuswahl", _
    "frm_OB_Objekt", _
    "sub_OB_Objekt_Positionen" _
)

Set container = db.Containers("Forms")

For i = 0 To UBound(formList)
    formName = formList(i)
    formFound = False

    For Each doc In container.Documents
        If doc.Name = formName Then
            formFound = True
            WScript.Echo "[OK] " & formName
            Exit For
        End If
    Next

    If Not formFound Then
        WScript.Echo "[FEHLT] " & formName
    End If
Next

' ========================================
' 3. Pruefe Tabellen
' ========================================

WScript.Echo ""
WScript.Echo "=== 3. TABELLEN ==="

Dim tableList, tableName, tableFound, tdf
tableList = Array( _
    "tbl_N_Positions_Vorlagen", _
    "tbl_N_Positions_Vorlagen_Details", _
    "tbl_OB_Objekt", _
    "tbl_OB_Objekt_Positionen" _
)

For i = 0 To UBound(tableList)
    tableName = tableList(i)
    tableFound = False

    For Each tdf In db.TableDefs
        If tdf.Name = tableName Then
            tableFound = True
            WScript.Echo "[OK] " & tableName
            Exit For
        End If
    Next

    If Not tableFound Then
        WScript.Echo "[FEHLT] " & tableName
    End If
Next

' ========================================
' 4. Pruefe Felder in tbl_OB_Objekt
' ========================================

WScript.Echo ""
WScript.Echo "=== 4. FELDER IN tbl_OB_Objekt ==="

Dim requiredFields, fieldName, fld, fieldFound
requiredFields = Array("Zeit1_Label", "Zeit2_Label", "Zeit3_Label", "Zeit4_Label")

For Each tdf In db.TableDefs
    If tdf.Name = "tbl_OB_Objekt" Then
        For i = 0 To UBound(requiredFields)
            fieldName = requiredFields(i)
            fieldFound = False

            For Each fld In tdf.Fields
                If fld.Name = fieldName Then
                    fieldFound = True
                    WScript.Echo "[OK] " & fieldName
                    Exit For
                End If
            Next

            If Not fieldFound Then
                WScript.Echo "[FEHLT] " & fieldName
            End If
        Next
        Exit For
    End If
Next

' ========================================
' 5. Pruefe Felder in tbl_OB_Objekt_Positionen
' ========================================

WScript.Echo ""
WScript.Echo "=== 5. FELDER IN tbl_OB_Objekt_Positionen ==="

requiredFields = Array("PosNr", "Zeit1", "Zeit2", "Zeit3", "Zeit4", "Sort", "Gruppe", "Zusatztext")

For Each tdf In db.TableDefs
    If tdf.Name = "tbl_OB_Objekt_Positionen" Then
        For i = 0 To UBound(requiredFields)
            fieldName = requiredFields(i)
            fieldFound = False

            For Each fld In tdf.Fields
                If fld.Name = fieldName Then
                    fieldFound = True
                    WScript.Echo "[OK] " & fieldName
                    Exit For
                End If
            Next

            If Not fieldFound Then
                WScript.Echo "[FEHLT] " & fieldName
            End If
        Next
        Exit For
    End If
Next

' ========================================
' 6. Pruefe Buttons in frm_OB_Objekt
' ========================================

WScript.Echo ""
WScript.Echo "=== 6. BUTTONS IN frm_OB_Objekt ==="

Dim buttonList, buttonName, buttonFound, ctl

accApp.DoCmd.OpenForm "frm_OB_Objekt", 1 ' Design
WScript.Sleep 1500

Dim frm
Set frm = accApp.Forms("frm_OB_Objekt")

buttonList = Array( _
    "btnUploadPositionen", _
    "btnExportExcel", _
    "btnKopierePositionen", _
    "btnVorlageSpeichern", _
    "btnVorlageLaden", _
    "btnZeitLabels", _
    "btnMoveUp", _
    "btnMoveDown", _
    "txtSuche" _
)

For i = 0 To UBound(buttonList)
    buttonName = buttonList(i)
    buttonFound = False

    For Each ctl In frm.Controls
        If ctl.Name = buttonName Then
            buttonFound = True
            WScript.Echo "[OK] " & buttonName
            Exit For
        End If
    Next

    If Not buttonFound Then
        WScript.Echo "[FEHLT] " & buttonName
    End If
Next

accApp.DoCmd.Close 2, "frm_OB_Objekt", 2 ' acSaveNo

' ========================================
' 7. Pruefe Funktionen in Modulen
' ========================================

WScript.Echo ""
WScript.Echo "=== 7. WICHTIGE FUNKTIONEN ==="

Dim funcList, funcName, funcFound, codeText
funcList = Array( _
    "ExportPositionslisteToExcel|mdl_N_PositionslistenExport", _
    "ImportPositionslisteFromExcel|mdl_N_PositionslistenImport", _
    "KopierePositionen|mdl_N_PositionsVorlagen", _
    "SpeichereAlsVorlage|mdl_N_PositionsVorlagen", _
    "LadeVorlage|mdl_N_PositionsVorlagen", _
    "MovePositionUp|mdl_N_PositionsVorlagen", _
    "MovePositionDown|mdl_N_PositionsVorlagen", _
    "FilterObjektListe|mdl_N_ObjektFilter", _
    "ValidateZeitWert|mdl_N_ZeitHeader", _
    "GetGruppenFarbe|mdl_N_ZeitHeader", _
    "BearbeiteZeitLabels|mdl_N_ZeitHeader", _
    "UpdateZeitHeaderLabels|mdl_N_ZeitHeader", _
    "UpdateSummenAnzeige|mdl_N_ZeitHeader" _
)

Dim parts
For i = 0 To UBound(funcList)
    parts = Split(funcList(i), "|")
    funcName = parts(0)
    moduleName = parts(1)
    funcFound = False

    For Each comp In proj.VBComponents
        If comp.Name = moduleName Then
            If comp.CodeModule.CountOfLines > 0 Then
                codeText = comp.CodeModule.Lines(1, comp.CodeModule.CountOfLines)
                If InStr(codeText, funcName) > 0 Then
                    funcFound = True
                    WScript.Echo "[OK] " & funcName & " in " & moduleName
                End If
            End If
            Exit For
        End If
    Next

    If Not funcFound Then
        WScript.Echo "[FEHLT] " & funcName & " in " & moduleName
    End If
Next

' ========================================
' 8. Pruefe Code-Referenzen (keine alten Namen)
' ========================================

WScript.Echo ""
WScript.Echo "=== 8. PRUEFE AUF ALTE REFERENZEN ==="

Dim oldNames, oldName, foundOld
oldNames = Array( _
    "frm_PositionenKopieren", _
    "frm_VorlageAuswahl", _
    "tbl_Positions_Vorlagen", _
    "mdl_PositionslistenExport", _
    "mdl_PositionslistenImport", _
    "mdl_PositionsVorlagen", _
    "mdl_ObjektFilter", _
    "mdl_ZeitHeader", _
    "mdl_FormBuilder" _
)

Dim totalOldRefs
totalOldRefs = 0

For Each comp In proj.VBComponents
    If comp.Type = 1 Or comp.Type = 100 Then
        If comp.CodeModule.CountOfLines > 0 Then
            codeText = comp.CodeModule.Lines(1, comp.CodeModule.CountOfLines)

            For i = 0 To UBound(oldNames)
                oldName = oldNames(i)
                ' Pruefe ob alter Name vorkommt (aber nicht als Teil des neuen Namens)
                If InStr(codeText, """" & oldName & """") > 0 Then
                    WScript.Echo "[WARNUNG] Alte Referenz '" & oldName & "' in " & comp.Name
                    totalOldRefs = totalOldRefs + 1
                End If
            Next
        End If
    End If
Next

If totalOldRefs = 0 Then
    WScript.Echo "[OK] Keine alten Referenzen gefunden"
End If

WScript.Echo ""
WScript.Echo "=========================================="
WScript.Echo "PRUEFUNG ABGESCHLOSSEN"
WScript.Echo "=========================================="

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing
