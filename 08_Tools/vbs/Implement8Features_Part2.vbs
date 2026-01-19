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
' Buttons zum Hauptformular hinzufuegen
' ========================================

WScript.Echo "=== Fuege Buttons zu frm_OB_Objekt hinzu ==="

' Oeffne Formular in Design-Modus
accApp.DoCmd.OpenForm "frm_OB_Objekt", 1 ' acDesign
WScript.Sleep 2000

Dim frmObj
Set frmObj = accApp.Forms("frm_OB_Objekt")

' Finde Position (neben Upload-Button)
Dim uploadBtn, btnTop, btnLeft
Set uploadBtn = Nothing

Dim ctl
For Each ctl In frmObj.Controls
    If ctl.Name = "btnUploadPositionen" Then
        Set uploadBtn = ctl
        Exit For
    End If
Next

If Not uploadBtn Is Nothing Then
    btnTop = uploadBtn.Top
    btnLeft = uploadBtn.Left + uploadBtn.Width + 100
Else
    btnTop = 7800
    btnLeft = 100
End If

Dim btnWidth, btnHeight
btnWidth = 2000
btnHeight = 400

' Button 1: Excel-Export
Dim btnExport
Set btnExport = Nothing
For Each ctl In frmObj.Controls
    If ctl.Name = "btnExportExcel" Then
        Set btnExport = ctl
        Exit For
    End If
Next

If btnExport Is Nothing Then
    Set btnExport = accApp.CreateControl("frm_OB_Objekt", 104, 0, "", "", btnLeft, btnTop, btnWidth, btnHeight)
    btnExport.Name = "btnExportExcel"
    btnExport.Caption = "Excel Export"
    btnExport.OnClick = "[Event Procedure]"
    WScript.Echo "btnExportExcel erstellt"
    btnLeft = btnLeft + btnWidth + 100
Else
    btnLeft = btnExport.Left + btnExport.Width + 100
    WScript.Echo "btnExportExcel existiert bereits"
End If

' Button 2: Positionen kopieren
Dim btnKopieren
Set btnKopieren = Nothing
For Each ctl In frmObj.Controls
    If ctl.Name = "btnKopierePositionen" Then
        Set btnKopieren = ctl
        Exit For
    End If
Next

If btnKopieren Is Nothing Then
    Set btnKopieren = accApp.CreateControl("frm_OB_Objekt", 104, 0, "", "", btnLeft, btnTop, btnWidth, btnHeight)
    btnKopieren.Name = "btnKopierePositionen"
    btnKopieren.Caption = "Positionen kopieren"
    btnKopieren.OnClick = "[Event Procedure]"
    WScript.Echo "btnKopierePositionen erstellt"
    btnLeft = btnLeft + btnWidth + 100
Else
    btnLeft = btnKopieren.Left + btnKopieren.Width + 100
    WScript.Echo "btnKopierePositionen existiert bereits"
End If

' Button 3: Als Vorlage speichern
Dim btnVorlageSpeichern
Set btnVorlageSpeichern = Nothing
For Each ctl In frmObj.Controls
    If ctl.Name = "btnVorlageSpeichern" Then
        Set btnVorlageSpeichern = ctl
        Exit For
    End If
Next

If btnVorlageSpeichern Is Nothing Then
    Set btnVorlageSpeichern = accApp.CreateControl("frm_OB_Objekt", 104, 0, "", "", btnLeft, btnTop, btnWidth, btnHeight)
    btnVorlageSpeichern.Name = "btnVorlageSpeichern"
    btnVorlageSpeichern.Caption = "Als Vorlage"
    btnVorlageSpeichern.OnClick = "[Event Procedure]"
    WScript.Echo "btnVorlageSpeichern erstellt"
    btnLeft = btnLeft + btnWidth + 100
End If

' Button 4: Vorlage laden
Dim btnVorlageLaden
Set btnVorlageLaden = Nothing
For Each ctl In frmObj.Controls
    If ctl.Name = "btnVorlageLaden" Then
        Set btnVorlageLaden = ctl
        Exit For
    End If
Next

If btnVorlageLaden Is Nothing Then
    Set btnVorlageLaden = accApp.CreateControl("frm_OB_Objekt", 104, 0, "", "", btnLeft, btnTop, btnWidth, btnHeight)
    btnVorlageLaden.Name = "btnVorlageLaden"
    btnVorlageLaden.Caption = "Vorlage laden"
    btnVorlageLaden.OnClick = "[Event Procedure]"
    WScript.Echo "btnVorlageLaden erstellt"
    btnLeft = btnLeft + btnWidth + 100
End If

' Button 5: Zeit-Labels bearbeiten
Dim btnZeitLabels
Set btnZeitLabels = Nothing
For Each ctl In frmObj.Controls
    If ctl.Name = "btnZeitLabels" Then
        Set btnZeitLabels = ctl
        Exit For
    End If
Next

If btnZeitLabels Is Nothing Then
    Set btnZeitLabels = accApp.CreateControl("frm_OB_Objekt", 104, 0, "", "", btnLeft, btnTop, btnWidth, btnHeight)
    btnZeitLabels.Name = "btnZeitLabels"
    btnZeitLabels.Caption = "Zeitslots"
    btnZeitLabels.OnClick = "[Event Procedure]"
    WScript.Echo "btnZeitLabels erstellt"
End If

' Suchfeld hinzufuegen (Feature 6)
WScript.Echo "Fuege Suchfeld hinzu..."

