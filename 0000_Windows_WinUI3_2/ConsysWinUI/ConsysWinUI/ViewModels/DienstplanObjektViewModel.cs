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
/// ViewModel für Dienstplan pro Objekt (frm_VA_Planungsuebersicht).
/// Zeigt alle Schichten und MA-Zuordnungen für einen Auftrag.
/// </summary>
public partial class DienstplanObjektViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Auftrag

    [ObservableProperty]
    private int? _selectedVaId;

    partial void OnSelectedVaIdChanged(int? value)
    {
        if (value.HasValue)
        {
            _ = LoadDienstplanAsync();
        }
    }

    [ObservableProperty]
    private ObservableCollection<AuftragLookupItem> _auftragListe = new();

    [ObservableProperty]
    private string? _selectedAuftragName;

    [ObservableProperty]
    private string? _objektName;

    [ObservableProperty]
    private string? _veranstalterName;

    [ObservableProperty]
    private DateTime? _vaDatumVon;

    [ObservableProperty]
    private DateTime? _vaDatumBis;

    #endregion

    #region Properties - Schichten

    [ObservableProperty]
    private ObservableCollection<SchichtDetailItem> _schichten = new();

    [ObservableProperty]
    private SchichtDetailItem? _selectedSchicht;

    [ObservableProperty]
    private ObservableCollection<MaZuordnungDetailItem> _zugeordneteMitarbeiter = new();

    #endregion

    #region Properties - Statistik

    [ObservableProperty]
    private int _anzahlSchichten;

    [ObservableProperty]
    private int _maGesamt;

    [ObservableProperty]
    private int _maZugeordnet;

    [ObservableProperty]
    private int _maFehlt;

    [ObservableProperty]
    private decimal _besetzungsgrad;

    public string BesetzungsgradText => Besetzungsgrad.ToString("0.0");

    partial void OnBesetzungsgradChanged(decimal value)
    {
        OnPropertyChanged(nameof(BesetzungsgradText));
    }

    #endregion

    #region Properties - Filter

    [ObservableProperty]
    private DateTime _filterDatumVon = DateTime.Today;

    [ObservableProperty]
    private DateTime _filterDatumBis = DateTime.Today.AddDays(30);

    [ObservableProperty]
    private bool _nurUnbesetzte;

    #endregion

    #region Properties - Kalender

    [ObservableProperty]
    private ObservableCollection<Controls.CalendarEntry> _kalenderEintraege = new();

    #endregion

    public DienstplanObjektViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
    }

    public override async Task InitializeAsync()
    {
        await LoadAuftragListeAsync();
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int vaId)
        {
            SelectedVaId = vaId;
            _ = LoadDienstplanAsync();
        }
    }

    public void OnNavigatedFrom()
    {
        // Cleanup wenn nötig
    }

    #region Data Loading

    private async Task LoadAuftragListeAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT a.VA_ID, a.Auftrag, a.Objekt, k.kun_Firma as Veranstalter,
                       a.VA_Datum_von, a.VA_Datum_bis
                FROM tbl_VA_Auftragstamm a
                LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
                WHERE a.VA_Status IN (0, 1)
                ORDER BY a.VA_Datum_von DESC, a.Auftrag";

            var data = await _databaseService.ExecuteQueryAsync(sql);

            AuftragListe.Clear();
            foreach (DataRow row in data.Rows)
            {
                AuftragListe.Add(new AuftragLookupItem
                {
                    VaId = Convert.ToInt32(row["VA_ID"]),
                    Auftrag = row["Auftrag"]?.ToString() ?? "",
                    Objekt = row["Objekt"]?.ToString() ?? "",
                    Veranstalter = row["Veranstalter"]?.ToString() ?? "",
                    DisplayName = $"{row["Auftrag"]} ({row["Objekt"]})"
                });
            }
        }, "Lade Auftragsliste...");
    }

    [RelayCommand]
    private async Task LoadDienstplanAsync()
    {
        if (!SelectedVaId.HasValue)
        {
            ShowError("Bitte Auftrag auswählen");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Load Auftrag-Details
            var auftragSql = @"
                SELECT a.Auftrag, a.Objekt, k.kun_Firma as Veranstalter,
                       a.VA_Datum_von, a.VA_Datum_bis
                FROM tbl_VA_Auftragstamm a
                LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
                WHERE a.VA_ID = @VaId";

            var auftragData = await _databaseService.ExecuteQueryAsync(auftragSql, new Dictionary<string, object>
            {
                { "VaId", SelectedVaId.Value }
            });

            if (auftragData.Rows.Count > 0)
            {
                var row = auftragData.Rows[0];
                SelectedAuftragName = row["Auftrag"]?.ToString();
                ObjektName = row["Objekt"]?.ToString();
                VeranstalterName = row["Veranstalter"]?.ToString();
                VaDatumVon = row["VA_Datum_von"] != DBNull.Value ? Convert.ToDateTime(row["VA_Datum_von"]) : null;
                VaDatumBis = row["VA_Datum_bis"] != DBNull.Value ? Convert.ToDateTime(row["VA_Datum_bis"]) : null;
            }

            // Load Schichten mit MA-Zuordnungen
            var schichtSql = @"
                SELECT s.VAStart_ID, s.VADatum, s.VA_Start, s.VA_Ende,
                       s.MA_Anzahl, s.MA_Anzahl_Ist, s.Bemerkung,
                       COUNT(p.MA_ID) as MA_Zugeordnet
                FROM tbl_VA_Start s
                LEFT JOIN tbl_MA_VA_Planung p ON s.VA_ID = p.VA_ID
                    AND s.VADatum = p.VADatum
                    AND s.VA_Start = p.VA_Start
                WHERE s.VA_ID = @VaId";

            if (NurUnbesetzte)
            {
                schichtSql += " AND s.MA_Anzahl_Ist < s.MA_Anzahl";
            }

            schichtSql += @"
                GROUP BY s.VAStart_ID, s.VADatum, s.VA_Start, s.VA_Ende,
                         s.MA_Anzahl, s.MA_Anzahl_Ist, s.Bemerkung
                ORDER BY s.VADatum, s.VA_Start";

            var schichtData = await _databaseService.ExecuteQueryAsync(schichtSql, new Dictionary<string, object>
            {
                { "VaId", SelectedVaId.Value }
            });

            Schichten.Clear();
            int gesamtMa = 0;
            int zugeordnetMa = 0;

            foreach (DataRow row in schichtData.Rows)
            {
                var maAnzahl = row["MA_Anzahl"] != DBNull.Value ? Convert.ToInt32(row["MA_Anzahl"]) : 0;
                var maAnzahlIst = row["MA_Anzahl_Ist"] != DBNull.Value ? Convert.ToInt32(row["MA_Anzahl_Ist"]) : 0;

                gesamtMa += maAnzahl;
                zugeordnetMa += maAnzahlIst;

                Schichten.Add(new SchichtDetailItem
                {
                    VaStartId = row["VAStart_ID"] != DBNull.Value ? Convert.ToInt32(row["VAStart_ID"]) : null,
                    VaId = SelectedVaId.Value,
                    VaDatum = Convert.ToDateTime(row["VADatum"]),
                    VaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : null,
                    VaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : null,
                    MaAnzahl = maAnzahl,
                    MaAnzahlIst = maAnzahlIst,
                    Bemerkung = row["Bemerkung"]?.ToString(),
                    IstVollbesetzt = maAnzahlIst >= maAnzahl,
                    IstUnbesetzt = maAnzahlIst == 0
                });
            }

            // Statistik
            AnzahlSchichten = Schichten.Count;
            MaGesamt = gesamtMa;
            MaZugeordnet = zugeordnetMa;
            MaFehlt = gesamtMa - zugeordnetMa;
            Besetzungsgrad = gesamtMa > 0 ? (decimal)zugeordnetMa / gesamtMa * 100 : 0;

            // Clear zugeordnete MA (wird bei Schicht-Auswahl geladen)
            ZugeordneteMitarbeiter.Clear();

            // Erstelle Kalender-Einträge
            CreateKalenderEintraege();

            ShowSuccess($"{AnzahlSchichten} Schichten geladen ({Besetzungsgrad:F1}% besetzt)");
        }, "Lade Dienstplan...");
    }

    /// <summary>
    /// Konvertiert Schichten in Kalender-Einträge
    /// </summary>
    private void CreateKalenderEintraege()
    {
        KalenderEintraege.Clear();

        foreach (var schicht in Schichten)
        {
            var badgeColor = schicht.IstVollbesetzt
                ? Windows.UI.Color.FromArgb(255, 0, 100, 0)    // DarkGreen
                : schicht.IstUnbesetzt
                    ? Windows.UI.Color.FromArgb(255, 139, 0, 0)  // DarkRed
                    : Windows.UI.Color.FromArgb(255, 255, 140, 0); // DarkOrange

            KalenderEintraege.Add(new Controls.CalendarEntry
            {
                Id = schicht.VaId,
                Date = schicht.VaDatum,
                StartTime = schicht.VaStart ?? TimeSpan.Zero,
                EndTime = schicht.VaEnde ?? TimeSpan.Zero,
                Title = $"{SelectedAuftragName}",
                Details = schicht.Bemerkung ?? ObjektName,
                Badge = $"{schicht.MaAnzahlIst}/{schicht.MaAnzahl} MA",
                BadgeColor = badgeColor,
                Type = Controls.CalendarEntryType.Schicht,
                Data = schicht
            });
        }
    }

    partial void OnSelectedSchichtChanged(SchichtDetailItem? value)
    {
        if (value != null)
        {
            _ = LoadMitarbeiterFuerSchichtAsync(value);
        }
    }

    private async Task LoadMitarbeiterFuerSchichtAsync(SchichtDetailItem schicht)
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT p.MA_ID, m.Nachname, m.Vorname, m.Tel_Mobil,
                       p.VA_Start, p.VA_Ende
                FROM tbl_MA_VA_Planung p
                INNER JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.MA_ID
                WHERE p.VA_ID = @VaId
                  AND p.VADatum = @VaDatum
                  AND p.VA_Start = @VaStart
                ORDER BY m.Nachname, m.Vorname";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", schicht.VaId },
                { "VaDatum", schicht.VaDatum },
                { "VaStart", schicht.VaStart ?? TimeSpan.Zero }
            });

            ZugeordneteMitarbeiter.Clear();
            foreach (DataRow row in data.Rows)
            {
                ZugeordneteMitarbeiter.Add(new MaZuordnungDetailItem
                {
                    MaId = Convert.ToInt32(row["MA_ID"]),
                    Nachname = row["Nachname"]?.ToString() ?? "",
                    Vorname = row["Vorname"]?.ToString() ?? "",
                    TelMobil = row["Tel_Mobil"]?.ToString(),
                    VaStart = row["VA_Start"] != DBNull.Value ? TimeSpan.Parse(row["VA_Start"].ToString()!) : null,
                    VaEnde = row["VA_Ende"] != DBNull.Value ? TimeSpan.Parse(row["VA_Ende"].ToString()!) : null
                });
            }
        }, "Lade Mitarbeiter...");
    }

    #endregion

    #region Commands - Sidebar Navigation

    [RelayCommand]
    private void NavigateDienstplan()
    {
        _navigationService.NavigateTo<DienstplanMAViewModel>();
    }

    [RelayCommand]
    private void NavigatePlanung()
    {
        // Already on Planung Objekt
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

    #region Commands - Filter & Load

    [RelayCommand]
    private async Task FilterChangedAsync()
    {
        if (SelectedVaId.HasValue)
        {
            await LoadDienstplanAsync();
        }
    }

    #endregion

    #region Commands - Actions

    [RelayCommand]
    private void OpenSchnellauswahl()
    {
        if (SelectedSchicht != null)
        {
            _navigationService.NavigateTo<SchnellauswahlViewModel>(SelectedSchicht);
        }
        else
        {
            ShowError("Bitte Schicht auswählen");
        }
    }

    [RelayCommand]
    private void OpenAuftrag()
    {
        if (SelectedVaId.HasValue)
        {
            _navigationService.NavigateTo<AuftragstammViewModel>(SelectedVaId.Value);
        }
    }

    [RelayCommand]
    private void OpenMitarbeiter()
    {
        if (ZugeordneteMitarbeiter.Any())
        {
            var firstMa = ZugeordneteMitarbeiter.First();
            _navigationService.NavigateTo<MitarbeiterstammViewModel>(firstMa.MaId);
        }
    }

    [RelayCommand]
    private async Task RemoveMitarbeiterAsync(MaZuordnungDetailItem? mitarbeiter)
    {
        if (mitarbeiter == null || SelectedSchicht == null)
            return;

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Mitarbeiter entfernen",
            $"Möchten Sie {mitarbeiter.Vorname} {mitarbeiter.Nachname} von dieser Schicht entfernen?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                DELETE FROM tbl_MA_VA_Planung
                WHERE VA_ID = @VaId
                  AND MA_ID = @MaId
                  AND VADatum = @VaDatum
                  AND VA_Start = @VaStart";

            await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
            {
                { "VaId", SelectedSchicht.VaId },
                { "MaId", mitarbeiter.MaId },
                { "VaDatum", SelectedSchicht.VaDatum },
                { "VaStart", SelectedSchicht.VaStart ?? TimeSpan.Zero }
            });

            await LoadDienstplanAsync();

            ShowSuccess("Mitarbeiter entfernt");
        }, "Entferne Mitarbeiter...");
    }

    [RelayCommand]
    private async Task ExportAsync()
    {
        if (!SelectedVaId.HasValue)
        {
            ShowError("Bitte Auftrag auswählen");
            return;
        }

        // TODO: Implement export functionality
        await _dialogService.ShowMessageAsync("Export", "Export-Funktion noch nicht implementiert");
    }

    [RelayCommand]
    private async Task PrintAsync()
    {
        if (!SelectedVaId.HasValue)
        {
            ShowError("Bitte Auftrag auswählen");
            return;
        }

        // TODO: Implement print functionality
        await _dialogService.ShowMessageAsync("Drucken", "Druck-Funktion noch nicht implementiert");
    }

    #endregion
}

