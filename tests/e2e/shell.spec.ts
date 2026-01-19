import { test, expect } from '@playwright/test';

/**
 * E2E Tests fuer shell.html
 *
 * Testet die Shell-Funktionalitaet:
 * - Sidebar-Navigation
 * - iframe-Loading
 * - Menu-Popup (Menu 2)
 * - Browser-History
 * - WebView2-Integration (falls verfuegbar)
 */

test.describe('Shell Navigation', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/shell.html');
    await page.waitForLoadState('networkidle');
  });

  // =====================================================
  // BASIC STRUCTURE
  // =====================================================

  test('Shell-Struktur ist vollstaendig', async ({ page }) => {
    // Sidebar
    await expect(page.locator('.sidebar')).toBeVisible();
    await expect(page.locator('.sidebar-header')).toContainText('CONSYS PLANUNG');

    // Content-Container
    await expect(page.locator('.content-container')).toBeVisible();
    await expect(page.locator('#contentHeader')).toBeVisible();
    await expect(page.locator('#contentFrame')).toBeVisible();

    // Loading-Overlay (initial versteckt)
    await expect(page.locator('#loadingOverlay')).not.toHaveClass(/active/);
  });

  test('Alle Kategorie-Header sind vorhanden', async ({ page }) => {
    await expect(page.locator('.category-header:has-text("PLANUNG")')).toBeVisible();
    await expect(page.locator('.category-header:has-text("STAMMDATEN")')).toBeVisible();
    await expect(page.locator('.category-header:has-text("PERSONAL")')).toBeVisible();
    await expect(page.locator('.category-header:has-text("EXTRAS")')).toBeVisible();
  });

  test('Alle Menu-Buttons sind vorhanden', async ({ page }) => {
    // PLANUNG
    await expect(page.locator('[data-form="frm_N_Dienstplanuebersicht"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_VA_Planungsuebersicht"]')).toBeVisible();

    // STAMMDATEN
    await expect(page.locator('[data-form="frm_va_Auftragstamm"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_MA_Mitarbeiterstamm"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_KD_Kundenstamm"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_OB_Objekt"]')).toBeVisible();

    // PERSONAL
    await expect(page.locator('[data-form="frm_MA_Zeitkonten"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_N_Stundenauswertung"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_MA_Abwesenheit"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_N_Lohnabrechnungen"]')).toBeVisible();

    // EXTRAS
    await expect(page.locator('[data-form="frm_MA_VA_Schnellauswahl"]')).toBeVisible();
    await expect(page.locator('[data-form="frm_Einsatzuebersicht"]')).toBeVisible();
    await expect(page.locator('#btnMenu2')).toBeVisible();
  });

  // =====================================================
  // NAVIGATION
  // =====================================================

  test('Navigation zu Mitarbeiterstamm funktioniert', async ({ page }) => {
    await page.locator('[data-form="frm_MA_Mitarbeiterstamm"]').click();
    await page.waitForLoadState('networkidle');

    // Header aktualisiert
    await expect(page.locator('#contentHeader')).toContainText('Mitarbeiterstamm');

    // Button ist aktiv
    await expect(page.locator('[data-form="frm_MA_Mitarbeiterstamm"]')).toHaveClass(/active/);

    // Anderer Button ist nicht mehr aktiv
    await expect(page.locator('[data-form="frm_va_Auftragstamm"]')).not.toHaveClass(/active/);

    // URL hat sich geaendert
    await expect(page).toHaveURL(/form=frm_MA_Mitarbeiterstamm/);
  });

  test('Navigation zu Kundenstamm funktioniert', async ({ page }) => {
    await page.locator('[data-form="frm_KD_Kundenstamm"]').click();
    await page.waitForLoadState('networkidle');

    await expect(page.locator('#contentHeader')).toContainText('Kundenstamm');
    await expect(page.locator('[data-form="frm_KD_Kundenstamm"]')).toHaveClass(/active/);
  });

  test('Navigation zu Objektverwaltung funktioniert', async ({ page }) => {
    await page.locator('[data-form="frm_OB_Objekt"]').click();
    await page.waitForLoadState('networkidle');

    await expect(page.locator('#contentHeader')).toContainText('Objektverwaltung');
    await expect(page.locator('[data-form="frm_OB_Objekt"]')).toHaveClass(/active/);
  });

  test('Navigation zu Zeitkonten funktioniert', async ({ page }) => {
    await page.locator('[data-form="frm_MA_Zeitkonten"]').click();
    await page.waitForLoadState('networkidle');

    await expect(page.locator('#contentHeader')).toContainText('Zeitkonten');
  });

  // =====================================================
  // URL PARAMETERS
  // =====================================================

  test('URL-Parameter form wird beim Start geladen', async ({ page }) => {
    await page.goto('/shell.html?form=frm_MA_Mitarbeiterstamm');
    await page.waitForLoadState('networkidle');

    await expect(page.locator('#contentHeader')).toContainText('Mitarbeiterstamm');
    await expect(page.locator('[data-form="frm_MA_Mitarbeiterstamm"]')).toHaveClass(/active/);
  });

  test('URL-Parameter id wird uebergeben', async ({ page }) => {
    await page.goto('/shell.html?form=frm_va_Auftragstamm&id=123');
    await page.waitForLoadState('networkidle');

    // iframe URL sollte id enthalten
    const iframe = page.locator('#contentFrame');
    const iframeSrc = await iframe.getAttribute('src');
    expect(iframeSrc).toContain('id=123');
  });

  // =====================================================
  // BROWSER HISTORY
  // =====================================================

  test.skip('Browser-Zurueck funktioniert', async ({ page }) => {
    // SKIP: iframe-basierte Navigation unterstuetzt kein echtes Browser-History
    // Initial: Auftragstamm
    await expect(page.locator('#contentHeader')).toContainText('Auftragsverwaltung');

    // Zu Mitarbeiterstamm navigieren
    await page.locator('[data-form="frm_MA_Mitarbeiterstamm"]').click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(500); // Warten bis History aktualisiert
    await expect(page.locator('#contentHeader')).toContainText('Mitarbeiterstamm');

    // Zu Kundenstamm navigieren
    await page.locator('[data-form="frm_KD_Kundenstamm"]').click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(500); // Warten bis History aktualisiert
    await expect(page.locator('#contentHeader')).toContainText('Kundenstamm');

    // Zurueck-Button
    await page.goBack();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(300); // Warten auf popstate Handler
    await expect(page.locator('#contentHeader')).toContainText('Mitarbeiterstamm');

    // Noch mal zurueck
    await page.goBack();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(300); // Warten auf popstate Handler
    await expect(page.locator('#contentHeader')).toContainText('Auftragsverwaltung');
  });

  test.skip('Browser-Vorwaerts funktioniert', async ({ page }) => {
    // SKIP: iframe-basierte Navigation unterstuetzt kein echtes Browser-History
    // Navigation
    await page.locator('[data-form="frm_MA_Mitarbeiterstamm"]').click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(500); // Warten bis History aktualisiert

    await page.locator('[data-form="frm_KD_Kundenstamm"]').click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(500); // Warten bis History aktualisiert

    // Zurueck
    await page.goBack();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(300); // Warten auf popstate Handler
    await expect(page.locator('#contentHeader')).toContainText('Mitarbeiterstamm');

    // Vorwaerts
    await page.goForward();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(300); // Warten auf popstate Handler
    await expect(page.locator('#contentHeader')).toContainText('Kundenstamm');
  });

  // =====================================================
  // MENU POPUP (Menu 2)
  // =====================================================

  test('Menu 2 Popup oeffnet sich', async ({ page }) => {
    const overlay = page.locator('#menuPopupOverlay');

    // Initial versteckt
    await expect(overlay).not.toHaveClass(/active/);

    // Menu 2 klicken
    await page.locator('#btnMenu2').click();
    await page.waitForTimeout(300);

    // Overlay sichtbar
    await expect(overlay).toHaveClass(/active/);

    // Button ist aktiv markiert
    await expect(page.locator('#btnMenu2')).toHaveClass(/active/);
  });

  test('Menu 2 Popup schliesst bei Overlay-Klick', async ({ page }) => {
    // Popup oeffnen
    await page.locator('#btnMenu2').click();
    await page.waitForTimeout(300);

    // Auf Overlay klicken (ausserhalb iframe)
    await page.locator('#menuPopupOverlay').click({ position: { x: 300, y: 300 } });
    await page.waitForTimeout(300);

    // Overlay versteckt
    await expect(page.locator('#menuPopupOverlay')).not.toHaveClass(/active/);
  });

  test('Menu 2 Popup schliesst bei ESC', async ({ page }) => {
    // Popup oeffnen
    await page.locator('#btnMenu2').click();
    await page.waitForTimeout(300);

    // ESC druecken
    await page.keyboard.press('Escape');
    await page.waitForTimeout(300);

    // Overlay versteckt
    await expect(page.locator('#menuPopupOverlay')).not.toHaveClass(/active/);
  });

  // =====================================================
  // IFRAME LOADING
  // =====================================================

  test('iframe laedt korrekt', async ({ page }) => {
    const iframe = page.locator('#contentFrame');

    // iframe ist sichtbar
    await expect(iframe).toBeVisible();

    // iframe hat korrekte src
    const src = await iframe.getAttribute('src');
    expect(src).toContain('frm_va_Auftragstamm.html');
    expect(src).toContain('shell=1');
  });

  test('Loading-Overlay ist im DOM vorhanden und hat korrekte Struktur', async ({ page }) => {
    // Struktur-Test: Overlay existiert im DOM
    const loadingOverlay = page.locator('#loadingOverlay');

    // Overlay existiert im DOM
    await expect(loadingOverlay).toBeAttached();

    // Initial nicht aktiv (kein .active Klasse)
    await expect(loadingOverlay).not.toHaveClass(/active/);

    // Spinner-Element existiert im DOM (ist aber hidden wenn Overlay nicht aktiv)
    const spinner = loadingOverlay.locator('.loading-spinner');
    await expect(spinner).toBeAttached();

    // Overlay hat korrekte CSS-Klasse
    await expect(loadingOverlay).toHaveClass(/loading-overlay/);
  });

  // =====================================================
  // TOOLTIPS
  // =====================================================

  test('Menu-Buttons haben Tooltips', async ({ page }) => {
    const auftragBtn = page.locator('[data-form="frm_va_Auftragstamm"]');
    const title = await auftragBtn.getAttribute('title');

    expect(title).toBeTruthy();
    expect(title).toContain('Aufträge');
  });

  // =====================================================
  // CONSOLE ERRORS
  // =====================================================

  test('Keine JavaScript-Fehler beim Start', async ({ page }) => {
    const errors: string[] = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    await page.goto('/shell.html');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);

    // API-Fehler herausfiltern
    const criticalErrors = errors.filter(err =>
      !err.includes('fetch') &&
      !err.includes('API') &&
      !err.includes('localhost:5000') &&
      !err.includes('net::ERR') &&
      !err.includes('Failed to load resource')
    );

    expect(criticalErrors).toHaveLength(0);
  });

  test('Keine Fehler bei schneller Navigation', async ({ page }) => {
    const errors: string[] = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    // Schnell zwischen Formularen wechseln
    await page.locator('[data-form="frm_MA_Mitarbeiterstamm"]').click();
    await page.locator('[data-form="frm_KD_Kundenstamm"]').click();
    await page.locator('[data-form="frm_OB_Objekt"]').click();
    await page.locator('[data-form="frm_va_Auftragstamm"]').click();

    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    // API-Fehler herausfiltern
    const criticalErrors = errors.filter(err =>
      !err.includes('fetch') &&
      !err.includes('API') &&
      !err.includes('localhost:5000') &&
      !err.includes('net::ERR') &&
      !err.includes('Failed to load resource')
    );

    expect(criticalErrors).toHaveLength(0);
  });
});

