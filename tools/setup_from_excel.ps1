<#
  Setup workspace from the CONFIG excel file.
  Requirements: PowerShell 5+ and internet access for installing ImportExcel (if missing) and MCP packages.
#>
param(
  [Parameter(Mandatory=$true)][string]$ConfigXlsx
)

$ErrorActionPreference="Stop"

function Ensure-Dir($p){ if(!(Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null } }

function Try-InstallImportExcel {
  if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue | Out-Null
    Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber
  }
  Import-Module ImportExcel -Force
}

Try-InstallImportExcel

$cfgRows = Import-Excel -Path $ConfigXlsx -WorksheetName "CONFIG"
$cfg=@{}
foreach($r in $cfgRows){
  if($r.'Schlüssel'){ $cfg[$r.'Schlüssel'] = [string]$r.'Wert (bitte ausfüllen)' }
}

$ProjectRoot = $cfg["ProjectRoot"]
if([string]::IsNullOrWhiteSpace($ProjectRoot)){ throw "ProjectRoot fehlt in CONFIG" }

# Copy this package contents into ProjectRoot
$here = Split-Path $MyInvocation.MyCommand.Path -Parent
$pkgRoot = Resolve-Path (Join-Path $here "..")
Ensure-Dir $ProjectRoot

robocopy $pkgRoot $ProjectRoot /E /XD ".git" /XF "*.zip" /NFL /NDL /NJH /NJS | Out-Null

Write-Host "Workspace files copied -> $ProjectRoot"

# Sync exports if available
$exports = $cfg["AccessJsonExportsDir"]
if($exports -and (Test-Path $exports)){
  & (Join-Path $ProjectRoot "tools\sync_exports.ps1") -Source $exports -Target (Join-Path $ProjectRoot "claude\knowledge\exports")
}

# MCP installs (sheet MCP)
$mcpRows = Import-Excel -Path $ConfigXlsx -WorksheetName "MCP"
$claude = Get-Command claude -ErrorAction SilentlyContinue
if(-not $claude){
  Write-Warning "claude CLI nicht gefunden. MCP Installation übersprungen."
  exit 0
}

foreach($r in $mcpRows){
  $name=[string]$r.'MCP-Server'
  if(!$name){ continue }
  $en = ([string]$r.'Enable (yes/no)').Trim().ToLower()
  if($en -ne "yes"){ continue }
  $cmd=[string]$r.'Install Command (Claude Code)'
  if(!$cmd -or $cmd -match "<"){ 
    Write-Warning "MCP '$name' hat Platzhalter im Install Command – bitte in Excel anpassen."
    continue
  }
  Write-Host "Installing MCP: $name"
  Invoke-Expression $cmd
}

Write-Host "Setup done."
