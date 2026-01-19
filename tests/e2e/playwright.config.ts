import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright E2E Test Configuration for CONSYS HTML Forms
 * @see https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: './',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: '../../reports/playwright' }],
    ['list']
  ],
  use: {
    // Base URL for forms3 directory (served locally)
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  // Webserver to serve forms3 directory
  webServer: {
    command: 'npx http-server ../04_HTML_Forms/forms3 -p 8080 -c-1 --cors',
    url: 'http://localhost:8080',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
