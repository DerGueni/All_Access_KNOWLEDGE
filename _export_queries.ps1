$fe = 'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb'
if (!(Test-Path $fe)) { Write-Error 'FE not found'; exit 1 }
$out = 'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\AccessLayouts\query_defs.json'
$app = $null
try {
  $app = New-Object -ComObject Access.Application
  try { $app.Visible = $false } catch {}
  try { $app.AutomationSecurity = 3 } catch {}
  $app.OpenCurrentDatabase($fe, $true)
  $db = $app.CurrentDb()
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
  if ($app -ne $null) {
    try { $app.CloseCurrentDatabase() } catch {}
    try { $app.Quit() } catch {}
    try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($app) | Out-Null } catch {}
  }
}