#region Helper Classes

public class AuftragLookupItem
{
    public int VaId { get; set; }
    public string Auftrag { get; set; } = string.Empty;
    public string Objekt { get; set; } = string.Empty;
    public string Veranstalter { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
}

public class SchichtDetailItem
{
    public int? VaStartId { get; set; }
    public int VaId { get; set; }
    public DateTime VaDatum { get; set; }
    public TimeSpan? VaStart { get; set; }
    public TimeSpan? VaEnde { get; set; }
    public int MaAnzahl { get; set; }
    public int MaAnzahlIst { get; set; }
    public string? Bemerkung { get; set; }
    public bool IstVollbesetzt { get; set; }
    public bool IstUnbesetzt { get; set; }

    public string DatumText => VaDatum.ToString("dd.MM.yyyy");
    public string DisplayText => $"{VaDatum:dd.MM.yyyy} {VaStart:hh\\:mm}-{VaEnde:hh\\:mm} ({MaAnzahlIst}/{MaAnzahl} MA)";
    public string StatusText => IstVollbesetzt ? "Vollbesetzt" : IstUnbesetzt ? "Unbesetzt" : $"{MaAnzahl - MaAnzahlIst} fehlen";
}

public class MaZuordnungDetailItem
{
    public int MaId { get; set; }
    public string Nachname { get; set; } = string.Empty;
    public string Vorname { get; set; } = string.Empty;
    public string? TelMobil { get; set; }
    public TimeSpan? VaStart { get; set; }
    public TimeSpan? VaEnde { get; set; }

    public string DisplayName => $"{Nachname}, {Vorname}";
    public string DisplayText => $"{Nachname}, {Vorname} ({TelMobil})";
}

#endregion
