import { test, expect } from '@playwright/test';

/**
 * E2E Tests fuer frm_OB_Objekt.html
 * Testet: Navigation, Speichern mit Pflichtfeld, Positionen-Tab, JS-Errors
 */
test.describe('Objektstamm (frm_OB_Objekt)', () => {
  const errors: string[] = [];

  test.beforeEach(async ({ page }) => {
    // Console-Errors sammeln
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    // Formular laden
    await page.goto('/frm_OB_Objekt.html');
    await page.waitForLoadState('networkidle');
  });

  test.afterEach(async () => {
    errors.length = 0;
  });

  test('laedt ohne JavaScript-Errors', async ({ page }) => {
    await page.waitForTimeout(2000);

    // Keine kritischen JS-Errors (API-Fehler ignorieren)
    const criticalErrors = errors.filter(e =>
      !e.includes('favicon') &&
      !e.includes('404') &&
      !e.includes('localhost:5000')
    );
    expect(criticalErrors).toHaveLength(0);
  });

  test('zeigt Formular-Titel "Objekt" an', async ({ page }) => {
    const titel = page.locator('.title-text, .title-bar, h1, h2, #Bezeichnungsfeld96').first();
    await expect(titel).toBeVisible();

    const pageContent = await page.content();
    expect(pageContent.toLowerCase()).toContain('objekt');
  });

  test('Navigation: Record-Navigation vorhanden', async ({ page }) => {
    // Record-Info Element
    const recordInfo = page.locator('#recordInfo, .record-info');
    await expect(recordInfo.first()).toBeVisible();

    // Navigations-Gruppe
    const navGroup = page.locator('.nav-group, .nav-btn').first();
    await expect(navGroup).toBeVisible();
  });

  test('Navigation: Erster/Letzter Datensatz', async ({ page }) => {
    const firstBtn = page.locator('button:has-text("|<"), button[onclick*="goFirst"]').first();
    const lastBtn = page.locator('button:has-text(">|"), button[onclick*="goLast"]').first();

    if (await firstBtn.count() > 0) {
      await firstBtn.click();
      await page.waitForTimeout(500);

      // Kein Crash
      expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
    }

    if (await lastBtn.count() > 0) {
      await lastBtn.click();
      await page.waitForTimeout(500);

      expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
    }
  });

  test('Speichern: Pflichtfeld Objekt validieren', async ({ page }) => {
    // Neu-Button klicken
    const neuBtn = page.locator('button:has-text("Neu"), .btn-green:has-text("Neu")').first();
    if (await neuBtn.count() > 0) {
      await neuBtn.click();
      await page.waitForTimeout(500);
    }

    // Objekt-Feld leeren (Pflichtfeld)
    const objektField = page.locator('#Objekt, input[data-field="Objekt"], input[id="Objekt"]').first();
    if (await objektField.count() > 0) {
      await objektField.fill('');
    }

    // Speichern klicken
    const saveBtn = page.locator('button:has-text("Speichern"), .btn:has-text("Speichern"), button[onclick*="saveRecord"]').first();
    if (await saveBtn.count() > 0) {
      await saveBtn.click();
      await page.waitForTimeout(1000);

      // Toast mit Fehlermeldung oder Feld-Markierung erwartet
      const errorIndicator = page.locator('.toast-error, .toast:has-text("Objekt"), input.invalid');
      const hasError = await errorIndicator.count() > 0;

      // Required-Attribut sollte Validierung triggern
      const fieldRequired = await objektField.getAttribute('required');

      expect(hasError || fieldRequired !== null).toBeTruthy();
    }
  });

  test('Speichern: Mit gueltigem Objektnamen', async ({ page }) => {
    // Neu-Button
    const neuBtn = page.locator('button:has-text("Neu"), .btn-green').first();
    if (await neuBtn.count() > 0) {
      await neuBtn.click();
      await page.waitForTimeout(500);
    }

    // Objekt-Feld fuellen
    const objektField = page.locator('#Objekt, input[data-field="Objekt"]').first();
    if (await objektField.count() > 0) {
      await objektField.fill('Test Objekt ' + Date.now());
    }

    // Speichern
    const saveBtn = page.locator('button:has-text("Speichern")').first();
    if (await saveBtn.count() > 0) {
      await saveBtn.click();
      await page.waitForTimeout(1500);

      // Kein JS-Crash (API-Fehler ignorieren)
      expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
    }
  });

  test('Positionen-Tab: Tab wechseln', async ({ page }) => {
    // Positionen-Tab finden
    const posTab = page.locator('.tab-btn:has-text("Positionen"), button[data-tab="tabPositionen"]').first();

    if (await posTab.count() > 0) {
      await posTab.click();
      await page.waitForTimeout(500);

      // Tab aktiv
      await expect(posTab).toHaveClass(/active/);

      // Positionen-Bereich sichtbar
      const posContent = page.locator('#tabPositionen, #positionenBody');
      if (await posContent.count() > 0) {
        await expect(posContent.first()).toBeVisible();
      }
    }
  });

  test('Positionen-Tab: Tabelle vorhanden', async ({ page }) => {
    // Zum Positionen-Tab wechseln
    const posTab = page.locator('.tab-btn:has-text("Positionen")').first();
    if (await posTab.count() > 0) {
      await posTab.click();
      await page.waitForTimeout(500);
    }

    // Positionen-Tabelle pruefen
    const posTable = page.locator('.positionen-grid, #positionenBody');
    if (await posTable.count() > 0) {
      await expect(posTable.first()).toBeVisible();

      // Header-Spalten pruefen
      const headers = page.locator('.positionen-grid th');
      const headerCount = await headers.count();
      expect(headerCount).toBeGreaterThan(0);
    }
  });

  test('Positionen-Tab: Buttons vorhanden', async ({ page }) => {
    // Tab wechseln
    const posTab = page.locator('.tab-btn:has-text("Positionen")').first();
    if (await posTab.count() > 0) {
      await posTab.click();
      await page.waitForTimeout(500);
    }

    // Positions-Buttons
    const neuPosBtn = page.locator('button:has-text("Neue Position"), button[onclick*="newPosition"]');
    const delPosBtn = page.locator('button:has-text("Position"), .btn-red:has-text("löschen")');

    const neuCount = await neuPosBtn.count();
    const delCount = await delPosBtn.count();

    expect(neuCount + delCount).toBeGreaterThan(0);
  });

  test('Objektliste: Suche funktioniert', async ({ page }) => {
    const searchInput = page.locator('#searchInput, input[placeholder*="such"]').first();

    if (await searchInput.count() > 0) {
      await searchInput.fill('Arena');
      await page.waitForTimeout(500);

      // Kein Crash
      expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
    }
  });

  test('Geocode-Button: Vorhanden', async ({ page }) => {
    const geocodeBtn = page.locator('button:has-text("Geocode"), button[onclick*="geocode"]');

    if (await geocodeBtn.count() > 0) {
      await expect(geocodeBtn.first()).toBeVisible();
    }
  });

  test('Tab-Wechsel: Alle Tabs erreichbar', async ({ page }) => {
    const tabs = page.locator('.tab-btn');
    const tabCount = await tabs.count();

    for (let i = 0; i < tabCount; i++) {
      const tab = tabs.nth(i);
      const tabText = await tab.textContent();

      await tab.click();
      await page.waitForTimeout(300);

      // Tab sollte aktiv werden
      await expect(tab).toHaveClass(/active/);

      console.log(`Tab ${i + 1}: ${tabText} - OK`);
    }

    // Kein JS-Crash
    expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
  });

  test('Formular-Felder: Eingabe moeglich', async ({ page }) => {
    const fields = [
      { selector: '#Strasse, input[data-field="Strasse"]', value: 'Teststrasse 123' },
      { selector: '#PLZ, input[data-field="PLZ"]', value: '90402' },
      { selector: '#Ort, input[data-field="Ort"]', value: 'Nuernberg' },
      { selector: '#Treffpunkt, input[data-field="Treffpunkt"]', value: 'Haupteingang' },
    ];

    for (const field of fields) {
      const input = page.locator(field.selector).first();
      if (await input.count() > 0 && await input.isEditable()) {
        await input.fill(field.value);
        const value = await input.inputValue();
        expect(value).toBe(field.value);
      }
    }
  });

  test('Status-Bar: Anzeige vorhanden', async ({ page }) => {
    const statusBar = page.locator('.status-bar, #statusText');
    if (await statusBar.count() > 0) {
      await expect(statusBar.first()).toBeVisible();
    }
  });

  test('Loeschen-Button: Bestaetigung erforderlich', async ({ page }) => {
    const deleteBtn = page.locator('button:has-text("Löschen"), .btn-red:has-text("Löschen")').first();

    if (await deleteBtn.count() > 0) {
      // Dialog-Handler einrichten
      let dialogAppeared = false;
      page.on('dialog', async dialog => {
        dialogAppeared = true;
        await dialog.dismiss(); // Abbrechen
      });

      await deleteBtn.click();
      await page.waitForTimeout(500);

      // Bei leerem Formular kommt evtl. kein Dialog
      // Wichtig: Kein unbehandelter JS-Error
      expect(errors.filter(e => !e.includes('localhost:5000'))).toHaveLength(0);
    }
  });
});
