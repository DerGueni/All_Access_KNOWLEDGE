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
/// ViewModel für Abwesenheitsverwaltung (frm_MA_Abwesenheit).
/// Zeigt alle Abwesenheiten eines Mitarbeiters mit Kalenderansicht.
/// </summary>
public partial class AbwesenheitViewModel : BaseViewModel, INavigationAware
{
    #region Properties - Mitarbeiter Auswahl

    [ObservableProperty]
    private int? _selectedMaId;

    [ObservableProperty]
    private ObservableCollection<MitarbeiterLookupItem> _mitarbeiterListe = new();

    [ObservableProperty]
    private string? _selectedMitarbeiterName;

    partial void OnSelectedMaIdChanged(int? value)
    {
        if (value.HasValue)
        {
            _ = LoadAbwesenheitenAsync();
        }
    }

    #endregion

    #region Properties - Filter

    [ObservableProperty]
    private DateTimeOffset _vonDatum = new DateTimeOffset(DateTime.Today.AddMonths(-3));

    [ObservableProperty]
    private DateTimeOffset _bisDatum = new DateTimeOffset(DateTime.Today.AddMonths(3));

    [ObservableProperty]
    private bool _zeigeNurAktive = true;

    #endregion

    #region Properties - Abwesenheiten Liste

    [ObservableProperty]
    private ObservableCollection<AbwesenheitDetailItem> _abwesenheiten = new();

    [ObservableProperty]
    private AbwesenheitDetailItem? _selectedAbwesenheit;

    partial void OnSelectedAbwesenheitChanged(AbwesenheitDetailItem? value)
    {
        if (value != null)
        {
            LoadAbwesenheitForEdit(value);
        }
    }

    #endregion

    #region Properties - Detail Bereich (Edit/New)

    [ObservableProperty]
    private bool _isEditMode;

    [ObservableProperty]
    private bool _isNewRecord;

    [ObservableProperty]
    private int _currentNvId;

    [ObservableProperty]
    private DateTimeOffset _editVonDat = DateTimeOffset.Now;

    [ObservableProperty]
    private DateTimeOffset _editBisDat = DateTimeOffset.Now;

    [ObservableProperty]
    private TimeOnly _editVonZeit = new TimeOnly(8, 0);

    [ObservableProperty]
    private TimeOnly _editBisZeit = new TimeOnly(17, 0);

    [ObservableProperty]
    private int? _selectedGrundId;

    [ObservableProperty]
    private ObservableCollection<NvGrund> _gruendeListe = new();

    [ObservableProperty]
    private bool _ganzerTag = true;

    partial void OnGanzerTagChanged(bool value)
    {
        // Zeiteingaben deaktivieren wenn ganzer Tag
        OnPropertyChanged(nameof(ZeitfelderSichtbar));
    }

    public bool ZeitfelderSichtbar => !GanzerTag;

    [ObservableProperty]
    private string? _bemerkung;

    #endregion

    #region Properties - Statistik

    [ObservableProperty]
    private int _anzahlAbwesenheiten;

    [ObservableProperty]
    private int _gesamtTage;

    [ObservableProperty]
    private int _urlaubTage;

    [ObservableProperty]
    private int _krankTage;

    [ObservableProperty]
    private int _sonstigeTage;

    #endregion

    #region Properties - Kalender

    [ObservableProperty]
    private ObservableCollection<Controls.CalendarEntry> _kalenderEintraege = new();

    [ObservableProperty]
    [NotifyPropertyChangedFor(nameof(MonatJahrText))]
    private int _kalenderMonat;

    [ObservableProperty]
    [NotifyPropertyChangedFor(nameof(MonatJahrText))]
    private int _kalenderJahr;

    public string MonatJahrText => new DateTime(KalenderJahr, KalenderMonat, 1).ToString("MMMM yyyy");

    partial void OnKalenderMonatChanged(int value)
    {
        UpdateKalenderEintraege();
    }

    partial void OnKalenderJahrChanged(int value)
    {
        UpdateKalenderEintraege();
    }

    #endregion

