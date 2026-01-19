---
name: CSS Design Tokens
description: Zentrale CSS-Variablen und Design-Tokens für konsistente Styles im gesamten CONSYS-Projekt. Farben, Schriften, Abstände, Schatten.
when_to_use: CSS-Variable, Farbe ändern, Theme, konsistent, Design-System, Token
version: 1.0.0
auto_trigger: token, variable, css var, theme, farbe color
---

# CSS Design Tokens für CONSYS

## 🎯 Zweck

Design Tokens sind **zentrale CSS-Variablen**, die im gesamten Projekt wiederverwendet werden. Änderungen an einem Token wirken sich automatisch auf alle Stellen aus, die ihn verwenden.

---

## 📁 Token-Datei

**Pfad:** `04_HTML_Forms/forms3/css/variables.css`

> ℹ️ Diese Datei existiert bereits und enthält alle CONSYS Design-Tokens!

```css
:root {
  /* ========================================
     CONSYS DESIGN TOKENS
     ======================================== */

  /* --- FARBEN: Primär --- */
  --color-primary: #0066CC;
  --color-primary-hover: #0077DD;
  --color-primary-active: #004499;
  --color-primary-light: #E8F4FF;
  
  /* --- FARBEN: Sekundär --- */
  --color-secondary: #6C757D;
  --color-secondary-hover: #5A6268;
  
  /* --- FARBEN: Hintergrund --- */
  --color-bg-page: #F0F0F0;
  --color-bg-form: #F5F5F5;
  --color-bg-header: #E0E0E0;
  --color-bg-input: #FFFFFF;
  --color-bg-disabled: #E8E8E8;
  --color-bg-selected: #0066CC;
  --color-bg-hover: #E8F4FF;
  --color-bg-alternating: #F8F8F8;
  
  /* --- FARBEN: Text --- */
  --color-text-primary: #000000;
  --color-text-secondary: #333333;
  --color-text-muted: #666666;
  --color-text-disabled: #999999;
  --color-text-inverse: #FFFFFF;
  --color-text-link: #0066CC;
  
  /* --- FARBEN: Rahmen --- */
  --color-border-input: #7F9DB9;
  --color-border-section: #808080;
  --color-border-light: #C0C0C0;
  --color-border-focus: #0066CC;
  
  /* --- FARBEN: Status --- */
  --color-success: #28A745;
  --color-success-bg: #D4EDDA;
  --color-warning: #FFC107;
  --color-warning-bg: #FFF3CD;
  --color-error: #DC3545;
  --color-error-bg: #F8D7DA;
  --color-info: #17A2B8;
  --color-info-bg: #D1ECF1;

  /* ========================================
     TYPOGRAFIE
     ======================================== */
  
  /* --- Schriftfamilien --- */
  --font-family-primary: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  --font-family-mono: 'Consolas', 'Courier New', monospace;
  
  /* --- Schriftgrößen --- */
  --font-size-xs: 9px;
  --font-size-sm: 10px;
  --font-size-base: 11px;
  --font-size-md: 12px;
  --font-size-lg: 14px;
  --font-size-xl: 15px;
  --font-size-xxl: 18px;
  
  /* --- Schriftgewichte --- */
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-bold: 700;
  
  /* --- Zeilenhöhen --- */
  --line-height-tight: 1.2;
  --line-height-normal: 1.4;
  --line-height-relaxed: 1.6;

  /* ========================================
     ABSTÄNDE (4px Grid)
     ======================================== */
  
  --spacing-0: 0;
  --spacing-1: 4px;
  --spacing-2: 8px;
  --spacing-3: 12px;
  --spacing-4: 16px;
  --spacing-5: 20px;
  --spacing-6: 24px;
  --spacing-8: 32px;
  --spacing-10: 40px;

  /* ========================================
     GRÖSZEN
     ======================================== */
  
  /* --- Input-Höhen --- */
  --input-height-sm: 22px;
  --input-height-md: 26px;
  --input-height-lg: 32px;
  
  /* --- Button-Höhen --- */
  --button-height-sm: 24px;
  --button-height-md: 28px;
  --button-height-lg: 36px;
  
  /* --- Min-Breiten --- */
  --button-min-width: 75px;
  --input-min-width: 120px;

  /* ========================================
     RAHMEN
     ======================================== */
  
  --border-width: 1px;
  --border-radius-none: 0;
  --border-radius-sm: 2px;
  --border-radius-md: 4px;
  --border-radius-lg: 8px;

  /* ========================================
     SCHATTEN
     ======================================== */
  
  --shadow-none: none;
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.1);
  --shadow-md: 0 2px 4px rgba(0,0,0,0.15);
  --shadow-lg: 0 4px 8px rgba(0,0,0,0.2);
  --shadow-focus: 0 0 3px rgba(0,102,204,0.3);

  /* ========================================
     ÜBERGÄNGE
     ======================================== */
  
  --transition-fast: 0.1s ease;
  --transition-normal: 0.2s ease;
  --transition-slow: 0.3s ease;

  /* ========================================
     Z-INDEX
     ======================================== */
  
  --z-dropdown: 100;
  --z-sticky: 200;
  --z-modal-backdrop: 900;
  --z-modal: 1000;
  --z-tooltip: 1100;
}
```

