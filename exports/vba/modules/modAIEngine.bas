Attribute VB_Name = "modAIEngine"
'=== mdl_AccessRunner =======================================================
Option Compare Database
Option Explicit

' --- Tabellen-Konstanten ---
Private Const TBL_AUF  As String = "tbl_VA_Auftragstamm"
Private Const TBL_ZUO  As String = "tbl_ma_va_zuordnung"
Private Const TBL_TAGE As String = "tbl_VA_AnzTage"

' --- Versionssichere Section-Konstanten für Formulare ---
Private Const AI_SEC_DETAIL      As Integer = 0
Private Const AI_SEC_FORMHEADER  As Integer = 1
Private Const AI_SEC_FORMFOOTER  As Integer = 2

' =======================================================================
' Pfade/Helfer
' =======================================================================
Private Function AI_GetRunnerRoot() As String
    AI_GetRunnerRoot = Environ$("USERPROFILE") & "\Documents\000_Runner"
End Function

Private Function AI_GetInboxPath() As String
    AI_GetInboxPath = AI_GetRunnerRoot() & "\inbox"
End Function

Private Function AI_GetLogFile() As String
    AI_GetLogFile = AI_GetRunnerRoot() & "\logs\access_runner_log.txt"
End Function

Private Sub AI_EnsureDir(ByVal p As String)
    On Error Resume Next
    If Len(Dir(p, vbDirectory)) = 0 Then MkDir p
End Sub

Private Sub AI_SafeDelete(ByVal p As String)
    On Error Resume Next
    If Len(Dir(p)) > 0 Then Kill p
End Sub

' =======================================================================
' Form-Utils
' =======================================================================
Private Function AI_IsFormOpen(ByVal formName As String) As Boolean
    On Error Resume Next
    AI_IsFormOpen = (SysCmd(acSysCmdGetObjectState, acForm, formName) And acObjStateOpen) <> 0
End Function

Private Sub AI_ReopenIfClosed(ByVal formName As String)
    On Error Resume Next
    If Not AI_IsFormOpen(formName) Then
        DoCmd.OpenForm formName, acNormal
    End If
End Sub

Private Sub AI_EnsureHost()
    On Error Resume Next
    If Not AI_IsFormOpen("frm_AIRunner_Host") Then
        DoCmd.OpenForm "frm_AIRunner_Host", , , , , acHidden
        Forms("frm_AIRunner_Host").TimerInterval = 10000
        Forms("frm_AIRunner_Host").OnTimer = "=AI_ProcessInbox()"
    End If
End Sub

' =======================================================================
' Logging
' =======================================================================
Private Sub AI_Log(ByVal msg As String)
    On Error Resume Next
    Dim f As Integer, p As String
    p = AI_GetLogFile()
    AI_EnsureDir AI_GetRunnerRoot()
    AI_EnsureDir AI_GetRunnerRoot() & "\logs"
    f = FreeFile
    Open p For Append As #f
        Print #f, Format(Now, "yyyy-mm-dd hh:nn:ss"); "  - "; msg
    Close #f
End Sub

' =======================================================================
' TIMER-EINSTIEG
' =======================================================================
Public Sub AI_ProcessInbox()
    On Error GoTo FIN
    Application.Echo False
    DoCmd.SetWarnings False

    ' 1) Ordner sicherstellen
    Dim root As String, inbox As String, logs As String
    root = AI_GetRunnerRoot()
    inbox = AI_GetInboxPath()
    logs = root & "\logs"
    AI_EnsureDir root
    AI_EnsureDir inbox
    AI_EnsureDir logs

    ' 2) Merken, ob dein Main-Form offen war (z. B. Auftragsstamm)
    Dim keepForm As String, wasOpen As Boolean
    keepForm = "frm_va_auftragstamm"
    wasOpen = AI_IsFormOpen(keepForm)

    ' 3) Nur *.txt verarbeiten
    Dim f As String, filePath As String
    f = Dir(inbox & "\*.txt")
    If Len(f) = 0 Then GoTo FIN

    Do While Len(f) > 0
        filePath = inbox & "\" & f
        On Error Resume Next
        AI_Log "Processing file: " & filePath
        On Error GoTo PF

        AI_ProcessFile filePath
        AI_SafeDelete filePath

        GoTo NEXTFILE

PF:
        AI_Log "Fehler PROCESS_FILE: " & Err.Number & " / " & Err.description
        ' Datei liegen lassen, falls nötig

