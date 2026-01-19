/**
 * CONSYS Visual Consistency Test
 * Vergleicht alle HTML-Formulare auf visuelle Einheitlichkeit
 */

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

// Pfad zu den HTML-Formularen
const FORMS_DIR = 'C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms';
const SCREENSHOTS_DIR = 'C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/screenshots_test';

// Zu testende Formulare
const FORMS_TO_TEST = [
    // Hauptformulare (mit Sidebar)
    'frm_MA_Mitarbeiterstamm.html',
    'frm_KD_Kundenstamm.html',
    'frm_OB_Objekt.html',
    'frm_va_Auftragstamm.html',

    // Korrigierte Formulare
    'frm_DP_Dienstplan_MA.html',
    'frm_Abwesenheiten.html',
    'frm_abwesenheitsuebersicht.html',
    'frm_DP_Dienstplan_Objekt.html',
    'frm_MA_VA_Positionszuordnung.html',
    'frmOff_Outlook_aufrufen.html',
    'frmTop_Geo_Verwaltung.html'
];

// Erwartete Standards
const STANDARDS = {
    bodyBackground: '#8080c0',
    sidebarBackground: '#6060a0',
    sidebarWidth: 155,
    sidebarButtonCount: 18
};

async function runVisualTest() {
    // Screenshot-Verzeichnis erstellen
    if (!fs.existsSync(SCREENSHOTS_DIR)) {
        fs.mkdirSync(SCREENSHOTS_DIR, { recursive: true });
    }

    const browser = await chromium.launch({
        headless: false,
        slowMo: 200
    });

    const context = await browser.newContext({
        viewport: { width: 1400, height: 900 }
    });

    const page = await context.newPage();

    const results = [];

    console.log('='.repeat(60));
    console.log('CONSYS Visual Consistency Test');
    console.log('='.repeat(60));

    for (const formFile of FORMS_TO_TEST) {
        const formPath = path.join(FORMS_DIR, formFile);

        // Pruefen ob Datei existiert
        if (!fs.existsSync(formPath)) {
            console.log(`\n[SKIP] ${formFile} - Datei nicht gefunden`);
            results.push({
                form: formFile,
                status: 'SKIP',
                reason: 'Datei nicht gefunden'
            });
            continue;
        }

        console.log(`\n[TEST] ${formFile}`);
        console.log('-'.repeat(40));

        try {
            // Formular laden
            await page.goto(`file:///${formPath.replace(/\\/g, '/')}`, {
                waitUntil: 'networkidle',
                timeout: 10000
            });

            // Kurz warten fuer vollstaendiges Rendering
            await page.waitForTimeout(500);

            const formResult = {
                form: formFile,
                checks: {}
            };

            // 1. Body-Hintergrundfarbe pruefen
            const bodyBgColor = await page.evaluate(() => {
                const body = document.body;
                const computed = window.getComputedStyle(body);
                return computed.backgroundColor;
            });
            const bodyBgHex = rgbToHex(bodyBgColor);
            formResult.checks.bodyBackground = {
                actual: bodyBgHex,
                expected: STANDARDS.bodyBackground,
                pass: bodyBgHex.toLowerCase() === STANDARDS.bodyBackground.toLowerCase()
            };
            console.log(`  Body BG: ${bodyBgHex} ${formResult.checks.bodyBackground.pass ? '✓' : '✗ (erwartet: ' + STANDARDS.bodyBackground + ')'}`);

            // 2. Sidebar pruefen
            const sidebarInfo = await page.evaluate(() => {
                // Verschiedene Sidebar-Selektoren versuchen
                const selectors = ['.left-menu', '.app-sidebar', '.sidebar', '[class*="sidebar"]', '[class*="menu"]'];
                let sidebar = null;

                for (const sel of selectors) {
                    sidebar = document.querySelector(sel);
                    if (sidebar && sidebar.offsetWidth > 100) break;
                }

                if (!sidebar) return null;

                const computed = window.getComputedStyle(sidebar);
                const buttons = sidebar.querySelectorAll('.menu-btn, button');

                return {
                    width: sidebar.offsetWidth,
                    backgroundColor: computed.backgroundColor,
                    buttonCount: buttons.length
                };
            });

            if (sidebarInfo) {
                const sidebarBgHex = rgbToHex(sidebarInfo.backgroundColor);

                formResult.checks.sidebarWidth = {
                    actual: sidebarInfo.width,
                    expected: STANDARDS.sidebarWidth,
                    pass: Math.abs(sidebarInfo.width - STANDARDS.sidebarWidth) <= 5
                };
                console.log(`  Sidebar Breite: ${sidebarInfo.width}px ${formResult.checks.sidebarWidth.pass ? '✓' : '✗ (erwartet: ' + STANDARDS.sidebarWidth + 'px)'}`);

                formResult.checks.sidebarBackground = {
                    actual: sidebarBgHex,
                    expected: STANDARDS.sidebarBackground,
                    pass: sidebarBgHex.toLowerCase() === STANDARDS.sidebarBackground.toLowerCase()
                };
                console.log(`  Sidebar BG: ${sidebarBgHex} ${formResult.checks.sidebarBackground.pass ? '✓' : '✗ (erwartet: ' + STANDARDS.sidebarBackground + ')'}`);

                formResult.checks.buttonCount = {
                    actual: sidebarInfo.buttonCount,
                    expected: STANDARDS.sidebarButtonCount,
                    pass: sidebarInfo.buttonCount === STANDARDS.sidebarButtonCount
                };
                console.log(`  Button-Anzahl: ${sidebarInfo.buttonCount} ${formResult.checks.buttonCount.pass ? '✓' : '✗ (erwartet: ' + STANDARDS.sidebarButtonCount + ')'}`);
            } else {
                console.log('  Sidebar: Nicht gefunden oder andere Struktur');
                formResult.checks.sidebar = { actual: 'nicht gefunden', pass: false };
            }

            // 3. Loading Overlay pruefen
            const hasLoadingOverlay = await page.evaluate(() => {
                return !!document.getElementById('loadingOverlay');
            });
            formResult.checks.loadingOverlay = {
                actual: hasLoadingOverlay,
                expected: true,
                pass: hasLoadingOverlay
            };
            console.log(`  Loading Overlay: ${hasLoadingOverlay ? '✓' : '✗'}`);

            // 4. Toast Container pruefen
            const hasToastContainer = await page.evaluate(() => {
                return !!document.getElementById('toastContainer');
            });
            formResult.checks.toastContainer = {
                actual: hasToastContainer,
                expected: true,
                pass: hasToastContainer
            };
            console.log(`  Toast Container: ${hasToastContainer ? '✓' : '✗'}`);

            // 5. global-handlers.js pruefen
            const hasGlobalHandlers = await page.evaluate(() => {
                const scripts = Array.from(document.querySelectorAll('script[src]'));
                return scripts.some(s => s.src.includes('global-handlers.js'));
            });
            formResult.checks.globalHandlers = {
                actual: hasGlobalHandlers,
                expected: true,
                pass: hasGlobalHandlers
            };
            console.log(`  global-handlers.js: ${hasGlobalHandlers ? '✓' : '✗'}`);

            // Screenshot aufnehmen
            const screenshotPath = path.join(SCREENSHOTS_DIR, formFile.replace('.html', '.png'));
            await page.screenshot({
                path: screenshotPath,
                fullPage: false
            });
            console.log(`  Screenshot: ${screenshotPath}`);

            // Gesamtstatus
            const allPassed = Object.values(formResult.checks).every(c => c.pass);
            formResult.status = allPassed ? 'PASS' : 'FAIL';
            results.push(formResult);

        } catch (error) {
            console.log(`  FEHLER: ${error.message}`);
            results.push({
                form: formFile,
                status: 'ERROR',
                error: error.message
            });
        }
    }

    await browser.close();

    // Zusammenfassung
    console.log('\n' + '='.repeat(60));
    console.log('ZUSAMMENFASSUNG');
    console.log('='.repeat(60));

    const passed = results.filter(r => r.status === 'PASS').length;
    const failed = results.filter(r => r.status === 'FAIL').length;
    const errors = results.filter(r => r.status === 'ERROR').length;
    const skipped = results.filter(r => r.status === 'SKIP').length;

    console.log(`Bestanden: ${passed}`);
    console.log(`Fehlgeschlagen: ${failed}`);
    console.log(`Fehler: ${errors}`);
    console.log(`Uebersprungen: ${skipped}`);

    // Detaillierte Fehler anzeigen
    const failedForms = results.filter(r => r.status === 'FAIL');
    if (failedForms.length > 0) {
        console.log('\nFEHLGESCHLAGENE FORMULARE:');
        for (const form of failedForms) {
            console.log(`\n${form.form}:`);
            for (const [check, result] of Object.entries(form.checks)) {
                if (!result.pass) {
                    console.log(`  - ${check}: ${result.actual} (erwartet: ${result.expected})`);
                }
            }
        }
    }

    // Ergebnis als JSON speichern
    const reportPath = path.join(SCREENSHOTS_DIR, 'visual_test_report.json');
    fs.writeFileSync(reportPath, JSON.stringify(results, null, 2));
    console.log(`\nReport gespeichert: ${reportPath}`);

    return results;
}

// Hilfsfunktion: RGB zu HEX
function rgbToHex(rgb) {
    if (!rgb || rgb === 'transparent') return 'transparent';

    // Falls bereits HEX
    if (rgb.startsWith('#')) return rgb;

    // RGB(a) parsen
    const match = rgb.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    if (!match) return rgb;

    const r = parseInt(match[1]);
    const g = parseInt(match[2]);
    const b = parseInt(match[3]);

    return '#' + [r, g, b].map(x => x.toString(16).padStart(2, '0')).join('').toUpperCase();
}

// Test ausfuehren
runVisualTest().then(results => {
    console.log('\nTest abgeschlossen.');
    process.exit(results.every(r => r.status === 'PASS' || r.status === 'SKIP') ? 0 : 1);
}).catch(err => {
    console.error('Test-Fehler:', err);
    process.exit(1);
});
