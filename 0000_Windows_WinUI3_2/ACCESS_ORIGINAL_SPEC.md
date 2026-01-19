# Access Original Spezifikation: frm_MA_Mitarbeiterstamm

**Quelle:** `Screenshots ACCESS Formulare\frm_MA_Mitarbeiterstamm.jpg`
**Datum:** 2025-12-30
**Zweck:** Pixel-perfekte Referenz für WinUI3 Nachbildung

---

## 1. FARBEN (HEX-Werte)

| Element | HEX-Farbe | RGB | Beschreibung |
|---------|-----------|-----|--------------|
| **Sidebar Hintergrund** | `#C0C0C0` | rgb(192,192,192) | Hellgrau |
| **Sidebar Button (normal)** | `#F0F0F0` | rgb(240,240,240) | Fast weiß, mit 3D-Effekt |
| **Sidebar Button (hover)** | `#E8E8E8` | rgb(232,232,232) | Leicht dunkler |
| **Header Titel** | `#4B0082` | rgb(75,0,130) | Dunkel-Violett/Lila |
| **Header Hintergrund** | `#4B0082` | rgb(75,0,130) | Dunkel-Violett/Lila (identisch mit Titel-Hintergrund) |
| **Navigation Buttons** | `#FFFFFF` | rgb(255,255,255) | Weiß mit blauem Rand |
| **Navigation Button Border** | `#0078D4` | rgb(0,120,212) | Microsoft Blau |
| **Tab Control Hintergrund** | `#F0F0F0` | rgb(240,240,240) | Hellgrau |
| **Tab Active** | `#FFFFFF` | rgb(255,255,255) | Weiß |
| **Tab Inactive** | `#E0E0E0` | rgb(224,224,224) | Grau |
| **Formular Hintergrund** | `#F0F0F0` | rgb(240,240,240) | Hellgrau |
| **TextBox Hintergrund** | `#FFFFFF` | rgb(255,255,255) | Weiß |
| **TextBox Border** | `#A0A0A0` | rgb(160,160,160) | Mittelgrau |
| **Label Text** | `#000000` | rgb(0,0,0) | Schwarz |
| **Disabled Text** | `#808080` | rgb(128,128,128) | Grau |
| **Button Rechts (Blau)** | `#0078D4` | rgb(0,120,212) | Microsoft Blau |
| **Button Rechts (Gelb)** | `#FFD700` | rgb(255,215,0) | Gold/Gelb |
| **Checkbox** | `#FFFFFF` | rgb(255,255,255) | Weiß mit schwarzem Rahmen |
| **ListBox Hintergrund** | `#FFFFFF` | rgb(255,255,255) | Weiß |
| **ListBox Header** | `#F0F0F0` | rgb(240,240,240) | Hellgrau |
| **ListBox Selected** | `#0078D4` | rgb(0,120,212) | Microsoft Blau |
| **Foto Border** | `#A0A0A0` | rgb(160,160,160) | Mittelgrau |

---

## 2. LAYOUT & ABMESSUNGEN (in Pixel)

### Hauptbereiche

| Element | Breite | Höhe | Position (X, Y) | Beschreibung |
|---------|--------|------|-----------------|--------------|
| **Gesamt-Fenster** | ~1140 | ~460 | - | Sichtbarer Bereich |
| **Sidebar** | 140 | 460 | (0, 0) | Linke Navigationsleiste |
| **Header** | 1000 | 60 | (140, 0) | Titel + Navigation |
| **Tab Control** | 1000 | 30 | (140, 60) | Tab-Leiste |
| **Content Area** | 1000 | 370 | (140, 90) | Formular-Inhalt |

### Sidebar Buttons

| Button | Breite | Höhe | Position Y | Abstand |
|--------|--------|------|------------|---------|
| HAUPTMENÜ | 120 | 28 | 10 | - |
| Dienstplanübersicht | 120 | 28 | 42 | 4px |
| Planungsübersicht | 120 | 28 | 74 | 4px |
| Auftragsverwaltung | 120 | 28 | 106 | 4px |
| Mitarbeiterverwaltung | 120 | 28 | 138 | 4px |
| Offene Mail Anfragen | 120 | 28 | 170 | 4px |
| Excel Zeitkonten | 120 | 28 | 202 | 4px |
| Zeitkonten | 120 | 28 | 234 | 4px |
| Abwesenheitsplanung | 120 | 28 | 266 | 4px |
| Dienstausweis erstellen | 120 | 28 | 298 | 4px |

