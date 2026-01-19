using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using ConsysWinUI.Services;

namespace ConsysWinUI.ViewModels;

/// <summary>
/// ViewModel für Lohnabrechnungen (frm_N_Lohnabrechnungen).
/// Verwaltet Lohnabrechnungen und Stundenauswertungen.
/// </summary>
public partial class LohnabrechnungenViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Filter

    [ObservableProperty]
    private DateTimeOffset _vonDatum = new DateTimeOffset(new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1));

    [ObservableProperty]
    private DateTimeOffset _bisDatum = new DateTimeOffset(DateTime.Today);

    [ObservableProperty]
    private int? _selectedMaId;

    [ObservableProperty]
    private ObservableCollection<MitarbeiterLookupItem> _mitarbeiterListe = new();

    [ObservableProperty]
    private string _suchbegriff = string.Empty;

    #endregion

    #region Properties - Abrechnungen

    [ObservableProperty]
    private ObservableCollection<LohnabrechnungItem> _abrechnungen = new();

    [ObservableProperty]
    private LohnabrechnungItem? _selectedAbrechnung;

    [ObservableProperty]
    private ObservableCollection<StundenDetailItem> _stundenDetails = new();

    #endregion

    #region Properties - Statistik

    [ObservableProperty]
    private int _anzahlMitarbeiter;

    [ObservableProperty]
    private decimal _gesamtStunden;

    [ObservableProperty]
    private decimal _gesamtBrutto;

    [ObservableProperty]
    private decimal _durchschnittStundenProMa;

    public string GesamtStundenText => GesamtStunden.ToString("0.00");
    public string GesamtBruttoText => GesamtBrutto.ToString("C2");
    public string DurchschnittText => DurchschnittStundenProMa.ToString("0.00");

    partial void OnGesamtStundenChanged(decimal value) => OnPropertyChanged(nameof(GesamtStundenText));
    partial void OnGesamtBruttoChanged(decimal value) => OnPropertyChanged(nameof(GesamtBruttoText));
    partial void OnDurchschnittStundenProMaChanged(decimal value) => OnPropertyChanged(nameof(DurchschnittText));

    #endregion

    public LohnabrechnungenViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadMitarbeiterListeAsync();
        await LoadAbrechnungenAsync();
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int maId)
        {
            SelectedMaId = maId;
            _ = LoadAbrechnungenAsync();
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    #region Data Loading

    private async Task LoadMitarbeiterListeAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT MA_ID, Nachname, Vorname
                FROM tbl_MA_Mitarbeiterstamm
                WHERE IstAktiv = True
                ORDER BY Nachname, Vorname";

            var data = await _databaseService.ExecuteQueryAsync(sql);

            MitarbeiterListe.Clear();
            MitarbeiterListe.Add(new MitarbeiterLookupItem
            {
                MaId = 0,
                DisplayName = "-- Alle Mitarbeiter --"
            });

            foreach (DataRow row in data.Rows)
            {
                MitarbeiterListe.Add(new MitarbeiterLookupItem
                {
                    MaId = Convert.ToInt32(row["MA_ID"]),
                    Nachname = row["Nachname"]?.ToString() ?? "",
                    Vorname = row["Vorname"]?.ToString() ?? "",
                    DisplayName = $"{row["Nachname"]}, {row["Vorname"]}"
                });
            }
        }, "Lade Mitarbeiterliste...");
    }

    [RelayCommand]
    private async Task LoadAbrechnungenAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            // SQL für Lohnabrechnungen - aggregiert aus Planungsdaten
            var sql = @"
                SELECT m.MA_ID, m.Nachname, m.Vorname,
                       COUNT(DISTINCT p.VADatum) as AnzahlTage,
                       SUM(DATEDIFF('n', p.VA_Start, p.VA_Ende) / 60.0) as GesamtStunden
                FROM tbl_MA_Mitarbeiterstamm m
                INNER JOIN tbl_MA_VA_Planung p ON m.MA_ID = p.MA_ID
                WHERE p.VADatum BETWEEN @VonDatum AND @BisDatum";

            if (SelectedMaId.HasValue && SelectedMaId.Value > 0)
            {
                sql += " AND m.MA_ID = @MaId";
            }

            if (!string.IsNullOrWhiteSpace(Suchbegriff))
            {
                sql += " AND (m.Nachname LIKE @Such OR m.Vorname LIKE @Such)";
            }

            sql += @"
                GROUP BY m.MA_ID, m.Nachname, m.Vorname
                ORDER BY m.Nachname, m.Vorname";

            var parameters = new Dictionary<string, object>
            {
                { "VonDatum", VonDatum.DateTime },
                { "BisDatum", BisDatum.DateTime }
            };

            if (SelectedMaId.HasValue && SelectedMaId.Value > 0)
            {
                parameters["MaId"] = SelectedMaId.Value;
            }

            if (!string.IsNullOrWhiteSpace(Suchbegriff))
            {
                parameters["Such"] = $"%{Suchbegriff}%";
            }

            var data = await _databaseService.ExecuteQueryAsync(sql, parameters);

            Abrechnungen.Clear();
            foreach (DataRow row in data.Rows)
            {
                var stunden = row["GesamtStunden"] != DBNull.Value
                    ? Convert.ToDecimal(row["GesamtStunden"])
                    : 0;

                Abrechnungen.Add(new LohnabrechnungItem
                {
                    MaId = Convert.ToInt32(row["MA_ID"]),
                    Nachname = row["Nachname"]?.ToString() ?? "",
                    Vorname = row["Vorname"]?.ToString() ?? "",
                    AnzahlTage = Convert.ToInt32(row["AnzahlTage"]),
                    GesamtStunden = stunden,
                    // Beispiel-Stundensatz - in Produktion aus Stammdaten
                    Stundensatz = 15.00m,
                    BruttoBetrag = stunden * 15.00m
                });
            }

            // Statistik berechnen
            AnzahlMitarbeiter = Abrechnungen.Count;
            GesamtStunden = Abrechnungen.Sum(a => a.GesamtStunden);
            GesamtBrutto = Abrechnungen.Sum(a => a.BruttoBetrag);
            DurchschnittStundenProMa = AnzahlMitarbeiter > 0
                ? GesamtStunden / AnzahlMitarbeiter
                : 0;

            ShowSuccess($"{AnzahlMitarbeiter} Abrechnungen geladen");
        }, "Lade Abrechnungen...");
    }

    [RelayCommand]
    private async Task LoadStundenDetailsAsync()
    {
        if (SelectedAbrechnung == null)
        {
            StundenDetails.Clear();
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT p.VADatum, p.VA_Start, p.VA_Ende,
                       a.Auftrag, a.Objekt,
                       DATEDIFF('n', p.VA_Start, p.VA_Ende) / 60.0 as Stunden
                FROM tbl_MA_VA_Planung p
                INNER JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
                WHERE p.MA_ID = @MaId
                  AND p.VADatum BETWEEN @VonDatum AND @BisDatum
                ORDER BY p.VADatum, p.VA_Start";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "MaId", SelectedAbrechnung.MaId },
                { "VonDatum", VonDatum.DateTime },
                { "BisDatum", BisDatum.DateTime }
            });

            StundenDetails.Clear();
            foreach (DataRow row in data.Rows)
            {
                StundenDetails.Add(new StundenDetailItem
                {
                    Datum = Convert.ToDateTime(row["VADatum"]),
                    VaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : TimeSpan.Zero,
                    VaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : TimeSpan.Zero,
                    Auftrag = row["Auftrag"]?.ToString() ?? "",
                    Objekt = row["Objekt"]?.ToString() ?? "",
                    Stunden = row["Stunden"] != DBNull.Value ? Convert.ToDecimal(row["Stunden"]) : 0
                });
            }
        }, "Lade Stundendetails...");
    }

    partial void OnSelectedAbrechnungChanged(LohnabrechnungItem? value)
    {
        _ = LoadStundenDetailsAsync();
    }

    #endregion

    #region Commands - Filter

    [RelayCommand]
    private async Task FilterAktualisierenAsync()
    {
        await LoadAbrechnungenAsync();
    }

    [RelayCommand]
    private async Task FilterZuruecksetzenAsync()
    {
        SelectedMaId = null;
        Suchbegriff = string.Empty;
        VonDatum = new DateTimeOffset(new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1));
        BisDatum = new DateTimeOffset(DateTime.Today);
        await LoadAbrechnungenAsync();
    }

    [RelayCommand]
    private async Task VormonatAsync()
    {
        var firstOfLastMonth = new DateTime(VonDatum.Year, VonDatum.Month, 1).AddMonths(-1);
        VonDatum = new DateTimeOffset(firstOfLastMonth);
        BisDatum = new DateTimeOffset(firstOfLastMonth.AddMonths(1).AddDays(-1));
        await LoadAbrechnungenAsync();
    }

    [RelayCommand]
    private async Task AktuellerMonatAsync()
    {
        VonDatum = new DateTimeOffset(new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1));
        BisDatum = new DateTimeOffset(DateTime.Today);
        await LoadAbrechnungenAsync();
    }

    #endregion

    #region Commands - Export

    [RelayCommand]
    private async Task ExportExcelAsync()
    {
        // TODO: Implementiere Excel-Export
        await _dialogService.ShowMessageAsync("Export", "Excel-Export ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task ExportPdfAsync()
    {
        // TODO: Implementiere PDF-Export
        await _dialogService.ShowMessageAsync("Export", "PDF-Export ist in Entwicklung.");
    }

    [RelayCommand]
    private async Task DruckenAsync()
    {
        // TODO: Implementiere Druck
        await _dialogService.ShowMessageAsync("Drucken", "Druck-Funktion ist in Entwicklung.");
    }

    #endregion

    #region Commands - Sidebar Navigation

    [RelayCommand]
    private void NavigateToMitarbeiter()
    {
        _navigationService.NavigateTo<MitarbeiterstammViewModel>();
    }

    [RelayCommand]
    private void NavigateToDienstplan()
    {
        _navigationService.NavigateTo<DienstplanMAViewModel>();
    }

    [RelayCommand]
    private void NavigateToAbwesenheit()
    {
        _navigationService.NavigateTo<AbwesenheitViewModel>();
    }

    [RelayCommand]
    private void NavigateToZeitkonten()
    {
        _navigationService.NavigateTo<ZeitkontenViewModel>();
    }

    #endregion
}

#region Helper Classes

public class LohnabrechnungItem
{
    public int MaId { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public int AnzahlTage { get; set; }
    public decimal GesamtStunden { get; set; }
    public decimal Stundensatz { get; set; }
    public decimal BruttoBetrag { get; set; }

    public string DisplayName => $"{Nachname}, {Vorname}";
    public string StundenText => GesamtStunden.ToString("0.00") + " h";
    public string BruttoText => BruttoBetrag.ToString("C2");
}

public class StundenDetailItem
{
    public DateTime Datum { get; set; }
    public TimeSpan VaStart { get; set; }
    public TimeSpan VaEnde { get; set; }
    public string Auftrag { get; set; } = string.Empty;
    public string Objekt { get; set; } = string.Empty;
    public decimal Stunden { get; set; }

    public string DatumText => Datum.ToString("dd.MM.yyyy");
    public string ZeitText => $"{VaStart:hh\\:mm} - {VaEnde:hh\\:mm}";
    public string StundenText => Stunden.ToString("0.00") + " h";
}

#endregion
