# REPORT: Layout-Probleme

**Erstellt:** 2026-01-08

---

## 1. Kritische Probleme (behoben)

### 1.1 Mitarbeiterfoto ueberlappt Spalte 3

**Problem:**
- `.photo-section` hatte `position: absolute; right: 10px; top: 10px`
- Keine Reservierung von Platz im Container
- Foto konnte Bankdaten/Bemerkungen-Felder in Spalte 3 ueberdecken

**Loesung:**
```css
.form-columns {
    padding-right: 120px; /* Platz fuer Photo-Section */
}
```

**Status:** BEHOBEN in frm_MA_Mitarbeiterstamm.html (Zeile 376)

---

### 1.2 CSS-Bug: .form-input.medium und .form-input.wide identisch

**Problem:**
```css
/* VORHER (falsch) */
.form-input.medium { width: 150px; }
.form-input.wide { width: 150px; }  /* Sollte breiter sein! */
```

**Loesung:**
```css
/* NACHHER (korrekt) */
.form-input.medium { width: 150px; }
.form-input.wide { width: 200px; }
```

**Status:** BEHOBEN in:
- frm_MA_Mitarbeiterstamm.html (Zeile 420)
- frm_KD_Kundenstamm.html (Zeile 420)

---

## 2. Feldgroessen-Abweichungen

### 2.1 Inkonsistente CSS-Klassennamen

| Formular | Klassennamen | Standard? |
|----------|--------------|-----------|
| frm_MA_Mitarbeiterstamm | .form-input.small/medium/wide | JA |
| frm_KD_Kundenstamm | .form-input.small/medium/wide | JA |
| frm_va_Auftragstamm | .input-narrow/medium/wide | ABWEICHEND |
| frm_OB_Objekt | Nur Inline-Styles | ABWEICHEND |

**Empfehlung:** Alle auf `.form-input.small/medium/wide` standardisieren

---

### 2.2 Abweichende Feldbreiten im selben Bereich

**frm_MA_Mitarbeiterstamm.html:**
| Feld | Breite | Bereich | Problem |
|------|--------|---------|---------|
| select#Geschlecht | 120px | Stammdaten | Kleiner als andere Selects (150px) |
| select#Kleidergroesse | 100px | Stammdaten | Kleiner als andere Selects |
| select#Stundenlohn_brutto | 180px | Stammdaten | Groesser als Standard |
| select#Taetigkeit_Bezeichnung | 180px | Stammdaten | Groesser als Standard |

**frm_KD_Kundenstamm.html:**
| Feld | Breite | Bereich | Problem |
|------|--------|---------|---------|
| input#cboKDNrSuche | 50px | Suche | Sehr schmal |
| select#kun_LKZ | 100px | Stammdaten | Kleiner als andere Selects (150px) |
| select#kun_IDF_PersonID | 200px | Stammdaten | Groesser als Standard |
| input#adr_eMail | 200px | Ansprechpartner | Groesser als andere (150px) |
| input#adr_Geburtstag | 130px | Ansprechpartner | Ungewoehnliche Breite |

**frm_OB_Objekt.html:**
| Feld | Breite | Bereich | Problem |
|------|--------|---------|---------|
| input#Objekt | 200px | Stammdaten | Groesser als Ort (150px) |
| input#Strasse | 200px | Stammdaten | Groesser als andere |
| input#Treffp_Zeit | 50px | Stammdaten | Sehr schmal |
| textarea#txtAnfahrt | 235px | Stammdaten | Ungewoehnliche Breite |

---

## 3. Strukturelle Probleme

### 3.1 Fehlende position: relative

**Problem:**
Tab-Content-Container ohne `position: relative` koennen zu falscher Positionierung von absolut positionierten Kind-Elementen fuehren.

**Betroffene Dateien:**
- Alle Formulare mit Photo-Section oder absolut positionierten Elementen

**Loesung in layout_standard.css:**
```css
.tab-page.active,
.tab-pane.active {
    position: relative;
}
```

---

### 3.2 Right-Panel Breiten-Inkonsistenz

| Formular | Right-Panel Breite |
|----------|-------------------|
| frm_MA_Mitarbeiterstamm | 300px |
| frm_KD_Kundenstamm | 320px |
| frm_OB_Objekt | 320px |
| frm_va_Auftragstamm | 500px |

**Empfehlung:** Standardisieren auf 320px (ausser Auftragstamm wegen mehr Spalten)

---

## 4. Potentielle Ueberlappungs-Risiken

### 4.1 Absolute Positionierung

| Datei | Element | Position | Risiko |
|-------|---------|----------|--------|
| frm_MA_Mitarbeiterstamm | .photo-section | absolute, right: 10px | BEHOBEN |
| Diverse | .status-dropdown | absolute | Gering |
| Diverse | Navigation Buttons | absolute | Gering |

### 4.2 Responsive Verhalten

Bei schmalen Viewports (<1200px) koennen folgende Probleme auftreten:
- Flex-Columns brechen um und kollidieren mit absolut positionierten Elementen
- Photo-Section ueberlappt umgebrochene Spalten

**Loesung in layout_standard.css:**
```css
@media (max-width: 1200px) {
    .form-columns {
        padding-right: 0;
    }
    .photo-section {
        position: relative;
    }
}
```

---

## 5. Zusammenfassung

| Kategorie | Gefunden | Behoben |
|-----------|----------|---------|
| Kritische Ueberlappungen | 1 | 1 |
| CSS-Bugs | 2 | 2 |
| Feldgroessen-Abweichungen | 27 | 0 (dokumentiert) |
| Strukturelle Probleme | 3 | 1 (via CSS) |
| Potentielle Risiken | 2 | 1 (via CSS) |

---

*Erstellt von Claude Code*
