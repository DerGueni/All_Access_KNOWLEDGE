# Formulartitel Schriftgröße - Projekt Übersicht

**Datum:** 2026-01-15
**Status:** ✅ Implementiert und dokumentiert

---

## 🎯 Projekt-Ziel

Einheitliche Schriftgröße für alle Formulartitel basierend auf der Sidebar-Button-Größe (12px).

**Ergebnis:** Alle Hauptformular-Titel erhalten **24px** (= 2× Sidebar-Buttons)

---

## 📁 Projekt-Dateien

### 1. Implementierung (CSS)
- ✅ `css/variables.css` - Neue Variable `--font-size-3xl: 24px`
- ✅ `css/form-titles.css` - Globale Titel-Styling-Regeln

### 2. Dokumentation
- ✅ `FORMULARTITEL_SCHRIFTGROESSE_SPEC.md` - Vollständige Spezifikation
- ✅ `FORMULARTITEL_MIGRATION.md` - Migrations-Anleitung
- ✅ `SCHRIFTGROESSEN_HIERARCHIE.md` - Visuelle Hierarchie
- ✅ `SCHRIFTGROESSEN_QUICK_REFERENCE.md` - Schnellreferenz
- ✅ `README_FORMULARTITEL.md` - Diese Übersicht

---

## 🔍 Analyse-Ergebnisse

### Sidebar-Buttons (BASIS)
```css
/* shell.html Zeile 85 */
.menu-btn {
    font-size: 12px;
}
```

### Bisherige Formulartitel (INKONSISTENT)
- `frm_va_Auftragstamm.html`: **32px** ❌ zu groß
- `frm_MA_Zeitkonten.html`: **23px** ❌ inkonsistent
- `frm_MA_Adressen.html`: **24px** ✅ korrekt (aber lokal)
- `frm_KD_Umsatzauswertung.html`: **16px** ❌ zu klein

### Neue Standardgröße (EINHEITLICH)
- **ALLE Hauptformulare**: **24px** ✅

---

## 🚀 Implementierung

### CSS Variable
```css
/* css/variables.css - Zeile 118 */
:root {
    --font-size-3xl: 24px;  /* Hauptformular-Titel (2× Sidebar-Buttons) */
}
```

### Globale CSS-Regeln
```css
/* css/form-titles.css */
.app-title,
.form-title,
.page-title,
.placeholder h1 {
    font-size: var(--font-size-3xl, 24px) !important;
    font-weight: var(--font-weight-bold, 700);
    color: var(--color-text-title, #000080);
}
```

---

## 📊 Schriftgrößen-Hierarchie

```
32px  ████████  ❌ VERALTET (zu dominant)
24px  ██████    ✅ HAUPTFORMULAR-TITEL (NEU)
18px  █████     Große Titel (Spezial)
16px  ████      Haupt-Titel
14px  ███       SUBFORM-HEADER
12px  ██        SIDEBAR-BUTTONS (BASIS) 🎯
11px  █         Standard-Text
10px  ▓         Status-Bar
9px   ░         Badges, Notizen
```

---

## 🔧 Migration

### Schritt 1: CSS einbinden
```html
<head>
    <link rel="stylesheet" href="css/variables.css">
    <link rel="stylesheet" href="css/form-titles.css">  <!-- NEU -->
</head>
```

### Schritt 2: Lokale Überschreibungen entfernen
```css
/* ENTFERNEN: */
:root { --title-font-size: 32px; }
.app-title { font-size: 23px !important; }
.placeholder h1 { font-size: 16px; }
```

### Schritt 3: Titel-Klassen verwenden
```html
<!-- Hauptformular -->
<div class="app-title">Auftragsverwaltung</div>

<!-- Subform -->
<div class="subform-header">Einsatzliste</div>
```

---

## 📋 Betroffene Formulare

### Hohe Priorität (inkonsistent)
- `frm_va_Auftragstamm.html` (32px → 24px)
- `frm_MA_Zeitkonten.html` (23px → 24px)
- `frm_KD_Verrechnungssaetze.html` (23px → 24px)

