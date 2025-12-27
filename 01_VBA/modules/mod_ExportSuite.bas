Attribute VB_Name = "mod_ExportSuite"
Option Compare Database
Option Explicit
Private gAssets As Collection
Private gAssetsRoot As String
' ============================================================
'  Claude/HTML Export Suite (Access 2021 / 64-bit / Win10)
'  - Exportiert ausgewählte Formulare (Startliste) + ALLE Abhängigkeiten rekursiv
'  - Überspringt bereits exportierte Objekte (auch über mehrere Läufe)
'  - Fehler pro Formular/Report werden geloggt, Export läuft weiter
'  - Exportiert zusätzlich: ALLE Reports, ALLE Queries, VBA, Makros
'  - Erstellt: dependency_map.json, report.json
'  - Erstellt: tables_schema.json (Tabellen/Felder/Indizes)
'  - Erstellt: references.json (VBA-References/COM)
'  - Erstellt: assets_manifest.json + kopiert referenzierte Bilddateien nach exports\assets\
' ============================================================

' =========================
' CONFIG
' =========================
Private Const EXPORT_ROOT As String = "C:\users\guenther.siegert\Documents\01_ClaudeCode_HTML\exports\"

' OPTIONAL Root-Forms (falls du nur 2 Startforms exportieren willst)
Private Const ROOT_FORM_1 As String = "frm_MA_Mitarbeiterstamm"
Private Const ROOT_FORM_2 As String = "frm_Menuefuehrung"

' =========================
' PUBLIC ENTRYPOINTS
' =========================

' 1) Exportiert nur die beiden Root-Forms rekursiv (inkl. Abhängigkeiten)
Public Sub Export_Project_For_RootForms()
    Dim Report As Collection: Set Report = New Collection
    Dim visited As Object: Set visited = CreateObject("Scripting.Dictionary")
    Dim exportRoot As String

    On Error GoTo EH

    exportRoot = PrepareExportFolders(Report)

    ' Root-Forms rekursiv exportieren (skip wenn bereits exportiert)
    TryExportOneForm ROOT_FORM_1, exportRoot, visited, Report
    TryExportOneForm ROOT_FORM_2, exportRoot, visited, Report

    ExportAllSensibleGlobals exportRoot, visited, Report

    MsgBox "Export abgeschlossen (RootForms). Ziel: " & exportRoot, vbInformation
    Exit Sub

EH:
    Report.Add "FATAL Export_Project_For_RootForms: " & Err.Number & " - " & Err.description
    On Error Resume Next
    Write_Report EnsureDir(EXPORT_ROOT) & "report.json", Report
    MsgBox "Abbruch: " & Err.description, vbExclamation
End Sub


' 2) Exportiert deine markierten Formulare (Split), rekursiv inkl. Abhängigkeiten
Public Sub Export_MyMarkedForms_WithDependencies_Split()
    Dim Report As Collection: Set Report = New Collection
    Dim visited As Object: Set visited = CreateObject("Scripting.Dictionary")
    Dim exportRoot As String

    On Error GoTo EH

    exportRoot = PrepareExportFolders(Report)

    ' Startliste in 2 Teilen (inkl. rekursiver Unterformulare/Subreports)
    Export_MarkedForms_Part1 exportRoot, visited, Report
    Export_MarkedForms_Part2 exportRoot, visited, Report

    ExportAllSensibleGlobals exportRoot, visited, Report

    MsgBox "Export abgeschlossen (Split + Fehler tolerant + Skip). Ziel: " & exportRoot, vbInformation
    Exit Sub

EH:
    Report.Add "FATAL Export_MyMarkedForms_WithDependencies_Split: " & Err.Number & " - " & Err.description
    On Error Resume Next
    Write_Report EnsureDir(EXPORT_ROOT) & "report.json", Report
    MsgBox "Abbruch: " & Err.description, vbExclamation
End Sub


' =========================
' STARTLISTE – TEIL 1
' =========================
Public Sub Export_MarkedForms_Part1(ByVal exportRoot As String, ByVal visited As Object, ByVal Report As Collection)
    Dim formsToExport As Variant
    formsToExport = Array( _
        "frm_Abwesenheiten", _
        "frm_abwesenheitsuebersicht", _
        "frm_Auswahlboxen", _
        "frm_Ausweis_Create", _
        "frm_DP_Dienstplan_MA", _
        "frm_DP_Dienstplan_Objekt", _
        "frm_DP_Dienstplan_Objekt1", _
        "frm_KD_Kundenstamm", _
        "frm_Kundenpreise", _
        "frm_Kundenpreise_gueni", _
        "frm_Letzter_Einsatz_MA_Gueni", _
        "frm_lst_row_auftrag", _
        "frm_MA_Mitarbeiterstamm", _
        "frm_MA_NVerfuegZeiten_Si", _
        "frm_MA_Offene_Anfragen" _
    )

    Dim i As Long
    For i = LBound(formsToExport) To UBound(formsToExport)
        TryExportOneForm CStr(formsToExport(i)), exportRoot, visited, Report
    Next i
End Sub