    public AbwesenheitViewModel(
        IDatabaseService databaseService,
        INavigationService navigationService,
        IDialogService dialogService)
        : base(databaseService, navigationService, dialogService)
    {
        var today = DateTime.Today;
        KalenderMonat = today.Month;
        KalenderJahr = today.Year;
    }

    public override async Task InitializeAsync()
    {
        await LoadMitarbeiterListeAsync();
        await LoadGruendeListeAsync();

        if (MitarbeiterListe.Any())
        {
            SelectedMaId = MitarbeiterListe.First().MaId;
        }
    }

    public void OnNavigatedTo(object? parameter)
    {
        if (parameter is int maId)
        {
            SelectedMaId = maId;
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

    private async Task LoadGruendeListeAsync()
    {
        await ExecuteWithLoadingAsync(async () =>
        {
            var sql = @"
                SELECT NV_Grund_ID, Bezeichnung
                FROM tbl_MA_NV_Gruende
                ORDER BY Bezeichnung";

            var data = await _databaseService.ExecuteQueryAsync(sql);

            GruendeListe.Clear();
            foreach (DataRow row in data.Rows)
            {
                GruendeListe.Add(new NvGrund
                {
                    GrundId = Convert.ToInt32(row["NV_Grund_ID"]),
                    Bezeichnung = row["Bezeichnung"]?.ToString() ?? ""
                });
            }
        }, "Lade Abwesenheitsgründe...");
    }

    [RelayCommand]
    private async Task LoadAbwesenheitenAsync()
    {
        if (!SelectedMaId.HasValue)
        {
            Abwesenheiten.Clear();
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            // Update selected MA name
            var selectedMa = MitarbeiterListe.FirstOrDefault(m => m.MaId == SelectedMaId.Value);
            SelectedMitarbeiterName = selectedMa?.DisplayName ?? "";

            // Load Abwesenheiten
            var sql = @"
                SELECT n.NV_ID, n.MA_ID, n.vonDat, n.bisDat, n.NV_Grund_ID,
                       n.Bemerkung, n.GanzerTag, n.vonZeit, n.bisZeit,
                       g.Bezeichnung as GrundText
                FROM tbl_MA_NVerfuegZeiten n
                LEFT JOIN tbl_MA_NV_Gruende g ON n.NV_Grund_ID = g.NV_Grund_ID
                WHERE n.MA_ID = @MaId
                  AND (n.vonDat BETWEEN @VonDatum AND @BisDatum
                       OR n.bisDat BETWEEN @VonDatum AND @BisDatum
                       OR (n.vonDat <= @VonDatum AND n.bisDat >= @BisDatum))
                ORDER BY n.vonDat DESC";

            var data = await _databaseService.ExecuteQueryAsync(sql, new Dictionary<string, object>
            {
                { "MaId", SelectedMaId.Value },
                { "VonDatum", VonDatum.DateTime },
                { "BisDatum", BisDatum.DateTime }
            });

            Abwesenheiten.Clear();
            foreach (DataRow row in data.Rows)
            {
                var vonZeit = row["vonZeit"] != DBNull.Value && row["vonZeit"] != null
                    ? TimeOnly.Parse(row["vonZeit"].ToString()!)
                    : (TimeOnly?)null;

                var bisZeit = row["bisZeit"] != DBNull.Value && row["bisZeit"] != null
                    ? TimeOnly.Parse(row["bisZeit"].ToString()!)
                    : (TimeOnly?)null;

                Abwesenheiten.Add(new AbwesenheitDetailItem
                {
                    NvId = Convert.ToInt32(row["NV_ID"]),
                    MaId = Convert.ToInt32(row["MA_ID"]),
                    VonDat = Convert.ToDateTime(row["vonDat"]),
                    BisDat = Convert.ToDateTime(row["bisDat"]),
                    GrundId = row["NV_Grund_ID"] != DBNull.Value ? Convert.ToInt32(row["NV_Grund_ID"]) : null,
                    GrundText = row["GrundText"]?.ToString() ?? "",
                    Bemerkung = row["Bemerkung"]?.ToString(),
                    GanzerTag = row["GanzerTag"] != DBNull.Value && Convert.ToBoolean(row["GanzerTag"]),
                    VonZeit = vonZeit,
                    BisZeit = bisZeit
                });
            }

            // Berechne Statistik
            BerrechneStatistik();

            // Update Kalender
            UpdateKalenderEintraege();

            ShowSuccess($"{Abwesenheiten.Count} Abwesenheiten geladen");
        }, "Lade Abwesenheiten...");
    }

    private void BerrechneStatistik()
    {
        AnzahlAbwesenheiten = Abwesenheiten.Count;

        GesamtTage = 0;
        UrlaubTage = 0;
        KrankTage = 0;
        SonstigeTage = 0;

        foreach (var abw in Abwesenheiten)
        {
            var tage = (abw.BisDat - abw.VonDat).Days + 1;
            GesamtTage += tage;

            var grundLower = abw.GrundText?.ToLower() ?? "";
            if (grundLower.Contains("urlaub") || grundLower.Contains("ferien"))
            {
                UrlaubTage += tage;
            }
            else if (grundLower.Contains("krank") || grundLower.Contains("krankheit"))
            {
                KrankTage += tage;
            }
            else
            {
                SonstigeTage += tage;
            }
        }
    }

    private void UpdateKalenderEintraege()
    {
        KalenderEintraege.Clear();

        // Nur Abwesenheiten für den aktuell angezeigten Monat
        var monatsStart = new DateTime(KalenderJahr, KalenderMonat, 1);
        var monatsEnde = monatsStart.AddMonths(1).AddDays(-1);

        foreach (var abw in Abwesenheiten)
        {
            // Überschneidung mit aktuellem Monat prüfen
            if (abw.BisDat < monatsStart || abw.VonDat > monatsEnde)
                continue;

            // Für jeden Tag der Abwesenheit einen Eintrag erstellen
            var startDate = abw.VonDat > monatsStart ? abw.VonDat : monatsStart;
            var endDate = abw.BisDat < monatsEnde ? abw.BisDat : monatsEnde;

            for (var date = startDate; date <= endDate; date = date.AddDays(1))
            {
                var entryType = DetermineAbwesenheitsType(abw.GrundText);
                var badgeColor = entryType switch
                {
                    Controls.CalendarEntryType.Urlaub => Windows.UI.Color.FromArgb(255, 255, 140, 0), // DarkOrange
                    Controls.CalendarEntryType.Krank => Windows.UI.Color.FromArgb(255, 178, 34, 34), // Firebrick
                    _ => Windows.UI.Color.FromArgb(255, 139, 0, 0) // DarkRed
                };

                var startTime = abw.GanzerTag ? TimeSpan.Zero : TimeSpan.FromHours(abw.VonZeit?.Hour ?? 0);
                var endTime = abw.GanzerTag ? TimeSpan.FromHours(24) : TimeSpan.FromHours(abw.BisZeit?.Hour ?? 0);

                KalenderEintraege.Add(new Controls.CalendarEntry
                {
                    Id = abw.NvId,
                    Date = date,
                    StartTime = startTime,
                    EndTime = endTime,
                    Title = abw.GrundText,
                    Details = abw.Bemerkung,
                    Badge = GetAbwesenheitBadge(entryType),
                    BadgeColor = badgeColor,
                    Type = entryType,
                    Data = abw
                });
            }
        }
    }

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

    private string GetAbwesenheitBadge(Controls.CalendarEntryType type)
    {
        return type switch
        {
            Controls.CalendarEntryType.Urlaub => "Urlaub",
            Controls.CalendarEntryType.Krank => "Krank",
            _ => "Abwesend"
        };
    }

    private void LoadAbwesenheitForEdit(AbwesenheitDetailItem abw)
    {
        CurrentNvId = abw.NvId;
        EditVonDat = new DateTimeOffset(abw.VonDat);
        EditBisDat = new DateTimeOffset(abw.BisDat);
        EditVonZeit = abw.VonZeit ?? new TimeOnly(8, 0);
        EditBisZeit = abw.BisZeit ?? new TimeOnly(17, 0);
        SelectedGrundId = abw.GrundId;
        GanzerTag = abw.GanzerTag;
        Bemerkung = abw.Bemerkung;

        IsNewRecord = false;
        IsEditMode = true;
    }

    #endregion

    #region CRUD Commands

    [RelayCommand]
    private void NewRecord()
    {
        CurrentNvId = 0;
        EditVonDat = DateTimeOffset.Now;
        EditBisDat = DateTimeOffset.Now;
        EditVonZeit = new TimeOnly(8, 0);
        EditBisZeit = new TimeOnly(17, 0);
        SelectedGrundId = GruendeListe.FirstOrDefault()?.GrundId;
        GanzerTag = true;
        Bemerkung = null;

        IsNewRecord = true;
        IsEditMode = true;

        ShowSuccess("Neue Abwesenheit");
    }

    [RelayCommand]
    private async Task SaveAsync()
    {
        if (!SelectedMaId.HasValue)
        {
            ShowError("Bitte Mitarbeiter auswählen");
            return;
        }

        if (EditBisDat.DateTime < EditVonDat.DateTime)
        {
            ShowError("Bis-Datum muss größer oder gleich Von-Datum sein");
            return;
        }

        if (!SelectedGrundId.HasValue)
        {
            ShowError("Bitte Abwesenheitsgrund auswählen");
            return;
        }

        await ExecuteWithLoadingAsync(async () =>
        {
            if (IsNewRecord)
            {
                // Insert
                var sql = @"
                    INSERT INTO tbl_MA_NVerfuegZeiten
                    (MA_ID, vonDat, bisDat, NV_Grund_ID, Bemerkung, GanzerTag, vonZeit, bisZeit)
                    VALUES (@MaId, @VonDat, @BisDat, @GrundId, @Bemerkung, @GanzerTag, @VonZeit, @BisZeit)";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "MaId", SelectedMaId.Value },
                    { "VonDat", EditVonDat.DateTime },
                    { "BisDat", EditBisDat.DateTime },
                    { "GrundId", SelectedGrundId.Value },
                    { "Bemerkung", (object?)Bemerkung ?? DBNull.Value },
                    { "GanzerTag", GanzerTag },
                    { "VonZeit", GanzerTag ? DBNull.Value : (object?)EditVonZeit.ToString("HH:mm:ss") },
                    { "BisZeit", GanzerTag ? DBNull.Value : (object?)EditBisZeit.ToString("HH:mm:ss") }
                });

                ShowSuccess("Abwesenheit gespeichert");
            }
            else
            {
                // Update
                var sql = @"
                    UPDATE tbl_MA_NVerfuegZeiten
                    SET vonDat = @VonDat,
                        bisDat = @BisDat,
                        NV_Grund_ID = @GrundId,
                        Bemerkung = @Bemerkung,
                        GanzerTag = @GanzerTag,
                        vonZeit = @VonZeit,
                        bisZeit = @BisZeit
                    WHERE NV_ID = @NvId";

                await _databaseService.ExecuteNonQueryAsync(sql, new Dictionary<string, object>
                {
                    { "NvId", CurrentNvId },
                    { "VonDat", EditVonDat.DateTime },
                    { "BisDat", EditBisDat.DateTime },
                    { "GrundId", SelectedGrundId.Value },
                    { "Bemerkung", (object?)Bemerkung ?? DBNull.Value },
                    { "GanzerTag", GanzerTag },
                    { "VonZeit", GanzerTag ? DBNull.Value : (object?)EditVonZeit.ToString("HH:mm:ss") },
                    { "BisZeit", GanzerTag ? DBNull.Value : (object?)EditBisZeit.ToString("HH:mm:ss") }
                });

                ShowSuccess("Abwesenheit aktualisiert");
            }

            IsEditMode = false;
            IsNewRecord = false;
            await LoadAbwesenheitenAsync();
        }, "Speichere Abwesenheit...");
    }

    [RelayCommand]
    private async Task DeleteAsync()
    {
        if (SelectedAbwesenheit == null || SelectedAbwesenheit.NvId <= 0)
        {
            ShowError("Bitte Abwesenheit auswählen");
            return;
        }

        var confirmed = await _dialogService.ShowConfirmationAsync(
            "Abwesenheit löschen",
            $"Möchten Sie die Abwesenheit vom {SelectedAbwesenheit.VonDatText} bis {SelectedAbwesenheit.BisDatText} wirklich löschen?");

        if (!confirmed)
            return;

        await ExecuteWithLoadingAsync(async () =>
        {
            await _databaseService.ExecuteNonQueryAsync(
                "DELETE FROM tbl_MA_NVerfuegZeiten WHERE NV_ID = @NvId",
                new Dictionary<string, object> { { "NvId", SelectedAbwesenheit.NvId } });

            ShowSuccess("Abwesenheit gelöscht");
            IsEditMode = false;
            IsNewRecord = false;
            await LoadAbwesenheitenAsync();
        }, "Lösche Abwesenheit...");
    }

    [RelayCommand]
    private void Cancel()
    {
        IsEditMode = false;
        IsNewRecord = false;
        SelectedAbwesenheit = null;
        ShowSuccess("Abgebrochen");
    }

    #endregion

    #region Kalender Navigation

    [RelayCommand]
    private void PreviousMonth()
    {
        if (KalenderMonat == 1)
        {
            KalenderMonat = 12;
            KalenderJahr--;
        }
        else
        {
            KalenderMonat--;
        }
    }

    [RelayCommand]
    private void NextMonth()
    {
        if (KalenderMonat == 12)
        {
            KalenderMonat = 1;
            KalenderJahr++;
        }
        else
        {
            KalenderMonat++;
        }
    }

    [RelayCommand]
    private void GoToCurrentMonth()
    {
        var today = DateTime.Today;
        KalenderMonat = today.Month;
        KalenderJahr = today.Year;
    }

    #endregion

    #region Filter Commands

    [RelayCommand]
    private async Task ApplyFilterAsync()
    {
        await LoadAbwesenheitenAsync();
    }

    [RelayCommand]
    private async Task ResetFilterAsync()
    {
        VonDatum = new DateTimeOffset(DateTime.Today.AddMonths(-3));
        BisDatum = new DateTimeOffset(DateTime.Today.AddMonths(3));
        ZeigeNurAktive = true;
        await LoadAbwesenheitenAsync();
    }

    #endregion

    #region Navigation Commands

    [RelayCommand]
    private void OpenMitarbeiter()
    {
        if (SelectedMaId.HasValue)
        {
            _navigationService.NavigateTo<MitarbeiterstammViewModel>(SelectedMaId.Value);
        }
    }

    #endregion
}

#region Helper Classes

public class AbwesenheitDetailItem
{
    public int NvId { get; set; }
    public int MaId { get; set; }
    public DateTime VonDat { get; set; }
    public DateTime BisDat { get; set; }
    public int? GrundId { get; set; }
    public string GrundText { get; set; } = "";
    public string? Bemerkung { get; set; }
    public bool GanzerTag { get; set; } = true;
    public TimeOnly? VonZeit { get; set; }
    public TimeOnly? BisZeit { get; set; }

    public string VonDatText => VonDat.ToString("dd.MM.yyyy");
    public string BisDatText => BisDat.ToString("dd.MM.yyyy");
    public int AnzahlTage => (BisDat - VonDat).Days + 1;
    public string ZeitraumText => $"{VonDatText} - {BisDatText}";
    public string DisplayText => GanzerTag
        ? $"{ZeitraumText}: {GrundText} ({AnzahlTage} Tag(e))"
        : $"{ZeitraumText} {VonZeit:HH\\:mm}-{BisZeit:HH\\:mm}: {GrundText}";
}

public class NvGrund
{
    public int GrundId { get; set; }
    public string Bezeichnung { get; set; } = "";

    public override string ToString() => Bezeichnung;
}

#endregion