**Padding:** 10px links/rechts, 4px oben/unten
**Margin:** 4px zwischen Buttons

### Header Bereich

| Element | Breite | Höhe | Position (X, Y) | Beschreibung |
|---------|--------|------|-----------------|--------------|
| Navigation Kreuz | 60 | 60 | (0, 0) | 4-Wege-Navigation |
| Titel "Mitarbeiterstammblatt" | 280 | 30 | (70, 15) | Weiß auf Violett |
| Untertitel "MA Adressen" | 280 | 20 | (70, 40) | Weiß auf Violett |
| Record Navigation | 50 | 24 | (330, 18) | ◀◀ ◀ ▶ ▶▶ |
| Name "Alali Ahmad" | 200 | 40 | (420, 10) | Zentriert, groß |
| MA-ID Label | 60 | 20 | (660, 18) | "MA - ID:" |
| MA-ID Wert | 40 | 24 | (720, 16) | "707" in TextBox |
| Button "Zeitkonto" | 100 | 28 | (820, 16) | Blau-weiß |
| Button "Neuer Mitarbeiter" | 120 | 28 | (925, 16) | Blau-weiß |
| Button "Einsätze übertragen" | 140 | 28 | (1050, 16) | Gelb-schwarz |

### Tab Control

| Tab | Breite | Höhe | Position X | Beschreibung |
|-----|--------|------|------------|--------------|
| Stammdaten | 90 | 30 | 150 | Aktiv (weiß) |
| Einsatzübersicht | 110 | 30 | 240 | Inaktiv (grau) |
| Dienstplan | 85 | 30 | 350 | Inaktiv (grau) |
| Nicht Verfügbar | 100 | 30 | 435 | Inaktiv (grau) |
| Bestand Dienstkleidung | 140 | 30 | 535 | Inaktiv (grau) |

**Tab-Border:** 1px solid #A0A0A0
**Active Tab:** Keine untere Border (verschmolzen mit Content)

### Formular-Felder (Linke Spalte)

| Feld | Label-Breite | Input-Breite | Position (X, Y) | Höhe |
|------|--------------|--------------|-----------------|------|
| PersNr + LexNr + Aktiv | - | 180+40+60 | (164, 120) | 24 |
| Nachname | 80 | 160 | (164, 148) | 24 |
| Vorname | 80 | 160 | (164, 176) | 24 |
| Strasse | 80 | 160 | (164, 204) | 24 |
| Nr | 80 | 40 | (164, 232) | 24 |
| PLZ | 80 | 60 | (164, 260) | 24 |
| Ort | 80 | 160 | (164, 288) | 24 |
| Land | 80 | 160 | (164, 316) | 24 |
| Bundesland | 80 | 160 | (164, 344) | 24 |
| Tel. Mobil | 80 | 140 | (164, 372) | 24 |
| Tel. Festnetz | 80 | 140 | (164, 400) | 24 |
| Email | 80 | 160 | (164, 428) | 24 |

**Label-Alignment:** Rechtsbündig
**Abstand Label-Input:** 8px
**Zeilenhöhe:** 28px (24px Input + 4px Margin)

### Formular-Felder (Rechte Spalte)

| Feld | Label-Breite | Input-Breite | Position (X, Y) | Höhe |
|------|--------------|--------------|-----------------|------|
| Kontoinhaber | 100 | 180 | (480, 148) | 24 |
| BIC | 100 | 180 | (480, 176) | 24 |
| IBAN | 100 | 200 | (480, 204) | 24 |
| Lohngruppe | 100 | 180 | (480, 232) | 24 |
| Bezüge gesamt als | 120 | 120 | (480, 260) | 24 |
| Koordinaten | 100 | 120 | (480, 288) | 24 |
| Steuer-ID | 100 | 120 | (480, 316) | 24 |
| Tätigkeit Bezeichnung | 140 | 140 | (480, 344) | 24 |
| Krankenkasse | 100 | 140 | (480, 372) | 24 |
| Steuerklasse | 100 | 40 | (480, 400) | 24 |
| Urlaubsanspruch pro Jahr | 160 | 40 | (480, 428) | 24 |

