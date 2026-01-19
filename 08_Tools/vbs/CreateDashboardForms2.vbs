' ============================================
' CreateDashboardForms2.vbs - Korrigierte Version
' Erstellt Dashboard-Formulare in Access
' ============================================

Option Explicit

Dim accessApp
Dim db
Dim frm
Dim ctrl
Dim frontendPath
Dim frmName

frontendPath = "\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - Diverses\Consys_FE_N_Test_Claude_GPT - Kopie (6).accdb"

' Access starten
WScript.Echo "Starte Access..."
Set accessApp = CreateObject("Access.Application")
accessApp.Visible = True  ' Sichtbar fuer Debugging
accessApp.AutomationSecurity = 1

WScript.Echo "Oeffne Datenbank: " & frontendPath
accessApp.OpenCurrentDatabase frontendPath, False
WScript.Sleep 2000

Set db = accessApp.CurrentDb

' ============================================
' Funktion: Formular erstellen und speichern
' ============================================
Function CreateDatasheetForm(formName, queryName, captionText)
    On Error Resume Next

    WScript.Echo "Erstelle " & formName & "..."

    ' Loesche falls vorhanden
    accessApp.DoCmd.DeleteObject 2, formName
    Err.Clear

    ' Neues Formular erstellen
    Set frm = accessApp.CreateForm()
    WScript.Sleep 500

    If Err.Number <> 0 Then
        WScript.Echo "  FEHLER bei CreateForm: " & Err.Description
        CreateDatasheetForm = False
        Exit Function
    End If

    ' Konfigurieren
    frm.RecordSource = queryName
    frm.DefaultView = 2  ' Datenblatt
    frm.ViewsAllowed = 2
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    frm.AllowEdits = False
    frm.NavigationButtons = False
    frm.RecordSelectors = True
    frm.Caption = captionText

    ' Speichern - WICHTIG: Formular ist noch offen!
    accessApp.DoCmd.Close 2, , 1  ' Aktives Formular schliessen mit Speichern
    WScript.Sleep 500

    ' Umbenennen (war "Formular1" oder aehnlich)
    ' Wir muessen den letzten erstellten Formular-Namen finden
    Dim lastForm
    lastForm = ""
    Dim obj
    For Each obj In accessApp.CurrentProject.AllForms
        If Left(obj.Name, 8) = "Formular" Or Left(obj.Name, 4) = "Form" Then
            If obj.Name > lastForm Then lastForm = obj.Name
        End If
    Next

    If lastForm <> "" Then
        accessApp.DoCmd.Rename formName, 2, lastForm
        WScript.Echo "  Erstellt (umbenannt von " & lastForm & ")"
    Else
        WScript.Echo "  WARNUNG: Konnte Formular nicht umbenennen"
    End If

    CreateDatasheetForm = True
End Function

' ============================================
' Unterformulare erstellen
' ============================================
WScript.Echo ""
WScript.Echo "Erstelle Unterformulare..."
WScript.Echo "----------------------------------------"

Call CreateDatasheetForm("sub_N_Dashboard_AuftraegeHeute", "qry_N_Dashboard_AuftraegeHeute", "Auftraege Heute")
WScript.Sleep 500

Call CreateDatasheetForm("sub_N_Dashboard_Unterbesetzung", "qry_N_Dashboard_Unterbesetzung", "Unterbesetzte Auftraege")
WScript.Sleep 500

Call CreateDatasheetForm("sub_N_Dashboard_OffeneAnfragen", "qry_N_Dashboard_OffeneAnfragen", "Offene Anfragen")
WScript.Sleep 500

' ============================================
' Hauptformular erstellen
' ============================================
WScript.Echo ""
WScript.Echo "Erstelle Hauptformular frm_N_Dashboard..."
WScript.Echo "----------------------------------------"

On Error Resume Next
accessApp.DoCmd.DeleteObject 2, "frm_N_Dashboard"
Err.Clear

Set frm = accessApp.CreateForm()
WScript.Sleep 500

