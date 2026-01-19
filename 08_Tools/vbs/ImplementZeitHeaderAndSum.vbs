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

Dim vbe, proj, comp, codeModule

Set vbe = accApp.VBE
Set proj = vbe.VBProjects(1)

' ========================================
' 1. Aktualisiere Form_frm_OB_Objekt Code
' ========================================

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_OB_Objekt" Then
        Set codeModule = comp.CodeModule
        Dim lineCount, i, lineText
        lineCount = codeModule.CountOfLines

        ' Suche nach Form_Current
        Dim foundCurrent
        foundCurrent = False

        For i = 1 To lineCount
            lineText = codeModule.Lines(i, 1)

            ' Suche Form_Current um Zeit-Header-Update hinzuzufuegen
            If InStr(lineText, "Form_Current") > 0 And InStr(lineText, "Private Sub") > 0 Then
                WScript.Echo "Form_Current gefunden in Zeile " & i

                ' Finde End Sub
                Dim endLine
                For endLine = i + 1 To lineCount
                    If InStr(codeModule.Lines(endLine, 1), "End Sub") > 0 Then
                        ' Fuege Code vor End Sub ein
                        Dim zeitHeaderCode
                        zeitHeaderCode = "    " & vbCrLf & _
                            "    ' Aktualisiere Zeit-Header im Unterformular" & vbCrLf & _
                            "    UpdateZeitHeaderLabels Me"

                        codeModule.InsertLines endLine, zeitHeaderCode
                        WScript.Echo "Zeit-Header Update in Form_Current eingefuegt"
                        foundCurrent = True
                        Exit For
                    End If
                Next
                Exit For
            End If
        Next

        If Not foundCurrent Then
            ' Form_Current existiert nicht, erstelle es
            WScript.Echo "Form_Current nicht gefunden, erstelle neu..."
            Dim newCurrentCode
            newCurrentCode = vbCrLf & _
                "Private Sub Form_Current()" & vbCrLf & _
                "    On Error Resume Next" & vbCrLf & _
                "    " & vbCrLf & _
                "    ' Aktualisiere Zeit-Header im Unterformular" & vbCrLf & _
                "    UpdateZeitHeaderLabels Me" & vbCrLf & _
                "End Sub"
            codeModule.InsertLines codeModule.CountOfLines + 1, newCurrentCode
            WScript.Echo "Form_Current erstellt"
        End If

        Exit For
    End If
Next

' ========================================
' 2. Erstelle/Aktualisiere Hilfsmodul fuer Zeit-Header
' ========================================

Dim moduleExists
moduleExists = False

For Each comp In proj.VBComponents
    If comp.Name = "mdl_ZeitHeader" Then
        moduleExists = True
        Set codeModule = comp.CodeModule
        Exit For
    End If
Next

If Not moduleExists Then
    Set comp = proj.VBComponents.Add(1) ' vbext_ct_StdModule
    comp.Name = "mdl_ZeitHeader"
    Set codeModule = comp.CodeModule
    WScript.Echo "Modul mdl_ZeitHeader erstellt"
End If

' Loesche bestehenden Code
If codeModule.CountOfLines > 0 Then
    codeModule.DeleteLines 1, codeModule.CountOfLines
End If

