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
/// ViewModel für Dienstplan pro Mitarbeiter (frm_N_Dienstplanuebersicht).
/// Zeigt alle Einsätze eines Mitarbeiters in einem Zeitraum.
/// </summary>
public partial class DienstplanMAViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Mitarbeiter

    [ObservableProperty]
    private int? _selectedMaId;

    [ObservableProperty]
    private ObservableCollection<MitarbeiterLookupItem> _mitarbeiterListe = new();

    [ObservableProperty]
    private string? _selectedMitarbeiterName;

    #endregion

    #region Properties - Zeitraum

    [ObservableProperty]
    private DateTimeOffset _vonDatum = new DateTimeOffset(DateTime.Today.AddDays(-30));

    [ObservableProperty]
    private DateTimeOffset _bisDatum = new DateTimeOffset(DateTime.Today.AddDays(30));

    #endregion

    #region Properties - Dienstplan

    [ObservableProperty]
    private ObservableCollection<DienstplanEintragItem> _dienstplanEintraege = new();

    [ObservableProperty]
    private ObservableCollection<AbwesenheitEintragItem> _abwesenheiten = new();

    [ObservableProperty]
    private DienstplanEintragItem? _selectedEintrag;

    #endregion

    #region Properties - Statistik

    [ObservableProperty]
    private int _anzahlEinsaetze;

    [ObservableProperty]
    private decimal _gesamtStunden;

    [ObservableProperty]
    private int _anzahlTage;

    [ObservableProperty]
    private int _anzahlAbwesenheiten;

    public string GesamtStundenText => GesamtStunden.ToString("0.0");

    partial void OnGesamtStundenChanged(decimal value)
    {
        OnPropertyChanged(nameof(GesamtStundenText));
    }

    #endregion

    #region Properties - Kalender

    [ObservableProperty]
    private ObservableCollection<Controls.CalendarEntry> _kalenderEintraege = new();

    #endregion

    public DienstplanMAViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadMitarbeiterListeAsync();
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int maId)
        {
            SelectedMaId = maId;
            _ = LoadDienstplanAsync();
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
    private async Task LoadDienstplanAsync()
    {
        if (!SelectedMaId.HasValue)
        {
            ShowError("Bitte Mitarbeiter auswählen");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Update selected MA name
            var selectedMa = MitarbeiterListe.FirstOrDefault(m => m.MaId == SelectedMaId.Value);
            SelectedMitarbeiterName = selectedMa?.DisplayName ?? "";

            // Load Dienstplan-Einträge
            var sql = @"
                SELECT p.VA_ID, p.VADatum, p.VA_Start, p.VA_Ende, p.MA_ID,
                       a.Auftrag, a.Objekt, a.Veranstalter_ID,
                       k.kun_Firma as Veranstalter
                FROM tbl_MA_VA_Planung p
                INNER JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
                LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
                WHERE p.MA_ID = @MaId
                  AND p.VADatum BETWEEN @VonDatum AND @BisDatum
                ORDER BY p.VADatum, p.VA_Start";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "MaId", SelectedMaId.Value },
                { "VonDatum", VonDatum.DateTime },
                { "BisDatum", BisDatum.DateTime }
            });

            DienstplanEintraege.Clear();
            foreach (DataRow row in data.Rows)
            {
                var vaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : (TimeSpan?)null;
                var vaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : (TimeSpan?)null;

                decimal stunden = 0;
                if (vaStart.HasValue && vaEnde.HasValue)
                {
                    stunden = (decimal)(vaEnde.Value - vaStart.Value).TotalHours;
                }

                DienstplanEintraege.Add(new DienstplanEintragItem
                {
                    VaId = Convert.ToInt32(row["VA_ID"]),
                    VaDatum = Convert.ToDateTime(row["VADatum"]),
                    VaStart = vaStart,
                    VaEnde = vaEnde,
                    Stunden = stunden,
                    Auftrag = row["Auftrag"]?.ToString() ?? "",
                    Objekt = row["Objekt"]?.ToString() ?? "",
                    Veranstalter = row["Veranstalter"]?.ToString() ?? ""
                });
            }

            // Load Abwesenheiten
            var abwSql = @"
                SELECT MA_ID, vonDat, bisDat, Grund, Bemerkung
                FROM tbl_MA_NVerfuegZeiten
                WHERE MA_ID = @MaId
                  AND (vonDat BETWEEN @VonDatum AND @BisDatum
                       OR bisDat BETWEEN @VonDatum AND @BisDatum
                       OR (vonDat <= @VonDatum AND bisDat >= @BisDatum))
                ORDER BY vonDat";

            var abwData = await _databaseService.ExecuteQueryAsync(abwSql, new Dictionary<string, object>
            {
                { "MaId", SelectedMaId.Value },
                { "VonDatum", VonDatum.DateTime },
                { "BisDatum", BisDatum.DateTime }
            });

            Abwesenheiten.Clear();
            foreach (DataRow row in abwData.Rows)
            {
                Abwesenheiten.Add(new AbwesenheitEintragItem
                {
                    VonDat = Convert.ToDateTime(row["vonDat"]),
                    BisDat = Convert.ToDateTime(row["bisDat"]),
                    Grund = row["Grund"]?.ToString() ?? "",
                    Bemerkung = row["Bemerkung"]?.ToString()
                });
            }

            // Berechne Statistik
            AnzahlEinsaetze = DienstplanEintraege.Count;
            GesamtStunden = DienstplanEintraege.Sum(e => e.Stunden);
            AnzahlTage = DienstplanEintraege.Select(e => e.VaDatum.Date).Distinct().Count();
            AnzahlAbwesenheiten = Abwesenheiten.Count;

            // Erstelle Kalender-Einträge für Grid
            CreateKalenderEintraege();

            ShowSuccess($"{AnzahlEinsaetze} Einsätze geladen ({GesamtStunden:F2} Stunden)");
        }, "Lade Dienstplan...");
    }

    /// <summary>
    /// Konvertiert Dienstplan-Einträge und Abwesenheiten in Kalender-Einträge
    /// </summary>
    private void CreateKalenderEintraege()
    {
        KalenderEintraege.Clear();

        // Einsätze
        foreach (var eintrag in DienstplanEintraege)
        {
            KalenderEintraege.Add(new Controls.CalendarEntry
            {
                Id = eintrag.VaId,
                Date = eintrag.VaDatum,
                StartTime = eintrag.VaStart ?? TimeSpan.Zero,
                EndTime = eintrag.VaEnde ?? TimeSpan.Zero,
                Title = eintrag.Auftrag,
                Details = $"{eintrag.Objekt}\n{eintrag.Veranstalter}",
                Badge = $"{eintrag.Stunden:F1}h",
                BadgeColor = Windows.UI.Color.FromArgb(255, 0, 100, 0), // DarkGreen
                Type = Controls.CalendarEntryType.Einsatz,
                Data = eintrag
            });
        }

        // Abwesenheiten (über mehrere Tage verteilt)
        foreach (var abw in Abwesenheiten)
        {
            for (var date = abw.VonDat; date <= abw.BisDat; date = date.AddDays(1))
            {
                // Nur wenn im aktuellen Zeitraum
                if (date >= VonDatum.DateTime && date <= BisDatum.DateTime)
                {
                    // Bestimme Abwesenheitstyp anhand des Grundes
                    var entryType = DetermineAbwesenheitsType(abw.Grund);
                    var badgeColor = entryType switch
                    {
                        Controls.CalendarEntryType.Urlaub => Windows.UI.Color.FromArgb(255, 255, 140, 0), // DarkOrange
                        Controls.CalendarEntryType.Krank => Windows.UI.Color.FromArgb(255, 178, 34, 34), // Firebrick
                        _ => Windows.UI.Color.FromArgb(255, 139, 0, 0) // DarkRed
                    };

                    KalenderEintraege.Add(new Controls.CalendarEntry
                    {
                        Id = 0, // Keine VA_ID bei Abwesenheiten
                        Date = date,
                        StartTime = TimeSpan.Zero,
                        EndTime = TimeSpan.FromHours(24),
                        Title = abw.Grund,
                        Details = abw.Bemerkung,
                        Badge = GetAbwesenheitBadge(entryType),
                        BadgeColor = badgeColor,
                        Type = entryType,
                        Data = abw
                    });
                }
            }
        }
    }

    /// <summary>
    /// Bestimmt den Abwesenheitstyp anhand des Grundes
    /// </summary>
    private Controls.CalendarEntryType DetermineAbwesenheitsType(string grund)
    {
        var grundLower = grund?.ToLower() ?? "";

        if (grundLower.Contains("urlaub") || grundLower.Contains("ferien"))
            return Controls.CalendarEntryType.Urlaub;

        if (grundLower.Contains("krank") || grundLower.Contains("krankheit") ||
            grundLower.Contains("au") || grundLower.Contains("arbeitsunfähig"))
            return Controls.CalendarEntryType.Krank;

        return Controls.CalendarEntryType.Abwesenheit;
    }

    /// <summary>
    /// Liefert Badge-Text für Abwesenheitstyp
    /// </summary>
    private string GetAbwesenheitBadge(Controls.CalendarEntryType type)
    {
        return type switch
        {
            Controls.CalendarEntryType.Urlaub => "Urlaub",
            Controls.CalendarEntryType.Krank => "Krank",
            _ => "Abwesend"
        };
    }

    #endregion

    #region Commands - Navigation

    [RelayCommand]
    private async Task PreviousWeekAsync()
    {
        VonDatum = VonDatum.AddDays(-7);
        BisDatum = BisDatum.AddDays(-7);
        await LoadDienstplanAsync();
    }

    [RelayCommand]
    private async Task NextWeekAsync()
    {
        VonDatum = VonDatum.AddDays(7);
        BisDatum = BisDatum.AddDays(7);
        await LoadDienstplanAsync();
    }

    [RelayCommand]
    private async Task HeuteAsync()
    {
        var today = DateTime.Today;
        VonDatum = new DateTimeOffset(today.AddDays(-30));
        BisDatum = new DateTimeOffset(today.AddDays(30));
        await LoadDienstplanAsync();
    }

    #endregion

    #region Commands - Sidebar Navigation

    [RelayCommand]
    private void NavigateDienstplan()
    {
        // Already on Dienstplan MA
    }

    [RelayCommand]
    private void NavigatePlanung()
    {
        _navigationService.NavigateTo<DienstplanObjektViewModel>();
    }

    [RelayCommand]
    private void NavigateAuftrag()
    {
        _navigationService.NavigateTo<AuftragstammViewModel>();
    }

    [RelayCommand]
    private void NavigateMitarbeiter()
    {
        _navigationService.NavigateTo<MitarbeiterstammViewModel>();
    }

    [RelayCommand]
    private void NavigateAnfragen()
    {
        // TODO: Implement when view is ready
        ShowInfo("Offene Mail Anfragen - noch nicht implementiert");
    }

    [RelayCommand]
    private void NavigateExcelZeitkonten()
    {
        // TODO: Implement when view is ready
        ShowInfo("Excel Zeitkonten - noch nicht implementiert");
    }

    [RelayCommand]
    private void NavigateZeitkonten()
    {
        // TODO: Implement when view is ready
        ShowInfo("Zeitkonten - noch nicht implementiert");
    }

    [RelayCommand]
    private void NavigateAbwesenheit()
    {
        // TODO: Implement when view is ready
        ShowInfo("Abwesenheitsplanung - noch nicht implementiert");
    }

    [RelayCommand]
    private void NavigateDienstausweis()
    {
        // TODO: Implement when view is ready
        ShowInfo("Dienstausweis erstellen - noch nicht implementiert");
    }

    #endregion

    #region Commands - Actions

    [RelayCommand]
    private void OpenAuftrag()
    {
        if (SelectedEintrag != null)
        {
            _navigationService.NavigateTo<AuftragstammViewModel>(SelectedEintrag.VaId);
        }
    }

    [RelayCommand]
    private void OpenMitarbeiter()
    {
        if (SelectedMaId.HasValue)
        {
            _navigationService.NavigateTo<MitarbeiterstammViewModel>(SelectedMaId.Value);
        }
    }

    [RelayCommand]
    private async Task ExportAsync()
    {
        if (!SelectedMaId.HasValue)
        {
            ShowError("Bitte Mitarbeiter auswählen");
            return;
        }

        // TODO: Implement export functionality
        await _dialogService.ShowMessageAsync("Export", "Export-Funktion noch nicht implementiert");
    }

    [RelayCommand]
    private async Task PrintAsync()
    {
        if (!SelectedMaId.HasValue)
        {
            ShowError("Bitte Mitarbeiter auswählen");
            return;
        }

        // TODO: Implement print functionality
        await _dialogService.ShowMessageAsync("Drucken", "Druck-Funktion noch nicht implementiert");
    }

    #endregion
}

