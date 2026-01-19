# Access HTML Codes Setup
$ErrorActionPreference = "Stop"

$dbPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"
$modulePath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\mod_HTML_Codes.bas"

function Update-MenuButton($acc, $formName) {
    try {
        $acc.DoCmd.OpenForm($formName, 1, $null, $null, $null, 1) # acDesign=1, acHidden=1
        $frm = $acc.Forms($formName)
        foreach ($ctl in $frm.Controls) {
            if ($ctl.ControlType -eq 104) {
                $caption = ""
                try { $caption = $ctl.Caption } catch {}
                if ($caption -match "HTML Ansicht") {
                    $ctl.OnClick = "=OpenHtmlShell_Codes(\"auftragstamm\")"
                    Write-Host "Updated HTML Ansicht button in $formName ($($ctl.Name))" -ForegroundColor Green
                }
            }
        }
        $acc.DoCmd.Close(2, $formName, 1)
    } catch {
        Write-Host "Failed to update $formName: $($_.Exception.Message)" -ForegroundColor Yellow
        try { $acc.DoCmd.Close(2, $formName, 0) } catch {}
    }
}

$acc = New-Object -ComObject Access.Application
$acc.Visible = $false
$acc.OpenCurrentDatabase($dbPath, $false)

# Import module
try {
    $acc.LoadFromText(1, "mod_HTML_Codes", $modulePath) # acModule=1
    Write-Host "Imported mod_HTML_Codes" -ForegroundColor Green
} catch {
    Write-Host "Failed to import mod_HTML_Codes: $($_.Exception.Message)" -ForegroundColor Yellow
}

Update-MenuButton $acc "frm_Menuefuehrung"
Update-MenuButton $acc "sub_Menuefuehrung"

$acc.CloseCurrentDatabase()
$acc.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($acc) | Out-Null