Dim lstObjekte
Set lstObjekte = Nothing
For Each ctl In frmObj.Controls
    If ctl.Name = "lstObjekte" Then
        Set lstObjekte = ctl
        Exit For
    End If
Next

Dim txtSuche, lblSuche
If Not lstObjekte Is Nothing Then
    ' Suchfeld oberhalb des Listenfelds
    Dim sucheTop, sucheLeft
    sucheTop = lstObjekte.Top - 500
    sucheLeft = lstObjekte.Left

    ' Pruefe ob txtSuche bereits existiert
    Set txtSuche = Nothing
    For Each ctl In frmObj.Controls
        If ctl.Name = "txtSuche" Then
            Set txtSuche = ctl
            Exit For
        End If
    Next

    If txtSuche Is Nothing Then
        ' Label
        Set lblSuche = accApp.CreateControl("frm_OB_Objekt", 100, 0, "", "", sucheLeft, sucheTop, 600, 300)
        lblSuche.Name = "lblSuche"
        lblSuche.Caption = "Suche:"

        ' Textfeld
        Set txtSuche = accApp.CreateControl("frm_OB_Objekt", 109, 0, "", "", sucheLeft + 650, sucheTop, 2000, 300)
        txtSuche.Name = "txtSuche"
        txtSuche.OnChange = "[Event Procedure]"
        WScript.Echo "Suchfeld erstellt"
    Else
        WScript.Echo "Suchfeld existiert bereits"
    End If
End If

' Speichern
accApp.DoCmd.Close 2, "frm_OB_Objekt", 1 ' acSaveYes
WScript.Sleep 1000

WScript.Echo "Formular gespeichert"

' ========================================
' Event-Code zu Form_frm_OB_Objekt hinzufuegen
' ========================================

WScript.Echo "=== Fuege Event-Code hinzu ==="

Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_OB_Objekt" Then
        Set codeModule = comp.CodeModule

        ' Fuege Button-Events am Ende hinzu
        Dim eventCode
        eventCode = vbCrLf & vbCrLf & _
"' === NEUE BUTTON-EVENTS ===" & vbCrLf & vbCrLf & _
"Private Sub btnExportExcel_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    ExportPositionslisteToExcel Nz(Me.ID, 0)" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnKopierePositionen_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    KopierePositionenDialog Nz(Me.ID, 0)" & vbCrLf & _
"    Me.sub_OB_Objekt_Positionen.Requery" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnVorlageSpeichern_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    SpeichereAlsVorlage Nz(Me.ID, 0)" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnVorlageLaden_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    LadeVorlageDialog Nz(Me.ID, 0)" & vbCrLf & _
"    Me.sub_OB_Objekt_Positionen.Requery" & vbCrLf & _
"    UpdateSummenAnzeige Me" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub btnZeitLabels_Click()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    BearbeiteZeitLabels Me" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"Private Sub txtSuche_Change()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    FilterObjektListe Me, Nz(Me.txtSuche.Text, """")" & vbCrLf & _
"End Sub"

        ' Pruefe ob Events bereits existieren
        Dim existingCode
        existingCode = codeModule.Lines(1, codeModule.CountOfLines)

        If InStr(existingCode, "btnExportExcel_Click") = 0 Then
            codeModule.InsertLines codeModule.CountOfLines + 1, eventCode
            WScript.Echo "Event-Code hinzugefuegt"
        Else
            WScript.Echo "Event-Code existiert bereits"
        End If

        Exit For
    End If
Next

' ========================================
' Farbcodierung zum Unterformular hinzufuegen
' ========================================

WScript.Echo "=== Fuege Farbcodierung zum Unterformular hinzu ==="

For Each comp In proj.VBComponents
    If comp.Name = "Form_sub_OB_Objekt_Positionen" Then
        Set codeModule = comp.CodeModule

        Dim farbEventCode
        farbEventCode = vbCrLf & vbCrLf & _
"Private Sub Form_Current()" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    ' Farbcodierung anwenden" & vbCrLf & _
"    ApplyFarbcodierung Me" & vbCrLf & _
"End Sub"

        ' Pruefe ob Form_Current bereits existiert
        Dim subFormCode
        subFormCode = codeModule.Lines(1, codeModule.CountOfLines)

        If InStr(subFormCode, "Form_Current") = 0 Then
            codeModule.InsertLines codeModule.CountOfLines + 1, farbEventCode
            WScript.Echo "Farbcodierung zum Unterformular hinzugefuegt"
        Else
            ' Form_Current existiert - fuege ApplyFarbcodierung hinzu falls nicht vorhanden
            If InStr(subFormCode, "ApplyFarbcodierung") = 0 Then
                Dim i, lineText
                For i = 1 To codeModule.CountOfLines
                    lineText = codeModule.Lines(i, 1)
                    If InStr(lineText, "Form_Current") > 0 And InStr(lineText, "Private Sub") > 0 Then
                        ' Finde passende Stelle
                        codeModule.InsertLines i + 1, "    On Error Resume Next"
                        codeModule.InsertLines i + 2, "    ApplyFarbcodierung Me"
                        WScript.Echo "ApplyFarbcodierung zu bestehendem Form_Current hinzugefuegt"
                        Exit For
                    End If
                Next
            Else
                WScript.Echo "Farbcodierung existiert bereits"
            End If
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
WScript.Echo "=== Teil 2 abgeschlossen ==="