Dim zeitHeaderModuleCode
zeitHeaderModuleCode = "Option Compare Database" & vbCrLf & _
"Option Explicit" & vbCrLf & vbCrLf & _
"' Modul fuer Zeit-Header und Summen-Funktionen" & vbCrLf & vbCrLf & _
"Public Sub UpdateZeitHeaderLabels(frm As Form)" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    " & vbCrLf & _
"    Dim strZeit1 As String, strZeit2 As String" & vbCrLf & _
"    Dim strZeit3 As String, strZeit4 As String" & vbCrLf & _
"    " & vbCrLf & _
"    ' Hole Zeit-Labels aus dem Hauptformular (tbl_OB_Objekt)" & vbCrLf & _
"    strZeit1 = Nz(frm!Zeit1_Label, ""08:00"")" & vbCrLf & _
"    strZeit2 = Nz(frm!Zeit2_Label, ""12:00"")" & vbCrLf & _
"    strZeit3 = Nz(frm!Zeit3_Label, ""16:00"")" & vbCrLf & _
"    strZeit4 = Nz(frm!Zeit4_Label, ""20:00"")" & vbCrLf & _
"    " & vbCrLf & _
"    ' Setze Standard-Werte falls leer" & vbCrLf & _
"    If strZeit1 = """" Then strZeit1 = ""08:00""" & vbCrLf & _
"    If strZeit2 = """" Then strZeit2 = ""12:00""" & vbCrLf & _
"    If strZeit3 = """" Then strZeit3 = ""16:00""" & vbCrLf & _
"    If strZeit4 = """" Then strZeit4 = ""20:00""" & vbCrLf & _
"    " & vbCrLf & _
"    ' Aktualisiere Spalten-Ueberschriften im Unterformular (Datenblatt)" & vbCrLf & _
"    ' Bei Datenblatt-Ansicht sind die Spalten-Header die Control-Captions" & vbCrLf & _
"    Dim subFrm As Form" & vbCrLf & _
"    Set subFrm = frm!sub_OB_Objekt_Positionen.Form" & vbCrLf & _
"    " & vbCrLf & _
"    ' Setze die Caption der Zeit-Felder (wird als Spalten-Header angezeigt)" & vbCrLf & _
"    If Not subFrm Is Nothing Then" & vbCrLf & _
"        subFrm!Zeit1.Caption = strZeit1" & vbCrLf & _
"        subFrm!Zeit2.Caption = strZeit2" & vbCrLf & _
"        subFrm!Zeit3.Caption = strZeit3" & vbCrLf & _
"        subFrm!Zeit4.Caption = strZeit4" & vbCrLf & _
"    End If" & vbCrLf & _
"End Sub" & vbCrLf & vbCrLf & _
"' Berechnet die Summe einer Zeit-Spalte" & vbCrLf & _
"Public Function SumZeitSpalte(lngObjektID As Long, strFeld As String) As Long" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    SumZeitSpalte = Nz(DSum(strFeld, ""tbl_OB_Objekt_Positionen"", ""OB_Objekt_Kopf_ID = "" & lngObjektID), 0)" & vbCrLf & _
"End Function" & vbCrLf & vbCrLf & _
"' Berechnet die Gesamtsumme aller Zeiten fuer ein Objekt" & vbCrLf & _
"Public Function SumAlleZeiten(lngObjektID As Long) As Long" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    Dim lngSum As Long" & vbCrLf & _
"    lngSum = Nz(DSum(""Nz(Zeit1,0) + Nz(Zeit2,0) + Nz(Zeit3,0) + Nz(Zeit4,0)"", ""tbl_OB_Objekt_Positionen"", ""OB_Objekt_Kopf_ID = "" & lngObjektID), 0)" & vbCrLf & _
"    SumAlleZeiten = lngSum" & vbCrLf & _
"End Function" & vbCrLf & vbCrLf & _
"' Aktualisiert die Summen-Anzeige im Formular" & vbCrLf & _
"Public Sub UpdateSummenAnzeige(frm As Form)" & vbCrLf & _
"    On Error Resume Next" & vbCrLf & _
"    " & vbCrLf & _
"    Dim lngObjektID As Long" & vbCrLf & _
"    lngObjektID = Nz(frm!ID, 0)" & vbCrLf & _
"    " & vbCrLf & _
"    If lngObjektID = 0 Then Exit Sub" & vbCrLf & _
"    " & vbCrLf & _
"    ' Aktualisiere Summen-Felder falls vorhanden" & vbCrLf & _
"    frm!txtSumZeit1 = SumZeitSpalte(lngObjektID, ""Zeit1"")" & vbCrLf & _
"    frm!txtSumZeit2 = SumZeitSpalte(lngObjektID, ""Zeit2"")" & vbCrLf & _
"    frm!txtSumZeit3 = SumZeitSpalte(lngObjektID, ""Zeit3"")" & vbCrLf & _
"    frm!txtSumZeit4 = SumZeitSpalte(lngObjektID, ""Zeit4"")" & vbCrLf & _
"    frm!txtSumGesamt = SumAlleZeiten(lngObjektID)" & vbCrLf & _
"End Sub"

