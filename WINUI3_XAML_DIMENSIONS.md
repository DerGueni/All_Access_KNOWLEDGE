# WinUI3 XAML Control-Dimensionen Dokumentation

**Datum:** 2025-12-31
**Quelle:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ConsysWinUI\ConsysWinUI\Views\`

---

## Übersicht

Diese Dokumentation listet alle explizit definierten Control-Dimensionen in den WinUI3 XAML Views auf.

---

## 1. MitarbeiterstammView.xaml

### Grid Column Definitions
```xml
<ColumnDefinition Width="140"/>  <!-- Sidebar -->
<ColumnDefinition Width="*"/>    <!-- Hauptbereich -->
```

### Content Area Grid Columns (Stammdaten Tab)
```xml
<ColumnDefinition Width="320"/>  <!-- Linke Spalte -->
<ColumnDefinition Width="350"/>  <!-- Rechte Spalte -->
<ColumnDefinition Width="Auto"/> <!-- Foto -->
```

### Mitarbeiter-Liste Spalte
```xml
<ColumnDefinition Width="200"/>  <!-- Liste rechts -->
```

### Styles - Control Dimensionen

#### SidebarButtonStyle
- `MinHeight="28"`
- `Padding="10,6"`
- `FontSize="11"`

#### AccessTextBoxStyle
- `MinHeight="20"`
- `Padding="3,2"`
- `FontSize="12"`

#### AccessComboBoxStyle
- `MinHeight="20"`
- `Padding="3,2"`
- `FontSize="12"`

#### AccessLabelStyle
- `FontSize="12"`

#### AccessBlueButtonStyle
- `Padding="10,4"`
- `FontSize="11"`

#### AccessCheckBoxStyle
- `MinWidth="12"`
- `MinHeight="12"`
- `FontSize="11"`

### Spezifische Controls

#### Logo/Titel Border
- `Margin="8,10"`
- `Padding="8,3"`
- `FontSize="11"` (TextBlock)

#### Navigations-Buttons (Kopfzeile 1)
- `Width="22"`
- `Height="20"`
- `Padding="0"`
- `FontSize="9"`

#### Icon Border (Kopfzeile 1)
- `Width="28"`
- `Height="28"`
- `FontSize="16"` (Icon)

#### Tab-Button "MA Adressen"
- `Padding="12,3"`
- `FontSize="11"`
- `Margin="15,0,0,0"`

#### Name-Anzeige (Kopfzeile)
- `FontSize="16"` (Nachname/Vorname)
- `FontSize="11"` (MA-ID)

#### Header-Aktionsbuttons
- `Height="36"`
- `Padding="16,0"`
- `FontSize="14"` (Icon)

#### Formular-Felder (Linke Spalte)
- Label Width: `70px` (Nachname, Vorname, Strasse, etc.)
- TextBox Width: `200px` (Standard), `55px` (PersNr), `45px` (LexNr), `60px` (Nr), `80px` (PLZ), `180px` (Email)
- Grid Margin: `0,6` (zwischen Feldern)

#### Formular-Felder (Rechte Spalte)
- Label Width: `100px` (Standard), `150px` (breitere Labels), `160px` (längste Labels)
- TextBox Width: `180px` (Standard), `50px` (schmale Felder), `60px` (mittlere)
- Grid Margin: `0,6` (zwischen Feldern)

#### Koordinaten-Border (Gelb)
- `Background="#FFFACD"`
- `Padding="3"`
- Label Width: `124px`

#### Foto-Bereich
- Border: `Width="110"`, `Height="140"`
- Button Margin: `0,8,0,0`
- Button Padding: `12,4`
- Button FontSize: `11`

#### Mitarbeiter-Liste (Rechts)
- Search/Filter: `Margin="5,5,5,3"` bzw. `Margin="5,0,5,3"`
- FontSize: `10` (Labels)
- Spalten: `Width="60"` (Nachname, Vorname), `Width="*"` (Ort)
- ListViewItem: `MinHeight="20"`

---

## 2. KundenstammView.xaml

### Grid Column Definitions
```xml
<ColumnDefinition Width="140"/>  <!-- Sidebar -->
<ColumnDefinition Width="*"/>    <!-- Hauptbereich -->
```

### Main Content Grid Columns
```xml
<ColumnDefinition Width="280"/>  <!-- Kundenliste -->
<ColumnDefinition Width="*"/>    <!-- Formular -->
<ColumnDefinition Width="300"/>  <!-- Info Card -->
```

### Styles
- `SidebarButtonStyle`: Identisch zu MitarbeiterstammView

### Spezifische Controls

#### Logo/Titel Border
- `Margin="8,10"`
- `Padding="8,3"`
- `FontSize="11"`

#### Main Grid Padding
- `Padding="24"`

#### Navigation Buttons
- `Spacing="4"` (StackPanel)
- `FontSize="14"` (Icons)

#### Search Box
- `Width="200"`

#### Header Buttons
- `Height="36"` (nicht explizit, aber konsistent)
- `FontSize="14"` (Icons)

#### Status Bar
- `Padding="12,8"`
- `ProgressRing`: `Width="16"`, `Height="16"`

#### Kundenliste (Links)
- `CornerRadius="8"`
- `Padding="8"`
- `Margin="0,0,16,0"`
- ListView ItemTemplate: `Padding="4"`, `ColumnSpacing="8"`

#### Formular Cards
- `CornerRadius="8"`
- `Padding="16"`
- `Margin="0,0,0,16"` (zwischen Cards)
- `Spacing="12"` (StackPanel)

#### Formular-Felder
- Kunde-ID TextBox: `Width="100"`
- Kontakt Grid: 2 Spalten à `Width="*"`
- Adresse Grid: `Width="100"` (PLZ), `Width="*"` (Ort), `Width="120"` (Land)
- Bemerkung TextBox: `Height="80"`

#### Info Card (Rechts)
- `Padding="16"`
- Zahlungsziel TextBox: `MaxLength="3"`, `InputScope="Number"`
- Statistik Badges: `Padding="12"`, `Margin="0,0,0,16"`

#### Footer
- `Padding="0,12,0,0"`
- `Margin="0,16,0,0"`

---

## 3. AuftragstammView.xaml

### Grid Column Definitions
```xml
<ColumnDefinition Width="140"/>  <!-- Sidebar -->
<ColumnDefinition Width="*"/>    <!-- Main Content -->
```

### Styles
- `SidebarButtonStyle`: Identisch zu anderen Views

### Spezifische Controls

#### Main Grid
- `Padding="24"` (ScrollViewer → Grid)

#### Header
- `Padding="16"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- `Background="#F7B580"`
- `FontSize="20"`, `FontWeight="Bold"`

