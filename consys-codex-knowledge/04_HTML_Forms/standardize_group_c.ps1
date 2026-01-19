$formsPath = "c:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms"

# Template für standardisiertes Formular
$standardTemplate = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{TITLE} - CONSYS</title>
    <link rel="stylesheet" href="../css/design-system.css">
    <link rel="stylesheet" href="../css/app-layout.css">
    <link rel="stylesheet" href="../theme/consys_theme.css">
    <link rel="stylesheet" href="styles/{FILENAME}.css">
</head>
<body>
    <div class="app-container">
        <!-- Sidebar Navigation -->
        <aside class="app-sidebar">
            <div class="sidebar-header">CONSYS</div>
            <nav class="sidebar-menu">
                <a href="frm_N_Dienstplanuebersicht.html" class="sidebar-btn">Dienstplanübersicht</a>
                <a href="frm_VA_Planungsuebersicht.html" class="sidebar-btn">Planungsübersicht</a>
                <a href="frm_va_Auftragstamm.html" class="sidebar-btn">Auftragsverwaltung</a>
                <a href="frm_MA_Mitarbeiterstamm.html" class="sidebar-btn">Mitarbeiterverwaltung</a>
                <a href="frm_N_Email_versenden.html" class="sidebar-btn">Offene Mail Anfragen</a>
                <a href="frm_MA_Zeitkonten.html" class="sidebar-btn">Excel Zeitkonten</a>
                <a href="frm_MA_Zeitkonten.html" class="sidebar-btn">Zeitkonten</a>
                <a href="frm_MA_Abwesenheit.html" class="sidebar-btn">Abwesenheitsplanung</a>
                <a href="frm_Ausweis_Create.html" class="sidebar-btn">Dienstausweis erstellen</a>
                <a href="frm_N_Stundenauswertung.html" class="sidebar-btn">Stundenabgleich</a>
                <a href="frm_KD_Kundenstamm.html" class="sidebar-btn">Kundenverwaltung</a>
                <a href="frm_KD_Kundenstamm.html" class="sidebar-btn">Verrechnungssätze</a>
                <a href="frm_N_Lohnabrechnungen.html" class="sidebar-btn">Sub Rechnungen</a>
                <a href="frm_N_Email_versenden.html" class="sidebar-btn">E-Mail</a>
                <hr class="sidebar-divider">
                <a href="frm_Menuefuehrung.html" class="sidebar-btn">Hauptmenü</a>
                <a href="frm_N_Optimierung.html" class="sidebar-btn">System Info</a>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="app-main">
            <!-- Header -->
            <div class="form-header">
                <div class="header-left">
                    <h1 class="form-title">{TITLE}</h1>
                </div>
                <div class="header-right">
                    <button class="header-btn" id="btnClose" title="Schließen">×</button>
                </div>
            </div>

            <!-- Content Area -->
            <div id="content-area">
                <div class="content-placeholder">
                    <p>{TITLE}</p>
                    <p style="font-size: 11px; color: #666;">Formular wird geladen...</p>
                </div>
            </div>

            <!-- Status Bar -->
            <div class="status-bar">
                <div class="status-left">Ready</div>
                <div class="status-right">
                    <span id="timestamp"></span>
                </div>
            </div>
        </main>
    </div>

    <script type="module" src="../js/sidebar.js"></script>
    <script type="module" src="logic/{FILENAME}.logic.js"></script>
    <script>
        document.getElementById('btnClose').addEventListener('click', () => {
            window.close();
        });
        
        // Update timestamp
        function updateTimestamp() {
            const now = new Date();
            document.getElementById('timestamp').textContent = now.toLocaleString('de-DE');
        }
        updateTimestamp();
        setInterval(updateTimestamp, 1000);
    </script>
</body>
</html>
"@

# Funktion um Formular zu standardisieren
function Standardize-Form {
    param([string]$filename, [string]$title)
    
    $filepath = Join-Path $formsPath $filename
    $content = $standardTemplate.Replace("{FILENAME}", $filename.Replace(".html", "")).Replace("{TITLE}", $title)
    
    # Sicherungskopie erstellen
    if (Test-Path $filepath) {
        Copy-Item $filepath "$filepath.backup"
        Write-Host "  ✓ Backup erstellt: $filename.backup"
    }
    
    # Neue Datei schreiben
    $content | Out-File -FilePath $filepath -Encoding UTF8
    Write-Host "  ✓ Standardisiert: $filename"
}

Write-Host "📝 FORMULARE WERDEN STANDARDISIERT (GRUPPE C)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. frm_Menuefuehrung.html"
Standardize-Form "frm_Menuefuehrung.html" "Hauptmenü"

Write-Host ""
Write-Host "2. frm_N_Menuefuehrung1_HTML.html"
Standardize-Form "frm_N_Menuefuehrung1_HTML.html" "Menü 1"

Write-Host ""
Write-Host "3. frm_N_Menuefuehrung_HTML.html"
Standardize-Form "frm_N_Menuefuehrung_HTML.html" "Menü"

Write-Host ""
Write-Host "════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ 3 Formulare erfolgreich standardisiert!" -ForegroundColor Green
