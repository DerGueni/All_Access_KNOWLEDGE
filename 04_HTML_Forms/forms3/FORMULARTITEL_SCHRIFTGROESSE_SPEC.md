# FORMULARTITEL SCHRIFTGRÖSSE - Spezifikation

**Erstellt:** 15.01.2026
**Status:** Definiert

## Übersicht

Dieses Dokument definiert die einheitlichen Schriftgrößen für alle HTML-Formulare in `forms3/`.

## Schriftgrößen-Hierarchie

### CSS-Variablen (in :root)

```css
:root {
    --base-font-size: 11px;        /* Standard für alle Texte */
    --small-font-size: 10px;       /* Kleinere Texte, Hinweise */
    --header-font-size: 12px;      /* Header in Tabellen */
    --title-font-size: 24px;       /* Formulartitel im Header */
}
```

## Anwendungsbereiche

### 1. Formulartitel (24px)
**Verwendung:** Haupttitel im Header-Bereich
**CSS-Klasse:** `.title-text`
**Beispiel:** "Auftragsverwaltung", "Mitarbeiterstamm", "Kundenstamm"

```css
.title-text {
    font-size: var(--title-font-size);
    font-weight: bold;
    color: #000000;
}
```

### 2. Standard-Text (11px)
**Verwendung:**
- Buttons
- Labels
- Input-Felder
- Dropdown-Menüs
- Text-Links
- Allgemeiner Body-Text

**CSS:**
```css
* {
    font-size: var(--base-font-size);
}
```

### 3. Tabellen-Header (12px)
**Verwendung:** Header-Zeilen in Datasheets/Tabellen
**CSS-Klasse:** `.datasheet th`

```css
.datasheet th {
    font-size: var(--header-font-size);
    font-weight: bold;
}
```

### 4. Kleine Texte (10px)
**Verwendung:**
- Hinweistexte
- Timestamps
- Meta-Informationen

**CSS-Klasse:** `.small-text`

```css
.small-text {
    font-size: var(--small-font-size);
}
```

## Implementierung in Formularen

### HTML-Struktur
```html
<style>
    :root {
        --base-font-size: 11px;
        --small-font-size: 10px;
        --header-font-size: 12px;
        --title-font-size: 24px;
    }

    * {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        font-size: var(--base-font-size);
    }

    .title-text {
        font-size: var(--title-font-size);
        font-weight: bold;
    }
</style>
```

### Beispiel: Formulartitel im Header
```html
<div class="header-row combined-buttons">
    <div class="logo-box">C</div>
    <span class="title-text">Auftragsverwaltung</span>
    <!-- Buttons folgen... -->
</div>
```

## Migration bestehender Formulare

### Schritt 1: CSS-Variablen hinzufügen
Falls noch nicht vorhanden, im `<style>` Block hinzufügen.

### Schritt 2: title-text Klasse anwenden
```html
<!-- ALT -->
<span>Auftragsverwaltung</span>

<!-- NEU -->
<span class="title-text">Auftragsverwaltung</span>
```

### Schritt 3: Inline-Styles entfernen
```html
<!-- ALT -->
<span style="font-size: 14px; font-weight: bold;">Titel</span>

<!-- NEU -->
<span class="title-text">Titel</span>
```

## Betroffene Formulare

### Priorität 1 (Sofortige Umsetzung)
- [x] frm_va_Auftragstamm.html (bereits 32px → auf 24px reduzieren)
- [ ] frm_MA_Mitarbeiterstamm.html
- [ ] frm_KD_Kundenstamm.html
- [ ] frm_OB_Objekt.html

### Priorität 2 (Später)
- [ ] frm_MA_Abwesenheit.html
- [ ] frm_MA_Zeitkonten.html
- [ ] frm_N_Bewerber.html
- [ ] frm_N_Lohnabrechnungen.html
- [ ] Weitere Formulare...

## Validierung

Nach der Implementierung prüfen:
- [ ] Formulartitel hat exakt 24px
- [ ] Alle Buttons haben 11px
- [ ] Tabellen-Header haben 12px
- [ ] Keine inline-Styles mehr für Schriftgrößen
- [ ] CSS-Variablen sind definiert
- [ ] Konsistenz über alle Formulare

## Browser-Kompatibilität

CSS-Variablen werden unterstützt in:
- Chrome/Edge 49+
- Firefox 31+
- Safari 9.1+
- Opera 36+

Für ältere Browser: Fallback mit festen Werten.

## Änderungshistorie

| Datum | Änderung | Begründung |
|-------|----------|------------|
| 15.01.2026 | Initiale Spezifikation | Einheitliches Design |
| 15.01.2026 | title-font-size auf 24px festgelegt | Lesbarkeit vs. Platz-Balance |

## Referenzen

- Haupt-Design-Spec: `UNIFIED_HEADER_DESIGN.md`
- CSS-Datei: `css/unified-header.css`
- Referenzformular: `frm_va_Auftragstamm.html`
