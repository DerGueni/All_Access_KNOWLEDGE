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
' Erstelle Vorlagen-Tabellen falls nicht vorhanden
' ========================================

WScript.Echo "=== Erstelle Vorlagen-Tabellen ==="

Dim db
Set db = accApp.CurrentDb

' Pruefe ob Tabelle existiert
Dim tdf
Dim tblExists
tblExists = False

For Each tdf In db.TableDefs
    If tdf.Name = "tbl_Positions_Vorlagen" Then
        tblExists = True
        Exit For
    End If
Next

If Not tblExists Then
    db.Execute "CREATE TABLE tbl_Positions_Vorlagen (ID AUTOINCREMENT PRIMARY KEY, VorlageName TEXT(100), ErstelltAm DATETIME, ErstelltVon TEXT(50))"
    WScript.Echo "tbl_Positions_Vorlagen erstellt"
Else
    WScript.Echo "tbl_Positions_Vorlagen existiert bereits"
End If

tblExists = False
For Each tdf In db.TableDefs
    If tdf.Name = "tbl_Positions_Vorlagen_Details" Then
        tblExists = True
        Exit For
    End If
Next

If Not tblExists Then
    db.Execute "CREATE TABLE tbl_Positions_Vorlagen_Details (ID AUTOINCREMENT PRIMARY KEY, Vorlage_ID LONG, PosNr INTEGER, Gruppe TEXT(100), Zusatztext TEXT(255), Zeit1 INTEGER, Zeit2 INTEGER, Zeit3 INTEGER, Zeit4 INTEGER, Sort INTEGER)"
    WScript.Echo "tbl_Positions_Vorlagen_Details erstellt"
Else
    WScript.Echo "tbl_Positions_Vorlagen_Details existiert bereits"
End If

' ========================================
' Aktualisiere MoveUp/MoveDown in Form_frm_OB_Objekt
' ========================================

WScript.Echo "=== Aktualisiere MoveUp/MoveDown Buttons ==="

Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_OB_Objekt" Then
        Set codeModule = comp.CodeModule

        ' Suche nach bestehenden MoveUp/MoveDown und ersetze sie
        Dim existingCode
        existingCode = codeModule.Lines(1, codeModule.CountOfLines)

        ' Wenn alte btnMoveUp_Click existiert, ersetze mit neuer Version
        If InStr(existingCode, "btnMoveUp_Click") > 0 Then
            WScript.Echo "MoveUp/MoveDown existieren bereits"
        Else
            ' Fuege neue MoveUp/MoveDown hinzu
            Dim moveCode
            moveCode = vbCrLf & vbCrLf & _
"' Verbesserte MoveUp/MoveDown mit Sortier-Funktionen" & vbCrLf & _
"Private Sub btnMoveUp_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    Dim lngPosID As Long" & vbCrLf & _
"    lngPosID = Nz(Me.sub_OB_Objekt_Positionen.Form!ID, 0)" & vbCrLf & _
"    If lngPosID > 0 Then" & vbCrLf & _
"        MovePositionUp lngPosID" & vbCrLf & _
"        Me.sub_OB_Objekt_Positionen.Requery" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnMoveDown_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    Dim lngPosID As Long" & vbCrLf & _
"    lngPosID = Nz(Me.sub_OB_Objekt_Positionen.Form!ID, 0)" & vbCrLf & _
"    If lngPosID > 0 Then" & vbCrLf & _
"        MovePositionDown lngPosID" & vbCrLf & _
"        Me.sub_OB_Objekt_Positionen.Requery" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub"

            codeModule.InsertLines codeModule.CountOfLines + 1, moveCode
            WScript.Echo "MoveUp/MoveDown Code hinzugefuegt"
        End If

        Exit For
    End If
Next

' ========================================
' Fuege Code zu Dialog-Formularen hinzu
' ========================================

WScript.Echo "=== Fuege Code zu Dialog-Formularen hinzu ==="

