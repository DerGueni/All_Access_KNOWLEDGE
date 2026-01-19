# =====================================================
# Install_WebView2_Shell.ps1
# Importiert mod_N_WebView2_Shell und aktualisiert den "HTML Ansicht" Button
# =====================================================

$ErrorActionPreference = "Stop"

$dbPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"
$modulePath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\vba\mod_N_WebView2_Shell.bas"

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "WEBVIEW2 SHELL INSTALLATION" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Pruefen ob Dateien existieren
if (-not (Test-Path $dbPath)) {
    Write-Host "FEHLER: Datenbank nicht gefunden: $dbPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $modulePath)) {
    Write-Host "FEHLER: VBA-Modul nicht gefunden: $modulePath" -ForegroundColor Red
    exit 1
}

Write-Host "Datenbank: $dbPath" -ForegroundColor Gray
Write-Host "VBA-Modul: $modulePath" -ForegroundColor Gray
Write-Host ""

# Access starten
Write-Host "Starte Access..." -ForegroundColor Yellow
$acc = New-Object -ComObject Access.Application
$acc.Visible = $true

try {
    # Datenbank oeffnen
    Write-Host "Oeffne Datenbank..." -ForegroundColor Yellow
    $acc.OpenCurrentDatabase($dbPath, $false)
    Start-Sleep -Seconds 2

    # Altes Modul loeschen falls vorhanden
    Write-Host "Pruefe auf existierendes Modul..." -ForegroundColor Yellow
    try {
        $acc.DoCmd.DeleteObject(1, "mod_N_WebView2_Shell")  # acModule = 1
        Write-Host "  -> Altes Modul geloescht" -ForegroundColor Gray
    } catch {
        Write-Host "  -> Kein altes Modul vorhanden" -ForegroundColor Gray
    }

    # Neues Modul importieren
    Write-Host "Importiere VBA-Modul: mod_N_WebView2_Shell..." -ForegroundColor Yellow
    $acc.LoadFromText(1, "mod_N_WebView2_Shell", $modulePath)  # acModule = 1
    Write-Host "  -> Modul importiert" -ForegroundColor Green

    # Button in frm_va_Auftragstamm aktualisieren
    Write-Host ""
    Write-Host "Aktualisiere Button 'HTML Ansicht' in frm_va_Auftragstamm..." -ForegroundColor Yellow

    try {
        $acc.DoCmd.OpenForm("frm_va_Auftragstamm", 1, $null, $null, $null, 1)  # acDesign=1, acHidden=1
        $frm = $acc.Forms("frm_va_Auftragstamm")

        $buttonFound = $false
        foreach ($ctl in $frm.Controls) {
            # Suche nach Button mit "HTML" im Namen oder Caption
            if ($ctl.ControlType -eq 104) {  # CommandButton
                $caption = ""
                try { $caption = $ctl.Caption } catch {}
                $name = $ctl.Name

                if ($caption -match "HTML" -or $name -match "HTML") {
                    # Button gefunden - OnClick aktualisieren
                    $ctl.OnClick = "=OpenShell_Auftragstamm([ID])"
                    Write-Host "  -> Button '$name' ($caption) aktualisiert" -ForegroundColor Green
                    Write-Host "     OnClick = =OpenShell_Auftragstamm([ID])" -ForegroundColor Gray
                    $buttonFound = $true
                }
            }
        }

        if (-not $buttonFound) {
            Write-Host "  -> Kein HTML-Button gefunden" -ForegroundColor Yellow
        }

        $acc.DoCmd.Close(2, "frm_va_Auftragstamm", 1)  # acForm=2, acSaveYes=1

    } catch {
        Write-Host "  -> Fehler beim Aktualisieren: $($_.Exception.Message)" -ForegroundColor Yellow
        try { $acc.DoCmd.Close(2, "frm_va_Auftragstamm", 0) } catch {}
    }

    # Button in frm_MA_Mitarbeiterstamm aktualisieren
    Write-Host ""
    Write-Host "Aktualisiere Button 'HTML Ansicht' in frm_MA_Mitarbeiterstamm..." -ForegroundColor Yellow

    try {
        $acc.DoCmd.OpenForm("frm_MA_Mitarbeiterstamm", 1, $null, $null, $null, 1)
        $frm = $acc.Forms("frm_MA_Mitarbeiterstamm")

        $buttonFound = $false
        foreach ($ctl in $frm.Controls) {
            if ($ctl.ControlType -eq 104) {
                $caption = ""
                try { $caption = $ctl.Caption } catch {}
                $name = $ctl.Name

                if ($caption -match "HTML" -or $name -match "HTML") {
                    $ctl.OnClick = "=OpenShell_Mitarbeiterstamm([ID])"
                    Write-Host "  -> Button '$name' ($caption) aktualisiert" -ForegroundColor Green
                    Write-Host "     OnClick = =OpenShell_Mitarbeiterstamm([ID])" -ForegroundColor Gray
                    $buttonFound = $true
                }
            }
        }

        if (-not $buttonFound) {
            Write-Host "  -> Kein HTML-Button gefunden" -ForegroundColor Yellow
        }

        $acc.DoCmd.Close(2, "frm_MA_Mitarbeiterstamm", 1)

    } catch {
        Write-Host "  -> Fehler beim Aktualisieren: $($_.Exception.Message)" -ForegroundColor Yellow
        try { $acc.DoCmd.Close(2, "frm_MA_Mitarbeiterstamm", 0) } catch {}
    }

    # Button in frm_KD_Kundenstamm aktualisieren
    Write-Host ""
    Write-Host "Aktualisiere Button 'HTML Ansicht' in frm_KD_Kundenstamm..." -ForegroundColor Yellow

    try {
        $acc.DoCmd.OpenForm("frm_KD_Kundenstamm", 1, $null, $null, $null, 1)
        $frm = $acc.Forms("frm_KD_Kundenstamm")

        $buttonFound = $false
        foreach ($ctl in $frm.Controls) {
            if ($ctl.ControlType -eq 104) {
                $caption = ""
                try { $caption = $ctl.Caption } catch {}
                $name = $ctl.Name

                if ($caption -match "HTML" -or $name -match "HTML") {
                    $ctl.OnClick = "=OpenShell_Kundenstamm([kun_Id])"
                    Write-Host "  -> Button '$name' ($caption) aktualisiert" -ForegroundColor Green
                    Write-Host "     OnClick = =OpenShell_Kundenstamm([kun_Id])" -ForegroundColor Gray
                    $buttonFound = $true
                }
            }
        }

        if (-not $buttonFound) {
            Write-Host "  -> Kein HTML-Button gefunden" -ForegroundColor Yellow
        }

        $acc.DoCmd.Close(2, "frm_KD_Kundenstamm", 1)

    } catch {
        Write-Host "  -> Fehler beim Aktualisieren: $($_.Exception.Message)" -ForegroundColor Yellow
        try { $acc.DoCmd.Close(2, "frm_KD_Kundenstamm", 0) } catch {}
    }

    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor Green
    Write-Host "INSTALLATION ABGESCHLOSSEN" -ForegroundColor Green
    Write-Host "=" * 70 -ForegroundColor Green
    Write-Host ""
    Write-Host "Der 'HTML Ansicht' Button oeffnet jetzt:" -ForegroundColor White
    Write-Host "  - WebView2 Host (nicht Browser)" -ForegroundColor Gray
    Write-Host "  - Shell mit Sidebar (bleibt persistent)" -ForegroundColor Gray
    Write-Host "  - Formulare werden im iframe geladen" -ForegroundColor Gray
    Write-Host "  - KEIN API Server erforderlich!" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "FEHLER: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Datenbank schliessen
    try {
        $acc.CloseCurrentDatabase()
    } catch {}

    # Access NICHT beenden - User kann weiterarbeiten
    Write-Host "Access bleibt geoeffnet fuer weitere Arbeit." -ForegroundColor Gray
}

Write-Host ""
Write-Host "Druecke eine Taste zum Beenden..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
