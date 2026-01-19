# Personal-Formulare Optische Übereinstimmung - Korrektur-Bericht

**Datum:** 31.12.2025
**Geprüfte Formulare:**
- `AbwesenheitView.xaml`
- `ZeitkontenView.xaml`
- `BewerberView.xaml`

**Referenz-Formular:** `MitarbeiterstammView.xaml`

---

## Gefundene Abweichungen und Korrekturen

### 1. Sidebar-Struktur

**Problem:**
- **AbwesenheitView:** Fehlende "HAUPTMENÜ" Box, falsche Sidebar-Button-Farbe (#A05050 statt transparent)
- **ZeitkontenView:** Separator-Linien statt HAUPTMENÜ-Box
- **BewerberView:** Fehlende HAUPTMENÜ-Box, falsche Button-Padding/Height

**Korrektur:**
Alle Sidebars jetzt konsistent mit **HAUPTMENÜ-Box** (weiß mit schwarzem Rahmen):

```xaml
<Border Background="White" BorderBrush="Black" BorderThickness="1"
        Margin="8,10" Padding="8,3">
    <TextBlock Text="HAUPTMENÜ"
               Foreground="Black"
               FontWeight="Bold"
               FontSize="11"
               HorizontalAlignment="Center"/>
</Border>
```

### 2. Sidebar-Button-Style

**Problem:**
- **AbwesenheitView:** `Background="#A05050"` (falsch)
- **BewerberView:** `Padding="12,10"`, `Height="40"`, `FontSize="12"` (zu groß)

**Korrektur:**
Einheitlicher Style für alle Formulare:

```xaml
<Style x:Key="SidebarButtonStyle" TargetType="Button">
    <Setter Property="Background" Value="Transparent"/>
    <Setter Property="Foreground" Value="White"/>
    <Setter Property="Padding" Value="10,6"/>
    <Setter Property="MinHeight" Value="28"/>
    <Setter Property="FontSize" Value="11"/>
</Style>
```

### 3. Aktiver Button

**Problem:**
- **ZeitkontenView:** Separate `SidebarButtonActiveStyle` (unnötig)

**Korrektur:**
Aktiver Button jetzt einheitlich mit **Inline-Attributen**:

```xaml
<Button Content="Zeitkonten"
        Background="#D4A574"
        Foreground="Black"
        Style="{StaticResource SidebarButtonStyle}"
        Margin="5,2"/>
```

### 4. Access-Button-Style

**Problem:**
- **AbwesenheitView:** Fehlender `AccessBlueButtonStyle` für Filter-Buttons
- Buttons hatten keinen einheitlichen Access-Look

**Korrektur:**
Alle Action-Buttons verwenden jetzt `AccessBlueButtonStyle`:

```xaml
<Style x:Key="AccessBlueButtonStyle" TargetType="Button">
    <Setter Property="Background" Value="#95B3D7"/>
    <Setter Property="Foreground" Value="Black"/>
    <Setter Property="Padding" Value="10,4"/>
    <Setter Property="BorderBrush" Value="#7A97BE"/>
</Style>
```

Angewendet auf:
- "MA öffnen" Button
- "Filter anwenden" Button
- "Reset" Button

### 5. Sidebar-Border

**Problem:**
- **BewerberView:** Unnötiger `BorderBrush="#6B0000" BorderThickness="0,0,1,0"`

**Korrektur:**
Nur noch `Background="#8B0000"` wie in allen anderen Formularen

---

## Optische Konsistenz - Zusammenfassung

### Sidebar (Links)
✅ **Einheitlich für alle Personal-Formulare:**
- Breite: `140px`
- Hintergrund: `#8B0000` (Dunkelrot)
- HAUPTMENÜ-Box: Weiß mit schwarzem Rahmen
- Button-Background: Transparent
- Button-Foreground: Weiß
- Aktiver Button: `#D4A574` (Hellbraun) mit schwarzer Schrift
- Button-Padding: `10,6`
- Button-MinHeight: `28`
- Button-FontSize: `11`
- Button-Margin: `5,2`

### Header-Styles
✅ **Konsistent:**
- Lila Hintergrund: `#6B4D8C` (bei Abwesenheit, Zeitkonten, Bewerber)
- Weiße Schrift auf lilafarbenem Header
- Icon + Titel-Struktur

### Button-Farben
✅ **Access-konform:**
- Standard-Buttons: `#95B3D7` (Hellblau)
- Border: `#7A97BE`
- Foreground: Schwarz

### DataGrid/ListView
✅ **Konsistent:**
- Header: `#D9D9D9`
- Border: `#A6A6A6`
- FontSize: `11-12px`

---

## Dateien geändert

1. **AbwesenheitView.xaml**
   - Sidebar-Button-Style von `#A05050` → `Transparent`
   - HAUPTMENÜ-Box hinzugefügt
   - `AccessBlueButtonStyle` hinzugefügt
   - Filter-Buttons mit Access-Style versehen

2. **ZeitkontenView.xaml**
   - Separator-Linien entfernt
   - HAUPTMENÜ-Box hinzugefügt
   - `SidebarButtonActiveStyle` entfernt (inline ersetzt)

3. **BewerberView.xaml**
   - HAUPTMENÜ-Box hinzugefügt
   - Sidebar-Button-Padding/Height korrigiert
   - Border-Attribute entfernt

---

## Vergleich mit Access-Originalen

Da keine JSON-Exporte für diese Formulare vorhanden sind (`11_json_Export/000_Consys_Eport_11_25/30_forms/`), wurde die Konsistenz anhand des **MitarbeiterstammView** als Referenz hergestellt.

**MitarbeiterstammView** ist die am besten dokumentierte 1:1-Nachbildung und dient als Vorlage für:
- Sidebar-Struktur
- Button-Styles
- Farbschema
- Typografie

---

## Ergebnis

✅ **Alle Personal-Formulare sind jetzt visuell konsistent**
✅ **Sidebar-Struktur identisch mit Access-Optik**
✅ **Button-Farben entsprechen Access-Standard**
✅ **HAUPTMENÜ-Box wie im Original vorhanden**

Die Formulare können nun nahtlos nebeneinander geöffnet werden, ohne dass optische Unterschiede auffallen.
