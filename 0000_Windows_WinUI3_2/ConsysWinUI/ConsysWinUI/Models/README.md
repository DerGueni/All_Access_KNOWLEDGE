# CONSYS WinUI3 - Models Dokumentation

## Übersicht

Alle Models nutzen **CommunityToolkit.Mvvm** für automatische INotifyPropertyChanged-Implementierung und Validierung.

## Haupt-Models

### Mitarbeiter.cs
**Mapping:** `tbl_MA_Mitarbeiterstamm`

**Features:**
- Vollständige Mitarbeiter-Stammdaten
- Validierung für Pflichtfelder (Nachname, Vorname, E-Mail)
- Automatische Berechnung von Alter und Vollständigem Namen
- Erbt von `ObservableValidator` für Validierung

**Properties:**
- `MaId` - Eindeutige ID
- `Nachname`, `Vorname` - Name (Required)
- `TelMobil`, `TelPrivat`, `TelGeschaeft` - Kontaktdaten
- `Email` - E-Mail (mit Validierung)
- `Strasse`, `Plz`, `Ort`, `Land` - Adresse
- `Geburtsdatum`, `Geburtsort` - Geburtsdaten
- `IstAktiv` - Status
- `IstSchichtleiter`, `IstObjektleiter` - Rollen
- Audit-Felder: `ErstelltAm`, `GeaendertAm`, etc.

**Computed Properties:**
- `VollstaendigerName` - "Nachname, Vorname"
- `Anzeigename` - "Vorname Nachname"
- `Alter` - Berechnet aus Geburtsdatum
- `StatusText` - "Aktiv" / "Inaktiv"

### Kunde.cs
**Mapping:** `tbl_KD_Kundenstamm`

**Features:**
- Kunden-Stammdaten mit Branchen-Zuordnung
- Validierung für Pflichtfelder
- Separate `KundeBranche` Klasse

**Properties:**
- `KunId` - Eindeutige ID
- `KunFirma` - Firmenname (Required)
- `KunFirmaZusatz` - Firmenzusatz
- Adress-Felder: `KunStrasse`, `KunPlz`, `KunOrt`, `KunLand`
- Kontakt: `KunTelefon`, `KunEmail`, `KunWebsite`
- Finanzen: `KunUstIdNr`, `KunSteuernummer`
- `KunBrancheId` - FK zu KundeBranche
- `KunIstAktiv` - Status

**Computed Properties:**
- `VollstaendigerFirmenname` - Mit Zusatz
- `VollstaendigeAdresse` - Formatierte Adresse
- `StatusText` - "Aktiv" / "Inaktiv"

### Auftrag.cs
**Mapping:** `tbl_VA_Auftragstamm`

**WICHTIG:** Property heißt `AuftragNr` (NICHT `Auftrag`) wegen Namenskonflikt!

**Features:**
- Auftrags-Stammdaten mit Schichten und Tagen
- Collections für `AuftragTag`, `Schicht`, `MitarbeiterZuordnung`
- Separate Klassen: `Veranstalter`, `Objekt`

**Properties:**
- `VaId` - Eindeutige ID
- `AuftragNr` - Auftragsnummer (Required)
- `AuftragBezeichnung` - Beschreibung
- `VeranstalterId`, `Veranstalter` - FK und Navigation
- `ObjektId`, `Objekt` - FK und Navigation
- `DatVaVon`, `DatVaBis` - Zeitraum
- `Treffpunkt`, `TreffpunktZeit` - Einsatz-Details
- `Tage` - Collection von `AuftragTag`
- `Schichten` - Collection von `Schicht`

**Sub-Models:**
- `AuftragTag` - Einzelne Tage (tbl_VA_AnzTage)
- `Schicht` - Schichten pro Tag (tbl_VA_Start)
- `MitarbeiterZuordnung` - MA-Zuordnungen (tbl_MA_VA_Planung)
- `Veranstalter` - Veranstalter-Stamm
- `Objekt` - Objekt-Stamm

### DienstplanEintrag.cs
**Zweck:** Optimierte Models für Dienstplan-Ansichten

**Models:**
- `DienstplanEintrag` - Einzelner Einsatz
- `DienstplanMitarbeiter` - Gruppierung nach MA
- `DienstplanObjekt` - Gruppierung nach Objekt
- `Abwesenheit` - Mapping zu tbl_MA_NVerfuegZeiten
- `AbwesenheitsGrund` - Mapping zu tbl_DP_Grund

**Features:**
- Kombinierte Daten aus mehreren Tabellen
- Formatierte Ausgaben für UI
- Aggregierte Berechnungen (Gesamt-Stunden, Anzahlen)

## Planungs-Models

### PlanungModels.cs
**Zweck:** Spezielle Models für das Planungssystem

