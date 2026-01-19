' ============================================
' mod_N_HTML_Ansicht_Wechsler
' VBA Modul fuer nahtlosen Wechsel zwischen Access und HTML Ansicht
' ============================================
' Version 2.0 - Stand: 14.12.2025
' Aktualisiert fuer alle HTML-Formulare in frms_HTML_alle
'
' VERWENDUNG IN EINEM ACCESS-FORMULAR:
' 1. Button "HTML Ansicht" erstellen
' 2. OnClick: =HTML_Ansicht_Button_Click([Form])
'
' Das Modul oeffnet die HTML-Datei im Standard-Browser
' ============================================

' Pfad zu den HTML-Dateien (NEUER PFAD!)
Private Const HTML_BASE_PATH As String = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\frms_HTML_alle\"

' Mapping von Access-Formularnamen zu HTML-Dateinamen
Private mFormMapping As Object ' Dictionary

' ============================================
' INITIALISIERUNG
' ============================================

Private Sub InitFormMapping()
    ' Erstellt das Mapping zwischen Access-Formularen und HTML-Dateien

    If mFormMapping Is Nothing Then
        Set mFormMapping = CreateObject("Scripting.Dictionary")
    End If

    ' Formulare leeren und neu befuellen
    mFormMapping.RemoveAll

    ' === MAPPING: Access-Formularname -> HTML-Dateiname ===
    ' Format: mFormMapping.Add "AccessFormularName", "HTML_Dateiname.html"
    ' Stand: 14.12.2025 - Alle verfuegbaren HTML-Formulare

    ' === HAUPTFORMULARE ===
    mFormMapping.Add "frmTop_Login", "frmTop_Login.html"
    mFormMapping.Add "frm_Startmenue", "frm_Startmenue.html"
    mFormMapping.Add "frm_Menuefuehrung", "frm_Startmenue.html"

    ' === PLANUNG & DIENSTPLAN ===
    ' Dienstplanuebersicht
    mFormMapping.Add "frm_DP_Dienstplan_MA", "frm_N_Dienstplanuebersicht.html"
    mFormMapping.Add "frm_DP_Dienstplan_Objekt", "frm_N_Dienstplanuebersicht.html"
    mFormMapping.Add "frm_Einsatzuebersicht_kpl", "frm_N_Dienstplanuebersicht.html"
    mFormMapping.Add "frm_N_Dienstplanuebersicht", "frm_N_Dienstplanuebersicht.html"

    ' Planungsuebersicht
    mFormMapping.Add "frm_N_MA_Monatsuebersicht", "frm_N_Planungsuebersicht.html"
    mFormMapping.Add "frm_N_Planungsuebersicht", "frm_N_Planungsuebersicht.html"

    ' Abwesenheitsplanung
    mFormMapping.Add "frm_Abwesenheiten", "frm_N_Abwesenheitsplanung.html"
    mFormMapping.Add "frmTop_MA_Abwesenheitsplanung", "frm_N_Abwesenheitsplanung.html"
    mFormMapping.Add "frm_MA_NVerfuegZeiten_Si", "frm_N_Abwesenheitsplanung.html"
    mFormMapping.Add "frm_N_Abwesenheitsplanung", "frm_N_Abwesenheitsplanung.html"

    ' Abwesenheitsstatistik
    mFormMapping.Add "frm_abwesenheitsuebersicht", "frm_N_Abwesenheitsstatistik.html"
    mFormMapping.Add "frm_N_Abwesenheitsstatistik", "frm_N_Abwesenheitsstatistik.html"

    ' === STAMMDATEN ===
    ' Mitarbeiterstammblatt
    mFormMapping.Add "frm_MA_Mitarbeiterstamm", "frm_N_Mitarbeiterstammblatt.html"
    mFormMapping.Add "frm_N_Mitarbeiterstammblatt", "frm_N_Mitarbeiterstammblatt.html"

    ' Kundenstammblatt
    mFormMapping.Add "frm_KD_Kundenstamm", "frm_N_Kundenstammblatt.html"
    mFormMapping.Add "frm_N_Kundenstammblatt", "frm_N_Kundenstammblatt.html"

    ' Auftragsverwaltung
    mFormMapping.Add "frm_VA_Auftragstamm", "frm_VA_Auftragstamm_HTML.html"
    mFormMapping.Add "frm_N_VA_Auftragstamm_HTML", "frm_VA_Auftragstamm_HTML.html"
    mFormMapping.Add "frm_Auftragsuebersicht_neu", "frm_VA_Auftragstamm_HTML.html"
    mFormMapping.Add "frmTop_VA_Auftrag_Neu", "frm_VA_Auftragstamm_HTML.html"

    ' Objektverwaltung
    mFormMapping.Add "frm_OB_Objekt", "frm_OB_Objekt.html"

    ' Mitarbeiterauswahl
    mFormMapping.Add "frm_MA_VA_Schnellauswahl", "frm_N_Mitarbeiterauswahl.html"
    mFormMapping.Add "frm_MA_VA_Positionszuordnung", "frm_N_Mitarbeiterauswahl.html"
    mFormMapping.Add "frm_N_MA_VA_Positionszuordnung", "frm_N_Mitarbeiterauswahl.html"
    mFormMapping.Add "frm_N_Mitarbeiterauswahl", "frm_N_Mitarbeiterauswahl.html"

    ' Bewerberverwaltung
    mFormMapping.Add "frm_N_MA_Bewerber_Verarbeitung", "frm_N_Bewerberverwaltung.html"
    mFormMapping.Add "frm_N_Bewerberverwaltung", "frm_N_Bewerberverwaltung.html"

    ' === WEITERE FUNKTIONEN ===
    ' Offene Mail Anfragen
    mFormMapping.Add "frm_MA_Offene_Anfragen", "frm_MA_Offene_Anfragen.html"

    ' Serien E-Mail
    mFormMapping.Add "frm_MA_Serien_eMail_Auftrag", "frm_MA_Serien_eMail.html"
    mFormMapping.Add "frm_MA_Serien_eMail_dienstplan", "frm_MA_Serien_eMail.html"
    mFormMapping.Add "frm_MA_Serien_eMail_Vorlage", "frm_MA_Serien_eMail.html"

    ' Rechnungen
    mFormMapping.Add "frm_Rechnungen_bezahlt_offen", "frm_Rechnungen.html"
    mFormMapping.Add "frmTop_Rch_Berechnungsliste", "frm_Rechnungen.html"
    mFormMapping.Add "frmTop_RechnungsStamm", "frm_Rechnungen.html"

    ' Zeitkonten
    mFormMapping.Add "zfrm_MA_ZK_top", "frm_Zeitkonten.html"
    mFormMapping.Add "zfrm_ZUO_Stunden", "frm_Zeitkonten.html"

    ' Dashboard
    mFormMapping.Add "frm_N_Dashboard", "frm_N_Dashboard.html"

    ' Einstellungen
    mFormMapping.Add "frmStamm_EigeneFirma", "frm_Einstellungen.html"