---

## 📖 Verwendung in CSS

### Farben

```css
/* Statt hartcodierter Werte */
.btn-primary {
  background-color: var(--color-primary);
  color: var(--color-text-inverse);
}

.btn-primary:hover {
  background-color: var(--color-primary-hover);
}

.error-message {
  color: var(--color-error);
  background-color: var(--color-error-bg);
}
```

### Typografie

```css
body {
  font-family: var(--font-family-primary);
  font-size: var(--font-size-base);
  line-height: var(--line-height-normal);
}

.form-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
}

.code-block {
  font-family: var(--font-family-mono);
  font-size: var(--font-size-sm);
}
```

### Abstände

```css
.form-group {
  margin-bottom: var(--spacing-2);
}

.form-section {
  padding: var(--spacing-3);
  margin-bottom: var(--spacing-4);
}

.modal-body {
  padding: var(--spacing-4);
}
```

### Rahmen & Schatten

```css
input {
  border: var(--border-width) solid var(--color-border-input);
  border-radius: var(--border-radius-none);
}

input:focus {
  border-color: var(--color-border-focus);
  box-shadow: var(--shadow-focus);
}

.card {
  border: var(--border-width) solid var(--color-border-light);
  box-shadow: var(--shadow-sm);
}
```

---

## 🔧 Token-Anpassung

### Globale Änderung (empfohlen)

Um z.B. die Primärfarbe zu ändern:

```css
/* In design-tokens.css */
:root {
  --color-primary: #007ACC; /* Neuer Wert */
}
```

→ Ändert automatisch ALLE Stellen, die `var(--color-primary)` verwenden

### Formular-spezifische Überschreibung

```css
/* In frm_spezial.css */
.frm-spezial {
  --color-primary: #CC0000; /* Nur für dieses Formular */
}
```

---

## ✅ Best Practices

1. **Immer Tokens verwenden** statt hartcodierter Werte
2. **Keine Magic Numbers** → Abstände aus dem Grid-System
3. **Konsistente Benennung** → `--category-property-variant`
4. **Dokumentieren** → Neue Tokens hier und in design-tokens.css eintragen
5. **Testen** → Nach Token-Änderung alle Formulare prüfen

---

## 📋 Token-Übersicht

| Kategorie | Präfix | Beispiel |
|-----------|--------|----------|
| Farben | `--color-` | `--color-primary` |
| Schrift | `--font-` | `--font-size-base` |
| Abstände | `--spacing-` | `--spacing-4` |
| Rahmen | `--border-` | `--border-radius-md` |
| Schatten | `--shadow-` | `--shadow-lg` |
| Z-Index | `--z-` | `--z-modal` |
| Übergang | `--transition-` | `--transition-fast` |
