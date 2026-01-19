' ============================================
' CreateDashboardForms.vbs
' Erstellt Dashboard-Formulare in Access
' ============================================

Option Explicit

Dim accessApp
Dim db
Dim frm
Dim ctrl
Dim frontendPath

frontendPath = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - Diverses\Consys_FE_N_Test_Claude_GPT - Kopie (6).accdb"

' Access starten
WScript.Echo "Starte Access..."
Set accessApp = CreateObject("Access.Application")
accessApp.Visible = False
accessApp.AutomationSecurity = 1

WScript.Echo "Oeffne Datenbank: " & frontendPath
accessApp.OpenCurrentDatabase frontendPath, False

Set db = accessApp.CurrentDb

' ============================================
' Unterformular: Auftraege heute
' ============================================
WScript.Echo "Erstelle sub_N_Dashboard_AuftraegeHeute..."

On Error Resume Next
accessApp.DoCmd.DeleteObject 2, "sub_N_Dashboard_AuftraegeHeute"
On Error GoTo 0

Set frm = accessApp.CreateForm()
frm.RecordSource = "qry_N_Dashboard_AuftraegeHeute"
frm.DefaultView = 2  ' Datenblatt
frm.ViewsAllowed = 2
frm.AllowAdditions = False
frm.AllowDeletions = False
frm.AllowEdits = False
frm.NavigationButtons = False
frm.RecordSelectors = True
frm.Caption = "Auftraege Heute"

accessApp.DoCmd.Save 2, "sub_N_Dashboard_AuftraegeHeute"
accessApp.DoCmd.Close 2, "sub_N_Dashboard_AuftraegeHeute", 1

WScript.Echo "  Erstellt!"

' ============================================
' Unterformular: Unterbesetzung
' ============================================
WScript.Echo "Erstelle sub_N_Dashboard_Unterbesetzung..."

On Error Resume Next
accessApp.DoCmd.DeleteObject 2, "sub_N_Dashboard_Unterbesetzung"
On Error GoTo 0

Set frm = accessApp.CreateForm()
frm.RecordSource = "qry_N_Dashboard_Unterbesetzung"
frm.DefaultView = 2
frm.ViewsAllowed = 2
frm.AllowAdditions = False
frm.AllowDeletions = False
frm.AllowEdits = False
frm.NavigationButtons = False
frm.Caption = "Unterbesetzte Auftraege"

accessApp.DoCmd.Save 2, "sub_N_Dashboard_Unterbesetzung"
accessApp.DoCmd.Close 2, "sub_N_Dashboard_Unterbesetzung", 1

WScript.Echo "  Erstellt!"

' ============================================
' Unterformular: Offene Anfragen
' ============================================
WScript.Echo "Erstelle sub_N_Dashboard_OffeneAnfragen..."

On Error Resume Next
accessApp.DoCmd.DeleteObject 2, "sub_N_Dashboard_OffeneAnfragen"
On Error GoTo 0

Set frm = accessApp.CreateForm()
frm.RecordSource = "qry_N_Dashboard_OffeneAnfragen"
frm.DefaultView = 2
frm.ViewsAllowed = 2
frm.AllowAdditions = False
frm.AllowDeletions = False
frm.AllowEdits = False
frm.NavigationButtons = False
frm.Caption = "Offene Anfragen"

accessApp.DoCmd.Save 2, "sub_N_Dashboard_OffeneAnfragen"
accessApp.DoCmd.Close 2, "sub_N_Dashboard_OffeneAnfragen", 1

WScript.Echo "  Erstellt!"

' ============================================
' Hauptformular: Dashboard
' ============================================
WScript.Echo "Erstelle frm_N_Dashboard..."

On Error Resume Next
accessApp.DoCmd.DeleteObject 2, "frm_N_Dashboard"
On Error GoTo 0

Set frm = accessApp.CreateForm()

' Grundeinstellungen
frm.Caption = "CONSYS Dashboard - Live-Uebersicht"
frm.RecordSelectors = False
frm.NavigationButtons = False
frm.DividingLines = False
frm.ScrollBars = 0
frm.BorderStyle = 1
frm.AutoCenter = True
frm.Width = 17000
frm.Section(0).Height = 10000
frm.Section(0).BackColor = 15921906