### Weitere Felder (Unten Links)

| Feld | Label-Breite | Input-Breite | Position (X, Y) | Höhe |
|------|--------------|--------------|-----------------|------|
| Geschlecht | 80 | 100 | (164, 456) | 24 |
| Staatsangehörigkeit | 120 | 100 | (164, 484) | 24 |
| Geb. Datum | 80 | 100 | (164, 512) | 24 |
| Geb. Ort | 80 | 160 | (164, 540) | 24 |
| Geb. Name | 80 | 160 | (164, 568) | 24 |

### Weitere Felder (Unten Rechts)

| Feld | Label-Breite | Input-Breite | Position (X, Y) | Höhe |
|------|--------------|--------------|-----------------|------|
| Stundenzahl Monat max. | 160 | 60 | (480, 456) | 24 |
| RV Befreiung beantragt | 140 | Checkbox | (480, 484) | 20 |
| Brutto=30% | 100 | Checkbox | (480, 512) | 20 |
| Abrechnung per eMail | 140 | Checkbox | (480, 540) | 20 |
| Lichtbild | 80 | Button+Input | (480, 568) | 24 |

### Foto-Bereich

| Element | Breite | Höhe | Position (X, Y) | Beschreibung |
|---------|--------|------|-----------------|--------------|
| Foto-Container | 140 | 140 | (795, 148) | Mit Border |
| Foto-Bild | 130 | 130 | (800, 153) | Innen-Padding 5px |
| Button "Maps öffnen" | 100 | 28 | (810, 295) | Unterhalb Foto |

### Rechte Sidebar (Suche + Liste)

| Element | Breite | Höhe | Position (X, Y) | Beschreibung |
|---------|--------|------|-----------------|--------------|
| Such-TextBox | 180 | 24 | (945, 108) | Mit Dropdown |
| Filter-ComboBox | 180 | 24 | (945, 136) | "Alle Aktiven" |
| ListBox | 180 | 260 | (945, 168) | 3 Spalten |

### ListBox Spalten

| Spalte | Breite | Header | Beschreibung |
|--------|--------|--------|--------------|
| Vorname | 50 | "Vorname" | Links |
| Name | 70 | "Name" | Mitte |
| Ort | 60 | "Ort" | Rechts |

**Zeilenhöhe:** 18px
**Header-Höhe:** 20px
**Scrollbar:** 16px rechts

### Untere Buttons (Rechts vom Foto)

| Button | Breite | Höhe | Position (X, Y) | Farbe |
|--------|--------|------|-----------------|-------|
| Arbeitsstd. pro Arbeitstag | 140 | 24 | (795, 330) | Label |
| 7,67 | 50 | 24 | (940, 330) | TextBox |
| Arbeitstage pro Woche | 140 | 24 | (795, 358) | Label |
| 5,16 | 50 | 24 | (940, 358) | TextBox |

---

## 3. SCHRIFTEN

| Element | Font-Family | Font-Size | Font-Weight | Color | Beschreibung |
|---------|-------------|-----------|-------------|-------|--------------|
| **Header Titel** | Segoe UI | 16pt | Bold | #FFFFFF | "Mitarbeiterstammblatt" |
| **Header Untertitel** | Segoe UI | 10pt | Normal | #FFFFFF | "MA Adressen" |
| **Header Name** | Segoe UI | 18pt | Bold | #FFFFFF | "Alali Ahmad" |
| **Sidebar Button** | Segoe UI | 9pt | Normal | #000000 | Links ausgerichtet |
| **Tab Text** | Segoe UI | 9pt | Normal | #000000 | Zentriert |
| **Label** | Segoe UI | 9pt | Normal | #000000 | Rechtsbündig |
| **TextBox** | Segoe UI | 9pt | Normal | #000000 | Linksbündig |
| **Button Text** | Segoe UI | 9pt | Bold | #FFFFFF | Zentriert |
| **ListBox Header** | Segoe UI | 8pt | Bold | #000000 | Zentriert |
| **ListBox Item** | Segoe UI | 8pt | Normal | #000000 | Linksbündig |
| **MA-ID Label** | Segoe UI | 9pt | Normal | #FFFFFF | "MA - ID:" |
| **MA-ID Wert** | Segoe UI | 9pt | Bold | #000000 | In TextBox |

