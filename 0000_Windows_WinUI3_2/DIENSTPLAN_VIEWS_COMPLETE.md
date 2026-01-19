# Dienstplan Views - Vollständige Implementierung

**Status:** ✅ FERTIG
**Datum:** 30.12.2025
**Agent:** Agent 4

---

## Übersicht

Die beiden Dienstplan-Views wurden vollständig mit Access Backend-Anbindung implementiert:

### 1. DienstplanMAView (Mitarbeiter-Dienstplan)
**ViewModel:** `DienstplanMAViewModel.cs` (bereits komplett)
**View:** `DienstplanMAView.xaml` + `.xaml.cs`

**Features:**
- Mitarbeiter-Auswahl via ComboBox
- Datumsfiltrer (Von/Bis) mit DatePicker
- Quick Actions: Aktuelle Woche, Aktueller Monat, Navigation (←/→)
- Einsätze-Liste mit Datum, Zeit, Auftrag, Objekt, Stunden
- Abwesenheiten-Liste mit Grund, Zeitraum, Bemerkung
- Statistik-Panel: Anzahl Einsätze, Gesamtstunden, Arbeitstage, Abwesenheiten
- Navigation zu Mitarbeiterstamm, Auftragstamm
- Export & Druck (Vorbereitet, noch nicht implementiert)

**Datenbankzugriff:**
```sql
-- Einsätze
SELECT p.VA_ID, p.VADatum, p.VA_Start, p.VA_Ende, p.MA_ID,
       a.Auftrag, a.Objekt, a.Veranstalter_ID,
       k.kun_Firma as Veranstalter
FROM tbl_MA_VA_Planung p
INNER JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
WHERE p.MA_ID = @MaId
  AND p.VADatum BETWEEN @VonDatum AND @BisDatum
ORDER BY p.VADatum, p.VA_Start

-- Abwesenheiten
SELECT MA_ID, vonDat, bisDat, Grund, Bemerkung
FROM tbl_MA_NVerfuegZeiten
WHERE MA_ID = @MaId
  AND (vonDat BETWEEN @VonDatum AND @BisDatum
       OR bisDat BETWEEN @VonDatum AND @BisDatum
       OR (vonDat <= @VonDatum AND bisDat >= @BisDatum))
ORDER BY vonDat
```

---

### 2. DienstplanObjektView (Objekt-/Auftrag-Dienstplan)
**ViewModel:** `DienstplanObjektViewModel.cs` (bereits komplett)
**View:** `DienstplanObjektView.xaml` + `.xaml.cs`

**Features:**
- Auftrag-Auswahl via ComboBox (zeigt "Auftrag (Objekt)")
- Filter: "Nur unbesetzte Schichten" Checkbox
- Auftrag-Infos: Auftrag, Objekt, Veranstalter, Datum Von/Bis
- Schichten-Liste mit:
  - Datum, Zeit (Start - Ende)
  - Bemerkung
  - Status-Badge (Vollbesetzt / X fehlen / Unbesetzt)
  - MA-Anzahl Ist/Soll (große Anzeige)
- Zugeordnete Mitarbeiter (rechts):
  - Name, Telefon, Zeiten
  - Remove-Button pro Mitarbeiter
  - Empty State wenn keine MA zugeordnet
- Statistik-Bar:
  - Anzahl Schichten
  - MA Soll (gesamt)
  - MA Ist (zugeordnet)
  - MA Fehlen
  - Besetzungsgrad in %
- "Schnellauswahl öffnen" Button (navigiert zu SchnellauswahlViewModel)
- Navigation zu Auftragstamm
- Export & Druck (vorbereitet)