' Titel-Label
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 200, 100, 16500, 600)
ctrl.Name = "lblTitel"
ctrl.Caption = "CONSYS DASHBOARD - Live-Uebersicht"
ctrl.FontSize = 18
ctrl.FontBold = True
ctrl.ForeColor = 0
ctrl.BackStyle = 0  ' Transparent
ctrl.TextAlign = 2  ' Zentriert

' Datum-Label
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 200, 750, 8000, 350)
ctrl.Name = "lblDatum"
ctrl.Caption = "=Format(Date(),'dddd, dd. mmmm yyyy')"
ctrl.FontSize = 10
ctrl.ForeColor = 8421504
ctrl.BackStyle = 0

' ============================================
' Kennzahlen-Bereich
' ============================================

' Box 1: Auftraege heute
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 101, 0, "", "", 200, 1200, 3800, 1500)
ctrl.Name = "boxAuftraegeHeute"
ctrl.SpecialEffect = 2  ' Erhaben
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 300, 1300, 3600, 300)
ctrl.Name = "lblAuftraegeHeuteText"
ctrl.Caption = "Auftraege heute"
ctrl.FontSize = 9
ctrl.TextAlign = 2

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 300, 1650, 3600, 700)
ctrl.Name = "lblAuftraegeHeute"
ctrl.Caption = "=Dashboard_AuftraegeHeute()"
ctrl.FontSize = 28
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 8388608

' Box 2: MA verfuegbar
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 101, 0, "", "", 4200, 1200, 3800, 1500)
ctrl.Name = "boxMAVerfuegbar"
ctrl.SpecialEffect = 2
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 4300, 1300, 3600, 300)
ctrl.Name = "lblMAVerfuegbarText"
ctrl.Caption = "Aktive Mitarbeiter"
ctrl.FontSize = 9
ctrl.TextAlign = 2

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 4300, 1650, 3600, 700)
ctrl.Name = "lblMAVerfuegbar"
ctrl.Caption = "=Dashboard_MitarbeiterAktiv()"
ctrl.FontSize = 28
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 32768

' Box 3: Offene Anfragen
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 101, 0, "", "", 8200, 1200, 3800, 1500)
ctrl.Name = "boxOffeneAnfragen"
ctrl.SpecialEffect = 2
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 8300, 1300, 3600, 300)
ctrl.Name = "lblOffeneAnfragenText"
ctrl.Caption = "Offene Anfragen"
ctrl.FontSize = 9
ctrl.TextAlign = 2

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 8300, 1650, 3600, 700)
ctrl.Name = "lblOffeneAnfragen"
ctrl.Caption = "=Dashboard_OffeneAnfragen()"
ctrl.FontSize = 28
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 16744448

' Box 4: Unterbesetzung
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 101, 0, "", "", 12200, 1200, 3800, 1500)
ctrl.Name = "boxUnterbesetzung"
ctrl.SpecialEffect = 2
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 12300, 1300, 3600, 300)
ctrl.Name = "lblUnterbesetzungText"
ctrl.Caption = "Unterbesetzt"
ctrl.FontSize = 9
ctrl.TextAlign = 2

Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 12300, 1650, 3600, 700)
ctrl.Name = "lblUnterbesetzung"
ctrl.Caption = "=Dashboard_Unterbesetzung()"
ctrl.FontSize = 28
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 255

' ============================================
' Unterformulare
' ============================================

' Label fuer Auftraege
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 200, 2900, 8000, 350)
ctrl.Name = "lblAuftraegeHeuteUF"
ctrl.Caption = "Auftraege heute (mit SOLL-IST)"
ctrl.FontSize = 11
ctrl.FontBold = True

' Unterformular Auftraege heute
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 112, 0, "", "", 200, 3300, 8000, 3000)
ctrl.Name = "subAuftraegeHeute"
ctrl.SourceObject = "sub_N_Dashboard_AuftraegeHeute"

' Label fuer Unterbesetzung
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 100, 0, "", "", 8400, 2900, 7800, 350)
ctrl.Name = "lblUnterbesetzungUF"
ctrl.Caption = "WARNUNG: Unterbesetzte Auftraege"
ctrl.FontSize = 11
ctrl.FontBold = True
ctrl.ForeColor = 255

' Unterformular Unterbesetzung
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 112, 0, "", "", 8400, 3300, 7800, 3000)
ctrl.Name = "subUnterbesetzung"
ctrl.SourceObject = "sub_N_Dashboard_Unterbesetzung"

' ============================================
' Buttons
' ============================================

