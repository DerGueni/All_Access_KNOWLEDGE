# Sidebar Design Varianten

## Verfügbare Varianten

### Variante 5: Material Design 3
**Datei:** `sidebar_variant_05_material.css`

**Features:**
- Google Material Design 3 Richtlinien
- Ripple-Effekt bei Klick (CSS + optionales JS)
- Elevation Shadows mit 3 Stufen
- Rounded Corners (28px für active state, 16px für Kategorien)
- Surface Tones für Tiefenwirkung
- Touch-freundlich: 48-56px Button-Höhe
- Dark Mode Support
- Smooth Hover-Transitions

**Einbinden in shell.html:**
```html
<link rel="stylesheet" href="css/sidebar_variants/sidebar_variant_05_material.css">
```

---

### Variante 6: Accordion Sections
**Datei:** `sidebar_variant_06_accordion.css`

**Features:**
- Klappbare Kategorien (Personal, Aufträge, Planung, etc.)
- Chevron-Icon zeigt Status (auf/zu)
- Nur aktive Kategorie expanded
- Smooth expand/collapse Animation (300ms)
- Auto-expand für Kategorie mit aktivem Button
- Touch-freundlich: 48-52px Button-Höhe
- Optional: Emoji-Icons vor Buttons
- Dark Mode Support

**Einbinden in shell.html:**
```html
<link rel="stylesheet" href="css/sidebar_variants/sidebar_variant_06_accordion.css">
```

**WICHTIG:** JavaScript erforderlich für volle Funktionalität!

Füge in shell.html vor `</body>` ein:
```javascript
// Accordion Functionality
document.addEventListener('DOMContentLoaded', function() {
    const categoryHeaders = document.querySelectorAll('.category-header');

    categoryHeaders.forEach(header => {
        header.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();

            const block = this.closest('.category-block');
            const isExpanded = block.classList.contains('expanded');

            // Single Expansion: Alle anderen schließen
            document.querySelectorAll('.category-block.expanded').forEach(b => {
                if (b !== block) {
                    b.classList.remove('expanded');
                }
            });

            // Toggle current
            block.classList.toggle('expanded', !isExpanded);
        });
    });

    // Auto-expand category with active button
    const activeBtn = document.querySelector('.menu-btn.active');
    if (activeBtn) {
        const block = activeBtn.closest('.category-block');
        if (block) {
            block.classList.add('expanded');
        }
    }

    // Expand first category by default if none has active
    if (!document.querySelector('.category-block.expanded')) {
        const firstBlock = document.querySelector('.category-block');
        if (firstBlock) {
            firstBlock.classList.add('expanded');
        }
    }
});
```

---

## Testen

### Schnelltest (ohne shell.html zu ändern):

1. Öffne Browser DevTools (F12)
2. Console Tab
3. Füge ein:

**Material Design testen:**
```javascript
const link = document.createElement('link');
link.rel = 'stylesheet';
link.href = 'css/sidebar_variants/sidebar_variant_05_material.css';
document.head.appendChild(link);
```

**Accordion testen:**
```javascript
const link = document.createElement('link');
link.rel = 'stylesheet';
link.href = 'css/sidebar_variants/sidebar_variant_06_accordion.css';
document.head.appendChild(link);
// Accordion JS
document.querySelectorAll('.category-header').forEach(h => h.addEventListener('click', e => { e.preventDefault(); const b = h.closest('.category-block'); document.querySelectorAll('.category-block.expanded').forEach(x => x !== b && x.classList.remove('expanded')); b.classList.toggle('expanded'); }));
document.querySelector('.category-block')?.classList.add('expanded');
```

---

## Anpassungen

### Farben ändern
Beide Varianten nutzen CSS Custom Properties. Überschreibe in eigenem CSS:

```css
:root {
    /* Material */
    --md-primary: #your-color;

    /* Accordion */
    --acc-primary: #your-color;
}
```

### Button-Höhe anpassen
```css
.menu-btn {
    min-height: 56px !important; /* Größer für Touch */
}
```
