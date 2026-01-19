Option Compare Database
Option Explicit


' ============================================
' mod_N_Menu_Interceptor - Leitet Menue-Aufrufe um
' ============================================
' Dieses Modul leitet bestimmte Formular-Aufrufe auf HTML um
' ============================================

Private bUseHTML As Boolean

Public Sub InitHTMLMode()
    ' Aktiviert den HTML-Modus
    bUseHTML = True
    TempVars.Add "UseHTMLForms", True
End Sub

Public Sub DisableHTMLMode()
    ' Deaktiviert den HTML-Modus
    bUseHTML = False
    TempVars.Remove "UseHTMLForms"
End Sub

Public Function IsHTMLModeActive() As Boolean
    ' Prueft ob HTML-Modus aktiv ist
    On Error Resume Next
    IsHTMLModeActive = (TempVars("UseHTMLForms").Value = True)
    On Error GoTo 0
End Function

' ============================================
' FORMULAR-OEFFNER (ersetzt DoCmd.OpenForm)
' ============================================

'Public Sub OpenFormularSmart(formName As String, Optional viewMode As Integer = 0)
'    ' Oeffnet ein Formular - entweder Access oder HTML Version
'    ' viewMode: 0 = Normal, 1 = Design, 2 = Preview
'
'    If viewMode <> 0 Then
'        ' Design/Preview: immer Access-Formular
'        DoCmd.OpenForm formName, viewMode
'        Exit Sub
'    End If
'
'    ' Pruefe ob HTML-Version verfuegbar
'    Select Case LCase(formName)
'        Case "frm_ma_mitarbeiterstamm", "mitarbeiterstamm", "mitarbeiter"
'            If IsHTMLModeActive() Then
'                HTML_Mitarbeiterstammblatt
'            Else
'                DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
'            End If
'
'        Case "frm_kd_kundenstamm", "kundenstamm", "kunden"
'            If IsHTMLModeActive() Then
'                HTML_Kundenstammblatt
'            Else
'                DoCmd.OpenForm "frm_KD_Kundenstamm"
'            End If
'
'        Case "frm_ma_nverfuegzeiten_si", "abwesenheit", "abwesenheitsplanung"
'            If IsHTMLModeActive() Then
'                HTML_Abwesenheitsplanung
'            Else
'                DoCmd.OpenForm "frm_MA_NVerfuegZeiten_Si"
'            End If
'
'        Case "frm_ma_va_schnellauswahl", "mitarbeiterauswahl", "maauswahl"
'            If IsHTMLModeActive() Then
'                HTML_Mitarbeiterauswahl
'            Else
'                DoCmd.OpenForm "frm_MA_VA_Schnellauswahl"
'            End If
'
'        Case Else
'            ' Alle anderen: normales Access-Formular
'            DoCmd.OpenForm formName, viewMode
'    End Select
'End Sub

' ============================================
' DIREKTE HTML-AUFRUFE (fuer Menue-Buttons)
' ============================================

'Public Sub Cmd_HTML_Mitarbeiter()
'    ' Direkter Aufruf fuer Mitarbeiter-Button
'    HTML_Mitarbeiterstammblatt
'End Sub

'Public Sub Cmd_HTML_Kunden()
'    ' Direkter Aufruf fuer Kunden-Button
'    HTML_Kundenstammblatt
'End Sub
'
'Public Sub Cmd_HTML_Abwesenheit()
'    ' Direkter Aufruf fuer Abwesenheit-Button
'    HTML_Abwesenheitsplanung
'End Sub
'
'Public Sub Cmd_HTML_MAauswahl()
'    ' Direkter Aufruf fuer MA-Auswahl-Button
'    HTML_Mitarbeiterauswahl
'End Sub
'
'Public Sub Cmd_HTML_Dienstplan()
'    ' Direkter Aufruf fuer Dienstplan-Button
'    HTML_Dienstplanuebersicht
'End Sub
'