' Button: Aktualisieren
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 104, 0, "", "", 200, 6500, 2500, 450)
ctrl.Name = "btnAktualisieren"
ctrl.Caption = "Aktualisieren"
ctrl.OnClick = "[Event Procedure]"

' Button: Zur Einsatzplanung
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 104, 0, "", "", 2900, 6500, 2500, 450)
ctrl.Name = "btnEinsatzplanung"
ctrl.Caption = "Einsatzplanung"
ctrl.OnClick = "[Event Procedure]"

' Button: Schliessen
Set ctrl = accessApp.CreateControl("frm_N_Dashboard", 104, 0, "", "", 14000, 6500, 2000, 450)
ctrl.Name = "btnSchliessen"
ctrl.Caption = "Schliessen"
ctrl.OnClick = "[Event Procedure]"

' Speichern
accessApp.DoCmd.Save 2, "frm_N_Dashboard"
accessApp.DoCmd.Close 2, "frm_N_Dashboard", 1

WScript.Echo "  Dashboard erstellt!"

' ============================================
' VBA-Code zum Formular hinzufuegen
' ============================================
WScript.Echo "Fuege VBA-Code hinzu..."

accessApp.DoCmd.OpenForm "frm_N_Dashboard", 1  ' Design-Ansicht

Dim vbe, proj, comp, cm, formCode

Set vbe = accessApp.VBE
Set proj = vbe.ActiveVBProject

For Each comp In proj.VBComponents
    If comp.Name = "Form_frm_N_Dashboard" Then
        Set cm = comp.CodeModule

        formCode = "" & vbCrLf
        formCode = formCode & "Private Sub btnAktualisieren_Click()" & vbCrLf
        formCode = formCode & "    Me.Requery" & vbCrLf
        formCode = formCode & "    Me.subAuftraegeHeute.Form.Requery" & vbCrLf
        formCode = formCode & "    Me.subUnterbesetzung.Form.Requery" & vbCrLf
        formCode = formCode & "    Me.Repaint" & vbCrLf
        formCode = formCode & "End Sub" & vbCrLf
        formCode = formCode & "" & vbCrLf
        formCode = formCode & "Private Sub btnEinsatzplanung_Click()" & vbCrLf
        formCode = formCode & "    DoCmd.OpenForm ""frm_Einsatzuebersicht_kpl""" & vbCrLf
        formCode = formCode & "End Sub" & vbCrLf
        formCode = formCode & "" & vbCrLf
        formCode = formCode & "Private Sub btnSchliessen_Click()" & vbCrLf
        formCode = formCode & "    DoCmd.Close acForm, Me.Name" & vbCrLf
        formCode = formCode & "End Sub" & vbCrLf
        formCode = formCode & "" & vbCrLf
        formCode = formCode & "Private Sub Form_Load()" & vbCrLf
        formCode = formCode & "    ' Auto-Refresh alle 60 Sekunden" & vbCrLf
        formCode = formCode & "    Me.TimerInterval = 60000" & vbCrLf
        formCode = formCode & "End Sub" & vbCrLf
        formCode = formCode & "" & vbCrLf
        formCode = formCode & "Private Sub Form_Timer()" & vbCrLf
        formCode = formCode & "    Call btnAktualisieren_Click" & vbCrLf
        formCode = formCode & "End Sub" & vbCrLf

        cm.AddFromString formCode
        Exit For
    End If
Next

accessApp.DoCmd.Save 2, "frm_N_Dashboard"
accessApp.DoCmd.Close 2, "frm_N_Dashboard", 1

WScript.Echo "  VBA-Code hinzugefuegt!"

' ============================================
' Kompilieren und speichern
' ============================================
WScript.Echo "Kompiliere und speichere..."

On Error Resume Next
accessApp.DoCmd.RunCommand 14  ' Kompilieren
On Error GoTo 0

' Aufraeumen
Set ctrl = Nothing
Set frm = Nothing
Set db = Nothing

accessApp.CloseCurrentDatabase
accessApp.Quit

Set accessApp = Nothing

WScript.Echo ""
WScript.Echo "============================================"
WScript.Echo "FERTIG! Dashboard-Formulare erstellt:"
WScript.Echo "  - frm_N_Dashboard (Hauptformular)"
WScript.Echo "  - sub_N_Dashboard_AuftraegeHeute"
WScript.Echo "  - sub_N_Dashboard_Unterbesetzung"
WScript.Echo "  - sub_N_Dashboard_OffeneAnfragen"
WScript.Echo "============================================"
