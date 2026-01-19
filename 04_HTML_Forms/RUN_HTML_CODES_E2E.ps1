# E2E test runner for HTML _Codes + Access screenshots
$ErrorActionPreference = "Stop"

$dbPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"
$rootPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE"
$httpUrl = "http://127.0.0.1:8080/forms/_Codes/shell.html"
$outDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\e2e_screenshots"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

function Start-ApiServer {
    Start-Process -FilePath "wscript.exe" -ArgumentList "$rootPath\04_HTML_Forms\start_api_server_hidden.vbs" | Out-Null
    Start-Sleep -Seconds 3
}

function Start-HttpServer {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$rootPath\04_HTML_Forms\start_http_server.bat`"" | Out-Null
    Start-Sleep -Seconds 2
}

function Start-HttpServerDirect {
    $py = (Get-Command python -ErrorAction SilentlyContinue)
    $pyLauncher = (Get-Command py -ErrorAction SilentlyContinue)
    if ($py -and $py.Path) {
        Start-Process -FilePath $py.Path -ArgumentList @("-m","http.server","8080","--bind","127.0.0.1") -WorkingDirectory (Join-Path $rootPath "04_HTML_Forms") | Out-Null
        return $true
    }
    if ($pyLauncher -and $pyLauncher.Path) {
        Start-Process -FilePath $pyLauncher.Path -ArgumentList @("-3","-m","http.server","8080","--bind","127.0.0.1") -WorkingDirectory (Join-Path $rootPath "04_HTML_Forms") | Out-Null
        return $true
    }
    return $false
}

function Test-Url($url) {
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 5
        return $resp.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Wait-Url($url, $retries = 6, $sleepSeconds = 2) {
    for ($i=0; $i -lt $retries; $i++) {
        if (Test-Url $url) { return $true }
        Start-Sleep -Seconds $sleepSeconds
    }
    return $false
}

function Save-Screenshot($path) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen
    $bitmap = New-Object System.Drawing.Bitmap($screen.Bounds.Width, $screen.Bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Bounds.Location, [System.Drawing.Point]::Empty, $screen.Bounds.Size)
    $bitmap.Save($path)
    $graphics.Dispose()
    $bitmap.Dispose()
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Win32 {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

function Activate-ProcessWindow($proc, $titleFallback) {
    $maxWait = 10
    for ($i = 0; $i -lt $maxWait; $i++) {
        if ($proc -and $proc.MainWindowHandle -and $proc.MainWindowHandle -ne [IntPtr]::Zero) { break }
        Start-Sleep -Seconds 1
        try { $proc.Refresh() } catch {}
    }
    if ($proc -and $proc.MainWindowHandle -and $proc.MainWindowHandle -ne [IntPtr]::Zero) {
        try { [Win32]::ShowWindow($proc.MainWindowHandle, 9) | Out-Null } catch {}
        try { [Win32]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null } catch {}
        return
    }
    try { $wshell.AppActivate($proc.Id) | Out-Null } catch {}
    if ($titleFallback) {
        try { $wshell.AppActivate($titleFallback) | Out-Null } catch {}
    }
}

$forms = @(
    @{ html = "auftragstamm"; access = "frm_va_Auftragstamm" },
    @{ html = "mitarbeiterstamm"; access = "frm_MA_Mitarbeiterstamm" },
    @{ html = "kundenstamm"; access = "frm_KD_Kundenstamm" },
    @{ html = "schnellauswahl"; access = "frm_MA_VA_Schnellauswahl" },
    @{ html = "dienstplanuebersicht"; access = "frm_DP_Dienstplan_MA" },
    @{ html = "planungsuebersicht"; access = "frm_VA_Planungsuebersicht" }
)

Start-ApiServer
$startedDirect = Start-HttpServerDirect
if (-not $startedDirect) { Start-HttpServer }
if (-not (Wait-Url $httpUrl 6 2)) {
    Start-HttpServer
    Wait-Url $httpUrl 6 2 | Out-Null
}

# Open Access
$acc = New-Object -ComObject Access.Application
$acc.Visible = $true
$acc.OpenCurrentDatabase($dbPath, $false)

$wshell = New-Object -ComObject WScript.Shell

foreach ($f in $forms) {
    # HTML
    $formUrl = "$httpUrl?form=$($f.html)"
    $edgeProfile = Join-Path $env:TEMP "consys_html_e2e_$($f.html)"
    if (-not (Test-Path $edgeProfile)) { New-Item -ItemType Directory -Path $edgeProfile -Force | Out-Null }
    $edgeArgs = @(
        "--app=$formUrl",
        "--no-first-run",
        "--disable-features=msNewTabPage",
        "--user-data-dir=$edgeProfile"
    )
    $edge = Start-Process -FilePath "msedge.exe" -ArgumentList $edgeArgs -PassThru
    Start-Sleep -Seconds 6
    Activate-ProcessWindow $edge "Microsoft Edge"
    if (-not ($edge -and $edge.MainWindowHandle -and $edge.MainWindowHandle -ne [IntPtr]::Zero)) {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c start `"`" microsoft-edge:`"$formUrl`"" | Out-Null
        Start-Sleep -Seconds 3
        try { $wshell.AppActivate("Microsoft Edge") | Out-Null } catch {}
    }
    Start-Sleep -Seconds 1
    Save-Screenshot "$outDir\html_$($f.html).png"

    # Access
    try {
        $acc.DoCmd.OpenForm($f.access, 0)
        Start-Sleep -Seconds 2
        try { $wshell.AppActivate($acc.Name) | Out-Null } catch {}
        try { $wshell.AppActivate("Access") | Out-Null } catch {}
        Start-Sleep -Seconds 1
        Save-Screenshot "$outDir\access_$($f.access).png"
    } catch {}
}

$acc.CloseCurrentDatabase()
$acc.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($acc) | Out-Null