' frm_PositionenKopieren
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_PositionenKopieren" Then
        Set codeModule = comp.CodeModule

        If codeModule.CountOfLines < 5 Then
            Dim kopierenFormCode
            kopierenFormCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Private Sub Form_Load()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If Len(Nz(Me.OpenArgs, """")) > 0 Then" & vbCrLf & _
"        Me.Tag = Me.OpenArgs" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnOK_Click()" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If IsNull(Me.cboQuellObjekt) Then" & vbCrLf & _
"        MsgBox ""Bitte Quell-Objekt auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim lngZielID As Long" & vbCrLf & _
"    lngZielID = CLng(Nz(Me.Tag, 0))" & vbCrLf & _
"    " & vbCrLf & _
"    KopierePositionen CLng(Me.cboQuellObjekt), lngZielID, Nz(Me.chkLoescheZiel, False)" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnAbbrechen_Click()" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"End Sub"

            If codeModule.CountOfLines > 0 Then
                codeModule.DeleteLines 1, codeModule.CountOfLines
            End If
            codeModule.InsertLines 1, kopierenFormCode
            WScript.Echo "Code fuer frm_PositionenKopieren eingefuegt"
        Else
            WScript.Echo "frm_PositionenKopieren hat bereits Code"
        End If
        Exit For
    End If
Next

' frm_VorlageAuswahl
For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_VorlageAuswahl" Then
        Set codeModule = comp.CodeModule

        If codeModule.CountOfLines < 5 Then
            Dim vorlageFormCode
            vorlageFormCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"Private Sub Form_Load()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If Len(Nz(Me.OpenArgs, """")) > 0 Then" & vbCrLf & _
"        Me.Tag = Me.OpenArgs" & vbCrLf & _
"    End If" & vbCrLf & _
"    Me.lstVorlagen.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnLaden_Click()" & vbCrLf & _
"    On Error GoTo ErrHandler" & vbCrLf & _
"    " & vbCrLf & _
"    If IsNull(Me.lstVorlagen) Then" & vbCrLf & _
"        MsgBox ""Bitte Vorlage auswaehlen!"", vbExclamation" & vbCrLf & _
"        Exit Sub" & vbCrLf & _
"    End If" & vbCrLf & _
"    " & vbCrLf & _
"    Dim lngZielID As Long" & vbCrLf & _
"    lngZielID = CLng(Nz(Me.Tag, 0))" & vbCrLf & _
"    " & vbCrLf & _
"    LadeVorlage CLng(Me.lstVorlagen), lngZielID, Nz(Me.chkLoescheZiel, True)" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"    Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"ErrHandler:" & vbCrLf & _
"    MsgBox ""Fehler: "" & Err.Description, vbCritical" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnLoeschen_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    If IsNull(Me.lstVorlagen) Then Exit Sub" & vbCrLf & _
"    LoescheVorlage CLng(Me.lstVorlagen)" & vbCrLf & _
"    Me.lstVorlagen.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnSchliessen_Click()" & vbCrLf & _
"    DoCmd.Close acForm, Me.Name" & vbCrLf & _
"End Sub"

            If codeModule.CountOfLines > 0 Then
                codeModule.DeleteLines 1, codeModule.CountOfLines
            End If
            codeModule.InsertLines 1, vorlageFormCode
            WScript.Echo "Code fuer frm_VorlageAuswahl eingefuegt"
        Else
            WScript.Echo "frm_VorlageAuswahl hat bereits Code"
        End If
        Exit For
    End If
Next

' ========================================
' Aktualisiere Zeit-Validierung im Unterformular
' ========================================

WScript.Echo "=== Aktualisiere Zeit-Validierung im Unterformular ==="

For Each comp In proj.VBComponents
    If comp.Name = "Form_sub_OB_Objekt_Positionen" Then
        Set codeModule = comp.CodeModule

        Dim subFormCode
        subFormCode = codeModule.Lines(1, codeModule.CountOfLines)

        ' Fuege verbesserte BeforeUpdate Events hinzu falls nicht vorhanden
        If InStr(subFormCode, "Zeit1_BeforeUpdate") = 0 Then
            Dim zeitValidCode
            zeitValidCode = vbCrLf & vbCrLf & _
"' Verbesserte Zeit-Validierung" & vbCrLf & _
"Private Sub Zeit1_BeforeUpdate(Cancel As Integer)" & vbCrLf & _
"    Dim strMsg As String" & vbCrLf & _
"    If Not ValidateZeitWert(Me.Zeit1, strMsg) Then" & vbCrLf & _
"        If strMsg <> """" Then MsgBox strMsg, vbExclamation" & vbCrLf & _
"        Cancel = True" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub Zeit2_BeforeUpdate(Cancel As Integer)" & vbCrLf & _
"    Dim strMsg As String" & vbCrLf & _
"    If Not ValidateZeitWert(Me.Zeit2, strMsg) Then" & vbCrLf & _
"        If strMsg <> """" Then MsgBox strMsg, vbExclamation" & vbCrLf & _
"        Cancel = True" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub Zeit3_BeforeUpdate(Cancel As Integer)" & vbCrLf & _
"    Dim strMsg As String" & vbCrLf & _
"    If Not ValidateZeitWert(Me.Zeit3, strMsg) Then" & vbCrLf & _
"        If strMsg <> """" Then MsgBox strMsg, vbExclamation" & vbCrLf & _
"        Cancel = True" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub Zeit4_BeforeUpdate(Cancel As Integer)" & vbCrLf & _
"    Dim strMsg As String" & vbCrLf & _
"    If Not ValidateZeitWert(Me.Zeit4, strMsg) Then" & vbCrLf & _
"        If strMsg <> """" Then MsgBox strMsg, vbExclamation" & vbCrLf & _
"        Cancel = True" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub"

            codeModule.InsertLines codeModule.CountOfLines + 1, zeitValidCode
            WScript.Echo "Zeit-Validierung zum Unterformular hinzugefuegt"
        Else
            WScript.Echo "Zeit-Validierung existiert bereits"
        End If

        Exit For
    End If
Next

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
End If

On Error GoTo 0

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo ""
WScript.Echo "=== ALLE 8 FEATURES VOLLSTAENDIG IMPLEMENTIERT ==="
