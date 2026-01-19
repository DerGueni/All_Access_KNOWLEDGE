$ErrorActionPreference = "Stop"
$logFile = "C:\Users\guenther.siegert\Documents\Access Bridge\formatting_log.txt"

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File $logFile -Append
    Write-Host $Message
}

Write-Log "=== START Formatierungskonfiguration ==="

try {
    Write-Log "Erstelle Access.Application COM-Objekt..."
    $accessApp = New-Object -ComObject Access.Application
    $accessApp.Visible = $false
    Write-Log "✓ COM-Objekt erstellt"
    
    $dbPath = "C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    Write-Log "Öffne DB: $dbPath"
    
    if (-not (Test-Path $dbPath)) {
        throw "Datenbankdatei nicht gefunden: $dbPath"
    }
    
    $accessApp.OpenCurrentDatabase($dbPath)
    Write-Log "✓ Datenbank geöffnet"
    
    # VBA-Code
    $vbaCode = @'
Option Compare Database
Option Explicit

Public Sub Configure_Ist_ConditionalFormatting()
    Const FORM_NAME As String = "frm_lst_row_auftrag"
    Dim hasTxtOffene As Boolean
    Dim ctl As Control
    Dim istCtl As Control
    
    DoCmd.OpenForm FORM_NAME, View:=acDesign, WindowMode:=acHidden
    
    hasTxtOffene = False
    For Each ctl In Forms(FORM_NAME).Controls
        If ctl.Name = "txtOffeneAnfragen" Then
            hasTxtOffene = True
            Exit For
        End If
    Next ctl
    
    If Not hasTxtOffene Then
        Dim txt As Control
        Set txt = Application.CreateControl(FORM_NAME, acTextBox, acDetail)
        With txt
            .Name = "txtOffeneAnfragen"
            .Top = 0
            .Left = 0
            .Width = 100
            .Height = 200
        End With
    End If
    
    With Forms(FORM_NAME).Controls("txtOffeneAnfragen")
        .ControlSource = "=Nz(DCount(""*""; ""qry_MA_Offene_Anfragen""; ""VA_ID="" & [ID]);0)"
        .Visible = False
        .Locked = True
        .TabStop = False
    End With
    
    DoCmd.Close acForm, FORM_NAME, acSaveYes
    DoCmd.OpenForm FORM_NAME, View:=acNormal
    
    On Error Resume Next
    Set istCtl = Forms(FORM_NAME).Controls("Ist")
    On Error GoTo 0
    
    If istCtl Is Nothing Then
        For Each ctl In Forms(FORM_NAME).Controls
            If ctl.ControlType = acTextBox Then
                If LCase$(Nz(ctl.ControlSource, "")) = "ist" Then
                    Set istCtl = ctl
                    Exit For
                End If
            End If
        Next ctl
    End If
    
    If istCtl Is Nothing Then
        MsgBox "Konnte Ist-Feld nicht finden.", vbExclamation
        Exit Sub
    End If
    
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
    
    MsgBox "Formatierung erfolgreich gesetzt!", vbInformation
End Sub
'@

    Write-Log "Zugriff auf VBE..."
    $vbe = $accessApp.VBE
    $vbProject = $vbe.ActiveVBProject
    Write-Log "✓ VBE-Zugriff OK"
    
    # Modul löschen falls vorhanden
    Write-Log "Prüfe existierende Module..."
    $found = $false
    foreach ($component in $vbProject.VBComponents) {
        if ($component.Name -eq "mod_InitIstFormat") {
            Write-Log "  Lösche altes Modul..."
            $vbProject.VBComponents.Remove($component)
            $found = $true
            break
        }
    }
    
    # Neues Modul erstellen
    Write-Log "Erstelle neues Modul..."
    $vbModule = $vbProject.VBComponents.Add(1)  # 1 = vbext_ct_StdModule
    $vbModule.Name = "mod_InitIstFormat"
    $vbModule.CodeModule.AddFromString($vbaCode)
    Write-Log "✓ Modul erstellt und Code eingefügt"
    
    # Prozedur ausführen
    Write-Log "Führe Configure_Ist_ConditionalFormatting aus..."
    $accessApp.Run("Configure_Ist_ConditionalFormatting")
    Write-Log "✓ Prozedur ausgeführt"
    
    Write-Log "=== ERFOLGREICH ABGESCHLOSSEN ==="
    
} catch {
    Write-Log "FEHLER: $($_.Exception.Message)"
    Write-Log "Stack: $($_.ScriptStackTrace)"
    throw
} finally {
    if ($accessApp) {
        Write-Log "Schließe Access..."
        $accessApp.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($accessApp) | Out-Null
        Write-Log "✓ Access geschlossen"
    }
}

Write-Log "=== SCRIPT BEENDET ==="
Write-Host ""
Write-Host "Log-Datei: $logFile"
