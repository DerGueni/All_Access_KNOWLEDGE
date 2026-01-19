using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.Collections.ObjectModel;

namespace ConsysWinUI.Models;

/// <summary>
/// Planungs-Anfrage Model - Mapping zu tbl_VA_Anfragen
/// Für das Planungssystem zur Mitarbeiter-Anforderung
/// </summary>
public partial class PlanungsAnfrage : ObservableValidator
{
    [ObservableProperty]
    private int _anfrageId;

    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    private int _vaStartId;

    [ObservableProperty]
    private DateTime _datum;

    [ObservableProperty]
    private TimeSpan _startzeit;

    [ObservableProperty]
    private TimeSpan _endzeit;

    [ObservableProperty]
    private int _anzahlMitarbeiterBenoeligt;

    [ObservableProperty]
    private int _anzahlMitarbeiterZugeordnet;

    [ObservableProperty]
    private string? _qualifikationenErforderlich;

    [ObservableProperty]
    private bool _istSchichtleiterErforderlich;

    [ObservableProperty]
    private bool _istGeschlossen;

    [ObservableProperty]
    private DateTime? _erstelltAm;

    [ObservableProperty]
    private string? _erstelltVon;

    /// <summary>
    /// Noch benötigte Mitarbeiter
    /// </summary>
    public int MitarbeiterOffen => AnzahlMitarbeiterBenoeligt - AnzahlMitarbeiterZugeordnet;

    /// <summary>
    /// Ist die Anfrage vollständig besetzt?
    /// </summary>
    public bool IstVollstaendigBesetzt => AnzahlMitarbeiterZugeordnet >= AnzahlMitarbeiterBenoeligt;

    /// <summary>
    /// Auslastung in Prozent
    /// </summary>
    public double AuslastungProzent
    {
        get
        {
            if (AnzahlMitarbeiterBenoeligt == 0)
                return 0;

            return (double)AnzahlMitarbeiterZugeordnet / AnzahlMitarbeiterBenoeligt * 100;
        }
    }

    /// <summary>
    /// Validiert alle Properties
    /// </summary>
    public void Validate()
    {
        ValidateAllProperties();
    }
}

/// <summary>
/// Verfügbarkeits-Info Model für Planungs-Ansichten
/// Zeigt an ob ein Mitarbeiter für einen bestimmten Zeitraum verfügbar ist
/// </summary>
public partial class VerfuegbarkeitInfo : ObservableObject
{
    [ObservableProperty]
    private int _maId;

    [ObservableProperty]
    private string? _mitarbeiterName;

    [ObservableProperty]
    private DateTime _datum;

    [ObservableProperty]
    private TimeSpan _startzeit;

    [ObservableProperty]
    private TimeSpan _endzeit;

    [ObservableProperty]
    private bool _istVerfuegbar;

    [ObservableProperty]
    private string? _nichtverfuegbarGrund;

    [ObservableProperty]
    private bool _hatKonflikt;

    [ObservableProperty]
    private string? _konfliktBeschreibung;

    [ObservableProperty]
    private ObservableCollection<string> _qualifikationen = new();

    /// <summary>
    /// Status-Text für Anzeige
    /// </summary>
    public string StatusText
    {
        get
        {
            if (IstVerfuegbar)
                return "Verfügbar";

            if (HatKonflikt)
                return $"Konflikt: {KonfliktBeschreibung}";

            return $"Nicht verfügbar: {NichtverfuegbarGrund}";
        }
    }

    /// <summary>
    /// Ampel-Farbe für UI (Grün/Gelb/Rot)
    /// </summary>
    public string AmpelFarbe
    {
        get
        {
            if (IstVerfuegbar)
                return "#28A745"; // Grün

            if (HatKonflikt)
                return "#FFC107"; // Gelb

            return "#DC3545"; // Rot
        }
    }
}

/// <summary>
/// Planungs-Board-Eintrag für Dashboard/Übersichts-Ansichten
/// Kombiniert alle relevanten Informationen für schnelle Übersicht
/// </summary>
public partial class PlanungsBoardEintrag : ObservableObject
{
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
    private int _anzahlSchichten;

    [ObservableProperty]
    private int _mitarbeiterBenoeligt;

    [ObservableProperty]
    private int _mitarbeiterZugeordnet;

    [ObservableProperty]
    private int _mitarbeiterBestaetigt;

    [ObservableProperty]
    private double _auslastungProzent;

    [ObservableProperty]
    private bool _istKritisch;

    [ObservableProperty]
    private string? _warnung;

    /// <summary>
    /// Schichten-Übersicht
    /// </summary>
    [ObservableProperty]
    private ObservableCollection<Schicht> _schichten = new();