#### Navigation Bar
- `Padding="16"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- Navigation Buttons: `Width="40"`, `Height="36"`
- Icons: `FontSize="14"`

#### Record Counter
- `Background="#F0F0F0"`
- `CornerRadius="4"`
- `Padding="12,8"`

#### CRUD Buttons
- `Height="36"`
- `Padding="16,0"`
- `Spacing="8"` (StackPanel)

#### Stammdaten Form
- `Padding="24"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- Grid: `ColumnSpacing="16"`
- Spalten: `Width="150"` (Labels), `Width="*"` (Controls)
- Bemerkung TextBox: `Height="80"`

#### Header-Buttonleiste
- `Padding="16"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- Buttons: `Height="36"`, `Padding="16,0"`
- Icons: `FontSize="14"`

#### Tab-Bereich
- `Padding="0"`
- `CornerRadius="8"`
- Tab Content Padding: `Padding="16"`
- ListView: `MaxHeight="200"` (Schichten), `MinHeight="400"` (Antworten ausstehend)
- ListView ItemTemplate: `Padding="4"`, Grid Columns variabel

---

## 4. DienstplanMAView.xaml

### Grid Column Definitions
```xml
<ColumnDefinition Width="140"/>  <!-- Sidebar -->
<ColumnDefinition Width="*"/>    <!-- Hauptbereich -->
```

### Listen-Ansicht Grid Columns
```xml
<ColumnDefinition Width="2*"/>   <!-- Einsätze Liste -->
<ColumnDefinition Width="16"/>   <!-- Spacer -->
<ColumnDefinition Width="*"/>    <!-- Statistik + Abwesenheiten -->
```

### Styles

#### SidebarButtonStyle
- Identisch zu anderen Views

#### ExportButtonStyle
- `Background="#D5A5D7"`
- `Padding="12,6"`

#### HeaderLabelStyle
- `Foreground="White"`

#### DayHeaderStyle
- `Foreground="Black"`

### Spezifische Controls

#### Main Grid
- `Padding="24"`

#### Header
- `Margin="0,0,0,16"`
- Export Buttons: `Spacing="8"`, Icons `FontSize="14"`

#### Filter-Bereich
- `Padding="16"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- Mitarbeiter ComboBox: `Width="250"`
- DatePicker: `Width="150"`

