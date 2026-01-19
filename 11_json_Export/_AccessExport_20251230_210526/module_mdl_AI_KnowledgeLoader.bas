'=== mdl_AI_KnowledgeLoader ==============================================
Option Compare Database
Option Explicit

' --- Modulzustand / Caches ---
Private mLoaded     As Boolean
Private mTables     As Object   ' Scripting.Dictionary (Set)
Private mForms      As Object   ' Scripting.Dictionary (Set)
Private mDeps       As Object   ' Map: object -> ArrayList(deps)
Private mFormRS     As Object   ' Map: form -> recordsource
Private mFormCtrls  As Object   ' Map: form -> ArrayList(control names)
Private mRawJSON    As String   ' Roh-JSON/Volltext

'==================== Öffentliche API ====================

Public Function AIK_EnsureLoaded() As Boolean
    On Error GoTo EH
    If mLoaded Then AIK_EnsureLoaded = True: Exit Function
    AIK_InitStores
    AIK_LoadAll
    mLoaded = True
    AIK_EnsureLoaded = True
    Exit Function
EH:
    mLoaded = False
    AIK_Log "AIK_EnsureLoaded ERROR: " & Err.Number & " / " & Err.description
End Function

Public Function AIK_TableExists(ByVal tbl As String) As Boolean
    If Not mLoaded Then Call AIK_EnsureLoaded
    AIK_TableExists = (mTables.exists(LCase$(Trim$(tbl))))
End Function

Public Function AIK_FormExists(ByVal frm As String) As Boolean
    If Not mLoaded Then Call AIK_EnsureLoaded
    AIK_FormExists = (mForms.exists(LCase$(Trim$(frm))))
End Function

Public Function AIK_GetFormRecordSource(ByVal frm As String) As String
    If Not mLoaded Then Call AIK_EnsureLoaded
    frm = LCase$(Trim$(frm))
    If mFormRS.exists(frm) Then
        AIK_GetFormRecordSource = mFormRS(frm)
    Else
        AIK_GetFormRecordSource = ""
    End If
End Function

' Gibt Komma-Liste bekannter Controls eines Formulars zurück
Public Function AIK_ListFormControls(ByVal frm As String) As String
    If Not mLoaded Then Call AIK_EnsureLoaded
    frm = LCase$(Trim$(frm))
    If mFormCtrls.exists(frm) Then
        AIK_ListFormControls = Join(mFormCtrls(frm).ToArray, ",")
    Else
        AIK_ListFormControls = ""
    End If
End Function

' Abhängigkeiten als Komma-Liste
Public Function AIK_GetDependencies(ByVal objName As String) As String
    If Not mLoaded Then Call AIK_EnsureLoaded
    objName = LCase$(Trim$(objName))
    If mDeps.exists(objName) Then
        AIK_GetDependencies = Join(mDeps(objName).ToArray, ",")
    Else
        AIK_GetDependencies = ""
    End If
End Function

' Grobe Volltextsuche
Public Function AIK_Search(ByVal needle As String) As Boolean
    If Not mLoaded Then Call AIK_EnsureLoaded
    needle = LCase$(Trim$(needle))
    AIK_Search = (InStr(1, mRawJSON, needle, vbTextCompare) > 0) _
                 Or mTables.exists(needle) _
                 Or mForms.exists(needle)
End Function

' Diagnose
Public Sub AIK_DumpSummary()
    If Not mLoaded Then Call AIK_EnsureLoaded
    Debug.Print "=== AIK SUMMARY ==="
    Debug.Print "Tables:   "; mTables.Count
    Debug.Print "Forms:    "; mForms.Count
    Debug.Print "Deps:     "; mDeps.Count
    Debug.Print "FormRS:   "; mFormRS.Count
    Debug.Print "FormCtrl: "; mFormCtrls.Count
    AIK_Log "AIK Summary: TBL=" & mTables.Count & " FORM=" & mForms.Count & " DEP=" & mDeps.Count
End Sub

'==================== Pfade / Logging ====================

Private Function AIK_Root() As String
    AIK_Root = Environ$("USERPROFILE") & "\Documents\000_Runner"
End Function

Private Function AIK_KnowledgeDir() As String
    AIK_KnowledgeDir = AIK_Root() & "\Consys_Knowledge\FE_Abhaengigkeiten"
End Function

Private Function AIK_LogFile() As String
    AIK_LogFile = AIK_Root() & "\logs\access_runner_log.txt"
End Function

