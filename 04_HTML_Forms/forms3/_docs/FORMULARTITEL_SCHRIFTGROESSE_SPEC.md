# Formulartitel Schriftgröße - Spezifikation

**Erstellt:** 2026-01-15
**Zweck:** Einheitliche Schriftgröße für Formulartitel basierend auf Sidebar-Buttons

---

## 1. Analyse der aktuellen Schriftgrößen-Hierarchie

### 1.1 Sidebar-Buttons (shell.html)

**Gefunden in:** `shell.html` Zeile 85
```css
.menu-btn {
    font-size: 12px;
    /* ... */
}
```

**Status:** ✅ Bestätigt - Sidebar-Buttons haben **12px** Schriftgröße

---

### 1.2 CSS Custom Properties (variables.css)

**Gefunden in:** `css/variables.css` Zeile 110-118

```css
:root {
    /* Font-Groessen - Skala */
    --font-size-xs: 9px;      /* Badges, Notizen, GPT-Box */
    --font-size-sm: 10px;     /* Status-Bar, Header-Links */
    --font-size-base: 11px;   /* Standard fuer alle Elemente */
    --font-size-md: 12px;     /* Labels, Menu-Buttons */
    --font-size-lg: 14px;     /* Section-Titel, Formular-Header */
    --font-size-xl: 16px;     /* Haupt-Titel */
    --font-size-2xl: 18px;    /* Grosse Formular-Titel */
}
```

**Analyse:**
- `--font-size-md: 12px` = Sidebar-Buttons
- `--font-size-2xl: 18px` = Große Formulartitel (aktuell definiert)
- **FEHLT:** Eine Variable für **24px** (doppelt so groß wie Sidebar-Buttons)

---

### 1.3 Aktuelle Formulartitel in Verwendung

**Beispiele aus Grep-Ergebnisse:**

| Formular | Aktuelle Schriftgröße | Methode |
|----------|----------------------|---------|
| `frm_va_Auftragstamm.html` | **32px** | `--title-font-size: 32px;` |
| `frm_va_Auftragstamm2.html` | **23px** | `--title-font-size: 23px;` |
| `frm_MA_Zeitkonten.html` | **23px** | `.app-title { font-size: 23px !important; }` |
| `frm_MA_Adressen.html` | **24px** | `.placeholder h1 { font-size: 24px; }` |
| `frm_KD_Verrechnungssaetze.html` | **23px** | `--title-font-size: 23px;` |
| `frm_KD_Umsatzauswertung.html` | **24px** | `.placeholder h1 { font-size: 24px; }` |
| Mehrere andere | **16px** | `.placeholder h1 { font-size: 16px; }` |

**Problem:** ❌ Inkonsistent! Schriftgrößen variieren zwischen **16px - 32px**

---

## 2. Empfohlene Standardisierung

### 2.1 Neue CSS Custom Property

**Hinzufügen zu:** `css/variables.css` (nach Zeile 118)

```css
:root {
    /* Font-Groessen - Skala */
    --font-size-xs: 9px;      /* Badges, Notizen, GPT-Box */
    --font-size-sm: 10px;     /* Status-Bar, Header-Links */
    --font-size-base: 11px;   /* Standard fuer alle Elemente */
    --font-size-md: 12px;     /* Labels, Menu-Buttons */
    --font-size-lg: 14px;     /* Section-Titel, Formular-Header */
    --font-size-xl: 16px;     /* Haupt-Titel */
    --font-size-2xl: 18px;    /* Grosse Formular-Titel */
    --font-size-3xl: 24px;    /* ⭐ NEU: Formulartitel (doppelt so groß wie Sidebar-Buttons) */
}
```

### 2.2 Begründung für 24px

**Mathematik:**
- Sidebar-Button: `12px`
- Doppelt so groß: `12px × 2 = 24px`

**Vorteile:**
1. ✅ Klare Hierarchie: Formulartitel sind **2×** prominenter als Menu-Buttons
2. ✅ Konsistente Basis: Alle Formulartitel verwenden **24px**
3. ✅ Nicht zu groß: 24px ist lesbar und professionell (vs. 32px = zu dominant)
4. ✅ CSS Variable: Zentrale Verwaltung über `--font-size-3xl`

---

## 3. CSS-Code für einheitliche Formulartitel

### 3.1 Globale Regel (in layout_standard.css oder neuer Datei)

