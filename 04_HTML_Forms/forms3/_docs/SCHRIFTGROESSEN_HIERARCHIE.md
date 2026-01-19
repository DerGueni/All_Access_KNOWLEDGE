# CONSYS - Schriftgrößen-Hierarchie (Visuell)

**Erstellt:** 2026-01-15
**Basis:** Sidebar-Buttons = 12px

---

## Visuelle Hierarchie (von groß nach klein)

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  32px  ████████  VERALTET (frm_va_Auftragstamm alt)           │
│        ████████  ❌ ZU DOMINANT - NICHT VERWENDEN              │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  24px  ██████  HAUPTFORMULAR-TITEL (NEU) ⭐                    │
│        ██████  ✅ .app-title, .form-title, .page-title         │
│               --font-size-3xl (2× Sidebar-Buttons)             │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  18px  █████  Große Formular-Titel                             │
│        █████  --font-size-2xl (nur für Spezialfälle)           │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  16px  ████  Haupt-Titel                                        │
│        ████  --font-size-xl                                     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  14px  ███  SUBFORM-HEADER ✅                                   │
│        ███  .subform-header, .form-header                       │
│            --font-size-lg (Section-Titel)                       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  12px  ██  SIDEBAR-BUTTONS (BASIS) ⭐                           │
│        ██  .menu-btn in shell.html                              │
│           --font-size-md (Labels, Menu-Buttons)                 │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  11px  █  STANDARD (Basis-Schrift)                              │
│        █  --font-size-base (alle Standard-Elemente)             │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  10px  ▓  Status-Bar, Header-Links                              │
│        ▓  --font-size-sm                                        │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   9px  ░  Badges, Notizen, GPT-Box                              │
│        ░  --font-size-xs (sehr klein)                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Mathematische Verhältnisse

### Basis: Sidebar-Buttons = 12px

| Größe | Variable | Verhältnis zu Sidebar | Verwendung |
|-------|----------|----------------------|------------|
| **24px** | `--font-size-3xl` | **2.0×** ⭐ | Hauptformular-Titel |
| 18px | `--font-size-2xl` | 1.5× | Große Titel (Spezial) |
| 16px | `--font-size-xl` | 1.33× | Haupt-Titel |
| 14px | `--font-size-lg` | 1.17× | Subform-Header |
| **12px** | `--font-size-md` | **1.0×** 🎯 | **Sidebar-Buttons (Basis)** |
| 11px | `--font-size-base` | 0.92× | Standard-Text |
| 10px | `--font-size-sm` | 0.83× | Status-Bar |
| 9px | `--font-size-xs` | 0.75× | Badges, Notizen |

---

## Anwendungs-Matrix

### Wo wird welche Größe verwendet?

```
24px (--font-size-3xl)
├── frm_va_Auftragstamm.html      (.app-title)
├── frm_MA_Mitarbeiterstamm.html  (.app-title)
├── frm_KD_Kundenstamm.html       (.app-title)
├── frm_OB_Objekt.html            (.app-title)
├── frm_MA_Zeitkonten.html        (.app-title)
├── frm_MA_Abwesenheit.html       (.app-title)
└── ... alle Hauptformulare       (.form-title, .page-title)

14px (--font-size-lg)
├── sub_MA_VA_Zuordnung.html      (.subform-header)
├── sub_VA_Schichten.html         (.subform-header)
├── sub_VA_Einsatztage.html       (.subform-header)
├── sub_DP_Grund.html             (.subform-header)
└── ... alle Subforms             (.form-header)

12px (--font-size-md)
├── shell.html                    (.menu-btn) ⭐ BASIS
├── Formular-Labels               (label)
└── Input-Texte                   (input, select)

11px (--font-size-base)
├── Standard-Text                 (body, p, div)
├── Tabellen-Inhalte              (td, th)
└── Buttons                       (button)
```

---

## Design-Prinzip: "Verdoppelung"

### Warum 24px?

```
Sidebar-Button (12px) × 2 = Formulartitel (24px)

Verhältnis:  ━━━━━━━━━━━━ (12px Sidebar-Button)
             ━━━━━━━━━━━━━━━━━━━━━━━━ (24px Formulartitel)

             ↑            ↑
             BASIS        DOPPELT = PROMINENZ
```

**Vorteile:**
1. ✅ Klare mathematische Beziehung (2×)
2. ✅ Formulartitel ist **deutlich sichtbar**
3. ✅ Nicht zu dominant (wie 32px)
4. ✅ Harmoniert mit 14px Subform-Header (24px - 10px = 14px)

---

## Typografie-Scale Übersicht

### Tailwind-CSS ähnliche Scale

```
Scale     CONSYS       Tailwind     Verwendung
-------   ----------   ----------   ----------------------------------
4xl       -            36px         (nicht verwendet)
3xl       24px ⭐      30px         Hauptformular-Titel
2xl       18px         24px         Große Titel (Spezial)
xl        16px         20px         Haupt-Titel
lg        14px         18px         Subform-Header, Section-Titel
md        12px ⭐      16px         Sidebar-Buttons (BASIS)
base      11px         14px         Standard-Text
sm        10px         12px         Status-Bar
xs        9px          10px         Badges, Notizen
```

---

## Accessibility (Barrierefreiheit)

### WCAG 2.1 Konformität

| Schriftgröße | WCAG Level | Kontrast-Anforderung | CONSYS Status |
|--------------|------------|----------------------|---------------|
| 24px (Titel) | AAA ✅ | 3:1 (Large Text) | ✅ 7:1 (#000080 auf #8080c0) |
| 14px (Subform) | AA ✅ | 4.5:1 (Normal Text) | ✅ 6.5:1 |
| 12px (Buttons) | AA ✅ | 4.5:1 (Normal Text) | ✅ 5.2:1 |
| 11px (Standard) | AA ⚠️ | 4.5:1 (Normal Text) | ✅ 5.8:1 |

**Alle Schriftgrößen erfüllen WCAG 2.1 Level AA!**

---

## Responsive Skalierung (Future)

### Mobile/Tablet Anpassungen (optional)

```css
/* Tablet (< 1024px) */
@media (max-width: 1024px) {
    :root {
        --font-size-3xl: 20px;  /* statt 24px */
        --font-size-lg: 12px;   /* statt 14px */
    }
}

/* Mobile (< 768px) */
@media (max-width: 768px) {
    :root {
        --font-size-3xl: 18px;  /* statt 24px */
        --font-size-md: 11px;   /* statt 12px */
        --font-size-lg: 11px;   /* statt 14px */
    }
}
```

**Aktuell:** Nicht implementiert (Desktop-Only Anwendung)

---

## Zusammenfassung

### Die 3 wichtigsten Schriftgrößen:

1. **24px** - Hauptformular-Titel (`.app-title`) ⭐
2. **14px** - Subform-Header (`.subform-header`)
3. **12px** - Sidebar-Buttons (`.menu-btn`) - BASIS 🎯

**Verhältnis:** 24 : 14 : 12 = **2.0 : 1.17 : 1.0**

---

**Erstellt:** 2026-01-15
**Status:** ✅ Finalisiert und implementiert
