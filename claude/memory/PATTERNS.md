# Patterns für Webform-Entwicklung

## Etappe A: UI-Scaffold (frm_MA_Mitarbeiterstamm) ✓

### Pattern 1: Master-Detail Layout
- **Toolbar** (50px) → Navigation + Buttons
- **Main Container** (flex 1) → Sidebar (280px) + Content
- **List Section** (200px) → Employee Table mit Row-Selection

### Pattern 2: TabControl Simulation
```html
<div class="tab-control">
  <div class="tab-header">
    <button data-tab="pgAdresse">Tab1</button>
  </div>
  <div id="pgAdresse" class="tab-page tab-active">...</div>
</div>
```
CSS: `.tab-page.tab-active { display: block; }`

### Pattern 3: Field Mapping (ControlName → DOM)
```javascript
const fieldMap = {
  'Nachname': dom.Nachname,
  'Vorname': dom.Vorname,
  // ...
};
```
Nutze für: `populateFormFields(record)`, `gatherFormData()`

### Pattern 4: Bridge Events
- `Bridge.on('loadForm', fn)` – Event-Listener registrieren
- `Bridge.callAccess('Method', {args})` – Methode an Access senden
- Event-Namen in camelCase

### Pattern 5: State Management
```javascript
const state = {
  currentRecord: null,
  recordList: [],
  isDirty: false,
  currentTab: 'pgAdresse',
  filters: { anstellungsart_id: [3, 5] }
};
```

### Pattern 6: List Row Selection
- Klick auf Zeile → `.selected` Klasse hinzufügen
- `state.currentRecord` aktualisieren
- `populateFormFields()` aufrufen

### Pattern 7: Navigation Buttons
- `first/prev/next/last` als Arrays navigieren
- Bounds-Check: `Math.min()` / `Math.max()`

### Pattern 8: Checkbox vs. TextBox Handling
```javascript
if (element.type === 'checkbox') {
  element.checked = !!value;
} else {
  element.value = value || '';
}
```

### Pattern 9: Error Toast-Message
```javascript
function showErrorMessage(message) {
  const div = document.createElement('div');
  div.style.cssText = '...';
  setTimeout(() => div.remove(), 5000);
}
```

### Pattern 10: Responsive Fields
- `.field-row` mit `flex-wrap: wrap`
- `.field-group` mit `min-width: 150px`
- `@media (max-width: 768px)` → `flex-direction: column`

### Pattern 11: Image Control (Foto)
```html
<div class="image-control">
  <img src="" alt="Foto" />
</div>
```
CSS: `object-fit: cover` + `max-width/height: 100%`

---

## Nächste Etappen

### Etappe B: Binding & Events
- [ ] Bridge-Integration testen
- [ ] LoadForm-Event implementieren
- [ ] Field Change Events
- [ ] Save/Delete Logic

### Etappe C: SubForms & Validierung
- [ ] frm_Menuefuehrung integrieren
- [ ] sub_MA_ErsatzEmail integrieren
- [ ] Formularvalidierung
- [ ] PostMessage für Subforms

### Etappe D: Polish & Tests
- [ ] Foto-Upload
- [ ] Performance optimieren
- [ ] Smoke-Tests (Playwright)
- [ ] Production Build
