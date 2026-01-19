# Auto-Save Integration Guide

**Für:** Entwickler
**Datum:** 2026-01-15

---

## 🎯 Ziel

Dieses Dokument erklärt wie Auto-Save in bestehende HTML-Formulare integriert wird.

---

## 📋 Schnellstart

### 1. CSS einbinden

In `<head>` des Formulars:
```html
<link rel="stylesheet" href="../css/auto-save.css">
```

### 2. JavaScript importieren

Am Anfang der `.logic.js` Datei:
```javascript
import {
    initAutoSaveAuftragstamm,  // oder andere Init-Funktion
    injectAutoSaveStatus
} from '../js/auto-save-integration.js';
```

### 3. Status-Element im HTML

Option A: Automatisch einfügen (empfohlen):
```javascript
// In init() Funktion:
injectAutoSaveStatus();
```

Option B: Manuell im HTML einfügen:
```html
<div class="form-footer">
    <span id="saveStatus" class="save-status"></span>
</div>
```

### 4. Initialisieren

In der `init()` Funktion:
```javascript
async function init() {
    // ... bestehender Code ...

    // Auto-Save aktivieren
    injectAutoSaveStatus();
    const autoSave = initAutoSaveAuftragstamm(state);
    state.autoSave = autoSave;

    console.log('[Formular] Auto-Save aktiviert');
}
```

---

## 📝 Beispiele für verschiedene Formulare

### Auftragstamm

```javascript
import { initAutoSaveAuftragstamm, injectAutoSaveStatus } from '../js/auto-save-integration.js';

async function init() {
    // Bestehender Init-Code...
    initTabs();
    initButtons();
    bindFieldEvents();

    // Auto-Save aktivieren
    injectAutoSaveStatus();
    state.autoSave = initAutoSaveAuftragstamm(state);

    // Daten laden
    await loadInitialData();
}
```

### Mitarbeiterstamm

```javascript
import { initAutoSaveMitarbeiterstamm, injectAutoSaveStatus } from '../js/auto-save-integration.js';

async function init() {
    // Bestehender Code...

    // Auto-Save aktivieren
    injectAutoSaveStatus();
    state.autoSave = initAutoSaveMitarbeiterstamm(state);

    await loadMitarbeiterListe();
}
```

### Kundenstamm

```javascript
import { initAutoSaveKundenstamm, injectAutoSaveStatus } from '../js/auto-save-integration.js';

async function init() {
    // Bestehender Code...

    // Auto-Save aktivieren
    injectAutoSaveStatus();
    state.autoSave = initAutoSaveKundenstamm(state);

    await loadList();
}
```

### Objektverwaltung

```javascript
import { initAutoSaveObjekt, injectAutoSaveStatus } from '../js/auto-save-integration.js';

async function init() {
    // Bestehender Code...

    // Auto-Save aktivieren
    injectAutoSaveStatus();
    state.autoSave = initAutoSaveObjekt(state);

    await loadObjektListe();
}
```

---

## 🔧 Custom Auto-Save für neues Formular

Falls das Formular NICHT in `auto-save-integration.js` vorkonfiguriert ist:

```javascript
import { AutoSaveManager } from '../js/auto-save.js';
import { Bridge } from '../api/bridgeClient.js';

async function init() {
    // Bestehender Code...

    // Custom Auto-Save
    const autoSave = new AutoSaveManager({
        debounceMs: 500,
        statusElementId: 'saveStatus',
        trackFields: [
            'Feld1',
            'Feld2',
            'Feld3'
            // ... alle zu trackenden Felder
        ],
        onSave: async (data) => {
            // Custom Speicher-Logik
            const currentId = state.currentRecord?.ID;
            if (!currentId) return null;

            const payload = {
                ID: currentId,
                Feld1: data.Feld1,
                Feld2: data.Feld2,
                Feld3: data.Feld3
            };

            console.log('[Custom] Speichere:', payload);

            // API-Call
            const result = await Bridge.execute('updateEntity', payload);
            return result.data;
        },
        onConflict: (local, remote) => {
            // Conflict-Resolution
            return local;  // Lokale Änderungen haben Vorrang
        },
        showToast: true,
        debug: false
    });

    state.autoSave = autoSave;
}
```

---

## 🎨 Status-Anzeige Anpassen

### Position ändern

Default: Rechts im Footer
```css
.save-status {
    margin-left: auto;  /* Rechts */
}
```

Links im Footer:
```css
.save-status {
    margin-right: auto;  /* Links */
}
```

### Farben anpassen

In `auto-save.css`:
```css
.save-status.saved {
    background-color: #d4edda;  /* Grüner Hintergrund */
    color: #155724;             /* Dunkelgrüner Text */
}
```

### Icons ändern

In `auto-save.js`, Methode `setStatus()`:
```javascript
const statusMap = {
    saved: { icon: '✓', text: 'Gespeichert', className: 'saved' },
    saving: { icon: '⏳', text: 'Wird gespeichert...', className: 'saving' }
};
```

