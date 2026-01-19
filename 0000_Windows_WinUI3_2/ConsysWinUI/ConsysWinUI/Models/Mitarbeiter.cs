using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.ComponentModel.DataAnnotations;

namespace ConsysWinUI.Models;

/// <summary>
/// Mitarbeiter Model - Mapping zu tbl_MA_Mitarbeiterstamm
/// Erbt von ObservableValidator für automatische Validierung und INotifyPropertyChanged
/// </summary>
public partial class Mitarbeiter : ObservableValidator
{
    [ObservableProperty]
    private int _maId;

    [ObservableProperty]
    [Required(ErrorMessage = "Nachname ist erforderlich")]
    [MaxLength(100, ErrorMessage = "Nachname darf maximal 100 Zeichen lang sein")]
    private string? _nachname;

    [ObservableProperty]
    [Required(ErrorMessage = "Vorname ist erforderlich")]
    [MaxLength(100, ErrorMessage = "Vorname darf maximal 100 Zeichen lang sein")]
    private string? _vorname;

    [ObservableProperty]
    private string? _telMobil;

    [ObservableProperty]
    private string? _telPrivat;

    [ObservableProperty]
    private string? _telGeschaeft;

    [ObservableProperty]
    [EmailAddress(ErrorMessage = "Ungültige E-Mail-Adresse")]
    private string? _email;

    [ObservableProperty]
    private string? _strasse;

    [ObservableProperty]
    private string? _plz;

    [ObservableProperty]
    private string? _ort;

    [ObservableProperty]
    private string? _land;

    [ObservableProperty]
    private DateTime? _geburtsdatum;

    [ObservableProperty]
    private string? _geburtsort;

    [ObservableProperty]
    private string? _staatsangehoerigkeit;

    [ObservableProperty]
    private string? _sozialversicherungsnr;

    [ObservableProperty]
    private string? _steuerklasse;

    [ObservableProperty]
    private string? _steuerId;

    [ObservableProperty]
    private string? _iban;

    [ObservableProperty]
    private string? _bic;

    [ObservableProperty]
    private string? _bankname;

    [ObservableProperty]
    private DateTime? _eintrittsdatum;

    [ObservableProperty]
    private DateTime? _austrittsdatum;

    [ObservableProperty]
    private bool _istAktiv = true;

    [ObservableProperty]
    private bool _istSchichtleiter;

    [ObservableProperty]
    private bool _istObjektleiter;

    [ObservableProperty]
    private string? _qualifikationen;

    [ObservableProperty]
    private string? _fuehrerscheinklassen;

    [ObservableProperty]
    private string? _notfallkontaktName;

    [ObservableProperty]
    private string? _notfallkontaktTelefon;

    [ObservableProperty]
    private string? _bemerkungen;

    [ObservableProperty]
    private DateTime? _erstelltAm;

    [ObservableProperty]
    private DateTime? _geaendertAm;

    [ObservableProperty]
    private string? _erstelltVon;

    [ObservableProperty]
    private string? _geaendertVon;

    /// <summary>
    /// Vollständiger Name (Nachname, Vorname)
    /// </summary>
    public string VollstaendigerName => $"{Nachname}, {Vorname}";

    /// <summary>
    /// Anzeigename (Vorname Nachname)
    /// </summary>
    public string Anzeigename => $"{Vorname} {Nachname}";

    /// <summary>
    /// Alter in Jahren
    /// </summary>
    public int? Alter
    {
        get
        {
            if (!Geburtsdatum.HasValue)
                return null;

            var today = DateTime.Today;
            var age = today.Year - Geburtsdatum.Value.Year;
            if (Geburtsdatum.Value.Date > today.AddYears(-age))
                age--;

            return age;
        }
    }

    /// <summary>
    /// Status-Text für Anzeige
    /// </summary>
    public string StatusText => IstAktiv ? "Aktiv" : "Inaktiv";

    /// <summary>
    /// Validiert alle Properties
    /// </summary>
    public void Validate()
    {
        ValidateAllProperties();
    }
}