End Sub

' ============================================
' OEFFENTLICHE FUNKTIONEN
' ============================================

Public Function HTML_Ansicht_Zeigen(frm As Form) As Boolean
    ' Zeigt die HTML-Ansicht fuer das uebergebene Formular an
    '
    ' Parameter:
    '   frm - Das Access-Formular, dessen HTML-Version angezeigt werden soll
    '
    ' Rueckgabe:
    '   True wenn erfolgreich, False wenn kein HTML-Mapping existiert

    On Error GoTo ErrorHandler

    InitFormMapping

    Dim formName As String
    formName = frm.Name

    ' Pruefen ob HTML-Mapping existiert
    If Not mFormMapping.exists(formName) Then
        MsgBox "Fuer das Formular '" & formName & "' existiert keine HTML-Version." & vbCrLf & vbCrLf & _
               "Verfuegbare HTML-Formulare finden Sie unter:" & vbCrLf & _
               HTML_BASE_PATH & "index.html", _
               vbInformation, "HTML-Ansicht"
        HTML_Ansicht_Zeigen = False
        Exit Function
    End If

    ' HTML-Datei ermitteln
    Dim htmlFile As String
    htmlFile = HTML_BASE_PATH & mFormMapping(formName)

    ' Pruefen ob Datei existiert
    If Dir(htmlFile) = "" Then
        MsgBox "HTML-Datei nicht gefunden: " & htmlFile, vbCritical, "Fehler"
        HTML_Ansicht_Zeigen = False
        Exit Function
    End If

    ' HTML im Standard-Browser oeffnen
    Shell "cmd /c start """" """ & htmlFile & """", vbHide

    HTML_Ansicht_Zeigen = True
    Exit Function

ErrorHandler:
    MsgBox "Fehler beim Anzeigen der HTML-Ansicht: " & Err.description, vbCritical
    HTML_Ansicht_Zeigen = False
End Function

Public Sub HTML_Ansicht_Button_Click(frm As Form)
    ' Standard-OnClick Handler fuer den "HTML Ansicht" Button
    '
    ' Verwendung im Button:
    '   OnClick: =HTML_Ansicht_Button_Click([Form])

    Call HTML_Ansicht_Zeigen(frm)
End Sub

Public Function HTML_Hat_HTML_Version(formName As String) As Boolean
    ' Prueft ob fuer ein Formular eine HTML-Version existiert
    '
    ' Parameter:
    '   formName - Name des Access-Formulars
    '
    ' Rueckgabe:
    '   True wenn HTML-Version existiert

    InitFormMapping
    HTML_Hat_HTML_Version = mFormMapping.exists(formName)
End Function

Public Function HTML_GetHTMLPath(formName As String) As String
    ' Gibt den Pfad zur HTML-Datei zurueck
    '
    ' Parameter:
    '   formName - Name des Access-Formulars
    '
    ' Rueckgabe:
    '   Vollstaendiger Pfad zur HTML-Datei oder leer wenn nicht vorhanden

    InitFormMapping

    If mFormMapping.exists(formName) Then
        HTML_GetHTMLPath = HTML_BASE_PATH & mFormMapping(formName)
    Else
        HTML_GetHTMLPath = ""
    End If
End Function

' ============================================
' HILFSFUNKTION: ALLE FORMULARE AUFLISTEN
' ============================================

Public Sub HTML_ListeFormulare()
    ' Listet alle Access-Formulare auf, die eine HTML-Version haben
    '
    ' Ausgabe im Direktfenster (Strg+G)

    InitFormMapping

    Debug.Print "============================================"
    Debug.Print "Formulare mit HTML-Version (Stand: 14.12.2025)"
    Debug.Print "Pfad: " & HTML_BASE_PATH
    Debug.Print "============================================"

    Dim key As Variant
    For Each key In mFormMapping.Keys
        Debug.Print "  " & key & " -> " & mFormMapping(key)
    Next key

    Debug.Print "============================================"
    Debug.Print "Gesamt: " & mFormMapping.Count & " Zuordnungen"
    Debug.Print ""
    Debug.Print "Button-Aufruf: =HTML_Ansicht_Button_Click([Form])"
    Debug.Print "============================================"
End Sub

' ============================================
' INDEX OEFFNEN
' ============================================

Public Sub HTML_Index_Oeffnen()
    ' Oeffnet die Index-Uebersicht aller HTML-Formulare

    Dim indexFile As String
    indexFile = HTML_BASE_PATH & "index.html"

    If Dir(indexFile) <> "" Then
        Shell "cmd /c start """" """ & indexFile & """", vbHide
    Else
        MsgBox "Index-Datei nicht gefunden: " & indexFile, vbCritical
    End If
End Sub