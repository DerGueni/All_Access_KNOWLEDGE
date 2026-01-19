$ErrorActionPreference = "Stop"

$rootPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE"
$logDir = Join-Path $rootPath "runtime_logs"
$logPath = Join-Path $logDir "auto_runner.log"
$e2eScript = Join-Path $rootPath "04_HTML_Forms\RUN_HTML_CODES_E2E.ps1"
$httpBat = Join-Path $rootPath "04_HTML_Forms\start_http_server.bat"
$apiVbs = Join-Path $rootPath "04_HTML_Forms\start_api_server_hidden.vbs"

if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Start-Transcript -Path $logPath -Append

function Write-Section($text) {
    Write-Host ""
    Write-Host "==== $text ===="
}

function Test-Python {
    $python = (Get-Command python -ErrorAction SilentlyContinue)
    $py = (Get-Command py -ErrorAction SilentlyContinue)
    if ($python) { Write-Host "python: $($python.Path)" } else { Write-Host "python: NOT FOUND" }
    if ($py) { Write-Host "py: $($py.Path)" } else { Write-Host "py: NOT FOUND" }
}

function Test-Url($url) {
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 5
        Write-Host "OK: $url ($($resp.StatusCode))"
        return $true
    } catch {
        Write-Host "FAIL: $url ($($_.Exception.Message))"
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

function Start-HttpServerDirect {
    $py = (Get-Command python -ErrorAction SilentlyContinue)
    $pyLauncher = (Get-Command py -ErrorAction SilentlyContinue)
    if ($py -and $py.Path) {
        Start-Process -FilePath $py.Path -ArgumentList @("-m","http.server","8080","--bind","127.0.0.1") -WorkingDirectory (Join-Path $rootPath "04_HTML_Forms") | Out-Null
        return
    }
    if ($pyLauncher -and $pyLauncher.Path) {
        Start-Process -FilePath $pyLauncher.Path -ArgumentList @("-3","-m","http.server","8080","--bind","127.0.0.1") -WorkingDirectory (Join-Path $rootPath "04_HTML_Forms") | Out-Null
        return
    }
    Write-Host "Start-HttpServerDirect: No python/py found."
}

function Start-ApiServerDirect {
    $py = (Get-Command python -ErrorAction SilentlyContinue)
    $pyLauncher = (Get-Command py -ErrorAction SilentlyContinue)
    $apiPath = Join-Path $rootPath "08_Tools\\python\\api_server.py"
    if ($py -and $py.Path) {
        Start-Process -FilePath $py.Path -ArgumentList @("$apiPath") | Out-Null
        return
    }
    if ($pyLauncher -and $pyLauncher.Path) {
        Start-Process -FilePath $pyLauncher.Path -ArgumentList @("-3",$apiPath) | Out-Null
        return
    }
    Write-Host "Start-ApiServerDirect: No python/py found."
}

function Get-PythonVersion {
    try {
        $out = & py -3 --version 2>&1
        Write-Host "py -3 --version: $out"
        return
    } catch {}
    try {
        $out = & python --version 2>&1
        Write-Host "python --version: $out"
        return
    } catch {}
    Write-Host "Python version: NOT FOUND"
}

function Log-Netstat($port) {
    Write-Host "netstat :$port"
    try {
        & cmd.exe /c "netstat -ano | findstr :$port"
    } catch {}
}

Write-Section "Environment"
Write-Host "rootPath: $rootPath"
Write-Host "logPath: $logPath"
Test-Python
Get-PythonVersion

Write-Section "Start HTTP server"
Start-HttpServerDirect
Start-Sleep -Seconds 2
if (-not (Wait-Url "http://127.0.0.1:8080/forms/_Codes/shell.html" 1 1)) {
    if (Test-Path $httpBat) {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c start ""CONSYS_HTTP"" /min ""$httpBat""" | Out-Null
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Missing: $httpBat"
    }
}

Write-Section "Port status before smoke test"
Log-Netstat 8080

Write-Section "Start API server"
if (Test-Path $apiVbs) {
    Start-Process -FilePath "wscript.exe" -ArgumentList "$apiVbs" | Out-Null
    Start-Sleep -Seconds 2
} else {
    Write-Host "Missing: $apiVbs"
}

Write-Section "Smoke test URL"
$ok = Wait-Url "http://127.0.0.1:8080/forms/_Codes/shell.html" 4 2
if (-not $ok) {
    Write-Host "Retry: starting HTTP server directly"
    Start-HttpServerDirect
    Start-Sleep -Seconds 3
    $ok = Wait-Url "http://127.0.0.1:8080/forms/_Codes/shell.html" 4 2
}
if (-not $ok) {
    Write-Host "Retry: starting API server directly"
    Start-ApiServerDirect
    Start-Sleep -Seconds 3
    Wait-Url "http://127.0.0.1:8080/forms/_Codes/shell.html" 4 2 | Out-Null
}
if (-not $ok) { Log-Netstat 8080 }

Write-Section "Run E2E script"
if (Test-Path $e2eScript) {
    try {
        powershell -ExecutionPolicy Bypass -File $e2eScript
    } catch {
        Write-Host "E2E script failed: $($_.Exception.Message)"
    }
} else {
    Write-Host "Missing: $e2eScript"
}

Write-Section "Artifacts"
$shotDir = Join-Path $rootPath "runtime_logs\e2e_screenshots"
if (Test-Path $shotDir) {
    Get-ChildItem -Path $shotDir -Filter *.png | Sort-Object LastWriteTime | ForEach-Object {
        Write-Host $_.FullName
    }
} else {
    Write-Host "No screenshots folder found: $shotDir"
}

Write-Section "Done"
Stop-Transcript