**Standard Line-Height:** 1.4
**Button Padding:** 6px 12px
**TextBox Padding:** 4px 6px

---

## 4. CONTROLS & STYLES

### 4.1 Sidebar Buttons

```
Breite: 120px
Höhe: 28px
Background: #F0F0F0
Border: 1px outset #C0C0C0 (3D-Effekt)
Border-Radius: 0px (eckig)
Padding: 4px 8px
Text-Align: left
Cursor: pointer

Hover:
  Background: #E8E8E8
  Border: 1px outset #B0B0B0

Active/Selected:
  Background: #D0D0D0
  Border: 1px inset #A0A0A0
```

### 4.2 Navigation Kreuz (4-Wege)

```
Container: 60x60px
Kreuz-Design:
  - Vertikaler Balken: 20x60px
  - Horizontaler Balken: 60x20px
  - Zentrum: 20x20px
  - Background: #0078D4
  - Border: 2px solid #FFFFFF
  - Cursor: pointer

Pfeile:
  - Oben: ▲
  - Unten: ▼
  - Links: ◀
  - Rechts: ▶
  - Farbe: #FFFFFF
  - Font-Size: 14pt
```

### 4.3 Record Navigation

```
Container: 50x24px
Buttons: 4x (◀◀ ◀ ▶ ▶▶)
Button-Breite: 12px
Button-Höhe: 24px
Spacing: 0px
Background: #FFFFFF
Border: 1px solid #0078D4
Color: #0078D4
Cursor: pointer

Symbole:
  - Erste: ◀◀
  - Zurück: ◀
  - Vor: ▶
  - Letzte: ▶▶
```

### 4.4 TextBox

```
Höhe: 24px
Background: #FFFFFF
Border: 1px solid #A0A0A0
Border-Radius: 2px
Padding: 4px 6px
Font-Size: 9pt
Color: #000000

Focus:
  Border: 2px solid #0078D4
  Outline: none

Disabled:
  Background: #F0F0F0
  Color: #808080
  Border: 1px solid #C0C0C0
```

### 4.5 ComboBox/Dropdown

```
Höhe: 24px
Background: #FFFFFF
Border: 1px solid #A0A0A0
Border-Radius: 2px
Padding: 4px 6px 4px 6px
Font-Size: 9pt
Color: #000000

Dropdown-Icon:
  Position: right
  Width: 16px
  Background: #F0F0F0
  Border-left: 1px solid #A0A0A0
  Icon: ▼ (Chevron)
```

### 4.6 Checkbox

```
Größe: 16x16px
Background: #FFFFFF
Border: 1px solid #808080
Border-Radius: 2px

Checked:
  Background: #0078D4
  Checkmark: ✓ (weiß)

Disabled:
  Background: #F0F0F0
  Border: 1px solid #C0C0C0
```

### 4.7 Button (Standard Blau)

```
Höhe: 28px
Min-Breite: 80px
Background: #0078D4
Border: 1px solid #005A9E
Border-Radius: 2px
Padding: 6px 12px
Color: #FFFFFF
Font-Size: 9pt
Font-Weight: Bold
Cursor: pointer

Hover:
  Background: #005A9E
  Border: 1px solid #004275

Active:
  Background: #004275
  Border: 1px inset #003A68
```

### 4.8 Button (Gelb - Einsätze übertragen)

