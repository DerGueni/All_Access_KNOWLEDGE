# CONSYS WinUI3 Models - Verwendungsbeispiele

## 1. Mitarbeiter erstellen und validieren

```csharp
using ConsysWinUI.Models;

// Neuen Mitarbeiter erstellen
var mitarbeiter = new Mitarbeiter
{
    Nachname = "Mustermann",
    Vorname = "Max",
    Email = "max.mustermann@example.com",
    TelMobil = "+49 170 1234567",
    Geburtsdatum = new DateTime(1990, 5, 15),
    IstAktiv = true,
    IstSchichtleiter = true
};

// Audit-Tracking
mitarbeiter.MarkAsCreated("GSiegert");

// Validierung
mitarbeiter.Validate();

if (mitarbeiter.HasErrors)
{
    var errors = mitarbeiter.GetErrors(nameof(Mitarbeiter.Email));
    foreach (var error in errors)
    {
        Console.WriteLine(error.ErrorMessage);
    }
}

// Computed Properties verwenden
Console.WriteLine($"Name: {mitarbeiter.VollstaendigerName}");
Console.WriteLine($"Alter: {mitarbeiter.Alter}");
Console.WriteLine($"Status: {mitarbeiter.StatusText}");
```

## 2. Kunde mit Branche

```csharp
// Branche erstellen
var branche = new KundeBranche
{
    BrancheId = 1,
    Bezeichnung = "Eventmanagement",
    IstAktiv = true
};

// Kunde erstellen
var kunde = new Kunde
{
    KunFirma = "Event GmbH",
    KunFirmaZusatz = "Veranstaltungsservice",
    KunStrasse = "Musterstraße 123",
    KunPlz = "12345",
    KunOrt = "Berlin",
    KunEmail = "info@event-gmbh.de",
    KunBrancheId = 1,
    Branche = branche,
    KunIstAktiv = true
};

kunde.MarkAsCreated("GSiegert");

// Formatierte Ausgaben
Console.WriteLine($"Firma: {kunde.VollstaendigerFirmenname}");
Console.WriteLine($"Adresse: {kunde.VollstaendigeAdresse}");
```

## 3. Auftrag mit Schichten und Tagen

```csharp
// Veranstalter
var veranstalter = new Veranstalter
{
    VeranstalterId = 1,
    Name = "Event AG",
    Kontaktperson = "Anna Schmidt",
    Telefon = "+49 30 12345678",
    IstAktiv = true
};

// Objekt
var objekt = new Objekt
{
    ObjektId = "OBJ-001",
    Bezeichnung = "Messe Berlin",
    Strasse = "Messedamm 22",
    Plz = "14055",
    Ort = "Berlin",
    IstAktiv = true
};

// Auftrag erstellen
var auftrag = new Auftrag
{
    VaId = 1,
    AuftragNr = "VA-2025-001", // WICHTIG: AuftragNr, nicht Auftrag!
    AuftragBezeichnung = "Technologiemesse 2025",
    VeranstalterId = 1,
    Veranstalter = veranstalter,
    ObjektId = "OBJ-001",
    Objekt = objekt,
    DatVaVon = new DateTime(2025, 3, 15),
    DatVaBis = new DateTime(2025, 3, 17),
    Treffpunkt = "Eingang Ost",
    TreffpunktZeit = "07:30",
    IstAktiv = true
};

// Tage hinzufügen
auftrag.Tage.Add(new AuftragTag
{
    VaId = 1,
    VaDatum = new DateTime(2025, 3, 15),
    IstAktiv = true
});

auftrag.Tage.Add(new AuftragTag
{
    VaId = 1,
    VaDatum = new DateTime(2025, 3, 16),
    IstAktiv = true
});

// Schicht erstellen
var schicht = new Schicht
{
    VaStartId = 1,
    VaId = 1,
    VaDatum = new DateTime(2025, 3, 15),
    VaStart = new TimeSpan(8, 0, 0),
    VaEnde = new TimeSpan(16, 0, 0),
    MaAnzahl = 10,
    MaAnzahlIst = 0,
    IstAktiv = true
};

auftrag.Schichten.Add(schicht);

// Mitarbeiter zuordnen
var zuordnung = new MitarbeiterZuordnung
{
    VaId = 1,
    VaStartId = 1,
    MaId = mitarbeiter.MaId,
    Mitarbeiter = mitarbeiter,
    VaDatum = new DateTime(2025, 3, 15),
    VaStart = new TimeSpan(8, 0, 0),
    VaEnde = new TimeSpan(16, 0, 0),
    IstBestaetigt = false
};

zuordnung.MarkAsCreated("GSiegert");
schicht.MitarbeiterZuordnungen.Add(zuordnung);
schicht.MaAnzahlIst++;

// Computed Properties
Console.WriteLine($"Auftrag: {auftrag.VollstaendigeBezeichnung}");
Console.WriteLine($"Dauer: {auftrag.Dauer} Tage");
Console.WriteLine($"Anzahl Schichten: {auftrag.AnzahlSchichten}");
Console.WriteLine($"Schicht: {schicht.SchichtBezeichnung}");
Console.WriteLine($"Dauer: {schicht.Dauer:F1} Stunden");
Console.WriteLine($"Auslastung: {schicht.Auslastung:F1}%");
```