' Grundeinstellungen
frm.Caption = "CONSYS Dashboard - Live-Uebersicht"
frm.RecordSelectors = False
frm.NavigationButtons = False
frm.DividingLines = False
frm.ScrollBars = 0
frm.BorderStyle = 1
frm.AutoCenter = True
frm.Width = 17000
frm.Section(0).Height = 7500
frm.Section(0).BackColor = 15921906

' Titel
Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 200, 100, 16500, 600)
ctrl.Name = "lblTitel"
ctrl.Caption = "CONSYS DASHBOARD - Live-Uebersicht"
ctrl.FontSize = 18
ctrl.FontBold = True
ctrl.BackStyle = 0

' Datum
Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 200, 750, 8000, 350)
ctrl.Name = "lblDatum"
ctrl.Caption = "=Format(Date(),'dddd, dd. mmmm yyyy')"
ctrl.FontSize = 10
ctrl.ForeColor = 8421504
ctrl.BackStyle = 0

' ============================================
' Kennzahlen-Boxen
' ============================================

' Box 1: Auftraege heute
Set ctrl = accessApp.CreateControl(frm.Name, 101, 0, "", "", 200, 1200, 3800, 1400)
ctrl.SpecialEffect = 2
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 300, 1300, 3600, 280)
ctrl.Caption = "Auftraege heute"
ctrl.FontSize = 9
ctrl.TextAlign = 2
ctrl.BackStyle = 0

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 300, 1600, 3600, 700)
ctrl.Name = "lblKZ1"
ctrl.Caption = "=Dashboard_AuftraegeHeute()"
ctrl.FontSize = 26
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 8388608
ctrl.BackStyle = 0

' Box 2: Aktive MA
Set ctrl = accessApp.CreateControl(frm.Name, 101, 0, "", "", 4200, 1200, 3800, 1400)
ctrl.SpecialEffect = 2
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 4300, 1300, 3600, 280)
ctrl.Caption = "Aktive Mitarbeiter"
ctrl.FontSize = 9
ctrl.TextAlign = 2
ctrl.BackStyle = 0

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 4300, 1600, 3600, 700)
ctrl.Name = "lblKZ2"
ctrl.Caption = "=Dashboard_MitarbeiterAktiv()"
ctrl.FontSize = 26
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 32768
ctrl.BackStyle = 0

' Box 3: Offene Anfragen
Set ctrl = accessApp.CreateControl(frm.Name, 101, 0, "", "", 8200, 1200, 3800, 1400)
ctrl.SpecialEffect = 2
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 8300, 1300, 3600, 280)
ctrl.Caption = "Offene Anfragen"
ctrl.FontSize = 9
ctrl.TextAlign = 2
ctrl.BackStyle = 0

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 8300, 1600, 3600, 700)
ctrl.Name = "lblKZ3"
ctrl.Caption = "=Dashboard_OffeneAnfragen()"
ctrl.FontSize = 26
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 16744448
ctrl.BackStyle = 0

' Box 4: Unterbesetzung
Set ctrl = accessApp.CreateControl(frm.Name, 101, 0, "", "", 12200, 1200, 3800, 1400)
ctrl.SpecialEffect = 2
ctrl.BackColor = 16777215

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 12300, 1300, 3600, 280)
ctrl.Caption = "Unterbesetzt"
ctrl.FontSize = 9
ctrl.TextAlign = 2
ctrl.BackStyle = 0

Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 12300, 1600, 3600, 700)
ctrl.Name = "lblKZ4"
ctrl.Caption = "=Dashboard_Unterbesetzung()"
ctrl.FontSize = 26
ctrl.FontBold = True
ctrl.TextAlign = 2
ctrl.ForeColor = 255
ctrl.BackStyle = 0

' ============================================
' Unterformular-Bereiche
' ============================================

' Label Auftraege
Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 200, 2800, 8000, 300)
ctrl.Caption = "Auftraege heute (SOLL-IST)"
ctrl.FontSize = 11
ctrl.FontBold = True
ctrl.BackStyle = 0

