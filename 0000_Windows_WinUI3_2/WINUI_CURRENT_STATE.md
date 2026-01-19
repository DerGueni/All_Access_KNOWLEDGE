# WinUI3 Aktueller Zustand: MitarbeiterstammView

**Stand:** 30.12.2025
**Quelle:** `ConsysWinUI\ConsysWinUI\Views\MitarbeiterstammView.xaml`
**Zweck:** Dokumentation aller visuellen Eigenschaften für Vergleich mit Access-Original

---

## 1. FARBEN (aus XAML)

### Hauptfarben

| Element | Aktueller Wert | XAML-Zeile | Beschreibung |
|---------|---------------|------------|--------------|
| **Page Background** | `#F0F0F0` | Zeile 10 | Hellgrau - Haupthintergrund |
| **Sidebar Background** | `#8B0000` | Zeile 74 | Dunkelrot |
| **Sidebar Button (Standard)** | `#A05050` | Zeile 17 | Helleres Rot |
| **Sidebar Button (Aktiv)** | `#D4A574` | Zeile 90 | Beige/Sand - Mitarbeiterverwaltung |
| **Sidebar Button Text** | `White` | Zeile 18 | Weiß |
| **Tab Background** | `#D9D9D9` | Zeile 219 | Mittelgrau |
| **Content Background** | `White` | Zeile 222, 612, 619, 626, 633, 642 | Weiß |

### Button-Farben

| Element | Background | Foreground | BorderBrush | Zeile |
|---------|-----------|------------|-------------|-------|
| **Blauer Button (Standard)** | `#95B3D7` | `Black` | `#7A97BE` | 55-60 |
| **Tab-Button "MA Adressen"** | `#C0FF00` | `Black` | - | 153 |
| **Neuer Mitarbeiter** | `#CAD9EB` | `Black` | - | 201 |
| **Navigation Buttons** | `White` | - | - | 137-146 |
| **Maps öffnen** | `#D9D9D9` | `Black` | - | 600 |

### Rahmen & Linien

| Element | Farbe | XAML-Zeile |
|---------|-------|------------|
| **TextBox Border** | `#A6A6A6` | Zeile 28 |
| **ComboBox Border** | `#A6A6A6` | Zeile 38 |
| **Kopfzeile Border** | `#CCCCCC` | Zeile 113, 183 |
| **Liste Border** | `#A6A6A6` | Zeile 642, 676 |
| **Foto Placeholder** | `#CCCCCC` | Zeile 594 |

### Spezielle Hintergründe

| Element | Farbe | XAML-Zeile | Beschreibung |
|---------|-------|------------|--------------|
| **Koordinaten-Feld** | `#FFFACD` | Zeile 464 | Gelb hinterlegt |
| **Icon-Box** | `#808080` | Zeile 125 | Grau |
| **Foto Placeholder** | `#F5F5F5` | Zeile 594 | Sehr hellgrau |
| **Listen-Header** | `#E8E8E8` | Zeile 676 | Hellgrau |

---

## 2. GRÖSSEN & ABSTÄNDE

### Layout-Grid

| Element | Width/Height | XAML-Zeile |
|---------|--------------|------------|
| **Sidebar Breite** | `140px` | Zeile 67 |
| **Listen-Spalte Rechts** | `200px` | Zeile 215 |
| **Icon Größe** | `28x28px` | Zeile 125 |

### Spaltenbreiten (Stammdaten - Links)

| Element | Width | XAML-Zeile |
|---------|-------|------------|
| **Linke Spalte** | `320px` | Zeile 225 |
| **Label-Breite (Standard)** | `90px` | Zeile 248, 258, 268, etc. |
| **PersNr Feld** | `55px` | Zeile 235 |
| **LexNr Feld** | `45px` | Zeile 238 |
| **TextBox (Standard)** | `180px` | Zeile 249, 260, 271, etc. |
| **Staatsangehörigkeit Label** | `110px` | Zeile 370 |
| **Staatsangehörigkeit Feld** | `160px` | Zeile 371 |

### Spaltenbreiten (Stammdaten - Rechts)