## 4. Dienstplan-Eintrag

```csharp
// Dienstplan-Eintrag für Mitarbeiter-Ansicht
var dpEintrag = new DienstplanEintrag
{
    MaId = mitarbeiter.MaId,
    MitarbeiterName = mitarbeiter.Anzeigename,
    VaId = auftrag.VaId,
    AuftragNr = auftrag.AuftragNr,
    AuftragBezeichnung = auftrag.AuftragBezeichnung,
    ObjektBezeichnung = objekt.Bezeichnung,
    Datum = new DateTime(2025, 3, 15),
    Startzeit = new TimeSpan(8, 0, 0),
    Endzeit = new TimeSpan(16, 0, 0),
    StundenGesamt = 8.0,
    IstBestaetigt = false,
    Treffpunkt = auftrag.Treffpunkt,
    Dienstkleidung = auftrag.Dienstkleidung
};

// Formatierte Ausgaben
Console.WriteLine($"Datum: {dpEintrag.DatumFormatiert}");
Console.WriteLine($"Zeit: {dpEintrag.Zeitraum}");
Console.WriteLine($"Einsatz: {dpEintrag.EinsatzBezeichnung}");
Console.WriteLine($"Status: {dpEintrag.BestaetigungsStatus}");
```

## 5. Dienstplan-Mitarbeiter (Gruppierung)

```csharp
var dpMitarbeiter = new DienstplanMitarbeiter
{
    MaId = mitarbeiter.MaId,
    Nachname = mitarbeiter.Nachname,
    Vorname = mitarbeiter.Vorname,
    Telefon = mitarbeiter.TelMobil,
    IstAktiv = mitarbeiter.IstAktiv
};

// Einträge hinzufügen
dpMitarbeiter.Eintraege.Add(dpEintrag);

// Aggregierte Daten
Console.WriteLine($"MA: {dpMitarbeiter.VollstaendigerName}");
Console.WriteLine($"Einsätze: {dpMitarbeiter.AnzahlEinsaetze}");
Console.WriteLine($"Gesamt-Stunden: {dpMitarbeiter.GesamtStunden:F1}h");
```

## 6. Abwesenheit

```csharp
// Abwesenheits-Grund
var grund = new AbwesenheitsGrund
{
    GrundId = 1,
    Bezeichnung = "Urlaub",
    Kurzbezeichnung = "URL",
    Farbcode = "#28A745",
    IstBezahlt = true,
    IstAktiv = true
};

// Abwesenheit erstellen
var abwesenheit = new Abwesenheit
{
    MaId = mitarbeiter.MaId,
    Mitarbeiter = mitarbeiter,
    VonDatum = new DateTime(2025, 7, 1),
    BisDatum = new DateTime(2025, 7, 14),
    GrundId = 1,
    Grund = grund,
    Bemerkungen = "Sommerurlaub",
    IstGenehmigt = false
};

abwesenheit.MarkAsCreated("GSiegert");

Console.WriteLine($"Abwesenheit: {abwesenheit.ZeitraumFormatiert}");
Console.WriteLine($"Dauer: {abwesenheit.Dauer} Tage");
Console.WriteLine($"Status: {abwesenheit.GenehmigungsStatus}");
```

