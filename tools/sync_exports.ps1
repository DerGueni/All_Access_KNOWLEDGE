param(
  [string]$Source = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export",
  [string]$Target = (Join-Path $PSScriptRoot "..\claude\knowledge\exports")
)
$ErrorActionPreference="Stop"
if(!(Test-Path $Source)){ throw "Source not found: $Source" }
if(!(Test-Path $Target)){ New-Item -ItemType Directory -Path $Target | Out-Null }
robocopy $Source $Target *.json /E /NFL /NDL /NJH /NJS | Out-Null
Write-Host "Exports synced -> $Target"