| Element | Width | XAML-Zeile |
|---------|-------|------------|
| **Rechte Spalte** | `350px` | Zeile 226 |
| **Label-Breite (Standard)** | `130px` | Zeile 416, 426, etc. |
| **TextBox (Standard)** | `180px` | Zeile 417, 427, etc. |
| **Steuerklasse Feld** | `80px` | Zeile 509 |
| **Urlaubsanspruch Label** | `150px` | Zeile 518 |
| **Urlaubsanspruch Feld** | `50px` | Zeile 519 |
| **Arbeitstage Label** | `160px` | Zeile 573, 584 |

### Listen-Spalten (Rechts)

| Element | Width | XAML-Zeile |
|---------|-------|------------|
| **Nachname** | `65px` | Zeile 679, 699 |
| **Vorname** | `65px` | Zeile 680, 700 |
| **Ort** | `*` (Rest) | Zeile 681, 701 |

### Padding & Margins

| Element | Wert | XAML-Zeile |
|---------|------|------------|
| **Sidebar Buttons** | Padding: `8,6` | Zeile 20 |
| **Sidebar Button Margin** | `5,2` | Zeile 86-95 |
| **TextBox Padding** | `4,2` | Zeile 30 |
| **ComboBox Padding** | `4,2` | Zeile 40 |
| **Button (Blau) Padding** | `10,4` | Zeile 57 |
| **Kopfzeile Padding** | `8,4` | Zeile 113, 183 |
| **Content Padding** | `10` | Zeile 222 |
| **Listen-Header Padding** | `5,3` | Zeile 676 |
| **Listen-Item Padding** | `5,3` | Zeile 697 |

### Höhen

| Element | Height | XAML-Zeile |
|---------|--------|------------|
| **TextBox MinHeight** | `22px` | Zeile 31 |
| **ComboBox MinHeight** | `22px` | Zeile 41 |
| **Navigation Buttons** | `20px` | Zeile 135-145 |
| **Foto Placeholder** | `140px` | Zeile 594 |
| **ListView Item MinHeight** | `20px` | Zeile 712 |

---

## 3. FONTS

### Standard-Schriften

| Element | FontSize | FontWeight | XAML-Zeile |
|---------|----------|------------|------------|
| **Sidebar Titel "HAUPTMENÜ"** | `12` | `Bold` | Zeile 80-81 |
| **Sidebar Buttons** | `11` | Normal | Zeile 21 |
| **TextBox** | `12` | Normal | Zeile 32 |
| **ComboBox** | `12` | Normal | Zeile 42 |
| **Labels** | `12` | Normal | Zeile 48 |
| **Button (Blau)** | `11` | Normal | Zeile 58 |
| **Formular-Titel** | `14` | `Bold` | Zeile 128 |

### Spezielle Schriften

| Element | FontSize | XAML-Zeile | Kontext |
|---------|----------|------------|---------|
| **Navigation Buttons** | `9` | 135-145 | Pfeile |
| **Tab-Button** | `11` | 155 | MA Adressen |
| **MA-ID Label** | `11` | 165-166 | Kopfzeile |
| **Nachname/Vorname (Header)** | `16` | 161-164 | Fett |
| **CheckBox (klein)** | `10` | 241 | Subunternehmer |
| **CheckBox (standard)** | `11` | 239, 242 | Aktiv, Lex_Aktiv |
| **Staatsangehörigkeit** | `11` | 373 | Kleinere Labels |
| **Bezüge gezahlt als** | `11` | 459 | Kleinere Labels |
| **Tätigkeit Bezeichnung** | `10` | 491 | Kleinere Labels |
| **Urlaubsanspruch** | `10` | 521 | Kleinere Labels |
| **RV Befreiung** | `11` | 537 | Kleinere Labels |
| **Abrechnung per eMail** | `10` | 553 | Kleinere Labels |
| **Arbeitsstd. pro Arbeitstag** | `10` | 576 | Kleinere Labels |
| **Suche/Filter** | `10` | 652, 659 | Kleinere Labels |
| **Listen-Header** | `10` | 683-685 | `SemiBold` |
| **Listen-Items** | `10` | 703-705 | Normal |

---

## 4. BORDER-STYLES

