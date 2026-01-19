$fe = 'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb'
if (!(Test-Path $fe)) { Write-Error 'FE not found'; exit 1 }
$out = 'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\AccessLayouts\query_defs.json'
$dbEngine = $null
foreach ($progId in @('DAO.DBEngine.120','DAO.DBEngine.150','DAO.DBEngine.160','DAO.DBEngine.36')) {
  try {
    $dbEngine = New-Object -ComObject $progId
    if ($dbEngine -ne $null) { break }
  } catch {}
}
if ($dbEngine -eq $null) { Write-Error 'DAO DBEngine not available'; exit 1 }
$db = $null
try {
  $db = $dbEngine.OpenDatabase($fe, $false, $true)
  $defs = @()
  foreach ($q in $db.QueryDefs) {
    $name = $q.Name
    if ($name -like '~*') { continue }
    $sql = $q.SQL
    $defs += [pscustomobject]@{ name = $name; sql = $sql }
  }
  $defs | ConvertTo-Json -Depth 10 | Set-Content -Path $out -Encoding UTF8
  Write-Host ("Wrote: $out ($($defs.Count))")
}
finally {
  if ($db -ne $null) { try { $db.Close() } catch {} }
  if ($dbEngine -ne $null) { try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($dbEngine) | Out-Null } catch {} }
}
