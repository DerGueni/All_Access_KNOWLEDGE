# Refresh PATH from registry
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')

# Try to find gh
$ghPath = Get-Command gh -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if ($ghPath) {
    Write-Host "Found: $ghPath"
    & $ghPath --version
} else {
    Write-Host "gh not found in PATH. Searching..."
    $found = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Filter "gh.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        Write-Host "Found: $($found.FullName)"
    } else {
        Write-Host "gh.exe not found"
    }
}
