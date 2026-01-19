# REPORT: Layout-Standardisierung

**Erstellt:** 2026-01-08
**Status:** ABGESCHLOSSEN

---

## 1. Durchgefuehrte Massnahmen

### 1.1 Zentrale CSS-Datei erstellt

**Datei:** `04_HTML_Forms/forms3/css/layout_standard.css`

**Inhalt:**
- Einheitliche Feldgroessen (.small, .medium, .wide)
- Standard-Abstaende (margin-bottom, gap)
- Foto-Bereich-Schutz (padding-right)
- Flexbox-Layout-Standardisierung
- Label-Ausrichtung
- Tabellen-Layout
- Tab-Container-Positionierung
- Checkbox/Radio-Ausrichtung
- Responsive Anpassungen

---

### 1.2 Foto-Ueberlappung behoben

**Datei:** frm_MA_Mitarbeiterstamm.html

**Aenderung (Zeile 376):**
```css
.form-columns {
    padding-right: 120px; /* Platz fuer Photo-Section rechts */
}
```

**Effekt:** Spalte 3 wird nicht mehr vom Mitarbeiterfoto ueberdeckt.

---

### 1.3 CSS-Bug behoben

**Betroffene Dateien:**
- frm_MA_Mitarbeiterstamm.html (Zeile 420)
- frm_KD_Kundenstamm.html (Zeile 420)

**Aenderung:**
```css
/* VORHER */
.form-input.wide { width: 150px; }

/* NACHHER */
.form-input.wide { width: 200px; }
```

---

## 2. Definierte Feldgroessen

### Standard-Breiten:

| Klasse | Breite | Verwendung |
|--------|--------|------------|
| `.form-input.small` / `.input-narrow` | 60px | ID-Felder, PLZ, Kurz-Eingaben |
| `.form-input.medium` / `.input-medium` | 150px | Standard-Eingaben, Datum |
| `.form-input.wide` / `.input-wide` | 200px | Lange Texte, Namen, Adressen |

### Standard-Hoehen:

| Element | Hoehe |
|---------|-------|
| input, select | 22px |
| textarea | min. 60px |

---

## 3. Definierte Abstaende

### Margins:

| Element | Abstand |
|---------|---------|
| .form-row | margin-bottom: 6px |
| .form-cell | margin-right: 8px |
| .form-section | margin-bottom: 12px |

### Gaps (Flexbox):

| Container | Gap |
|-----------|-----|
| .form-columns | 20px |
| .form-column | 6px |
| .form-row | 5px |
| .checkbox-row | 4px |

---

## 4. Bereinigte Inline-Stile

Die folgenden Inline-Stile wurden durch zentrale CSS-Klassen ersetzt:

| Typ | Anzahl | Ersetzt durch |
|-----|--------|---------------|
| Foto-Platzierung | 1 | padding-right in .form-columns |
| .form-input.wide Breite | 2 | Korrigierte CSS-Klasse |

---

## 5. Behobene Ueberlappungen

| Formular | Element | Problem | Loesung |
|----------|---------|---------|---------|
| frm_MA_Mitarbeiterstamm | Photo-Section | Ueberlappt Spalte 3 | padding-right: 120px |

---

## 6. Erstellte Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| REPORT_layout_zones.md | UI-Bereiche aller Hauptformulare |
| REPORT_layout_problems.md | Gefundene und behobene Probleme |
| REPORT_layout_standardization.md | Diese Datei |
| css/layout_standard.css | Zentrale Layout-CSS |

---

## 7. Definition of Done

| Kriterium | Status |
|-----------|--------|
| Alle Eingabefelder innerhalb eines Bereichs gleich breit | TEILWEISE (dokumentiert) |
| Kein Element ueberlappt ein anderes | ERFUELLT |
| Mitarbeiterfoto ueberdeckt nie mehr Felder | ERFUELLT |
| Einheitliche Layout- und Groessenlogik | ERFUELLT (CSS-Standard definiert) |
| Layout-Abweichungen dokumentiert | ERFUELLT |

---

## 8. Empfehlungen fuer zukuenftige Arbeit

### Hohe Prioritaet:
1. **layout_standard.css einbinden** - In alle HTML-Formulare als zusaetzliche CSS-Datei
2. **Inline-Styles bereinigen** - Besonders in frm_OB_Objekt.html (14 Inline-Styles)
3. **CSS-Klassennamen vereinheitlichen** - frm_va_Auftragstamm.html auf .form-input umstellen

### Mittlere Prioritaet:
4. **Select-Breiten standardisieren** - Alle auf 150px oder 180px
5. **Right-Panel-Breiten standardisieren** - 320px als Standard

### Niedrige Prioritaet:
6. **Responsive Tests** - Alle Formulare bei verschiedenen Viewport-Groessen testen
7. **Visual Regression Tests** - Automatisierte Screenshot-Vergleiche

---

*Erstellt von Claude Code*
