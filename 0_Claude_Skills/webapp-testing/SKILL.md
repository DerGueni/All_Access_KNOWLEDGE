---
name: WebApp Testing
description: Testet HTML-Formulare mit Playwright. UI-Verifizierung, Button-Tests, Formular-Validierung, Screenshots, Console-Logs prüfen.
when_to_use: Testen, Test, prüfen, verifizieren, funktioniert, Browser-Test, Playwright, Screenshot
version: 1.0.0
auto_trigger: test, testen, prüfen, verifizieren, playwright, screenshot
---

# WebApp Testing für CONSYS

## 🎯 Zweck

Automatisierte Tests für HTML-Formulare mit Playwright:
- UI-Verifizierung (sieht aus wie erwartet?)
- Funktions-Tests (Buttons, Inputs, Navigation)
- Regressions-Tests (funktioniert nach Änderung noch?)
- Screenshot-Vergleiche

---

## 🛠️ Setup

### Playwright bereits installiert
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\.playwright-mcp\
```

### Test-Konfiguration
```
playwright.config.ts
```

---

## 📋 Test-Workflows

### 1. Einfacher Button-Test

```javascript
// tests/button-test.spec.js
const { test, expect } = require('@playwright/test');

test('Button btnSpeichern funktioniert', async ({ page }) => {
  // 1. Formular öffnen
  await page.goto('http://localhost:8080/frm_va_Auftragstamm.html');
  
  // 2. Warten bis geladen
  await page.waitForLoadState('networkidle');
  
  // 3. Button finden und klicken
  const btn = page.locator('#btnSpeichern');
  await expect(btn).toBeVisible();
  await btn.click();
  
  // 4. Erwartetes Ergebnis prüfen
  await expect(page.locator('#lblStatus')).toContainText('Gespeichert');
});
```

### 2. Formular-Eingabe-Test

```javascript
test('Formular kann ausgefüllt werden', async ({ page }) => {
  await page.goto('http://localhost:8080/frm_MA_Mitarbeiterstamm.html');
  
  // Felder ausfüllen
  await page.fill('#txtVorname', 'Max');
  await page.fill('#txtNachname', 'Mustermann');
  await page.selectOption('#cboAbteilung', '3');
  await page.check('#chkAktiv');
  
  // Prüfen ob Werte gesetzt
  await expect(page.locator('#txtVorname')).toHaveValue('Max');
  await expect(page.locator('#txtNachname')).toHaveValue('Mustermann');
});
```

### 3. API-Response-Test

```javascript
test('API liefert Daten', async ({ page }) => {
  // API-Response abfangen
  const responsePromise = page.waitForResponse(
    response => response.url().includes('/api/mitarbeiter') && response.status() === 200
  );
  
  await page.goto('http://localhost:8080/frm_MA_Mitarbeiterstamm.html');
  
  const response = await responsePromise;
  const data = await response.json();
  
  expect(data.length).toBeGreaterThan(0);
});
```

### 4. Screenshot-Test

```javascript
test('Formular sieht korrekt aus', async ({ page }) => {
  await page.goto('http://localhost:8080/frm_va_Auftragstamm.html');
  await page.waitForLoadState('networkidle');
  
  // Screenshot erstellen
  await page.screenshot({ 
    path: 'screenshots/frm_va_Auftragstamm.png',
    fullPage: true 
  });
  
  // Oder spezifisches Element
  await page.locator('.form-header').screenshot({
    path: 'screenshots/header.png'
  });
});
```

### 5. Console-Error-Test

```javascript
test('Keine JavaScript-Fehler', async ({ page }) => {
  const errors = [];
  
  // Console-Errors sammeln
  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text());
    }
  });
  
  await page.goto('http://localhost:8080/frm_va_Auftragstamm.html');
  await page.waitForLoadState('networkidle');
  
  // Alle Buttons klicken
  const buttons = await page.locator('button').all();
  for (const btn of buttons) {
    await btn.click({ force: true }).catch(() => {}); // Fehler ignorieren
  }
  
  // Prüfen ob Errors aufgetreten
  expect(errors).toEqual([]);
});
```

---

## 🔧 Schnell-Befehle

### Test ausführen
```bash
# Einzelner Test
npx playwright test tests/button-test.spec.js

# Alle Tests
npx playwright test

# Mit UI
npx playwright test --ui

# Debug-Modus
npx playwright test --debug
```

### Screenshot machen
```bash
npx playwright screenshot http://localhost:8080/frm_va_Auftragstamm.html screenshot.png
```

### Browser öffnen und interaktiv testen
```bash
npx playwright open http://localhost:8080/frm_va_Auftragstamm.html
```

---

## 📝 Test-Checkliste für Formulare

Bei jedem neuen/geänderten Formular prüfen:

- [ ] Formular lädt ohne Fehler
- [ ] Keine Console-Errors
- [ ] Alle Buttons sind klickbar
- [ ] API-Calls funktionieren
- [ ] Daten werden angezeigt
- [ ] Eingabefelder funktionieren
- [ ] Select-Boxen haben Optionen
- [ ] Navigation funktioniert (Vor/Zurück)
- [ ] Speichern funktioniert
- [ ] Schließen funktioniert

---

## 🚨 Typische Fehler finden

### Button reagiert nicht
```javascript
test('Debug: Button onclick', async ({ page }) => {
  await page.goto('http://localhost:8080/form.html');
  
  const btn = page.locator('#btnProblem');
  
  // Hat Button onclick?
  const onclick = await btn.getAttribute('onclick');
  console.log('onclick:', onclick);
  
  // Ist Button sichtbar?
  const visible = await btn.isVisible();
  console.log('visible:', visible);
  
  // Ist Button disabled?
  const disabled = await btn.isDisabled();
  console.log('disabled:', disabled);
});
```

### API-Fehler finden
```javascript
test('Debug: API Responses', async ({ page }) => {
  page.on('response', response => {
    if (response.url().includes('/api/')) {
      console.log(`${response.status()} ${response.url()}`);
    }
  });
  
  await page.goto('http://localhost:8080/form.html');
  await page.waitForTimeout(3000);
});
```

---

## 📁 Dateipfade

- **Tests:** `tests/*.spec.js`
- **Config:** `playwright.config.ts`
- **Screenshots:** `screenshots/`
- **Reports:** `test-results/`

---

## ✅ Integration mit CONSYS-Workflow

Nach jeder HTML-Änderung:

1. **Server starten** (falls nicht läuft)
   ```bash
   cd 06_Server && python quick_api_server.py
   ```

2. **Test ausführen**
   ```bash
   npx playwright test tests/[formular].spec.js
   ```

3. **Screenshot vergleichen**
   - Vorher/Nachher visuell prüfen

4. **In CLAUDE2.md dokumentieren**
   - Test-Ergebnis eintragen