' =========================
' STARTLISTE – TEIL 2
' =========================
Public Sub Export_MarkedForms_Part2(ByVal exportRoot As String, ByVal visited As Object, ByVal Report As Collection)
    Dim formsToExport As Variant
    formsToExport = Array( _
        "frm_MA_Serien_eMail_Auftrag", _
        "frm_MA_VA_Positionszuordnung", _
        "frm_MA_VA_Schnellauswahl", _
        "frm_Menuefuehrung", _
        "frm_Menuefuehrung1", _
        "frm_N_AuswahlMaster", _
        "frm_N_MA_Bewerber_Verarbeitung", _
        "frm_N_MA_VA_Positionszuordnung", _
        "frm_VA_Auftragstamm", _
        "frm_Off_Outlook_aufrufen", _
        "frmTop_DP_MA_Auftrag_Zuo", _
        "frmTop_eMail_MA_ID_NGef", _
        "frmTop_Geo_Verwaltung", _
        "frmTop_MA_Abwesenheitsplanung" _
    )

    Dim i As Long
    For i = LBound(formsToExport) To UBound(formsToExport)
        TryExportOneForm CStr(formsToExport(i)), exportRoot, visited, Report
    Next i
End Sub


' =========================
' PER-FORM EXPORT (Fehler tolerant + Skip)
' =========================
Private Sub TryExportOneForm(ByVal formName As String, ByVal exportRoot As String, ByVal visited As Object, ByVal Report As Collection)
    On Error GoTo EH

    Dim fn As String
    fn = Trim$(formName)
    If Len(fn) = 0 Then Exit Sub

    ' Bereits im Lauf erledigt?
    If visited.Exists("Form:" & fn) Then Exit Sub

    ' Bereits auf Platte exportiert?
    If IsFormAlreadyExported(exportRoot, fn) Then
        visited.Add "Form:" & fn, True
        Exit Sub
    End If

    Collect_And_Export_FormRecursive fn, exportRoot, visited, Report
    Exit Sub

EH:
    Report.Add "ERROR Form '" & fn & "': " & Err.Number & " - " & Err.description
    Err.clear
End Sub


Private Function IsFormAlreadyExported(ByVal exportRoot As String, ByVal formName As String) As Boolean
    Dim baseDir As String
    baseDir = exportRoot & "forms\" & formName & "\"
    ' Mindestkriterium: form_design.txt existiert
    IsFormAlreadyExported = (Dir(baseDir & "form_design.txt") <> "")
End Function


Private Function IsReportAlreadyExported(ByVal exportRoot As String, ByVal reportName As String) As Boolean
    Dim baseDir As String
    baseDir = exportRoot & "reports\" & reportName & "\"
    IsReportAlreadyExported = (Dir(baseDir & "report_design.txt") <> "")
End Function


' =========================
' RECURSIVE EXPORT – FORMS/REPORTS (mit Skip auf Platte)
' =========================
Private Sub Collect_And_Export_FormRecursive(ByVal formName As String, ByVal exportRoot As String, ByVal visited As Object, ByRef Report As Collection)
    On Error GoTo EH

    If Len(formName) = 0 Then Exit Sub

    If visited.Exists("Form:" & formName) Then Exit Sub

    If IsFormAlreadyExported(exportRoot, formName) Then
        visited.Add "Form:" & formName, True
        Exit Sub
    End If

    visited.Add "Form:" & formName, True

    Export_One_Form formName, exportRoot, Report

    ' Open hidden to read subforms/subreports source objects
    DoCmd.OpenForm formName, acNormal, , , acFormReadOnly, acHidden
    Dim frm As Form: Set frm = Forms(formName)

    ' Assets aus dem Form sammeln (best effort)
    GatherAssets_FromForm frm, exportRoot, Report

    Dim c As control
    For Each c In frm.Controls
        If c.ControlType = acSubform Then
            Dim src As String
            src = CStr(GetPropSafe(c, "SourceObject"))

            Dim objType As String, objName As String
            Parse_SourceObject src, objType, objName

            If LCase$(objType) = "form" Then
                TryExportOneForm objName, exportRoot, visited, Report
            ElseIf LCase$(objType) = "report" Then
                Collect_And_Export_ReportRecursive objName, exportRoot, visited, Report
            End If
        End If
    Next c

    DoCmd.Close acForm, formName, acSaveNo
    Exit Sub

EH:
    Report.Add "ERROR Collect_And_Export_FormRecursive(" & formName & "): " & Err.Number & " - " & Err.description
    On Error Resume Next
    DoCmd.Close acForm, formName, acSaveNo
End Sub