NEXTFILE:
        f = Dir()
    Loop

FIN:
    DoCmd.SetWarnings True
    Application.Echo True
    If wasOpen Then AI_ReopenIfClosed keepForm
End Sub

' =======================================================================
' Datei lesen / Normalisieren
' =======================================================================
Private Function AI_ReadFileAsCleanString(ByVal filePath As String) As String
    On Error GoTo EH
    Dim h As Integer, l As Long, b() As Byte, i As Long, s As String
    h = FreeFile
    Open filePath For Binary As #h
        l = LOF(h)
        If l > 0 Then
            ReDim b(1 To l)
            Get #h, , b
        End If
    Close #h

    For i = LBound(b) To UBound(b)
        If b(i) <> 0 Then s = s & Chr$(b(i))
    Next i
    s = Replace(s, "ï»¿", "")
    s = Replace(s, ChrW$(&HFEFF), "")
    AI_ReadFileAsCleanString = s
    Exit Function
EH:
    AI_ReadFileAsCleanString = ""
End Function

Private Function AI_StripBOM(ByVal s As String) As String
    If Left$(s, 3) = "ï»¿" Then
        AI_StripBOM = Mid$(s, 4)
    ElseIf Len(s) > 0 And AscW(Left$(s, 1)) = &HFEFF Then
        AI_StripBOM = Mid$(s, 2)
    Else
        AI_StripBOM = s
    End If
End Function

' =======================================================================
' Instruction-Datei parsen/dispatchen
' =======================================================================
Private Sub AI_ProcessFile(ByVal filePath As String)
    On Error GoTo EH

    Dim content As String, blocks() As String, block As Variant
    Dim lines() As String, ln As Variant
    Dim aAction As String, aForm As String, aName As String, aCaption As String
    Dim aTemplate As String, aControls As String, aSection As String

    content = AI_ReadFileAsCleanString(filePath)
    content = Replace(content, "`r`n", vbCrLf)
    content = Replace(content, vbCr, vbLf)
    content = Replace(content, vbLf & vbLf & vbLf, vbLf & vbLf)

    blocks = Split(content, vbLf & vbLf)
    If UBound(blocks) < 0 Then
        ReDim blocks(0): blocks(0) = content
    End If

    For Each block In blocks
        If Trim$(block) <> "" Then
            aAction = "": aForm = "": aName = "": aCaption = ""
            aTemplate = "": aControls = "": aSection = ""

            lines = Split(CStr(block), vbLf)
            For Each ln In lines
                ln = Trim$(AI_StripBOM(ln))
                If ln <> "" Then
                    If UCase$(Left$(ln, 7)) = "ACTION=" Then aAction = Mid$(ln, 8)
                    If UCase$(Left$(ln, 5)) = "FORM=" Then aForm = Mid$(ln, 6)
                    If UCase$(Left$(ln, 5)) = "NAME=" Then aName = Mid$(ln, 6)
                    If UCase$(Left$(ln, 8)) = "CAPTION=" Then aCaption = Mid$(ln, 9)
                    If UCase$(Left$(ln, 9)) = "TEMPLATE=" Then aTemplate = Mid$(ln, 10)
                    If UCase$(Left$(ln, 9)) = "CONTROLS=" Then aControls = Mid$(ln, 10)
                    If UCase$(Left$(ln, 8)) = "SECTION=" Then aSection = Mid$(ln, 9)
                End If
            Next ln

            Select Case UCase$(Trim$(aAction))

                Case "CREATE_FORM"
                    Call AI_DoCreateFormFromTemplate(aForm, aTemplate, aCaption, aControls)

                Case "ADD_BUTTON", "ADD_BUTTONS"
                    Call AI_DoAddButtonEx(aForm, aName, aCaption, aSection)

                Case "CREATE_AUFTRAG"
                    Call AI_Action_CreateAuftrag(block)

                Case "CREATE_AUFTRAG_MULTI"
                    Call AI_Action_CreateAuftragMulti(block)

                Case "ASSIGN_MA"
                    Call AI_Action_AssignMA(block)

                Case Else
                    If Trim$(aAction) <> "" Then AI_Log "Unknown ACTION: " & aAction
            End Select
        End If
    Next block
    Exit Sub

EH:
    AI_Log "Fehler PROCESS_FILE: " & Err.Number & " / " & Err.description
End Sub