## 7. Planungs-Anfrage

```csharp
var anfrage = new PlanungsAnfrage
{
    AnfrageId = 1,
    VaId = auftrag.VaId,
    VaStartId = schicht.VaStartId,
    Datum = new DateTime(2025, 3, 15),
    Startzeit = new TimeSpan(8, 0, 0),
    Endzeit = new TimeSpan(16, 0, 0),
    AnzahlMitarbeiterBenoeligt = 10,
    AnzahlMitarbeiterZugeordnet = 5,
    IstSchichtleiterErforderlich = true,
    IstGeschlossen = false
};

anfrage.MarkAsCreated("GSiegert");

Console.WriteLine($"Offen: {anfrage.MitarbeiterOffen} Mitarbeiter");
Console.WriteLine($"Auslastung: {anfrage.AuslastungProzent:F1}%");
Console.WriteLine($"Vollständig: {anfrage.IstVollstaendigBesetzt}");
```

## 8. Verfügbarkeits-Prüfung

```csharp
var verfuegbarkeit = new VerfuegbarkeitInfo
{
    MaId = mitarbeiter.MaId,
    MitarbeiterName = mitarbeiter.Anzeigename,
    Datum = new DateTime(2025, 3, 15),
    Startzeit = new TimeSpan(8, 0, 0),
    Endzeit = new TimeSpan(16, 0, 0),
    IstVerfuegbar = true,
    HatKonflikt = false
};

verfuegbarkeit.Qualifikationen.Add("Schichtleiter");
verfuegbarkeit.Qualifikationen.Add("Ersthelfer");

Console.WriteLine($"Status: {verfuegbarkeit.StatusText}");
Console.WriteLine($"Farbe: {verfuegbarkeit.AmpelFarbe}");
```

## 9. Planungs-Board-Eintrag

```csharp
var boardEintrag = new PlanungsBoardEintrag
{
    VaId = auftrag.VaId,
    AuftragNr = auftrag.AuftragNr,
    AuftragBezeichnung = auftrag.AuftragBezeichnung,
    ObjektBezeichnung = objekt.Bezeichnung,
    Datum = new DateTime(2025, 3, 15),
    AnzahlSchichten = 3,
    MitarbeiterBenoeligt = 30,
    MitarbeiterZugeordnet = 25,
    MitarbeiterBestaetigt = 20,
    AuslastungProzent = 83.3,
    IstKritisch = false
};

boardEintrag.Schichten.Add(schicht);

Console.WriteLine($"Status: {boardEintrag.StatusText}");
Console.WriteLine($"Farbe: {boardEintrag.StatusFarbe}");
Console.WriteLine($"Offen: {boardEintrag.MitarbeiterOffen}");
```

## 10. Schnellauswahl-Mitarbeiter

```csharp
var schnellMA = new SchnellauswahlMitarbeiter
{
    MaId = mitarbeiter.MaId,
    Nachname = mitarbeiter.Nachname,
    Vorname = mitarbeiter.Vorname,
    Telefon = mitarbeiter.TelMobil,
    IstAktiv = mitarbeiter.IstAktiv,
    IstSchichtleiter = mitarbeiter.IstSchichtleiter,
    IstVerfuegbar = true,
    AnzahlEinsaetzeImZeitraum = 5,
    StundenImZeitraum = 42.5,
    LetzterEinsatz = new DateTime(2025, 3, 10)
};

schnellMA.Qualifikationen.Add("Schichtleiter");
schnellMA.Qualifikationen.Add("Ersthelfer");

Console.WriteLine($"Name: {schnellMA.Anzeigename}");
Console.WriteLine($"Verfügbar: {schnellMA.VerfuegbarkeitsFarbe}");
Console.WriteLine($"Auslastung: {schnellMA.AuslastungsText}");
```

