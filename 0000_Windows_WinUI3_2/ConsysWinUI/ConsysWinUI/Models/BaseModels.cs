using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.ComponentModel.DataAnnotations;

namespace ConsysWinUI.Models;

/// <summary>
/// Basis-Model für alle Entitäten mit Standard-Audit-Feldern
/// Stellt gemeinsame Properties für Erstellung/Änderung bereit
/// </summary>
public abstract partial class AuditableEntity : ObservableValidator
{
    [ObservableProperty]
    private DateTime? _erstelltAm;

    [ObservableProperty]
    private DateTime? _geaendertAm;

    [ObservableProperty]
    private string? _erstelltVon;

    [ObservableProperty]
    private string? _geaendertVon;

    /// <summary>
    /// Markiert die Entität als neu erstellt (setzt ErstelltAm auf jetzt)
    /// </summary>
    public virtual void MarkAsCreated(string? username = null)
    {
        ErstelltAm = DateTime.Now;
        ErstelltVon = username ?? Environment.UserName;
    }

    /// <summary>
    /// Markiert die Entität als geändert (setzt GeaendertAm auf jetzt)
    /// </summary>
    public virtual void MarkAsModified(string? username = null)
    {
        GeaendertAm = DateTime.Now;
        GeaendertVon = username ?? Environment.UserName;
    }
}

/// <summary>
/// Basis-Model für alle Entitäten mit IstAktiv-Flag
/// </summary>
public abstract partial class ActivatableEntity : AuditableEntity
{
    [ObservableProperty]
    private bool _istAktiv = true;

    /// <summary>
    /// Aktiviert die Entität
    /// </summary>
    public virtual void Activate(string? username = null)
    {
        IstAktiv = true;
        MarkAsModified(username);
    }

    /// <summary>
    /// Deaktiviert die Entität
    /// </summary>
    public virtual void Deactivate(string? username = null)
    {
        IstAktiv = false;
        MarkAsModified(username);
    }

    /// <summary>
    /// Status-Text
    /// </summary>
    public string StatusText => IstAktiv ? "Aktiv" : "Inaktiv";
}

/// <summary>
/// Lookup-Item für Dropdown-Listen
/// Einfaches Key-Value Model für Auswahllisten
/// </summary>
public partial class LookupItem : ObservableObject
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private string? _bezeichnung;

    [ObservableProperty]
    private string? _kurzbezeichnung;

    [ObservableProperty]
    private bool _istAktiv = true;

    [ObservableProperty]
    private int _sortierung;

    [ObservableProperty]
    private object? _zusatzDaten;

    public LookupItem()
    {
    }

    public LookupItem(int id, string? bezeichnung)
    {
        Id = id;
        Bezeichnung = bezeichnung;
    }

    public LookupItem(int id, string? bezeichnung, string? kurzbezeichnung)
    {
        Id = id;
        Bezeichnung = bezeichnung;
        Kurzbezeichnung = kurzbezeichnung;
    }

    public override string ToString() => Bezeichnung ?? string.Empty;
}

/// <summary>
/// Validierungs-Result für Model-Validierung
/// </summary>
public class ValidationResult
{
    public bool IsValid { get; set; }
    public string[] Errors { get; set; } = Array.Empty<string>();
    public string ErrorMessage => string.Join("; ", Errors);

    public static ValidationResult Success() => new() { IsValid = true };

    public static ValidationResult Failure(params string[] errors) => new()
    {
        IsValid = false,
        Errors = errors
    };
}

/// <summary>
/// Filter-Model für Datenbankabfragen
/// Basis-Klasse für alle Filter
/// </summary>
public abstract partial class FilterBase : ObservableObject
{
    [ObservableProperty]
    private bool _nurAktive = true;

    [ObservableProperty]
    private string? _suchbegriff;

    [ObservableProperty]
    private DateTime? _vonDatum;

    [ObservableProperty]
    private DateTime? _bisDatum;

    [ObservableProperty]
    private int _limit = 100;

    [ObservableProperty]
    private int _offset;

    /// <summary>
    /// Setzt alle Filter zurück
    /// </summary>
    public virtual void Reset()
    {
        NurAktive = true;
        Suchbegriff = null;
        VonDatum = null;
        BisDatum = null;
        Limit = 100;
        Offset = 0;
    }
}

/// <summary>
/// Mitarbeiter-Filter
/// </summary>
public partial class MitarbeiterFilter : FilterBase
{
    [ObservableProperty]
    private bool? _nurSchichtleiter;

    [ObservableProperty]
    private bool? _nurObjektleiter;

    [ObservableProperty]
    private bool? _nurVerfuegbar;

    [ObservableProperty]
    private string? _qualifikation;

    public override void Reset()
    {
        base.Reset();
        NurSchichtleiter = null;
        NurObjektleiter = null;
        NurVerfuegbar = null;
        Qualifikation = null;
    }
}

/// <summary>
/// Auftrag-Filter
/// </summary>
public partial class AuftragFilter : FilterBase
{
    [ObservableProperty]
    private int? _veranstalterId;

    [ObservableProperty]
    private string? _objektId;

    [ObservableProperty]
    private int? _statusId;

    [ObservableProperty]
    private bool? _nurMitOffenenAnfragen;

    public override void Reset()
    {
        base.Reset();
        VeranstalterId = null;
        ObjektId = null;
        StatusId = null;
        NurMitOffenenAnfragen = null;
    }
}

/// <summary>
/// Dienstplan-Filter
/// </summary>
public partial class DienstplanFilter : FilterBase
{
    [ObservableProperty]
    private int? _mitarbeiterId;

    [ObservableProperty]
    private int? _auftragId;

    [ObservableProperty]
    private string? _objektId;

    [ObservableProperty]
    private bool? _nurBestaetigt;

    [ObservableProperty]
    private bool? _nurUnbestaetigt;

    public override void Reset()
    {
        base.Reset();
        MitarbeiterId = null;
        AuftragId = null;
        ObjektId = null;
        NurBestaetigt = null;
        NurUnbestaetigt = null;
    }
}