| Element | BorderThickness | CornerRadius | XAML-Zeile |
|---------|----------------|--------------|------------|
| **Sidebar Buttons** | `0` | `0` | Zeile 22-23 |
| **TextBox** | `1` | `0` | Zeile 29, 33 |
| **ComboBox** | `1` | `0` | Zeile 39, 43 |
| **Button (Blau)** | `1` | `0` | Zeile 59, 61 |
| **Kopfzeile** | `0,0,0,1` | - | Zeile 113, 183 |
| **Navigation Container** | `1` | - | Zeile 133 |
| **Tab-Button** | - | `0` | Zeile 157 |
| **Neuer Mitarbeiter** | - | `0` | Zeile 202 |
| **Koordinaten** | - | - | Zeile 464 (Border) |
| **Foto Placeholder** | `1` | - | Zeile 594 |
| **Maps Button** | - | `0` | Zeile 604 |
| **Listen-Rechts** | `1,0,0,0` | - | Zeile 642 |
| **Listen-Header** | `0,0,0,1` | - | Zeile 676 |

---

## 5. STYLES (ResourceDictionary)

### Definierte Styles

| Style Key | TargetType | Zeilen | Verwendung |
|-----------|-----------|--------|------------|
| **SidebarButtonStyle** | `Button` | 16-24 | Sidebar-Menü |
| **AccessTextBoxStyle** | `TextBox` | 27-34 | Alle Eingabefelder |
| **AccessComboBoxStyle** | `ComboBox` | 37-44 | Alle Dropdowns |
| **AccessLabelStyle** | `TextBlock` | 47-51 | Alle Labels |
| **AccessBlueButtonStyle** | `Button` | 54-62 | Aktions-Buttons |

---

## 6. CONTROLS & PROPERTIES

### TextBox-Bindings

| Feld | Binding | Mode | XAML-Zeile |
|------|---------|------|------------|
| **PersNr** | `ViewModel.MaId` | `OneWay` | 235 |
| **Nachname** | `ViewModel.Nachname` | `TwoWay` | 253 |
| **Vorname** | `ViewModel.Vorname` | `TwoWay` | 264 |
| **Strasse** | `ViewModel.Strasse` | `TwoWay` | 275 |
| **PLZ** | `ViewModel.Plz` | `TwoWay` | 296 |
| **Ort** | `ViewModel.Ort` | `TwoWay` | 307 |
| **Tel. Mobil** | `ViewModel.TelMobil` | `TwoWay` | 328 |
| **Tel. Festnetz** | `ViewModel.TelFestnetz` | `TwoWay` | 339 |
| **Email** | `ViewModel.Email` | `TwoWay` | 350 |
| **Stundenlohn** | `ViewModel.Stundenlohn` | `TwoWay` | 578 |

### CheckBox-Bindings

| Feld | Binding | Mode | XAML-Zeile |
|------|---------|------|------------|
| **Aktiv** | `ViewModel.IstAktiv` | `TwoWay` | 240 |

### CalendarDatePicker

| Feld | Binding | Format | XAML-Zeile |
|------|---------|--------|------------|
| **Geb. Datum** | `ViewModel.Geburtsdatum` | `{day}.{month}.{year}` | 385-386 |

### Command-Bindings

| Button | Command | XAML-Zeile |
|--------|---------|------------|
| **Erste Seite** | `ViewModel.NavigateFirstCommand` | 136 |
| **Vorherige Seite** | `ViewModel.NavigatePreviousCommand` | 139 |
| **Nächste Seite** | `ViewModel.NavigateNextCommand` | 142 |
| **Letzte Seite** | `ViewModel.NavigateLastCommand` | 145 |
| **Mitarbeiter löschen** | `ViewModel.DeleteCommand` | 174 |
| **Neuer Mitarbeiter** | `ViewModel.NewRecordCommand` | 203 |

### ListView

| Property | Binding | XAML-Zeile |
|----------|---------|------------|
| **ItemsSource** | `ViewModel.Mitarbeiter` | 691 |
| **SelectedItem** | `ViewModel.SelectedMitarbeiter` | 692 |
| **SearchText** | `ViewModel.SearchText` | 654 |

---

## 7. KRITISCHE UNTERSCHIEDE ZU ACCESS (Vermutet)

