import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright Configuration for CONSYS HTML Forms E2E Tests
 *
 * Basis-URL: http://localhost:8081 (forms3 Verzeichnis)
 * Testverzeichnis: tests/e2e/
 */
export default defineConfig({
  testDir: './tests/e2e',

  // Parallele Ausfuehrung pro Datei
  fullyParallel: true,

  // Fehler bei test.only() im CI
  forbidOnly: !!process.env.CI,

  // Retries bei Fehlern (mehr im CI)
  retries: process.env.CI ? 2 : 0,

  // Worker (weniger im CI fuer Stabilitaet)
  workers: process.env.CI ? 1 : undefined,

  // Reporter
  reporter: [
    ['html', { open: 'never', outputFolder: 'playwright-report' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['list']
  ],

  // Globale Einstellungen
  use: {
    // Basis-URL fuer shell.html
    baseURL: 'http://localhost:8081',

    // Headless-Modus
    headless: true,

    // Screenshots bei Fehler
    screenshot: 'only-on-failure',

    // Trace bei Retry
    trace: 'on-first-retry',

    // Video bei Fehler
    video: 'retain-on-failure',

    // Timeout pro Aktion
    actionTimeout: 10000,

    // Timeout fuer Navigation
    navigationTimeout: 30000,
  },

  // Projekte (Browser-Konfigurationen)
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Optional: Firefox und WebKit
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    // },
  ],

  // Web Server starten (optional - falls kein externer Server laeuft)
  // webServer: {
  //   command: 'npx http-server ./04_HTML_Forms/forms3 -p 8081 -c-1',
  //   url: 'http://localhost:8081',
  //   reuseExistingServer: !process.env.CI,
  //   timeout: 120 * 1000,
  // },

  // Output-Verzeichnis
  outputDir: 'test-results/',

  // Globaler Timeout pro Test
  timeout: 60000,

  // Expect-Timeout
  expect: {
    timeout: 5000,
  },
});