Private Sub AIK_EnsureDir(ByVal p As String)
    On Error Resume Next
    If Len(Dir(p, vbDirectory)) = 0 Then MkDir p
End Sub

Private Sub AIK_Log(ByVal msg As String)
    On Error Resume Next
    AIK_EnsureDir AIK_Root()
    AIK_EnsureDir AIK_Root() & "\logs"
    Dim f As Integer: f = FreeFile
    Open AIK_LogFile For Append As #f
        Print #f, Format(Now, "yyyy-mm-dd hh:nn:ss"); "  - "; msg
    Close #f
End Sub

Private Function AIK_ReadFile(ByVal p As String) As String
    On Error GoTo EH
    Dim h As Integer, l As Long, b() As Byte, i As Long, s As String
    If Len(Dir(p)) = 0 Then Exit Function
    h = FreeFile
    Open p For Binary As #h
        l = LOF(h)
        If l > 0 Then
            ReDim b(1 To l)
            Get #h, , b
        End If
    Close #h
    For i = LBound(b) To UBound(b)
        If b(i) <> 0 Then s = s & Chr$(b(i))
    Next
    s = Replace(s, "ï»¿", "")
    s = Replace(s, ChrW$(&HFEFF), "")
    AIK_ReadFile = s
    Exit Function
EH:
    AIK_ReadFile = ""
End Function

'==================== Init / Laden ====================

Private Sub AIK_InitStores()
    Set mTables = CreateObject("Scripting.Dictionary")
    Set mForms = CreateObject("Scripting.Dictionary")
    Set mDeps = CreateObject("Scripting.Dictionary")
    Set mFormRS = CreateObject("Scripting.Dictionary")
    Set mFormCtrls = CreateObject("Scripting.Dictionary")
    mTables.RemoveAll: mForms.RemoveAll: mDeps.RemoveAll
    mFormRS.RemoveAll: mFormCtrls.RemoveAll
    mRawJSON = ""
End Sub

' Auto-Fallback + Laden aller Quellen
Private Sub AIK_LoadAll()
    On Error Resume Next
    Dim base As String: base = AIK_KnowledgeDir()
    Dim lex As String:  lex = base & "\FormLexikon.md"

    ' Lexikon automatisch erzeugen, wenn fehlend/zu klein
    If Len(Dir(lex)) = 0 Or (fileLen(lex) < 50) Then
        AIK_BuildFormLexikon
    Else
        ' Caches zumindest initialisieren
        If mFormRS Is Nothing Then Set mFormRS = CreateObject("Scripting.Dictionary")
        If mFormCtrls Is Nothing Then Set mFormCtrls = CreateObject("Scripting.Dictionary")
    End If

    ' 1) JSON
    mRawJSON = AIK_ReadFile(base & "\Enhanced_Knowledge.json")
    AIK_ParseNamesFromJSON mRawJSON

    ' 2) Dependencies
    AIK_LoadDependencies AIK_ReadFile(base & "\DependencyLinks.txt")
    AIK_LoadDependencies AIK_ReadFile(base & "\DependencyObjects.txt")

    ' 3) FormLexikon aus Datei (zur Sicherheit nachziehen)
    AIK_LoadFormLexikon AIK_ReadFile(lex)

    AIK_Log "AIK loaded. TBL=" & mTables.Count & " FORM=" & mForms.Count & " DEP=" & mDeps.Count
End Sub

'==================== Builder / Scanner ====================

' Rekursiv Controls einsammeln (inkl. Subforms)
Private Sub AIK_CollectControls(ByVal f As Form, ByVal list As Object, ByVal prefix As String)
    On Error Resume Next
    Dim c As control
    For Each c In f.Controls
        Select Case c.ControlType
            Case acTextBox, acComboBox, acListBox, acCommandButton, _
                 acCheckBox, acOptionButton, acToggleButton, acTabCtl, _
                 acPage, acLabel, acSubform
                Dim nm As String: nm = LCase$(prefix & c.Name)
                If Len(nm) > 0 Then If list.IndexOf(nm) < 0 Then list.Add nm
                If c.ControlType = acSubform Then
                    If Not c.Form Is Nothing Then
                        AIK_CollectControls c.Form, list, nm & "!"
                    End If
                End If
        End Select
    Next
End Sub