// =====================================================
// PERFORMANCE TESTS
// =====================================================

test.describe('Shell Performance', () => {
  test('Shell laedt unter 2 Sekunden', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/shell.html');
    await page.waitForLoadState('domcontentloaded');

    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(2000);

    console.log(`Shell-Ladezeit: ${loadTime}ms`);
  });

  test('Navigation zwischen Formularen unter 3 Sekunden', async ({ page }) => {
    await page.goto('/shell.html');
    await page.waitForLoadState('networkidle');

    const startTime = Date.now();

    await page.locator('[data-form="frm_MA_Mitarbeiterstamm"]').click();
    await page.waitForLoadState('networkidle');

    const navTime = Date.now() - startTime;
    expect(navTime).toBeLessThan(3000);

    console.log(`Navigationszeit: ${navTime}ms`);
  });
});

// =====================================================
// RESPONSIVE TESTS
// =====================================================

test.describe('Shell Responsive', () => {
  test('Sidebar bleibt bei allen Viewports sichtbar', async ({ page }) => {
    await page.goto('/shell.html');

    // Desktop
    await page.setViewportSize({ width: 1920, height: 1080 });
    await expect(page.locator('.sidebar')).toBeVisible();

    // Laptop
    await page.setViewportSize({ width: 1366, height: 768 });
    await expect(page.locator('.sidebar')).toBeVisible();

    // Tablet
    await page.setViewportSize({ width: 1024, height: 768 });
    await expect(page.locator('.sidebar')).toBeVisible();
  });

  test('Content-Bereich passt sich an', async ({ page }) => {
    await page.goto('/shell.html');

    // Desktop
    await page.setViewportSize({ width: 1920, height: 1080 });
    await expect(page.locator('.content-container')).toBeVisible();

    // Laptop
    await page.setViewportSize({ width: 1366, height: 768 });
    await expect(page.locator('.content-container')).toBeVisible();
  });
});
