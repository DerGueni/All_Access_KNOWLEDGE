# ============================================================
#  export_and_hash.ps1 – Access Frontend Voll-Export + Hashing
# ============================================================
#  Erstellt: 2025-11-08
#  Kompatibel: Microsoft Access 2021 (64-bit)
# ------------------------------------------------------------
#  Dieses Skript:
#   1. Startet Access im Hintergrund
#   2. Führt Export_AllPlus() aus (aus modAccessFE_Exporter)
#   3. Erstellt SHA-256-Hashes aller Exportdateien
#   4. Schreibt Log- und Hash-Dateien in den Exportordner
# ============================================================

param(
  [string]$accdb = "C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
)

# --- Einstellungen ----------------------------------------------------------
$ErrorActionPreference = 'Stop'

# Exportpfad (fester Ordner laut Anforderung)
$root = "C:\Users\guenther.siegert\Documents\000_Consys_Eport_11_25"

# --- Hilfsfunktionen --------------------------------------------------------
function Ensure-Dir([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
  }
}

# Log
$stamp  = (Get-Date).ToString("yyyy-MM-dd__HH-mm-ss")
$logDir = Join-Path $root "99_logs"
Ensure-Dir $root
Ensure-Dir $logDir
$log    = Join-Path $logDir "export_$stamp.log"

function Write-Log([string]$msg) {
  $line = "[{0}] {1}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"), $msg
  $line | Tee-Object -FilePath $log -Append
}

# --- Schritt 1: Access starten und Export ausführen -------------------------
try {
  Write-Log "Starte Access-Export..."
  Write-Log "Frontend-Datei: $accdb"
  Write-Log "Export-Ordner: $root"

  $access = New-Object -ComObject Access.Application
  $access.OpenCurrentDatabase($accdb)

  try { $access.Echo($false) | Out-Null } catch {}

  Write-Log "Rufe Export_AllPlus() auf ..."
  $access.Run("Export_AllPlus")
  Write-Log "Export_AllPlus() erfolgreich ausgeführt."

} catch {
  Write-Log "FEHLER während des Exports: $($_.Exception.Message)"
  throw
} finally {
  if ($null -ne $access) {
    try { $access.Quit() } catch {}
    try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null } catch {}
  }
}

# --- Schritt 2: Hashing aller Dateien --------------------------------------
try {
  Write-Log "Beginne Hashing (SHA-256)..."

  $hashDir = Join-Path $root "99_hashes"
  Ensure-Dir $hashDir
  $hashFile = Join-Path $hashDir "hashes.json"

  $files = Get-ChildItem -Path $root -Recurse -File | Where-Object {
    $_.FullName -ne $hashFile
  }

  $result = [ordered]@{}
  foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length).TrimStart('\')
    $h   = Get-FileHash -Algorithm SHA256 -Path $f.FullName
    $result[$rel] = $h.Hash.ToLower()
  }

  ($result | ConvertTo-Json -Depth 10) | Set-Content -Path $hashFile -Encoding UTF8
  Write-Log "Hashing abgeschlossen. Datei: $hashFile"
  Write-Log "Export + Hash erfolgreich beendet."
}
catch {
  Write-Log "FEHLER beim Hashing: $($_.Exception.Message)"
  throw
}
