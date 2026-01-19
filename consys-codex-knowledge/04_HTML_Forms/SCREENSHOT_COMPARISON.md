# 📊 Vergleich: Original Access-Formular vs. HTML-Version

## Aktueller Status: VISUELLER VERGLEICH

**Datum:** 2024-12-25  
**Datei:** frm_MA_Mitarbeiterstamm.html  
**Ziel:** 1:1 optischer Abgleich mit Original

---

## 📸 ANALYSE: Bekannte Unterschiede vom Original

### ✅ KORREKT IMPLEMENTIERT:

#### 1. **Header-Bereich**
- [x] Höhe: 94px ✓
- [x] Farbe: #D0D0D0 (grau) ✓
- [x] Navigation: Pfeile (◄◄ ◄ ► ►►) oben links ✓
- [x] Titel: "Mitarbeiterstammblatt" zentriert ✓
- [x] Buttons rechts: Dienstplan, Einsatzübersicht, Karte, Zeitkonto ✓
- [x] MA-Nr Eingabe oben rechts ✓
- [x] MA löschen / Neuer MA Buttons ✓

#### 2. **Employee-Info Box**
- [x] Höhe: 42px ✓
- [x] Farbe: #D0D0D0 ✓
- [x] Text: Nachname + Vorname angezeigt ✓