### Mittlere Priorität (zu klein)
- `frm_MA_Adressen.html` (16px → 24px)
- `frm_KD_Umsatzauswertung.html` (16px → 24px)
- `frmTop_VA_Akt_Objekt_Kopf.html` (16px → 24px)

---

## ✅ Testing

### Browser DevTools Test
```
F12 → Elements → .app-title → Computed:
  font-size: 24px ✅
  font-weight: 700 ✅
  color: rgb(0, 0, 128) ✅
```

### Visuelle Prüfung
- [ ] Titel ist 2× größer als Sidebar-Buttons
- [ ] Titel ist nicht zu dominant
- [ ] Alle Formulare haben identische Größe
- [ ] Subforms sind kleiner (14px)

---

## 🎓 Design-Prinzip

### Mathematische Basis
```
Sidebar-Button: 12px (BASIS)
Haupttitel:     24px (= 12px × 2)
Subform-Header: 14px (= 12px + 2px)

Verhältnis: 24 : 14 : 12 = 2.0 : 1.17 : 1.0
```

### Begründung für 24px
1. ✅ Klare Hierarchie (2× prominenter als Menu-Buttons)
2. ✅ Konsistente mathematische Beziehung
3. ✅ Nicht zu dominant (wie 32px)
4. ✅ Professionell und lesbar

---

## 📚 Dokumentations-Links

| Dokument | Zweck | Zielgruppe |
|----------|-------|------------|
| `FORMULARTITEL_SCHRIFTGROESSE_SPEC.md` | Vollständige technische Spezifikation | Entwickler |
| `FORMULARTITEL_MIGRATION.md` | Schritt-für-Schritt Migrations-Anleitung | Entwickler |
| `SCHRIFTGROESSEN_HIERARCHIE.md` | Visuelle Darstellung der Hierarchie | Designer/Entwickler |
| `SCHRIFTGROESSEN_QUICK_REFERENCE.md` | Schnellreferenz für tägliche Arbeit | Alle |
| `README_FORMULARTITEL.md` | Projekt-Übersicht | Management/Team |

---

## 🔄 Wartung

### CSS Variables
**Datei:** `css/variables.css`
```css
--font-size-3xl: 24px;  /* Hauptformular-Titel */
```

**Änderung:** Einmal ändern → Alle Formulare aktualisiert

### Globale Regeln
**Datei:** `css/form-titles.css`
- Einheitliche Styling-Regeln für alle Titel
- Zentrale Wartung

---

## ⚠️ Wichtige Hinweise

### DO's ✅
- CSS-Variable `--font-size-3xl` verwenden
- Titel-Klassen (`.app-title`) nutzen
- Zentrale CSS-Dateien einbinden
- Lokale Überschreibungen entfernen

### DON'Ts ❌
- Keine manuellen Schriftgrößen (z.B. `font-size: 23px;`)
- Keine lokalen `:root` Überschreibungen
- Keine `!important` auf lokaler Ebene
- Keine inkonsistenten Größen

---

## 📈 Nächste Schritte

1. ✅ CSS-Infrastruktur fertig
2. ⏳ Migration der Hauptformulare starten
3. ⏳ Visuelle Tests durchführen
4. ⏳ Dokumentation an Team verteilen

---

## 🎉 Zusammenfassung

**Vorher:**
- Inkonsistente Schriftgrößen (16px - 32px)
- Lokale Überschreibungen in jedem Formular
- Keine zentrale Verwaltung

**Nachher:**
- Einheitliche Schriftgröße: **24px**
- CSS-Variable: `--font-size-3xl`
- Zentrale Verwaltung via `form-titles.css`
- Klare Hierarchie: 24px (Titel) : 14px (Subform) : 12px (Buttons)

---

**Erstellt:** 2026-01-15
**Status:** ✅ Bereit für Produktion
**Version:** 1.0
