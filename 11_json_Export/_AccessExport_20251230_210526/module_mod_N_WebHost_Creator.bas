' ============================================
' mod_N_WebHost_Creator
' ============================================
' Erstellt das Formular frm_N_WebHost mit WebBrowser-Control
' zur Anzeige von HTML-Formularen in Access.
'
' Ausfuehren: CreateWebHostForm
' ============================================

Private Const HTML_PATH As String = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\"

Public Sub CreateWebHostForm()
    ' Erstellt das WebHost-Formular mit WebBrowser-Control

    On Error GoTo ErrorHandler

    Dim formName As String
    formName = "frm_N_WebHost"

    ' Pruefen ob Formular existiert
    Dim exists As Boolean
    exists = FormExists(formName)

    If exists Then
        If MsgBox("Formular " & formName & " existiert bereits." & vbCrLf & _
                  "Loeschen und neu erstellen?", vbYesNo + vbQuestion) = vbNo Then
            Exit Sub
        End If
        DoCmd.DeleteObject acForm, formName
    End If

    ' Neues Formular erstellen
    Dim frm As Form
    Set frm = Application.CreateForm

    ' Formular-Eigenschaften
    frm.caption = "HTML WebHost"
    frm.DefaultView = 0  ' Single Form
    frm.ScrollBars = 0   ' None
    frm.RecordSelectors = False
    frm.NavigationButtons = False
    frm.DividingLines = False
    frm.AutoCenter = True
    frm.PopUp = False
    frm.Modal = False
    frm.BorderStyle = 1  ' Thin

    ' Groesse: ca. 1200 x 800 Pixel
    frm.width = 18000  ' Twips

    ' Ungebundener Objektrahmen hinzufuegen
    Dim ctl As control
    Set ctl = Application.CreateControl(frm.Name, acObjectFrame, acDetail, "", "", 50, 50, 17900, 11900)
    ctl.Name = "ctlWebBrowser"

    ' Formular speichern
    Dim tempName As String
    tempName = frm.Name
    DoCmd.Save acForm, tempName
    DoCmd.Close acForm, tempName, acSaveYes

    ' Umbenennen
    DoCmd.Rename formName, acForm, tempName

    ' VBA-Code hinzufuegen
    Call AddVBACodeToForm(formName)

    MsgBox "Formular erstellt: " & formName & vbCrLf & vbCrLf & _
           "WICHTIG - Naechster Schritt:" & vbCrLf & _
           "1. Formular im Entwurf oeffnen" & vbCrLf & _
           "2. ctlWebBrowser anklicken" & vbCrLf & _
           "3. Rechtsklick -> Objekt einfuegen" & vbCrLf & _
           "4. 'Microsoft Web Browser' waehlen" & vbCrLf & vbCrLf & _
           "Dann testen mit:" & vbCrLf & _
           "DoCmd.OpenForm """ & formName & """", _
           vbInformation

    Exit Sub

ErrorHandler:
    MsgBox "Fehler: " & Err.description & " (Nr. " & Err.Number & ")", vbCritical
End Sub

Private Function FormExists(formName As String) As Boolean
    Dim obj As AccessObject
    For Each obj In CurrentProject.AllForms
        If obj.Name = formName Then
            FormExists = True
            Exit Function
        End If
    Next obj
    FormExists = False
End Function

Private Sub AddVBACodeToForm(formName As String)
    ' Fuegt VBA-Code zum Formular hinzu

    On Error GoTo ErrorHandler

    ' Formular im Entwurfsmodus oeffnen
    DoCmd.OpenForm formName, acDesign

    Dim vbe As Object
    Dim proj As Object
    Dim comp As Object
    Dim codeMod As Object

    Set vbe = Application.vbe
    Set proj = vbe.ActiveVBProject

    ' Form-Modul finden
    For Each comp In proj.VBComponents
        If comp.Name = "Form_" & formName Then
            Set codeMod = comp.codeModule

            ' Code einfuegen
            Dim code As String
            code = GetFormVBACode()

            codeMod.InsertLines codeMod.CountOfLines + 1, code
            Exit For
        End If
    Next comp

    ' Formular speichern und schliessen
    DoCmd.Close acForm, formName, acSaveYes

    Exit Sub

ErrorHandler:
    Debug.Print "VBA-Code Fehler: " & Err.description
    DoCmd.Close acForm, formName, acSaveYes
End Sub

Private Function GetFormVBACode() As String
    ' Gibt den VBA-Code fuer das Formular zurueck

    Dim s As String

    s = s & vbCrLf & "Private Sub Form_Load()"
    s = s & vbCrLf & "    ' HTML-Formular laden"
    s = s & vbCrLf & "    Dim htmlFile As String"
    s = s & vbCrLf & "    htmlFile = """ & HTML_PATH & "index.html"""
    s = s & vbCrLf & ""
    s = s & vbCrLf & "    ' Parameter pruefen (uebergeben via OpenArgs)"
    s = s & vbCrLf & "    If Not IsNull(Me.OpenArgs) And Me.OpenArgs <> """" Then"
    s = s & vbCrLf & "        htmlFile = """ & HTML_PATH & """ & Me.OpenArgs & "".html"""
    s = s & vbCrLf & "    End If"
    s = s & vbCrLf & ""
    s = s & vbCrLf & "    ' WebBrowser navigieren"
    s = s & vbCrLf & "    On Error Resume Next"
    s = s & vbCrLf & "    Me.ctlWebBrowser.Object.Navigate htmlFile"
    s = s & vbCrLf & "End Sub"
    s = s & vbCrLf & ""
    s = s & vbCrLf & "Private Sub Form_Resize()"
    s = s & vbCrLf & "    ' WebBrowser an Formulargroesse anpassen"
    s = s & vbCrLf & "    On Error Resume Next"
    s = s & vbCrLf & "    Me.ctlWebBrowser.Width = Me.InsideWidth - 100"
    s = s & vbCrLf & "    Me.ctlWebBrowser.Height = Me.InsideHeight - 100"
    s = s & vbCrLf & "End Sub"
    s = s & vbCrLf & ""
    s = s & vbCrLf & "Public Sub LoadHTMLForm(formName As String)"
    s = s & vbCrLf & "    ' Laedt ein bestimmtes HTML-Formular"
    s = s & vbCrLf & "    Dim htmlFile As String"
    s = s & vbCrLf & "    htmlFile = """ & HTML_PATH & """ & formName & "".html"""
    s = s & vbCrLf & "    Me.ctlWebBrowser.Object.Navigate htmlFile"
    s = s & vbCrLf & "End Sub"
    s = s & vbCrLf & ""
    s = s & vbCrLf & "Public Sub RefreshHTML()"
    s = s & vbCrLf & "    ' Aktualisiert die HTML-Seite"
    s = s & vbCrLf & "    Me.ctlWebBrowser.Object.Refresh"
    s = s & vbCrLf & "End Sub"

    GetFormVBACode = s