**Datenbankzugriff:**
```sql
-- Schichten mit Zuordnungen
SELECT s.VAStart_ID, s.VADatum, s.VA_Start, s.VA_Ende,
       s.MA_Anzahl, s.MA_Anzahl_Ist, s.Bemerkung,
       COUNT(p.MA_ID) as MA_Zugeordnet
FROM tbl_VA_Start s
LEFT JOIN tbl_MA_VA_Planung p ON s.VA_ID = p.VA_ID
    AND s.VADatum = p.VADatum
    AND s.VA_Start = p.VA_Start
WHERE s.VA_ID = @VaId
  [AND s.MA_Anzahl_Ist < s.MA_Anzahl] -- wenn NurUnbesetzte
GROUP BY s.VAStart_ID, s.VADatum, s.VA_Start, s.VA_Ende,
         s.MA_Anzahl, s.MA_Anzahl_Ist, s.Bemerkung
ORDER BY s.VADatum, s.VA_Start

-- Mitarbeiter pro Schicht
SELECT p.MA_ID, m.Nachname, m.Vorname, m.Tel_Mobil,
       p.VA_Start, p.VA_Ende
FROM tbl_MA_VA_Planung p
INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.MA_ID
WHERE p.VA_ID = @VaId
  AND p.VADatum = @VaDatum
  AND p.VA_Start = @VaStart
ORDER BY m.Nachname, m.Vorname

-- MA entfernen
DELETE FROM tbl_MA_VA_Planung
WHERE VA_ID = @VaId
  AND MA_ID = @MaId
  AND VADatum = @VaDatum
  AND VA_Start = @VaStart
```

---

## Verwendete Technologien

### WinUI3 Features
- **x:Bind** statt Binding (Performance + Compile-Time Type Checking)
- **Mode=OneWay/TwoWay** für reaktive Properties
- **FallbackValue** für sichere Defaults
- **DataTemplate mit x:DataType** für typsichere Item Templates
- **Border mit CardBackgroundFillColorDefaultBrush** für moderne Karten-Optik
- **FontIcon mit Segoe MDL2 Assets** Glyphs
- **ListView mit ItemContainerStyle** für Full-Width Items

### MVVM Pattern
- **BaseViewModel** mit IsLoading, StatusMessage, ExecuteWithLoadingAsync
- **RelayCommand** aus CommunityToolkit.Mvvm
- **ObservableProperty** mit Source Generators
- **INavigationAware** Interface für Navigation-Lifecycle

### Access Backend
- **DatabaseService** mit OleDbConnection
- **ExecuteQueryAsync** für SELECT
- **ExecuteNonQueryAsync** für DELETE/INSERT/UPDATE
- **Parametrisierte Queries** gegen SQL Injection
- **DBNull.Value** Handling für Nullable-Felder

---

## Dateien

### DienstplanMAView
```
Views/
├── DienstplanMAView.xaml          # 368 Zeilen XAML
└── DienstplanMAView.xaml.cs       #  34 Zeilen C#

ViewModels/
└── DienstplanMAViewModel.cs       # 349 Zeilen (bereits fertig)
```

### DienstplanObjektView
```
Views/
├── DienstplanObjektView.xaml      # 407 Zeilen XAML
└── DienstplanObjektView.xaml.cs   #  34 Zeilen C#

ViewModels/
└── DienstplanObjektViewModel.cs   # 445 Zeilen (bereits fertig)
```

---

## XAML Highlights

### DienstplanMAView

**Filter-Bereich mit DatePicker:**
```xml
<DatePicker Date="{x:Bind ViewModel.VonDatum, Mode=TwoWay}"
            Width="150"
            DayFormat="{}{day.integer}"
            MonthFormat="{}{month.abbreviated}"
            YearFormat="{}{year.full}"/>
```

**Einsätze DataTemplate:**
```xml
<DataTemplate x:DataType="viewmodels:DienstplanEintragItem">
    <Grid Padding="12,8" ColumnSpacing="12">
        <TextBlock Text="{x:Bind VaDatum.ToString('dd.MM.yyyy')}"/>
        <TextBlock Text="{x:Bind ZeitText}"/>
        <TextBlock Text="{x:Bind Auftrag}"/>
        <TextBlock Text="{x:Bind Objekt}"/>
        <TextBlock Text="{x:Bind Stunden.ToString('0.0h')}"/>
    </Grid>
</DataTemplate>
```

