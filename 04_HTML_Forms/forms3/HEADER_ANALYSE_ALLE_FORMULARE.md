# Header-Analyse aller HTML-Hauptformulare

**Analysezeitpunkt:** 2026-01-15
**Analysierte Formulare:** 12 Hauptformulare
**Pfad:** `04_HTML_Forms/forms3/`

---

## 1. Übersichtstabelle aller Header-Properties

| Formular | CSS-Klasse | Hintergrundfarbe | Höhe | Titel (Font-Size) | Button-Anordnung |
|----------|-----------|------------------|------|-------------------|------------------|
| **frm_va_Auftragstamm** | `.header-row` | `#d3d3d3` | Auto | 23px (Bold, #000080) | Links: Logo + Titel, Rechts: Datum |
| **frm_MA_Mitarbeiterstamm** | `.header-row` | `#d3d3d3` | Auto | 23px (Bold, #000080) | Links: Logo + Titel, Rechts: Datum |
| **frm_KD_Kundenstamm** | `.header-row` | `#d3d3d3` | Auto | 23px (Bold, #000080) | Links: Logo + Titel, Rechts: Datum |
| **frm_OB_Objekt** | `.header-row` | `#d3d3d3` | Auto | 23px (Bold, #000080) | Links: Logo + Titel + Links, Rechts: Datum |
| **frm_DP_Dienstplan_MA** | `.form-header` | `#d3d3d3` | 88px | 14px (Bold, #fff) | Dunkelrot-Header mit Datum-Controls |
| **frm_DP_Dienstplan_Objekt** | `.form-header` | `#d3d3d3` | 70px | 22px (Bold, #000080) | Datum-Controls + Filter-Checkboxen |
| **frm_MA_Abwesenheit** | `.form-header` | `#d3d3d3` | Auto | 22px (Bold, White) | Rechts: Icon-Button |
| **frm_MA_Zeitkonten** | `.app-header` | Gradient (Blau) | Auto | 23px (Bold, White) | Gradient-Header mit Toolbar darunter |
| **frm_N_Bewerber** | `.header-bar` | Gradient (Blau) | Auto | 22px (Bold, White) | Gradient-Header mit Toolbar |
| **frm_Abwesenheiten** | `.app-header` | Gradient (Blau) | Auto | 16px (Bold, #000080) | Standard-Header mit Toolbar |
| **frm_Kundenpreise_gueni** | `.toolbar` | `#9090c0` | Auto | 16px (Bold, #000080) | Toolbar statt Header |
| **frm_MA_VA_Schnellauswahl** | `.title-bar` | Gradient (Blau) | Auto | 14px (Bold, White) | Gradient-Header mit Center-Title |

---

## 2. Screenshot-Beschreibungen der Header

### 2.1 Standard-Header (Grau-Design)
**Formulare:** frm_va_Auftragstamm, frm_MA_Mitarbeiterstamm, frm_KD_Kundenstamm, frm_OB_Objekt

**Aussehen:**
```
┌─────────────────────────────────────────────────────────────┐
│ [Logo-Box: 36x36px] Formulartitel (23px Bold #000080)      │
│                                               15.01.2026    │
└─────────────────────────────────────────────────────────────┘
```

**Details:**
- Hintergrund: `#d3d3d3` (Hellgrau)
- Logo-Box: 36x36px, Gradient Lila-Blau
- Titel: 23px (!), Bold, Dunkelblau (#000080)
- Datum rechts: 10px, Dunkelblau
- Padding: 4px 8px

**Besonderheit frm_OB_Objekt:**
- Zusätzliche Links nach dem Titel:
  - "Aufträge zu Objekt"
  - "Positionen"
  - Font-Size: 10px, underline, #000080

### 2.2 Dienstplan-Header (Funktions-Design)
**Formulare:** frm_DP_Dienstplan_MA, frm_DP_Dienstplan_Objekt

**Aussehen frm_DP_Dienstplan_MA:**
```
┌─────────────────────────────────────────────────────────────────┐
│ Dienstplanübersicht   [KW:__] [Datum] [<][>]  [Filter]  [...]  │
│                                                     1 | V1.55    │
└─────────────────────────────────────────────────────────────────┘
```

**Details:**
- Höhe: 88px (!)
- Hintergrund: `#d3d3d3`
- Titel: 14px (Klein!), Bold, #ffffff (!!)
- Viele Controls: KW-Dropdown, Datum-Picker, Vor/Zurück-Buttons
- MA-Filter-ComboBox
- Buttons: "Dienstpläne senden bis", "Einzeldienstpläne", "Übersicht drucken"
- Version-Label rechts oben

**Aussehen frm_DP_Dienstplan_Objekt:**
```
┌─────────────────────────────────────────────────────────────────┐
│ Planungsübersicht  [KW:__][Datum][<][>] [Heute]  [Filter-Checks] │
│                                                    [Drucken] [X] │
└─────────────────────────────────────────────────────────────────┘
```

**Details:**
- Höhe: 70px
- Titel: 22px, Bold, #000080
- Datum-Controls ähnlich wie MA-Dienstplan
- Filter-Checkboxen: "Nur freie Schichten", "Nur Aufträge mit < X Positionen"

### 2.3 Gradient-Header (Modern-Design)
**Formulare:** frm_MA_Zeitkonten, frm_N_Bewerber, frm_MA_VA_Schnellauswahl

**Aussehen:**
```
┌─────────────────────────────────────────────────────────────┐
│ ████████████ Formulartitel ████████████████     15.01.2026 │
│    (Gradient: #000080 → #1084d0)                           │
└─────────────────────────────────────────────────────────────┘
```

**Details:**
- Hintergrund: `linear-gradient(to right, #000080, #1084d0)`
- Titel: 22-23px, Bold, White
- Datum rechts: White
- Padding: 6-8px 12px
- Wirkt modern und hochwertig

**Besonderheit frm_MA_VA_Schnellauswahl:**
- Titel zentriert (absolut)
- Links: Icon/Logo
- Rechts: Datum + Window-Buttons (Minimieren, Maximieren, Schließen)

### 2.4 Toolbar-Header (Hybrid-Design)
**Formulare:** frm_Kundenpreise_gueni, frm_Abwesenheiten

**Aussehen:**
```
┌─────────────────────────────────────────────────────────────┐
│ Kundenpreise Verwaltung  [Filter] [Button] [Button] [...]  │
└─────────────────────────────────────────────────────────────┘
```

**Details:**
- Hintergrund: `#9090c0` (Lila) oder `#d3d3d3` (Grau)
- Titel: 16px, Bold, #000080
- Titel und Buttons in einer Zeile
- Keine separate Header-Section

### 2.5 Minimal-Header (Nur Titel)
**Formular:** frm_MA_Abwesenheit

**Aussehen:**
```
┌─────────────────────────────────────────────────────────────┐
│ Abwesenheitsplanung                              [Icon]    │
└─────────────────────────────────────────────────────────────┘
```

**Details:**
- Hintergrund: `#d3d3d3`
- Titel: 22px, Bold, White
- Nur ein Icon-Button rechts
- Sehr minimalistisch

---

## 3. Formulartitel-Analyse

| Formular | Titel-Text | Font-Size | Font-Weight | Color | CSS-Klasse |
|----------|-----------|-----------|-------------|-------|-----------|
| frm_va_Auftragstamm | Auftragsstammdaten | 23px | Bold | #000080 | `.title-text` |
| frm_MA_Mitarbeiterstamm | Mitarbeiterstamm | 23px | Bold | #000080 | `.title-text` |
| frm_KD_Kundenstamm | Kundenstamm | 23px | Bold | #000080 | `.title-text` |
| frm_OB_Objekt | Objektstammdaten | 23px | Bold | #000080 | `.title-text` |
| frm_DP_Dienstplan_MA | Dienstplanübersicht | 14px | Bold | #ffffff | `#Bezeichnungsfeld96` |
| frm_DP_Dienstplan_Objekt | Planungsübersicht | 22px | Bold | #000080 | `.header-title` |
| frm_MA_Abwesenheit | Abwesenheitsplanung | 22px | Bold | White | `.form-header` (Inline) |
| frm_MA_Zeitkonten | Mitarbeiter-Zeitkonten | 23px | Bold | White | `.app-title` |
| frm_N_Bewerber | Bewerberverwaltung | 22px | Bold | White | `.header-bar` (Inline) |
| frm_Abwesenheiten | Abwesenheitsübersicht | 16px | Bold | #000080 | `.app-title` (H1) |
| frm_Kundenpreise_gueni | Kundenpreise Verwaltung | 16px | Bold | #000080 | `.toolbar-title` |
| frm_MA_VA_Schnellauswahl | Mitarbeiter Auswahl - Offene Mail Anfragen | 14px | Bold | White | `.title-bar-title` |

**Wichtiger Hinweis:**
Die Anforderung "+8px" wurde in den meisten Formularen umgesetzt (23px statt 15px), aber **NICHT KONSISTENT**:
- ✅ Konsistent 23px: Auftragstamm, Mitarbeiterstamm, Kundenstamm, Objekt, Zeitkonten
- ⚠️ 22px: Dienstplan_Objekt, Abwesenheit, Bewerber (nah dran)
- ❌ Zu klein: Dienstplan_MA (14px), Abwesenheiten (16px), Kundenpreise (16px), Schnellauswahl (14px)

---

## 4. Button-Typen im Header

### 4.1 Häufig vorkommende Buttons

| Button-Typ | Vorkommen | CSS-Klasse | Farbe |
|-----------|-----------|-----------|-------|
| **Navigation (|< < > >|)** | 8x | `.nav-btn` | Standard-Grau |
| **+ Neu** | 7x | `.btn-green` | Grün-Gradient |
| **Speichern** | 6x | `.btn-yellow` oder `.btn-primary` | Gelb/Blau |
| **Löschen** | 6x | `.btn-red` | Rot-Gradient |
| **Aktualisieren** | 4x | `.btn` | Standard-Grau |
| **Filter/Suche** | 5x | `.form-control` (ComboBox/Input) | - |
| **Drucken/Excel** | 4x | `.btn` oder `.btn-blue` | Standard/Blau |
| **Schließen (X)** | 3x | `.title-btn.close` oder `.header-btn-close` | Rot (#c75050) |
| **Hilfe (?)** | 2x | `.btn` | Standard-Grau |
| **Vollbild** | Alle | `.fullscreen-btn` (Fixed) | Standard-Grau |

### 4.2 Button-Anordnung

**Links-Anordnung (Häufig):**
- Logo/Icon
- Formulartitel
- Inline-Links (nur frm_OB_Objekt)
- Navigation-Buttons (bei Stammdaten-Formularen)

**Mitte-Anordnung (Selten):**
- Datum-Controls (Dienstplan-Formulare)
- Filter-Controls (Dienstplan-Objekt)

**Rechts-Anordnung (Immer):**
- Datum (statisch)
- Export-Buttons (optional)
- Schließen-Button (optional)
- Vollbild-Button (fixed, top-right)

---

## 5. Abweichungen vom Standard

### 5.1 frm_DP_Dienstplan_MA
**Besonderheiten:**
- Höchster Header: 88px (!)
- Viele Controls im Header (normalerweise in Toolbar)
- Titel zu klein (14px statt 23px)
- Titel weiß (#ffffff) statt dunkelblau (#000080)
- Version-Label im Header
- Enddatum-Feld im Header

### 5.2 frm_DP_Dienstplan_Objekt
**Besonderheiten:**
- Filter-Checkboxen im Header (nicht in Toolbar)
- Checkbox-Labels mit Input-Feldern kombiniert
- "Nur Aufträge mit < X Positionen" - dynamischer Filter

### 5.3 frm_OB_Objekt
**Besonderheiten:**
- Inline-Links direkt nach dem Titel
- Links öffnen andere Bereiche/Formulare
- Unterstrichen und klickbar

### 5.4 frm_MA_VA_Schnellauswahl
**Besonderheiten:**
- Titel zentriert (nicht links)
- Window-Buttons im Header (Minimieren, Maximieren, Schließen)
- Ähnelt Windows-Fenster-Design

### 5.5 frm_Kundenpreise_gueni & frm_Abwesenheiten
**Besonderheiten:**
- Kein separater Header - Toolbar fungiert als Header
- Titel und Buttons in einer Zeile
- Platzsparender

---

## 6. CSS-Klassen-Konsistenz

### 6.1 Verwendete Header-Klassen

| CSS-Klasse | Verwendung | Formulare |
|-----------|-----------|-----------|
| `.header-row` | Standard-Header (Grau) | Auftragstamm, Mitarbeiterstamm, Kundenstamm, Objekt |
| `.form-header` | Funktions-Header (Dienstplan) | DP_Dienstplan_MA, DP_Dienstplan_Objekt, MA_Abwesenheit |
| `.app-header` | Gradient-Header (Modern) | MA_Zeitkonten, Abwesenheiten |
| `.header-bar` | Gradient-Header (Bewerber) | N_Bewerber |
| `.title-bar` | Windows-Style Header | MA_VA_Schnellauswahl |
| `.toolbar` | Toolbar als Header | Kundenpreise_gueni |

**Problem:** Zu viele verschiedene CSS-Klassen für den gleichen Zweck (Header).

### 6.2 Verwendete Titel-Klassen

| CSS-Klasse | Font-Size | Color | Verwendung |
|-----------|-----------|-------|-----------|
| `.title-text` | 23px | #000080 | Standard (4x) |
| `.header-title` | 22px | #000080 | DP_Dienstplan_Objekt |
| `.app-title` | 23px | White | MA_Zeitkonten |
| `.toolbar-title` | 16px | #000080 | Kundenpreise_gueni |
| `#Bezeichnungsfeld96` | 14px | #ffffff | DP_Dienstplan_MA |
| `.title-bar-title` | 14px | White | MA_VA_Schnellauswahl |
| `.header-bar` (inline) | 22px | White | N_Bewerber |

**Problem:** Inkonsistente Benennung und Font-Sizes.

---

## 7. Empfehlungen für einheitliches Design

### 7.1 Standard-Header-Design (Empfohlen)

**Basis:**
```css
.form-header {
    background-color: #d3d3d3;
    border-bottom: 1px solid #606090;
    padding: 8px 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: auto;
}

.form-header-title {
    font-size: 23px !important; /* +8px erfüllt */
    font-weight: bold !important;
    color: #000080;
}

.form-header-date {
    font-size: 10px;
    color: #000080;
}
```

**Logo (optional):**
```css
.form-header-logo {
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, #4040a0, #8080c0);
    border: 2px solid #404080;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: bold;
    font-size: 16px;
    margin-right: 10px;
}
```

### 7.2 Alternative: Gradient-Header (Modern)

**Für neue Formulare oder Redesign:**
```css
.form-header-gradient {
    background: linear-gradient(to right, #000080, #1084d0);
    color: white;
    padding: 8px 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.form-header-gradient .form-header-title {
    font-size: 23px !important;
    font-weight: bold !important;
    color: white;
}
```

### 7.3 Button-Konsistenz

**Standard-Buttons:**
```css
.btn-header {
    background: linear-gradient(to bottom, #d0d0e0, #a0a0c0);
    border: none;
    padding: 4px 12px;
    font-size: 11px;
    cursor: pointer;
    white-space: nowrap;
}

.btn-header-green {
    background: linear-gradient(to bottom, #90c090, #60a060);
    color: white;
}

.btn-header-red {
    background: linear-gradient(to bottom, #c09090, #a06060);
    color: white;
}

.btn-header-blue {
    background: linear-gradient(to bottom, #9090c0, #6060a0);
    color: white;
}
```

### 7.4 Vereinheitlichungs-Maßnahmen

**Phase 1: CSS-Klassen vereinheitlichen**
- Alle Header auf `.form-header` umstellen
- Alle Titel auf `.form-header-title` umstellen
- Einheitliche Font-Size: 23px (erfüllt "+8px")

**Phase 2: Layout vereinheitlichen**
- Logo links (optional)
- Titel links neben Logo
- Datum rechts
- Buttons zwischen Titel und Datum (optional)

**Phase 3: Sonderfälle behandeln**
- Dienstplan-Formulare: Controls in separate Toolbar verschieben
- Objektformular: Links als Unterzeile oder in Toolbar

**Phase 4: Farb-Konsistenz**
- Standard: Grau-Header (#d3d3d3) + Dunkelblauer Titel (#000080)
- Alternative: Gradient-Header (Blau) + Weißer Titel
- KEINE Mischformen

---

## 8. Priorisierte Änderungsliste

### 8.1 Kritisch (Sofort)
1. **frm_DP_Dienstplan_MA**: Titel von 14px auf 23px erhöhen
2. **frm_DP_Dienstplan_MA**: Titel-Farbe von #ffffff auf #000080 ändern (oder Gradient-Header)
3. **frm_Kundenpreise_gueni**: Titel von 16px auf 23px erhöhen
4. **frm_Abwesenheiten**: Titel von 16px auf 23px erhöhen
5. **frm_MA_VA_Schnellauswahl**: Titel von 14px auf 23px erhöhen

### 8.2 Wichtig (Kurzfristig)
6. Alle Header-CSS-Klassen auf `.form-header` vereinheitlichen
7. Alle Titel-CSS-Klassen auf `.form-header-title` vereinheitlichen
8. Button-Positionen standardisieren (Logo-Titel-Datum-Layout)

### 8.3 Optional (Langfristig)
9. Dienstplan-Formulare: Controls aus Header in Toolbar verschieben
10. Alle Formulare auf Gradient-Header umstellen (Modern-Look)
11. Logo-Box für alle Formulare hinzufügen (Corporate Identity)

---

## 9. Zusammenfassung

**Status Quo:**
- 12 analysierte Hauptformulare
- 6 verschiedene Header-CSS-Klassen
- 7 verschiedene Titel-CSS-Klassen
- Font-Sizes: 14px bis 23px (Soll: 23px)
- 3 Haupt-Design-Varianten (Grau-Standard, Gradient-Modern, Toolbar-Hybrid)

**Stärken:**
- Viele Formulare haben bereits 23px Titel (Anforderung erfüllt)
- Grau-Header-Design ist konsistent bei 4 Stammdaten-Formularen
- Gradient-Header wirkt modern und hochwertig

**Schwächen:**
- Inkonsistente CSS-Klassen-Namen
- 4 Formulare haben zu kleine Titel (14-16px)
- Dienstplan-Formulare überladen (zu viele Controls im Header)
- Keine einheitliche Button-Anordnung

**Empfehlung:**
1. Standard-Header-Design (Grau, 23px Titel) für alle Stammdaten-Formulare
2. Gradient-Header-Design (Blau, 23px Titel) für moderne/neue Formulare
3. CSS-Klassen vereinheitlichen (`.form-header` + `.form-header-title`)
4. Dienstplan-Formulare: Controls in separate Toolbar auslagern

---

**Stand:** 2026-01-15
**Nächste Schritte:**
1. Kritische Änderungen umsetzen (Font-Sizes anpassen)
2. CSS-Klassen vereinheitlichen (`.form-header` einführen)
3. Design-Guideline erstellen (für neue Formulare)