' Alle Forms scannen und direkt in Caches schreiben
Private Sub AIK_ScanFormsIntoCaches()
    On Error GoTo EH
    Dim i As Long, ao As AccessObject, frmName As String, wasOpen As Boolean

    Application.Echo False
    DoCmd.SetWarnings False

    If mFormRS Is Nothing Then Set mFormRS = CreateObject("Scripting.Dictionary")
    If mFormCtrls Is Nothing Then Set mFormCtrls = CreateObject("Scripting.Dictionary")

    For i = 0 To CurrentProject.AllForms.Count - 1
        Set ao = CurrentProject.AllForms(i)
        frmName = ao.Name
        If Len(frmName) = 0 Then GoTo CONT

        wasOpen = (SysCmd(acSysCmdGetObjectState, acForm, frmName) And acObjStateOpen) <> 0
        If Not wasOpen Then
            DoCmd.OpenForm frmName, acDesign, , , , acHidden
        End If

        On Error Resume Next
        mFormRS(LCase$(frmName)) = Nz(forms(frmName).recordSource & "", "")
        On Error GoTo EH

        Dim al As Object: Set al = CreateObject("System.Collections.ArrayList")
        AIK_CollectControls forms(frmName), al, ""
        mFormCtrls(LCase$(frmName)) = al

        If Not mForms.exists(LCase$(frmName)) Then mForms.Add LCase$(frmName), True

        If Not wasOpen Then
            DoCmd.Close acForm, frmName, acSaveNo
        End If
CONT:
    Next i

    DoCmd.SetWarnings True
    Application.Echo True
    Exit Sub
EH:
    DoCmd.SetWarnings True
    Application.Echo True
    AIK_Log "AIK_ScanFormsIntoCaches ERROR: " & Err.Number & " / " & Err.description
End Sub

' FormLexikon neu erzeugen (und Caches füllen)
Public Sub AIK_BuildFormLexikon()
    On Error GoTo EH
    Dim base As String, fn As String, f As Integer, k As Variant, lst As Object

    base = AIK_KnowledgeDir()
    AIK_EnsureDir AIK_Root()
    AIK_EnsureDir AIK_Root() & "\Consys_Knowledge"
    AIK_EnsureDir base

    ' frisch scannen
    If mFormRS Is Nothing Then Set mFormRS = CreateObject("Scripting.Dictionary")
    If mFormCtrls Is Nothing Then Set mFormCtrls = CreateObject("Scripting.Dictionary")
    mFormRS.RemoveAll: mFormCtrls.RemoveAll

    AIK_ScanFormsIntoCaches

    ' Datei schreiben
    fn = base & "\FormLexikon.md"
    f = FreeFile
    Open fn For Output As #f
        Print #f, "# FormLexikon (auto-generated)"
        Print #f, ""
        For Each k In mFormRS.Keys
            Print #f, "Form: " & k
            Print #f, "RecordSource: " & mFormRS(k)
            Set lst = mFormCtrls(k)
            If Not lst Is Nothing Then
                If lst.Count > 0 Then
                    Print #f, "Controls: " & Join(lst.ToArray, ", ")
                Else
                    Print #f, "Controls: "
                End If
            Else
                Print #f, "Controls: "
            End If
            Print #f, ""
        Next k
    Close #f

    AIK_Log "AIK_BuildFormLexikon OK: " & fn & " (Forms=" & mFormRS.Count & ")"
    Exit Sub
EH:
    AIK_Log "AIK_BuildFormLexikon ERROR: " & Err.Number & " / " & Err.description
End Sub

'==================== Parser für Dateien ====================