' =======================================================================
' Formulare/Buttons
' =======================================================================
Private Sub AI_DoCreateFormFromTemplate(ByVal formName As String, ByVal TemplateName As String, _
                                        ByVal captionText As String, ByVal controlsList As String)
    On Error GoTo EH
    If formName = "" Then Exit Sub
    If TemplateName = "" Then TemplateName = "frm_N_template"

    Dim cleanCaption As String
    cleanCaption = formName
    cleanCaption = Replace(cleanCaption, "frm_", "", , , vbTextCompare)
    cleanCaption = Replace(cleanCaption, "_N_", " ", , , vbTextCompare)
    cleanCaption = Replace(cleanCaption, "_", " ")
    If Len(Trim$(captionText)) > 0 Then cleanCaption = captionText

    DoCmd.OpenForm TemplateName, acDesign
    DoCmd.Save acForm, TemplateName
    DoCmd.CopyObject , formName, acForm, TemplateName

    DoCmd.OpenForm formName, acDesign
    Forms(formName).caption = cleanCaption

    Dim lbl As control
    Set lbl = CreateControl(formName, acLabel, AI_SEC_FORMHEADER, , , 200, 200, 3000, 400)
    lbl.caption = cleanCaption
    lbl.FontBold = True

    If Len(Trim$(controlsList)) > 0 Then
        Call AI_AddControlsList(formName, controlsList)
    End If

    DoCmd.Close acForm, formName, acSaveYes
    AI_Log "Formular angelegt aus Template: " & cleanCaption & " (" & TemplateName & ")"
    Exit Sub

EH:
    AI_Log "Fehler CREATE_FORM: " & Err.Number & " / " & Err.description
    On Error Resume Next
    DoCmd.Close acForm, formName, acSaveNo
End Sub

Private Sub AI_AddControlsList(ByVal formName As String, ByVal controlsList As String)
    On Error GoTo EH
    Dim parts() As String, i As Long, one As String
    Dim nm As String, sec As String, p As Long

    parts = Split(controlsList, ",")
    For i = LBound(parts) To UBound(parts)
        one = Trim$(parts(i))
        If one <> "" Then
            p = InStr(1, one, ":", vbTextCompare)
            If p > 0 Then
                nm = Trim$(Left$(one, p - 1))
                sec = Trim$(Mid$(one, p + 1))
                Call AI_DoAddButtonEx(formName, nm, nm, sec)
            Else
                Call AI_DoAddButtonEx(formName, one, one, "Detail")
            End If
        End If
    Next i
    Exit Sub
EH:
    AI_Log "Fehler CONTROLS: " & Err.Number & " / " & Err.description
End Sub

Private Sub AI_DoAddButtonEx(ByVal formName As String, ByVal btnName As String, ByVal btnCaption As String, ByVal sectionName As String)
    On Error GoTo EH
    If Len(Trim$(formName)) = 0 Then Exit Sub

    Dim sectionConst As Integer
    sectionConst = AI_GetSectionNumberByName(sectionName)
    If sectionConst < 0 Then sectionConst = AI_SEC_DETAIL

    DoCmd.OpenForm formName, acDesign
    Dim frm As Form
    Set frm = Forms(formName)

    Dim secObj As Access.Section
    On Error Resume Next
    Set secObj = frm.Section(sectionConst)
    On Error GoTo EH
    If secObj Is Nothing Then
        DoCmd.RunCommand acCmdFormView
        DoCmd.RunCommand acCmdDesignView
        Set frm = Forms(formName)
        Set secObj = frm.Section(sectionConst)
    End If
    If Not secObj Is Nothing Then
        If secObj.height < 1200 Then secObj.height = 1200
    End If

    If Len(Trim$(btnName)) = 0 Then btnName = "cmd_AI_" & Format(Now, "hhmmss")
    If Len(Trim$(btnCaption)) = 0 Then btnCaption = "AI"

    If AI_ControlExists(formName, btnName) Then
        Dim base As String, n As Long
        base = btnName: n = 1
        Do While AI_ControlExists(formName, base & "_" & n)
            n = n + 1
        Loop
        btnName = base & "_" & n
        AI_Log "Hinweis: Buttonname existierte bereits, benutzt: " & btnName
    End If

    Dim lastTop As Long:   lastTop = 500
    Dim lastLeft As Long:  lastLeft = 500
    Dim lastH As Long:     lastH = 500
    Dim lastW As Long:     lastW = 1800

    Dim c As control, haveTemplate As Boolean
    For Each c In frm.Controls
        If c.Section = sectionConst And c.ControlType = acCommandButton Then
            If c.Top + c.height > lastTop Then
                lastTop = c.Top + c.height
                lastLeft = c.Left
                lastH = c.height
                lastW = c.width
            End If
            haveTemplate = True
        End If
    Next c
    lastTop = lastTop + 120

    Dim ctl As control
    Set ctl = CreateControl(formName, acCommandButton, sectionConst, , , lastLeft, lastTop, lastW, lastH)
    ctl.Name = btnName
    ctl.caption = btnCaption

    If haveTemplate Then
        For Each c In frm.Controls
            If c.Section = sectionConst And c.ControlType = acCommandButton Then
                On Error Resume Next
                ctl.ForeColor = c.ForeColor
                ctl.backColor = c.backColor
                ctl.FontName = c.FontName
                ctl.FontSize = c.FontSize
                ctl.FontWeight = c.FontWeight
                ctl.SpecialEffect = c.SpecialEffect
                ctl.BorderColor = c.BorderColor
                On Error GoTo EH
                Exit For
            End If
        Next c
    End If

    DoCmd.Close acForm, formName, acSaveYes
    AI_Log "ADD_BUTTON OK: " & formName & " / " & btnName & " / " & btnCaption & " / sec=" & CStr(sectionConst)
    Exit Sub

