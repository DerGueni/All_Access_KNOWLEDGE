using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.Collections.ObjectModel;
using System.ComponentModel.DataAnnotations;

namespace ConsysWinUI.Models;

/// <summary>
/// Auftrag Model - Mapping zu tbl_VA_Auftragstamm
/// WICHTIG: Property heißt "AuftragNr" (NICHT "Auftrag") wegen Namenskonflikt mit Klasse
/// </summary>
public partial class Auftrag : ObservableValidator
{
    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    [Required(ErrorMessage = "Auftragsnummer ist erforderlich")]
    [MaxLength(50, ErrorMessage = "Auftragsnummer darf maximal 50 Zeichen lang sein")]
    private string? _auftragNr; // NICHT "Auftrag" - Namenskonflikt!

    [ObservableProperty]
    private string? _auftragBezeichnung;

    [ObservableProperty]
    private int? _veranstalterId;

    [ObservableProperty]
    private Veranstalter? _veranstalter;

    [ObservableProperty]
    private string? _objektId;

    [ObservableProperty]
    private Objekt? _objekt;

    [ObservableProperty]
    private DateTime? _datVaVon;

    [ObservableProperty]
    private DateTime? _datVaBis;

    [ObservableProperty]
    private string? _treffpunkt;

    [ObservableProperty]
    private string? _treffpunktZeit;

    [ObservableProperty]
    private string? _dienstkleidung;

    [ObservableProperty]
    private string? _ansprechpartner;

    [ObservableProperty]
    private string? _ansprechpartnerTel;

    [ObservableProperty]
    private string? _bemerkungen;

    [ObservableProperty]
    private int? _veranstStatusId;

    [ObservableProperty]
    private string? _statusBezeichnung;

    [ObservableProperty]
    private bool _istAktiv = true;

    [ObservableProperty]
    private DateTime? _erstelltAm;

    [ObservableProperty]
    private DateTime? _geaendertAm;

    [ObservableProperty]
    private string? _erstelltVon;

    [ObservableProperty]
    private string? _geaendertVon;

    /// <summary>
    /// Auftrags-Tage (tbl_VA_AnzTage)
    /// </summary>
    [ObservableProperty]
    private ObservableCollection<AuftragTag> _tage = new();

    /// <summary>
    /// Schichten pro Tag (tbl_VA_Start)
    /// </summary>
    [ObservableProperty]
    private ObservableCollection<Schicht> _schichten = new();

    /// <summary>
    /// Dauer des Auftrags in Tagen
    /// </summary>
    public int? Dauer
    {
        get
        {
            if (!DatVaVon.HasValue || !DatVaBis.HasValue)
                return null;

            return (DatVaBis.Value - DatVaVon.Value).Days + 1;
        }
    }

    /// <summary>
    /// Anzahl zugeordneter Tage
    /// </summary>
    public int AnzahlTage => Tage.Count;

    /// <summary>
    /// Anzahl Schichten
    /// </summary>
    public int AnzahlSchichten => Schichten.Count;

