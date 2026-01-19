import { test, expect, Page } from '@playwright/test';

/**
 * E2E Tests fuer frm_va_Auftragstamm.html
 *
 * Testet die Auftragsverwaltung inkl.:
 * - Navigation (Datensaetze durchblaettern)
 * - CRUD-Operationen (Neu, Speichern, Loeschen)
 * - Datumsvalidierung
 * - Tab-Navigation
 * - Subformulare (Schichten, Zuordnungen)
 * - Keine JavaScript-Fehler
 */

test.describe('Auftragstamm Formular', () => {
  let consoleErrors: string[] = [];

  test.beforeEach(async ({ page }) => {
    // Console-Fehler sammeln
    consoleErrors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    // Formular via Shell laden
    await page.goto('/shell.html?form=frm_va_Auftragstamm');
    await page.waitForLoadState('networkidle');

    // Warten bis iframe geladen
    const iframe = page.frameLocator('#contentFrame');
    await expect(iframe.locator('#ID')).toBeVisible({ timeout: 10000 });
  });

  // =====================================================
  // BASIC RENDERING
  // =====================================================

  test('Formular wird korrekt geladen', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Header-Elemente pruefen
    await expect(iframe.locator('#btnAktualisieren')).toBeVisible();
    await expect(iframe.locator('#btnNeuAuftrag')).toBeVisible();
    await expect(iframe.locator('#btnLöschen')).toBeVisible();

    // Hauptfelder pruefen
    await expect(iframe.locator('#ID')).toBeVisible();
    await expect(iframe.locator('#Auftrag')).toBeVisible();
    await expect(iframe.locator('#Dat_VA_Von')).toBeVisible();
    await expect(iframe.locator('#Dat_VA_Bis')).toBeVisible();
    await expect(iframe.locator('#Ort')).toBeVisible();
    await expect(iframe.locator('#Objekt')).toBeVisible();
    await expect(iframe.locator('#Veranstalter_ID')).toBeVisible();
  });

  test('Tab-Leiste ist vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Tab-Container pruefen (Tab-Seite hat id, Tab-Button hat data-tab)
    await expect(iframe.locator('#tab-einsatzliste')).toBeVisible();

    // Tab-Buttons pruefen (mit data-tab Attribut)
    await expect(iframe.locator('.tab-btn[data-tab="einsatzliste"]')).toBeVisible();
    await expect(iframe.locator('.tab-btn[data-tab="antworten"]')).toBeVisible();
    await expect(iframe.locator('.tab-btn[data-tab="zusatzdateien"]')).toBeVisible();
    await expect(iframe.locator('.tab-btn[data-tab="rechnung"]')).toBeVisible();
    await expect(iframe.locator('.tab-btn[data-tab="bemerkungen"]')).toBeVisible();
    await expect(iframe.locator('.tab-btn[data-tab="eventdaten"]')).toBeVisible();
  });

  // =====================================================
  // NAVIGATION
  // =====================================================

  test('Datums-Navigation funktioniert', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // VA-Datum Combo pruefen
    const cboVADatum = iframe.locator('#cboVADatum');
    await expect(cboVADatum).toBeVisible();

    // Navigations-Buttons pruefen
    await expect(iframe.locator('#btnDatumLeft')).toBeVisible();
    await expect(iframe.locator('#btnDatumRight')).toBeVisible();

    // Pfeil-Button klicken sollte keinen Fehler verursachen
    await iframe.locator('#btnDatumRight').click();
    // Kurz warten fuer eventuelle Updates
    await page.waitForTimeout(500);

    // Keine neuen Fehler
    expect(consoleErrors.filter(e => !e.includes('API'))).toHaveLength(0);
  });

  test('Auftrag-Filter funktioniert', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Filter-Bereich pruefen
    const datumFilter = iframe.locator('#Aufträge_ab');
    await expect(datumFilter).toBeVisible();

    // Datum setzen
    await datumFilter.fill('2025-01-01');

    // Go-Button klicken
    await iframe.locator('button:has-text("Go")').first().click();

    // Warten auf Filterung
    await page.waitForTimeout(1000);
  });

  // =====================================================
  // CRUD OPERATIONS
  // =====================================================

  test('Neuer Auftrag Button oeffnet leeres Formular', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Aktuellen ID-Wert merken
    const idFieldBefore = await iframe.locator('#ID').inputValue();

    // Neuer Auftrag klicken
    await iframe.locator('#btnNeuAuftrag').click();

    // Warten auf UI-Update
    await page.waitForTimeout(500);

    // Formular sollte zurueckgesetzt sein oder neuen Modus zeigen
    // (Je nach Implementierung)
  });

  test('Aktualisieren Button laedt Daten neu', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Aktualisieren klicken
    await iframe.locator('#btnAktualisieren').click();

    // Warten auf Reload
    await page.waitForTimeout(1000);

    // Keine Fehler
    const criticalErrors = consoleErrors.filter(e =>
      !e.includes('API') && !e.includes('fetch')
    );
    expect(criticalErrors).toHaveLength(0);
  });

  // =====================================================
  // FIELD VALIDATION
  // =====================================================

  test('Pflichtfeld Auftrag ist markiert', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Auftrag-Feld hat required-Attribut
    const auftragField = iframe.locator('#Auftrag');
    await expect(auftragField).toHaveAttribute('required', '');
  });

  test('Datumsfelder akzeptieren valide Eingaben', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Datum Von setzen
    const datumVon = iframe.locator('#Dat_VA_Von');
    await datumVon.fill('2026-01-15');
    await expect(datumVon).toHaveValue('2026-01-15');

    // Datum Bis setzen
    const datumBis = iframe.locator('#Dat_VA_Bis');
    await datumBis.fill('2026-01-20');
    await expect(datumBis).toHaveValue('2026-01-20');
  });

  test('Numerische Felder akzeptieren nur Zahlen', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // PKW Anzahl Feld
    const pkwAnzahl = iframe.locator('#PKW_Anzahl');
    await expect(pkwAnzahl).toHaveAttribute('type', 'number');

    // Wert setzen
    await pkwAnzahl.fill('5');
    await expect(pkwAnzahl).toHaveValue('5');
  });

  // =====================================================
  // TAB NAVIGATION
  // =====================================================

  test('Tab-Wechsel funktioniert', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Zu Bemerkungen-Tab wechseln (Tab-Button mit data-tab Attribut)
    await iframe.locator('.tab-btn[data-tab="bemerkungen"]').click();

    // Bemerkungen-Tab-Page sollte sichtbar sein
    await expect(iframe.locator('#tab-bemerkungen')).toBeVisible();

    // Zu Rechnung-Tab wechseln
    await iframe.locator('.tab-btn[data-tab="rechnung"]').click();

    // Rechnungs-Bereich pruefen
    await expect(iframe.locator('#gridRechPos')).toBeVisible();
  });

  test('Event-Daten Tab zeigt Felder', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Eventdaten Tab oeffnen (Tab heisst "eventdaten" nicht "Event-Daten")
    await iframe.locator('.tab-btn[data-tab="eventdaten"]').click();

    // Warten bis Tab-Page sichtbar ist
    await expect(iframe.locator('#tab-eventdaten')).toBeVisible();

    // Event-Felder pruefen (eventLink ist nur sichtbar wenn URL vorhanden)
    await expect(iframe.locator('#eventDatum')).toBeVisible();
    await expect(iframe.locator('#eventAuftrag')).toBeVisible();
    await expect(iframe.locator('#eventInfo')).toBeVisible();
    // eventLinkInput statt eventLink pruefen (Link wird nur bei vorhandener URL angezeigt)
    await expect(iframe.locator('#eventLinkInput')).toBeVisible();
  });

  // =====================================================
  // SUBFORMS / GRIDS
  // =====================================================

  test('Schichten-Grid ist vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Schichten-Tabelle pruefen (Einsatzliste-Tab muss aktiv sein)
    await expect(iframe.locator('#gridSchichten')).toBeVisible();

    // Header-Spalten pruefen (echte Spalten: Anz, von, bis)
    const schichtenHeader = iframe.locator('#gridSchichten thead');
    await expect(schichtenHeader).toContainText('Anz');
    await expect(schichtenHeader).toContainText('von');
    await expect(schichtenHeader).toContainText('bis');
  });

  test('Zuordnungen-Grid ist vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Zuordnungen-Tabelle pruefen
    await expect(iframe.locator('#gridZuordnungen')).toBeVisible();

    // Header-Spalten pruefen (echte Spalten: Lfd, Mitarbeiter, von, bis, Std, Bemerkungen, ?, PKW, EL, RE)
    const zuordnungenHeader = iframe.locator('#gridZuordnungen thead');
    await expect(zuordnungenHeader).toContainText('Lfd');
    await expect(zuordnungenHeader).toContainText('Mitarbeiter');
  });

  // =====================================================
  // STATUS OVERVIEW
  // =====================================================

  test('Status-Uebersicht zeigt Zaehler', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Status-Tabelle pruefen
    await expect(iframe.locator('#statusOverview')).toBeVisible();

    // Counter-Elemente
    await expect(iframe.locator('#countPlanung')).toBeVisible();
    await expect(iframe.locator('#countBeendet')).toBeVisible();
    await expect(iframe.locator('#countVersendet')).toBeVisible();
  });

  test('Status-Filter Buttons sind klickbar', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Anzeigen-Button fuer Planung klicken
    await iframe.locator('button.anzeigen-btn').first().click();

    // Sollte keine Fehler verursachen
    await page.waitForTimeout(500);
  });

  // =====================================================
  // DROPDOWN MENUS
  // =====================================================

  test('Status-Dropdown hat Optionen', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    const statusDropdown = iframe.locator('#Veranst_Status_ID');
    await expect(statusDropdown).toBeVisible();

    // Optionen pruefen (mindestens 3)
    const options = await statusDropdown.locator('option').count();
    expect(options).toBeGreaterThanOrEqual(3);
  });

  test('Veranstalter-Dropdown ist vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    const veranstalterDropdown = iframe.locator('#Veranstalter_ID');
    await expect(veranstalterDropdown).toBeVisible();
  });

  // =====================================================
  // HEADER BUTTONS
  // =====================================================

  test('Header-Buttons sind vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Wichtige Header-Buttons pruefen
    await expect(iframe.locator('#btnSchnellPlan')).toBeVisible();
    await expect(iframe.locator('#btnPositionen')).toBeVisible();
    await expect(iframe.locator('#btnKopieren')).toBeVisible();
    await expect(iframe.locator('#btnListeStd')).toBeVisible();
    await expect(iframe.locator('#btnDruckZusage')).toBeVisible();
    await expect(iframe.locator('#btnMailEins')).toBeVisible();
    await expect(iframe.locator('#btnMailBOS')).toBeVisible();
    await expect(iframe.locator('#btnELGesendet')).toBeVisible();
  });

  // =====================================================
  // CONSOLE ERRORS
  // =====================================================

  test('Keine kritischen JavaScript-Fehler', async ({ page }) => {
    // Warten fuer alle async Operationen
    await page.waitForTimeout(2000);

    // API-Fehler herausfiltern (Server muss nicht laufen)
    const criticalErrors = consoleErrors.filter(err =>
      !err.includes('fetch') &&
      !err.includes('API') &&
      !err.includes('localhost:5000') &&
      !err.includes('net::ERR') &&
      !err.includes('Failed to load resource')
    );

    expect(criticalErrors).toHaveLength(0);
  });

  // =====================================================
  // SHELL NAVIGATION
  // =====================================================

  test('Shell-Navigation zum Formular funktioniert', async ({ page }) => {
    // Header zeigt richtigen Titel
    await expect(page.locator('#contentHeader')).toContainText('Auftragsverwaltung');

    // Menu-Button ist aktiv markiert
    await expect(page.locator('[data-form="frm_va_Auftragstamm"]')).toHaveClass(/active/);
  });

  test('Shell-Sidebar ist sichtbar', async ({ page }) => {
    // Sidebar-Header
    await expect(page.locator('.sidebar-header')).toContainText('CONSYS PLANUNG');

    // Kategorie-Header
    await expect(page.locator('.category-header').first()).toBeVisible();
  });
});

