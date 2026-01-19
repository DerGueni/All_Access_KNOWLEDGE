# ═══════════════════════════════════════════════════════════════════════════════
# Skript:    Generate_Report.ps1
# Zweck:     Generiert einen interaktiven HTML-Report der Datenbank-Struktur
# Autor:     Access-Forensiker Agent
# Datum:     2025-10-31
# Version:   1.0
# ═══════════════════════════════════════════════════════════════════════════════

[CmdletBinding()]
param(
    [string]$KnowledgeBasePath = "$env:USERPROFILE\Documents\0000_Consys_Wissen_kpl\03_Export_Ergebnisse\Consys_FE_N_KnowledgeBase.json",
    [string]$OutputPath = "$env:USERPROFILE\Documents\0000_Consys_Wissen_kpl\04_Dokumentation\Datenbank_Report.html"
)

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Consys Knowledge Base - HTML Report Generator" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Wissensdatenbank laden
if (-not (Test-Path $KnowledgeBasePath)) {
    Write-Host "✗ Wissensdatenbank nicht gefunden!" -ForegroundColor Red
    exit 1
}

Write-Host "Lade Wissensdatenbank..." -ForegroundColor Green
$kb = Get-Content -Path $KnowledgeBasePath -Raw | ConvertFrom-Json