    /// <summary>
    /// Noch benötigte Mitarbeiter
    /// </summary>
    public int MitarbeiterOffen => MitarbeiterBenoeligt - MitarbeiterZugeordnet;

    /// <summary>
    /// Status-Text
    /// </summary>
    public string StatusText
    {
        get
        {
            if (MitarbeiterZugeordnet >= MitarbeiterBenoeligt)
                return "Vollständig besetzt";

            if (IstKritisch)
                return $"KRITISCH: Noch {MitarbeiterOffen} fehlen";

            return $"Offen: {MitarbeiterOffen} von {MitarbeiterBenoeligt}";
        }
    }

    /// <summary>
    /// Status-Farbe für UI
    /// </summary>
    public string StatusFarbe
    {
        get
        {
            if (MitarbeiterZugeordnet >= MitarbeiterBenoeligt)
                return "#28A745"; // Grün

            if (IstKritisch)
                return "#DC3545"; // Rot

            if (AuslastungProzent >= 50)
                return "#FFC107"; // Gelb

            return "#6C757D"; // Grau
        }
    }
}

/// <summary>
/// Schnellauswahl-Mitarbeiter für die VA-Schnellauswahl
/// Erweitert Mitarbeiter-Info mit Planungs-relevanten Daten
/// </summary>
public partial class SchnellauswahlMitarbeiter : ObservableObject
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

    [ObservableProperty]
    private bool _istSchichtleiter;

    [ObservableProperty]
    private bool _istVerfuegbar;

    [ObservableProperty]
    private int _anzahlEinsaetzeImZeitraum;

    [ObservableProperty]
    private double _stundenImZeitraum;

    [ObservableProperty]
    private DateTime? _letzterEinsatz;

    [ObservableProperty]
    private ObservableCollection<string> _qualifikationen = new();

    [ObservableProperty]
    private ObservableCollection<VerfuegbarkeitInfo> _verfuegbarkeiten = new();

    /// <summary>
    /// Vollständiger Name
    /// </summary>
    public string VollstaendigerName => $"{Nachname}, {Vorname}";

    /// <summary>
    /// Anzeigename
    /// </summary>
    public string Anzeigename => $"{Vorname} {Nachname}";

    /// <summary>
    /// Verfügbarkeits-Ampel
    /// </summary>
    public string VerfuegbarkeitsFarbe => IstVerfuegbar ? "#28A745" : "#DC3545";

    /// <summary>
    /// Auslastungs-Text
    /// </summary>
    public string AuslastungsText => $"{AnzahlEinsaetzeImZeitraum} Einsätze, {StundenImZeitraum:F1}h";
}

/// <summary>
/// Einsatz-Übersicht Model für Übersichts-Seiten
/// Fasst alle Einsätze eines Zeitraums zusammen
/// </summary>
public partial class EinsatzUebersicht : ObservableObject
{
    [ObservableProperty]
    private DateTime _vonDatum;

    [ObservableProperty]
    private DateTime _bisDatum;

    [ObservableProperty]
    private int _anzahlAuftraege;

    [ObservableProperty]
    private int _anzahlSchichten;

    [ObservableProperty]
    private int _anzahlMitarbeiterBenoeligt;

    [ObservableProperty]
    private int _anzahlMitarbeiterZugeordnet;

    [ObservableProperty]
    private int _anzahlMitarbeiterBestaetigt;

    [ObservableProperty]
    private double _gesamtStunden;

    [ObservableProperty]
    private int _anzahlOffeneAnfragen;

    [ObservableProperty]
    private int _anzahlKritischeAnfragen;

    /// <summary>
    /// Detail-Einträge
    /// </summary>
    [ObservableProperty]
    private ObservableCollection<PlanungsBoardEintrag> _eintraege = new();

    /// <summary>
    /// Zeitraum formatiert
    /// </summary>
    public string ZeitraumFormatiert => $"{VonDatum:dd.MM.yyyy} - {BisDatum:dd.MM.yyyy}";

    /// <summary>
    /// Gesamtauslastung in Prozent
    /// </summary>
    public double GesamtAuslastung
    {
        get
        {
            if (AnzahlMitarbeiterBenoeligt == 0)
                return 0;

            return (double)AnzahlMitarbeiterZugeordnet / AnzahlMitarbeiterBenoeligt * 100;
        }
    }

    /// <summary>
    /// Status-Text
    /// </summary>
    public string StatusText
    {
        get
        {
            if (AnzahlKritischeAnfragen > 0)
                return $"KRITISCH: {AnzahlKritischeAnfragen} kritische Anfragen";

            if (AnzahlOffeneAnfragen > 0)
                return $"{AnzahlOffeneAnfragen} offene Anfragen";

            return "Alle Anfragen besetzt";
        }
    }
}