Private Sub Collect_And_Export_ReportRecursive(ByVal reportName As String, ByVal exportRoot As String, ByVal visited As Object, ByRef Report As Collection)
    On Error GoTo EH

    If Len(reportName) = 0 Then Exit Sub

    If visited.Exists("Report:" & reportName) Then Exit Sub

    If IsReportAlreadyExported(exportRoot, reportName) Then
        visited.Add "Report:" & reportName, True
        Exit Sub
    End If

    visited.Add "Report:" & reportName, True

    Export_One_Report reportName, exportRoot, Report

    DoCmd.OpenReport reportName, acViewPreview, , , acHidden
    Dim rpt As Report: Set rpt = Reports(reportName)

    ' Assets aus dem Report sammeln (best effort)
    GatherAssets_FromReport rpt, exportRoot, Report

    Dim c As control
    For Each c In rpt.Controls
        If c.ControlType = acSubform Then
            Dim src As String
            src = CStr(GetPropSafe(c, "SourceObject"))

            Dim objType As String, objName As String
            Parse_SourceObject src, objType, objName

            If LCase$(objType) = "report" Then
                Collect_And_Export_ReportRecursive objName, exportRoot, visited, Report
            ElseIf LCase$(objType) = "form" Then
                TryExportOneForm objName, exportRoot, visited, Report
            End If
        End If
    Next c

    DoCmd.Close acReport, reportName, acSaveNo
    Exit Sub

EH:
    Report.Add "ERROR Collect_And_Export_ReportRecursive(" & reportName & "): " & Err.Number & " - " & Err.description
    On Error Resume Next
    DoCmd.Close acReport, reportName, acSaveNo
End Sub


Private Sub Parse_SourceObject(ByVal src As String, ByRef objType As String, ByRef objName As String)
    objType = ""
    objName = ""
    If Len(src) = 0 Then Exit Sub

    Dim parts() As String
    parts = Split(src, ".")
    If UBound(parts) >= 1 Then
        objType = parts(0)
        objName = parts(1)
    End If
End Sub