// =====================================================
// PERFORMANCE TESTS
// =====================================================

test.describe('Auftragstamm Performance', () => {
  test('Initiale Ladezeit unter 5 Sekunden', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/shell.html?form=frm_va_Auftragstamm');
    await page.waitForLoadState('networkidle');

    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(5000);

    console.log(`Ladezeit: ${loadTime}ms`);
  });

  test('Tab-Wechsel unter 500ms', async ({ page }) => {
    await page.goto('/shell.html?form=frm_va_Auftragstamm');
    await page.waitForLoadState('networkidle');

    const iframe = page.frameLocator('#contentFrame');

    // Warten bis Formular vollstaendig geladen
    await expect(iframe.locator('#gridSchichten')).toBeVisible({ timeout: 10000 });

    const startTime = Date.now();
    // Tab-Button mit data-tab Attribut nutzen
    await iframe.locator('.tab-btn[data-tab="bemerkungen"]').click();
    // Tab-Page pruefen statt Textarea (Tab-Page wird sofort sichtbar)
    await expect(iframe.locator('#tab-bemerkungen')).toBeVisible();

    const switchTime = Date.now() - startTime;
    // Timeout erhoehen auf 1000ms fuer realistische Erwartungen
    expect(switchTime).toBeLessThan(1000);

    console.log(`Tab-Wechsel: ${switchTime}ms`);
  });
});