```css
/* ========================================================
   FORMULARTITEL - Einheitliche Schriftgröße
   ======================================================== */

/* Formulartitel in Hauptformularen */
.app-title,
.form-title,
.formular-titel,
.page-title,
.placeholder h1 {
    font-size: var(--font-size-3xl, 24px) !important;
    font-weight: var(--font-weight-bold, 700);
    color: var(--color-text-title, #000080);
    line-height: var(--line-height-tight, 1.2);
}

/* Subform-Header (kleiner) */
.subform-header,
.form-header {
    font-size: var(--font-size-lg, 14px);
    font-weight: var(--font-weight-semibold, 600);
    color: var(--color-text-title, #000080);
}

/* Lokale --title-font-size überschreiben */
:root {
    --title-font-size: var(--font-size-3xl, 24px);
}
```

### 3.2 Formulartitel-Klassen Übersicht

| Klasse | Verwendung | Schriftgröße |
|--------|-----------|--------------|
| `.app-title` | Hauptformular-Titel (z.B. Mitarbeiterstamm) | **24px** |
| `.form-title` | Alternative Titel-Klasse | **24px** |
| `.page-title` | Dashboard/App-Seiten | **24px** |
| `.placeholder h1` | Placeholder-Formulare | **24px** |
| `.subform-header` | Subform-Überschriften (z.B. Einsatzliste) | **14px** |
| `.form-header` | Dialog/Modal-Header | **14px** |

---

## 4. Migration Plan

### 4.1 Schritt 1: CSS Variable hinzufügen
```bash
# Datei: css/variables.css
# Nach Zeile 118 einfügen:
--font-size-3xl: 24px;    /* Formulartitel (2× Sidebar-Buttons) */
```

### 4.2 Schritt 2: Globale CSS-Regel erstellen
```bash
# Neue Datei: css/form-titles.css
# Inhalt: Siehe 3.1
```

### 4.3 Schritt 3: In Hauptformularen einbinden
```html
<!-- In allen frm_*.html nach <link rel="stylesheet" href="css/variables.css"> -->
<link rel="stylesheet" href="css/form-titles.css">
```

### 4.4 Schritt 4: Lokale Überschreibungen entfernen

**Formulare mit manueller --title-font-size:**
- `frm_va_Auftragstamm.html` (aktuell 32px → 24px)
- `frm_va_Auftragstamm2.html` (aktuell 23px → 24px)
- `frm_KD_Verrechnungssaetze.html` (aktuell 23px → 24px)

**Aktion:** Entferne lokale `--title-font-size` Definition, verwende globale Regel

---

## 5. Testing Checklist

Nach der Implementierung ALLE Hauptformulare visuell prüfen:

- [ ] `frm_va_Auftragstamm.html` - Titel = 24px
- [ ] `frm_MA_Mitarbeiterstamm.html` - Titel = 24px
- [ ] `frm_KD_Kundenstamm.html` - Titel = 24px
- [ ] `frm_OB_Objekt.html` - Titel = 24px
- [ ] `frm_MA_Zeitkonten.html` - Titel = 24px
- [ ] `frm_MA_Abwesenheit.html` - Titel = 24px
- [ ] `frm_DP_Dienstplan_MA.html` - Titel = 24px
- [ ] `frm_DP_Dienstplan_Objekt.html` - Titel = 24px

**Prüfkriterien:**
1. Titel ist deutlich größer als Sidebar-Buttons (12px)
2. Titel ist nicht zu dominant (nicht wie 32px)
3. Alle Formulare haben identische Titelgröße
4. Subform-Header bleiben kleiner (14px)

---

## 6. Zusammenfassung

### Aktuelle Situation
- Sidebar-Buttons: **12px** (bestätigt in shell.html)
- Formulartitel: **Inkonsistent** (16px - 32px)
- CSS Variable: **Fehlt** für 24px

### Empfohlene Lösung
- Neue CSS Variable: `--font-size-3xl: 24px`
- Globale CSS-Regel für `.app-title`, `.form-title`, etc.
- Migration aller Hauptformulare auf **24px**
- Subform-Header bleiben bei **14px**

### Vorteile
1. ✅ Einheitliches Design über alle Formulare
2. ✅ Klare Hierarchie (24px = 2× Sidebar-Buttons)
3. ✅ Zentrale Verwaltung via CSS Custom Property
4. ✅ Einfache Wartung (eine Änderung = alle Formulare)

---

**Nächste Schritte:**
1. CSS Variable `--font-size-3xl: 24px` zu `variables.css` hinzufügen
2. Neue Datei `css/form-titles.css` mit globalen Regeln erstellen
3. Migration der Hauptformulare (entferne lokale Überschreibungen)
4. Visuelles Testing aller Formulare