' =========================
' SINGLE OBJECT EXPORTS
' =========================
Private Sub Export_One_Form(ByVal formName As String, ByVal exportRoot As String, ByRef Report As Collection)
    On Error GoTo EH

    Dim baseDir As String
    baseDir = EnsureDir(exportRoot & "forms\" & formName & "\")

    Export_ObjectText acForm, formName, baseDir & "form_design.txt", Report
    Export_Form_RuntimeSnapshot formName, baseDir, Report
    Exit Sub

EH:
    Report.Add "ERROR Export_One_Form(" & formName & "): " & Err.Number & " - " & Err.description
End Sub


Private Sub Export_One_Report(ByVal reportName As String, ByVal exportRoot As String, ByRef Report As Collection)
    On Error GoTo EH

    Dim baseDir As String
    baseDir = EnsureDir(exportRoot & "reports\" & reportName & "\")

    Export_ObjectText acReport, reportName, baseDir & "report_design.txt", Report
    Exit Sub

EH:
    Report.Add "ERROR Export_One_Report(" & reportName & "): " & Err.Number & " - " & Err.description
End Sub


Private Sub Export_Form_RuntimeSnapshot(ByVal formName As String, ByVal baseDir As String, ByRef Report As Collection)
    On Error GoTo EH

    DoCmd.OpenForm formName, acNormal, , , acFormReadOnly, acHidden
    Dim frm As Form: Set frm = Forms(formName)

    WriteTextFile baseDir & "recordsource.json", _
        "{" & vbCrLf & _
        JsonKV("Name", frm.Name, True) & "," & vbCrLf & _
        JsonKV("RecordSource", Nz(frm.recordSource, ""), True) & "," & vbCrLf & _
        JsonKV("Filter", Nz(frm.filter, ""), True) & "," & vbCrLf & _
        JsonKV("OrderBy", Nz(frm.OrderBy, ""), True) & "," & vbCrLf & _
        JsonKV("AllowEdits", CStr(frm.AllowEdits), False) & "," & vbCrLf & _
        JsonKV("AllowAdditions", CStr(frm.AllowAdditions), False) & "," & vbCrLf & _
        JsonKV("AllowDeletions", CStr(frm.AllowDeletions), False) & vbCrLf & _
        "}"

    WriteTextFile baseDir & "controls.json", Export_Controls_ToJson(frm)
    WriteTextFile baseDir & "subforms.json", Export_Subforms_ToJson(frm)
    WriteTextFile baseDir & "tabs.json", Export_Tabs_ToJson(frm)

    DoCmd.Close acForm, formName, acSaveNo
    Exit Sub

EH:
    Report.Add "ERROR Export_Form_RuntimeSnapshot(" & formName & "): " & Err.Number & " - " & Err.description
    On Error Resume Next
    DoCmd.Close acForm, formName, acSaveNo
End Sub


' =========================
' GLOBAL EXPORTS (alles sinnvolle)
' =========================
Private Sub ExportAllSensibleGlobals(ByVal exportRoot As String, ByVal visited As Object, ByVal Report As Collection)
    On Error Resume Next

    ' Vollständigkeit: alle Reports (falls Buttons welche öffnen)
    Export_All_Reports exportRoot, Report
    If Err.Number <> 0 Then Report.Add "ERROR Export_All_Reports: " & Err.Number & " - " & Err.description: Err.clear

    ' Queries (alles)
    Export_All_Queries exportRoot & "queries\", Report
    If Err.Number <> 0 Then Report.Add "ERROR Export_All_Queries: " & Err.Number & " - " & Err.description: Err.clear

    ' VBA (alles)
    Export_All_VBA exportRoot & "vba\", Report
    If Err.Number <> 0 Then Report.Add "ERROR Export_All_VBA: " & Err.Number & " - " & Err.description: Err.clear

    ' Makros
    Export_All_Macros exportRoot & "macros\", Report
    If Err.Number <> 0 Then Report.Add "ERROR Export_All_Macros: " & Err.Number & " - " & Err.description: Err.clear

    ' Tabellen-Schema (hilft Claude für Bindings/Typen/Validation)
    Export_TableSchema exportRoot & "tables_schema.json", Report
    If Err.Number <> 0 Then Report.Add "ERROR Export_TableSchema: " & Err.Number & " - " & Err.description: Err.clear

    ' References (Outlook/DAO/ODBC etc.)
    Export_References exportRoot & "references.json", Report
    If Err.Number <> 0 Then Report.Add "ERROR Export_References: " & Err.Number & " - " & Err.description: Err.clear

    ' Assets-Manifest final schreiben (wird während Form/Report-Sammlung befüllt)
    FlushAssetsManifest exportRoot, Report
    If Err.Number <> 0 Then Report.Add "ERROR FlushAssetsManifest: " & Err.Number & " - " & Err.description: Err.clear

    On Error GoTo 0

    ' Abschluss: dependency/report
    Write_DependencyMap exportRoot & "dependency_map.json", visited
    Write_Report exportRoot & "report.json", Report
End Sub


Private Function PrepareExportFolders(ByVal Report As Collection) As String
    Dim exportRoot As String
    exportRoot = EnsureDir(EXPORT_ROOT)

    EnsureDir exportRoot & "forms\"
    EnsureDir exportRoot & "reports\"
    EnsureDir exportRoot & "queries\"
    EnsureDir exportRoot & "vba\"
    EnsureDir exportRoot & "vba\modules\"
    EnsureDir exportRoot & "vba\classes\"
    EnsureDir exportRoot & "vba\forms\"
    EnsureDir exportRoot & "macros\"
    EnsureDir exportRoot & "assets\"

    ' Asset manifest init (pro Lauf)
    Assets_Init exportRoot

    PrepareExportFolders = exportRoot
End Function


' =========================
' QUERIES / VBA / MACROS / REPORTS
' =========================
Private Sub Export_All_Reports(ByVal exportRoot As String, ByRef Report As Collection)
    On Error GoTo EH

    Dim ao As AccessObject
    For Each ao In CurrentProject.AllReports
        If Not IsReportAlreadyExported(exportRoot, ao.Name) Then
            EnsureDir exportRoot & "reports\" & ao.Name & "\"
            Export_ObjectText acReport, ao.Name, exportRoot & "reports\" & ao.Name & "\report_design.txt", Report
        End If
    Next ao
    Exit Sub

EH:
    Report.Add "ERROR Export_All_Reports: " & Err.Number & " - " & Err.description
End Sub


Private Sub Export_All_Queries(ByVal outDir As String, ByRef Report As Collection)
    On Error GoTo EH

    outDir = EnsureDir(outDir)

    Dim db As Object
    Set db = CurrentDb()

    Dim qd As Object
    For Each qd In db.QueryDefs
        If Left$(qd.Name, 4) <> "~sq_" Then
            WriteTextFile outDir & SafeFileName(qd.Name) & ".sql", qd.sql
        End If
    Next qd

    Exit Sub
EH:
    Report.Add "ERROR Export_All_Queries: " & Err.Number & " - " & Err.description
End Sub


Private Sub Export_All_VBA(ByVal vbaRoot As String, ByRef Report As Collection)
    On Error GoTo EH

    Dim vbproj As Object, vbcomp As Object
    Set vbproj = Application.vbe.ActiveVBProject

    EnsureDir vbaRoot & "modules\"
    EnsureDir vbaRoot & "classes\"
    EnsureDir vbaRoot & "forms\"

    For Each vbcomp In vbproj.VBComponents
        Select Case vbcomp.Type
            Case 1 ' StdModule
                Export_VBComponent vbcomp, vbaRoot & "modules\" & SafeFileName(vbcomp.Name) & ".bas"
            Case 2 ' ClassModule
                Export_VBComponent vbcomp, vbaRoot & "classes\" & SafeFileName(vbcomp.Name) & ".cls"
            Case 100 ' Document (Form/Report module)
                Export_VBComponent vbcomp, vbaRoot & "forms\" & SafeFileName(vbcomp.Name) & ".bas"
        End Select
    Next vbcomp
    Exit Sub

EH:
    Report.Add "ERROR Export_All_VBA: " & Err.Number & " - " & Err.description & _
               " (Tipp: Trust Center ? 'Zugriff auf VBA-Projektobjektmodell vertrauen')"
End Sub


Private Sub Export_All_Macros(ByVal macroRoot As String, ByRef Report As Collection)
    On Error GoTo EH

    macroRoot = EnsureDir(macroRoot)

    Dim ao As AccessObject
    For Each ao In CurrentProject.AllMacros
        Export_ObjectText acMacro, ao.Name, macroRoot & SafeFileName(ao.Name) & ".txt", Report
    Next ao

    Exit Sub
EH:
    Report.Add "WARN Export_All_Macros: " & Err.Number & " - " & Err.description
End Sub


Private Sub Export_ObjectText(ByVal objType As AcObjectType, ByVal objName As String, ByVal outFile As String, ByRef Report As Collection)
    On Error GoTo EH
    Application.SaveAsText objType, objName, outFile
    Exit Sub
EH:
    Report.Add "ERROR SaveAsText " & objName & ": " & Err.Number & " - " & Err.description
End Sub


Private Sub Export_VBComponent(ByVal vbcomp As Object, ByVal outFile As String)
    On Error Resume Next
    vbcomp.Export outFile
End Sub


' =========================
' TABLE SCHEMA EXPORT (JSON)
' =========================
Private Sub Export_TableSchema(ByVal outFile As String, ByRef Report As Collection)
    On Error GoTo EH

    Dim db As Object: Set db = CurrentDb()
    Dim td As Object, fld As Object, idx As Object, idxFld As Object

    Dim sb As String
    sb = "{""tables"":["
    Dim firstT As Boolean: firstT = True

    For Each td In db.TableDefs
        ' Skip system/hidden tables
        If Left$(td.Name, 4) <> "MSys" And Left$(td.Name, 1) <> "~" Then
            If Not firstT Then sb = sb & ","
            firstT = False

            sb = sb & "{"
            sb = sb & JsonKV("name", td.Name, True) & ","

            ' Fields
            sb = sb & """fields"":["
            Dim firstF As Boolean: firstF = True
            For Each fld In td.fields
                If Not firstF Then sb = sb & ","
                firstF = False
                sb = sb & "{"
                sb = sb & JsonKV("name", fld.Name, True) & ","
                sb = sb & JsonKV("type", CStr(fld.Type), False) & ","
                sb = sb & JsonKV("size", CStr(fld.Size), False) & ","
                sb = sb & JsonKV("required", CStr(fld.Required), False) & ","
                sb = sb & JsonKV("allowZeroLength", CStr(GetDaoPropSafe(fld, "AllowZeroLength")), False)
                sb = sb & "}"
            Next fld
            sb = sb & "],"

            ' Indexes
            sb = sb & """indexes"":["
            Dim firstI As Boolean: firstI = True
            For Each idx In td.Indexes
                If Not firstI Then sb = sb & ","
                firstI = False
                sb = sb & "{"
                sb = sb & JsonKV("name", idx.Name, True) & ","
                sb = sb & JsonKV("primary", CStr(idx.Primary), False) & ","
                sb = sb & JsonKV("unique", CStr(idx.Unique), False) & ","
                sb = sb & """fields"":["
                Dim firstIF As Boolean: firstIF = True
                For Each idxFld In idx.fields
                    If Not firstIF Then sb = sb & ","
                    firstIF = False
                    sb = sb & JsonStr(idxFld.Name)
                Next idxFld
                sb = sb & "]}"
            Next idx
            sb = sb & "]"

            sb = sb & "}"
        End If
    Next td

    sb = sb & "]}"
    WriteTextFile outFile, sb
    Exit Sub

EH:
    Report.Add "ERROR Export_TableSchema: " & Err.Number & " - " & Err.description
End Sub


Private Function GetDaoPropSafe(ByVal daoObj As Object, ByVal propName As String) As Variant
    On Error GoTo EH
    GetDaoPropSafe = daoObj.Properties(propName).Value
    Exit Function
EH:
    GetDaoPropSafe = Null
End Function


' =========================
' REFERENCES EXPORT (JSON)
' =========================
Private Sub Export_References(ByVal outFile As String, ByRef Report As Collection)
    On Error GoTo EH

    Dim vbproj As Object
    Set vbproj = Application.vbe.ActiveVBProject

    Dim refs As Object
    Set refs = vbproj.References

    Dim sb As String
    sb = "{""references"":["
    Dim i As Long
    For i = 1 To refs.Count
        Dim r As Object
        Set r = refs.item(i)
        If i > 1 Then sb = sb & ","
        sb = sb & "{"
        sb = sb & JsonKV("name", Nz(r.Name, ""), True) & ","
        sb = sb & JsonKV("description", Nz(r.description, ""), True) & ","
        sb = sb & JsonKV("fullPath", Nz(r.fullPath, ""), True) & ","
        sb = sb & JsonKV("guid", Nz(r.guid, ""), True) & ","
        sb = sb & JsonKV("major", CStr(r.Major), False) & ","
        sb = sb & JsonKV("minor", CStr(r.Minor), False) & ","
        sb = sb & JsonKV("isBroken", CStr(r.IsBroken), False)
        sb = sb & "}"
    Next i
    sb = sb & "]}"
    WriteTextFile outFile, sb
    Exit Sub

EH:
    Report.Add "ERROR Export_References: " & Err.Number & " - " & Err.description & _
               " (Tipp: Trust Center ? 'Zugriff auf VBA-Projektobjektmodell vertrauen')"
End Sub


' =========================
' ASSETS (Manifest + Copy files if referenced)
' =========================
' Wir sammeln Assets während Form/Report-Export in einer globalen Collection



Private Sub Assets_Init(ByVal exportRoot As String)
    Set gAssets = New Collection

    If Right$(exportRoot, 1) <> "\" Then exportRoot = exportRoot & "\"
    gAssetsRoot = exportRoot & "assets\"

    If Dir(gAssetsRoot, vbDirectory) = "" Then
        MkDirRecursive gAssetsRoot
    End If
End Sub

Private Sub GatherAssets_FromForm(ByVal frm As Form, ByVal exportRoot As String, ByRef Report As Collection)
    On Error Resume Next

    Dim c As control
    For Each c In frm.Controls
        GatherAsset_FromControl "Form", frm.Name, c, exportRoot, Report
    Next c
End Sub

Private Sub GatherAssets_FromReport(ByVal rpt As Report, ByVal exportRoot As String, ByRef Report As Collection)
    On Error Resume Next

    Dim c As control
    For Each c In rpt.Controls
        GatherAsset_FromControl "Report", rpt.Name, c, exportRoot, Report
    Next c
End Sub

Private Sub GatherAsset_FromControl(ByVal containerType As String, ByVal containerName As String, ByVal c As control, ByVal exportRoot As String, ByRef Report As Collection)
    On Error Resume Next

    Dim pic As String
    pic = CStr(GetPropSafe(c, "Picture"))

    If Len(Trim$(pic)) = 0 Then Exit Sub

    Dim entry As String
    entry = "{""containerType"":" & JsonStr(containerType) & _
            ",""containerName"":" & JsonStr(containerName) & _
            ",""controlName"":" & JsonStr(c.Name) & _
            ",""controlType"":" & JsonStr(CStr(c.ControlType)) & _
            ",""picture"":" & JsonStr(pic) & _
            ",""copiedTo"":" & JsonStr("") & _
            ",""note"":" & JsonStr("") & "}"

    ' Versuche Datei zu kopieren, wenn es wie ein Pfad aussieht
    Dim copiedTo As String
    copiedTo = TryCopyAssetFile(pic, exportRoot, Report)

    If Len(copiedTo) > 0 Then
        entry = "{""containerType"":" & JsonStr(containerType) & _
                ",""containerName"":" & JsonStr(containerName) & _
                ",""controlName"":" & JsonStr(c.Name) & _
                ",""controlType"":" & JsonStr(CStr(c.ControlType)) & _
                ",""picture"":" & JsonStr(pic) & _
                ",""copiedTo"":" & JsonStr(copiedTo) & _
                ",""note"":" & JsonStr("file copied") & "}"
    Else
        ' Könnte embedded oder invalid sein
        entry = "{""containerType"":" & JsonStr(containerType) & _
                ",""containerName"":" & JsonStr(containerName) & _
                ",""controlName"":" & JsonStr(c.Name) & _
                ",""controlType"":" & JsonStr(CStr(c.ControlType)) & _
                ",""picture"":" & JsonStr(pic) & _
                ",""copiedTo"":" & JsonStr("") & _
                ",""note"":" & JsonStr("not copied (embedded or path not found)") & "}"
    End If

    gAssets.Add entry
End Sub

Private Function TryCopyAssetFile(ByVal pictureValue As String, ByVal exportRoot As String, ByRef Report As Collection) As String
    On Error GoTo EH

    Dim p As String
    p = Trim$(pictureValue)

    ' Manche Access-Picture-Werte sind nur Dateinamen oder relative Pfade.
    ' Wir kopieren nur, wenn eine Datei existiert.
    If Len(p) = 0 Then
        TryCopyAssetFile = ""
        Exit Function
    End If

    If Dir(p) = "" Then
        TryCopyAssetFile = ""
        Exit Function
    End If

    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")

    Dim fileName As String
    fileName = fso.GetFileName(p)

    Dim dest As String
    dest = EnsureDir(exportRoot & "assets\") & fileName

    ' Skip wenn schon vorhanden
    If Dir(dest) = "" Then
        fso.CopyFile p, dest, True
    End If

    TryCopyAssetFile = "assets\" & fileName
    Exit Function

EH:
    Report.Add "WARN TryCopyAssetFile: " & Err.Number & " - " & Err.description & " (" & pictureValue & ")"
    TryCopyAssetFile = ""
End Function

Private Sub FlushAssetsManifest(ByVal exportRoot As String, ByRef Report As Collection)
    On Error GoTo EH

    Dim outFile As String
    outFile = exportRoot & "assets_manifest.json"

    Dim sb As String
    sb = "{""assets"":["
    Dim i As Long
    If Not (gAssets Is Nothing) Then
        For i = 1 To gAssets.Count
            If i > 1 Then sb = sb & ","
            sb = sb & CStr(gAssets(i))
        Next i
    End If
    sb = sb & "]}"

    WriteTextFile outFile, sb
    Exit Sub

EH:
    Report.Add "ERROR FlushAssetsManifest: " & Err.Number & " - " & Err.description
End Sub


' =========================
' JSON SNAPSHOTS (Controls/Tabs/Subforms)
' =========================
Private Function Export_Controls_ToJson(ByVal frm As Form) As String
    Dim sb As String, i As Long
    sb = "{" & vbCrLf
    sb = sb & """Form"": " & JsonStr(frm.Name) & "," & vbCrLf
    sb = sb & """InsideWidth"": " & frm.InsideWidth & "," & vbCrLf
    sb = sb & """InsideHeight"": " & frm.InsideHeight & "," & vbCrLf
    sb = sb & """Controls"": [" & vbCrLf

    Dim c As control
    i = 0
    For Each c In frm.Controls
        If i > 0 Then sb = sb & "," & vbCrLf
        sb = sb & Control_ToJson(c)
        i = i + 1
    Next c

    sb = sb & vbCrLf & "]" & vbCrLf & "}"
    Export_Controls_ToJson = sb
End Function


Private Function Control_ToJson(ByVal c As control) As String
    On Error Resume Next

    Dim sb As String
    sb = "{"

    sb = sb & JsonKV("Name", c.Name, True) & ","
    sb = sb & JsonKV("ControlType", CStr(c.ControlType), False) & ","
    sb = sb & JsonKV("Left", CStr(c.Left), False) & ","
    sb = sb & JsonKV("Top", CStr(c.Top), False) & ","
    sb = sb & JsonKV("Width", CStr(c.width), False) & ","
    sb = sb & JsonKV("Height", CStr(c.height), False) & ","
    sb = sb & JsonKV("Visible", CStr(GetPropSafe(c, "Visible")), False) & ","
    sb = sb & JsonKV("Enabled", CStr(GetPropSafe(c, "Enabled")), False) & ","
    sb = sb & JsonKV("Locked", CStr(GetPropSafe(c, "Locked")), False) & ","
    sb = sb & JsonKV("TabIndex", CStr(GetPropSafe(c, "TabIndex")), False) & ","
    sb = sb & JsonKV("ControlSource", CStr(GetPropSafe(c, "ControlSource")), True) & ","
    sb = sb & JsonKV("RowSource", CStr(GetPropSafe(c, "RowSource")), True) & ","
    sb = sb & JsonKV("RecordSource", CStr(GetPropSafe(c, "RecordSource")), True) & ","
    sb = sb & JsonKV("LinkMasterFields", CStr(GetPropSafe(c, "LinkMasterFields")), True) & ","
    sb = sb & JsonKV("LinkChildFields", CStr(GetPropSafe(c, "LinkChildFields")), True) & ","
    sb = sb & JsonKV("BackColor", CStr(GetPropSafe(c, "BackColor")), False) & ","
    sb = sb & JsonKV("ForeColor", CStr(GetPropSafe(c, "ForeColor")), False) & ","
    sb = sb & JsonKV("BorderColor", CStr(GetPropSafe(c, "BorderColor")), False) & ","
    sb = sb & JsonKV("SpecialEffect", CStr(GetPropSafe(c, "SpecialEffect")), False) & ","
    sb = sb & JsonKV("FontName", CStr(GetPropSafe(c, "FontName")), True) & ","
    sb = sb & JsonKV("FontSize", CStr(GetPropSafe(c, "FontSize")), False) & ","
    sb = sb & JsonKV("FontBold", CStr(GetPropSafe(c, "FontBold")), False) & ","
    sb = sb & JsonKV("FontItalic", CStr(GetPropSafe(c, "FontItalic")), False) & ","
    sb = sb & JsonKV("Caption", CStr(GetPropSafe(c, "Caption")), True) & ","
    sb = sb & JsonKV("Picture", CStr(GetPropSafe(c, "Picture")), True) & ","
    sb = sb & """Events"": " & Export_Control_Events(c)

    sb = sb & "}"
    Control_ToJson = sb
End Function


Private Function Export_Control_Events(ByVal c As control) As String
    Dim sb As String
    sb = "{"
    sb = sb & JsonKV("OnClick", CStr(GetPropSafe(c, "OnClick")), True) & ","
    sb = sb & JsonKV("OnDblClick", CStr(GetPropSafe(c, "OnDblClick")), True) & ","
    sb = sb & JsonKV("OnChange", CStr(GetPropSafe(c, "OnChange")), True) & ","
    sb = sb & JsonKV("OnEnter", CStr(GetPropSafe(c, "OnEnter")), True) & ","
    sb = sb & JsonKV("OnExit", CStr(GetPropSafe(c, "OnExit")), True) & ","
    sb = sb & JsonKV("BeforeUpdate", CStr(GetPropSafe(c, "BeforeUpdate")), True) & ","
    sb = sb & JsonKV("AfterUpdate", CStr(GetPropSafe(c, "AfterUpdate")), True)
    sb = sb & "}"
    Export_Control_Events = sb
End Function


Private Function Export_Subforms_ToJson(ByVal frm As Form) As String
    Dim sb As String, i As Long
    sb = "{""Form"": " & JsonStr(frm.Name) & ", ""Subforms"": ["
    i = 0

    Dim c As control
    For Each c In frm.Controls
        If c.ControlType = acSubform Then
            If i > 0 Then sb = sb & ","
            sb = sb & "{"
            sb = sb & JsonKV("Name", c.Name, True) & ","
            sb = sb & JsonKV("SourceObject", CStr(GetPropSafe(c, "SourceObject")), True) & ","
            sb = sb & JsonKV("LinkMasterFields", CStr(GetPropSafe(c, "LinkMasterFields")), True) & ","
            sb = sb & JsonKV("LinkChildFields", CStr(GetPropSafe(c, "LinkChildFields")), True)
            sb = sb & "}"
            i = i + 1
        End If
    Next c

    sb = sb & "]}"
    Export_Subforms_ToJson = sb
End Function


Private Function Export_Tabs_ToJson(ByVal frm As Form) As String
    Dim sb As String, i As Long, j As Long
    sb = "{""Form"": " & JsonStr(frm.Name) & ", ""TabControls"": ["
    i = 0

    Dim c As control
    For Each c In frm.Controls
        If c.ControlType = acTabCtl Then
            If i > 0 Then sb = sb & ","
            sb = sb & "{"
            sb = sb & JsonKV("Name", c.Name, True) & ","
            sb = sb & """Pages"": ["
            j = 0
            Dim p As Page
            For Each p In c.Pages
                If j > 0 Then sb = sb & ","
                sb = sb & "{"
                sb = sb & JsonKV("Name", p.Name, True) & ","
                sb = sb & JsonKV("Caption", Nz(p.caption, ""), True)
                sb = sb & "}"
                j = j + 1
            Next p
            sb = sb & "]}"
            i = i + 1
        End If
    Next c

    sb = sb & "]}"
    Export_Tabs_ToJson = sb
End Function


' =========================
' DEP MAP + FILE HELPERS
' =========================
Private Sub Write_DependencyMap(ByVal filePath As String, ByVal visited As Object)
    Dim sb As String, k As Variant, first As Boolean
    sb = "{""visited"":["
    first = True
    For Each k In visited.Keys
        If Not first Then sb = sb & ","
        sb = sb & JsonStr(CStr(k))
        first = False
    Next k
    sb = sb & "]}"
    WriteTextFile filePath, sb
End Sub


Private Function EnsureDir(ByVal path As String) As String
    If Right$(path, 1) <> "\" Then path = path & "\"
    If Dir(path, vbDirectory) = "" Then MkDirRecursive path
    EnsureDir = path
End Function

Private Sub MkDirRecursive(ByVal fullPath As String)
    Dim parts() As String, i As Long, cur As String
    parts = Split(fullPath, "\")
    cur = parts(0) & "\"
    For i = 1 To UBound(parts)
        If parts(i) <> "" Then
            cur = cur & parts(i) & "\"
            If Dir(cur, vbDirectory) = "" Then MkDir cur
        End If
    Next i
End Sub

Private Sub WriteTextFile(ByVal filePath As String, ByVal content As String)
    Dim f As Integer
    f = FreeFile
    Open filePath For Output As #f
    Print #f, content
    Close #f
End Sub

Private Function SafeFileName(ByVal s As String) As String
    Dim bad As Variant, i As Long
    bad = Array("\", "/", ":", "*", "?", """", "<", ">", "|")
    For i = LBound(bad) To UBound(bad)
        s = Replace(s, bad(i), "_")
    Next i
    SafeFileName = s
End Function

Private Function GetPropSafe(ByVal obj As Object, ByVal propName As String) As Variant
    On Error GoTo EH
    GetPropSafe = CallByName(obj, propName, VbGet)
    Exit Function
EH:
    GetPropSafe = Null
End Function

Private Function Nz(ByVal v As Variant, ByVal fallback As Variant) As Variant
    If IsNull(v) Then
        Nz = fallback
    Else
        Nz = v
    End If
End Function


' =========================
' JSON HELPERS
' =========================
Private Function JsonStr(ByVal s As String) As String
    JsonStr = """" & JsonEscape(s) & """"
End Function

Private Function JsonEscape(ByVal s As String) As String
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCrLf, "\n")
    s = Replace(s, vbCr, "\n")
    s = Replace(s, vbLf, "\n")
    JsonEscape = s
End Function

Private Function JsonKV(ByVal key As String, ByVal val As String, ByVal isString As Boolean) As String
    If isString Then
        JsonKV = """" & JsonEscape(key) & """: " & JsonStr(val)
    Else
        If Len(val) = 0 Then
            JsonKV = """" & JsonEscape(key) & """: null"
        ElseIf LCase$(val) = "true" Or LCase$(val) = "false" Then
            JsonKV = """" & JsonEscape(key) & """: " & LCase$(val)
        ElseIf IsNumeric(val) Then
            JsonKV = """" & JsonEscape(key) & """: " & val
        Else
            JsonKV = """" & JsonEscape(key) & """: " & JsonStr(val)
        End If
    End If
End Function


Private Sub Write_Report(ByVal filePath As String, ByVal Report As Collection)
    Dim sb As String, i As Long
    sb = "{""items"":["
    For i = 1 To Report.Count
        If i > 1 Then sb = sb & ","
        sb = sb & JsonStr(CStr(Report(i)))
    Next i
    sb = sb & "]}"
    WriteTextFile filePath, sb
End Sub