#### Status Bar
- `Padding="12,8"`
- `CornerRadius="4"`
- `Margin="0,0,0,16"`
- ProgressRing: `Width="16"`, `Height="16"`

#### View-Toggle
- `Spacing="8"`
- `Margin="0,0,0,12"`

#### Einsätze Liste (ListView)
- `Padding="16"` (Border)
- ItemTemplate Grid: `Padding="12,8"`, `ColumnSpacing="12"`
- Spalten: `Width="100"` (Datum), `Width="80"` (Zeit/Stunden), `Width="*"` (Auftrag/Objekt)
- ItemContainer: `Margin="0,2"`

#### Statistik Card
- `Padding="16"`
- `CornerRadius="8"`
- `Spacing="16"` (StackPanel)
- Labels: `FontSize="12"`

#### Abwesenheiten Liste
- `Padding="16"`
- `Margin="0,0,0,12"` (Titel)
- ItemTemplate Grid: `Padding="8"`
- Text: `FontSize="11"`
- ItemContainer: `Margin="0,4"`

---

## 5. DienstplanObjektView.xaml

### Grid Column Definitions
```xml
<ColumnDefinition Width="140"/>  <!-- Sidebar -->
<ColumnDefinition Width="*"/>    <!-- Hauptbereich -->
```

### Listen-Ansicht Grid Columns
```xml
<ColumnDefinition Width="2*"/>   <!-- Schichten Liste -->
<ColumnDefinition Width="16"/>   <!-- Spacer -->
<ColumnDefinition Width="*"/>    <!-- Zugeordnete MA + Actions -->
```

### Styles
- `SidebarButtonStyle`: Identisch
- `ExportButtonStyle`: Identisch zu DienstplanMAView
- `HeaderLabelStyle`: Identisch
- `DayHeaderStyle`: Identisch

### Spezifische Controls

#### Main Grid
- `Padding="24"`

#### Header
- `Margin="0,0,0,16"`
- Buttons: `Spacing="8"`

#### Filter-Bereich
- `Padding="16"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- Auftrag ComboBox: `Width="350"`
- CheckBox Margin: `0,0,16,8`

#### Status + Statistik Bar
- `Padding="12,8"`
- `CornerRadius="4"`
- `Margin="0,0,0,16"`
- ProgressRing: `Width="16"`, `Height="16"`
- Statistik StackPanels: `Spacing="16"`, `Spacing="4"` (innere)

#### View-Toggle
- `Spacing="8"`
- `Margin="0,0,0,12"`

#### Schichten Liste
- `Padding="16"`
- `CornerRadius="8"`
- ItemTemplate Grid: `Padding="12,8"`, `ColumnSpacing="12"`
- Spalten: `Width="100"` (Datum/Zeit/Status), `Width="*"` (Bemerkung), `Width="80"` (MA Anzahl)
- Status Border: `Padding="8,4"`, `FontSize="11"`
- MA Anzahl: `FontSize="18"`
- ItemContainer: `Margin="0,2"`

#### Zugeordnete Mitarbeiter Card
- `Padding="16"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- ItemTemplate Grid: `Padding="8"`
- Remove Button: `Width="32"`, `Height="32"`, `Padding="0"`, Icon `FontSize="12"`
- Text: `FontSize="11"`
- ItemContainer: `Margin="0,4"`

#### Action Buttons (unten)
- `Spacing="8"`
- Buttons: HorizontalAlignment="Stretch"

---

## 6. ObjektstammView.xaml