#region Helper Classes

public class MitarbeiterLookupItem
{
    public int MaId { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
}

public class DienstplanEintragItem
{
    public int VaId { get; set; }
    public DateTime VaDatum { get; set; }
    public TimeSpan? VaStart { get; set; }
    public TimeSpan? VaEnde { get; set; }
    public decimal Stunden { get; set; }
    public string Auftrag { get; set; } = string.Empty;
    public string Objekt { get; set; } = string.Empty;
    public string Veranstalter { get; set; } = string.Empty;

    public string DisplayText => $"{VaDatum:dd.MM.yyyy} {VaStart:hh\\:mm}-{VaEnde:hh\\:mm} | {Auftrag} ({Objekt})";
    public string ZeitText => $"{VaStart:hh\\:mm} - {VaEnde:hh\\:mm}";
    public string DatumText => VaDatum.ToString("dd.MM.yyyy");
    public string StundenText => Stunden.ToString("0.0") + "h";
}

public class AbwesenheitEintragItem
{
    public DateTime VonDat { get; set; }
    public DateTime BisDat { get; set; }
    public string Grund { get; set; } = string.Empty;
    public string? Bemerkung { get; set; }

    public string DisplayText => $"{VonDat:dd.MM.yyyy} - {BisDat:dd.MM.yyyy}: {Grund}";
    public string VonDatText => VonDat.ToString("dd.MM.yyyy");
    public string BisDatText => BisDat.ToString("dd.MM.yyyy");
    public int AnzahlTage => (BisDat - VonDat).Days + 1;
}

#endregion
