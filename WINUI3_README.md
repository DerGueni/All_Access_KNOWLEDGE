# Access zu WinUI3 Control Mapping - Dokumentation

## Übersicht

Dieser Ordner enthält eine detaillierte Analyse der Access-Formulare mit exakten Control-Dimensionen für die Migration zu WinUI3.

## Generierte Dateien

### WINUI3_ACCESS_CONTROL_MAPPING.md
Vollständiger Bericht mit allen Control-Dimensionen (812 Zeilen)

**Inhalt:**
- Detaillierte Auflistung aller 5 analysierten Formulare
- Exakte Pixel-Positionen für jedes Control (konvertiert von Twips)
- Control-Typ, Sichtbarkeit und Dimensionen
- Zusammenfassung der Formular-Größen
- Statistik der verwendeten Control-Typen

## Analysierte Formulare

| Formular | Breite (px) | Höhe (px) | Controls |
|----------|-------------|-----------|----------|
| frm_MA_Mitarbeiterstamm | 1883.66 | 802.53 | 290 |
| frm_KD_Kundenstamm | 1762.53 | 786.0 | 187 |
| frm_va_auftragstamm | 1914.4 | 837.0 | 136 |
| frm_DP_Dienstplan_MA | 1903.93 | 412.13 | 32 |
| frm_OB_Objekt | 1834.94 | 529.07 | 49 |

**Gesamt: 694 Controls**

## Control-Typen Verteilung

Die häufigsten Control-Typen:
1. **Label** - 229 (33.0%)
2. **TextBox** - 184 (26.5%)
3. **CommandButton** - 132 (19.0%)
4. **ComboBox** - 40 (5.8%)
5. **SubForm** - 35 (5.0%)

## Verwendung für WinUI3 Migration

### 1. Control-Mapping

Jedes Access-Control muss auf ein entsprechendes WinUI3-Control gemappt werden:

**Access → WinUI3 Mapping:**
```
Label          → TextBlock
TextBox        → TextBox
CommandButton  → Button
ComboBox       → ComboBox
CheckBox       → CheckBox
ListBox        → ListView / ListBox
TabControl     → TabView / Pivot
Page           → TabViewItem / PivotItem
SubForm        → Frame / ContentControl
Rectangle      → Border / Rectangle
Image          → Image
OptionGroup    → RadioButtons (grouped)
OptionButton   → RadioButton
```

### 2. Koordinaten-System

**Access (Twips):**
- 1 Pixel = 15 Twips
- Koordinaten-Ursprung: Links oben (0,0)
- Absolute Positionierung

**WinUI3 (Pixel):**
- Koordinaten in Pixel (bereits konvertiert im Bericht)
- Empfohlen: Relative Layouts (Grid, StackPanel) statt absolut
- Canvas für absolute Positionierung

### 3. Layout-Strategie

**Empfohlene Vorgehensweise:**

1. **Formular-Struktur analysieren**
   - Identifiziere logische Gruppen (z.B. TabControl mit Pages)
   - Erkenne Header, Content, Footer Bereiche

2. **Grid-Layout definieren**
   - Erstelle Rows und Columns basierend auf Control-Positionen
   - Nutze RowDefinitions/ColumnDefinitions

3. **Controls platzieren**
   - Verwende Grid.Row, Grid.Column, Grid.RowSpan, Grid.ColumnSpan
   - Margin für Feinabstimmung

4. **Responsive Design**
   - Verwende MinWidth/MaxWidth statt fixer Breiten
   - Auto-Sizing für flexible Layouts

### 4. Beispiel-Konvertierung

**Access Control (aus Bericht):**
```
Name: MANameEingabe
Type: ComboBox
Left: 1294.8 px
Top: 26.0 px
Width: 199.33 px
Height: 25.0 px
Visible: YES
```

**WinUI3 XAML:**
```xml
<ComboBox
    x:Name="MANameEingabe"
    Grid.Row="1"
    Grid.Column="5"
    Width="199"
    Height="25"
    Margin="1295,26,0,0"
    VerticalAlignment="Top"
    HorizontalAlignment="Left"
    Visibility="Visible" />
```

**Oder mit Grid (empfohlen):**
```xml
<Grid.RowDefinitions>
    <RowDefinition Height="26" />
    <RowDefinition Height="25" />
</Grid.RowDefinitions>
<Grid.ColumnDefinitions>
    <ColumnDefinition Width="1295" />
    <ColumnDefinition Width="199" />
</Grid.ColumnDefinitions>

<ComboBox
    x:Name="MANameEingabe"
    Grid.Row="1"
    Grid.Column="1" />
```

## Analyse-Script

Das Python-Script `analyze_forms.py` kann für weitere Formulare verwendet werden:

```bash
python analyze_forms.py
```

**Features:**
- Automatische Encoding-Erkennung (Latin-1, ISO-8859-1, CP1252, UTF-8)
- Bereinigung deutscher Boolean-Werte (wahr/falsch → true/false)
- Berechnung der Formular-Dimensionen aus Control-Positionen
- Markdown-Report-Generierung

## JSON-Quellen

Die Analyse basiert auf Access-JSON-Exporten:
- Pfad: `11_json_Export/000_Consys_Eport_11_25/30_forms/`
- Format: Einzeiliges JSON mit deutschen Boolean-Werten
- Encoding: Latin-1 / ISO-8859-1

## Nächste Schritte

1. **WinUI3-Projekt erstellen**
   - Neue WinUI3 Desktop App
   - Target Framework: .NET 8.0 oder höher

2. **Formular-Klassen generieren**
   - Eine Page/Window pro Access-Formular
   - XAML für UI-Struktur
   - Code-Behind für Logik

3. **Data-Binding implementieren**
   - MVVM-Pattern verwenden
   - Observable Collections für Listen
   - INotifyPropertyChanged für Formular-Felder

4. **Testing**
   - Pixel-genaue Positionierung prüfen
   - Funktionalität gegen Access-Original testen

## Kontakt

Erstellt: 2025-12-31
Generator: analyze_forms.py
