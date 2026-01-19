using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.ComponentModel.DataAnnotations;

namespace ConsysWinUI.Models;

/// <summary>
/// Kunde Model - Mapping zu tbl_KD_Kundenstamm
/// Erbt von ObservableValidator für automatische Validierung und INotifyPropertyChanged
/// </summary>
public partial class Kunde : ObservableValidator
{
    [ObservableProperty]
    private int _kunId;

    [ObservableProperty]
    [Required(ErrorMessage = "Firmenname ist erforderlich")]
    [MaxLength(200, ErrorMessage = "Firmenname darf maximal 200 Zeichen lang sein")]
    private string? _kunFirma;

    [ObservableProperty]
    private string? _kunFirmaZusatz;

    [ObservableProperty]
    private string? _kunStrasse;

    [ObservableProperty]
    private string? _kunPlz;

    [ObservableProperty]
    private string? _kunOrt;

    [ObservableProperty]
    private string? _kunLand;

    [ObservableProperty]
    private string? _kunTelefon;

    [ObservableProperty]
    private string? _kunFax;

    [ObservableProperty]
    [EmailAddress(ErrorMessage = "Ungültige E-Mail-Adresse")]
    private string? _kunEmail;

    [ObservableProperty]
    private string? _kunWebsite;

    [ObservableProperty]
    private string? _kunUstIdNr;

    [ObservableProperty]
    private string? _kunSteuernummer;

    [ObservableProperty]
    private string? _kunHandelsregister;

    [ObservableProperty]
    private int? _kunBrancheId;

    [ObservableProperty]
    private KundeBranche? _branche;

    [ObservableProperty]
    private string? _kunAnsprechpartner;

    [ObservableProperty]
    private string? _kunAnsprechpartnerTel;

    [ObservableProperty]
    [EmailAddress(ErrorMessage = "Ungültige E-Mail-Adresse")]
    private string? _kunAnsprechpartnerEmail;

    [ObservableProperty]
    private string? _kunRechnungsadresse;

    [ObservableProperty]
    private string? _kunZahlungsziel;

    [ObservableProperty]
    private decimal? _kunRabatt;

    [ObservableProperty]
    private bool _kunIstAktiv = true;

    [ObservableProperty]
    private string? _kunBemerkungen;

    [ObservableProperty]
    private DateTime? _kunErstelltAm;

    [ObservableProperty]
    private DateTime? _kunGeaendertAm;

    [ObservableProperty]
    private string? _kunErstelltVon;

    [ObservableProperty]
    private string? _kunGeaendertVon;

    /// <summary>
    /// Vollständiger Firmenname mit Zusatz
    /// </summary>
    public string VollstaendigerFirmenname
    {
        get
        {
            if (string.IsNullOrWhiteSpace(KunFirmaZusatz))
                return KunFirma ?? string.Empty;

            return $"{KunFirma} - {KunFirmaZusatz}";
        }
    }

    /// <summary>
    /// Vollständige Adresse
    /// </summary>
    public string VollstaendigeAdresse => $"{KunStrasse}, {KunPlz} {KunOrt}";

    /// <summary>
    /// Status-Text für Anzeige
    /// </summary>
    public string StatusText => KunIstAktiv ? "Aktiv" : "Inaktiv";

    /// <summary>
    /// Validiert alle Properties
    /// </summary>
    public void Validate()
    {
        ValidateAllProperties();
    }
}

/// <summary>
/// Kunde Branche Model - Mapping zu tbl_KD_Branche
/// </summary>
public partial class KundeBranche : ObservableValidator
{
    [ObservableProperty]
    private int _brancheId;

    [ObservableProperty]
    [Required(ErrorMessage = "Branchenbezeichnung ist erforderlich")]
    [MaxLength(100, ErrorMessage = "Branchenbezeichnung darf maximal 100 Zeichen lang sein")]
    private string? _bezeichnung;

    [ObservableProperty]
    private string? _beschreibung;

    [ObservableProperty]
    private bool _istAktiv = true;
}