End Function

' ============================================
' HILFSFUNKTIONEN ZUM OEFFNEN VON HTML
' ============================================

Public Sub OpenHTMLForm(htmlFormName As String)
    ' Oeffnet ein HTML-Formular im WebHost
    '
    ' Beispiele:
    '   OpenHTMLForm "frm_N_Kundenstammblatt"
    '   OpenHTMLForm "frm_N_Mitarbeiterstammblatt"

    DoCmd.OpenForm "frm_N_WebHost", , , , , , htmlFormName
End Sub

Public Sub OpenHTMLKundenstamm()
    OpenHTMLForm "frm_N_Kundenstammblatt"
End Sub

Public Sub OpenHTMLMitarbeiter()
    OpenHTMLForm "frm_N_Mitarbeiterstammblatt"
End Sub

Public Sub OpenHTMLDienstplan()
    OpenHTMLForm "frm_N_Dienstplanuebersicht"
End Sub

Public Sub OpenHTMLAbwesenheit()
    OpenHTMLForm "frm_N_Abwesenheitsplanung"
End Sub

Public Sub OpenHTMLAuftrag()
    OpenHTMLForm "frm_VA_Auftragstamm_HTML"
End Sub

Public Sub OpenHTMLIndex()
    ' Oeffnet die Index-Seite
    DoCmd.OpenForm "frm_N_WebHost"
End Sub