EH:
    AI_Log "Fehler ADD_BUTTON: " & Err.Number & " / " & Err.description
    On Error Resume Next
    DoCmd.Close acForm, formName, acSaveNo
End Sub

Private Function AI_ControlExists(ByVal formName As String, ByVal ctrlName As String) As Boolean
    On Error GoTo NX
    Dim t As control
    Set t = Forms(formName).Controls(ctrlName)
    AI_ControlExists = True
    Exit Function
NX:
    AI_ControlExists = False
End Function

Private Function AI_GetSectionNumberByName(ByVal sectionName As String) As Integer
    Dim s As String: s = LCase$(Trim$(sectionName))
    Select Case s
        Case "formheader", "header", "kopf", "formularkopf"
            AI_GetSectionNumberByName = AI_SEC_FORMHEADER
        Case "detail", "detailbereich", "haupt"
            AI_GetSectionNumberByName = AI_SEC_DETAIL
        Case "formfooter", "footer", "fuß", "fuss", "formularfuß", "formularfuss"
            AI_GetSectionNumberByName = AI_SEC_FORMFOOTER
        Case Else
            AI_GetSectionNumberByName = -1
    End Select
End Function

' =======================================================================
' Mini-Parser / DB-Helfer
' =======================================================================
Private Function AI_GetField(ByVal blob As String, ByVal key As String) As String
    Dim i As Long, ln As String, lines() As String, k As String
    blob = Replace(blob, "`r`n", vbCrLf)
    blob = Replace(blob, vbCr, vbLf)
    lines = Split(blob, vbLf)
    For i = LBound(lines) To UBound(lines)
        ln = Trim$(lines(i))
        If ln <> "" Then
            k = UCase$(key) & "="
            If UCase$(Left$(ln, Len(k))) = k Then
                AI_GetField = Mid$(ln, Len(k) + 1)
                Exit Function
            End If
        End If
    Next
    AI_GetField = ""
End Function

Private Function AI_TableHasField(ByVal tbl As String, ByVal fld As String) As Boolean
    Dim t As DAO.TableDef, f As DAO.field
    On Error GoTo NX
    Set t = CurrentDb.TableDefs(tbl)
    For Each f In t.fields
        If StrComp(f.Name, fld, vbTextCompare) = 0 Then AI_TableHasField = True: Exit Function
    Next
NX:
End Function

Private Function AI_FirstExistingField(ByVal tbl As String, ParamArray names()) As String
    Dim i As Long
    For i = LBound(names) To UBound(names)
        If AI_TableHasField(tbl, CStr(names(i))) Then
            AI_FirstExistingField = CStr(names(i))
            Exit Function
        End If
    Next
    AI_FirstExistingField = ""
End Function

Private Function AI_ParseDate(ByVal s As String) As Date
    On Error Resume Next
    If IsDate(s) Then AI_ParseDate = CDate(s) Else AI_ParseDate = 0
End Function

