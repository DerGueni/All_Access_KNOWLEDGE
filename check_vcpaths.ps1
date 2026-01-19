$jsonPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ConsysWinUI\ConsysWinUI\obj\x64\Debug\net8.0-windows10.0.19041.0\input.json"
$content = Get-Content $jsonPath -Raw
$json = $content | ConvertFrom-Json

Write-Host "VCInstallDir: '$($json.VCInstallDir)'"
Write-Host "VCInstallPath32: '$($json.VCInstallPath32)'"
Write-Host "VCInstallPath64: '$($json.VCInstallPath64)'"