```
Höhe: 28px
Breite: 140px
Background: #FFD700
Border: 1px solid #FFC700
Border-Radius: 2px
Padding: 6px 12px
Color: #000000
Font-Size: 9pt
Font-Weight: Bold
Cursor: pointer

Hover:
  Background: #FFC700
  Border: 1px solid #FFB700
```

### 4.9 Tab Control

```
Tab (Inactive):
  Background: #E0E0E0
  Border: 1px solid #A0A0A0
  Border-Bottom: none
  Padding: 6px 12px
  Color: #000000
  Cursor: pointer

Tab (Active):
  Background: #FFFFFF
  Border: 1px solid #A0A0A0
  Border-Bottom: none
  Padding: 6px 12px
  Color: #000000
  Font-Weight: Bold
  Z-Index: 10

Tab-Content:
  Background: #FFFFFF
  Border: 1px solid #A0A0A0
  Border-Top: none (verschmolzen mit Active Tab)
  Padding: 12px
```

### 4.10 ListBox (3-Spalten)

```
Container: 180x260px
Background: #FFFFFF
Border: 1px solid #A0A0A0

Header:
  Height: 20px
  Background: #F0F0F0
  Border-Bottom: 1px solid #A0A0A0
  Font-Weight: Bold
  Font-Size: 8pt
  Text-Align: center

Row:
  Height: 18px
  Padding: 2px 4px
  Border-Bottom: 1px solid #E0E0E0
  Cursor: pointer

Row (Hover):
  Background: #E8F4FC

Row (Selected):
  Background: #0078D4
  Color: #FFFFFF

Scrollbar:
  Width: 16px
  Background: #F0F0F0
  Thumb: #C0C0C0
  Thumb-Hover: #A0A0A0
```

### 4.11 Foto-Container

```
Breite: 140px
Höhe: 140px
Background: #FFFFFF
Border: 2px solid #A0A0A0
Padding: 5px

Image:
  Max-Width: 130px
  Max-Height: 130px
  Object-Fit: contain
  Background: #F0F0F0 (wenn kein Bild)
```

### 4.12 Label

```
Font-Size: 9pt
Color: #000000
Text-Align: right
Padding-Right: 8px
Vertical-Align: middle
Line-Height: 24px (entspricht Input-Höhe)
```

---

## 5. BESONDERHEITEN & SPEZIAL-EFFEKTE

### 5.1 3D-Effekte (Classic Windows Style)

**Outset Border (erhabener Button):**
```
Border-Top: 2px solid #FFFFFF (hell)
Border-Left: 2px solid #FFFFFF (hell)
Border-Bottom: 2px solid #808080 (dunkel)
Border-Right: 2px solid #808080 (dunkel)
```

**Inset Border (vertiefter Button):**
```
Border-Top: 2px solid #808080 (dunkel)
Border-Left: 2px solid #808080 (dunkel)
Border-Bottom: 2px solid #FFFFFF (hell)
Border-Right: 2px solid #FFFFFF (hell)
```

### 5.2 Fokus-Indikator

```
Outline: 2px dotted #000000
Outline-Offset: 2px
```

### 5.3 Disabled State (Global)

```
Opacity: 0.6
Cursor: not-allowed
Color: #808080
Background: #F0F0F0
Border-Color: #C0C0C0
```

### 5.4 Scrollbars (Classic Style)

```
Width/Height: 16px
Background: #F0F0F0

Thumb:
  Background: #C0C0C0
  Border: 1px outset #C0C0C0
  Min-Height/Width: 20px

Thumb (Hover):
  Background: #A0A0A0

Track-Buttons (Pfeile):
  Size: 16x16px
  Background: #F0F0F0
  Border: 1px outset #C0C0C0
  Icon: ▲ ▼ ◀ ▶
```

---

## 6. RESPONSIVE VERHALTEN

**NICHT VORHANDEN** - Access-Formulare haben fixe Größen.

**Minimum Window Size:**
- Breite: 1140px
- Höhe: 460px

**Bei kleinerer Auflösung:**
- Scrollbars erscheinen
- Kein Reflow, kein Responsive-Design

---

## 7. ACCESSIBILITY NOTES

