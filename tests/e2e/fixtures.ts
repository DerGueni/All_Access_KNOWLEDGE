import { test as base, expect } from '@playwright/test';

/**
 * Gemeinsame Test-Fixtures fuer CONSYS E2E Tests
 */

// Erweiterte Test-Fixture mit Shell-Helpers
export const test = base.extend<{
  shellPage: ShellPage;
}>({
  shellPage: async ({ page }, use) => {
    const shellPage = new ShellPage(page);
    await use(shellPage);
  },
});

/**
 * Shell-Page Wrapper mit Hilfsfunktionen
 */
class ShellPage {
  constructor(private page: any) {}

  /**
   * Navigiert zu einem Formular via Shell
   */
  async navigateToForm(formName: string, recordId?: string | number) {
    let url = `/shell.html?form=${formName}`;
    if (recordId) {
      url += `&id=${recordId}`;
    }
    await this.page.goto(url);
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Gibt den iframe-Locator zurueck
   */
  get iframe() {
    return this.page.frameLocator('#contentFrame');
  }

  /**
   * Wartet bis das Formular im iframe geladen ist
   */
  async waitForFormLoad(timeout = 10000) {
    await expect(this.iframe.locator('#ID')).toBeVisible({ timeout });
  }

  /**
   * Klickt auf einen Button im Shell-Menu
   */
  async clickMenuButton(formName: string) {
    await this.page.locator(`[data-form="${formName}"]`).click();
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Prueft ob ein bestimmter Menu-Button aktiv ist
   */
  async isMenuActive(formName: string): Promise<boolean> {
    const classes = await this.page.locator(`[data-form="${formName}"]`).getAttribute('class');
    return classes?.includes('active') ?? false;
  }

  /**
   * Gibt den Content-Header Text zurueck
   */
  async getContentHeader(): Promise<string> {
    return await this.page.locator('#contentHeader').textContent();
  }
}

/**
 * API Mock-Helper
 */
export const ApiMock = {
  /**
   * Mockt GET-Anfragen fuer ein bestimmtes Pattern
   */
  async mockGet(page: any, urlPattern: string, response: any) {
    await page.route(urlPattern, (route: any) => {
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify(response),
      });
    });
  },

  /**
   * Mockt POST-Anfragen
   */
  async mockPost(page: any, urlPattern: string, response: any) {
    await page.route(urlPattern, (route: any, request: any) => {
      if (request.method() === 'POST') {
        route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify(response),
        });
      } else {
        route.continue();
      }
    });
  },
};

/**
 * Testdaten-Generatoren
 */
export const TestData = {
  /**
   * Generiert einen zufaelligen Mitarbeiter
   */
  mitarbeiter(overrides = {}) {
    return {
      ID: Math.floor(Math.random() * 10000),
      Nachname: 'Test-' + Math.random().toString(36).substring(7),
      Vorname: 'Vorname-' + Math.random().toString(36).substring(7),
      IstAktiv: true,
      Strasse: 'Teststrasse',
      Nr: '1',
      PLZ: '90000',
      Ort: 'Nuernberg',
      Tel_Mobil: '0151-12345678',
      Email: 'test@example.com',
      ...overrides,
    };
  },

  /**
   * Generiert einen zufaelligen Auftrag
   */
  auftrag(overrides = {}) {
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    return {
      ID: Math.floor(Math.random() * 10000),
      Auftrag: 'Test-Auftrag-' + Math.random().toString(36).substring(7),
      Dat_VA_Von: today.toISOString().split('T')[0],
      Dat_VA_Bis: tomorrow.toISOString().split('T')[0],
      Ort: 'Nuernberg',
      Veranst_Status_ID: 1,
      ...overrides,
    };
  },
};

// Re-export expect
export { expect };