### Mögliche Abweichungen

1. **Sidebar-Farbe:**
   - WinUI: `#8B0000` (Dunkelrot)
   - Access: Möglicherweise heller oder anders

2. **Button-Farben:**
   - WinUI: `#95B3D7` (Blau), `#C0FF00` (Neongelb)
   - Access: Vermutlich gedämpftere Farben

3. **Fonts:**
   - WinUI: Segoe UI (Standard in WinUI3)
   - Access: Tahoma, Calibri oder MS Sans Serif

4. **CornerRadius:**
   - WinUI: Durchgehend `0` (eckig)
   - Access: Immer eckig (korrekt)

5. **Padding/Margins:**
   - WinUI: Moderne Abstände (8,4 / 10,4)
   - Access: Kompaktere Abstände

---

## 8. HANDLUNGSBEDARF

### Zum Vergleich mit Access benötigt:

1. **JSON-Export:** `FRM_MA_Mitarbeiterstamm.json`
   - Pfad: `11_json_Export/000_Consys_Eport_11_25/30_forms/FRM_frm_MA_Mitarbeiterstamm.json`
   - Für exakte Farben, Größen, Positionen

2. **Spec-File:** `frm_MA_Mitarbeiterstamm.spec.json`
   - Pfad: `05_Dokumentation/specs/frm_MA_Mitarbeiterstamm.spec.json`
   - Für Captions, Control-Sources, Events

3. **Screenshot der Access-Anwendung:**
   - Um visuell zu vergleichen

4. **Screenshot der WinUI3-App:**
   - Um Side-by-Side zu vergleichen

### Zu prüfende Eigenschaften:

- [ ] **Farben:** Sidebar, Buttons, Hintergründe
- [ ] **Schriftarten:** Family, Size, Weight
- [ ] **Abstände:** Padding, Margins zwischen Controls
- [ ] **Größen:** Control-Höhen, -Breiten
- [ ] **Border:** Dicken, Farben
- [ ] **Layout:** Spaltenbreiten, Reihenfolge
- [ ] **Icons:** Emoji vs. echte Icons
- [ ] **Foto-Bereich:** Position, Größe

---

## 9. XAML-ZEILEN FÜR ANPASSUNGEN

### Farben anpassen:

| Zeile | Element | Aktuell | Aktion |
|-------|---------|---------|--------|
| 10 | Page Background | `#F0F0F0` | Mit Access-Wert vergleichen |
| 74 | Sidebar Background | `#8B0000` | Mit Access-Wert vergleichen |
| 17 | Sidebar Button | `#A05050` | Mit Access-Wert vergleichen |
| 90 | Aktiver Button | `#D4A574` | Mit Access-Wert vergleichen |
| 55 | Blauer Button | `#95B3D7` | Mit Access-Wert vergleichen |
| 153 | Tab-Button | `#C0FF00` | Mit Access-Wert vergleichen |
| 201 | Neuer MA Button | `#CAD9EB` | Mit Access-Wert vergleichen |
| 464 | Koordinaten BG | `#FFFACD` | Mit Access-Wert vergleichen |

### Größen anpassen:

| Zeile | Element | Aktuell | Aktion |
|-------|---------|---------|--------|
| 67 | Sidebar Width | `140px` | Mit Access-Wert vergleichen |
| 215 | Listen-Spalte | `200px` | Mit Access-Wert vergleichen |
| 225 | Linke Spalte | `320px` | Mit Access-Wert vergleichen |
| 226 | Rechte Spalte | `350px` | Mit Access-Wert vergleichen |

### Fonts anpassen:

| Zeile | Element | Aktuell | Aktion |
|-------|---------|---------|--------|
| 32 | TextBox FontSize | `12` | Mit Access-Wert vergleichen |
| 48 | Label FontSize | `12` | Mit Access-Wert vergleichen |
| 80 | Sidebar Titel | `12` Bold | Mit Access-Wert vergleichen |

---

**Nächste Schritte:**
1. Access-JSON laden und auswerten
2. Pixel-genauen Vergleich durchführen
3. Farbkonvertierung (BGR Long → HEX) anwenden
4. XAML entsprechend anpassen
5. Screenshot-Vergleich durchführen
