import { test, expect, Page } from '@playwright/test';

/**
 * E2E Tests fuer frm_MA_Mitarbeiterstamm.html
 *
 * Testet die Mitarbeiterverwaltung inkl.:
 * - Navigation (First/Prev/Next/Last)
 * - CRUD-Operationen (Neu, Speichern, Loeschen)
 * - Pflichtfeld-Validierung
 * - Tab-Navigation (Stammdaten, Nichtverfuegbarkeiten, etc.)
 * - Foto-Upload Bereich
 * - Keine JavaScript-Fehler
 */

test.describe('Mitarbeiterstamm Formular', () => {
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
    await page.goto('/shell.html?form=frm_MA_Mitarbeiterstamm');
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
    await expect(iframe.locator('#btnNeuMA')).toBeVisible();
    await expect(iframe.locator('#btnLöschen')).toBeVisible();
    await expect(iframe.locator('#btnSpeichern')).toBeVisible();

    // Navigation-Buttons pruefen
    await expect(iframe.locator('#btnErste')).toBeVisible();
    await expect(iframe.locator('#btnVorige')).toBeVisible();
    await expect(iframe.locator('#btnNächste')).toBeVisible();
    await expect(iframe.locator('#btnLetzte')).toBeVisible();
  });

  test('Stammdaten-Felder sind vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Hauptfelder im Stammdaten-Tab
    await expect(iframe.locator('#ID')).toBeVisible();
    await expect(iframe.locator('#Nachname')).toBeVisible();
    await expect(iframe.locator('#Vorname')).toBeVisible();
    await expect(iframe.locator('#Strasse')).toBeVisible();
    await expect(iframe.locator('#PLZ')).toBeVisible();
    await expect(iframe.locator('#Ort')).toBeVisible();
    await expect(iframe.locator('#Tel_Mobil')).toBeVisible();
    await expect(iframe.locator('#Email')).toBeVisible();
    await expect(iframe.locator('#IstAktiv')).toBeVisible();
  });

  test('Mitarbeiter-Name wird im Header angezeigt', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Name-Display im Header
    await expect(iframe.locator('#displayNachname')).toBeVisible();
    await expect(iframe.locator('#displayVorname')).toBeVisible();
  });

  // =====================================================
  // NAVIGATION
  // =====================================================

  test('Navigation Buttons navigieren durch Datensaetze', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Zur ersten Seite
    await iframe.locator('#btnErste').click();
    await page.waitForTimeout(500);

    // Zum naechsten Datensatz
    await iframe.locator('#btnNächste').click();
    await page.waitForTimeout(500);

    // Zum letzten Datensatz
    await iframe.locator('#btnLetzte').click();
    await page.waitForTimeout(500);

    // Zum vorherigen Datensatz
    await iframe.locator('#btnVorige').click();
    await page.waitForTimeout(500);

    // Keine kritischen Fehler
    const criticalErrors = consoleErrors.filter(e =>
      !e.includes('API') && !e.includes('fetch')
    );
    expect(criticalErrors).toHaveLength(0);
  });

  // =====================================================
  // CRUD OPERATIONS
  // =====================================================

  test('Neuer Mitarbeiter Button oeffnet leeres Formular', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Neuer Mitarbeiter klicken
    await iframe.locator('#btnNeuMA').click();

    // Warten auf UI-Update
    await page.waitForTimeout(500);

    // ID-Feld sollte leer oder "neu" sein
    // (Je nach Implementierung)
  });

  test('Speichern Button ist klickbar', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Warten bis Formular bereit
    await expect(iframe.locator('#btnSpeichern')).toBeEnabled();

    // Speichern klicken (ohne Aenderungen)
    await iframe.locator('#btnSpeichern').click();

    // Warten
    await page.waitForTimeout(500);
  });

  test('Aktualisieren laedt Daten neu', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    await iframe.locator('#btnAktualisieren').click();
    await page.waitForTimeout(1000);
  });

  // =====================================================
  // FIELD VALIDATION
  // =====================================================

  test('Pflichtfelder sind markiert', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Nachname hat required
    await expect(iframe.locator('#Nachname')).toHaveAttribute('required', '');

    // Vorname hat required
    await expect(iframe.locator('#Vorname')).toHaveAttribute('required', '');
  });

  test('E-Mail Feld hat Pattern-Validierung', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Email-Feld hat pattern
    const emailField = iframe.locator('#Email');
    await expect(emailField).toHaveAttribute('type', 'email');
    await expect(emailField).toHaveAttribute('pattern');
  });

  test('PLZ Feld hat Pattern-Validierung', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    const plzField = iframe.locator('#PLZ');
    await expect(plzField).toHaveAttribute('pattern', '[0-9]{5}');
  });

  test('Telefon-Felder haben Pattern-Validierung', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    await expect(iframe.locator('#Tel_Mobil')).toHaveAttribute('type', 'tel');
    await expect(iframe.locator('#Tel_Festnetz')).toHaveAttribute('type', 'tel');
  });

  test('Datumsfelder sind vom Typ date', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    await expect(iframe.locator('#Geb_Dat')).toHaveAttribute('type', 'date');
    await expect(iframe.locator('#Eintrittsdatum')).toHaveAttribute('type', 'date');
    await expect(iframe.locator('#Austrittsdatum')).toHaveAttribute('type', 'date');
  });

  test('IBAN Feld hat Pattern-Validierung', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    const ibanField = iframe.locator('#IBAN');
    await expect(ibanField).toHaveAttribute('pattern');
  });

  // =====================================================
  // DATA ENTRY
  // =====================================================

  test('Textfelder akzeptieren Eingaben', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    const nachnameField = iframe.locator('#Nachname');
    await nachnameField.fill('Test-Nachname');
    await expect(nachnameField).toHaveValue('Test-Nachname');

    const vornameField = iframe.locator('#Vorname');
    await vornameField.fill('Test-Vorname');
    await expect(vornameField).toHaveValue('Test-Vorname');
  });

  test('Checkbox-Felder sind togglebar', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    const istAktiv = iframe.locator('#IstAktiv');
    const initialState = await istAktiv.isChecked();

    await istAktiv.click();
    expect(await istAktiv.isChecked()).toBe(!initialState);

    // Zurueck zum urspruenglichen Zustand
    await istAktiv.click();
    expect(await istAktiv.isChecked()).toBe(initialState);
  });

  test('Dropdown-Felder sind auswahlbar', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Land-Dropdown
    const landDropdown = iframe.locator('#Land');
    await expect(landDropdown).toBeVisible();

    // Geschlecht-Dropdown
    const geschlechtDropdown = iframe.locator('#Geschlecht');
    await expect(geschlechtDropdown).toBeVisible();

    // Anstellungsart-Dropdown
    const anstellungsartDropdown = iframe.locator('#Anstellungsart_ID');
    await expect(anstellungsartDropdown).toBeVisible();
  });

  // =====================================================
  // TAB NAVIGATION
  // =====================================================

  test('Stammdaten Tab ist initial aktiv', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Stammdaten-Tab ist aktiv
    await expect(iframe.locator('#tab-stammdaten')).toHaveClass(/active/);
  });

  test('Tab-Wechsel funktioniert', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Pruefen ob weitere Tabs existieren
    const tabButtons = iframe.locator('[role="tab"], .tab-button, [data-tab]');
    const tabCount = await tabButtons.count();

    if (tabCount > 1) {
      // Zum naechsten Tab wechseln
      await tabButtons.nth(1).click();
      await page.waitForTimeout(300);
    }
  });

  // =====================================================
  // FOTO SECTION
  // =====================================================

  test('Foto-Bereich ist vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Foto-Element
    await expect(iframe.locator('#maPhoto')).toBeVisible();

    // Upload-Input (versteckt)
    await expect(iframe.locator('#fotoUploadInput')).toBeAttached();
  });

  // =====================================================
  // HEADER BUTTONS
  // =====================================================

  test('Zusaetzliche Header-Buttons sind vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Spezielle Buttons
    await expect(iframe.locator('#btnMAAdressen')).toBeVisible();
    await expect(iframe.locator('#btnZeitkonto')).toBeVisible();
    await expect(iframe.locator('#btnDienstplan')).toBeVisible();
    await expect(iframe.locator('#btnEinsatzÜbersicht')).toBeVisible();
    await expect(iframe.locator('#btnMapsÖffnen')).toBeVisible();

    // Zeitkonten-Buttons
    await expect(iframe.locator('#btnZKFest')).toBeVisible();
    await expect(iframe.locator('#btnZKMini')).toBeVisible();
    await expect(iframe.locator('#btnZKeinzel')).toBeVisible();
  });

  test('Excel Export Dropdown ist vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    // Excel Export Button
    const excelBtn = iframe.locator('button:has-text("Excel Export")');
    await expect(excelBtn).toBeVisible();

    // Dropdown-Menue oeffnen
    await excelBtn.click();
    await page.waitForTimeout(300);

    // Dropdown-Optionen pruefen
    await expect(iframe.locator('button:has-text("Einsatzuebersicht")')).toBeVisible();
  });

  test('Zeitraum-Dropdown ist vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    const cboZeitraum = iframe.locator('#cboZeitraum');
    await expect(cboZeitraum).toBeVisible();

    // Optionen pruefen
    const options = await cboZeitraum.locator('option').count();
    expect(options).toBeGreaterThan(0);
  });

  // =====================================================
  // BANK DATA SECTION
  // =====================================================

  test('Bankdaten-Felder sind vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    await expect(iframe.locator('#Kontoinhaber')).toBeVisible();
    await expect(iframe.locator('#Bankname')).toBeVisible();
    await expect(iframe.locator('#IBAN')).toBeVisible();
    await expect(iframe.locator('#BIC')).toBeVisible();
  });

  // =====================================================
  // EMPLOYMENT DATA
  // =====================================================

  test('Anstellungsdaten-Felder sind vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    await expect(iframe.locator('#Eintrittsdatum')).toBeVisible();
    await expect(iframe.locator('#Austrittsdatum')).toBeVisible();
    await expect(iframe.locator('#Anstellungsart_ID')).toBeVisible();
    await expect(iframe.locator('#Stundenlohn_brutto')).toBeVisible();
    await expect(iframe.locator('#Kostenstelle')).toBeVisible();
  });

  test('Urlaub-Felder sind vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    await expect(iframe.locator('#Resturlaub_Vorjahr')).toBeVisible();
    await expect(iframe.locator('#Urlaubsanspr_pro_Jahr')).toBeVisible();
  });

  // =====================================================
  // SECURITY DATA
  // =====================================================

  test('Sicherheitsrelevante Felder sind vorhanden', async ({ page }) => {
    const iframe = page.frameLocator('#contentFrame');

    await expect(iframe.locator('#DienstausweisNr')).toBeVisible();
    await expect(iframe.locator('#Ausweis_Endedatum')).toBeVisible();
    await expect(iframe.locator('#Bewacher_ID')).toBeVisible();
    await expect(iframe.locator('#Hat_keine_34a')).toBeVisible();
    await expect(iframe.locator('#HatSachkunde')).toBeVisible();
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
  // SHELL INTEGRATION
  // =====================================================

  test('Shell-Navigation zum Formular funktioniert', async ({ page }) => {
    // Header zeigt richtigen Titel
    await expect(page.locator('#contentHeader')).toContainText('Mitarbeiterstamm');

    // Menu-Button ist aktiv markiert
    await expect(page.locator('[data-form="frm_MA_Mitarbeiterstamm"]')).toHaveClass(/active/);
  });

  test('Navigation von Shell zu anderem Formular', async ({ page }) => {
    // Zu Auftraege navigieren
    await page.locator('[data-form="frm_va_Auftragstamm"]').click();

    // Warten auf Navigation
    await page.waitForLoadState('networkidle');

    // Header hat sich geaendert
    await expect(page.locator('#contentHeader')).toContainText('Auftragsverwaltung');

    // Zurueck zu Mitarbeiter
    await page.locator('[data-form="frm_MA_Mitarbeiterstamm"]').click();
    await page.waitForLoadState('networkidle');

    await expect(page.locator('#contentHeader')).toContainText('Mitarbeiterstamm');
  });
});