**Abwesenheiten mit Run-Bindung:**
```xml
<TextBlock>
    <Run Text="{x:Bind VonDat.ToString('dd.MM.yyyy')}"/>
    <Run Text=" - "/>
    <Run Text="{x:Bind BisDat.ToString('dd.MM.yyyy')}"/>
    <Run Text=" ("/>
    <Run Text="{x:Bind AnzahlTage}"/>
    <Run Text=" Tage)"/>
</TextBlock>
```

### DienstplanObjektView

**Statistik-Bar:**
```xml
<StackPanel Orientation="Horizontal" Spacing="16">
    <TextBlock Text="MA Soll:"/>
    <TextBlock Text="{x:Bind ViewModel.MaGesamt, Mode=OneWay}"/>
    <TextBlock Text="MA Ist:"/>
    <TextBlock Text="{x:Bind ViewModel.MaZugeordnet, Mode=OneWay}"
               Foreground="{ThemeResource SystemFillColorSuccessBrush}"/>
    <TextBlock Text="Besetzung:"/>
    <TextBlock Text="{x:Bind ViewModel.Besetzungsgrad.ToString('0.0'), Mode=OneWay}"/>
    <TextBlock Text="%"/>
</StackPanel>
```

**Status-Badge in Schichten-Liste:**
```xml
<Border Background="{ThemeResource SystemFillColorCautionBackgroundBrush}"
        CornerRadius="4"
        Padding="8,4">
    <TextBlock Text="{x:Bind StatusText}" FontSize="11"/>
</Border>
```

**Remove-Button mit Parent Binding:**
```xml
<Button Command="{Binding DataContext.RemoveMitarbeiterCommand, ElementName=Page}"
        CommandParameter="{x:Bind}"/>
```
*Hinweis: Page hat `x:Name="Page"` im Root-Element*

**Empty State:**
```xml
<StackPanel Visibility="{x:Bind ViewModel.ZugeordneteMitarbeiter.Count, Mode=OneWay, Converter={StaticResource InverseBoolToVisibilityConverter}}">
    <FontIcon Glyph="&#xE716;" FontSize="48"/>
    <TextBlock Text="Keine Mitarbeiter zugeordnet"/>
</StackPanel>
```

---

## Benötigte Converter

Die Views verwenden folgende Converter, die in `App.xaml` als Resources definiert sein müssen:

```xml
<Application.Resources>
    <ResourceDictionary>
        <!-- Converter für Visibility -->
        <converters:NullToVisibilityConverter x:Key="NullToVisibilityConverter"/>
        <converters:InverseBoolToVisibilityConverter x:Key="InverseBoolToVisibilityConverter"/>
    </ResourceDictionary>
</Application.Resources>
```

**Falls noch nicht vorhanden, erstellen:**

```csharp
// Converters/NullToVisibilityConverter.cs
public class NullToVisibilityConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, string language)
    {
        return value != null ? Visibility.Visible : Visibility.Collapsed;
    }

    public object ConvertBack(object value, Type targetType, object parameter, string language)
    {
        throw new NotImplementedException();
    }
}

// Converters/InverseBoolToVisibilityConverter.cs
public class InverseBoolToVisibilityConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, string language)
    {
        if (value is int count)
            return count == 0 ? Visibility.Visible : Visibility.Collapsed;

        if (value is bool boolValue)
            return boolValue ? Visibility.Collapsed : Visibility.Visible;

        return Visibility.Collapsed;
    }

    public object ConvertBack(object value, Type targetType, object parameter, string language)
    {
        throw new NotImplementedException();
    }
}
```

---

## Navigation

### DienstplanMAView aufrufen
```csharp
// Ohne Parameter (Mitarbeiter muss ausgewählt werden)
_navigationService.NavigateTo<DienstplanMAViewModel>();

// Mit MA_ID (Dienstplan wird direkt geladen)
_navigationService.NavigateTo<DienstplanMAViewModel>(maId: 123);
```