' Unterformular Auftraege
Set ctrl = accessApp.CreateControl(frm.Name, 112, 0, "", "", 200, 3150, 8000, 2800)
ctrl.Name = "subAuftraegeHeute"
ctrl.SourceObject = "sub_N_Dashboard_AuftraegeHeute"

' Label Unterbesetzung
Set ctrl = accessApp.CreateControl(frm.Name, 100, 0, "", "", 8400, 2800, 7800, 300)
ctrl.Caption = "WARNUNG: Unterbesetzt"
ctrl.FontSize = 11
ctrl.FontBold = True
ctrl.ForeColor = 255
ctrl.BackStyle = 0

' Unterformular Unterbesetzung
Set ctrl = accessApp.CreateControl(frm.Name, 112, 0, "", "", 8400, 3150, 7800, 2800)
ctrl.Name = "subUnterbesetzung"
ctrl.SourceObject = "sub_N_Dashboard_Unterbesetzung"

' ============================================
' Buttons
' ============================================

Set ctrl = accessApp.CreateControl(frm.Name, 104, 0, "", "", 200, 6100, 2300, 400)
ctrl.Name = "btnAktualisieren"
ctrl.Caption = "Aktualisieren"

Set ctrl = accessApp.CreateControl(frm.Name, 104, 0, "", "", 2700, 6100, 2300, 400)
ctrl.Name = "btnEinsatzplanung"
ctrl.Caption = "Einsatzplanung"

Set ctrl = accessApp.CreateControl(frm.Name, 104, 0, "", "", 5200, 6100, 2300, 400)
ctrl.Name = "btnAuftraege"
ctrl.Caption = "Alle Auftraege"

Set ctrl = accessApp.CreateControl(frm.Name, 104, 0, "", "", 14200, 6100, 2000, 400)
ctrl.Name = "btnSchliessen"
ctrl.Caption = "Schliessen"

' Speichern
WScript.Sleep 500
accessApp.DoCmd.Close 2, , 1

' Umbenennen
Dim lastForm
lastForm = ""
For Each obj In accessApp.CurrentProject.AllForms
    If Left(obj.Name, 8) = "Formular" Or Left(obj.Name, 4) = "Form" Then
        If obj.Name > lastForm Then lastForm = obj.Name
    End If
Next

If lastForm <> "" Then
    accessApp.DoCmd.Rename "frm_N_Dashboard", 2, lastForm
    WScript.Echo "  Hauptformular erstellt!"
End If

' ============================================
' Kompilieren und speichern
' ============================================
WScript.Echo ""
WScript.Echo "Speichere Datenbank..."
accessApp.DoCmd.RunCommand 3  ' Speichern

' Access schliessen
accessApp.CloseCurrentDatabase
accessApp.Quit

Set ctrl = Nothing
Set frm = Nothing
Set db = Nothing
Set accessApp = Nothing

WScript.Echo ""
WScript.Echo "============================================"
WScript.Echo "FERTIG! Folgende Objekte wurden erstellt:"
WScript.Echo ""
WScript.Echo "FORMULARE:"
WScript.Echo "  - frm_N_Dashboard (Haupt-Dashboard)"
WScript.Echo "  - sub_N_Dashboard_AuftraegeHeute"
WScript.Echo "  - sub_N_Dashboard_Unterbesetzung"
WScript.Echo "  - sub_N_Dashboard_OffeneAnfragen"
WScript.Echo ""
WScript.Echo "FUNKTIONEN (in mod_N_Dashboard):"
WScript.Echo "  - Dashboard_AuftraegeHeute()"
WScript.Echo "  - Dashboard_MitarbeiterAktiv()"
WScript.Echo "  - Dashboard_OffeneAnfragen()"
WScript.Echo "  - Dashboard_Unterbesetzung()"
WScript.Echo "  - Konflikt_Pruefen()"
WScript.Echo "  - Schnell_Zuordnen()"
WScript.Echo "  - Ampel_Farbe()"
WScript.Echo "============================================"