codeModule.InsertLines 1, zeitHeaderModuleCode

If Err.Number <> 0 Then
    WScript.Echo "Fehler: " & Err.Description
Else
    WScript.Echo "mdl_ZeitHeader Modul erfolgreich erstellt"
End If

' ========================================
' 3. Fuege Summen-Felder zum Hauptformular hinzu
' ========================================

WScript.Echo "Fuege Summen-Felder zum Formular hinzu..."

' Oeffne Formular in Design-Modus
accApp.DoCmd.OpenForm "frm_OB_Objekt", 1 ' acDesign

WScript.Sleep 2000

' Hole das Formular
Dim frmObj
Set frmObj = accApp.Forms("frm_OB_Objekt")

' Finde Position fuer Summen-Felder (unterhalb des Unterformulars)
Dim subFormCtl, subFormBottom, subFormLeft
On Error Resume Next
Set subFormCtl = frmObj.Controls("sub_OB_Objekt_Positionen")
If Not subFormCtl Is Nothing Then
    subFormBottom = subFormCtl.Top + subFormCtl.Height + 100
    subFormLeft = subFormCtl.Left
    WScript.Echo "Unterformular gefunden bei Top=" & subFormCtl.Top & ", Height=" & subFormCtl.Height
Else
    subFormBottom = 8000
    subFormLeft = 100
    WScript.Echo "Unterformular nicht gefunden, verwende Standardposition"
End If

' Erstelle Label und Textfelder fuer Summen
Dim leftPos, ctlWidth, ctlHeight, labelWidth
leftPos = subFormLeft
ctlWidth = 1000
ctlHeight = 300
labelWidth = 800

' Pruefe ob Felder bereits existieren
Dim ctl
Dim sumFieldsExist
sumFieldsExist = False

For Each ctl In frmObj.Controls
    If ctl.Name = "txtSumZeit1" Then
        sumFieldsExist = True
        Exit For
    End If
Next

If Not sumFieldsExist Then
    ' Label "Summen:"
    Dim lblSummen
    Set lblSummen = accApp.CreateControl("frm_OB_Objekt", 100, 0, "", "", leftPos, subFormBottom, labelWidth, ctlHeight) ' acLabel = 100
    lblSummen.Name = "lblSummen"
    lblSummen.Caption = "Summen:"
    lblSummen.FontWeight = 700
    WScript.Echo "Label Summen erstellt"

    leftPos = leftPos + labelWidth + 200

    ' Summen-Felder
    Dim sumFields
    sumFields = Array("txtSumZeit1", "txtSumZeit2", "txtSumZeit3", "txtSumZeit4", "txtSumGesamt")

    Dim j, txtCtl
    For j = 0 To UBound(sumFields)
        Set txtCtl = accApp.CreateControl("frm_OB_Objekt", 109, 0, "", "", leftPos, subFormBottom, ctlWidth, ctlHeight) ' acTextBox = 109
        txtCtl.Name = sumFields(j)
        txtCtl.Enabled = False
        txtCtl.Locked = True
        txtCtl.BackColor = 15921906 ' Hellgrau
        WScript.Echo sumFields(j) & " erstellt"
        leftPos = leftPos + ctlWidth + 100
    Next

    WScript.Echo "Summen-Felder erstellt"
Else
    WScript.Echo "Summen-Felder existieren bereits"
End If

On Error GoTo 0

' Speichere und schliesse das Formular
accApp.DoCmd.Close 2, "frm_OB_Objekt", 1 ' acSaveYes

WScript.Sleep 1000

accApp.CloseCurrentDatabase
accApp.Quit
Set accApp = Nothing

WScript.Echo "Fertig"