# HTML Template
$html = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consys Datenbank Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; padding: 20px; }
        .container { max-width: 1400px; margin: 0 auto; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; border-radius: 10px 10px 0 0; }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { opacity: 0.9; font-size: 1.1em; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; padding: 30px; }
        .stat-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #667eea; }
        .stat-card h3 { color: #667eea; font-size: 2em; margin-bottom: 5px; }
        .stat-card p { color: #666; font-size: 0.9em; }
        .content { padding: 30px; }
        .section { margin-bottom: 40px; }
        .section-title { color: #333; font-size: 1.8em; margin-bottom: 20px; border-bottom: 3px solid #667eea; padding-bottom: 10px; }
        .table-container { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #667eea; color: white; padding: 12px; text-align: left; font-weight: 600; }
        td { padding: 12px; border-bottom: 1px solid #eee; }
        tr:hover { background: #f8f9fa; }
        .badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 0.85em; font-weight: 600; }
        .badge-primary { background: #e3f2fd; color: #1976d2; }
        .badge-success { background: #e8f5e9; color: #388e3c; }
        .badge-warning { background: #fff3e0; color: #f57c00; }
        .badge-danger { background: #ffebee; color: #d32f2f; }
        .code-block { background: #2d2d2d; color: #f8f8f2; padding: 15px; border-radius: 5px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 0.9em; margin-top: 10px; }
        .tabs { display: flex; border-bottom: 2px solid #eee; margin-bottom: 20px; }
        .tab { padding: 12px 24px; cursor: pointer; border-bottom: 3px solid transparent; transition: all 0.3s; }
        .tab:hover { background: #f8f9fa; }
        .tab.active { border-bottom-color: #667eea; color: #667eea; font-weight: 600; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .search-box { width: 100%; padding: 12px; border: 2px solid #eee; border-radius: 5px; font-size: 1em; margin-bottom: 20px; }
        .search-box:focus { outline: none; border-color: #667eea; }
        .footer { text-align: center; padding: 20px; color: #666; border-top: 1px solid #eee; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Consys Datenbank Report</h1>
            <p>Vollständige Dokumentation der Access-Datenbank</p>
            <p style="margin-top: 10px; opacity: 0.8;">Export: $($kb.exportDate) | Version: $($kb.exportVersion)</p>
        </div>
        
        <div class="stats">
            <div class="stat-card">
                <h3>$($kb.tables.Count)</h3>
                <p>Tabellen</p>
            </div>
            <div class="stat-card">
                <h3>$($kb.queries.Count)</h3>
                <p>Queries</p>
            </div>
            <div class="stat-card">
                <h3>$($kb.forms.Count)</h3>
                <p>Formulare</p>
            </div>
            <div class="stat-card">
                <h3>$($kb.reports.Count)</h3>
                <p>Reports</p>
            </div>
            <div class="stat-card">
                <h3>$($kb.modules.Count)</h3>
                <p>VBA-Module</p>
            </div>
            <div class="stat-card">
                <h3>$($kb.relations.Count)</h3>
                <p>Beziehungen</p>
            </div>
        </div>
        
        <div class="content">
            <!-- Tabellen Section -->
            <div class="section">
                <h2 class="section-title">🗄️ Tabellen</h2>
                <input type="text" class="search-box" id="searchTables" placeholder="Tabellen durchsuchen...">
                <div class="table-container">
                    <table id="tablesTable">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Felder</th>
                                <th>Indizes</th>
                                <th>Datensätze</th>
                                <th>Erstellt</th>
                            </tr>
                        </thead>
                        <tbody>
"@

# Tabellen hinzufügen
foreach ($table in $kb.tables) {
    $html += @"
                            <tr>
                                <td><strong>$($table.name)</strong></td>
                                <td>$($table.fields.Count)</td>
                                <td>$($table.indexes.Count)</td>
                                <td>$($table.recordCount)</td>
                                <td>$($table.dateCreated)</td>
                            </tr>
"@
}

$html += @"
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Queries Section -->
            <div class="section">
                <h2 class="section-title">🔍 Queries</h2>
                <input type="text" class="search-box" id="searchQueries" placeholder="Queries durchsuchen...">
                <div class="table-container">
                    <table id="queriesTable">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Typ</th>
                                <th>Felder</th>
                                <th>Parameter</th>
                            </tr>
                        </thead>
                        <tbody>
"@

# Queries hinzufügen
foreach ($query in $kb.queries) {
    $html += @"
                            <tr>
                                <td><strong>$($query.name)</strong></td>
                                <td><span class="badge badge-primary">$($query.typeName)</span></td>
                                <td>$($query.fields.Count)</td>
                                <td>$($query.parameters.Count)</td>
                            </tr>
"@
}

$html += @"
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Formulare Section -->
            <div class="section">
                <h2 class="section-title">📝 Formulare</h2>
                <input type="text" class="search-box" id="searchForms" placeholder="Formulare durchsuchen...">
                <div class="table-container">
                    <table id="formsTable">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>RecordSource</th>
                                <th>Controls</th>
                                <th>Events</th>
                            </tr>
                        </thead>
                        <tbody>
"@

# Formulare hinzufügen
foreach ($form in $kb.forms) {
    $eventCount = ($form.events.PSObject.Properties | Measure-Object).Count
    $html += @"
                            <tr>
                                <td><strong>$($form.name)</strong></td>
                                <td>$($form.recordSource)</td>
                                <td>$($form.controls.Count)</td>
                                <td>$eventCount</td>
                            </tr>
"@
}

$html += @"
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Module Section -->
            <div class="section">
                <h2 class="section-title">💻 VBA-Module</h2>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Typ</th>
                                <th>Prozeduren</th>
                                <th>Zeilen</th>
                            </tr>
                        </thead>
                        <tbody>
"@

# Module hinzufügen
foreach ($module in $kb.modules) {
    $badgeClass = switch ($module.type) {
        "StandardModule" { "badge-primary" }
        "FormModule" { "badge-success" }
        "ReportModule" { "badge-warning" }
        default { "badge-primary" }
    }
    
    $html += @"
                            <tr>
                                <td><strong>$($module.name)</strong></td>
                                <td><span class="badge $badgeClass">$($module.type)</span></td>
                                <td>$($module.procedureCount)</td>
                                <td>$($module.lineCount)</td>
                            </tr>
"@
}

$html += @"
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>Generiert am $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Consys Access-Forensiker</p>
        </div>
    </div>
    
    <script>
        // Suchfunktion für Tabellen
        document.getElementById('searchTables').addEventListener('input', function(e) {
            filterTable('tablesTable', e.target.value);
        });
        
        document.getElementById('searchQueries').addEventListener('input', function(e) {
            filterTable('queriesTable', e.target.value);
        });
        
        document.getElementById('searchForms').addEventListener('input', function(e) {
            filterTable('formsTable', e.target.value);
        });
        
        function filterTable(tableId, searchTerm) {
            const table = document.getElementById(tableId);
            const rows = table.getElementsByTagName('tr');
            searchTerm = searchTerm.toLowerCase();
            
            for (let i = 1; i < rows.length; i++) {
                const row = rows[i];
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            }
        }
    </script>
</body>
</html>
"@

# HTML speichern
Write-Host "Generiere HTML-Report..." -ForegroundColor Green
$html | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ HTML-Report erfolgreich erstellt!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pfad: $OutputPath" -ForegroundColor White
Write-Host ""
Write-Host "Report im Browser öffnen? (J/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "J" -or $response -eq "j") {
    Start-Process $OutputPath
}