---

## ⚙️ Konfiguration

### Debounce-Zeit ändern

```javascript
const autoSave = new AutoSaveManager({
    debounceMs: 1000,  // 1 Sekunde statt 500ms
    // ...
});
```

### Toast-Notifications deaktivieren

```javascript
const autoSave = new AutoSaveManager({
    showToast: false,
    // ...
});
```

### Debug-Modus aktivieren

```javascript
const autoSave = new AutoSaveManager({
    debug: true,  // Console-Logs aktivieren
    // ...
});
```

### Auto-Detection deaktivieren

```javascript
const autoSave = new AutoSaveManager({
    autoTrack: false,  // Nur trackFields verwenden
    trackFields: ['Feld1', 'Feld2'],
    // ...
});
```

---

## 🐛 Troubleshooting

### Problem: Status-Element erscheint nicht

**Lösung 1:** Manuell im HTML einfügen
```html
<div class="form-footer">
    <span id="saveStatus"></span>
</div>
```

**Lösung 2:** CSS prüfen
```css
.save-status {
    display: inline-flex !important;
}
```

### Problem: Änderungen werden nicht getrackt

**Prüfen:**
1. Haben die Felder eine `id`?
2. Ist `autoTrack: true` gesetzt?
3. Sind die Felder in `trackFields` aufgeführt?

**Debug:**
```javascript
const autoSave = new AutoSaveManager({
    debug: true,  // Console-Logs aktivieren
    // ...
});
```

### Problem: Speichern schlägt fehl

**Prüfen:**
1. Console öffnen → Fehler-Meldung lesen
2. Ist `onSave` richtig implementiert?
3. Ist API-Server erreichbar?
4. Ist Backend-Endpoint korrekt?

**Test:**
```javascript
onSave: async (data) => {
    console.log('[Test] Speichere:', data);
    return data;  // Mock-Speichern
}
```

### Problem: Conflict-Dialog erscheint ständig

**Lösung:**
```javascript
onConflict: (local, remote) => {
    // Einfach lokale Änderungen übernehmen
    return local;
}
```

---

## 📊 Performance-Tipps

### 1. Nur relevante Felder tracken

```javascript
trackFields: [
    'Name',      // Wichtig
    'Email',     // Wichtig
    // 'ID',     // NICHT tracken (read-only)
    // 'Timestamp' // NICHT tracken (auto-generated)
]
```

### 2. Debounce-Zeit anpassen

Viele kleine Änderungen → höhere Debounce-Zeit:
```javascript
debounceMs: 1000  // 1 Sekunde
```

Selten Änderungen → niedrigere Debounce-Zeit:
```javascript
debounceMs: 300  // 300ms
```

### 3. Conflict-Detection nur wenn nötig

```javascript
const autoSave = new AutoSaveManager({
    onConflict: null,  // Conflict-Detection deaktivieren
    // ...
});
```

---

## 🧪 Testing

### Manueller Test

1. Formular öffnen
2. DevTools Console öffnen
3. Debug-Modus aktivieren:
   ```javascript
   state.autoSave.options.debug = true;
   ```
4. Feld ändern → Console-Logs prüfen
5. Status-Anzeige beobachten

### Automatisierter Test (Playwright)

```javascript
test('Auto-Save speichert Änderungen', async ({ page }) => {
    await page.goto('frm_va_Auftragstamm.html?id=123');

    // Warte auf Load
    await page.waitForSelector('#Auftrag');

    // Feld ändern
    await page.fill('#Auftrag', 'Test-Auftrag');

    // Warte auf "Wird gespeichert..."
    await page.waitForSelector('.save-status.saving');

    // Warte auf "Gespeichert"
    await page.waitForSelector('.save-status.saved', { timeout: 2000 });

    // Prüfe dass API-Call erfolgte
    const requests = page.context().requests();
    expect(requests.some(r => r.url().includes('/api/auftraege'))).toBe(true);
});
```

---

## ✅ Checkliste für Integration

- [ ] CSS eingebunden (`auto-save.css`)
- [ ] JavaScript importiert (`auto-save-integration.js`)
- [ ] Status-Element im HTML oder via `injectAutoSaveStatus()`
- [ ] Init-Funktion aufgerufen in `init()`
- [ ] Auto-Save in `state.autoSave` gespeichert
- [ ] Manueller Test durchgeführt
- [ ] Console-Logs überprüft (Debug-Modus)
- [ ] Status-Anzeige funktioniert
- [ ] Speichern funktioniert (Backend-Check)
- [ ] Dokumentation aktualisiert

---

## 📚 Weiterführende Links

- [auto-save.js Source](../js/auto-save.js)
- [auto-save-integration.js Source](../js/auto-save-integration.js)
- [auto-save.css Source](../css/auto-save.css)
- [DATA_SYNC_IMPLEMENTATION_REPORT.md](../../DATA_SYNC_IMPLEMENTATION_REPORT.md)

---

**Fragen?** → Claude fragen oder Dokumentation lesen