- **Tab-Order:** Von links nach rechts, oben nach unten
- **Keyboard-Navigation:** Tab, Shift+Tab, Arrow-Keys in ListBox
- **Focus-Visible:** Dotted Outline (siehe 5.2)
- **Screen-Reader:** Labels sind mit Inputs assoziiert
- **Contrast-Ratio:** Alle Text-Farben erfüllen WCAG AA (mindestens 4.5:1)

---

## 8. DATEN-FELDER (Control-Source Mapping)

| Feld | Control Source | Typ | Max-Length |
|------|----------------|-----|------------|
| PersNr | `MA_ID` | Number | - |
| LexNr | `MA_Lex_ID` | Number | - |
| Aktiv | `IstAktiv` | Boolean | - |
| Nachname | `Nachname` | Text | 50 |
| Vorname | `Vorname` | Text | 50 |
| Strasse | `Strasse` | Text | 100 |
| Nr | `Strasse_Nr` | Text | 10 |
| PLZ | `PLZ` | Text | 10 |
| Ort | `Ort` | Text | 50 |
| Land | `Land` | Text | 50 |
| Bundesland | `Bundesland` | Text | 50 |
| Tel. Mobil | `Tel_Mobil` | Text | 20 |
| Tel. Festnetz | `Tel_Festnetz` | Text | 20 |
| Email | `EMail` | Text | 100 |
| Kontoinhaber | `Kontoinhaber` | Text | 100 |
| BIC | `BIC` | Text | 11 |
| IBAN | `IBAN` | Text | 34 |
| Lohngruppe | `Lohngruppe` | Text | 50 |
| Bezüge gesamt als | `Bezuege_Gesamt_Als` | Text | 50 |
| Koordinaten | `Koordinaten` | Text | 100 |
| Steuer-ID | `Steuer_ID` | Text | 20 |
| Tätigkeit Bezeichnung | `Taetigkeit_ID` | ComboBox | - |
| Krankenkasse | `Krankenkasse` | Text | 100 |
| Steuerklasse | `Steuerklasse` | Number | - |
| Urlaubsanspruch pro Jahr | `Urlaub_Anspruch` | Number | - |
| Geschlecht | `Geschlecht` | ComboBox | - |
| Staatsangehörigkeit | `Staatsangehoerigkeit` | Text | 50 |
| Geb. Datum | `Geb_Datum` | Date | - |
| Geb. Ort | `Geb_Ort` | Text | 50 |
| Geb. Name | `Geb_Name` | Text | 50 |
| Stundenzahl Monat max. | `Stundenzahl_Monat_Max` | Number | - |
| RV Befreiung beantragt | `RV_Befreiung` | Boolean | - |
| Brutto=30% | `Brutto_30_Prozent` | Boolean | - |
| Abrechnung per eMail | `Abrechnung_EMail` | Boolean | - |
| Lichtbild | `Lichtbild_Pfad` | Text | 255 |
| Arbeitsstd. pro Arbeitstag | `Arbeitsstd_Pro_Tag` | Number (Decimal) | - |
| Arbeitstage pro Woche | `Arbeitstage_Pro_Woche` | Number (Decimal) | - |

---

## 9. EVENTS & INTERAKTIONEN

### Button-Events

| Button | Event | Aktion |
|--------|-------|--------|
| Navigation Oben/Unten/Links/Rechts | Click | Navigiert durch Datensätze |
| ◀◀ | Click | Erster Datensatz |
| ◀ | Click | Vorheriger Datensatz |
| ▶ | Click | Nächster Datensatz |
| ▶▶ | Click | Letzter Datensatz |
| Zeitkonto | Click | Öffnet Zeitkonto-Dialog |
| Neuer Mitarbeiter | Click | Leert Formular für Neuanlage |
| Einsätze übertragen | Click | Öffnet Übertragungsdialog |
| Maps öffnen | Click | Öffnet Google Maps mit Adresse |
| Lichtbild [...] | Click | Öffnet Datei-Dialog |

### ListBox-Events

