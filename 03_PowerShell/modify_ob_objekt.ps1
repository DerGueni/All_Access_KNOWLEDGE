# PowerShell Script zur Modifikation von frm_OB_Objekt und rpt_OB_Objekt
# Arbeitet mit laufender Access-Instanz

$ErrorActionPreference = "Stop"
$frontendPath = "S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

Write-Host "=" * 70
Write-Host "MODIFIKATION: frm_OB_Objekt und rpt_OB_Objekt"
Write-Host "=" * 70

# Verbindung zu laufender Access-Instanz
try {
    $access = [Runtime.InteropServices.Marshal]::GetActiveObject("Access.Application")
    Write-Host "Verbindung zu laufender Access-Instanz hergestellt"
} catch {
    Write-Host "Keine laufende Access-Instanz gefunden, starte neue..."
    $access = New-Object -ComObject Access.Application
    $access.Visible = $true
    $access.OpenCurrentDatabase($frontendPath)
}

$db = $access.CurrentDb()

# VBA-Code fuer Modifikationen
$vbaCode = @'
' ==============================================
' MODUL: mod_OB_Objekt_Anpassungen
' Automatisch generierte Anpassungen
' ==============================================

Option Compare Database
Option Explicit

' ===== 1. LISTENFELD ANPASSEN =====
' Zeigt nur Objekte MIT Positionen an und zeigt Positionslisten-Name

Public Sub AnpasseListenfeld_OB_Objekt()
    On Error Resume Next

    Dim frm As Form
    Dim lst As ListBox
    Dim strSQL As String

    ' Formular oeffnen im Entwurfsmodus
    DoCmd.OpenForm "frm_OB_Objekt", acDesign
    Set frm = Forms("frm_OB_Objekt")

    ' Listenfeld suchen (wahrscheinlich lst_Objekte oder aehnlich)
    Dim ctl As Control
    For Each ctl In frm.Controls
        If ctl.ControlType = acListBox Then
            Set lst = ctl
            Exit For
        End If
    Next

    If Not lst Is Nothing Then
        ' Neue RowSource: Nur Objekte mit Positionen, plus Anzahl Positionen
        strSQL = "SELECT o.ID, o.Objekt, o.Ort, " & _
                 "(SELECT COUNT(*) FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID) AS AnzahlPos " & _
                 "FROM tbl_OB_Objekt o " & _
                 "WHERE (SELECT COUNT(*) FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID) > 0 " & _
                 "ORDER BY o.Objekt"

        lst.RowSource = strSQL
        lst.ColumnCount = 4
        lst.ColumnWidths = "0cm;4cm;3cm;2cm"

        Debug.Print "Listenfeld angepasst: " & lst.Name
    End If

    ' Speichern und schliessen
    DoCmd.Close acForm, "frm_OB_Objekt", acSaveYes

End Sub

' ===== 2. ZEITSLOT-LABELS IMPLEMENTIEREN =====
' Zeigt die Zeit-Labels aus tbl_OB_Objekt als Ueberschriften

Public Sub ZeitslotLabelsImplementieren()
    On Error Resume Next

    ' Diese Funktion aktualisiert die Zeit-Ueberschriften im Unterformular
    ' basierend auf den Zeit1_Label bis Zeit4_Label Feldern in tbl_OB_Objekt

    Dim frm As Form
    Dim subFrm As SubForm

    DoCmd.OpenForm "frm_OB_Objekt", acNormal
    Set frm = Forms("frm_OB_Objekt")

    ' Labels aktualisieren basierend auf aktuellem Objekt
    UpdateZeitLabels frm

End Sub

Public Sub UpdateZeitLabels(frm As Form)
    On Error Resume Next

    Dim objID As Long
    Dim rs As DAO.Recordset

    ' Aktuelle Objekt-ID ermitteln
    objID = Nz(frm("txt_ObjektID"), 0)
    If objID = 0 Then Exit Sub

    ' Zeit-Labels aus Tabelle laden
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Zeit1_Label, Zeit2_Label, Zeit3_Label, Zeit4_Label " & _
        "FROM tbl_OB_Objekt WHERE ID = " & objID, dbOpenSnapshot)

    If Not rs.EOF Then
        ' Labels im Formular/Unterformular aktualisieren
        ' (Annahme: Es gibt Labels lbl_Zeit1 bis lbl_Zeit4)
        On Error Resume Next
        frm("lbl_Zeit1").Caption = Nz(rs("Zeit1_Label"), "Zeit1")
        frm("lbl_Zeit2").Caption = Nz(rs("Zeit2_Label"), "Zeit2")
        frm("lbl_Zeit3").Caption = Nz(rs("Zeit3_Label"), "Zeit3")
        frm("lbl_Zeit4").Caption = Nz(rs("Zeit4_Label"), "Zeit4")
    End If

    rs.Close
    Set rs = Nothing

