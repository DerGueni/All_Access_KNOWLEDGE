# Access export for HTML Codes comparison
$ErrorActionPreference = "Stop"

$dbPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"
$exportPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\AccessExport_Codes"

$detailPath = "$exportPath\Details"
if (-not (Test-Path $detailPath)) { New-Item -ItemType Directory -Path $detailPath -Force | Out-Null }

$accApp = New-Object -ComObject Access.Application
$accApp.Visible = $false
$accApp.OpenCurrentDatabase($dbPath, $false)

$formDetailPath = "$detailPath\Formulare"
if (-not (Test-Path $formDetailPath)) { New-Item -ItemType Directory -Path $formDetailPath -Force | Out-Null }

$allFormsOutput = @()
$allFormsOutput += "FORMULAR-DETAILS EXPORT (Codes)"
$allFormsOutput += "Exportiert am: $(Get-Date)"
$allFormsOutput += ""

$subformRelations = @()
$subformRelations += "UNTERFORMULAR-BEZIEHUNGEN (Codes)"
$subformRelations += ""

foreach ($frmObj in $accApp.CurrentProject.AllForms) {
    $frmName = $frmObj.Name
    try {
        $accApp.DoCmd.OpenForm($frmName, 1, $null, $null, $null, 1)
        $frm = $accApp.Forms($frmName)

        $formOutput = @()
        $formOutput += "FORMULAR: $frmName"
        $formOutput += "RecordSource: $($frm.RecordSource)"
        $formOutput += ""

        $events = @("OnOpen","OnClose","OnLoad","OnUnload","OnCurrent","BeforeUpdate","AfterUpdate","OnTimer","OnError","OnFilter","OnApplyFilter")
        foreach ($evt in $events) {
            try {
                $evtValue = $frm.$evt
                if ($evtValue -and $evtValue -ne "") { $formOutput += "  ${evt}: $evtValue" }
            } catch {}
        }

        $formOutput += ""
        $formOutput += "STEUERELEMENTE:"

        foreach ($ctl in $frm.Controls) {
            $ctlName = $ctl.Name
            $ctlType = $ctl.ControlType
            $formOutput += "  [$ctlType] $ctlName"

            try { if ($ctl.ControlSource) { $formOutput += "    ControlSource: $($ctl.ControlSource)" } } catch {}
            try { if ($ctl.RowSource) { $formOutput += "    RowSource: $($ctl.RowSource)" } } catch {}

            if ($ctlType -eq 112) {
                try {
                    $formOutput += "    SourceObject: $($ctl.SourceObject)"
                    $formOutput += "    LinkMasterFields: $($ctl.LinkMasterFields)"
                    $formOutput += "    LinkChildFields: $($ctl.LinkChildFields)"

                    $subformRelations += "Hauptformular: $frmName"
                    $subformRelations += "  -> $($ctl.Name) = $($ctl.SourceObject)"
                    $subformRelations += "     Link: $($ctl.LinkMasterFields) = $($ctl.LinkChildFields)"
                    $subformRelations += ""
                } catch {}
            }
        }

        $formOutput += ""
        $formOutput | Out-File -FilePath "$formDetailPath\$frmName.txt" -Encoding UTF8
        $allFormsOutput += $formOutput

        $accApp.DoCmd.Close(2, $frmName, 0)
    } catch {
        try { $accApp.DoCmd.Close(2, $frmName, 0) } catch {}
    }
}

$allFormsOutput | Out-File -FilePath "$detailPath\ALL_FORMS.txt" -Encoding UTF8
$subformRelations | Out-File -FilePath "$detailPath\SUBFORM_RELATIONS.txt" -Encoding UTF8

$accApp.CloseCurrentDatabase()
$accApp.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($accApp) | Out-Null