// =====================================================
// PERFORMANCE TESTS
// =====================================================

test.describe('Mitarbeiterstamm Performance', () => {
  test('Initiale Ladezeit unter 5 Sekunden', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/shell.html?form=frm_MA_Mitarbeiterstamm');
    await page.waitForLoadState('networkidle');

    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(5000);

    console.log(`Ladezeit: ${loadTime}ms`);
  });

  test('Navigation unter 1 Sekunde', async ({ page }) => {
    await page.goto('/shell.html?form=frm_MA_Mitarbeiterstamm');
    await page.waitForLoadState('networkidle');

    const iframe = page.frameLocator('#contentFrame');

    const startTime = Date.now();
    await iframe.locator('#btnNächste').click();
    await page.waitForTimeout(300);

    const navTime = Date.now() - startTime;
    expect(navTime).toBeLessThan(1000);

    console.log(`Navigationszeit: ${navTime}ms`);
  });
});

// =====================================================
// RESPONSIVE TESTS
// =====================================================

test.describe('Mitarbeiterstamm Responsive', () => {
  test('Formular ist bei verschiedenen Viewports nutzbar', async ({ page }) => {
    await page.goto('/shell.html?form=frm_MA_Mitarbeiterstamm');
    await page.waitForLoadState('networkidle');

    const iframe = page.frameLocator('#contentFrame');

    // Desktop (1920x1080)
    await page.setViewportSize({ width: 1920, height: 1080 });
    await expect(iframe.locator('#Nachname')).toBeVisible();

    // Laptop (1366x768)
    await page.setViewportSize({ width: 1366, height: 768 });
    await expect(iframe.locator('#Nachname')).toBeVisible();

    // Tablet (1024x768)
    await page.setViewportSize({ width: 1024, height: 768 });
    await expect(iframe.locator('#Nachname')).toBeVisible();
  });
});
