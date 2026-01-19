using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.Collections.ObjectModel;

namespace ConsysWinUI.Models;

/// <summary>
/// Dienstplan-Eintrag Model für Dienstplan-Ansichten
/// Kombiniert Daten aus mehreren Tabellen für optimierte Darstellung
/// </summary>
public partial class DienstplanEintrag : ObservableObject
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private int _maId;

    [ObservableProperty]
    private string? _mitarbeiterName;

    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    private string? _auftragNr;

    [ObservableProperty]
    private string? _auftragBezeichnung;

    [ObservableProperty]
    private string? _objektBezeichnung;

    [ObservableProperty]
    private DateTime _datum;

    [ObservableProperty]
    private TimeSpan? _startzeit;

    [ObservableProperty]
    private TimeSpan? _endzeit;

    [ObservableProperty]
    private double? _stundenGesamt;

    [ObservableProperty]
    private bool _istBestaetigt;

    [ObservableProperty]
    private string? _bemerkungen;

    [ObservableProperty]
    private string? _treffpunkt;

    [ObservableProperty]
    private string? _dienstkleidung;

    /// <summary>
    /// Formatiertes Datum (z.B. "Mo, 15.01.2025")
    /// </summary>
    public string DatumFormatiert => Datum.ToString("ddd, dd.MM.yyyy");

    /// <summary>
    /// Wochentag
    /// </summary>
    public string Wochentag => Datum.ToString("dddd");

    /// <summary>
    /// Zeitraum (z.B. "08:00 - 16:00")
    /// </summary>
    public string Zeitraum
    {
        get
        {
            if (!Startzeit.HasValue || !Endzeit.HasValue)
                return "Keine Zeit angegeben";

            return $"{Startzeit.Value:hh\\:mm} - {Endzeit.Value:hh\\:mm}";
        }
    }

    /// <summary>
    /// Vollständige Einsatzbezeichnung
    /// </summary>
    public string EinsatzBezeichnung
    {
        get
        {
            var bezeichnung = AuftragBezeichnung ?? AuftragNr ?? "Unbekannt";

            if (!string.IsNullOrWhiteSpace(ObjektBezeichnung))
                bezeichnung += $" @ {ObjektBezeichnung}";

            return bezeichnung;
        }
    }

    /// <summary>
    /// Bestätigungs-Status Text
    /// </summary>
    public string BestaetigungsStatus => IstBestaetigt ? "Bestätigt" : "Offen";
}

/// <summary>
/// Dienstplan-Mitarbeiter Model für Mitarbeiter-Dienstplan-Ansicht
/// Gruppiert Einträge pro Mitarbeiter
/// </summary>
public partial class DienstplanMitarbeiter : ObservableObject
{
    [ObservableProperty]
    private int _maId;

    [ObservableProperty]
    private string? _nachname;

    [ObservableProperty]
    private string? _vorname;

    [ObservableProperty]
    private string? _telefon;

    [ObservableProperty]
    private bool _istAktiv;

    /// <summary>
    /// Dienstplan-Einträge für diesen Mitarbeiter
    /// </summary>
    [ObservableProperty]
    private ObservableCollection<DienstplanEintrag> _eintraege = new();

    /// <summary>
    /// Vollständiger Name
    /// </summary>
    public string VollstaendigerName => $"{Nachname}, {Vorname}";

    /// <summary>
    /// Anzahl Einsätze
    /// </summary>
    public int AnzahlEinsaetze => Eintraege.Count;

    /// <summary>
    /// Gesamt-Stunden
    /// </summary>
    public double GesamtStunden
    {
        get
        {
            double total = 0;
            foreach (var eintrag in Eintraege)
            {
                if (eintrag.StundenGesamt.HasValue)
                    total += eintrag.StundenGesamt.Value;
            }
            return total;
        }
    }
}

/// <summary>
/// Dienstplan-Objekt Model für Objekt-Dienstplan-Ansicht
/// Gruppiert Einträge pro Objekt/Auftrag
/// </summary>
public partial class DienstplanObjekt : ObservableObject
{
    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    private string? _auftragNr;

    [ObservableProperty]
    private string? _auftragBezeichnung;

    [ObservableProperty]
    private string? _objektId;

    [ObservableProperty]
    private string? _objektBezeichnung;

    [ObservableProperty]
    private DateTime? _datumVon;

    [ObservableProperty]
    private DateTime? _datumBis;

    /// <summary>
    /// Dienstplan-Einträge für dieses Objekt
    /// </summary>
    [ObservableProperty]
    private ObservableCollection<DienstplanEintrag> _eintraege = new();

    /// <summary>
    /// Vollständige Bezeichnung
    /// </summary>
    public string VollstaendigeBezeichnung
    {
        get
        {
            var bezeichnung = AuftragBezeichnung ?? AuftragNr ?? "Unbekannt";

            if (!string.IsNullOrWhiteSpace(ObjektBezeichnung))
                bezeichnung += $" @ {ObjektBezeichnung}";

            return bezeichnung;
        }
    }

    /// <summary>
    /// Anzahl zugeordneter Mitarbeiter
    /// </summary>
    public int AnzahlMitarbeiter => Eintraege.Count;

    /// <summary>
    /// Gesamt-Stunden
    /// </summary>
    public double GesamtStunden
    {
        get
        {
            double total = 0;
            foreach (var eintrag in Eintraege)
            {
                if (eintrag.StundenGesamt.HasValue)
                    total += eintrag.StundenGesamt.Value;
            }
            return total;
        }
    }
}

/// <summary>
/// Abwesenheit Model - Mapping zu tbl_MA_NVerfuegZeiten
/// </summary>
public partial class Abwesenheit : ObservableValidator
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private int _maId;

    [ObservableProperty]
    private Mitarbeiter? _mitarbeiter;

    [ObservableProperty]
    private DateTime _vonDatum;

    [ObservableProperty]
    private DateTime _bisDatum;

    [ObservableProperty]
    private int? _grundId;

    [ObservableProperty]
    private AbwesenheitsGrund? _grund;

    [ObservableProperty]
    private string? _bemerkungen;

    [ObservableProperty]
    private bool _istGenehmigt;

    [ObservableProperty]
    private DateTime? _genehmigtAm;

    [ObservableProperty]
    private string? _genehmigtVon;

    [ObservableProperty]
    private DateTime? _erstelltAm;

    [ObservableProperty]
    private string? _erstelltVon;

    /// <summary>
    /// Dauer der Abwesenheit in Tagen
    /// </summary>
    public int Dauer => (BisDatum - VonDatum).Days + 1;

    /// <summary>
    /// Zeitraum formatiert
    /// </summary>
    public string ZeitraumFormatiert => $"{VonDatum:dd.MM.yyyy} - {BisDatum:dd.MM.yyyy}";

    /// <summary>
    /// Genehmigungs-Status
    /// </summary>
    public string GenehmigungsStatus => IstGenehmigt ? "Genehmigt" : "Offen";

    /// <summary>
    /// Validiert alle Properties
    /// </summary>
    public void Validate()
    {
        ValidateAllProperties();
    }
}

/// <summary>
/// Abwesenheits-Grund Model - Mapping zu tbl_DP_Grund
/// </summary>
public partial class AbwesenheitsGrund : ObservableObject
{
    [ObservableProperty]
    private int _grundId;

    [ObservableProperty]
    private string? _bezeichnung;

    [ObservableProperty]
    private string? _kurzbezeichnung;

    [ObservableProperty]
    private string? _farbcode;

    [ObservableProperty]
    private bool _istBezahlt;

    [ObservableProperty]
    private bool _istAktiv = true;
}