### Grid Column Definitions
```xml
<ColumnDefinition Width="140"/>  <!-- Sidebar -->
<ColumnDefinition Width="*"/>    <!-- Main Content -->
```

### Main Content Grid Columns
```xml
<ColumnDefinition Width="280"/>  <!-- Objektliste -->
<ColumnDefinition Width="*"/>    <!-- Formular -->
<ColumnDefinition Width="300"/>  <!-- Info Card -->
```

### Styles
- `SidebarButtonStyle`: Identisch zu anderen Views

### Spezifische Controls

#### Main Grid
- `Padding="24"`

#### Navigation Buttons
- `Spacing="4"`
- Icons: `FontSize="14"`

#### Search Box
- `Width="200"`

#### CRUD Buttons
- `Spacing="4"`
- Icons: `FontSize="14"`

#### Status Bar
- `Padding="12,8"`
- `CornerRadius="4"`
- `Margin="0,0,0,16"`
- ProgressRing: `Width="16"`, `Height="16"`

#### Objektliste (Links)
- `Padding="8"`
- `CornerRadius="8"`
- `Margin="0,0,16,0"`
- ListView ItemTemplate: `Padding="4"`, `ColumnSpacing="8"`

#### Formular Cards
- `Padding="16"`
- `CornerRadius="8"`
- `Margin="0,0,0,16"`
- `Spacing="12"` (StackPanel)

#### Formular-Felder
- Objekt-ID TextBox: `Width="100"`
- Adresse Grid: `Width="100"` (PLZ), `Width="*"` (Ort)
- Bemerkung TextBox: `Height="120"`

#### Info Card (Rechts)
- `Padding="16"`
- `CornerRadius="8"`
- Statistik Badges: `Padding="12"`, `Margin="0,0,0,12"` bzw. `Margin="0,0,0,16"`

#### Footer
- `Padding="0,12,0,0"`
- `Margin="0,16,0,0"`

---

## Gemeinsame Muster und Konventionen

### Grid-Struktur
- **Sidebar**: Konstant `140px` breit in allen Views
- **Main Content**: Flexible Breite mit `*`
- **Listen/Cards**: Meist `280px` (links) oder `300px` (rechts)

### Padding & Margin
- **Main Grid**: Standard `24px` Padding
- **Cards**: Standard `16px` Padding
- **Card Spacing**: `16px` Margin zwischen Cards
- **StackPanel Spacing**: `12px` innerhalb Cards, `8px` für Button-Groups

### Buttons
- **Standard Height**: `36px` (CRUD, Actions)
- **Icon Size**: `14px` (FontIcon)
- **Padding**: `16,0` (Standard), `12,6` (Export-Buttons)

### Border & CornerRadius
- **Standard CornerRadius**: `8px` für Cards
- **BorderThickness**: `1px` (Standard)

### TextBox & ComboBox
- **MinHeight**: `20px` (Access-Style)
- **Padding**: `3,2` (Access-Style)
- **FontSize**: `12px` (Access-Style)

### ListView
- **ItemTemplate Padding**: `12,8` oder `8` (je nach Komplexität)
- **ItemContainer Margin**: `0,2` oder `0,4`
- **ColumnSpacing**: `12px` (Grid in ItemTemplate)

### Typography
- **Labels**: `FontSize="12"` (Standard)
- **Titel**: `FontSize="16"` oder `20"` (je nach Hierarchie)
- **Sidebar**: `FontSize="11"`
- **Icons**: `FontSize="14"` (Standard)

### Status & Progress
- **ProgressRing**: `16x16px` (konsistent)
- **Status Bar Padding**: `12,8`

---

## Fazit

Die Views folgen einem einheitlichen Design-System mit konsistenten Dimensionen. Besonders auffällig:

1. **Sidebar**: Immer `140px` breit
2. **Main Padding**: Immer `24px`
3. **Card CornerRadius**: Immer `8px`
4. **Button Height**: Standardmäßig `36px`
5. **Icon Size**: Standardmäßig `14px`
6. **Access-Style Controls**: `MinHeight="20"`, `FontSize="12"`

Diese Konsistenz erleichtert die Wartung und Weiterentwicklung der Anwendung.