    /// <summary>
    /// Vollständige Auftragsbezeichnung
    /// </summary>
    public string VollstaendigeBezeichnung
    {
        get
        {
            if (string.IsNullOrWhiteSpace(AuftragBezeichnung))
                return AuftragNr ?? string.Empty;

            return $"{AuftragNr} - {AuftragBezeichnung}";
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
/// Veranstalter Model - Mapping zu tbl_VA_Veranstalter
/// </summary>
public partial class Veranstalter : ObservableValidator
{
    [ObservableProperty]
    private int _veranstalterId;

    [ObservableProperty]
    [Required(ErrorMessage = "Veranstalter-Name ist erforderlich")]
    private string? _name;

    [ObservableProperty]
    private string? _kontaktperson;

    [ObservableProperty]
    private string? _telefon;

    [ObservableProperty]
    private string? _email;

    [ObservableProperty]
    private bool _istAktiv = true;
}

/// <summary>
/// Objekt Model - Mapping zu tbl_OB_Objekt
/// </summary>
public partial class Objekt : ObservableValidator
{
    [ObservableProperty]
    private string? _objektId;

    [ObservableProperty]
    [Required(ErrorMessage = "Objektbezeichnung ist erforderlich")]
    private string? _bezeichnung;

    [ObservableProperty]
    private string? _strasse;

    [ObservableProperty]
    private string? _plz;

    [ObservableProperty]
    private string? _ort;

    [ObservableProperty]
    private string? _land;

    [ObservableProperty]
    private string? _bemerkungen;

    [ObservableProperty]
    private bool _istAktiv = true;

    /// <summary>
    /// Vollständige Adresse
    /// </summary>
    public string VollstaendigeAdresse => $"{Strasse}, {Plz} {Ort}";
}

/// <summary>
/// Auftrags-Tag Model - Mapping zu tbl_VA_AnzTage
/// </summary>
public partial class AuftragTag : ObservableObject
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    private DateTime _vaDatum;

    [ObservableProperty]
    private bool _istAktiv = true;

    /// <summary>
    /// Tag-Bezeichnung (z.B. "Montag, 15.01.2025")
    /// </summary>
    public string TagBezeichnung => VaDatum.ToString("dddd, dd.MM.yyyy");

    /// <summary>
    /// Wochentag
    /// </summary>
    public string Wochentag => VaDatum.ToString("dddd");
}

/// <summary>
/// Schicht Model - Mapping zu tbl_VA_Start
/// </summary>
public partial class Schicht : ObservableValidator
{
    [ObservableProperty]
    private int _vaStartId;

    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    private DateTime _vaDatum;

    [ObservableProperty]
    [Required(ErrorMessage = "Startzeit ist erforderlich")]
    private TimeSpan? _vaStart;

    [ObservableProperty]
    [Required(ErrorMessage = "Endzeit ist erforderlich")]
    private TimeSpan? _vaEnde;

    [ObservableProperty]
    [Range(1, 999, ErrorMessage = "Anzahl Mitarbeiter muss zwischen 1 und 999 liegen")]
    private int _maAnzahl;

    [ObservableProperty]
    private int _maAnzahlIst;

    [ObservableProperty]
    private string? _bemerkungen;

    [ObservableProperty]
    private bool _istAktiv = true;

    /// <summary>
    /// Zugeordnete Mitarbeiter
    /// </summary>
    [ObservableProperty]
    private ObservableCollection<MitarbeiterZuordnung> _mitarbeiterZuordnungen = new();

    /// <summary>
    /// Schicht-Bezeichnung (z.B. "08:00 - 16:00")
    /// </summary>
    public string SchichtBezeichnung
    {
        get
        {
            if (!VaStart.HasValue || !VaEnde.HasValue)
                return string.Empty;

            return $"{VaStart.Value:hh\\:mm} - {VaEnde.Value:hh\\:mm}";
        }
    }

    /// <summary>
    /// Dauer der Schicht in Stunden
    /// </summary>
    public double? Dauer
    {
        get
        {
            if (!VaStart.HasValue || !VaEnde.HasValue)
                return null;

            var duration = VaEnde.Value - VaStart.Value;
            return duration.TotalHours;
        }
    }

    /// <summary>
    /// Auslastung in Prozent
    /// </summary>
    public double Auslastung
    {
        get
        {
            if (MaAnzahl == 0)
                return 0;

            return (double)MaAnzahlIst / MaAnzahl * 100;
        }
    }

    /// <summary>
    /// Ist die Schicht vollständig besetzt?
    /// </summary>
    public bool IstVollstaendigBesetzt => MaAnzahlIst >= MaAnzahl;

    /// <summary>
    /// Validiert alle Properties
    /// </summary>
    public void Validate()
    {
        ValidateAllProperties();
    }
}

/// <summary>
/// Mitarbeiter-Zuordnung Model - Mapping zu tbl_MA_VA_Planung
/// </summary>
public partial class MitarbeiterZuordnung : ObservableObject
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private int _vaId;

    [ObservableProperty]
    private int _vaStartId;

    [ObservableProperty]
    private int _maId;

    [ObservableProperty]
    private Mitarbeiter? _mitarbeiter;

    [ObservableProperty]
    private DateTime _vaDatum;

    [ObservableProperty]
    private TimeSpan? _vaStart;

    [ObservableProperty]
    private TimeSpan? _vaEnde;

    [ObservableProperty]
    private bool _istBestaetigt;

    [ObservableProperty]
    private DateTime? _bestaetigtAm;

    [ObservableProperty]
    private string? _bemerkungen;

    [ObservableProperty]
    private DateTime? _erstelltAm;

    [ObservableProperty]
    private string? _erstelltVon;

    /// <summary>
    /// Zuordnungs-Bezeichnung (z.B. "Max Mustermann - 08:00 - 16:00")
    /// </summary>
    public string ZuordnungsBezeichnung
    {
        get
        {
            var mitarbeiterName = Mitarbeiter?.Anzeigename ?? $"MA-ID: {MaId}";

            if (!VaStart.HasValue || !VaEnde.HasValue)
                return mitarbeiterName;

            return $"{mitarbeiterName} - {VaStart.Value:hh\\:mm} - {VaEnde.Value:hh\\:mm}";
        }
    }
}