' =======================================================================
' Auftragslogik + Tageszeilen
' =======================================================================
Private Function AI_AuftragPK() As String
    AI_AuftragPK = AI_FirstExistingField(TBL_AUF, "ID", "AuftragID", "VA_ID", "PK", "Auftrag_Id")
End Function

Private Function AI_FindAuftragId(ByVal d As Date, ByVal titel As String, ByVal Objekt As String) As Variant
    On Error GoTo EH
    Dim pk As String: pk = AI_AuftragPK()
    If pk = "" Then Exit Function

    Dim sql As String, rs As DAO.Recordset
    sql = "SELECT " & pk & " FROM " & TBL_AUF & _
          " WHERE Dat_VA_Von = #" & Month(d) & "/" & Day(d) & "/" & Year(d) & "# " & _
          " AND Auftrag = '" & Replace(titel, "'", "''") & "' " & _
          " AND Objekt  = '" & Replace(Objekt, "'", "''") & "'"
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    If Not rs.EOF Then AI_FindAuftragId = rs.fields(0).Value Else AI_FindAuftragId = Null
    rs.Close
    Exit Function
EH:
    AI_FindAuftragId = Null
End Function

' --- NEU: Tageszeilen sicherstellen ------------------------------------
Private Sub AI_EnsureAnzTag(ByVal auftragId As Variant, ByVal d As Date)
    On Error GoTo EH
    If IsNull(auftragId) Or auftragId = 0 Or d = 0 Then Exit Sub

    Dim fldVA As String, fldDatum As String, fldFlag As String
    fldVA = AI_FirstExistingField(TBL_TAGE, "VA_ID", "AuftragID", "VA_Auftrag_ID", "ID_Auftrag", "Auftrag_Id")
    fldDatum = AI_FirstExistingField(TBL_TAGE, "VADatum", "VA_Datum", "Datum", "Tag")
    fldFlag = AI_FirstExistingField(TBL_TAGE, "Aktiv", "Sichtbar", "Anzeigen", "Enabled", "Gültig", "Gueltig")

    If fldVA = "" Or fldDatum = "" Then
        AI_Log "ANZTAGE: Feldnamen nicht gefunden (VA/Datum)."
        Exit Sub
    End If

    Dim sql As String, rs As DAO.Recordset
    sql = "SELECT * FROM " & TBL_TAGE & _
          " WHERE " & fldVA & "=" & CLng(auftragId) & _
          " AND " & fldDatum & "=#" & Month(d) & "/" & Day(d) & "/" & Year(d) & "#"
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    If Not rs.EOF Then
        rs.Close: Set rs = Nothing
        Exit Sub
    End If
    rs.Close: Set rs = Nothing

    Set rs = CurrentDb.OpenRecordset(TBL_TAGE, dbOpenDynaset)
    rs.AddNew
    rs.fields(fldVA).Value = CLng(auftragId)
    rs.fields(fldDatum).Value = DateValue(d)
    If fldFlag <> "" Then
        On Error Resume Next
        rs.fields(fldFlag).Value = True
        On Error GoTo EH
    End If
    rs.update
    rs.Close
    Set rs = Nothing

    AI_Log "ANZTAGE OK: VA_ID=" & auftragId & " / " & Format$(d, "dd.mm.yyyy")
    Exit Sub
EH:
    AI_Log "Fehler ANZTAGE: " & Err.Number & " / " & Err.description
    On Error Resume Next
    If Not rs Is Nothing Then
        If rs.EditMode <> dbEditNone Then rs.CancelUpdate
        rs.Close
    End If
    Set rs = Nothing
End Sub

Private Sub AI_EnsureAnzTageForRange(ByVal auftragId As Variant, ByVal vonD As Date, ByVal bisD As Date)
    Dim d As Date
    If vonD = 0 Then Exit Sub
    If bisD = 0 Then bisD = vonD
    If bisD < vonD Then bisD = vonD
    For d = DateValue(vonD) To DateValue(bisD)
        Call AI_EnsureAnzTag(auftragId, d)
    Next d
End Sub
' -----------------------------------------------------------------------