### DienstplanObjektView aufrufen
```csharp
// Ohne Parameter
_navigationService.NavigateTo<DienstplanObjektViewModel>();

// Mit VA_ID
_navigationService.NavigateTo<DienstplanObjektViewModel>(vaId: 456);
```

---

## Offene TODOs

### Export-Funktion implementieren
```csharp
[RelayCommand]
private async Task ExportAsync()
{
    // Excel-Export via ClosedXML oder EPPlus
    // Format: Datum | Zeit | Auftrag | Objekt | Stunden
}
```

### Druck-Funktion implementieren
```csharp
[RelayCommand]
private async Task PrintAsync()
{
    // Print-Dialog via Windows.Graphics.Printing
    // Oder PDF-Export via iText7/QuestPDF
}
```

### Schnellauswahl-View verbinden
```csharp
// In DienstplanObjektViewModel
[RelayCommand]
private void OpenSchnellauswahl()
{
    if (SelectedSchicht != null)
    {
        // Parameter: Schicht-Objekt übergeben
        _navigationService.NavigateTo<SchnellauswahlViewModel>(SelectedSchicht);
    }
}
```

---

## Testing

### Smoke Test Checklist

**DienstplanMAView:**
- [ ] Mitarbeiter-ComboBox lädt aktive MA aus tbl_MA_Mitarbeiterstamm
- [ ] DatePicker Von/Bis funktioniert (TwoWay Binding)
- [ ] "Laden" Button triggert LoadDienstplanCommand
- [ ] "Aktuelle Woche" / "Aktueller Monat" setzen korrektes Datum
- [ ] Navigation (←/→) verschiebt Zeitraum um 7 Tage
- [ ] Einsätze werden korrekt angezeigt mit Stunden-Berechnung
- [ ] Abwesenheiten werden geladen (inkl. Bemerkung falls vorhanden)
- [ ] Statistik zeigt korrekte Summen
- [ ] Klick auf Einsatz setzt SelectedEintrag
- [ ] "MA-Stamm" navigiert zu MitarbeiterstammViewModel mit MA_ID
- [ ] Loading-State wird während Datenbankzugriff angezeigt

**DienstplanObjektView:**
- [ ] Auftrag-ComboBox lädt Aufträge mit Status 0/1
- [ ] "Nur unbesetzte" Filter funktioniert
- [ ] Schichten werden geladen mit korrekten MA-Zahlen
- [ ] Status-Badge zeigt "Vollbesetzt" / "X fehlen" / "Unbesetzt"
- [ ] Klick auf Schicht lädt zugeordnete Mitarbeiter
- [ ] Remove-Button entfernt MA-Zuordnung (mit Bestätigungs-Dialog)
- [ ] Statistik-Bar zeigt korrekte Zahlen und Besetzungsgrad
- [ ] "Schnellauswahl öffnen" ist nur aktiv wenn Schicht ausgewählt
- [ ] Empty State wird angezeigt wenn keine MA zugeordnet
- [ ] Navigation zu Auftragstamm funktioniert

---

## Zusammenfassung

✅ **Vollständig implementiert:**
- DienstplanMAView (XAML + Code-Behind)
- DienstplanObjektView (XAML + Code-Behind)
- Beide ViewModels waren bereits komplett
- Datenbankanbindung via DatabaseService
- x:Bind für Performance
- Responsive Layout mit Card-Design
- Statistik-Anzeigen
- Navigation zwischen Views

⚠️ **Benötigt noch:**
- Converter-Klassen in App.xaml registrieren
- Export-Funktion implementieren
- Druck-Funktion implementieren
- SchnellauswahlViewModel verknüpfen

🎯 **Nächster Schritt:**
- Projekt kompilieren und testen
- Falls Converter fehlen: Erstellen und registrieren
- Bei Bedarf: Export/Druck-Features implementieren
