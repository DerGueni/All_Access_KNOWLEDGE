$ErrorActionPreference = "Continue"
$logPath = "C:\Users\guenther.siegert\Documents\Access Bridge\format_install_log.txt"

function Log {
    param($msg)
    $ts = Get-Date -Format "HH:mm:ss"
    "$ts - $msg" | Tee-Object -FilePath $logPath -Append | Write-Host
}

Log "=== START Formatierungskonfiguration ==="

try {
    Log "Erstelle Access.Application..."
    $accessApp = New-Object -ComObject Access.Application
    
    Log "Setze Visible=False..."
    $accessApp.Visible = $false
    
    $dbPath = "C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb"
    Log "Öffne: $dbPath"
    
    $accessApp.OpenCurrentDatabase($dbPath)
    Log "✓ DB geöffnet"

    $vbaCode = @'
Option Compare Database
Option Explicit

Public Sub Configure_Ist_ConditionalFormatting()
    Const FORM_NAME As String = "frm_lst_row_auftrag"
    Dim hasTxtOffene As Boolean, ctl As Control, istCtl As Control
    
    DoCmd.OpenForm FORM_NAME, View:=acDesign, WindowMode:=acHidden
    
    hasTxtOffene = False
    For Each ctl In Forms(FORM_NAME).Controls
        If ctl.Name = "txtOffeneAnfragen" Then: hasTxtOffene = True: Exit For
    Next
    
    If Not hasTxtOffene Then
        Dim txt As Control
        Set txt = Application.CreateControl(FORM_NAME, acTextBox, acDetail)
        txt.Name = "txtOffeneAnfragen"
        txt.Top = 0: txt.Left = 0: txt.Width = 100: txt.Height = 200
    End If
    
    With Forms(FORM_NAME).Controls("txtOffeneAnfragen")
        .ControlSource = "=Nz(DCount(""*""; ""qry_MA_Offene_Anfragen""; ""VA_ID="" & [ID]);0)"
        .Visible = False: .Locked = True: .TabStop = False
    End With
    
    DoCmd.Close acForm, FORM_NAME, acSaveYes
    DoCmd.OpenForm FORM_NAME, View:=acNormal
    
    On Error Resume Next
    Set istCtl = Forms(FORM_NAME).Controls("Ist")
    On Error GoTo 0
    If istCtl Is Nothing Then
        For Each ctl In Forms(FORM_NAME).Controls
            If ctl.ControlType = acTextBox And LCase$(Nz(ctl.ControlSource,"")) = "ist" Then
                Set istCtl = ctl: Exit For
            End If
        Next
    End If
    If istCtl Is Nothing Then: MsgBox "Ist-Feld nicht gefunden", vbExclamation: Exit Sub
    
    With istCtl.FormatConditions
        .Delete
        Dim fc As FormatCondition
        Set fc = .Add(Type:=acExpression, Expression:="[txtOffeneAnfragen] > 0")
        fc.ForeColor = vbBlue
        Set fc = .Add(Type:=acExpression, Expression:="[txtOffeneAnfragen] = 0 And Nz([Ist],0) <> Nz([Soll],0)")
        fc.ForeColor = vbRed
    End With
    
    Forms(FORM_NAME).Recalc
    DoCmd.RunCommand acCmdSaveRecord
    DoCmd.Close acForm, FORM_NAME, acSaveYes
    MsgBox "Formatierung konfiguriert!", vbInformation
End Sub
'@

    Log "Zugriff auf VBE..."
    $vbe = $accessApp.VBE
    $vbProject = $vbe.ActiveVBProject
    Log "✓ VBE-Zugriff"

    Log "Prüfe auf existierendes Modul..."
    $found = $false
    foreach ($comp in $vbProject.VBComponents) {
        if ($comp.Name -eq "mod_InitIstFormat") {
            Log "  Lösche altes Modul..."
            $vbProject.VBComponents.Remove($comp)
            $found = $true
            break
        }
    }
    
    Log "Erstelle neues Modul..."
    $vbModule = $vbProject.VBComponents.Add(1)
    $vbModule.Name = "mod_InitIstFormat"
    $vbModule.CodeModule.AddFromString($vbaCode)
    Log "✓ Modul erstellt"

    Log "Führe Configure_Ist_ConditionalFormatting aus..."
    $accessApp.Run("Configure_Ist_ConditionalFormatting")
    Log "✓ Prozedur ausgeführt"

    Log "Speichere Änderungen..."
    $accessApp.DoCmd.Save()
    
    Log "Schließe Access..."
    $accessApp.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($accessApp) | Out-Null
    Log "✓ Access geschlossen"

    Log ""
    Log "=========================================="
    Log "ERFOLGREICH ABGESCHLOSSEN"
    Log "=========================================="
    Log "Feld 'Ist' in frm_lst_row_auftrag:"
    Log "  • BLAU = Offene Mitarbeiteranfragen"
    Log "  • ROT = Keine Anfragen offen, Ist ≠ Soll"
    
} catch {
    Log "FEHLER: $($_.Exception.Message)"
    Log "Stack: $($_.ScriptStackTrace)"
    
    if ($accessApp) {
        try {
            $accessApp.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($accessApp) | Out-Null
        } catch {}
    }
}

Log "=== ENDE ==="
Log ""
Log "Logdatei: $logPath"