## 11. Filter verwenden

```csharp
// Mitarbeiter-Filter
var maFilter = new MitarbeiterFilter
{
    NurAktive = true,
    NurSchichtleiter = true,
    Suchbegriff = "Müller",
    VonDatum = new DateTime(2025, 1, 1),
    BisDatum = new DateTime(2025, 12, 31),
    Limit = 50
};

// Auftrag-Filter
var vaFilter = new AuftragFilter
{
    NurAktive = true,
    VeranstalterId = 1,
    VonDatum = new DateTime(2025, 3, 1),
    BisDatum = new DateTime(2025, 3, 31),
    NurMitOffenenAnfragen = true
};

// Dienstplan-Filter
var dpFilter = new DienstplanFilter
{
    MitarbeiterId = mitarbeiter.MaId,
    VonDatum = new DateTime(2025, 3, 1),
    BisDatum = new DateTime(2025, 3, 31),
    NurBestaetigt = false
};

// Filter zurücksetzen
maFilter.Reset();
```

## 12. Lookup-Items für Dropdowns

```csharp
// Einfache Lookup-Liste
var statusListe = new List<LookupItem>
{
    new(1, "Aktiv", "A"),
    new(2, "Inaktiv", "I"),
    new(3, "Archiviert", "AR")
};

// In ComboBox binden
// ItemsSource = statusListe
// DisplayMemberPath = "Bezeichnung"
// SelectedValuePath = "Id"
```

## 13. Event-Handling mit PropertyChanged

```csharp
// Property-Changed Event abonnieren
mitarbeiter.PropertyChanged += (sender, e) =>
{
    if (e.PropertyName == nameof(Mitarbeiter.Nachname) ||
        e.PropertyName == nameof(Mitarbeiter.Vorname))
    {
        Console.WriteLine($"Name geändert: {mitarbeiter.VollstaendigerName}");
    }
};

// Bei Änderung wird Event automatisch gefeuert
mitarbeiter.Nachname = "Schmidt"; // → Event wird gefeuert
```

## 14. Collection-Changed Event

```csharp
// Collection-Changed Event abonnieren
auftrag.Schichten.CollectionChanged += (sender, e) =>
{
    Console.WriteLine($"Anzahl Schichten: {auftrag.Schichten.Count}");

    if (e.Action == System.Collections.Specialized.NotifyCollectionChangedAction.Add)
    {
        foreach (Schicht s in e.NewItems!)
        {
            Console.WriteLine($"Neue Schicht: {s.SchichtBezeichnung}");
        }
    }
};

auftrag.Schichten.Add(schicht); // → Event wird gefeuert
```

## 15. Audit-Entity Basis-Klassen

```csharp
// Eigene Entität mit Audit-Tracking
public partial class MeineEntitaet : AuditableEntity
{
    [ObservableProperty]
    private string? _name;
}

var entitaet = new MeineEntitaet { Name = "Test" };
entitaet.MarkAsCreated("GSiegert");

Console.WriteLine($"Erstellt am: {entitaet.ErstelltAm}");
Console.WriteLine($"Erstellt von: {entitaet.ErstelltVon}");

// Ändern
entitaet.Name = "Test geändert";
entitaet.MarkAsModified("GSiegert");

Console.WriteLine($"Geändert am: {entitaet.GeaendertAm}");
```

## Best Practices Zusammenfassung

1. **Immer validieren** vor Speichern in DB
2. **Audit-Tracking** bei Neu/Änderung nutzen
3. **Computed Properties** für UI-Formatierung
4. **ObservableCollection** für dynamische Listen
5. **Filter-Klassen** für Datenbankabfragen
6. **PropertyChanged** für UI-Reaktivität
7. **Namenskonventionen** beibehalten (z.B. `AuftragNr` statt `Auftrag`)