#### 3. **Tab-System**
- [x] 13 Tabs sichtbar ✓
- [x] "Stammdaten" ist aktiv (weiß) ✓
- [x] Andere Tabs: grau (#CCCCCC) ✓
- [x] Hover-Effect: helleres Grau ✓

#### 4. **Spalten-Layout (Stammdaten)**
- [x] 3 Spalten nebeneinander ✓
- [x] Spalte 1: PersNr, LexNr, Aktiv ☑, Name, Adresse, Kontakt, Personal-Daten ✓
- [x] Spalte 2: Konto, Lohn, Steuern, Versicherung, Unterschriften ✓
- [x] Spalte 3: Arbeitszeiten, Ausweis-Daten ✓
- [x] Checkboxes in Spalten integriert (nicht oben) ✓

#### 5. **Feldformatierung**
- [x] Label-Breite: 105px ✓
- [x] Label rechtsausgerichtet ✓
- [x] Input-Höhe: 16px ✓
- [x] Font-Größe: 8px ✓
- [x] Focus-State: Blauer Border + gelber Hintergrund ✓

#### 6. **Employee-Liste (rechts)**
- [x] Breite: 280px ✓
- [x] Suchfeld vorhanden ✓
- [x] Filter-Dropdown (Alle Aktiven/Alle/Inaktive) ✓
- [x] Tabelle: Nachname | Vorname | Ort ✓
- [x] Hover: Hellgrün (#E8F4E8) ✓
- [x] Selected: Blau (#4A90D9) mit weißem Text ✓

#### 7. **Photo-Sektion**
- [x] Größe: 92×120px ✓
- [x] Position: Absolut, rechts 285px vom linken Rand ✓
- [x] Border: 2px solid #999 ✓
- [x] Button: "Karte öffnen" (grün) ✓

#### 8. **Status-Bar (unten)**
- [x] Höhe: 16px ✓
- [x] Farbe: #EFEFEF ✓
- [x] Text: "Erstellt: ... | Geändert: ..." ✓
- [x] Font-Größe: 7px ✓

---

## ⚠️ MÖGLICHE FEINABSTIMMUNGEN:

### 1. **Visuelle Unterschiede (zu prüfen per Screenshot):**

- [ ] **Button-Größen**: Sind die Button-Größen exakt? (2px 6px padding?)
- [ ] **Spalten-Breiten**: Sind die 3 Spalten gleich breit?
- [ ] **Schrift-Rendering**: Tahoma-Font korrekt geladen?
- [ ] **Abstände zwischen Feldern**: 0px Gap vs. 1px?
- [ ] **Scroll-Balken**: Styling der Scroll-Balken sichtbar?
- [ ] **Grau-Töne**: Sind die Grau-Abstufungen korrekt?
  - Header: #D0D0D0 ✓
  - Tab-Header: #CCCCCC ✓
  - Employee-List Border: #888 ✓
  - Status-Bar: #EFEFEF ✓

### 2. **Potenzielle CSS-Adjustments:**

#### Button-Styling:
```css
/* Aktuell */
.header-btn { padding: 2px 6px; font-size: 8px; }

/* Falls nötig: */
.header-btn { padding: 2px 5px; font-size: 7px; } /* Kompakter */
```

#### Label-Padding:
```css
/* Aktuell */
.form-label { padding-right: 5px; width: 105px; }

/* Falls nötig: */
.form-label { padding-right: 6px; width: 110px; } /* Größer */
```

#### Tab-Header-Padding:
```css
/* Aktuell */
.tab-header { padding: 3px 10px; }

/* Falls nötig: */
.tab-header { padding: 2px 8px; } /* Kompakter */
```

#### Form-Row Höhe:
```css
/* Aktuell */
.form-row { height: 19px; }

/* Falls nötig: */
.form-row { height: 20px; } /* Größer */
```

---

## 🔍 SCREENSHOT-VALIDIERUNGSPUNKTE:

### Header prüfen:
1. Pfeile: 16×16px, korrekt spaced?
2. Titel-Schrift: Größe und Farbe korrekt?
3. Buttons: Größe, Abstände, Farben (#C0A080)?
4. MA-Nr Input: Breite 45px, Höhe 16px?
5. Gesamt-Höhe: 94px?

### Formular prüfen:
1. Spalten: Gleich breit, proportional?
2. Labels: Rechts aligned, Breite 105px?
3. Inputs: Höhe 16px, Border #999?
4. Checkboxes: 12×12px, alignment korrekt?
5. Abstände: Gap 10px zwischen Spalten?

### Listen prüfen:
1. Employee-List: 280px breit?
2. Suchfeld: Funktional, Höhe 15px?
3. Tabelle: 3 Spalten, lesbar?
4. Scroll: Funktional, Border sichtbar?

### Farben prüfen:
1. Header: #D0D0D0 (grau)?
2. Tabs: #CCCCCC (heller grau)?
3. Active Tab: weiß?
4. Borders: #999 und #888?
5. Buttons: #C0A080 (beige), #4169E1 (blau), #7CFC00 (grün)?

### Status-Bar prüfen:
1. Höhe: 16px?
2. Farbe: #EFEFEF?
3. Text lesbar, Größe 7px?
4. Alignment: Space-between?

---

## 📋 CHECKLISTE FÜR SCREENSHOT-VERGLEICH:

### Vergleich durchführen:

1. **Screenshot des aktuellen HTML machen**
   - Browser-Fenster: 1280×800 (Standard)
   - Zoom: 100%
   - Speichern als: `frm_MA_Mitarbeiterstamm_AKTUELL.jpg`

2. **Mit Original vergleichen**
   - Original-Datei: `frm_MA_Mitarbeiterstamm.jpg`
   - Neue Datei: `frm_MA_Mitarbeiterstamm_AKTUELL.jpg`
   - Side-by-side Vergleich

3. **Abweichungen dokumentieren**
   - Position: Sind Elemente gleich positioniert?
   - Größe: Sind Abstände gleich?
   - Farbe: Sind RGB-Werte gleich?
   - Font: Ist Schrift identisch?

4. **Adjustments durchführen**
   - CSS bei Bedarf justieren
   - Neue Screenshot machen
   - Erneut vergleichen

---

## ✨ FINALE VALIDIERUNGSZIELE:

- [ ] Header: Optisch identisch
- [ ] Tabs: Optisch identisch
- [ ] Spalten: Optisch identisch
- [ ] Listen: Optisch identisch
- [ ] Farben: Exakt abgestimmt
- [ ] Abstände: Pixel-perfekt
- [ ] Fonts: Korrekt geladen
- [ ] Buttons: Optisch identisch
- [ ] Status-Bar: Optisch identisch

**Status:** 🟡 **BEREIT FÜR SCREENSHOT-VERGLEICH**

---

## 📌 NÄCHSTE SCHRITTE:

1. **Screenshot machen** (Browser-Version)
2. **Mit Original vergleichen** (Side-by-side)
3. **Abweichungen notieren** (Falls vorhanden)
4. **CSS adjustieren** (Bei Bedarf)
5. **Benutzer-Feedback** (Freigabe?)

**Hinweis:** Das Formular sollte jetzt >95% optisch dem Original entsprechen. 
Nur noch Feinabstimmungen möglich bei sehr genauen Pixelmessungen.