' leichte JSON-Namenernte (Heuristik)
Private Sub AIK_ParseNamesFromJSON(ByVal js As String)
    On Error Resume Next
    Dim l As Long: l = Len(js)
    If l = 0 Then Exit Sub

    Dim i As Long, token As String, inQuote As Boolean, buf As String
    For i = 1 To l
        token = Mid$(js, i, 1)
        If token = """" Then
            inQuote = Not inQuote
            If Not inQuote Then
                AIK_ConsiderName buf
                buf = ""
            End If
        ElseIf inQuote Then
            buf = buf & token
        End If
    Next
End Sub

Private Sub AIK_ConsiderName(ByVal nm As String)
    On Error Resume Next
    Dim k As String: k = LCase$(Trim$(nm))
    If Len(k) = 0 Then Exit Sub
    If Left$(k, 4) = "tbl_" Then If Not mTables.exists(k) Then mTables.Add k, True
    If Left$(k, 4) = "frm_" Then If Not mForms.exists(k) Then mForms.Add k, True
End Sub

' Dependencies: akzeptiert "A -> B,C" und "A: B,C"
Private Sub AIK_LoadDependencies(ByVal txt As String)
    On Error Resume Next
    If Len(Trim$(txt)) = 0 Then Exit Sub

    Dim lines() As String, i As Long, ln As String
    lines = Split(Replace(Replace(txt, vbCr, vbLf), vbLf & vbLf, vbLf), vbLf)

    For i = LBound(lines) To UBound(lines)
        ln = Trim$(lines(i))
        If Len(ln) = 0 Then GoTo CONT

        Dim lhs As String, rhs As String, p As Long

        p = InStr(1, ln, "->", vbTextCompare)
        If p > 0 Then
            lhs = Trim$(Left$(ln, p - 1))
            rhs = Trim$(Mid$(ln, p + 2))
            AIK_AddDeps lhs, rhs
            GoTo CONT
        End If

        p = InStr(1, ln, ":", vbTextCompare)
        If p > 0 Then
            lhs = Trim$(Left$(ln, p - 1))
            rhs = Trim$(Mid$(ln, p + 1))
            AIK_AddDeps lhs, rhs
            GoTo CONT
        End If
CONT:
    Next i
End Sub

Private Sub AIK_AddDeps(ByVal lhs As String, ByVal rhsList As String)
    On Error Resume Next
    Dim a As Variant, i As Long, key As String
    key = LCase$(Replace(lhs, " ", ""))
    If Not mDeps.exists(key) Then mDeps.Add key, AIK_NewArrayList()

    a = Split(rhsList, ",")
    For i = LBound(a) To UBound(a)
        Dim item As String
        item = LCase$(Trim$(a(i)))
        item = Replace(item, " ", "")
        If Len(item) > 0 Then AIK_ArrayListAddUnique mDeps(key), item
    Next
End Sub

' FormLexikon.md einlesen (falls schon vorhanden)
Private Sub AIK_LoadFormLexikon(ByVal txt As String)
    On Error Resume Next
    If Len(Trim$(txt)) = 0 Then Exit Sub

    Dim lines() As String, i As Long, ln As String, curForm As String
    lines = Split(Replace(Replace(txt, vbCr, vbLf), vbLf & vbLf, vbLf), vbLf)

    For i = LBound(lines) To UBound(lines)
        ln = Trim$(lines(i))
        If Len(ln) = 0 Then GoTo CONT

        If LCase$(Left$(ln, 5)) = "form:" Or LCase$(Left$(ln, 6)) = "form =" Then
            curForm = LCase$(Trim$(Mid$(ln, InStr(ln, ":") + 1)))
            If Not mForms.exists(curForm) And Left$(curForm, 4) = "frm_" Then mForms(curForm) = True
            GoTo CONT
        End If
        If Left$(LCase$(ln), 4) = "frm_" Then
            curForm = LCase$(ln)
            If Not mForms.exists(curForm) Then mForms(curForm) = True
            GoTo CONT
        End If

        If InStr(1, LCase$(ln), "recordsource", vbTextCompare) > 0 And curForm <> "" Then
            Dim p As Long: p = InStr(1, ln, ":", vbTextCompare)
            If p > 0 Then mFormRS(curForm) = Trim$(Mid$(ln, p + 1))
            GoTo CONT
        End If

        If InStr(1, LCase$(ln), "controls", vbTextCompare) > 0 And curForm <> "" Then
            Dim listStr As String, arr As Variant, j As Long
            listStr = Trim$(Mid$(ln, InStr(1, ln, ":") + 1))
            arr = Split(listStr, ",")
            Dim col As Object: Set col = AIK_NewArrayList
            For j = LBound(arr) To UBound(arr)
                Dim c As String: c = LCase$(Trim$(arr(j)))
                If Len(c) > 0 Then AIK_ArrayListAddUnique col, c
            Next
            mFormCtrls(curForm) = col
            GoTo CONT
        End If
CONT:
    Next i
End Sub

'==================== kleine Hilfen ====================

Private Function AIK_NewArrayList() As Object
    Set AIK_NewArrayList = CreateObject("System.Collections.ArrayList")
End Function

Private Sub AIK_ArrayListAddUnique(ByVal arr As Object, ByVal Value As String)
    On Error Resume Next
    If arr Is Nothing Then Exit Sub
    If arr.IndexOf(Value) < 0 Then arr.Add Value
End Sub

'=== END mdl_AI_KnowledgeLoader ==========================================