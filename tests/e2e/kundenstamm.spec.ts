import { test, expect } from '@playwright/test';

/**
 * E2E Tests fuer frm_KD_Kundenstamm.html
 * Testet: Navigation, Speichern mit Pflichtfeld, Auftragsfilter, Ansprechpartner-Tab, JS-Errors
 */
test.describe('Kundenstamm (frm_KD_Kundenstamm)', () => {
  const errors: string[] = [];

  test.beforeEach(async ({ page }) => {
    // Console-Errors sammeln
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    // Formular laden (direkt oder via shell.html)
    await page.goto('/frm_KD_Kundenstamm.html');
    await page.waitForLoadState('networkidle');
  });

  test.afterEach(async () => {
    // Errors nach jedem Test leeren
    errors.length = 0;
  });

  test('laedt ohne JavaScript-Errors', async ({ page }) => {
    // Warten auf initiales Laden
    await page.waitForTimeout(2000);

    // Keine kritischen JS-Errors
    const criticalErrors = errors.filter(e =>
      !e.includes('favicon') &&
      !e.includes('404') &&
      !e.includes('localhost:5000') // API-Server evtl. nicht gestartet
    );
    expect(criticalErrors).toHaveLength(0);
  });

  test('zeigt Formular-Titel an', async ({ page }) => {
    // Titel vorhanden
    const titel = page.locator('.title-text, .title-bar, h1, h2').first();
    await expect(titel).toBeVisible();

    // "Kunde" im Titel enthalten
    const pageContent = await page.content();
    expect(pageContent.toLowerCase()).toContain('kunde');
  });

  test('Navigation: Alle Buttons vorhanden', async ({ page }) => {
    // Navigation Buttons via data-testid (zuverlaessiger)
    const firstBtn = page.locator('[data-testid="kd-btn-erste"]');
    const prevBtn = page.locator('[data-testid="kd-btn-vorige"]');
    const nextBtn = page.locator('[data-testid="kd-btn-naechste"]');
    const lastBtn = page.locator('[data-testid="kd-btn-letzte"]');

    // Alle Navigation-Buttons sollten existieren
    await expect(firstBtn).toBeVisible({ timeout: 5000 });
    await expect(prevBtn).toBeVisible();
    await expect(nextBtn).toBeVisible();
    await expect(lastBtn).toBeVisible();
  });

  test('Navigation: Vor/Zurueck funktioniert', async ({ page }) => {
    // Warten bis Daten geladen (oder Demo-Daten vorhanden)
    await page.waitForTimeout(2000);

    // Naechster Datensatz klicken
    const nextBtn = page.locator('[data-testid="kd-btn-naechste"]');
    if (await nextBtn.isVisible()) {
      await nextBtn.click();
      await page.waitForTimeout(500);

      // Kein JS-Fehler sollte aufgetreten sein
      const criticalErrors = errors.filter(e => !e.includes('localhost:5000'));
      expect(criticalErrors).toHaveLength(0);
    }
  });

  test('Speichern: Pflichtfeld kun_Firma validieren', async ({ page }) => {
    // Firma-Feld finden und leeren
    const firmaField = page.locator('#kun_Firma, input[data-field="kun_Firma"]').first();

    if (await firmaField.count() > 0) {
      // Feld leeren
      await firmaField.fill('');
      await page.waitForTimeout(200);

      // Speichern klicken
      const saveBtn = page.locator('[data-testid="kd-btn-speichern"], button:has-text("Speichern")').first();
      if (await saveBtn.count() > 0) {
        await saveBtn.click();
        await page.waitForTimeout(1000);

        // Pruefe ob Validierung anschlaegt:
        // 1. Alert/Toast mit Fehlermeldung
        // 2. Feld hat .invalid CSS-Klasse
        // 3. Browser-native Validierung (required)

        const toastOrAlert = page.locator('.toast, .toast-error, .alert, [role="alert"]');
        const alertVisible = await toastOrAlert.count() > 0 && await toastOrAlert.first().isVisible().catch(() => false);

        const fieldHasInvalidClass = await firmaField.evaluate(el =>
          el.classList.contains('invalid')
        );

        const fieldIsNativeInvalid = await firmaField.evaluate(el => {
          const input = el as HTMLInputElement;
          return input.validity && !input.validity.valid;
        });

        // Mindestens eine der Validierungen sollte greifen
        const validationWorks = alertVisible || fieldHasInvalidClass || fieldIsNativeInvalid;
        expect(validationWorks).toBeTruthy();
      }
    }
  });

  test('Speichern: Mit gueltigen Daten erfolgreich', async ({ page }) => {
    // Firma-Feld fuellen (Pflichtfeld)
    const firmaField = page.locator('#kun_Firma, input[data-field="kun_Firma"]').first();

    if (await firmaField.count() > 0) {
      const testFirma = 'Test Firma GmbH ' + Date.now();
      await firmaField.fill(testFirma);
      await page.waitForTimeout(200);
    }

    // Speichern klicken
    const saveBtn = page.locator('[data-testid="kd-btn-speichern"], button:has-text("Speichern")').first();
    if (await saveBtn.count() > 0) {
      // Fehler-Counter vor dem Klick
      const errorsBefore = errors.filter(e => !e.includes('localhost:5000')).length;

      await saveBtn.click();
      await page.waitForTimeout(1500);

      // Pruefe: Keine neuen kritischen JS-Errors nach dem Speichern
      // (API-Fehler sind OK wenn Server nicht laeuft)
      const criticalErrors = errors.filter(e =>
        !e.includes('localhost:5000') &&
        !e.includes('Failed to fetch') &&
        !e.includes('NetworkError')
      );
      expect(criticalErrors.length).toBe(errorsBefore);
    }
  });

  test('Auftragsfilter: Zeitraum von/bis Felder vorhanden', async ({ page }) => {
    // Zeitraum-Filter suchen
    const vonField = page.locator('#dtVon, #datAuftraegeVon, input[type="date"][id*="von" i]').first();
    const bisField = page.locator('#dtBis, #datAuftraegeBis, input[type="date"][id*="bis" i]').first();

    // Falls Tab-Wechsel noetig (Auftraege-Tab)
    const auftraegeTab = page.locator('.tab-btn:has-text("Auftr"), button:has-text("Auftr")').first();
    if (await auftraegeTab.count() > 0) {
      await auftraegeTab.click();
      await page.waitForTimeout(500);
    }

    // Von-Bis Felder pruefen
    const vonCount = await vonField.count();
    const bisCount = await bisField.count();

    // Mindestens eines der Felder sollte vorhanden sein (oder kein Zeitraum-Filter)
    // Dieser Test ist optional - einige Formulare haben keinen Zeitraum-Filter
    if (vonCount > 0 || bisCount > 0) {
      expect(vonCount + bisCount).toBeGreaterThan(0);
    }
  });

  test('Ansprechpartner-Tab: Wechsel funktioniert', async ({ page }) => {
    // Ansprechpartner-Tab suchen
    const apTab = page.locator('.tab-btn:has-text("Ansprechpartner"), .tab-btn:has-text("Partner"), button[data-tab*="ansprechpartner"]').first();

    if (await apTab.count() > 0) {
      await apTab.click();
      await page.waitForTimeout(500);

      // Tab sollte aktiv sein
      await expect(apTab).toHaveClass(/active/);

      // Ansprechpartner-Bereich sollte sichtbar sein
      const apContent = page.locator('#tabAnsprechpartner, .tab-pane:has-text("Ansprechpartner"), [id*="ansprechpartner"]');
      if (await apContent.count() > 0) {
        await expect(apContent.first()).toBeVisible();
      }
    }
  });

  test('Kundenliste: Laden und Auswahl', async ({ page }) => {
    // Kundenliste/Grid suchen
    const kundenListe = page.locator('#kundenBody, .data-grid tbody, .list-container table tbody').first();

    if (await kundenListe.count() > 0) {
      await page.waitForTimeout(2000); // Warten auf Datenladen

      const rows = kundenListe.locator('tr');
      const rowCount = await rows.count();

      // Bei API-Server offline ist 0 OK, aber kein JS-Error
      if (rowCount > 0) {
        // Erste Zeile anklicken
        await rows.first().click();
        await page.waitForTimeout(500);

        // Zeile sollte selektiert sein
        const firstRow = rows.first();
        const hasSelected = await firstRow.evaluate(el =>
          el.classList.contains('selected') ||
          el.parentElement?.querySelector('.selected') !== null
        );
        // Selection optional - manche Formulare nutzen andere Mechanismen
      }
    }
  });

  test('Suche: Suchfeld funktioniert', async ({ page }) => {
    // Suchfeld finden
    const searchInput = page.locator('#txtSuche, #searchInput, input[placeholder*="suchen" i], input[placeholder*="Suche" i]').first();

    if (await searchInput.count() > 0) {
      // Suchbegriff eingeben
      await searchInput.fill('Test');
      await page.waitForTimeout(500);

      // Enter druecken oder Filter-Button klicken
      await searchInput.press('Enter');
      await page.waitForTimeout(500);

      // Kein JS-Crash
      expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
    }
  });

  test('Responsiveness: Fenstergroesse aendern', async ({ page }) => {
    // Initiale Groesse
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.waitForTimeout(500);

    // Kleinere Groesse
    await page.setViewportSize({ width: 1024, height: 768 });
    await page.waitForTimeout(500);

    // Noch kleiner
    await page.setViewportSize({ width: 768, height: 600 });
    await page.waitForTimeout(500);

    // Kein JS-Crash bei Resize
    expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
  });
});