Private Function AI_EnsureAuftrag(ByVal title As String, ByVal dFrom As Date, ByVal dTo As Date, _
                                  ByVal Ort As String, ByVal Objekt As String, _
                                  ByVal veranstId As Long) As Variant
    On Error GoTo EH

    Dim ID As Variant
    ID = AI_FindAuftragId(dFrom, title, Objekt)
    If Not IsNull(ID) Then
        ' auch bei bestehendem Auftrag die Tage sicherstellen
        Call AI_EnsureAnzTageForRange(ID, dFrom, dTo)
        AI_EnsureAuftrag = ID
        Exit Function
    End If

    Dim pk As String: pk = AI_AuftragPK()
    If pk = "" Then AI_Log "Auftrag PK-Feld unbekannt": Exit Function

    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset(TBL_AUF, dbOpenDynaset)
    rs.AddNew
    If AI_TableHasField(TBL_AUF, "Dat_VA_Von") Then rs!Dat_VA_Von = dFrom
    If AI_TableHasField(TBL_AUF, "Dat_VA_Bis") Then rs!Dat_VA_Bis = IIf(dTo = 0, dFrom, dTo)
    If AI_TableHasField(TBL_AUF, "Auftrag") Then rs!Auftrag = title
    If AI_TableHasField(TBL_AUF, "Ort") Then rs!Ort = Ort
    If AI_TableHasField(TBL_AUF, "Objekt") Then rs!Objekt = Objekt
    If AI_TableHasField(TBL_AUF, "VeranstalterID") Then rs!VeranstalterID = veranstId
    If AI_TableHasField(TBL_AUF, "Treffpunkt") Then rs!Treffpunkt = "15 min vor DB vor Ort"
    If AI_TableHasField(TBL_AUF, "Dienstkleidung") Then rs!Dienstkleidung = "Consec"
    If AI_TableHasField(TBL_AUF, "Erstellt_Am") Then rs!Erstellt_am = Now()
    If AI_TableHasField(TBL_AUF, "Erstellt_Von") Then rs!Erstellt_von = Environ$("USERNAME")
    rs.update
    rs.Close
    Set rs = Nothing

    ' ID erneut bestimmen und Tage anlegen
    ID = AI_FindAuftragId(dFrom, title, Objekt)
    AI_EnsureAuftrag = ID
    If Not IsNull(ID) Then
        Call AI_EnsureAnzTageForRange(ID, dFrom, dTo)
    End If
    Exit Function

EH:
    AI_Log "Fehler EnsureAuftrag: " & Err.Number & " / " & Err.description
End Function

Private Sub AI_InsertZuordnung(ByVal auftragId As Variant, ByVal maID As Variant, _
                               ByVal von As Date, ByVal bis As Date, _
                               ByVal rolle As String, ByVal stunden As Double)
    On Error GoTo EH

    Dim fldAuftrag As String, fldMA As String, fldVon As String, fldBis As String, fldRolle As String, fldStd As String
    fldAuftrag = AI_FirstExistingField(TBL_ZUO, "AuftragID", "VA_ID", "Auftrag_Id", "VA_Auftrag_ID", "ID_Auftrag")
    fldMA = AI_FirstExistingField(TBL_ZUO, "MA_ID", "MitarbeiterID", "ID_MA", "Mitarbeiter_Id")
    fldVon = AI_FirstExistingField(TBL_ZUO, "Von", "Dat_Von", "Datum_Von", "Beginn_Datum")
    fldBis = AI_FirstExistingField(TBL_ZUO, "Bis", "Dat_Bis", "Datum_Bis", "Ende_Datum")
    fldRolle = AI_FirstExistingField(TBL_ZUO, "Rolle", "Funktion", "Tätigkeit")
    fldStd = AI_FirstExistingField(TBL_ZUO, "Stunden", "Std", "Arbeitsstunden")

    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset(TBL_ZUO, dbOpenDynaset)
    rs.AddNew
    If fldAuftrag <> "" Then rs.fields(fldAuftrag).Value = auftragId
    If fldMA <> "" Then rs.fields(fldMA).Value = maID
    If fldVon <> "" Then rs.fields(fldVon).Value = IIf(von = 0, Date, von)
    If fldBis <> "" Then rs.fields(fldBis).Value = IIf(bis = 0, IIf(von = 0, Date, von), bis)
    If fldRolle <> "" Then rs.fields(fldRolle).Value = rolle
    If fldStd <> "" Then rs.fields(fldStd).Value = stunden
    rs.update
    rs.Close

    AI_Log "ZUORDNUNG OK: MA=" & maID & " -> AuftragID=" & auftragId
    Exit Sub

EH:
    AI_Log "Fehler InsertZuordnung: " & Err.Number & " / " & Err.description
    On Error Resume Next
    If Not rs Is Nothing Then
        If rs.EditMode <> dbEditNone Then rs.CancelUpdate
        rs.Close
    End If