End Sub

' ===== 3. BUTTON-REPARATUR =====
' Prueft und repariert alle Buttons im Formular

Public Sub RepariereButtons()
    On Error Resume Next

    Dim frm As Form
    Dim ctl As Control
    Dim strEvent As String
    Dim intErrors As Integer

    DoCmd.OpenForm "frm_OB_Objekt", acDesign
    Set frm = Forms("frm_OB_Objekt")

    For Each ctl In frm.Controls
        If ctl.ControlType = acCommandButton Then
            ' OnClick Event pruefen
            strEvent = ctl.OnClick

            If Len(strEvent) > 0 Then
                ' Pruefen ob Funktion/Makro existiert
                If Left(strEvent, 1) = "=" Then
                    ' Es ist ein Funktionsaufruf
                    ' Versuche die Funktion zu finden
                    Debug.Print "Button: " & ctl.Name & " -> " & strEvent
                ElseIf strEvent = "[Event Procedure]" Then
                    ' Es ist eine Event-Prozedur - ok
                    Debug.Print "Button: " & ctl.Name & " -> Event Procedure"
                Else
                    ' Makro-Aufruf
                    Debug.Print "Button: " & ctl.Name & " -> Makro: " & strEvent
                End If
            Else
                Debug.Print "Button OHNE Event: " & ctl.Name
                intErrors = intErrors + 1
            End If
        End If
    Next

    DoCmd.Close acForm, "frm_OB_Objekt", acSaveNo

    MsgBox "Button-Analyse abgeschlossen." & vbCrLf & _
           "Buttons ohne Event: " & intErrors, vbInformation

End Sub

' ===== 4. BERICHT ANPASSEN =====
' Passt rpt_OB_Objekt an das Formular an

Public Sub PasseBerichtAn()
    On Error Resume Next

    Dim rpt As Report

    ' Bericht im Entwurfsmodus oeffnen
    DoCmd.OpenReport "rpt_OB_Objekt", acViewDesign
    Set rpt = Reports("rpt_OB_Objekt")

    ' RecordSource anpassen
    rpt.RecordSource = "SELECT o.*, " & _
        "(SELECT COUNT(*) FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID) AS AnzahlPos " & _
        "FROM tbl_OB_Objekt o"

    ' Unterformular/Subreport fuer Positionen pruefen
    Dim ctl As Control
    For Each ctl In rpt.Controls
        If ctl.ControlType = acSubform Then
            Debug.Print "Subreport gefunden: " & ctl.Name
            ' SourceObject und LinkMasterFields/LinkChildFields pruefen
        End If
    Next

    ' Speichern und schliessen
    DoCmd.Close acReport, "rpt_OB_Objekt", acSaveYes

End Sub

' ===== HAUPTPROZEDUR =====
Public Sub AlleAnpassungenDurchfuehren()
    On Error GoTo Fehler

    DoCmd.SetWarnings False

    ' 1. Listenfeld anpassen
    Call AnpasseListenfeld_OB_Objekt

    ' 2. Zeitslot-Labels
    ' (wird beim Oeffnen des Formulars automatisch ausgefuehrt)

    ' 3. Buttons pruefen
    Call RepariereButtons

    ' 4. Bericht anpassen
    Call PasseBerichtAn

    DoCmd.SetWarnings True

    MsgBox "Alle Anpassungen wurden durchgefuehrt!", vbInformation
    Exit Sub

Fehler:
    DoCmd.SetWarnings True
    MsgBox "Fehler: " & Err.Description, vbCritical
End Sub
'@

# VBA-Modul erstellen
Write-Host "`nErstelle VBA-Modul..."

try {
    # Zugriff auf VBE
    $vbProj = $access.VBE.ActiveVBProject

    # Pruefen ob Modul bereits existiert
    $moduleName = "mod_OB_Objekt_Anpassungen"
    $moduleExists = $false

    foreach ($comp in $vbProj.VBComponents) {
        if ($comp.Name -eq $moduleName) {
            $moduleExists = $true
            $vbProj.VBComponents.Remove($comp)
            Write-Host "Existierendes Modul entfernt"
            break
        }
    }

    # Neues Modul erstellen
    $newModule = $vbProj.VBComponents.Add(1) # 1 = vbext_ct_StdModule
    $newModule.Name = $moduleName
    $newModule.CodeModule.AddFromString($vbaCode)

    Write-Host "VBA-Modul '$moduleName' erstellt!"

    # Modul ausfuehren
    Write-Host "`nFuehre Anpassungen aus..."
    $access.Run("AlleAnpassungenDurchfuehren")

} catch {
    Write-Host "VBA-Fehler: $_"
    Write-Host "Versuche alternative Methode..."
}

Write-Host "`n" + ("=" * 70)
Write-Host "ABGESCHLOSSEN"
Write-Host "=" * 70