**Models:**
- `PlanungsAnfrage` - Mapping zu tbl_VA_Anfragen
- `VerfuegbarkeitInfo` - Verfügbarkeits-Prüfung für MA
- `PlanungsBoardEintrag` - Dashboard/Board-Ansichten
- `SchnellauswahlMitarbeiter` - Erweiterte MA-Info für Schnellauswahl
- `EinsatzUebersicht` - Zusammenfassung von Einsätzen

**Features:**
- Ampel-Farben für Status-Anzeige
- Auslastungs-Berechnungen
- Konflikt-Erkennung

## Basis-Models

### BaseModels.cs
**Zweck:** Gemeinsame Basis-Klassen und Utilities

**Klassen:**
- `AuditableEntity` - Basis mit Audit-Feldern (ErstelltAm, GeaendertAm)
- `ActivatableEntity` - Erbt von AuditableEntity, fügt IstAktiv hinzu
- `LookupItem` - Einfaches Key-Value für Dropdowns
- `ValidationResult` - Validierungs-Ergebnis
- `FilterBase` - Basis für alle Filter-Klassen
- `MitarbeiterFilter` - Filter für Mitarbeiter-Abfragen
- `AuftragFilter` - Filter für Auftrags-Abfragen
- `DienstplanFilter` - Filter für Dienstplan-Abfragen

**Verwendung:**
```csharp
// Audit-Tracking
mitarbeiter.MarkAsCreated("GSiegert");
mitarbeiter.MarkAsModified("GSiegert");

// Aktivierung/Deaktivierung
kunde.Activate("GSiegert");
kunde.Deactivate("GSiegert");

// Filter
var filter = new MitarbeiterFilter
{
    NurAktive = true,
    NurSchichtleiter = true,
    Suchbegriff = "Müller"
};
```

## Verwendung mit CommunityToolkit.Mvvm

### [ObservableProperty]
Generiert automatisch INotifyPropertyChanged:

```csharp
[ObservableProperty]
private string? _nachname;

// Wird zu:
public string? Nachname
{
    get => _nachname;
    set => SetProperty(ref _nachname, value);
}
```

### ObservableValidator
Ermöglicht Data Annotations Validierung:

```csharp
[ObservableProperty]
[Required(ErrorMessage = "Nachname ist erforderlich")]
[MaxLength(100)]
private string? _nachname;

// Validierung:
mitarbeiter.Validate(); // Validiert alle Properties
var hasErrors = mitarbeiter.HasErrors;
var errors = mitarbeiter.GetErrors(nameof(Nachname));
```

## Namenskonventionen

### Access-Mapping
- **MA_** - Mitarbeiter (tbl_MA_Mitarbeiterstamm)
- **KD_** - Kunde (tbl_KD_Kundenstamm)
- **VA_** - Veranstaltung/Auftrag (tbl_VA_Auftragstamm)
- **OB_** - Objekt (tbl_OB_Objekt)
- **DP_** - Dienstplan (tbl_DP_Grund)

### Property-Namen
- Deutsche Bezeichnungen (entsprechend Access-Feldern)
- CamelCase für Properties
- Prefixes bleiben (z.B. `KunFirma`, nicht `Firma`)

### Computed Properties
- Keine [ObservableProperty] Attribute
- Nur Getter
- Beispiele: `VollstaendigerName`, `StatusText`, `Alter`

## Best Practices

### 1. Validierung vor Speichern
```csharp
mitarbeiter.Validate();
if (mitarbeiter.HasErrors)
{
    var errors = mitarbeiter.GetErrors();
    // Fehler anzeigen
    return;
}
```

### 2. Audit-Tracking
```csharp
// Bei Neu-Erstellung
mitarbeiter.MarkAsCreated(App.CurrentUser);

// Bei Änderung
mitarbeiter.MarkAsModified(App.CurrentUser);
```

### 3. Collections
```csharp
// ObservableCollection für UI-Binding
auftrag.Schichten.Add(neueSchicht);
auftrag.Tage.Clear();
```

### 4. Computed Properties
```csharp
// Kein Setter für berechnete Werte
public int? Alter => /* Berechnung */;

// Bei Änderung der Basis-Property wird automatisch OnPropertyChanged gefeuert
```

## Abhängigkeiten

- **CommunityToolkit.Mvvm** (v8.2.2) - MVVM Patterns
- **System.ComponentModel.DataAnnotations** - Validierung
- **.NET 8.0** - Target Framework

## Migration von WPF

Die Models wurden von der WPF-Version übernommen und erweitert:

**WPF:**
```csharp
public class Auftrag
{
    public int VA_ID { get; set; }
    public string? AuftragName { get; set; }
}
```

**WinUI3:**
```csharp
public partial class Auftrag : ObservableValidator
{
    [ObservableProperty]
    [Required]
    private string? _auftragNr;

    // + Validierung, Audit-Felder, Computed Properties
}
```

## Nächste Schritte

1. **Services erstellen** - Datenbankzugriff für Models
2. **ViewModels erstellen** - MVVM-Schicht über Models
3. **Views erstellen** - UI-Komponenten mit Binding
4. **Tests schreiben** - Unit-Tests für Model-Validierung