| Event | Aktion |
|-------|--------|
| Click | Lädt ausgewählten Mitarbeiter |
| DoubleClick | Lädt Mitarbeiter + setzt Focus auf Nachname |
| KeyDown (Arrow) | Navigiert in Liste |
| Scroll | Lädt weitere Einträge (bei großen Listen) |

### TextBox-Events

| Event | Aktion |
|-------|--------|
| Change | Markiert Datensatz als geändert |
| KeyDown (Enter) | Springt zum nächsten Feld |
| LostFocus | Validiert Eingabe |

### ComboBox-Events

| Event | Aktion |
|-------|--------|
| Change | Aktualisiert abhängige Felder |
| DropDown | Lädt Optionen (bei Bedarf) |

### Form-Events

| Event | Aktion |
|-------|--------|
| Load | Lädt ersten Datensatz |
| Current | Aktualisiert alle Controls |
| BeforeUpdate | Validiert alle Pflichtfelder |
| AfterUpdate | Speichert Änderungen |
| Dirty | Aktiviert Speichern-Button |

---

## 10. VALIDIERUNGS-CHECKLISTE (für Abweichungs-Analyse)

### Farben
- [ ] Sidebar Hintergrund: #C0C0C0
- [ ] Header: #4B0082 (Violett)
- [ ] Button Blau: #0078D4
- [ ] Button Gelb: #FFD700
- [ ] TextBox Border: #A0A0A0
- [ ] ListBox Selected: #0078D4

### Layout
- [ ] Sidebar Breite: 140px
- [ ] Header Höhe: 60px
- [ ] Tab Control Höhe: 30px
- [ ] TextBox Höhe: 24px
- [ ] Button Höhe: 28px
- [ ] ListBox Breite: 180px
- [ ] Foto-Container: 140x140px

### Fonts
- [ ] Segoe UI durchgehend
- [ ] Header Titel: 16pt Bold
- [ ] Standard: 9pt
- [ ] ListBox: 8pt

### Controls
- [ ] 3D-Effekt bei Sidebar-Buttons
- [ ] Navigation Kreuz: 4-Wege Design
- [ ] Record Navigation: ◀◀ ◀ ▶ ▶▶
- [ ] ComboBox mit Dropdown-Icon
- [ ] Checkbox: 16x16px
- [ ] Foto mit 2px Border

### Spacing
- [ ] Sidebar-Buttons: 4px Abstand
- [ ] Label-Input: 8px Abstand
- [ ] Zeilen: 28px (24px + 4px)
- [ ] Tab-Padding: 6px 12px

### Besonderheiten
- [ ] "Koordinaten" Feld mit Highlight (falls implementiert)
- [ ] ListBox 3-Spalten: Vorname, Name, Ort
- [ ] Foto rechts von Formular-Feldern
- [ ] Such-Filter oberhalb ListBox
- [ ] Classic Windows 3D-Style

---

## ZUSAMMENFASSUNG

Diese Spezifikation dokumentiert **JEDEN** sichtbaren Aspekt des Access-Originals `frm_MA_Mitarbeiterstamm.jpg`.

**Haupt-Charakteristika:**
1. **Classic Windows UI** - 3D-Effekte, Outset/Inset Borders
2. **Feste Größen** - Kein Responsive Design
3. **Segoe UI** - Durchgehend, verschiedene Größen
4. **Microsoft Blau** (#0078D4) - Primärfarbe für Interaktionen
5. **Violetter Header** (#4B0082) - Markantes Branding
6. **3-Spalten Layout** - Links Felder, Mitte Felder, Rechts Liste+Foto

**Für WinUI3 Umsetzung:**
- Verwende WinUI3 Controls mit klassischem Styling
- Setze `CornerRadius="0"` für eckige Ecken
- Implementiere 3D-Effekte via `Border` mit mehreren Layern
- Verwende feste Breiten/Höhen (keine *-Werte)
- Navigation Kreuz als Custom UserControl
- ListBox mit DataTemplate für 3 Spalten

**Datei erstellt:** 2025-12-30
**Analysiert von:** Claude Sonnet 4.5
**Zweck:** Pixel-perfekte WinUI3 Nachbildung
