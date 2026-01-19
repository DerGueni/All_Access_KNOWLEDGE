# Auto-Save Quick Reference

**1-Minuten-Überblick für schnelle Integration**

---

## ⚡ Schnellstart

### HTML (1 Zeile)
```html
<link rel="stylesheet" href="../css/auto-save.css">
```

### JavaScript (3 Zeilen)
```javascript
import { initAutoSaveAuftragstamm, injectAutoSaveStatus } from '../js/auto-save-integration.js';

injectAutoSaveStatus();
state.autoSave = initAutoSaveAuftragstamm(state);
```

**Fertig!** Änderungen werden automatisch gespeichert.

---

## 🎯 Verfügbare Init-Funktionen

| Formular | Funktion |
|----------|----------|
| Auftragstamm | `initAutoSaveAuftragstamm(state)` |
| Mitarbeiterstamm | `initAutoSaveMitarbeiterstamm(state)` |
| Kundenstamm | `initAutoSaveKundenstamm(state)` |
| Objektverwaltung | `initAutoSaveObjekt(state)` |

---

## 🔧 Custom Integration

```javascript
import { AutoSaveManager } from '../js/auto-save.js';

new AutoSaveManager({
    trackFields: ['field1', 'field2'],
    onSave: async (data) => Bridge.execute('save', data)
});
```

---

## ⚙️ Optionen

| Option | Default | Beschreibung |
|--------|---------|--------------|
| `debounceMs` | 500 | Wartezeit vor Speichern (ms) |
| `showToast` | true | Toast-Notifications |
| `debug` | false | Console-Logs |
| `autoTrack` | true | Auto-Detect Felder |

---

## 📊 Status-Anzeige

| Icon | Status | Bedeutung |
|------|--------|-----------|
| ● | Unsaved | Nicht gespeichert |
| ⏳ | Saving | Wird gespeichert... |
| ✓ | Saved | Gespeichert |
| ✗ | Error | Fehler |
| ⚠ | Conflict | Konflikt |

---

## 🐛 Troubleshooting

### Status-Element fehlt?
```javascript
injectAutoSaveStatus();
```

### Felder werden nicht getrackt?
```javascript
trackFields: ['Feld1', 'Feld2']  // Manuell angeben
```

### Debug-Logs aktivieren?
```javascript
state.autoSave.options.debug = true;
```

---

## 📚 Weitere Infos

- **Vollständige Doku:** `_docs/AUTO_SAVE_INTEGRATION_GUIDE.md`
- **Demo:** `_test/auto-save-demo.html`
- **README:** `AUTO_SAVE_README.md`
