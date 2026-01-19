# Schriftgrößen Quick Reference

**⚡ Schnellreferenz für CONSYS HTML-Formulare**

---

## 📏 Die 3 wichtigsten Größen

```
24px  →  Hauptformular-Titel  (.app-title)
14px  →  Subform-Header        (.subform-header)
12px  →  Sidebar-Buttons       (.menu-btn) ← BASIS
```

---

## 🎨 CSS-Variablen Übersicht

| Variable | Größe | Verwendung |
|----------|-------|------------|
| `--font-size-3xl` | **24px** | 🏆 Hauptformular-Titel |
| `--font-size-2xl` | 18px | Große Titel (Spezial) |
| `--font-size-xl` | 16px | Haupt-Titel |
| `--font-size-lg` | 14px | Subform-Header |
| `--font-size-md` | **12px** | 🎯 Sidebar-Buttons (BASIS) |
| `--font-size-base` | 11px | Standard-Text |
| `--font-size-sm` | 10px | Status-Bar |
| `--font-size-xs` | 9px | Badges, Notizen |

---

## 💻 HTML/CSS Code-Snippets

### Hauptformular-Titel (24px)
```html
<div class="app-title">Auftragsverwaltung</div>
```

### Subform-Header (14px)
```html
<div class="subform-header">Einsatzliste</div>
```

### CSS Variable verwenden
```css
.custom-title {
    font-size: var(--font-size-3xl);  /* 24px */
}
```

---

## 📦 Dateien einbinden

```html
<head>
    <link rel="stylesheet" href="css/variables.css">
    <link rel="stylesheet" href="css/form-titles.css">
</head>
```

---

## 🔧 Migration Checkliste

- [ ] `css/form-titles.css` eingebunden
- [ ] Lokale `--title-font-size` entfernt
- [ ] Titel-Klasse verwendet (`.app-title`)
- [ ] Browser-Test: F12 → font-size = 24px
- [ ] Subforms = 14px geprüft

---

## 📊 Verhältnis zur BASIS (12px)

```
24px = 2.0×  (Doppelt so groß) ⭐
18px = 1.5×
16px = 1.33×
14px = 1.17×
12px = 1.0×  (BASIS) 🎯
11px = 0.92×
```

---

## ⚠️ Häufige Fehler vermeiden

❌ NICHT: `font-size: 23px;` (inkonsistent)
✅ STATTDESSEN: `var(--font-size-3xl)`

❌ NICHT: Lokale `:root { --title-font-size: 32px; }`
✅ STATTDESSEN: `css/form-titles.css` einbinden

❌ NICHT: `.app-title { font-size: 16px !important; }`
✅ STATTDESSEN: Globale Regel aus `form-titles.css` verwenden

---

## 🎯 Klassen-Mapping

| Klasse | Element | Größe | Gewicht |
|--------|---------|-------|---------|
| `.app-title` | Haupttitel | 24px | bold (700) |
| `.form-title` | Formular-Titel | 24px | bold (700) |
| `.page-title` | Seiten-Titel | 24px | bold (700) |
| `.subform-header` | Subform-Header | 14px | semibold (600) |
| `.form-header` | Dialog-Header | 14px | semibold (600) |

---

## 🔍 Browser DevTools Test

```
F12 → Elements → .app-title → Computed:
  font-size: 24px ✅
  font-weight: 700 ✅
  color: rgb(0, 0, 128) ✅
```

---

## 📝 Dokumentation

- **Vollständige Spec:** `FORMULARTITEL_SCHRIFTGROESSE_SPEC.md`
- **Migration Guide:** `FORMULARTITEL_MIGRATION.md`
- **Hierarchie:** `SCHRIFTGROESSEN_HIERARCHIE.md`
- **CSS Variables:** `css/variables.css`
- **CSS Rules:** `css/form-titles.css`

---

**Erstellt:** 2026-01-15 | **Status:** ✅ Produktionsbereit