End Sub

' =======================================================================
' ACTION-Handler
' =======================================================================
Private Sub AI_Action_CreateAuftrag(ByVal blob As String)
    Dim title As String, Ort As String, Objekt As String
    Dim veranst As Long, d As Date, ID As Variant

    title = AI_GetField(blob, "TITLE")
    Ort = AI_GetField(blob, "ORT")
    Objekt = AI_GetField(blob, "OBJEKT")
    veranst = val(AI_GetField(blob, "VERANSTALTER_ID"))
    d = AI_ParseDate(AI_GetField(blob, "DATE"))

    If title = "" Or d = 0 Then AI_Log "CREATE_AUFTRAG: fehlende Felder": Exit Sub

    ID = AI_EnsureAuftrag(title, d, d, Ort, Objekt, veranst)
    If Not IsNull(ID) Then
        AI_Log "CREATE_AUFTRAG OK: " & title & " / " & Format(d, "dd.mm.yyyy") & " / ID=" & ID
    Else
        AI_Log "CREATE_AUFTRAG: keine ID erhalten"
    End If
End Sub

Private Sub AI_Action_CreateAuftragMulti(ByVal blob As String)
    Dim title As String, Ort As String, Objekt As String
    Dim veranst As Long, d1 As Date, d2 As Date, ID As Variant

    title = AI_GetField(blob, "TITLE")
    Ort = AI_GetField(blob, "ORT")
    Objekt = AI_GetField(blob, "OBJEKT")
    veranst = val(AI_GetField(blob, "VERANSTALTER_ID"))
    d1 = AI_ParseDate(AI_GetField(blob, "DATE_FROM"))
    d2 = AI_ParseDate(AI_GetField(blob, "DATE_TO"))
    If d2 = 0 Then d2 = d1

    If title = "" Or d1 = 0 Then AI_Log "CREATE_AUFTRAG_MULTI: fehlende Felder": Exit Sub

    ID = AI_EnsureAuftrag(title, d1, d2, Ort, Objekt, veranst)
    If Not IsNull(ID) Then
        AI_Log "CREATE_AUFTRAG_MULTI OK: " & title & " / " & _
               Format(d1, "dd.mm.yyyy") & "-" & Format(d2, "dd.mm.yyyy") & " / ID=" & ID
    Else
        AI_Log "CREATE_AUFTRAG_MULTI: keine ID erhalten"
    End If
End Sub

Private Sub AI_Action_AssignMA(ByVal blob As String)
    Dim auftragId As Variant, maID As Variant
    Dim d As Date, title As String, Objekt As String
    Dim vonD As Date, bisD As Date, rolle As String, std As Double

    auftragId = Null
    If Len(Trim$(AI_GetField(blob, "AUFTRAG_ID"))) > 0 Then
        auftragId = CLng(val(AI_GetField(blob, "AUFTRAG_ID")))
    Else
        title = AI_GetField(blob, "TITLE")
        Objekt = AI_GetField(blob, "OBJEKT")
        d = AI_ParseDate(AI_GetField(blob, "DATE"))
        If title <> "" And d <> 0 And Objekt <> "" Then
            auftragId = AI_FindAuftragId(d, title, Objekt)
        End If
    End If
    If IsNull(auftragId) Then AI_Log "ASSIGN_MA: Auftrag nicht gefunden": Exit Sub

    maID = CLng(val(AI_GetField(blob, "MA_ID")))
    If maID = 0 Then AI_Log "ASSIGN_MA: MA_ID fehlt": Exit Sub

    vonD = AI_ParseDate(AI_GetField(blob, "VON"))
    bisD = AI_ParseDate(AI_GetField(blob, "BIS"))
    rolle = AI_GetField(blob, "ROLLE")
    std = val(AI_GetField(blob, "STUNDEN"))

    ' NEU: sicherstellen, dass der Tag existiert (für die Übersicht)
    Dim tagD As Date
    tagD = IIf(vonD = 0, d, DateValue(vonD))
    If Not IsNull(auftragId) And tagD <> 0 Then
        Call AI_EnsureAnzTag(auftragId, tagD)
    End If

    Call AI_InsertZuordnung(auftragId, maID, vonD, bisD, rolle, std)
End Sub

'=== END mdl_AccessRunner ===================================================


